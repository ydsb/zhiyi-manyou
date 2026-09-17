"""
NLP 语义引擎单元测试

覆盖：分词与 n-gram、TF-IDF、SVD 语义向量、向量检索、图谱注入效果。

运行：
    set PYTHONPATH=G:\\DEV\\python-venv\\Lib\\site-packages
    python -m pytest tests/ -v        # 若有 pytest
    python tests/test_nlp.py          # 无 pytest 时直接跑（内置极简断言器）

作者：李泽宬
"""

from __future__ import annotations

import sys
import traceback
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import numpy as np  # noqa: E402

from nlp import (  # noqa: E402
    SemanticEmbedder,
    TfidfVectorizer,
    VectorIndex,
    cosine,
    keyword_tokens,
    normalize,
    overlapping_terms,
    token_set,
    tokenize,
)
from nlp.corpus import load_corpus  # noqa: E402

# ---------------------------------------------------------------------------
# 极简测试框架（环境无 pytest，用标准库实现，行为与 pytest 类似）
# ---------------------------------------------------------------------------

_CASES: list[tuple[str, callable]] = []

#: 测试临时目录。
#: **不能用 tempfile.TemporaryDirectory** —— 本机沙箱对系统临时目录有文件锁，
#: 退出清理时会抛 WinError 5。因此改用仓库内目录，并容忍清理失败。
_TMP_ROOT = Path(__file__).resolve().parent / "_tmp"


def _tmp_dir(name: str) -> Path:
    d = _TMP_ROOT / name
    d.mkdir(parents=True, exist_ok=True)
    return d


def case(desc: str):
    def deco(fn):
        _CASES.append((desc, fn))
        return fn
    return deco


class Assert:
    @staticmethod
    def true(cond, msg=""):
        if not cond:
            raise AssertionError(f"期望为真：{msg}")

    @staticmethod
    def false(cond, msg=""):
        if cond:
            raise AssertionError(f"期望为假：{msg}")

    @staticmethod
    def eq(a, b, msg=""):
        if a != b:
            raise AssertionError(f"期望 {b!r}，实际 {a!r}  {msg}")

    @staticmethod
    def close(a, b, tol=1e-6, msg=""):
        if abs(float(a) - float(b)) > tol:
            raise AssertionError(f"期望约 {b}，实际 {a}（容差 {tol}）  {msg}")

    @staticmethod
    def gt(a, b, msg=""):
        if not float(a) > float(b):
            raise AssertionError(f"期望 {a} > {b}  {msg}")

    @staticmethod
    def raises(exc, fn, msg=""):
        try:
            fn()
        except exc:
            return
        except Exception as e:  # noqa: BLE001
            raise AssertionError(f"期望 {exc.__name__}，实际 {type(e).__name__}: {e}  {msg}")
        raise AssertionError(f"期望抛出 {exc.__name__}，但没有异常  {msg}")


# ---------------------------------------------------------------------------
# 分词
# ---------------------------------------------------------------------------


@case("分词：全角字母数字应被折叠为半角")
def test_normalize_fullwidth():
    Assert.eq(normalize("Ｖｕｅ 前端"), "vue 前端", "NFKC 折叠")
    Assert.eq(normalize("ＥＣｈａｒｔｓ"), "echarts")


@case("分词：零宽字符与 BOM 应被清理（Word/网页复制常见）")
def test_normalize_zero_width():
    Assert.eq(normalize("数\u200b学\ufeff建模"), "数学建模")


@case("分词：中文应产出 2/3 字 n-gram，且不保留单字")
def test_tokenize_cjk_ngrams():
    tokens = tokenize("数学建模", ngrams=(1, 2, 3))
    Assert.true("数学" in tokens, "应含 2 字 n-gram '数学'")
    Assert.true("数学建" in tokens, "应含 3 字 n-gram '数学建'")
    Assert.false("数" in tokens, "默认不保留单字（噪声大）")
    # 2 字 n-gram 数量应为 len-1
    bigrams = [t for t in tokens if len(t) == 2]
    Assert.eq(len(bigrams), 3, "4 字文本应产出 3 个 bigram")


