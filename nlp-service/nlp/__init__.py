"""
知驿·漫游 · NLP 语义引擎（S3）

把技能标签与需求文本编码为稠密语义向量，支持跨表述的语义匹配。

模块：
    tokenizer   中文分词与 n-gram（技能短文本专用，无需词典）
    tfidf       TF-IDF 向量化（IDF 由技能语料预先拟合）
    corpus      训练语料加载（技能标签 + 需求文本 + 图谱关系对）
    embedder    潜在语义分析（随机化截断 SVD）→ 稠密向量
    index       向量索引与检索（精确 KNN / 可选 LSH）

【关于实现的诚实说明】
    需求文档约定用 `sentence-transformers` 类预训练模型 + Elasticsearch
    的 dense_vector + HNSW。本机环境装不了 torch、访问不了 HuggingFace、
    也没有 Docker（详见 docs/S3环境说明.md），因此改用：

      - 预训练模型  →  TfidfVectorizer + 截断 SVD（LSA）
      - ES HNSW    →  numpy 精确余弦检索（本规模下更快更准）+ 可选 LSH

    这两项在需求文档「已知边界」中如实标注，不作为已完成项宣称。
    对外接口（encode / search）与预训练方案保持一致，
    日后替换只需新增一个 Embedder / VectorIndex 的实现类。

作者：李泽宬
"""

from .tokenizer import (
    tokenize,
    token_set,
    keyword_tokens,
    overlapping_terms,
    normalize,
    split_segments,
)
from .tfidf import TfidfVectorizer, SparseVector, build_vocabulary_stats
from .embedder import SemanticEmbedder, cosine, randomized_svd, DEFAULT_DIM
from .index import VectorIndex, SearchHit, IndexItem

__all__ = [
    "tokenize",
    "token_set",
    "keyword_tokens",
    "overlapping_terms",
    "normalize",
    "split_segments",
    "TfidfVectorizer",
    "SparseVector",
    "build_vocabulary_stats",
    "SemanticEmbedder",
    "cosine",
    "randomized_svd",
    "DEFAULT_DIM",
    "VectorIndex",
    "SearchHit",
    "IndexItem",
]

__version__ = "0.1.0"
