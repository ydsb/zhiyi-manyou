package com.nwu.zhiyi.service.skill;

import com.nwu.zhiyi.api.dto.skill.ParseResultVO;
import com.nwu.zhiyi.api.dto.skill.SkillMatchVO;
import com.nwu.zhiyi.api.dto.skill.SkillVO;
import com.nwu.zhiyi.domain.entity.Skill;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 跨学科技能文本解析引擎。
 *
 * <p><b>对应需求</b>：FR-M2-01（自然语言发布）、FR-M2-02（抽取三元组并映射标准标签）、
 * FR-M2-07（跨域同义词映射）。
 *
 * <p><b>为什么先做规则+词典而不是直接上模型</b>：
 * <ol>
 *   <li>S2 阶段（2026.8–11）需要先跑通业务闭环，模型服务属 S3 阶段交付物；</li>
 *   <li>规则引擎完全离线可用，可满足 NFR-R-03 的 AI 依赖降级要求；</li>
 *   <li>接口契约（{@link ParseResultVO}）与 S3 阶段的模型输出保持一致，
 *       届时只需替换 {@code engine} 字段与内部实现，前端无需改动。</li>
 * </ol>
 *
 * <p><b>算法</b>：
 * <pre>
 *  1. 文本规范化：全角转半角、统一小写、压缩空白
 *  2. 词典匹配：用技能名与别名做多模式子串匹配，长词优先，标记已消费区间
 *  3. 意图判定：在命中位置前 12 字窗口内匹配意图规则（擅长/想学/急需）
 *  4. 打分排序：按匹配方式权重 + 释义程度 + 热度加成，去重后取 Top-K
 *  5. 三元组抽取：(主体, 动作, 技能实体)
 * </pre>
 *
 * @author 李泽宬
 */
@Slf4j
@Component
public class SkillTextParser {

    /** 意图判定时向前回溯的字符窗口 */
    private static final int INTENT_WINDOW = 12;

    /** 主体缺省值 */
    private static final String DEFAULT_SUBJECT = "我";

    /** 英文关键词最短匹配长度，避免 "C" 这类单字母误命中 */
    private static final int MIN_ASCII_KEYWORD_LENGTH = 3;

    /** 意图关键词最短长度（用于不含 minLength 的规则，过滤单字噪声） */
    private static final int MIN_INTENT_KEYWORD_LENGTH = 2;

    /**
     * 意图规则：按"最具体优先"排序，同距离时先出现的规则胜出。
     *
     * <p><b>关于「会」的处理</b>：「会」是典型的歧义词 ——
     * 「我<span>会</span> Vue」表示擅长，「我需要一位<span>会</span>做动效的同学」表示在描述他人能力。
     * 单字无法靠距离区分，因此：
     * <ul>
     *   <li>{@code minLength = 1} 的白名单里只保留明确的技能归属表达（会/教/能/懂）；
     *       它们只在紧邻技能词时（距离最短）才生效；</li>
     *   <li>「会做」这类 2 字短语统一归入 SKILLED（表达能力，而非需求），
     *       优先级高于远距离的「需要」，因为"需要一位会做X的同学"里 X 的能力才是匹配要点；</li>
     *   <li>多字需求词（需要/急需/求助/求带…）在距离更近时正常胜出。</li>
     * </ul>
     */
    private static final List<IntentRule> INTENT_RULES = List.of(
            // 我擅长 / 可提供 / 我能教
            new IntentRule(new String[]{"擅长", "精通", "会做", "能做", "可以教", "能教", "可教", "我教",
                    "教别人", "带你", "辅导", "主讲", "负责过", "做过", "拿手", "熟悉", "掌握",
                    "提供", "可以帮", "能帮", "帮你做"},
                    "SKILLED", "擅长", "我擅长", MIN_INTENT_KEYWORD_LENGTH),
            // 单字归属表达：仅在紧邻技能词时生效（更低优先级由距离决定）
            new IntentRule(new String[]{"会", "教", "能", "懂"},
                    "SKILLED", "擅长", "我擅长", 1),
            // 我正在研究 / 想学 / 在学
            // 注：「教我 / 带我做 / 求教 / 请教」表达的是"我被教"= 学习诉求，
            // 必须显式登记，否则会被紧邻技能词的单字「教」误判为 SKILLED。
            new IntentRule(new String[]{"正在研究", "正在学", "在学", "想学", "想学习", "求教", "入门",
                    "自学", "研究", "想了解", "正在做", "在做", "准备学", "打算学", "想入门",
                    "教我", "带我做", "带我学", "请教", "指导我", "帮我入门"},
                    "RESEARCHING", "想学", "我正在研究", MIN_INTENT_KEYWORD_LENGTH),
            // 我急需 / 求助 / 找人
            new IntentRule(new String[]{"急需", "需要", "求助", "求带", "求指导", "找人", "找一位",
                    "希望有人", "有人能", "谁会", "谁懂", "求个", "招募", "请人", "需要一位", "需要会"},
                    "NEEDED", "需要", "我急需", MIN_INTENT_KEYWORD_LENGTH)
    );

