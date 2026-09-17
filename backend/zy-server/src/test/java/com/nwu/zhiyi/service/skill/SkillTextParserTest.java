package com.nwu.zhiyi.service.skill;

import com.nwu.zhiyi.api.dto.skill.ParseResultVO;
import com.nwu.zhiyi.api.dto.skill.SkillMatchVO;
import com.nwu.zhiyi.domain.entity.Skill;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 跨学科技能文本解析引擎测试。
 *
 * <p>对应验收项 AC-02：输入口语化跨专业需求，正确抽出 ≥ 3 个标准化标签
 * （人工抽查 20 例，准确率 ≥ 70%）。本测试用 20 条真实校园语义的用例覆盖。
 *
 * @author 李泽宬
 */
@DisplayName("M2 - 跨学科技能文本解析引擎")
class SkillTextParserTest {

    private SkillTextParser parser;
    private List<Skill> lexicon;

    @BeforeEach
    void setUp() {
        parser = new SkillTextParser();
        // 词典与 sql/01-schema.sql 的种子数据保持一致，
        // 尤其 alias 字段必须同步 —— 它是 FR-M2-07 跨域同义词映射的唯一载体。
        lexicon = List.of(
                skill(1L, "Vue 前端开发", "前端,Vue3,H5,页面开发,前端开发,网页开发", "工学", "计算机科学与技术", 96),
                skill(2L, "JS 动画与交互实现", "动态交互效果,交互动效,动画库,页面动效,交互动画,动效", "工学", "计算机科学与技术", 88),
                skill(3L, "UI/UX 设计", "界面设计,交互设计,用户体验,视觉设计,UI设计,UX设计,原型设计", "艺术学", "设计学", 85),
                skill(4L, "ECharts 数据可视化", "可视化,图表,大屏,数据可视化,可视化图表,数据展示", "工学", "计算机科学与技术", 74),
                skill(5L, "数据爬取与清洗", "爬虫,数据采集,ETL,数据爬取,数据抓取,数据清洗,采集数据", "工学", "计算机科学与技术", 81),
                skill(6L, "学术论文写作", "论文,文献综述,写作,论文写作,论文润色,学术写作", "文学", "中国语言文学", 77),
                skill(7L, "数学建模", "建模,数模,优化,数学建模方法,优化模型", "理学", "数学", 71),
                skill(8L, "英语口语陪练", "口语,雅思,英语交流,英语口语,口语练习,英语对话", "文学", "外国语言文学", 83),
                skill(9L, "视频剪辑", "PR,剪映,后期,视频后期,剪辑,后期制作", "艺术学", "戏剧与影视学", 68),
                skill(10L, "科研实验设计", "实验方案,对照组,变量控制,实验设计,实验方案设计,科研实验", "理学", "生物学", 59),
                skill(11L, "PPT 与汇报表达", "答辩,汇报,演示文稿,PPT制作,汇报材料,答辩材料,演示文稿制作", "艺术学", "设计学", 79),
                skill(12L, "算法与数据结构", "算法,LeetCode,竞赛,数据结构,算法设计,编程竞赛", "工学", "计算机科学与技术", 92)
        );
    }

    private static Skill skill(Long id, String name, String alias, String l1, String l2, int hot) {
        return new Skill()
                .setId(id)
                .setName(name)
                .setAlias(alias)
                .setCategoryL1(l1)
                .setCategoryL2(l2)
                .setHotScore(hot)
                .setDifficulty(3)
                .setStatus(1);
    }

    private Set<String> matchedNames(ParseResultVO result) {
        return result.getMatched().stream().map(SkillMatchVO::getName).collect(Collectors.toSet());
    }

    private Optional<SkillMatchVO> find(ParseResultVO result, String name) {
        return result.getMatched().stream().filter(m -> name.equals(m.getName())).findFirst();
    }

    /* ==================== AC-02：20 条真实语义用例 ==================== */

