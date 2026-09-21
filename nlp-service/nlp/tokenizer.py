"""
中文技能文本分词器（S3 · 语义匹配基础）

【为什么不用 jieba 等成熟分词器】
  本机沙箱的 Python TLS 被拦、临时目录有文件锁，装不了第三方分词库
  （详见 docs/S3环境说明.md）。因此用标准库实现一个**面向技能短文本**的分词器。

【为什么技能文本适合字级 n-gram】
  通用分词器为长句新闻语料设计；而技能标签多为 2~8 字的名词短语，
  且跨专业术语常常"一个词没登记就完全匹配不上"。字级 n-gram（bigram + trigram）
  有三个实际好处：

  1. **不需要词典**：新术语（"体素建模""多模态对齐"）无需事先登记也能被匹配，
     这对"跨学科术语不断增长"的场景很重要；
  2. **容忍错位与简写**：'ECharts' 与 'echarts 图表'、'数学建模' 与 '建模' 都能拿到
     部分共现的 n-gram，不会因为一个词差一个字就归零；
  3. **中文无需外部分词**：中文字符本身就是良好的语义单元载体，
     '动态交互效果' 的 bigram 会自动产出 '动态/态交/交互/互效/效果'，
     与 'Vue 响应式动画' 的 '响应/应式/式动/动画' 在 '动' 字附近形成弱关联。

【与英文混排的处理】
  英文单词整体保留（'ECharts' 不拆成 'E','C'…），同时补一个"整体小写"的形式，
  使 'Vue' 与 'vue' 能对上；数字串同理保留。

作者：李泽宬
"""

from __future__ import annotations

import re
import unicodedata

# ---------------------------------------------------------------------------
# 停用词
# ---------------------------------------------------------------------------

#: 中文停用词：多为助词、连接词与平台口语，对技能语义无贡献
STOPWORDS_ZH = frozenset(
    """的 了 和 与 及 或 也 还 就 都 很 更 最 太 非常 比较 稍微 有点 一些 什么 怎么
    我 你 他 她 它 我们 你们 他们 自己 这个 那个 这些 那些 一个 一下 一直 已经
    可以 能够 会 能 想 要 需要 希望 打算 准备 正在 在 有 是 不 没 无 别 请
    把 被 让 给 对 向 从 到 在 于 为 为了 因为 所以 但是 不过 而且 并且 如果
    时候 地方 东西 事情 问题 方面 情况 时候 的话 一样 这样 那样 怎样 如何
    就是 还是 或者 然后 接着 于是 因此 另外 此外 例如 比如 等等 之类 什么的
    帮我 帮忙 教我 求教 请教 带我 一起 互相 相互 双方 大家 同学 朋友 老师
    需求 技能 交换 平台 系统 项目 内容 相关 进行 实现 完成 提供 获取 使用""".split()
)

#: 英文停用词（技能文本里出现得不多，但描述里会有）
STOPWORDS_EN = frozenset(
    """a an the and or but if then else for with without to of in on at by from
    is are was were be been being do does did have has had will would shall should
    can could may might must this that these those it its as not no nor so than
    very more most such own same too only just about into over under again""".split()
)

# ---------------------------------------------------------------------------
# 正则
# ---------------------------------------------------------------------------

#: 英文/数字词（连续字母数字，允许内部有 - _ . + # 以保留 C++、C#、Node.js 之类）
RE_WORD = re.compile(r"[A-Za-z][A-Za-z0-9_\-+.#]*|\d+(?:\.\d+)*")

#: 中日韩统一表意文字（含扩展 A 与兼容区）
RE_CJK = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")

#: 需要清理的标点与符号（保留字符本身的意义不大，统一当分隔处理）
RE_PUNCT = re.compile(
    r"[\s\u3000!-/:-@\[-`{-~\u3001-\u303f\uff01-\uff0f\uff1a-\uff20\uff3b-\uff40\uff5b-\uff65]+"
)


def normalize(text: str) -> str:
    """统一化文本：全角转半角、去零宽字符、转小写。

    技术文本里全角字母/数字很常见（从 Word 复制过来），
    不统一会让 `Ｖｕｅ` 与 `Vue` 完全无法匹配。
    """
    if not text:
        return ""
    # NFKC 会把全角字母数字、全角空格等折叠成半角
    text = unicodedata.normalize("NFKC", text)
    # 去掉零宽字符与 BOM（Word / 网页复制常见）
    text = text.replace("\u200b", "").replace("\u200c", "").replace("\u200d", "")
    text = text.replace("\ufeff", "")
    return text.lower()


def split_segments(text: str) -> list[tuple[str, str]]:
    """把文本切成 (类型, 内容) 段，类型为 'cjk' 或 'word'。

    保持原文顺序，便于后续生成相邻 n-gram。
    """
    text = normalize(text)
    out: list[tuple[str, str]] = []
    i = 0
    n = len(text)

    while i < n:
        ch = text[i]
        if RE_CJK.match(ch):
            # 连续中文聚成一段
            j = i
            while j < n and RE_CJK.match(text[j]):
                j += 1
            out.append(("cjk", text[i:j]))
            i = j
        elif ch.isalnum():
            m = RE_WORD.match(text, i)
            if m:
                out.append(("word", m.group(0)))
                i = m.end()
            else:
                i += 1
        else:
            # 标点/空白当分隔符跳过
            i += 1
    return out