    /** 主体识别规则 */
    private static final String[] SUBJECT_PATTERNS = {"我会", "我能", "我擅长", "我需要", "我想", "我在", "我是"};

    /** 词典索引缓存（volatile + 同步块，保证并发解析安全） */
    private volatile Map<Character, List<Token>> tokenIndex;
    private volatile List<Skill> indexedSource;

    /**
     * 解析非结构化文本。
     *
     * @param text      用户输入的自然语言
     * @param source    全量技能词典（调用方负责缓存）
     * @param limit     返回上限
     * @param withGraph 是否允许后续做图谱补充（由服务层处理，此处仅回传标记）
     * @return 解析结果
     */
    public ParseResultVO parse(String text, List<Skill> source, int limit, boolean withGraph) {
        ParseResultVO result = new ParseResultVO();
        result.setEngine("RULE_LEXICON");
        result.setDegraded(true); // S2 阶段为规则降级通道，S3 接入模型后置为 false

        if (text == null || text.isBlank()) {
            result.setText("");
            result.setHint("文本为空");
            return result;
        }
        result.setText(text);
        result.setSubject(extractSubject(text));

        String normalized = normalize(text);
        List<Candidate> candidates = lexiconMatch(normalized, tokenIndexOf(source));

        // 去重：同一标签保留最高分，合并命中方式与依据
        Map<Long, Candidate> best = new LinkedHashMap<>();
        for (Candidate c : candidates) {
            best.merge(c.skill.getId(), c, Candidate::betterOf);
        }

        List<Candidate> ranked = new ArrayList<>(best.values());
        ranked.sort(Comparator.comparingDouble(Candidate::score).reversed());

        int max = Math.max(1, Math.min(limit, 50));
        List<SkillMatchVO> matched = new ArrayList<>();
        for (Candidate c : ranked) {
            if (matched.size() >= max) {
                break;
            }
            matched.add(SkillMatchVO.of(SkillVO.of(c.skill), c.intent, c.score(), c.type, c.reason));
        }
        result.setMatched(matched);
        result.setTriples(buildTriples(matched));

        if (matched.isEmpty()) {
            result.setHint("未匹配到标准化标签，可尝试补充更具体的技能描述，或由用户手工选择标签");
        } else if (withGraph) {
            result.setHint("已返回语义命中标签，图谱关联标签由接口层补充");
        }
        return result;
    }

    /* ==================== 文本规范化 ==================== */

