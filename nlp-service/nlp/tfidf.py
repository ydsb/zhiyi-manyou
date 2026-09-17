"""
TF-IDF 向量化（S3 · 语义匹配第一步）

【为什么需要它，而不是直接比字面】
  M3 的关键词降级版是"标签命中率"：必须字面匹配才算相关。
  但项目要解决的正是"艺术设计专业的『动态交互效果』与计算机专业的
  『Vue 响应式动画』描述同一需求却搜不到"（需求文档 1.2 节）。
  要跨越这种表述差异，就必须把文本放进一个**连续向量空间**，
  让"用词不同但语义相近"的文本在空间里彼此靠近。

  TF-IDF 是这个空间的第一步：它把文本变成稀疏向量，
  并且**自动压低高频词、抬高稀有词** —— 对技能文本尤其重要，
  因为 '开发''设计' 这类词几乎每张卡片都有，而 '体素建模' 出现一次就有区分度。

【IDF 为什么要「拟合」而不是每次现算】
  若每次请求都用"当前这批候选文档"算 IDF，同一段文本在不同候选集合下
  会得到不同向量 —— 同一个需求昨天匹配 0.8、今天匹配 0.6，
  用户会觉得系统不稳定，且无法复现问题。
  因此 IDF 必须由**固定的技能语料**预先拟合并持久化，
  查询时复用。这与"向量与关系库一致"的要求（需求 DR 4.3）也吻合。

作者：李泽宬
"""

from __future__ import annotations

import json
import math
import os
from collections import Counter
from dataclasses import dataclass, field
from pathlib import Path

from .tokenizer import tokenize

#: 默认 n-gram 阶数。2/3 阶是中文短文本的经验最优区间：
#: 单字噪声大，4 阶以上在 2~8 字的技能标签里几乎无覆盖。
DEFAULT_NGRAMS = (2, 3)


@dataclass
class TfidfVectorizer:
    """TF-IDF 向量化器。

    用法：
        vec = TfidfVectorizer()
        vec.fit(corpus)                  # 用技能语料拟合 IDF
        v = vec.transform("需要 ECharts 图表指导")
        vec.save(path) / TfidfVectorizer.load(path)
    """

    ngrams: tuple[int, ...] = DEFAULT_NGRAMS
    max_features: int = 60000
    min_df: int = 1

    #: token → 列索引
    vocab: dict[str, int] = field(default_factory=dict)
    #: 每个 token 的 IDF
    idf: dict[str, float] = field(default_factory=dict)
    #: 拟合语料的文档数（用于增量 IDF 估计）
    doc_count: int = 0
    _fitted: bool = False

    # ------------------------------------------------------------------
    # 拟合与持久化
    # ------------------------------------------------------------------

    def fit(self, corpus: list[str]) -> "TfidfVectorizer":
        """用一批文档拟合词表与 IDF。

        @param corpus 文档列表（本项目中是全部技能标签 + 描述）
        """
        df: Counter[str] = Counter()
        for doc in corpus:
            df.update(set(self._tokens(doc)))

        total = max(1, len(corpus))
        self.doc_count = len(corpus)

        # 只保留出现次数达标、且不超过词表上限的 token
        # （高频 token 已达上限时按文档频率降序截取，保证保留最有区分度的）
        items = [(t, c) for t, c in df.items() if c >= self.min_df]
        items.sort(key=lambda kv: (-kv[1], kv[0]))
        if len(items) > self.max_features:
            items = items[: self.max_features]

        self.vocab = {t: i for i, (t, _) in enumerate(sorted(items))}

        # 平滑 IDF：idf = ln((1 + N) / (1 + df)) + 1
        # 用 +1 平滑而不是经典的 ln(N/df)：
        # 后者在 df == N（每个文档都有该词）时为 0，会把这类词完全抹掉；
        # 平滑版给一个正的下界，避免"某个 token 一旦全语料出现就彻底失效"。
        self.idf = {
            t: math.log((1 + total) / (1 + c)) + 1.0
            for t, c in items
        }
        self._fitted = True
        return self

    def save(self, path: str | Path) -> None:
        """持久化（JSON，便于人工检查与版本对比）。"""
        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)
        payload = {
            "version": 1,
            "ngrams": list(self.ngrams),
            "max_features": self.max_features,
            "min_df": self.min_df,
            "doc_count": self.doc_count,
            "vocab": self.vocab,
            "idf": self.idf,
        }
        # 原子写：先写临时文件再替换，避免写到一半被读取
        tmp = path.with_suffix(path.suffix + ".tmp")
        tmp.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
        os.replace(tmp, path)

    @classmethod
    def load(cls, path: str | Path) -> "TfidfVectorizer":
        """从持久化文件恢复。"""
        payload = json.loads(Path(path).read_text(encoding="utf-8"))
        vec = cls(
            ngrams=tuple(payload.get("ngrams", DEFAULT_NGRAMS)),
            max_features=payload.get("max_features", 60000),
            min_df=payload.get("min_df", 1),
        )
        vec.vocab = payload["vocab"]
        vec.idf = payload["idf"]
        vec.doc_count = payload.get("doc_count", 0)
        vec._fitted = True
        return vec

    # ------------------------------------------------------------------
    # 向量化
    # ------------------------------------------------------------------

    def _tokens(self, text: str) -> list[str]:
        return tokenize(text, ngrams=self.ngrams)

    def transform_sparse(self, text: str) -> dict[str, float]:
        """转成稀疏向量：{token: 权重}。

        权重 = (1 + log(tf)) × idf，然后做 **L2 归一化**。
        L2 归一化后，余弦相似度就等于点积，检索时省一次除法。

        @param text 文本
        @return     token → 权重（已归一化）；无有效 token 时返回空 dict
        """
        if not self._fitted:
            raise RuntimeError("向量化器尚未拟合，请先调用 fit() 或 load()")

        counts = Counter(self._tokens(text))
        raw: dict[str, float] = {}
        for token, tf in counts.items():
            idx = self.vocab.get(token)
            if idx is None:
                continue        # 词表外 token 直接丢弃
            w = (1.0 + math.log(tf)) * self.idf.get(token, 1.0)
            if w > 0:
                raw[token] = w

        norm = math.sqrt(sum(v * v for v in raw.values()))
        if norm <= 0:
            return {}
        return {t: v / norm for t, v in raw.items()}

    def transform(self, text: str) -> "SparseVector":
        """转成 SparseVector 对象（便于与其他向量运算）。"""
        return SparseVector.from_dict(self.transform_sparse(text))

    def top_terms(self, text: str, top: int = 8) -> list[tuple[str, float]]:
        """返回权重最高的若干 token —— 用于向用户解释"系统看重了哪些词"。"""
        sparse = self.transform_sparse(text)
        return sorted(sparse.items(), key=lambda kv: -kv[1])[:top]