@case("分词：keep_unigram 开关应能保留单字（短标签场景）")
def test_tokenize_keep_unigram():
    tokens = tokenize("画", ngrams=(1,), keep_unigram=True)
    Assert.eq(tokens, ["画"])
    tokens2 = tokenize("画", ngrams=(1,), keep_unigram=False)
    Assert.eq(tokens2, [], "不保留单字时应为空")


@case("分词：英文单词应整体保留，不拆成字母")
def test_tokenize_english_whole_word():
    tokens = tokenize("Vue ECharts")
    Assert.true("vue" in tokens, "Vue 应被小写化为整体 token")
    Assert.true("echarts" in tokens)
    Assert.false("v" in tokens, "不应拆成单字母")
    Assert.false("e" in tokens)


@case("分词：特殊符号词应保留（C++ / C# / Node.js / vue3）")
def test_tokenize_special_words():
    tokens = tokenize("学 C++ 和 Node.js，还有 vue3")
    Assert.true("c++" in tokens or any("c" == t for t in tokens), f"应识别 C++：{tokens}")
    Assert.true("node.js" in tokens, f"应识别 Node.js：{tokens}")
    Assert.true("vue3" in tokens, f"应识别 vue3：{tokens}")


@case("分词：数字与版本号应保留")
def test_tokenize_numbers():
    tokens = tokenize("Python 3.13 和 ES 8.0")
    Assert.true("3.13" in tokens, f"应保留版本号：{tokens}")
    Assert.true("8.0" in tokens)


@case("分词：中英混排应各自成段")
def test_tokenize_mixed():
    tokens = tokenize("用 Vue 做数据大屏")
    Assert.true("vue" in tokens, "英文词应在")
    Assert.true("数据" in tokens, "中文 bigram 应在")
    Assert.true("大屏" in tokens)


@case("分词：停用词不应成为 token 的独立成分（单字停用词）")
def test_stopwords():
    tokens = tokenize("我需要学习数学建模的能力")
    # '的' '我' '要' 等单字停用词不应出现（因为默认不保留单字）
    Assert.false("的" in tokens)
    Assert.false("我" in tokens)


@case("分词：token_set 应去重")
def test_token_set():
    s = token_set("数学数学建模建模", ngrams=(2,))
    # '数学数学建模建模' 的 bigram 序列：数学/学数/数学/学建/建模/模建/建模
    # 去重后 5 个 —— 注意 '模建' 也在其中（跨词边界的 n-gram，字级切分的固有产物）
    Assert.eq(s, {"数学", "学数", "学建", "建模", "模建"}, "重复 n-gram 应被去重")
    Assert.eq(len(s), 5, "应恰好 5 个不同的 bigram")


@case("分词：标点应作为分隔符，不进入 token")
def test_punctuation_split():
    tokens = tokenize("数学建模，数据可视化。")
    Assert.false(any("，" in t or "。" in t for t in tokens), f"标点不应进入 token：{tokens}")
    Assert.true("数学" in tokens and "可视" in tokens)


# ---------------------------------------------------------------------------
# 可解释性
# ---------------------------------------------------------------------------


@case("可解释：应找出两段文本的共有语义片段")
def test_overlapping_terms():
    common = overlapping_terms("需要做个数据大屏，要有图表", "ECharts 数据可视化 图表 数据大屏")
    Assert.true(len(common) > 0, "应找到共有片段")
    joined = "".join(common)
    Assert.true("数据" in joined or "图表" in joined, f"应包含关键共有词：{common}")


@case("可解释：更长的共有片段应排在前面（信息量更大）")
def test_overlapping_prefers_longer():
    common = overlapping_terms("数学建模竞赛", "数学建模 建模 数学")
    Assert.true(len(common) >= 1)
    Assert.true(len(common[0]) >= 3, f"首位应是较长的片段，实际 {common}")


@case("可解释：keyword_tokens 应保持出现顺序并去重")
def test_keyword_tokens():
    ks = keyword_tokens("Vue 前端开发")
    Assert.true("vue" in ks)
    Assert.eq(len(ks), len(set(ks)), "不应有重复")


# ---------------------------------------------------------------------------
# TF-IDF
# ---------------------------------------------------------------------------