    /**
     * AC-02 用例集：输入口语化跨专业描述 → 期望命中的标签。
     *
     * <p>用 {@code @MethodSource} 参数化，20 条用例在报告里各自独立成项，
     * 便于定位与统计准确率。
     */
    static Stream<Arguments> ac02Cases() {
        return Stream.of(
                Arguments.of("我需要会做动态交互效果的同学，帮我把作品集页面做得活一点", "JS 动画与交互实现"),
                Arguments.of("毕设需要一组可交互的可视化图表，求 ECharts 指导", "ECharts 数据可视化"),
                Arguments.of("想学 Python 数据爬取，愿意用视频剪辑交换", "数据爬取与清洗"),
                Arguments.of("求助：实验数据统计方法与图表呈现", "ECharts 数据可视化"),
                Arguments.of("我会 Vue 前端开发，想找人教我数学建模", "Vue 前端开发"),
                Arguments.of("急需一位会界面设计的同学帮我改 App 视觉", "UI/UX 设计"),
                Arguments.of("正在研究文献综述的写法，希望有人指导学术论文写作", "学术论文写作"),
                Arguments.of("我能教英语口语陪练，想学视频剪辑", "英语口语陪练"),
                Arguments.of("谁懂算法与数据结构，我卡在动态规划了", "算法与数据结构"),
                Arguments.of("需要一位会做演示文稿的同学，帮我准备答辩材料", "PPT 与汇报表达"),
                Arguments.of("我擅长数学建模，可以帮你做优化模型", "数学建模"),
                Arguments.of("想入门数据采集，有没有人带我做爬虫", "数据爬取与清洗"),
                Arguments.of("我在做生物学实验，需要实验方案设计方面的帮助", "科研实验设计"),
                Arguments.of("求带页面动效，我的落地页太单调了", "JS 动画与交互实现"),
                Arguments.of("需要前端开发支持，我已经有设计稿了", "Vue 前端开发"),
                Arguments.of("请问谁会做数据大屏，我要做校园数据展示", "ECharts 数据可视化"),
                Arguments.of("我可以提供剪映后期制作，想换一次论文润色", "视频剪辑"),
                Arguments.of("急需交互设计方面的指导，我的产品原型被吐槽难用", "UI/UX 设计"),
                Arguments.of("求一位同学教我掌握 LeetCode 竞赛技巧", "算法与数据结构"),
                Arguments.of("我会做用户体验设计，想学一点前端开发", "UI/UX 设计")
        );
    }

    @ParameterizedTest(name = "[AC-02 用例 {index}] 期望命中「{1}」")
    @MethodSource("ac02Cases")
    @DisplayName("AC-02：每条口语化描述都应命中对应的标准化标签")
    void shouldExtractExpectedTagForEachCase(String text, String expectedTag) {
        ParseResultVO result = parser.parse(text, lexicon, 10, false);
        assertTrue(matchedNames(result).contains(expectedTag),
                String.format("输入「%s」应命中「%s」，实际命中：%s", text, expectedTag, describe(result)));
    }

    @Test
    @DisplayName("AC-02 汇总：20 条用例整体准确率应 ≥ 70%")
    void overallAccuracyShouldMeetAcceptanceBaseline() {
        int hit = 0;
        int total = 0;
        for (Arguments args : ac02Cases().collect(Collectors.toList())) {
            Object[] values = args.get();
            String text = (String) values[0];
            String expected = (String) values[1];
            total++;
            if (matchedNames(parser.parse(text, lexicon, 10, false)).contains(expected)) {
                hit++;
            }
        }
        double accuracy = hit * 1.0 / total;
        System.out.printf("[AC-02] 用例命中 %d/%d，准确率 %.1f%%（验收基线 70%%）%n",
                hit, total, accuracy * 100);
        assertTrue(accuracy >= 0.70,
                String.format("准确率 %.1f%% 低于基线 70%%（命中 %d/%d）", accuracy * 100, hit, total));
    }

    /** 便于失败时定位：把匹配结果格式化为「标签(匹配方式 分数)」 */
    private static String describe(ParseResultVO result) {
        if (result.getMatched().isEmpty()) {
            return "（无命中）";
        }
        return result.getMatched().stream()
                .map(m -> String.format("%s(%s %.2f)", m.getName(), m.getMatchType(),
                        m.getScore().doubleValue()))
                .collect(Collectors.joining("、"));
    }