    /**
     * 全角转半角 + 小写化 + 压缩空白。
     *
     * @param text 原始文本
     * @return 规范化文本
     */
    public static String normalize(String text) {
        if (text == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder(text.length());
        for (char ch : text.toCharArray()) {
            // 全角 ASCII（！-～，即 U+FF01~U+FF5E）转半角
            if (ch >= '\uFF01' && ch <= '\uFF5E') {
                sb.append((char) (ch - 0xFEE0));
            } else if (ch == '\u3000') {
                // 全角空格
                sb.append(' ');
            } else {
                sb.append(ch);
            }
        }
        return sb.toString().toLowerCase().replaceAll("\\s+", " ").trim();
    }

    /* ==================== 词典匹配 ==================== */

    /**
     * 由技能词典构建"首字符 → 候选关键词"索引。
     *
     * <p>为什么需要它：早期实现直接对每个技能名/别名做 {@code indexOf}，有两个缺陷：
     * <ol>
     *   <li>只取第一个出现位置，当文本中同一标签出现多次（其中一次是更长匹配）时会选错；</li>
     *   <li>每个关键词都要扫全文一次，标签规模上千时是 O(标签数 × 文本长度)。</li>
     * </ol>
     * 改为按首字符分桶 + 每个位置做最长匹配优先，既修正正确性也把成本降到
     * O(文本长度 × 同首字符关键词数)。
     *
     * <p>索引本身按词典引用缓存：{@code SkillServiceImpl} 的词典来自 Spring Cache，
     * 引用稳定；缓存被清除后会产生新的 List 实例，从而自然触发索引重建。
     *
     * @param source 技能词典
     * @return 首字符索引，value 按关键词长度降序（最长优先）
     */
    private Map<Character, List<Token>> tokenIndexOf(List<Skill> source) {
        if (source == null || source.isEmpty()) {
            return Map.of();
        }
        if (indexedSource == source && tokenIndex != null) {
            return tokenIndex;
        }
        synchronized (this) {
            if (indexedSource != source || tokenIndex == null) {
                tokenIndex = buildTokenIndex(source);
                indexedSource = source;
                log.debug("[技能词典索引] 已重建，关键词条目数={}",
                        tokenIndex.values().stream().mapToInt(List::size).sum());
            }
            return tokenIndex;
        }
    }

    private Map<Character, List<Token>> buildTokenIndex(List<Skill> source) {
        Map<Character, List<Token>> index = new HashMap<>();
        for (Skill skill : source) {
            List<String> keywords = new ArrayList<>(4);
            List<SkillMatchVO.MatchType> types = new ArrayList<>(4);

            keywords.add(normalize(skill.getName()));
            types.add(SkillMatchVO.MatchType.EXACT);

            if (skill.getAlias() != null && !skill.getAlias().isBlank()) {
                for (String raw : skill.getAlias().split("[,，、;；]")) {
                    String alias = normalize(raw);
                    if (!isMatchable(alias) || alias.equals(keywords.get(0))) {
                        continue;
                    }
                    keywords.add(alias);
                    types.add(SkillMatchVO.MatchType.ALIAS);
                }
            }

            for (int i = 0; i < keywords.size(); i++) {
                String keyword = keywords.get(i);
                if (!isMatchable(keyword)) {
                    continue;
                }
                index.computeIfAbsent(keyword.charAt(0), k -> new ArrayList<>())
                        .add(new Token(keyword, skill, types.get(i)));
            }
        }
        // 长关键词优先，保证"数据爬取"优先于"数据"
        index.values().forEach(list -> list.sort(Comparator.comparingInt((Token t) -> t.keyword().length()).reversed()));
        return index;
    }

    /**
     * 按首字符索引扫描文本，逐位置做最长匹配。
     *
     * @param normalized 规范化文本
     * @param index      首字符索引
     * @return 候选列表（未去重）
     */
    private List<Candidate> lexiconMatch(String normalized, Map<Character, List<Token>> index) {
        List<Candidate> candidates = new ArrayList<>();
        if (normalized.isEmpty() || index.isEmpty()) {
            return candidates;
        }
        for (int i = 0; i < normalized.length(); i++) {
            List<Token> tokens = index.get(normalized.charAt(i));
            if (tokens == null) {
                continue;
            }
            for (Token token : tokens) {
                String keyword = token.keyword();
                // 已按长度降序，命中即跳出 —— 最长匹配优先
                if (normalized.startsWith(keyword, i)) {
                    candidates.add(buildCandidate(token.skill(), i, keyword.length(), normalized,
                            token.type(), reasonOf(token)));
                    break;
                }
            }
        }
        return candidates;
    }

    /** 生成匹配依据文案 */
    private String reasonOf(Token token) {
        return token.type() == SkillMatchVO.MatchType.EXACT
                ? "技能名称命中「" + token.skill().getName() + "」"
                : "同义词「" + token.keyword() + "」映射到「" + token.skill().getName() + "」";
    }

    /**
     * 关键词是否值得参与匹配。
     *
     * <p>中文 2 字以上即可（如"建模"）；纯 ASCII 需 3 字符以上，避免 "c"、"js" 之类误命中。
     */
    private boolean isMatchable(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return false;
        }
        boolean asciiOnly = keyword.chars().allMatch(c -> c < 128);
        return asciiOnly ? keyword.length() >= MIN_ASCII_KEYWORD_LENGTH : keyword.length() >= 2;
    }

    private Candidate buildCandidate(Skill skill, int idx, int length, String normalized,
                                     SkillMatchVO.MatchType type, String reason) {
        IntentHit intent = detectIntent(normalized, idx);
        double score = computeScore(type, skill, length, intent);
        return new Candidate(skill, type, intent.intent, score, reason + intent.note());
    }

    /* ==================== 意图判定 ==================== */