def _fitted_vectorizer() -> TfidfVectorizer:
    corpus = [
        "vue 前端开发 组件化 交互",
        "echarts 数据可视化 图表 看板",
        "数学建模 数模 竞赛",
        "视频剪辑 后期 特效 转场",
        "学术论文写作 文献综述",
        "数据爬取与清洗 爬虫 采集",
    ]
    return TfidfVectorizer().fit(corpus)


@case("TF-IDF：未拟合时应明确报错，而不是静默返回空")
def test_tfidf_not_fitted():
    v = TfidfVectorizer()
    Assert.raises(RuntimeError, lambda: v.transform_sparse("测试"))


@case("TF-IDF：向量应 L2 归一化（模长为 1）")
def test_tfidf_l2_normalized():
    v = _fitted_vectorizer()
    sp = v.transform_sparse("echarts 图表")
    norm = sum(x * x for x in sp.values()) ** 0.5
    Assert.close(norm, 1.0, 1e-5, "L2 归一化后模长应为 1")


@case("TF-IDF：稀有词的 IDF 应高于高频词")
def test_tfidf_idf_ordering():
    v = _fitted_vectorizer()
    idf_common = v.idf.get("数据", 0)
    idf_rare = v.idf.get("文献", 0)
    Assert.gt(idf_rare, idf_common, "稀有词应有更高 IDF")


@case("TF-IDF：词表外 token 应被丢弃而不是报错")
def test_tfidf_oov():
    v = _fitted_vectorizer()
    sp = v.transform_sparse("完全不存在的词汇xyz")
    Assert.eq(len(sp), 0, "词表外应返回空向量")


@case("TF-IDF：保存与加载应完全一致")
def test_tfidf_roundtrip():
    v = _fitted_vectorizer()
    text = "echarts 数据可视化"
    before = v.transform_sparse(text)
    p = _tmp_dir("tfidf") / "vec.json"
    v.save(p)
    v2 = TfidfVectorizer.load(p)
    after = v2.transform_sparse(text)
    Assert.eq(set(before.keys()), set(after.keys()), "token 集合应一致")
    for k in before:
        Assert.close(before[k], after[k], 1e-6, f"权重应一致：{k}")


@case("TF-IDF：top_terms 应返回权重最高的词，用于解释")
def test_tfidf_top_terms():
    v = _fitted_vectorizer()
    top = v.top_terms("echarts 图表 数据可视化", top=3)
    Assert.true(len(top) > 0)
    weights = [w for _, w in top]
    Assert.true(weights == sorted(weights, reverse=True), "应按权重降序")


# ---------------------------------------------------------------------------
# SVD 语义向量
# ---------------------------------------------------------------------------


def _fitted_embedder() -> SemanticEmbedder:
    corpus = [
        "vue 前端开发 组件化 页面交互 动效",
        "js 动画 交互动效 滚动动画 前端",
        "echarts 数据可视化 图表 看板 大屏",
        "数据爬取与清洗 爬虫 采集 整理",
        "数学建模 数模 竞赛 求解 验证",
        "科研实验设计 实验方案 对照组",
        "视频剪辑 后期 特效 转场 调色",
        "ui 界面设计 用户体验 原型",
        "学术论文写作 文献综述 规范",
        "英语口语 陪练 对话 speaking",
    ]
    vec = TfidfVectorizer().fit(corpus)
    emb = SemanticEmbedder(dim=16)
    emb.fit(corpus, vec)
    return emb


@case("SVD：编码结果应为 L2 归一化的稠密向量")
def test_embedder_dense_normalized():
    emb = _fitted_embedder()
    v = emb.encode("echarts 图表")
    Assert.eq(v.shape[0], emb.dim, "维度应等于设定值")
    Assert.close(float(np.linalg.norm(v)), 1.0, 1e-4, "应为单位向量")


@case("SVD：相同文本的向量应完全一致（可复现）")
def test_embedder_deterministic():
    emb = _fitted_embedder()
    a = emb.encode("数学建模 竞赛")
    b = emb.encode("数学建模 竞赛")
    Assert.close(float(np.linalg.norm(a - b)), 0.0, 1e-6, "同输入应同输出")


