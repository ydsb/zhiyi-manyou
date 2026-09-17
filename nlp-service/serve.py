"""
NLP 算法服务（FastAPI）—— 供 Java 后端调用的 HTTP 接口

【为什么用 HTTP 而不是把算法直接写进 Java】
  需求 6.1 的技术栈约定"算法服务：Python（FastAPI）承载 NLP 抽取 / Embedding /
  图谱推理，与 Java 服务通过 REST/gRPC 交互"。这样做的实际好处：

    1. **算法迭代不影响主服务**：换嵌入模型、调权重只需重启 Python 服务，
       Java 侧不用重新构建发布；
    2. **故障隔离**：算法服务挂了，Java 侧按 NFR-R-03 降级到关键词匹配，
       业务不中断（见 SemanticMatchClient 的降级逻辑）；
    3. **算力可独立扩容**：Embedding 是 CPU/GPU 密集型，
       与业务服务的扩容节奏不同。

【接口设计原则】
  1. **返回可解释结果**：每个命中都带 `reasons`（共有语义片段、图谱加成说明），
     对应 FR-M3-05"展示可解释理由"；
  2. **分数与理由分离**：`semantic_score` 与 `relation_boost` 分别返回，
     便于 Java 侧排查"为什么这条排前面"；
  3. **降级可用**：模型未加载时 /health 明确报 not_ready，
     Java 侧据此切换到关键词通道，而不是拿到一堆空结果。

启动：
    python serve.py                # 默认 127.0.0.1:8901
    python serve.py --port 8901

作者：李泽宬
"""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

sys.path.insert(0, str(Path(__file__).resolve().parent))

from nlp import SemanticEmbedder, VectorIndex  # noqa: E402

# ---------------------------------------------------------------------------
# 全局模型（进程内单例）
# ---------------------------------------------------------------------------

MODEL_DIR = Path(__file__).resolve().parent / "models"
_state: dict = {"embedder": None, "index": None, "loaded_at": None, "manifest": None}


def load_models() -> bool:
    """加载训练好的模型。返回是否成功。"""
    try:
        if not (MODEL_DIR / "embedder" / "embedder.json").exists():
            return False
        emb = SemanticEmbedder.load(MODEL_DIR / "embedder")
        idx = VectorIndex.load(MODEL_DIR / "index", emb)
        _state["embedder"] = emb
        _state["index"] = idx
        _state["loaded_at"] = time.strftime("%Y-%m-%d %H:%M:%S")
        manifest_path = MODEL_DIR / "manifest.json"
        if manifest_path.exists():
            import json
            _state["manifest"] = json.loads(manifest_path.read_text(encoding="utf-8"))
        return True
    except Exception as e:  # noqa: BLE001
        print(f"[NLP] 模型加载失败：{e}", file=sys.stderr)
        return False


def require_ready() -> tuple[SemanticEmbedder, VectorIndex]:
    """取模型，未就绪则返回 503 —— 让调用方明确知道该降级。"""
    if _state["embedder"] is None or _state["index"] is None:
        raise HTTPException(status_code=503, detail="模型未就绪（not_ready），请先训练模型")
    return _state["embedder"], _state["index"]


# ---------------------------------------------------------------------------
# 请求 / 响应模型
# ---------------------------------------------------------------------------


class SearchRequest(BaseModel):
    """语义检索请求（FR-M3-02）。"""

    query: str = Field(..., description="查询文本（需求标题+描述，或技能名）")
    top_k: int = Field(10, ge=1, le=100, description="返回条数")
    kind: str | None = Field(None, description="只检索某类型：SKILL / DEMAND / PROFILE")
    min_score: float = Field(0.0, ge=0.0, le=1.0, description="相似度下限")
    explain: bool = Field(True, description="是否返回可解释理由（FR-M3-05）")
    seed_skill_ids: list[int] | None = Field(
        None, description="查询已关联的技能 id；命中其图谱邻居时给予加成")


class MatchRequest(BaseModel):
    """两段文本的相似度（用于需求↔技能、需求↔需求的定向对比）。"""

    left: str = Field(..., description="文本 A")
    right: str = Field(..., description="文本 B")


class EncodeRequest(BaseModel):
    """批量编码（供 Java 侧缓存向量，避免重复调用）。"""

    texts: list[str] = Field(..., description="待编码文本列表", max_length=200)


class Hit(BaseModel):
    key: str
    kind: str
    text: str
    score: float
    semanticScore: float
    relationBoost: float
    reasons: list[str]
    meta: dict