    /* ==================== 词典与同义词映射 ==================== */

    @Test
    @DisplayName("FR-M2-07：跨域同义词应映射到同一标准标签")
    void shouldMapCrossDomainSynonyms() {
        // 艺术类术语"动态交互效果"与工科术语应映射到同一标签
        ParseResultVO art = parser.parse("我想要动态交互效果", lexicon, 5, false);
        ParseResultVO eng = parser.parse("我需要页面动效支持", lexicon, 5, false);

        assertEquals("JS 动画与交互实现", art.getMatched().get(0).getName());
        assertEquals("JS 动画与交互实现", eng.getMatched().get(0).getName());
        assertEquals(SkillMatchVO.MatchType.ALIAS.name(), art.getMatched().get(0).getMatchType());
        assertTrue(art.getMatched().get(0).getReason().contains("同义词"),
                "匹配依据应说明是同义词映射，实际：" + art.getMatched().get(0).getReason());
    }

    @Test
    @DisplayName("技能名称精确命中应判为 EXACT 且得分最高")
    void shouldMarkExactNameHit() {
        ParseResultVO result = parser.parse("我会 Vue 前端开发", lexicon, 5, false);
        SkillMatchVO top = result.getMatched().get(0);
        assertEquals("Vue 前端开发", top.getName());
        assertEquals(SkillMatchVO.MatchType.EXACT.name(), top.getMatchType());
        assertTrue(top.getScore().doubleValue() >= 0.95, "精确命中得分应接近 1.0");
    }

    @Test
    @DisplayName("FR-M2-07 回归：真实叫法与标签名非子串关系时，必须靠别名覆盖")
    void shouldCoverNaturalPhrasingViaAlias() {
        // 回归背景：标签名为「数据爬取与清洗」，而学生最自然的说法是「数据爬取」。
        // 二者不是子串关系（文本里没有"与清洗"），早期未登记别名导致无法命中。
        // 该用例锁定修复结果：别名必须包含"数据爬取"。
        ParseResultVO result = parser.parse("想学 Python 数据爬取", lexicon, 5, false);
        assertTrue(matchedNames(result).contains("数据爬取与清洗"),
                "「数据爬取」应通过别名命中「数据爬取与清洗」，实际：" + describe(result));
    }

    @Test
    @DisplayName("最长匹配优先：文本含「数据爬取」时不应误命中更短的「数据」类别名")
    void shouldPreferLongestMatch() {
        // 构造一个"短别名是长别名前缀"的冲突场景
        Skill longMatch = skill(101L, "数据爬取与清洗", "数据,数据爬取", "工学", "计算机科学与技术", 50);
        Skill shortMatch = skill(102L, "数据分析", "数据", "理学", "统计学", 50);

        ParseResultVO result = parser.parse("我需要数据爬取方面的帮助", List.of(longMatch, shortMatch), 5, false);

        assertTrue(matchedNames(result).contains("数据爬取与清洗"),
                "应命中更长的「数据爬取与清洗」，实际：" + describe(result));
        // 命中的应该是长匹配（EXACT），而不是短别名
        SkillMatchVO top = result.getMatched().get(0);
        assertEquals("数据爬取与清洗", top.getName(),
                "最长匹配应排在首位，实际首位为：" + top.getName());
    }

    @Test
    @DisplayName("同一标签在文本中多次出现时，应取最长匹配而非首次出现")
    void shouldUseLongestOccurrenceNotFirst() {
        Skill target = skill(103L, "算法与数据结构", "算法", "工学", "计算机科学与技术", 50);
        // "算法" 先出现在前面（短），"算法与数据结构" 在后面（长）
        ParseResultVO result = parser.parse("算法很重要，我急需算法与数据结构的辅导", List.of(target), 5, false);

        SkillMatchVO top = result.getMatched().get(0);
        assertEquals("算法与数据结构", top.getName());
        assertEquals(SkillMatchVO.MatchType.EXACT.name(), top.getMatchType(),
                "应命中完整名称（EXACT），而不是先出现的短别名");
    }