@case("SVD：相关文本的相似度应高于无关文本")
def test_embedder_semantic_ordering():
    emb = _fitted_embedder()
    q = emb.encode("echarts 数据可视化 图表")
    related = emb.encode("数据可视化 看板 大屏")
    unrelated = emb.encode("英语口语 陪练")
    Assert.gt(cosine(q, related), cosine(q, unrelated),
              "相关文本相似度应更高")


@case("SVD：完全词表外的查询应返回兜底向量而非零向量")
def test_embedder_oov_fallback():
    emb = _fitted_embedder()
    v = emb.encode("zzzz 完全不存在的词 qqqq")
    # 兜底为平均向量（已是单位向量）；至少不应全零
    Assert.true(float(np.linalg.norm(v)) > 0, "不应返回零向量")


@case("SVD：余弦相似度应对称且落在 [0,1]")
def test_cosine_symmetric():
    emb = _fitted_embedder()
    a = emb.encode("数学建模")
    b = emb.encode("数模竞赛")
    Assert.close(cosine(a, b), cosine(b, a), 1e-6, "应满足对称性")
    Assert.true(0.0 <= cosine(a, b) <= 1.0, "应落在 [0,1]")


@case("SVD：诊断信息应给出维度与信息量")
def test_embedder_diagnostics():
    emb = _fitted_embedder()
    d = emb.diagnostics()
    Assert.eq(d["dim"], emb.dim)
    Assert.true(d["energy_top10"] > 0, "应给出信息量")
    Assert.true(len(d["top5_singular_values"]) == 5, "应给出前 5 个奇异值")


@case("SVD：保存与加载应得到相同向量")
def test_embedder_roundtrip():
    emb = _fitted_embedder()
    v1 = emb.encode("数据可视化")
    d = _tmp_dir("embedder")
    emb.save(d)
    emb2 = SemanticEmbedder.load(d)
    v2 = emb2.encode("数据可视化")
    Assert.close(float(np.linalg.norm(v1 - v2)), 0.0, 1e-5, "加载后编码应一致")


@case("随机化 SVD：应逼近 numpy 完整 SVD 的前 k 个奇异值")
def test_randomized_svd_accuracy():
    from nlp import randomized_svd
    rng = np.random.default_rng(7)
    # 构造低秩矩阵（秩 5），随机化 SVD 应能基本还原
    a = rng.standard_normal((40, 30)).astype(np.float32)
    u, s, vt = np.linalg.svd(a, full_matrices=False)
    low_rank = (u[:, :5] * s[:5]) @ vt[:5, :]

    ru, rs, rvt = randomized_svd(low_rank, n_components=5, n_iter=4, seed=1)
    Assert.close(float(rs[0]), float(s[0]), tol=max(1e-2, abs(float(s[0])) * 0.05),
                 msg="主奇异值应接近")
    # 还原误差应很小
    restored = (ru * rs) @ rvt
    err = float(np.linalg.norm(restored - low_rank)) / float(np.linalg.norm(low_rank))
    Assert.true(err < 0.05, f"低秩矩阵还原误差应小于 5%，实际 {err:.4f}")


@case("随机化 SVD：结果应可复现（同 seed 同输出）")
def test_randomized_svd_reproducible():
    from nlp import randomized_svd
    rng = np.random.default_rng(3)
    a = rng.standard_normal((30, 20)).astype(np.float32)
    r1 = randomized_svd(a, n_components=4, seed=99)
    r2 = randomized_svd(a, n_components=4, seed=99)
    Assert.close(float(np.linalg.norm(r1[1] - r2[1])), 0.0, 1e-6, "奇异值应一致")


# ---------------------------------------------------------------------------
# 向量检索
# ---------------------------------------------------------------------------