class SearchResponse(BaseModel):
    query: str
    count: int
    hits: list[Hit]
    tookMs: float


# ---------------------------------------------------------------------------
# 应用
# ---------------------------------------------------------------------------

app = FastAPI(
    title="知驿·漫游 · NLP 语义引擎",
    description="技能语义匹配算法服务（S3）。供 Java 后端经 REST 调用。",
    version="0.1.0",
)

# 允许本机前端/后端联调（生产环境应收紧为具体来源）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup() -> None:
    ok = load_models()
    print(f"[NLP] 模型加载{'成功' if ok else '失败'}，目录 {MODEL_DIR}")


@app.get("/health")
def health() -> dict:
    """健康检查。

    `ready=false` 表示模型未加载 —— Java 侧据此切换到关键词降级通道（NFR-R-03），
    而不是反复重试或返回空结果。
    """
    ready = _state["embedder"] is not None and _state["index"] is not None
    data = {
        "ready": ready,
        "modelLoadedAt": _state["loaded_at"],
        "modelDir": str(MODEL_DIR),
    }
    if ready:
        data["index"] = _state["index"].stats()
        data["embedder"] = _state["embedder"].diagnostics()
    if _state["manifest"]:
        data["trainedAt"] = _state["manifest"].get("trained_at")
    return data


@app.post("/search", response_model=SearchResponse)
def search(req: SearchRequest) -> SearchResponse:
    """语义检索 Top-K（FR-M3-02）。

    FR-M3-01 由本服务的离线训练环节承担（TfidfVectorizer + SVD 编码），
    在线接口只需检索。
    """
    emb, idx = require_ready()
    t0 = time.perf_counter()
    hits = idx.search(
        req.query, top_k=req.top_k, kind=req.kind,
        min_score=req.min_score, explain=req.explain,
        seed_skill_ids=req.seed_skill_ids,
    )
    took = (time.perf_counter() - t0) * 1000.0
    return SearchResponse(
        query=req.query,
        count=len(hits),
        tookMs=round(took, 2),
        hits=[Hit(key=h.key, kind=h.kind, text=h.text, score=h.score,
                  semanticScore=h.semantic_score, relationBoost=h.relation_boost,
                  reasons=h.reasons, meta=h.meta) for h in hits],
    )


@app.post("/match")
def match(req: MatchRequest) -> dict:
    """计算两段文本的语义相似度。

    用于"这条需求与这个技能的相关性是多少"这类定向对比，
    比检索更轻量（不涉及排序）。
    """
    emb, _ = require_ready()
    from nlp import cosine
    a, b = emb.encode(req.left), emb.encode(req.right)
    from nlp.tokenizer import overlapping_terms
    return {
        "score": round(cosine(a, b), 4),
        "reasons": ["共有语义片段：" + "、".join(overlapping_terms(req.left, req.right, 5))]
        if overlapping_terms(req.left, req.right, 5) else [],
    }


@app.post("/encode")
def encode(req: EncodeRequest) -> dict:
    """批量编码为稠密向量（Java 侧可缓存，减少往返）。"""
    emb, _ = require_ready()
    vectors = emb.encode_batch(req.texts)
    return {
        "dim": emb.dim,
        "count": len(req.texts),
        # 用列表而非 base64：可读性优先，本场景文本量小；
        # 若日后量大再改二进制协议
        "vectors": [[round(float(x), 6) for x in v] for v in vectors],
    }


@app.get("/keywords")
def keywords(text: str, top: int = 12) -> dict:
    """抽取文本的关键语义片段（用于前端展示"系统看重了哪些词"）。"""
    emb, _ = require_ready()
    top_terms = emb.vectorizer.top_terms(text, top=top) if emb.vectorizer else []
    return {
        "text": text,
        "terms": [{"term": t, "weight": round(w, 4)} for t, w in top_terms],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="启动 NLP 算法服务")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8901)
    parser.add_argument("--reload", action="store_true")
    args = parser.parse_args()

    # 只监听回环地址：算法服务是内部服务，不应暴露到外网
    if not args.host.startswith("127.") and args.host != "localhost":
        print(f"[警告] 正在监听非回环地址 {args.host}，请确认网络策略允许", file=sys.stderr)

    import uvicorn
    uvicorn.run(app, host=args.host, port=args.port, log_level="info")
    return 0


if __name__ == "__main__":
    sys.exit(main())
