"""
稠密语义向量（S3 · 潜在语义分析 LSA）

【需求要的是什么，以及为什么这里不是预训练模型】
  需求 FR-M3-01 要求"基于 Embedding 模型将技能标签与需求文本向量化"，
  技术栈约定 `sentence-transformers` 类模型。但本机环境装不了 torch、
  也访问不了 HuggingFace（详见 docs/S3环境说明.md），因此改用
  **潜在语义分析（LSA）**：对 TF-IDF 矩阵做截断 SVD，得到低维稠密向量。

【LSA 为什么能"跨表述"匹配，而不只是字面】
  截断 SVD 把"词 × 文档"矩阵分解为 词向量 × 奇异值 × 文档向量 三部分。
  保留前 k 个奇异值，相当于把原始稀疏空间投影到"潜在主题"空间。
  效果是：**在相似上下文中出现的不同词，会被映射到相近的方向**。

  举例（本项目的真实场景）：
    语料里同时存在「ECharts 数据可视化」「图表库 前端图表」「数据看板 可视化」
    这三条技能/描述。它们共享 '可视化''图表' 等词，因此 SVD 会学到
    'ECharts' 与 '图表' 落在相近的潜在维度上。
    此后查询「需要做个数据大屏」——即便不含 'ECharts' 字样，
    它的向量也会与 'ECharts 数据可视化' 更接近，
    而不是与 '学术论文写作' 一样远。这是 TF-IDF 字面匹配做不到的。

【与预训练模型的差距，如实说明】
  LSA 的主题数是训练语料决定的，且**不含世界知识** ——
  它不知道 "Vue" 是一种前端框架，只知道 "Vue" 与哪些词共现。
  因此对"语料里从未共同出现过的跨域同义表述"效果有限。
  这正是需求 NFR-R-03 要求保留关键词降级通道的原因：
  语义匹配效果不达标时，系统仍能靠标签与关键词工作。

【维度选择】
  默认 128 维。理由：本项目语料规模（技能标签约千级）远小于
  预训练模型面对的规模，维度过高会让 SVD 记住噪声（过拟合），
  过低则区分力不足。128 是在"能判别"与"不记噪声"之间的折中，
  且向量存储开销小（1000 条 × 128 维 float32 ≈ 0.5 MB）。

作者：李泽宬
"""

from __future__ import annotations

import json
import math
import os
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

from .tfidf import TfidfVectorizer, SparseVector

#: 默认向量维度
DEFAULT_DIM = 128