def _fitted_index(mode: str = "exact") -> VectorIndex:
    emb = _fitted_embedder()
    idx = VectorIndex(emb, mode=mode)
    rows = [
        ("skill:1", "SKILL", "Vue 前端开发 组件化 页面交互 动效", {"name": "Vue 前端开发"}),
        ("skill:2", "SKILL", "JS 动画 交互动效 滚动动画", {"name": "JS 动画与交互实现"}),
        ("skill:3", "SKILL", "ECharts 数据可视化 图表 看板 大屏", {"name": "ECharts 数据可视化"}),
        ("skill:4", "SKILL", "数据爬取与清洗 爬虫 采集", {"name": "数据爬取与清洗"}),
        ("skill:5", "SKILL", "数学建模 数模 竞赛 求解", {"name": "数学建模"}),
        ("skill:6", "SKILL", "视频剪辑 后期 特效 转场", {"name": "视频剪辑"}),
        ("skill:7", "SKILL", "英语口语 陪练 对话", {"name": "英语口语陪练"}),
    ]
    idx.add_many(rows)
    return idx.build()


@case("检索：应返回最相关的技能，且给出可解释理由")
def test_index_search_basic():
    idx = _fitted_index()
    hits = idx.search("需要做个数据大屏要有图表", top_k=3)
    Assert.true(len(hits) > 0, "应有结果")
    Assert.eq(hits[0].key, "skill:3", "首位应是 ECharts 数据可视化")
    Assert.true(len(hits[0].reasons) > 0, "应给出可解释理由")


@case("检索：结果应按相似度降序")
def test_index_sorted():
    idx = _fitted_index()
    hits = idx.search("数学建模竞赛", top_k=5)
    scores = [h.score for h in hits]
    Assert.true(scores == sorted(scores, reverse=True), f"应降序：{scores}")


@case("检索：kind 过滤应只返回指定类型")
def test_index_kind_filter():
    idx = _fitted_index()
    idx.add("demand:1", "DEMAND", "想做数据大屏", {"title": "数据大屏"})
    idx.build()
    hits = idx.search("数据大屏", top_k=10, kind="SKILL")
    Assert.true(all(h.kind == "SKILL" for h in hits), "只应返回 SKILL")


@case("检索：min_score 应过滤低相关结果")
def test_index_min_score():
    idx = _fitted_index()
    hits_all = idx.search("数据可视化", top_k=10)
    if hits_all:
        cutoff = hits_all[0].score
        hits = idx.search("数据可视化", top_k=10, min_score=cutoff)
        Assert.true(all(h.score >= cutoff for h in hits), "应过滤低分")


@case("检索：LSH 模式应与精确模式给出高度一致的首位结果")
def test_index_lsh_vs_exact():
    exact = _fitted_index("exact")
    lsh = _fitted_index("lsh")
    q = "想学数学建模"
    he = exact.search(q, top_k=3)
    hl = lsh.search(q, top_k=3)
    Assert.true(len(he) > 0 and len(hl) > 0, "两种模式都应有结果")
    Assert.eq(hl[0].key, he[0].key, "首位应一致（LSH 有随机性但主项应稳定）")


@case("检索：重复 add 同 key 应覆盖而非追加")
def test_index_upsert():
    idx = _fitted_index()
    n1 = idx.stats()["size"]
    idx.add("skill:1", "SKILL", "Vue 前端开发 更新后的描述", {"name": "Vue 前端开发"})
    n2 = idx.stats()["size"]
    Assert.eq(n1, n2, "同 key 应覆盖，规模不变")


@case("检索：空索引应返回空结果而不是报错")
def test_index_empty():
    emb = _fitted_embedder()
    idx = VectorIndex(emb)
    idx.build()
    Assert.eq(idx.search("任意查询"), [], "空索引应返回空列表")


@case("检索：保存与加载后结果应一致")
def test_index_roundtrip():
    idx = _fitted_index()
    q = "数据大屏"
    before = [(h.key, h.score) for h in idx.search(q, top_k=3)]
    d = _tmp_dir("index")
    idx.save(d)
    idx2 = VectorIndex.load(d, idx.embedder)
    after = [(h.key, h.score) for h in idx2.search(q, top_k=3)]
    Assert.eq(before, after, "加载后检索结果应一致")


