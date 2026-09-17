package com.nwu.zhiyi.service.demand;

import com.nwu.zhiyi.api.dto.demand.MarketCardVO;
import com.nwu.zhiyi.common.enums.SkillIntent;
import com.nwu.zhiyi.common.enums.SkillRelationType;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.UserSkillProfile;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 集市匹配度计算测试（FR-M4-03）。
 *
 * @author 李泽宬
 */
@DisplayName("M4 - 集市匹配度计算")
class MatchScoreCalculatorTest {

    private MatchScoreCalculator calculator;

    /** 技能字典：1 前端 / 2 动效（与前端互补）/ 3 UI 设计（动效 Synonym）/ 4 数学建模 */
    private Map<Long, Skill> skillMap;

    @BeforeEach
    void setUp() {
        calculator = new MatchScoreCalculator();
        skillMap = Map.of(
                1L, skill(1L, "Vue 前端开发", "工学", "计算机科学与技术"),
                2L, skill(2L, "JS 动画与交互实现", "工学", "计算机科学与技术"),
                3L, skill(3L, "UI/UX 设计", "艺术学", "设计学"),
                4L, skill(4L, "数学建模", "理学", "数学")
        );
    }

    private static Skill skill(Long id, String name, String l1, String l2) {
        return new Skill().setId(id).setName(name).setCategoryL1(l1).setCategoryL2(l2)
                .setDifficulty(3).setHotScore(0).setStatus(1);
    }

    private static UserSkillProfile profile(String sno, Long skillId, SkillIntent intent) {
        return new UserSkillProfile().setSno(sno).setSkillId(skillId).setIntent(intent)
                .setLevel(3).setSource("SELF").setScore(java.math.BigDecimal.ZERO);
    }

    /** 图谱：2 与 3 互补；1 与 2 同二级学科 */
    private Map<Long, List<MatchScoreCalculator.Edge>> graph() {
        return MatchScoreCalculator.buildGraph(List.of(
                new MatchScoreCalculator.GraphEdgeRow(2L, 3L, SkillRelationType.COMPLEMENT),
                new MatchScoreCalculator.GraphEdgeRow(2L, 4L, SkillRelationType.SYNONYM)
        ));
    }

    private Demand demand(Long expectedSkillId, Long offerSkillId) {
        return new Demand()
                .setId(100L).setDemandNo("DM20260701001").setOwnerSno("owner")
                .setTitle("测试卡片").setExpectedSkillId(expectedSkillId).setOfferSkillId(offerSkillId)
                .setExpectedHours(8).setMatchCount(0).setViewCount(0)
                .setCreatedAt(LocalDateTime.now().minusHours(1));
    }

    private MarketCardVO.MatchFactor factor(MatchScoreCalculator.Score score, String name) {
        return score.factors().stream().filter(f -> name.equals(f.getName())).findFirst().orElseThrow();
    }

    @Test
    @DisplayName("我正好擅长对方急需的技能 → 供需因子满分，综合分应达高匹配")
    void shouldScoreFullWhenSkillsMatchExactly() {
        // 我擅长动效；对方急需动效，并愿意回报前端（我也急需）
        List<UserSkillProfile> profiles = List.of(
                profile("me", 2L, SkillIntent.SKILLED),
                profile("me", 1L, SkillIntent.NEEDED)
        );
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(2L, 1L), "me", "计算机学院", profiles, skillMap, graph());