    /**
     * 在命中位置前 {@link #INTENT_WINDOW} 字窗口内判定意图。
     *
     * <p><b>取"离技能词最近"的关键词</b>，而不是"按规则优先级第一个命中"。
     * 这是踩过坑后的修正：早前实现按规则顺序返回首个命中，SKILLED 规则里的单字
     * 「会」会在"我需要<span>会</span>做动态交互效果"中抢在更靠前的「需要」之前命中，
     * 把需求意图误判成擅长意图。改成比距离后，「需要」（距离更近）胜出，判定正确。
     *
     * <p>同时给意图关键词加了最小长度限制（半角≥2、全角≥2），过滤「会」「教」
     * 这类单字歧义词造成的噪声。
     *
     * @param normalized 规范化文本
     * @param hitIndex   命中起始位置
     * @return 意图判定结果
     */
    private IntentHit detectIntent(String normalized, int hitIndex) {
        int from = Math.max(0, hitIndex - INTENT_WINDOW);
        String window = normalized.substring(from, hitIndex);

        IntentRule bestRule = null;
        String bestKeyword = null;
        int bestDistance = Integer.MAX_VALUE;

        for (IntentRule rule : INTENT_RULES) {
            for (String keyword : rule.keywords) {
                if (keyword.length() < rule.minLength()) {
                    continue;
                }
                int idx = window.lastIndexOf(keyword);
                if (idx < 0) {
                    continue;
                }
                // 关键词结束位置距技能词的字符数，越小越近
                int distance = window.length() - (idx + keyword.length());
                // 距离更近者胜出；同距离时按规则声明顺序（更具体的规则排在前面）
                if (distance < bestDistance) {
                    bestDistance = distance;
                    bestRule = rule;
                    bestKeyword = keyword;
                }
            }
        }

        if (bestRule != null) {
            return new IntentHit(bestRule.intent, bestRule.action,
                    "，意图：" + bestRule.label + "（依据「" + bestKeyword + "」）");
        }
        // 未识别出意图时，按"我正在研究"处理（跨学科探索的默认语义）
        return new IntentHit("RESEARCHING", "涉及", "");
    }

    /**
     * 提取主体。当前以第一人称为主，后续可扩展为"我同学/我们组"等。
     */
    private String extractSubject(String text) {
        for (String pattern : SUBJECT_PATTERNS) {
            if (text.contains(pattern)) {
                return DEFAULT_SUBJECT;
            }
        }
        return DEFAULT_SUBJECT;
    }

    /* ==================== 打分 ==================== */

    /**
     * 综合打分：匹配方式权重 × 释义加成 × 热度加成，上限 1.0。
     *
     * <p>热度加成让被频繁交换的技能更容易被推荐，同时避免冷门标签永不出现
     * （热度项权重很小，仅 0~0.05）。
     */
    private double computeScore(SkillMatchVO.MatchType type, Skill skill, int matchedLength, IntentHit intent) {
        double score = type.getBaseWeight();

        // 释义加成：命中的关键词越长，说明描述越具体（最多 +0.08）
        score += Math.min(0.08, Math.max(0, matchedLength - 2) * 0.02);

        // 热度加成：0~0.05
        int hot = skill.getHotScore() == null ? 0 : skill.getHotScore();
        score += Math.min(0.05, hot / 2000.0);

        // 明确表达意图的，略微加权（体现"用户在提需求"而非泛泛而谈）
        if (!"RESEARCHING".equals(intent.intent)) {
            score += 0.02;
        }
        return Math.min(1.0, BigDecimal.valueOf(score).setScale(4, RoundingMode.HALF_UP).doubleValue());
    }

    /* ==================== 三元组 ==================== */

    /**
     * 由匹配结果构造 (主体, 动作, 技能实体) 三元组。
     */
    private List<ParseResultVO.Triple> buildTriples(List<SkillMatchVO> matched) {
        List<ParseResultVO.Triple> triples = new ArrayList<>();
        Set<String> seen = new HashSet<>();
        for (SkillMatchVO m : matched) {
            String action = switch (m.getIntent() == null ? "" : m.getIntent()) {
                case "SKILLED" -> "擅长";
                case "NEEDED" -> "需要";
                default -> "涉及";
            };
            String key = action + "|" + m.getName();
            if (seen.add(key)) {
                triples.add(new ParseResultVO.Triple(DEFAULT_SUBJECT, action, m.getName()));
            }
        }
        return triples;
    }

    /* ==================== 内部类型 ==================== */

    /** 意图规则 */
    private record IntentRule(String[] keywords, String intent, String action, String label, int minLength) {
    }

    /** 意图判定结果 */
    private record IntentHit(String intent, String action, String note) {
    }

    /**
     * 词典条目：一个可匹配的关键词（技能名或别名）及其归属技能与匹配方式。
     */
    private record Token(String keyword, Skill skill, SkillMatchVO.MatchType type) {
    }

    /** 候选匹配项 */
    private record Candidate(Skill skill, SkillMatchVO.MatchType type, String intent, double score, String reason) {

        /**
         * 合并同一标签的多次命中：取更高分者，并拼接匹配依据。
         */
        Candidate betterOf(Candidate other) {
            if (other.score() > this.score()) {
                return new Candidate(other.skill(), other.type(), other.intent(), other.score(),
                        other.reason() + "；" + this.reason());
            }
            return new Candidate(this.skill(), this.type(), this.intent(), this.score(),
                    this.reason() + "；" + other.reason());
        }
    }
}