def tokenize(text: str, ngrams: tuple[int, ...] = (1, 2, 3),
             keep_unigram: bool = False) -> list[str]:
    """把文本切成 token 列表。

    @param text          原始文本（技能名、需求描述等）
    @param ngrams        中文要生成的 n-gram 阶数；默认 1/2/3 阶
    @param keep_unigram  是否保留单字。默认 False ——
                         单字噪声大（'的''了'与任何文本都共现），
                         但短标签（如 'C++' 之外的 '画'）又需要它，
                         因此做成开关而不是硬编码。
    @return              token 列表（含重复，便于后续词频统计）
    """
    tokens: list[str] = []

    for kind, content in split_segments(text):
        if kind == "word":
            if content in STOPWORDS_EN or len(content) == 1:
                # 单字母无区分度（'a'、'i' 之外基本是噪声）
                continue
            tokens.append(content)
            continue

        # 中文：生成各阶 n-gram
        length = len(content)
        for n in ngrams:
            if n == 1 and not keep_unigram:
                continue
            if length < n:
                continue
            for i in range(length - n + 1):
                gram = content[i:i + n]
                if n == 1 and gram in STOPWORDS_ZH:
                    continue
                tokens.append(gram)

    return tokens


def token_set(text: str, ngrams: tuple[int, ...] = (2, 3)) -> set[str]:
    """返回去重后的 token 集合（用于集合相似度，如 Jaccard）。"""
    return set(tokenize(text, ngrams=ngrams))


def keyword_tokens(text: str) -> list[str]:
    """抽取"类关键词"token：英文整词 + 中文 2~4 字 n-gram。

    用于可解释性展示 —— 让用户看到"系统是从哪些词判断相似的"。
    """
    out: list[str] = []
    for kind, content in split_segments(text):
        if kind == "word":
            if content not in STOPWORDS_EN and len(content) > 1:
                out.append(content)
        else:
            for n in (2, 3, 4):
                if len(content) >= n:
                    out.extend(content[i:i + n] for i in range(len(content) - n + 1))
    # 保持顺序去重
    seen: set[str] = set()
    uniq: list[str] = []
    for t in out:
        if t not in seen:
            seen.add(t)
            uniq.append(t)
    return uniq


def split_semantic_segments(text: str, min_len: int = 2, max_segments: int = 6) -> list[str]:
    """把长句切成"语义片段"。

    【为什么需要它】
      实测同一语义的召回分数随句子变长而**单调下降**：

          动态交互                      -> 0.340
          动态交互 作品集                -> 0.239
          动态交互效果 作品集页面        -> 0.190
          需要会做动态交互效果的同学，帮我把作品集页面做得活一点 -> 0.095

      排序始终是对的（都指向 JS 动画与交互实现），但分数被对话填充词稀释：
      "我需要…的同学""帮我把…做得活一点" 这类词在技能短文本里罕见，
      IDF 反而高，于是平摊走了向量权重，把真正有信息量的词压到很低。
      结果就是正确标签被分数阈值一刀切掉 —— 表现为"用户正常说一句话却解析不出结果"。

      这不是阈值问题：降阈值会把噪声一起放进来（见 embedder.has_known_terms 的说明）。
      正确做法是**让长句按片段检索**，让"动态交互效果"这一段的分数不被填充词拖累。

    【切分规则】
      以标点与停用词为边界，取最长匹配的停用词（停用词表里既有单字"的/会/把"，
      也有多字"需要/帮我"，只按单字切会把手艺词也切碎）。

    @param text         原始文本
    @param min_len      片段最小长度（含），过短的片段信息量不足
    @param max_segments 最多返回几段
    @return             语义片段列表；无有效片段时返回空列表
    """
    if not text:
        return []
    norm = normalize(text)
    # 先按标点切成粗段
    rough = [p for p in RE_PUNCT.split(norm) if p]
    # 停用词按长度降序，保证"需要"优先于"要"被匹配
    stops = sorted(STOPWORDS_ZH, key=len, reverse=True)

    segments: list[str] = []
    for chunk in rough:
        buf: list[str] = []
        i = 0
        while i < len(chunk):
            hit = None
            for s in stops:
                if chunk.startswith(s, i):
                    hit = s
                    break
            if hit:
                if buf:
                    segments.append("".join(buf))
                    buf = []
                i += len(hit)
            else:
                buf.append(chunk[i])
                i += 1
        if buf:
            segments.append("".join(buf))

    out: list[str] = []
    seen: set[str] = set()
    for seg in segments:
        seg = seg.strip()
        # 至少含 min_len 个 CJK 字符或一个英文词，才算有信息量
        cjk = len(RE_CJK.findall(seg))
        if cjk < min_len and not RE_WORD.search(seg):
            continue
        if seg in seen:
            continue
        seen.add(seg)
        out.append(seg)
        if len(out) >= max_segments:
            break
    return out


def overlapping_terms(a: str, b: str, top: int = 8) -> list[str]:
    """找出两段文本共有的显著 token，用于解释"为什么判定相似"。

    优先返回较长的 token（3 字 n-gram 比 2 字更有解释力）。

    @param a   文本 A
    @param b   文本 B
    @param top 最多返回几个
    @return    共有 token 列表，长的在前
    """
    ta = token_set(a, ngrams=(2, 3))
    tb = token_set(b, ngrams=(2, 3))
    common = ta & tb
    # 去掉被更长 token 完全包含的短 token（'数学建模' 已命中则不必再列 '数学'）
    ordered = sorted(common, key=lambda x: (-len(x), x))
    result: list[str] = []
    for t in ordered:
        if any(t in longer for longer in result):
            continue
        result.append(t)
        if len(result) >= top:
            break
    return result