        assertEquals(1.0, factor(score, "技能供需匹配").getScore(), 0.0001, "精确命中应为满分");
        assertEquals(1.0, factor(score, "技能置换平衡").getScore(), 0.0001, "对方回报正是我急需");
        assertTrue(score.isHighMatch(), "双向都命中应判为高匹配，实际分：" + score.score());
    }

    @Test
    @DisplayName("图谱上不可达的技能 → 供需因子为 0（不因稀疏图的远距离链条误判相关）")
    void shouldScoreZeroWhenUnreachable() {
        // 我擅长 UI 设计（3），对方急需数学建模（4）。
        // 用一个"3、4 之间没有通路"的图，验证不可达时确实为 0。
        Map<Long, List<MatchScoreCalculator.Edge>> isolated = MatchScoreCalculator.buildGraph(List.of(
                new MatchScoreCalculator.GraphEdgeRow(1L, 2L, SkillRelationType.COMPLEMENT)
        ));
        List<UserSkillProfile> profiles = List.of(profile("me", 3L, SkillIntent.SKILLED));
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(4L, null), "me", "艺术学院", profiles, skillMap, isolated);

        assertEquals(0.0, factor(score, "技能供需匹配").getScore(), 0.0001,
                "不可达应为 0，实际依据：" + factor(score, "技能供需匹配").getDetail());
        assertFalse(score.isHighMatch(), "不应判为高匹配，实际分：" + score.score());
    }

    @Test
    @DisplayName("超过最大跳数（3 跳及以上）不应算作相关")
    void shouldIgnoreBeyondMaxDepth() {
        // 链条 3—1—2—4，3 到 4 为 3 跳，超过 MAX_GRAPH_DEPTH=2，应判为不相关。
        // 这是对早期"3 跳也算间接互补"缺陷的回归防护。
        Map<Long, List<MatchScoreCalculator.Edge>> chain = MatchScoreCalculator.buildGraph(List.of(
                new MatchScoreCalculator.GraphEdgeRow(3L, 1L, SkillRelationType.COMPLEMENT),
                new MatchScoreCalculator.GraphEdgeRow(1L, 2L, SkillRelationType.COMPLEMENT),
                new MatchScoreCalculator.GraphEdgeRow(2L, 4L, SkillRelationType.COMPLEMENT)
        ));
        Map<Long, Skill> map = Map.of(
                3L, skill(3L, "甲", "艺术学", "学科X"),
                1L, skill(1L, "乙", "工学", "学科Y"),
                2L, skill(2L, "丙", "工学", "学科Z"),
                4L, skill(4L, "丁", "理学", "学科W"));
        List<UserSkillProfile> profiles = List.of(profile("me", 3L, SkillIntent.SKILLED));
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(4L, null), "me", null, profiles, map, chain);

        assertEquals(0.0, factor(score, "技能供需匹配").getScore(), 0.0001,
                "3 跳链条不应算作相关，实际依据：" + factor(score, "技能供需匹配").getDetail());
    }

    @Test
    @DisplayName("两跳间接关联应给弱信号分（0.35），且说明是间接方向")
    void shouldScoreTwoHopAsWeakSignal() {
        // 我擅长 Vue 前端（1）→ 2 动效（同二级学科只影响 1 跳），
        // 这里直接用 1 与 4 的两跳路径验证：1—2—4
        Map<Long, List<MatchScoreCalculator.Edge>> g = MatchScoreCalculator.buildGraph(List.of(
                new MatchScoreCalculator.GraphEdgeRow(1L, 2L, SkillRelationType.COMPLEMENT),
                new MatchScoreCalculator.GraphEdgeRow(2L, 4L, SkillRelationType.COMPLEMENT)
        ));
        List<UserSkillProfile> profiles = List.of(profile("me", 1L, SkillIntent.SKILLED));
        // 目标技能设为 4，但把 1 与 4 的二级学科错开以排除"同二级学科"分支
        Map<Long, Skill> map = Map.of(
                1L, skill(1L, "甲技能", "工学", "学科A"),
                2L, skill(2L, "乙技能", "工学", "学科B"),
                4L, skill(4L, "丙技能", "理学", "学科C"));
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(4L, null), "me", null, profiles, map, g);

        double supply = factor(score, "技能供需匹配").getScore();
        assertEquals(0.35, supply, 0.0001, "两跳应为弱信号 0.35，实际 " + supply);
        assertTrue(factor(score, "技能供需匹配").getDetail().contains("间接"),
                "依据应说明是间接关联：" + factor(score, "技能供需匹配").getDetail());
    }

    @Test
    @DisplayName("图谱互补关系应给中间分（0.50），体现跨学科隐性需求")
    void shouldScoreComplementEdge() {
        // 我擅长 UI 设计（3），对方急需动效（2），二者是互补关系
        List<UserSkillProfile> profiles = List.of(profile("me", 3L, SkillIntent.SKILLED));
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(2L, null), "me", "艺术学院", profiles, skillMap, graph());

        double supply = factor(score, "技能供需匹配").getScore();
        assertEquals(0.50, supply, 0.0001, "互补关系应得 0.5，实际 " + supply);
        assertTrue(factor(score, "技能供需匹配").getDetail().contains("互补"),
                "依据应说明是互补关系：" + factor(score, "技能供需匹配").getDetail());
    }

    @Test
    @DisplayName("同二级学科应给 0.75")
    void shouldScoreSameSubCategory() {
        // 我擅长前端（1），对方急需动效（2），同属计算机科学与技术
        List<UserSkillProfile> profiles = List.of(profile("me", 1L, SkillIntent.SKILLED));
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(2L, null), "me", "计算机学院", profiles, skillMap, graph());

        assertEquals(0.75, factor(score, "技能供需匹配").getScore(), 0.0001);
    }

    @Test
    @DisplayName("同义关系应给 0.85（高于互补）")
    void shouldRankSynonymAboveComplement() {
        // 我擅长数学建模（4），与动效（2）是同义边
        List<UserSkillProfile> profiles = List.of(profile("me", 4L, SkillIntent.SKILLED));
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(2L, null), "me", "数学学院", profiles, skillMap, graph());
        assertEquals(0.85, factor(score, "技能供需匹配").getScore(), 0.0001);
    }

    @Test
    @DisplayName("卡片未声明回馈技能时，置换项权重应归还，不压低总分")
    void shouldRenormalizeWhenNoOfferSkill() {
        List<UserSkillProfile> profiles = List.of(profile("me", 2L, SkillIntent.SKILLED));
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(2L, null), "me", "计算机学院", profiles, skillMap, graph());

        assertEquals(0.0, factor(score, "技能置换平衡").getWeight(), 0.0001,
                "无回馈技能时该项权重应为 0");
        // 精确命中供需项，归一化后综合分仍应较高
        assertTrue(score.score() > 0.7,
                "权重归一化后总分不应被无谓压低，实际：" + score.score());
    }

    @Test
    @DisplayName("未登录用户只能得到客观质量分，并给出明确提示")
    void shouldHintWhenNotLoggedIn() {
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(2L, 1L), null, null, List.of(), skillMap, graph());

        assertNotNull(score.factors());
        assertTrue(score.factors().stream().anyMatch(f -> "提示".equals(f.getName())
                        && f.getDetail().contains("未登录")),
                "应提示未登录用户登录后可获得技能级匹配度");
    }

    @Test
    @DisplayName("无技能画像的登录用户应被引导去补充标签")
    void shouldGuideUserWithoutProfile() {
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(2L, null), "me", "计算机学院", List.of(), skillMap, graph());
        assertTrue(factor(score, "技能供需匹配").getDetail().contains("技能画像"),
                "应提示补充技能画像，实际：" + factor(score, "技能供需匹配").getDetail());
    }

    @Test
    @DisplayName("跨门类置换的学科相关度应高于同门类（平台跨学科定位）")
    void shouldRewardCrossDisciplineExchange() {
        // 动效（工学）⇄ UI 设计（艺术学）跨门类
        MatchScoreCalculator.Score cross = calculator.calculate(
                demand(2L, 3L), "me", null, List.of(), skillMap, graph());
        // 动效（工学）⇄ 数学建模（理学）同样跨门类，用作对照
        MatchScoreCalculator.Score cross2 = calculator.calculate(
                demand(2L, 4L), "me", null, List.of(), skillMap, graph());
        assertEquals(1.0, factor(cross, "学科相关度").getScore(), 0.0001);
        assertEquals(1.0, factor(cross2, "学科相关度").getScore(), 0.0001);

        // 同门类（工学 ⇄ 工学：动效 vs 前端）应为 0.7
        MatchScoreCalculator.Score same = calculator.calculate(
                demand(2L, 1L), "me", null, List.of(), skillMap, graph());
        assertEquals(0.7, factor(same, "学科相关度").getScore(), 0.0001);
    }

    @Test
    @DisplayName("越新的卡片时效性得分越高")
    void shouldRewardFreshness() {
        Demand fresh = demand(2L, null).setCreatedAt(LocalDateTime.now().minusHours(1));
        Demand stale = demand(2L, null).setCreatedAt(LocalDateTime.now().minusDays(20));

        double freshScore = calculator.calculate(fresh, "me", null, List.of(), skillMap, graph())
                .factors().stream().filter(f -> "时效性".equals(f.getName())).findFirst().orElseThrow().getScore();
        double staleScore = calculator.calculate(stale, "me", null, List.of(), skillMap, graph())
                .factors().stream().filter(f -> "时效性".equals(f.getName())).findFirst().orElseThrow().getScore();

        assertTrue(freshScore > staleScore, "新卡片时效分应更高");
        assertEquals(1.0, freshScore, 0.0001);
        assertEquals(0.2, staleScore, 0.0001);
    }

    @Test
    @DisplayName("综合分应始终落在 0~1 区间，且因子贡献之和与总分一致")
    void shouldStayInRangeAndBeConsistent() {
        List<UserSkillProfile> profiles = List.of(
                profile("me", 1L, SkillIntent.SKILLED),
                profile("me", 2L, SkillIntent.SKILLED),
                profile("me", 3L, SkillIntent.NEEDED)
        );
        MatchScoreCalculator.Score score = calculator.calculate(
                demand(2L, 3L), "me", "计算机学院", profiles, skillMap, graph());

        assertTrue(score.score() >= 0 && score.score() <= 1, "综合分越界：" + score.score());
        double weightSum = score.factors().stream().mapToDouble(MarketCardVO.MatchFactor::getWeight).sum();
        double contribution = score.factors().stream().mapToDouble(MarketCardVO.MatchFactor::getContribution).sum();
        assertEquals(score.score(), contribution / weightSum, 0.001, "总分应与加权贡献一致");
    }

    @Test
    @DisplayName("高匹配阈值用于置顶判定，边界值应稳定")
    void shouldUseStableHighMatchThreshold() {
        assertEquals(0.75, MatchScoreCalculator.HIGH_MATCH_THRESHOLD, 0.0001);
        assertTrue(new MatchScoreCalculator.Score(0.75, List.of()).isHighMatch());
        assertFalse(new MatchScoreCalculator.Score(0.7499, List.of()).isHighMatch());
    }
}