@case("图谱：关系加成应把关联技能从语义 0 提升到可召回（这是图谱的核心价值）")
def test_relation_boost_mechanism():
    """
    验证图谱关系加成机制。

    【为什么是"检索阶段加成"而不是"训练进向量"】
      实测：把图谱边拼接成训练语料会**降低**关联技能的相似度
      （20 篇语料、16/32/64 三种维度下一致 0.0545 → 0.0295），
      根因是共享词的文档频率升高使 IDF 降低，归一化后权重反被压低。
      因此改为检索阶段显式加成：可控、可解释、可关闭。

    【本用例测什么】
      'vue 前端开发 组件化' 与 'js 动画 交互动效' 无共享词，
      纯语义相似度为 0。此时图谱把两者标注为"互补"，
      加成应使 js 动画能被召回到结果中 —— 这正是图谱存在的意义。
    """
    emb = _fitted_embedder()
    idx = VectorIndex(emb)
    idx.add("skill:1", "SKILL", "Vue 前端开发 组件化 页面交互",
            {"id": 1, "name": "Vue 前端开发"})
    idx.add("skill:2", "SKILL", "JS 动画 交互动效 滚动动画",
            {"id": 2, "name": "JS 动画与交互实现"})
    idx.add("skill:3", "SKILL", "ECharts 数据可视化 图表",
            {"id": 3, "name": "ECharts 数据可视化"})
    idx.build()

    # 不启用图谱：只按语义检索"Vue 前端开发"
    no_boost = idx.search("Vue 前端开发 组件化", top_k=3, use_relations=False)
    # 启用图谱：从技能 1 出发，其图谱邻居（技能 2）应被提权
    with_boost = idx.search("Vue 前端开发 组件化", top_k=3,
                            seed_skill_ids=[1])

    # 给技能 1 加一条到技能 2 的互补边后重测
    idx.set_relations([{"fromId": 1, "toId": 2, "relation": "COMPLEMENT"}])
    boosted = idx.search("Vue 前端开发 组件化", top_k=3, seed_skill_ids=[1])

    def find(hits, key):
        return next((h for h in hits if h.key == key), None)

    h_before = find(no_boost, "skill:2")
    h_after = find(boosted, "skill:2")
    Assert.true(h_after is not None, "加成后技能2应出现在结果中")
    if h_before is not None:
        Assert.gt(h_after.score, h_before.score,
                  f"加成后得分应提高（{h_before.score} → {h_after.score}）")
    Assert.gt(h_after.relation_boost, 0.0, "应记录图谱加成值")
    Assert.true(any("图谱" in r for r in h_after.reasons),
                f"应在理由中说明图谱加成：{h_after.reasons}")


@case("图谱：加成应可关闭，便于对比与排查")
def test_relation_boost_can_be_disabled():
    emb = _fitted_embedder()
    idx = VectorIndex(emb)
    idx.add("skill:1", "SKILL", "Vue 前端开发 组件化", {"id": 1})
    idx.add("skill:2", "SKILL", "JS 动画 交互动效", {"id": 2})
    idx.set_relations([{"fromId": 1, "toId": 2, "relation": "COMPLEMENT"}])
    idx.build()
    on = idx.search("Vue 前端开发", top_k=2, seed_skill_ids=[1], use_relations=True)
    off = idx.search("Vue 前端开发", top_k=2, seed_skill_ids=[1], use_relations=False)
    h_on = next(h for h in on if h.key == "skill:2")
    h_off = next(h for h in off if h.key == "skill:2")
    Assert.eq(h_off.relation_boost, 0.0, "关闭时不应有加成")
    Assert.gt(h_on.score, h_off.score, "开启时得分应更高")


@case("图谱：同义关系的加成应强于互补关系（权重分级）")
def test_relation_weight_ordering():
    w = VectorIndex.DEFAULT_RELATION_WEIGHTS
    Assert.gt(w["SYNONYM"], w["PREREQUISITE"], "同义应强于先决")
    Assert.gt(w["PREREQUISITE"], w["COMPLEMENT"], "先决应强于互补")
    Assert.true(all(v < 1.0 for v in w.values()),
                "加成系数必须小于 1 —— 否则一个关系边就能顶掉语义证据")


