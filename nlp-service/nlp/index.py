"""
向量索引与相似度检索（S3 · FR-M3-02 / FR-M3-04）

【需求要的是 ANN，这里为什么默认精确检索】
  需求 FR-M3-02 写的是"通过 ANN 近似最近邻检索实现语义级技能匹配"，
  技术栈约定 Elasticsearch 的 dense_vector + HNSW。但本机无 Docker，
  起不了 ES（详见 docs/S3环境说明.md）。

  更关键的是：**本项目当前规模下，精确检索既更快也更准**。
  技能标签约千级，一次查询只有几千次 128 维点积 —— numpy 矩阵乘法毫秒级完成。
  而 HNSW 的价值在于百万级向量下避免全量扫描，
  在千级规模上它带来的只有"近似误差"与"索引维护成本"。

  因此设计为**可切换**：
    - `exact`   精确余弦检索（默认）—— 结果可复现，便于测试与验收
    - `lsh`     随机超平面 LSH 预筛 + 精排 —— 规模上万时启用
  统一走 `VectorIndex.search()`，上层业务代码无需关心用了哪种。
  日后接入 ES/HNSW 时，只需新增一个实现类。

【相似度为什么用余弦而不是欧氏距离】
  文本向量关心的是"方向"（语义构成）而非"长度"（文本长短）。
  两段文本一长一短，只要语义构成相近就应判为相似 ——
  余弦对长度不敏感，且在向量已 L2 归一化时等价于点积，计算最省。

【图谱关系为什么在检索阶段加成，而不是训练进向量】
  实测结论（详见 corpus.py 的注释）：把图谱边拼接成训练语料会**降低**
  关联技能的相似度 —— 因为共享词的文档频率升高、IDF 降低，
  归一化后权重反被压低。
  因此改为在检索时做显式加成：可控、可解释（写进 reasons）、可关闭。

作者：李泽宬
"""

from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

from .embedder import SemanticEmbedder, _l2


@dataclass
class IndexItem:
    """索引中的一条记录。"""

    key: str                       # 唯一标识（技能 ID / 卡片 ID）
    kind: str                      # 类型：SKILL / DEMAND / PROFILE
    text: str                      # 原始文本（用于解释与展示）
    vector: np.ndarray             # L2 归一化向量
    meta: dict = field(default_factory=dict)


@dataclass
class SearchHit:
    """一条检索结果。"""

    key: str
    kind: str
    text: str
    score: float                   # 最终得分（语义 + 图谱加成，已封顶 1.0）
    meta: dict = field(default_factory=dict)
    #: 可解释性：命中的共有词、图谱加成说明等（FR-M3-05 要求给出理由）
    reasons: list[str] = field(default_factory=list)
    #: 纯语义相似度（不含图谱加成），便于排查与调参
    semantic_score: float = 0.0
    #: 图谱加成值
    relation_boost: float = 0.0