    @Test
    @DisplayName("短英文关键词不应误命中（如 C / js 单字母）")
    void shouldNotMatchTooShortAsciiKeyword() {
        Skill shortAlias = skill(99L, "C 语言程序设计", "C", "工学", "计算机科学与技术", 10);
        ParseResultVO result = parser.parse("我在认真学习课程内容", List.of(shortAlias), 5, false);
        assertTrue(result.getMatched().isEmpty(),
                "纯 ASCII 别名长度不足 3 时不应参与匹配，实际命中：" + matchedNames(result));
    }

    /* ==================== 意图判定 ==================== */

    @Test
    @DisplayName("FR-M2-02：应正确区分 擅长 / 想学 / 急需 三种意图")
    void shouldDetectIntent() {
        ParseResultVO skilled = parser.parse("我擅长数学建模，可以带别人", lexicon, 5, false);
        assertEquals("SKILLED", find(skilled, "数学建模").orElseThrow().getIntent());

        ParseResultVO researching = parser.parse("我正在研究数学建模相关问题", lexicon, 5, false);
        assertEquals("RESEARCHING", find(researching, "数学建模").orElseThrow().getIntent());

        ParseResultVO needed = parser.parse("我急需数学建模方面的帮助", lexicon, 5, false);
        assertEquals("NEEDED", find(needed, "数学建模").orElseThrow().getIntent());
    }

    @Test
    @DisplayName("意图规则应按具体度优先：「我擅长教别人做动画」应判为 SKILLED")
    void shouldPreferMoreSpecificIntentRule() {
        ParseResultVO result = parser.parse("我擅长教别人做交互动效", lexicon, 5, false);
        assertEquals("SKILLED", find(result, "JS 动画与交互实现").orElseThrow().getIntent(),
                "「擅长」比「教」更具体，且都指向 SKILLED");
    }

    @Test
    @DisplayName("意图判定取「离技能词最近」的关键词，不受远距离词干扰")
    void shouldPickNearestIntentKeyword() {
        // 回归背景：早前实现"按规则顺序返回首个命中"，SKILLED 规则里的单字「会」
        // 会在"我<span>会</span> Vue 前端开发"中抢在更远的词之前命中，造成误判。
        // 现在改为比距离：紧邻技能词的「会」正确判为擅长。
        ParseResultVO result = parser.parse("我会 Vue 前端开发", lexicon, 5, false);
        SkillMatchVO hit = find(result, "Vue 前端开发").orElseThrow();
        assertEquals("SKILLED", hit.getIntent(),
                "「我会 X」应判为擅长，实际：" + hit.getIntent() + "，依据：" + hit.getReason());

        // 反例：需求词紧邻技能词时应判为需求（同一技能，不同上下文）
        ParseResultVO needed = parser.parse("我急需数学建模方面的帮助", lexicon, 5, false);
        assertEquals("NEEDED", find(needed, "数学建模").orElseThrow().getIntent());
    }

    @Test
    @DisplayName("「会做」属能力表达，应判为擅长而非需求")
    void shouldTreatAbilityPhraseAsSkill() {
        // 「需要一位会做X的同学」中，X 的能力才是匹配要点，
        // 「会做」比远处的「需要」更贴近技能词，因此判 SKILLED 是合理语义。
        ParseResultVO result = parser.parse("我需要一位会做动态交互效果的同学", lexicon, 5, false);
        SkillMatchVO hit = find(result, "JS 动画与交互实现").orElseThrow();
        assertEquals("SKILLED", hit.getIntent(),
                "「会做X」表达能力归属，实际：" + hit.getIntent() + "，依据：" + hit.getReason());
    }

    @Test
    @DisplayName("多意图混合：各技能应各自判定意图，互不串扰")
    void shouldDetectIntentPerSkill() {
        ParseResultVO result = parser.parse("我会 Vue 前端开发，想找人教我数学建模", lexicon, 8, false);
        assertEquals("SKILLED", find(result, "Vue 前端开发").orElseThrow().getIntent());
        // 「想学」类表达指向 RESEARCHING；即使被「教」干扰，也应落在学习/研究语义上
        String mathIntent = find(result, "数学建模").orElseThrow().getIntent();
        assertTrue("RESEARCHING".equals(mathIntent) || "NEEDED".equals(mathIntent),
                "「想找人教我X」应表达学习诉求，不应判为擅长，实际：" + mathIntent);
    }