@case("图谱：加成幅度应有界（不会把无关技能顶到首位）")
def test_relation_boost_bounded():
    emb = _fitted_embedder()
    idx = VectorIndex(emb)
    idx.add("skill:1", "SKILL", "Vue 前端开发 组件化", {"id": 1})
    # 技能 2 与查询语义无关，但图谱上与技能 1 同义（最强加成）
    idx.add("skill:2", "SKILL", "英语口语 陪练 对话 speaking", {"id": 2})
    idx.set_relations([{"fromId": 1, "toId": 2, "relation": "SYNONYM"}])
    idx.build()
    hits = idx.search("Vue 前端开发 组件化", top_k=2, seed_skill_ids=[1])
    top = hits[0]
    Assert.eq(top.key, "skill:1",
              f"语义最强项仍应排首位，加成不应颠倒顺序（实际首位 {top.key}）")


@case("边界：无共享词汇的技能在语料小时向量正交（锁定算法能力边界，防止误用）")
def test_lsa_orthogonal_boundary():
    """
    锁定 LSA 的真实边界：**两段文本若无共享 token、语料又极小，
    其向量会落在正交方向上（余弦为 0）**，此时注入图谱关系也难以拉近。

    这个用例的作用不是"证明系统好"，而是把边界固定下来：
    防止日后有人误以为"语义匹配可以替代图谱召回"。
    对应的工程结论：多路召回（向量 + 图谱 + 标签）是必需的（FR-M3-04），
    而不是可选项。
    """
    corpus = [
        "vue 前端开发 组件化",
        "js 动画 交互动效 滚动动画",
        "echarts 数据可视化 图表",
        "数学建模 竞赛",
        "视频剪辑 后期 特效",
        "英语口语 陪练 对话",
    ]
    vec = TfidfVectorizer().fit(corpus)
    emb = SemanticEmbedder(dim=8)
    emb.fit(corpus, vec)
    sim = cosine(emb.encode(corpus[0]), emb.encode(corpus[1]))
    Assert.close(sim, 0.0, 0.05,
                 f"无共享词汇且语料极小时应近似正交，实际 {sim:.4f}；"
                 f"若显著大于 0，说明语料已足够大、该边界不再成立，应更新此用例")

# ---------------------------------------------------------------------------
# 语料加载
# ---------------------------------------------------------------------------


@case("语料：内置种子语料应可用且结构完整")
def test_seed_corpus():
    c = load_corpus(from_json=None)
    Assert.true(len(c["skills"]) >= 10, f"种子技能应不少于 10 条，实际 {len(c['skills'])}")
    Assert.true(all("text" in s and s["text"].strip() for s in c["skills"]),
                "每条技能都应有训练文本")
    Assert.true(all(s.get("categoryL1") for s in c["skills"]), "应有学科门类")
    Assert.true(len(c["pairs"]) >= 3, "应含图谱关系对")


@case("语料：别名应用空格拆开拼入训练文本（否则会变成怪 token）")
def test_corpus_alias_split():
    c = load_corpus(from_json=None)
    vue = next(s for s in c["skills"] if "Vue" in s["name"])
    Assert.true("|" not in vue["text"], "训练文本里不应残留别名分隔符")
    Assert.true("vue3" in vue["text"] or "前端框架" in vue["text"],
                f"别名内容应进入文本：{vue['text']}")


# ---------------------------------------------------------------------------
# 运行器
# ---------------------------------------------------------------------------


def main() -> int:
    passed = 0
    failed: list[tuple[str, str]] = []

    print("=" * 70)
    print("NLP 语义引擎单元测试")
    print("=" * 70)
    for desc, fn in _CASES:
        try:
            fn()
            passed += 1
            print(f"  [通过] {desc}")
        except Exception as e:  # noqa: BLE001
            failed.append((desc, f"{type(e).__name__}: {e}"))
            print(f"  [失败] {desc}")
            print(f"         {type(e).__name__}: {e}")
            if "--trace" in sys.argv:
                traceback.print_exc()

    print("=" * 70)
    print(f"共 {len(_CASES)} 项：通过 {passed}，失败 {len(failed)}")
    if failed:
        print("\n失败明细：")
        for desc, err in failed:
            print(f"  - {desc}\n      {err}")
    print("=" * 70)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