# ---------------------------------------------------------------------------
# 稀疏向量
# ---------------------------------------------------------------------------


@dataclass
class SparseVector:
    """稀疏向量：只存非零项。技能文本长度短，稀疏度通常在 95% 以上。"""

    items: dict[str, float] = field(default_factory=dict)

    @classmethod
    def from_dict(cls, d: dict[str, float]) -> "SparseVector":
        return cls(items=dict(d))

    def __len__(self) -> int:
        return len(self.items)

    def norm(self) -> float:
        return math.sqrt(sum(v * v for v in self.items.values()))

    def cosine(self, other: "SparseVector") -> float:
        """余弦相似度。两个向量都假设已 L2 归一化，但仍做防御性归一。"""
        if not self.items or not other.items:
            return 0.0
        na, nb = self.norm(), other.norm()
        if na <= 0 or nb <= 0:
            return 0.0
        # 遍历较小的一侧，复杂度 O(min(|a|,|b|))
        small, large = (self.items, other.items) if len(self.items) <= len(other.items) \
            else (other.items, self.items)
        dot = sum(w * large.get(t, 0.0) for t, w in small.items())
        return max(0.0, min(1.0, dot / (na * nb)))

    def overlap(self, other: "SparseVector", top: int = 8) -> list[str]:
        """共有 token，按两侧权重之和降序 —— 解释相似原因用。"""
        common = set(self.items) & set(other.items)
        ordered = sorted(common, key=lambda t: -(self.items[t] + other.items[t]))
        # 去掉被更长 token 包含的短 token，读起来更像"关键词"
        result: list[str] = []
        for t in ordered:
            if any(t in longer for longer in result):
                continue
            result.append(t)
            if len(result) >= top:
                break
        return result


def build_vocabulary_stats(vectorizer: TfidfVectorizer) -> dict:
    """输出词表统计，供训练产物归档与问题排查。"""
    if not vectorizer._fitted:
        return {}
    sizes: Counter[int] = Counter(len(t) for t in vectorizer.vocab)
    return {
        "token_count": len(vectorizer.vocab),
        "doc_count": vectorizer.doc_count,
        "avg_idf": round(sum(vectorizer.idf.values()) / max(1, len(vectorizer.idf)), 4),
        "min_idf": round(min(vectorizer.idf.values()), 4) if vectorizer.idf else 0,
        "max_idf": round(max(vectorizer.idf.values()), 4) if vectorizer.idf else 0,
        "length_distribution": dict(sorted(sizes.items())),
    }
