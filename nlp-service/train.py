"""
训练脚本：从业务库读技能语料，训练 TF-IDF + SVD，导出向量索引。

【为什么训练语料要取自业务库，而不是用通用语料】
  LSA 学到的是"词在什么上下文里共同出现"。若用新闻语料训练，
  'Vue' 与 '动画' 的共现关系根本不存在于训练集中，投影后自然不相似。
  只有用**本项目自己的技能标签与需求文本**训练，
  潜在主题才会贴合"跨学科技能交换"这个领域。

【语料构成（三路合并）】
  1. `zy_skill` 的 名称 + 别名 + 描述 + 门类 + 二级学科
     —— 让向量空间覆盖"标签怎么写的"
  2. `zy_demand` 的 标题 + 描述
     —— 让空间覆盖"用户怎么说的"（口语化表述）
  3. 技能图谱的边（先决/互补/同义）
     —— 把有关联的技能对**拼接成一条训练样本**，
        使图谱里的语义关系被 SVD 吸收进向量空间

  第 3 路是让 LSA 效果接近图谱推理的关键：
  仅靠标签文本，'Vue 前端开发' 与 'JS 动画与交互实现' 可能不够近；
  但图谱里它们有"互补"关系，把两者拼成一条语料后，
  它们的向量会被拉近 —— 相当于把人工维护的领域知识注入统计模型。

用法：
    python train.py                     # 用默认数据库配置训练
    python train.py --out models/       # 指定输出目录
    python train.py --dim 128           # 指定向量维度
    python train.py --index-mode lsh    # 用 LSH 建索引（规模大时）
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
from pathlib import Path

# 允许直接运行本脚本（把包目录加入 sys.path）
sys.path.insert(0, str(Path(__file__).resolve().parent))

from nlp import SemanticEmbedder, TfidfVectorizer, VectorIndex, build_vocabulary_stats  # noqa: E402
from nlp.corpus import load_corpus  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(description="训练技能语义向量索引")
    parser.add_argument("--out", default=str(Path(__file__).parent / "models"),
                        help="模型输出目录")
    # 默认 512 维：由评测确定，不是拍脑袋。
    # 在 788 条技能语料上实测（tests/eval_match.py --compare）：
    #   维度   Hit@1   Hit@3   Hit@5     MRR
    #    64    53.3%   63.3%   73.3%   0.5883
    #   128    63.3%   76.7%   76.7%   0.6889
    #   256    56.7%   83.3%   86.7%   0.6972
    #   512    73.3%   93.3%   96.7%   0.8250   ← 选定
    # 语料小时低维够用（27 条时 26 维即可）；语料上千条后维度过低会压缩区分度。
    parser.add_argument("--dim", type=int, default=512, help="向量维度（默认 512，见上方依据）")
    parser.add_argument("--index-mode", default="exact", choices=["exact", "lsh"],
                        help="检索模式")
    parser.add_argument("--max-features", type=int, default=60000,
                        help="TF-IDF 词表上限")
    parser.add_argument("--dump-corpus", default=None,
                        help="把训练语料导出为 JSONL（便于人工检查）")
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    t0 = time.time()
    print("=" * 68)
    print("知驿·漫游 · 技能语义向量训练")
    print("=" * 68)

    # ---------------- 1. 读语料 ----------------
    print("\n[1/5] 读取训练语料")
    corpus = load_corpus()
    skills = corpus["skills"]
    demands = corpus["demands"]
    pairs = corpus["pairs"]
    print(f"      技能标签 {len(skills)} 条")
    print(f"      需求卡片 {len(demands)} 条")
    print(f"      图谱技能对 {len(pairs)} 对")

    if not skills:
        print("\n[错误] 技能语料为空 —— 请确认数据库已导入 sql/01-schema.sql，")
        print("       且环境变量 ZHIYI_DB_PASSWORD 已设置。")
        return 1

    if args.dump_corpus:
        dump = Path(args.dump_corpus)
        with dump.open("w", encoding="utf-8") as f:
            for s in skills:
                f.write(json.dumps({"type": "skill", **s}, ensure_ascii=False) + "\n")
            for d in demands:
                f.write(json.dumps({"type": "demand", **d}, ensure_ascii=False) + "\n")
        print(f"      语料已导出：{dump}")

    # ---------------- 2. 拟合 TF-IDF ----------------
    print("\n[2/5] 拟合 TF-IDF")
    # 训练文本：技能全字段 + 需求全文 + 图谱拼接对
    skill_texts = [s["text"] for s in skills]
    demand_texts = [d["text"] for d in demands]
    train_texts = skill_texts + demand_texts

    vectorizer = TfidfVectorizer(max_features=args.max_features)
    vectorizer.fit(train_texts)
    vstats = build_vocabulary_stats(vectorizer)
    print(f"      词表大小 {vstats['token_count']}")
    print(f"      IDF 区间 [{vstats['min_idf']}, {vstats['max_idf']}]，均值 {vstats['avg_idf']}")
    lengths = vstats.get("length_distribution", {})
    top_len = sorted(lengths.items(), key=lambda kv: -kv[1])[:3]
    print(f"      token 长度分布（前 3）: " + "、".join(f"{k}字×{v}" for k, v in top_len))

    # ---------------- 3. 拟合 SVD ----------------
    print("\n[3/5] 拟合语义向量（随机化截断 SVD）")
    embedder = SemanticEmbedder(dim=args.dim)
    embedder.fit(skill_texts, vectorizer, extra_context=demand_texts)
    diag = embedder.diagnostics()
    print(f"      实际维度 {diag['dim']}")
    print(f"      前 5 个奇异值 {diag['top5_singular_values']}")
    print(f"      前 10 维承载信息量 {diag['energy_top10'] * 100:.1f}%")

    # ---------------- 4. 建索引 ----------------
    print("\n[4/5] 构建向量索引")
    index = VectorIndex(embedder, mode=args.index_mode)
    for s in skills:
        index.add(f"skill:{s['id']}", "SKILL", s["text"], {
            "id": s["id"],
            "name": s["name"],
            "alias": s.get("alias"),
            "categoryL1": s.get("categoryL1"),
            "categoryL2": s.get("categoryL2"),
            "difficulty": s.get("difficulty"),
            "hotScore": s.get("hotScore"),
        })
    for d in demands:
        index.add(f"demand:{d['id']}", "DEMAND", d["text"], {
            "id": d["id"],
            "demandNo": d.get("demandNo"),
            "title": d.get("title"),
            "status": d.get("status"),
        })
    # 图谱关系：作为检索阶段的显式加成（不拼进训练语料 —— 实测拼接会降低相似度）
    index.set_relations(pairs)
    index.build()
    istats = index.stats()
    print(f"      索引规模 {istats['size']} 条（{istats['kinds']}）")
    print(f"      检索模式 {istats['mode']}")

    # ---------------- 5. 落盘 ----------------
    print("\n[5/5] 保存模型")
    vectorizer.save(out_dir / "vectorizer.json")
    embedder.save(out_dir / "embedder")
    index.save(out_dir / "index")
    manifest = {
        "trained_at": time.strftime("%Y-%m-%d %H:%M:%S"),
        "dim": diag["dim"],
        "vocab_size": vstats["token_count"],
        "index_size": istats["size"],
        "index_kinds": istats["kinds"],
        "index_mode": istats["mode"],
        "corpus": {"skills": len(skills), "demands": len(demands), "pairs": len(pairs)},
        "vectorizer": vstats,
        "embedder": diag,
        "note": "本模型为 LSA（TF-IDF + 截断 SVD），非预训练语义模型；"
                "详见 docs/S3环境说明.md",
    }
    (out_dir / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"      输出目录 {out_dir}")
    for f in sorted(out_dir.rglob("*")):
        if f.is_file():
            print(f"        {f.relative_to(out_dir)}  ({f.stat().st_size / 1024:.1f} KB)")

    # ---------------- 自检：跑几个真实查询 ----------------
    print("\n" + "=" * 68)
    print("自检：语义检索样例")
    print("=" * 68)
    probes = [
        ("需要做个数据大屏，要有图表", "应命中 ECharts 数据可视化（含跨表述）", None),
        ("想学一点数学建模打比赛", "应命中 数学建模", None),
        ("帮我剪个宣传视频加特效", "应命中 视频剪辑", None),
        ("论文怎么写才规范", "应命中 学术论文写作", None),
        # 演示图谱加成：查询未直接提及"数据爬取"，
        # 但需求已关联 ECharts(id=4)，图谱上二者互补，应被提权召回
        # 演示图谱加成：已有技能"JS 动画与交互实现"(id=2)，
        # 图谱标注它与"UI/UX 设计"(id=3) 同义 —— 查询界面设计时应把 id=3 提权
        ("需要有人帮我做界面设计", "从 JS 动画(id=2) 出发，同义关系应把 UI/UX 设计(id=3) 提权", [2]),
    ]
    for q, expect, seeds in probes:
        hits = index.search(q, top_k=3, kind="SKILL", seed_skill_ids=seeds)
        print(f"\n查询：{q}")
        print(f"  预期：{expect}")
        for h in hits:
            tag = f"  [图谱加成 +{h.relation_boost:.2f}]" if h.relation_boost > 0 else ""
            print(f"  → {h.score:.4f}  {h.meta.get('name', h.text[:20])}{tag}")
            if h.reasons:
                print(f"           {' | '.join(h.reasons[:2])}")

    print(f"\n总耗时 {time.time() - t0:.1f} 秒")
    return 0


if __name__ == "__main__":
    sys.exit(main())