@dataclass
class SemanticEmbedder:
    """把文本编码为低维稠密语义向量。

    用法：
        emb = SemanticEmbedder(dim=128)
        emb.fit(corpus, vectorizer)        # 拟合：TF-IDF → SVD
        v = emb.encode("需要 ECharts 图表指导")   # numpy 一维数组（已 L2 归一化）
        emb.save(dir) / SemanticEmbedder.load(dir)
    """

    dim: int = DEFAULT_DIM
    #: 拟合时用的 TF-IDF 向量化器（编码时需要它的词表与 IDF）
    vectorizer: TfidfVectorizer | None = None
    #: SVD 的右奇异向量转置：形状 (dim, n_features)
    components: np.ndarray | None = None
    #: 奇异值，用于诊断（解释各维承载多少信息）
    singular_values: np.ndarray | None = None
    #: 语料平均向量，用于"零向量兜底"（查询词全在词表外时不至于全零）
    mean_vector: np.ndarray | None = None
    _fitted: bool = False

    # ------------------------------------------------------------------
    # 拟合
    # ------------------------------------------------------------------

    def fit(self, corpus: list[str], vectorizer: TfidfVectorizer,
            extra_context: list[str] | None = None) -> "SemanticEmbedder":
        """用语料拟合 SVD。

        @param corpus         主训练语料（技能标签 + 描述）
        @param vectorizer     已 fit 的 TF-IDF 向量化器
        @param extra_context  额外语料（如历史需求描述），用于让主题空间
                              同时覆盖"用户怎么说"和"标签怎么写"
        """
        if not corpus:
            raise ValueError("训练语料为空")

        vectorizer = vectorizer or TfidfVectorizer()
        docs = list(corpus) + list(extra_context or [])

        # 构造稀疏矩阵（行 = 文档，列 = 词表）
        n_features = len(vectorizer.vocab)
        if n_features == 0:
            raise ValueError("词表为空，请先拟合 TF-IDF")

        rows: list[int] = []
        cols: list[int] = []
        vals: list[float] = []
        for r, doc in enumerate(docs):
            sparse = vectorizer.transform_sparse(doc)
            for token, w in sparse.items():
                c = vectorizer.vocab.get(token)
                if c is not None:
                    rows.append(r)
                    cols.append(c)
                    vals.append(w)

        if not vals:
            raise ValueError("所有文档都未产生有效 token，无法拟合")

        # 说明：本环境无 scipy，也没有稀疏矩阵库，因此直接用 numpy 构造稠密矩阵。
        # 语料规模为千级文档 × 数万词表，故用**随机化 SVD**（见 randomized_svd）：
        # 它只做矩阵乘法，复杂度 O(m·n·k)，不必对整矩阵做完整分解。
        matrix = np.zeros((len(docs), n_features), dtype=np.float32)
        matrix[rows, cols] = vals

        # 词频加权：对 TF-IDF 权重取平方根，
        # 这是 LSA 的常见做法 —— 平方根压缩了高频词的支配作用，
        # 让 SVD 更容易捕捉"中等频率但有区分度"的词。
        matrix = np.sqrt(np.abs(matrix)) * np.sign(matrix)

        k = min(self.dim, min(matrix.shape) - 1)
        if k < 2:
            raise ValueError(f"语料太小，无法做 {self.dim} 维 SVD（有效秩 {k}）")

        u, s, vt = randomized_svd(matrix, n_components=k, n_iter=5, seed=42)
        self.components = vt.astype(np.float32)          # (k, n_features)
        self.singular_values = s.astype(np.float32)
        self.vectorizer = vectorizer
        self.dim = k

        # 平均向量：用于零向量兜底
        if len(docs) > 0:
            encoded = [self._project(matrix[i]) for i in range(min(len(docs), 200))]
            self.mean_vector = np.mean(np.vstack(encoded), axis=0).astype(np.float32)
            self.mean_vector = _l2(self.mean_vector)

        self._fitted = True
        return self

    # ------------------------------------------------------------------
    # 编码
    # ------------------------------------------------------------------

    def _project(self, sparse_row: np.ndarray) -> np.ndarray:
        """把一行 TF-IDF 投影到潜在空间：v = row · V^T。"""
        assert self.components is not None
        v = self.components @ sparse_row.astype(np.float32)
        return _l2(v)

    def has_known_terms(self, text: str) -> bool:
        """文本是否至少含一个词表内的 token。

        <p>用于检索前的前置判定。**为什么必须有它**：
        {@link encode} 对全部词表外的文本会返回 mean_vector 兜底（见该方法注释），
        于是所有表外查询得到**同一个向量**，检索就会返回同一批文档。
        实测三条毫无关系的查询（「宿舍的网又断了」「中午吃什么好呢有点饿」
        「这个周末打算去看电影」）因此返回了完全相同的
        JVM 调优 / Matplotlib 绘图 / 数据标注，且分数稳定在 0.6824 ——
        把"没有相似度可言"包装成了 68% 的匹配。

        @param text 文本
        @return     含至少一个词表内 token 返回 True
        """
        if not self._fitted:
            raise RuntimeError("嵌入器尚未拟合，请先调用 fit() 或 load()")
        sparse = self.vectorizer.transform_sparse(text)
        return bool(sparse)

    def encode(self, text: str) -> np.ndarray:
        """把文本编码为 L2 归一化的稠密向量。

        @param text 文本
        @return     float32 一维数组，长度 = dim；无法编码时返回平均向量
        """
        if not self._fitted:
            raise RuntimeError("嵌入器尚未拟合，请先调用 fit() 或 load()")
        assert self.vectorizer is not None and self.components is not None

        sparse = self.vectorizer.transform_sparse(text)
        if not sparse:
            # 全部词表外（生僻表述）：用平均向量兜底。
            #
            # 注意：调用方**不应**把这里的兜底当成"有结果" ——
            # 所有表外文本会得到同一个向量，检索结果也就完全相同。
            # 检索路径必须先调 has_known_terms() 判定，再决定是否编码。
            # 保留兜底是为了 encode_batch 等场景不至于崩，不是为了让检索有输出。
            return self.mean_vector.copy() if self.mean_vector is not None \
                else np.zeros(self.dim, dtype=np.float32)

        row = np.zeros(len(self.vectorizer.vocab), dtype=np.float32)
        for token, w in sparse.items():
            c = self.vectorizer.vocab.get(token)
            if c is not None:
                row[c] = w
        row = np.sqrt(np.abs(row)) * np.sign(row)
        v = self._project(row)
        if not np.any(v):
            return self.mean_vector.copy() if self.mean_vector is not None \
                else np.zeros(self.dim, dtype=np.float32)
        return v

    def encode_batch(self, texts: list[str]) -> np.ndarray:
        """批量编码，返回 (n, dim) 矩阵。"""
        if not texts:
            return np.zeros((0, self.dim), dtype=np.float32)
        return np.vstack([self.encode(t) for t in texts])

    # ------------------------------------------------------------------
    # 持久化
    # ------------------------------------------------------------------

    def save(self, path: str | Path) -> None:
        """保存为 .npz（数组）+ .json（配置与词表）。"""
        path = Path(path)
        path.mkdir(parents=True, exist_ok=True)
        arrays = {"components": self.components}
        if self.singular_values is not None:
            arrays["singular_values"] = self.singular_values
        if self.mean_vector is not None:
            arrays["mean_vector"] = self.mean_vector
        np.savez_compressed(path / "embedder.npz", **arrays)

        assert self.vectorizer is not None
        meta = {"ver": 1, "dim": int(self.dim),
                "ngrams": list(self.vectorizer.ngrams),
                "max_features": self.vectorizer.max_features,
                "doc_count": self.vectorizer.doc_count}
        (path / "embedder.json").write_text(
            json.dumps(meta, ensure_ascii=False), encoding="utf-8")
        self.vectorizer.save(path / "vectorizer.json")

    @classmethod
    def load(cls, path: str | Path) -> "SemanticEmbedder":
        """从目录恢复。"""
        path = Path(path)
        meta = json.loads((path / "embedder.json").read_text(encoding="utf-8"))
        vec = TfidfVectorizer.load(path / "vectorizer.json")
        emb = cls(dim=int(meta.get("dim", DEFAULT_DIM)), vectorizer=vec)
        with np.load(path / "embedder.npz") as data:
            emb.components = data["components"].astype(np.float32)
            emb.singular_values = data["singular_values"].astype(np.float32) \
                if "singular_values" in data else None
            emb.mean_vector = data["mean_vector"].astype(np.float32) \
                if "mean_vector" in data else None
        emb._fitted = True
        return emb

    def diagnostics(self) -> dict:
        """输出诊断信息（供训练产物归档与问题排查）。"""
        if not self._fitted or self.singular_values is None:
            return {}
        s = self.singular_values
        energy = (s ** 2) / float(np.sum(s ** 2))
        return {
            "dim": int(self.dim),
            "vocab_size": len(self.vectorizer.vocab) if self.vectorizer else 0,
            "top5_singular_values": [round(float(x), 4) for x in s[:5]],
            "energy_top10": round(float(np.sum(energy[:10])), 4),
            "energy_total": round(float(np.sum(energy)), 4),
        }