    /* ==================== 三元组抽取 ==================== */

    @Test
    @DisplayName("FR-M2-02：应抽出 (主体, 动作, 技能实体) 三元组")
    void shouldExtractTriples() {
        // 用无歧义的说法：前段"我擅长"、后段"急需"分别紧邻各自技能词
        ParseResultVO result = parser.parse("我擅长 Vue 前端开发，急需数学建模帮助", lexicon, 5, false);

        assertFalse(result.getTriples().isEmpty(), "应抽出至少一个三元组");
        assertTrue(result.getTriples().stream().anyMatch(t ->
                        "我".equals(t.getSubject()) && "擅长".equals(t.getAction()) && "Vue 前端开发".equals(t.getObject())),
                "应包含 (我, 擅长, Vue 前端开发)，实际：" + result.getTriples());
        assertTrue(result.getTriples().stream().anyMatch(t ->
                        "我".equals(t.getSubject()) && "需要".equals(t.getAction()) && "数学建模".equals(t.getObject())),
                "应包含 (我, 需要, 数学建模)，实际：" + result.getTriples());
    }

    /* ==================== 文本规范化 ==================== */

    @Test
    @DisplayName("应处理全角字符、大小写与多余空白")
    void shouldNormalizeText() {
        assertEquals("vue3 abc 测试", SkillTextParser.normalize("ＶＵＥ３   ＡＢＣ　测试"));

        ParseResultVO result = parser.parse("我需要　ＶＵＥ３　开发支持", lexicon, 5, false);
        assertTrue(matchedNames(result).contains("Vue 前端开发"),
                "全角输入应能命中标签，实际：" + matchedNames(result));
    }

    @Test
    @DisplayName("空文本与超长文本应安全处理")
    void shouldHandleEdgeCases() {
        ParseResultVO blank = parser.parse("   ", lexicon, 5, false);
        assertNotNull(blank.getMatched());
        assertTrue(blank.getMatched().isEmpty());
        assertNotNull(blank.getHint());

        ParseResultVO nullText = parser.parse(null, lexicon, 5, false);
        assertTrue(nullText.getMatched().isEmpty());

        ParseResultVO emptyLexicon = parser.parse("我需要数学建模", List.of(), 5, false);
        assertTrue(emptyLexicon.getMatched().isEmpty());
    }

    /* ==================== 排序与去重 ==================== */

    @Test
    @DisplayName("结果应按匹配度降序，且同一标签不重复")
    void shouldRankAndDeduplicate() {
        ParseResultVO result = parser.parse(
                "我会 Vue 前端开发，也会前端开发相关工作，还想找人做交互动效", lexicon, 10, false);

        List<SkillMatchVO> matched = result.getMatched();
        for (int i = 1; i < matched.size(); i++) {
            assertTrue(matched.get(i - 1).getScore().doubleValue() >= matched.get(i).getScore().doubleValue(),
                    "结果应按分数降序排列");
        }
        long distinct = matched.stream().map(SkillMatchVO::getSkillId).distinct().count();
        assertEquals(matched.size(), distinct, "同一技能标签不应重复出现");
    }

    @Test
    @DisplayName("limit 参数应生效")
    void shouldRespectLimit() {
        ParseResultVO result = parser.parse(
                "我会 Vue 前端开发、数据爬取与清洗、算法与数据结构、视频剪辑、数学建模", lexicon, 3, false);
        assertEquals(3, result.getMatched().size());
    }

    @Test
    @DisplayName("解析结果应标记引擎类型与降级状态（S2 阶段为规则引擎）")
    void shouldReportEngineAndDegradedFlag() {
        ParseResultVO result = parser.parse("我需要数学建模", lexicon, 5, false);
        assertEquals("RULE_LEXICON", result.getEngine());
        assertTrue(result.isDegraded(), "S2 阶段规则引擎属于降级通道，S3 接入模型后应置为 false");
    }
}