class VectorIndex:
    """向量索引 + 可选图谱关系加成。

    用法：
        idx = VectorIndex(embedder)
        idx.add("skill:1", "SKILL", "ECharts 数据可视化", meta={...})
        idx.set_relations({(1, 4): "COMPLEMENT"})     # 图谱边
        idx.build()
        hits = idx.search("需要做数据大屏", top_k=5)
    """

    #: 各类关系的默认加成系数（0~1，表示"向满分拉近的比例"）
    #:
    #: 取值依据：同义关系最强（几乎等价，给 0.30），先决/互补次之（0.15/0.12），
    #: 都明显小于 1 —— 加成只是"提权"，不能替代语义证据本身。
    #: 若设得过大，一个关系边就能把无关技能顶到首位，反而破坏准确性。
    DEFAULT_RELATION_WEIGHTS = {
        "SYNONYM": 0.30,
        "PREREQUISITE": 0.15,
        "COMPLEMENT": 0.12,
    }

    def __init__(self, embedder: SemanticEmbedder, mode: str = "exact",
                 num_hash_bits: int = 12, num_tables: int = 6, seed: int = 42,
                 relation_weights: dict[str, float] | None = None):
        """
        @param mode             检索模式：exact 精确 / lsh 局部敏感哈希预筛
        @param num_hash_bits    LSH 每张表的哈希位数（决定桶数 2^bits）
        @param num_tables       LSH 表数量（越多召回越高、内存越大）
        @param relation_weights 图谱关系加成系数，默认见 DEFAULT_RELATION_WEIGHTS
        """
        self.embedder = embedder
        self.mode = mode
        self.num_hash_bits = num_hash_bits
        self.num_tables = num_tables
        self.seed = seed
        self.relation_weights = dict(relation_weights or self.DEFAULT_RELATION_WEIGHTS)

        self._items: list[IndexItem] = []
        self._by_key: dict[str, int] = {}
        self._matrix: np.ndarray | None = None
        #: 图谱边：{技能数字 id: [(对方 id, 关系, 权重)]}
        self._relations: dict[int, list[tuple[int, str, float]]] = {}
        # LSH
        self._planes: list[np.ndarray] | None = None
        self._tables: list[dict[int, list[int]]] | None = None
        self._dirty = True

    # ------------------------------------------------------------------
    # 构建
    # ------------------------------------------------------------------

    def add(self, key: str, kind: str, text: str, meta: dict | None = None,
            vector: np.ndarray | None = None) -> None:
        """添加一条记录。向量可由外部提供（复用已算好的），否则现算。"""
        vec = vector if vector is not None else self.embedder.encode(text)
        item = IndexItem(key, kind, text, vec, meta or {})
        if key in self._by_key:
            # 同 key 覆盖（技能描述更新时常见）
            self._items[self._by_key[key]] = item
        else:
            self._by_key[key] = len(self._items)
            self._items.append(item)
        self._dirty = True

    def add_many(self, rows: list[tuple[str, str, str, dict]]) -> None:
        """批量添加：(key, kind, text, meta)。"""
        for key, kind, text, meta in rows:
            self.add(key, kind, text, meta)

    def set_relations(self, pairs: list[dict]) -> None:
        """设置图谱关系边，供检索时加成。

        @param pairs 形如 [{"fromId":1,"toId":2,"relation":"COMPLEMENT"}, ...]
                     也接受 (fromId, toId, relation) 三元组
        """
        self._relations = {}
        for p in pairs:
            if isinstance(p, dict):
                a, b, rel = p.get("fromId"), p.get("toId"), p.get("relation")
            else:
                a, b, rel = p[0], p[1], p[2]
            if a is None or b is None:
                continue
            a, b = int(a), int(b)
            w = self.relation_weights.get(str(rel).upper(), 0.0)
            if w <= 0:
                continue
            # 双向记录：图谱关系对检索是对称的（A 与 B 互补 ⇔ B 与 A 互补）
            self._relations.setdefault(a, []).append((b, str(rel), w))
            self._relations.setdefault(b, []).append((a, str(rel), w))

    def build(self) -> "VectorIndex":
        """组装矩阵与（可选的）LSH 表。"""
        n = len(self._items)
        dim = self.embedder.dim
        self._matrix = np.zeros((n, dim), dtype=np.float32)
        for i, item in enumerate(self._items):
            v = item.vector
            if v.shape[0] != dim:
                v = _l2(np.resize(v, dim))
            self._matrix[i] = v

        if self.mode == "lsh" and n > 0:
            self._build_lsh()

        self._dirty = False
        return self

    def _build_lsh(self) -> None:
        """构造随机超平面 LSH 表。

        【原理】随机取若干超平面（法向量），用 sign(v·p) 得到 0/1 位。
        相近向量在同一批超平面上的符号大概率一致 —— 于是"有相同符号串"
        就成为"可能相近"的廉价判据。多张表并联可降低单表漏召风险。

        【为什么本项目默认不用它】千级规模下精确检索已是毫秒级，
        LSH 只会引入召回损失。保留它是为了规模增长后的平滑切换。
        """
        assert self._matrix is not None
        rng = np.random.default_rng(self.seed)
        dim = self.embedder.dim
        self._planes = []
        self._tables = []
        for _ in range(self.num_tables):
            planes = rng.standard_normal((self.num_hash_bits, dim)).astype(np.float32)
            self._planes.append(planes)
            signs = (self._matrix @ planes.T) > 0            # (n, bits)
            codes = np.packbits(signs.astype(np.uint8), axis=1)
            table: dict[int, list[int]] = {}
            for i in range(self._matrix.shape[0]):
                code = int.from_bytes(codes[i].tobytes(), "big")
                table.setdefault(code, []).append(i)
            self._tables.append(table)

    # ------------------------------------------------------------------
    # 检索
    # ------------------------------------------------------------------

    def search(self, query: str | np.ndarray, top_k: int = 10,
               kind: str | None = None, min_score: float = 0.0,
               explain: bool = True, use_relations: bool = True,
               seed_skill_ids: list[int] | None = None) -> list[SearchHit]:
        """检索最相似的记录。

        @param query          查询文本或已编码向量
        @param top_k          返回条数
        @param kind           只检索某类型（SKILL / DEMAND / PROFILE）
        @param min_score      相似度下限（低于此值不返回）
        @param explain        是否生成可解释理由（FR-M3-05）
        @param use_relations  是否启用图谱关系加成（可关闭以便对比效果）
        @param seed_skill_ids 查询已关联的技能 id（如需求卡片已选技能标签）。
                              命中这些技能在图谱上的邻居时给予加成 ——
                              这是"标签 + 图谱"的结合点。
        @return               按最终得分降序的结果
        """
        if self._dirty:
            self.build()
        if self._matrix is None or self._matrix.shape[0] == 0:
            return []

        q = query if isinstance(query, np.ndarray) else self.embedder.encode(query)
        q = _l2(q)

        candidates = self._candidate_indices(q)
        if not candidates:
            return []

        idx_arr = np.asarray(candidates, dtype=np.int64)
        # 余弦相似度：向量已归一化，故等价于点积
        sem = self._matrix[idx_arr] @ q

        if kind:
            mask = np.array([self._items[i].kind == kind for i in idx_arr])
            idx_arr, sem = idx_arr[mask], sem[mask]
        if idx_arr.size == 0:
            return []

        # 图谱加成：对与 seed 技能存在图谱关系的候选提权
        boost = np.zeros(idx_arr.shape[0], dtype=np.float32)
        boost_note: dict[int, str] = {}
        if use_relations and seed_skill_ids and self._relations:
            for pos, i in enumerate(idx_arr):
                item = self._items[int(i)]
                item_id = self._skill_id_of(item)
                if item_id is None:
                    continue
                for other, rel, w in self._relations.get(item_id, []):
                    if other in seed_skill_ids:
                        if w > boost[pos]:
                            boost[pos] = w
                            boost_note[int(i)] = f"与查询所选技能在图谱上是「{rel_label(rel)}」关系，提权 {w:.0%}"

        # 最终得分：向满分拉近 boost 的比例（而非直接相加），
        # 这样加成幅度有界，不会出现"语义 0.2 + 加成 0.3 = 0.5 超过语义 0.45"的倒挂
        final = sem + boost * (1.0 - sem)

        k = min(top_k, idx_arr.size)
        top_pos = np.argpartition(-final, k - 1)[:k]
        top_pos = top_pos[np.argsort(-final[top_pos])]

        hits: list[SearchHit] = []
        qtext = query if isinstance(query, str) else ""
        for p in top_pos:
            i = int(idx_arr[p])
            score = float(np.clip(final[p], 0.0, 1.0))
            if score < min_score:
                continue
            item = self._items[i]
            reasons: list[str] = []
            if explain and qtext:
                reasons = self._explain(qtext, item)
            if i in boost_note:
                reasons.insert(0, boost_note[i])
            hits.append(SearchHit(
                key=item.key, kind=item.kind, text=item.text,
                score=round(score, 4), meta=item.meta, reasons=reasons,
                semantic_score=round(float(np.clip(sem[p], 0.0, 1.0)), 4),
                relation_boost=round(float(boost[p]), 4)))
        return hits

    def _skill_id_of(self, item: IndexItem) -> int | None:
        """从索引项取出技能数字 id（用于查图谱边）。"""
        if item.kind != "SKILL":
            return None
        v = item.meta.get("id")
        try:
            return int(v) if v is not None else None
        except (TypeError, ValueError):
            return None

    def _candidate_indices(self, q: np.ndarray) -> list[int]:
        """按模式给出候选下标。"""
        n = self._matrix.shape[0]
        if self.mode != "lsh" or self._planes is None or self._tables is None:
            return list(range(n))            # 精确检索：全量候选

        cand: set[int] = set()
        for planes, table in zip(self._planes, self._tables):
            signs = (q @ planes.T) > 0
            code = int.from_bytes(np.packbits(signs.astype(np.uint8)).tobytes(), "big")
            cand.update(table.get(code, []))
        if not cand:
            # 桶内为空（新表述落在稀疏区域）→ 退化为精确检索。
            # 宁可慢一点也不返回空结果，这与 NFR-R-03 的降级思路一致。
            return list(range(n))
        return sorted(cand)

    def _explain(self, query: str, item: IndexItem) -> list[str]:
        """生成相似原因：共有词 + 学科门类。"""
        reasons: list[str] = []
        try:
            from .tokenizer import overlapping_terms
            common = overlapping_terms(query, item.text, top=5)
            if common:
                reasons.append("共有语义片段：" + "、".join(common))
        except Exception:  # noqa: BLE001
            pass
        if item.meta.get("categoryL1"):
            reasons.append(f"学科门类：{item.meta['categoryL1']}")
        return reasons

    # ------------------------------------------------------------------
    # 统计与持久化
    # ------------------------------------------------------------------

    def stats(self) -> dict:
        kinds: dict[str, int] = {}
        for it in self._items:
            kinds[it.kind] = kinds.get(it.kind, 0) + 1
        return {
            "mode": self.mode,
            "size": len(self._items),
            "dim": self.embedder.dim,
            "kinds": kinds,
            "lsh_tables": self.num_tables if self.mode == "lsh" else 0,
            "lsh_bits": self.num_hash_bits if self.mode == "lsh" else 0,
            "relation_edges": sum(len(v) for v in self._relations.values()) // 2,
        }

    def save(self, path: str | Path) -> None:
        """保存索引（向量矩阵 + 元信息），供服务启动时快速加载。"""
        path = Path(path)
        path.mkdir(parents=True, exist_ok=True)
        meta = {
            "ver": 1,
            "mode": self.mode,
            "keys": [i.key for i in self._items],
            "kinds": [i.kind for i in self._items],
            "texts": [i.text for i in self._items],
            "metas": [i.meta for i in self._items],
            "relation_weights": self.relation_weights,
            "relations": [
                {"fromId": a, "toId": b, "relation": rel}
                for a, lst in self._relations.items()
                for b, rel, _ in lst if a < b
            ],
        }
        (path / "index.json").write_text(
            json.dumps(meta, ensure_ascii=False), encoding="utf-8")
        if self._matrix is not None:
            np.save(path / "index.npy", self._matrix)

    @classmethod
    def load(cls, path: str | Path, embedder: SemanticEmbedder) -> "VectorIndex":
        """加载索引。"""
        path = Path(path)
        meta = json.loads((path / "index.json").read_text(encoding="utf-8"))
        idx = cls(embedder, mode=meta.get("mode", "exact"),
                  relation_weights=meta.get("relation_weights"))
        matrix = np.load(path / "index.npy") if (path / "index.npy").exists() else None
        for i, key in enumerate(meta["keys"]):
            vec = matrix[i] if matrix is not None else None
            idx.add(key, meta["kinds"][i], meta["texts"][i], meta["metas"][i], vector=vec)
        if meta.get("relations"):
            idx.set_relations(meta["relations"])
        return idx.build()


def rel_label(rel: str) -> str:
    """图谱关系的中文名（用于可解释文案）。"""
    return {
        "SYNONYM": "同义",
        "PREREQUISITE": "先决",
        "COMPLEMENT": "互补",
    }.get(str(rel).upper(), str(rel))