# ---------------------------------------------------------------------------
# 工具函数
# ---------------------------------------------------------------------------


def _l2(v: np.ndarray) -> np.ndarray:
    """L2 归一化；零向量原样返回（避免除零）。"""
    n = float(np.linalg.norm(v))
    if n <= 1e-12:
        return v.astype(np.float32)
    return (v / n).astype(np.float32)


def cosine(a: np.ndarray, b: np.ndarray) -> float:
    """余弦相似度（两向量通常已归一化，但仍做防御性归一）。"""
    if a is None or b is None or a.size == 0 or b.size == 0:
        return 0.0
    na = float(np.linalg.norm(a))
    nb = float(np.linalg.norm(b))
    if na <= 1e-12 or nb <= 1e-12:
        return 0.0
    return float(np.clip(float(np.dot(a, b)) / (na * nb), 0.0, 1.0))


def randomized_svd(matrix: np.ndarray, n_components: int = 128,
                   n_iter: int = 5, seed: int = 42) -> tuple:
    """随机化截断 SVD（Halko et al. 2009《Finding structure with randomness》）。

    【为什么不用 numpy.linalg.svd 直接算】
      直接做完整 SVD 的复杂度是 O(min(m,n)^2 · max(m,n))，
      矩阵为 文档数 × 词表大小。本项目词表可达数万，
      完整 SVD 会明显变慢且没必要 —— 我们只要前 k 个奇异三元组。

    【随机化 SVD 的思路（三步）】
      1. **随机投影**：取随机矩阵 Ω (n × (k+p))，算 Y = A·Ω。
         因为随机向量几乎必然与 A 的主子空间有非零投影，
         Y 的列空间以极高概率包含了 A 的主要奇异方向。
      2. **正交化 + 幂迭代**：对 Y 做 QR 得正交基 Q；
         再用 A 与 A^T 反复作用若干次（幂迭代），
         放大主奇异值的分量，使衰减缓慢的谱也能被准确捕捉。
      3. **小矩阵分解**：B = Q^T·A 只有 (k+p) × n，对 B 做精确 SVD 得到
         小尺寸的奇异三元组，再由 A ≈ Q·(U_b·S·V^T) 还原右奇异向量。

      相比完整 SVD，复杂度降到 O(m·n·k)，且只需矩阵乘法，
      不依赖 scipy / LAPACK 的完整分解接口。
    """
    rng = np.random.default_rng(seed)
    m, n = matrix.shape
    k = max(2, min(n_components, min(m, n) - 1))
    oversample = min(10, max(2, k // 5))
    l = min(k + oversample, min(m, n))

    # 步骤 1：随机投影
    omega = rng.standard_normal((n, l)).astype(np.float32)
    y = matrix @ omega

    # 步骤 2：幂迭代（提升谱衰减缓慢时的精度）
    for _ in range(max(0, n_iter)):
        q, _ = np.linalg.qr(y)
        z = matrix.T @ q
        q2, _ = np.linalg.qr(z)
        y = matrix @ q2

    q, _ = np.linalg.qr(y)

    # 步骤 3：投影到低维后做精确 SVD
    b = q.T @ matrix                       # (l, n)
    ub, s, vt = np.linalg.svd(b, full_matrices=False)

    u = q @ ub                             # (m, l)
    return u[:, :k], s[:k], vt[:k, :]
