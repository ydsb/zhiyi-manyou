"""
语义匹配效果评测（S3 · AC-03 验收）

对评测集跑检索，报告 Hit@1 / Hit@3 / Hit@5 与 MRR，
并给出未命中案例的明细，便于针对性改进。

用法：
    python tests/eval_match.py                    # 用已训练模型评测
    python tests/eval_match.py --train            # 先重训再评测
    python tests/eval_match.py --dim 256          # 指定维度对比
    python tests/eval_match.py --show-miss        # 只列未命中案例

作者：李泽宬
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from eval_set import load_cases, summarize  # noqa: E402

from nlp import SemanticEmbedder, TfidfVectorizer, VectorIndex  # noqa: E402
from nlp.corpus import load_corpus  # noqa: E402

MODEL_DIR = Path(__file__).resolve().parent.parent / "models"


def build_index(dim: int | None = None) -> VectorIndex:
    """构建索引。

    @param dim 指定则重新训练到该维度，否则加载已训练模型
    """
    if dim is None and (MODEL_DIR / "embedder" / "embedder.json").exists():
        emb = SemanticEmbedder.load(MODEL_DIR / "embedder")
        return VectorIndex.load(MODEL_DIR / "index", emb)

    c = load_corpus()
    skills, demands = c["skills"], c["demands"]
    skill_texts = [s["text"] for s in skills]
    demand_texts = [d["text"] for d in demands]
    vec = TfidfVectorizer().fit(skill_texts + demand_texts)
    emb = SemanticEmbedder(dim=dim or 128)
    emb.fit(skill_texts, vec, extra_context=demand_texts)
    idx = VectorIndex(emb)
    for s in skills:
        idx.add(f"skill:{s['id']}", "SKILL", s["text"],
                {"id": s["id"], "name": s["name"]})
    idx.set_relations(c["pairs"])
    return idx.build()


def run(dim: int | None = None, top_k: int = 5, verbose: bool = True) -> dict:
    """跑评测并输出明细。

    @param dim     向量维度（None 表示用已训练模型）
    @param top_k   取前 K 条
    @param verbose 是否打印每条结果
    @return 指标 + 明细
    """
    idx = build_index(dim)
    cases = load_cases()

    results: list[dict] = []
    for query, accept, note in cases:
        hits = idx.search(query, top_k=top_k, kind="SKILL", explain=False)
        names = [h.meta.get("name") for h in hits]

        # 找到第一个属于可接受集合的位置（1 起）
        rank = 0
        for i, n in enumerate(names, start=1):
            if n in accept:
                rank = i
                break

        # 命中但未在可接受集合中的（用于判断"可接受集合是否标窄了"）
        first_name = names[0] if names else None
        hit_in_any = rank > 0

        results.append({
            "query": query,
            "expected": sorted(accept),
            "got": names,
            "rank": rank,
            "hit1": rank == 1,
            "hit3": 1 <= rank <= 3,
            "hit5": 1 <= rank <= 5,
            "reciprocal_rank": (1.0 / rank) if rank else 0.0,
            "top1_score": hits[0].score if hits else 0.0,
            "possibly_mislabeled": (not hit_in_any and first_name is not None),
            "note": note,
        })

        if verbose:
            mark = "✓" if rank == 1 else ("△" if rank else "✗")
            print(f"  {mark} 「{query}」")
            print(f"      期望 {sorted(accept)}")
            print(f"      实际 {' / '.join(n or '?' for n in names[:3])}")
            if rank:
                print(f"      命中排名 {rank}")
            else:
                print(f"      未命中（Top1={first_name}，可能标注需复核）")

    metrics = summarize(results)
    return {"metrics": metrics, "details": results, "dim": idx.embedder.dim,
            "index_size": idx.stats()["size"]}


def main() -> int:
    parser = argparse.ArgumentParser(description="语义匹配效果评测（AC-03）")
    parser.add_argument("--dim", type=int, default=None, help="指定维度重新训练")
    parser.add_argument("--top-k", type=int, default=5)
    parser.add_argument("--show-miss", action="store_true", help="只列未命中案例")
    parser.add_argument("--json", default=None, help="把结果写入 JSON 文件")
    parser.add_argument("--compare", action="store_true",
                        help="对比 128/256/512 三个维度的效果")
    args = parser.parse_args()

    print("=" * 70)
    print("语义匹配效果评测（AC-03：匹配准确率 ≥ 70%）")
    print("=" * 70)

    if args.compare:
        print("\n维度对比（同一评测集）：")
        print(f"  {'维度':>6}  {'Hit@1':>8}  {'Hit@3':>8}  {'Hit@5':>8}  {'MRR':>8}")
        rows = []
        for dim in (64, 128, 256, 512):
            r = run(dim=dim, top_k=5, verbose=False)
            m = r["metrics"]
            rows.append((dim, m))
            print(f"  {dim:>6}  {m['accuracy_hit1']:>8.1%}  {m['accuracy_hit3']:>8.1%}  "
                  f"{m['accuracy_hit5']:>8.1%}  {m['mrr']:>8.4f}")
        best = max(rows, key=lambda x: (x[1]["accuracy_hit3"], x[1]["mrr"]))
        print(f"\n  最佳维度：{best[0]}（Hit@3 {best[1]['accuracy_hit3']:.1%}）")
        return 0

    result = run(dim=args.dim, top_k=args.top_k, verbose=not args.show_miss)
    m = result["metrics"]

    if args.show_miss:
        print("\n未命中案例：")
        for d in result["details"]:
            if not d["hit3"]:
                print(f"  ✗ 「{d['query']}」")
                print(f"      期望 {d['expected']}")
                print(f"      实际 {d['got'][:3]}")
                if d["possibly_mislabeled"]:
                    print(f"      ⚠ Top1 不在可接受集合中，可能是标注过窄，需复核")

    print()
    print("=" * 70)
    print(f"索引规模 {result['index_size']} 条，向量维度 {result['dim']}")
    print(f"评测集 {m['count']} 条查询")
    print("-" * 70)
    print(f"  Hit@1（首位命中）    {m['hit1']:>3} / {m['count']}  = {m['accuracy_hit1']:.1%}")
    print(f"  Hit@3（前 3 命中）   {m['hit3']:>3} / {m['count']}  = {m['accuracy_hit3']:.1%}")
    print(f"  Hit@5（前 5 命中）   {m['hit5']:>3} / {m['count']}  = {m['accuracy_hit5']:.1%}")
    print(f"  MRR                 {m['mrr']:.4f}")
    print("-" * 70)
    verdict = "达标" if m["accuracy_hit3"] >= 0.70 else "未达标"
    print(f"  AC-03 判定（按 Hit@3 ≥ 70%）：{verdict}")
    print("=" * 70)

    if args.json:
        Path(args.json).write_text(
            json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"\n结果已写入 {args.json}")

    return 0 if m["accuracy_hit3"] >= 0.70 else 1


if __name__ == "__main__":
    sys.exit(main())
