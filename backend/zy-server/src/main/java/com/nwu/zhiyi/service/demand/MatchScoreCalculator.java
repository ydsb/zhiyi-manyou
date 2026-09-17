package com.nwu.zhiyi.service.demand;

import com.nwu.zhiyi.api.dto.demand.MarketCardVO;
import com.nwu.zhiyi.common.enums.SkillIntent;
import com.nwu.zhiyi.common.enums.SkillRelationType;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.UserSkillProfile;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * 供需集市匹配度计算器（FR-M4-03 / FR-M3-03）。
 *
 * <p><b>为什么需要"两个视角"</b>：集市里的匹配不是单向的。一张卡片对某个人是否
 * 有价值，取决于两件事同时成立：
 * <ol>
 *   <li><b>我能帮上他</b> —— 我擅长的技能命中他急需的技能（供需维度）</li>
 *   <li><b>他能回报我</b> —— 他愿意提供的技能命中我急需的技能（置换维度）</li>
 * </ol>
 * 这正是「以技易技」的核心：单边有利的卡片不该被顶到最前面。
 *
 * <p><b>加权方案</b>（总分 0~1，各因子拆解一并返回以支撑"可解释推荐"）：
 * <table border="1">
 *   <tr><th>因子</th><th>权重</th><th>说明</th></tr>
 *   <tr><td>技能供需匹配</td><td>0.40</td><td>我擅长的技能 vs 他急需的技能（图距离衰减）</td></tr>
 *   <tr><td>技能置换平衡</td><td>0.25</td><td>他提供的技能 vs 我急需的技能；缺失时权重归还给上一项</td></tr>
 *   <tr><td>学科相关度</td><td>0.15</td><td>同一门类 / 同一二级学科加分</td></tr>
 *   <tr><td>时效性</td><td>0.10</td><td>越新越靠前</td></tr>
 *   <tr><td>活跃度</td><td>0.10</td><td>邀约数与浏览数（弱信号，防止零互动卡片沉底）</td></tr>
 * </table>
 *
 * <p>算法与 {@code SkillTextParser} 一样是<b>完全离线可用</b>的规则实现，
 * 满足 NFR-R-03 的 AI 降级要求；S3 阶段接入向量检索后，本计算器作为
 * 混合召回中的"图谱+规则"一路保留，并作为排序的兜底策略。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
public class MatchScoreCalculator {

    /** 高匹配阈值：达到该值的卡片在前端高亮置顶（FR-M4-03） */
    public static final double HIGH_MATCH_THRESHOLD = 0.75;

    /**
     * 图谱游走的最大跳数。
     *
     * <p>取 2 而不是 3：在稀疏图里 3 跳链条（A—B—C—D）几乎能把任意两个技能连起来，
     * 会把明显不相关的需求也算成"间接互补"。另外 {@code DemandCardAssembler}
     * 只加载了卡片相关技能的一跳邻域，2 跳是它真正能覆盖的范围，
     * 声明 3 跳会给出无法兑现的精度承诺。
     */
    private static final int MAX_GRAPH_DEPTH = 2;

    /** 各因子权重 */
    private static final double W_SUPPLY = 0.40;
    private static final double W_EXCHANGE = 0.25;
    private static final double W_CATEGORY = 0.15;
    private static final double W_FRESHNESS = 0.10;
    private static final double W_ACTIVITY = 0.10;

    /**
     * 计算结果。
     *
     * @param score   综合匹配度 0~1
     * @param factors 因子拆解
     */
    public record Score(double score, List<MarketCardVO.MatchFactor> factors) {

        /** 是否达到高匹配阈值 */
        public boolean isHighMatch() {
            return score >= HIGH_MATCH_THRESHOLD;
        }
    }

    /**
     * 计算一张需求卡片对当前用户的匹配度。
     *
     * @param demand       需求卡片
     * @param viewerSno    当前登录用户学号，为空表示未登录（只能算客观因子）
     * @param viewerCollege 当前用户院系
     * @param profiles     当前用户的技能画像
     * @param skillMap     技能字典（id → Skill），用于取门类信息
     * @param graph        图谱邻接表（skillId → 邻居及关系），用于算图距离
     * @return 匹配结果
     */
    public Score calculate(Demand demand,
                           String viewerSno,
                           String viewerCollege,
                           List<UserSkillProfile> profiles,
                           Map<Long, Skill> skillMap,
                           Map<Long, List<Edge>> graph) {

        List<MarketCardVO.MatchFactor> factors = new ArrayList<>();

        // ---------- 因子一：技能供需匹配（我能不能帮上他） ----------
        Set<Long> mySkilled = skillIdsOf(profiles, SkillIntent.SKILLED, SkillIntent.RESEARCHING);
        SupplyResult supply = evaluateSupply(demand.getExpectedSkillId(), mySkilled, skillMap, graph);
        factors.add(new MarketCardVO.MatchFactor("技能供需匹配", supply.score(), W_SUPPLY, supply.detail()));

        // ---------- 因子二：技能置换平衡（他能不能回报我） ----------
        Set<Long> myNeeded = skillIdsOf(profiles, SkillIntent.NEEDED);
        SupplyResult exchange;
        double wExchange = W_EXCHANGE;
        if (demand.getOfferSkillId() == null) {
            exchange = new SupplyResult(0.0, "发布人未声明可提供的技能，按单向求助处理");
            wExchange = 0.0; // 权重归还给供需匹配项
        } else {
            exchange = evaluateSupply(demand.getOfferSkillId(), myNeeded, skillMap, graph);
        }
        factors.add(new MarketCardVO.MatchFactor("技能置换平衡", wExchange == 0 ? 0.0 : exchange.score(),
                wExchange, exchange.detail()));

        // ---------- 因子三：学科相关度 ----------
        CategoryResult category = evaluateCategory(demand, viewerCollege, skillMap);
        factors.add(new MarketCardVO.MatchFactor("学科相关度", category.score(), W_CATEGORY, category.detail()));

        // ---------- 因子四：时效性 ----------
        double freshness = evaluateFreshness(demand);
        factors.add(new MarketCardVO.MatchFactor("时效性", freshness, W_FRESHNESS,
                describeFreshness(demand)));

        // ---------- 因子五：活跃度 ----------
        double activity = evaluateActivity(demand);
        factors.add(new MarketCardVO.MatchFactor("活跃度", activity, W_ACTIVITY,
                String.format("%d 次邀约 / %d 次浏览",
                        nvl(demand.getMatchCount()), nvl(demand.getViewCount()))));

        // ---------- 汇总（权重归一化，避免 offerSkill 缺失时总分被压低） ----------
        double weightSum = factors.stream().mapToDouble(MarketCardVO.MatchFactor::getWeight).sum();
        double raw = factors.stream().mapToDouble(MarketCardVO.MatchFactor::getContribution).sum();
        double score = weightSum <= 0 ? 0 : raw / weightSum;

        // 未登录用户没有技能画像，供需/置换两项必然为 0，此时分数只反映客观质量，
        // 明确标注以避免前端把"未登录"误读成"不匹配"。
        if (viewerSno == null) {
            factors.add(new MarketCardVO.MatchFactor("提示", 0.0, 0.0,
                    "未登录：仅按卡片客观质量排序，登录后可获得技能级匹配度"));
        }

        double finalScore = clamp(round(score));
        return new Score(finalScore, factors);
    }

    /* ==================== 供需匹配（图距离衰减） ==================== */

    private record SupplyResult(double score, String detail) {
    }

    /**
     * 计算"我的技能集合"与"目标技能"的匹配程度。
     *
     * <p>精确命中 1.0；同二级学科 0.75；图谱距离 1 跳按关系类型给分
     * （同义 0.85 / 先决 0.70 / 互补 0.50）；更远按跳数衰减。
     */
    private SupplyResult evaluateSupply(Long targetSkillId, Set<Long> mySkillIds,
                                        Map<Long, Skill> skillMap, Map<Long, List<Edge>> graph) {
        if (targetSkillId == null) {
            return new SupplyResult(0.0, "卡片未指定该方向技能");
        }
        if (mySkillIds == null || mySkillIds.isEmpty()) {
            return new SupplyResult(0.0, "你尚未建立技能画像，前往「新手导引」补充标签可提升匹配度");
        }
        if (mySkillIds.contains(targetSkillId)) {
            String name = nameOf(skillMap, targetSkillId);
            return new SupplyResult(1.0, "你已登记「" + name + "」，精确命中");
        }

        Skill target = skillMap.get(targetSkillId);

        // 同二级学科
        for (Long mine : mySkillIds) {
            Skill my = skillMap.get(mine);
            if (my != null && target != null && Objects.equals(my.getCategoryL2(), target.getCategoryL2())) {
                return new SupplyResult(0.75, "你登记的「" + my.getName() + "」与「" + target.getName()
                        + "」同属二级学科「" + target.getCategoryL2() + "」");
            }
        }

        // 图谱距离
        int best = Integer.MAX_VALUE;
        Long bestVia = null;
        SkillRelationType bestType = null;
        for (Long mine : mySkillIds) {
            List<Edge> neighbors = graph.get(mine);
            if (neighbors == null) {
                continue;
            }
            for (Edge edge : neighbors) {
                if (Objects.equals(edge.to(), targetSkillId)) {
                    int rank = edge.relationType() == SkillRelationType.SYNONYM ? 0
                            : edge.relationType() == SkillRelationType.PREREQUISITE ? 1 : 2;
                    if (rank < (best == Integer.MAX_VALUE ? 3 : best)) {
                        best = rank;
                        bestVia = mine;
                        bestType = edge.relationType();
                    }
                }
            }
        }
        if (bestType != null) {
            double s = switch (bestType) {
                case SYNONYM -> 0.85;
                case PREREQUISITE -> 0.70;
                case COMPLEMENT -> 0.50;
            };
            return new SupplyResult(s, "你登记的「" + nameOf(skillMap, bestVia) + "」与「"
                    + nameOf(skillMap, targetSkillId) + "」存在「" + bestType.getLabel() + "」关系（图谱 1 跳）");
        }

        // 2 跳：间接关联，弱信号
        int depth = bfsDepth(mySkillIds, targetSkillId, graph, MAX_GRAPH_DEPTH);
        if (depth > 0) {
            double s = 0.35;
            return new SupplyResult(s, "通过知识图谱 " + depth + " 跳关联到「"
                    + nameOf(skillMap, targetSkillId) + "」，属于间接互补方向（弱信号）");
        }
        return new SupplyResult(0.0, "你的技能画像与「" + nameOf(skillMap, targetSkillId) + "」暂无关联");
    }

    /** 多源 BFS：从我的技能集合出发，求到目标的最近跳数 */
    private int bfsDepth(Set<Long> sources, Long target, Map<Long, List<Edge>> graph, int maxDepth) {
        Set<Long> visited = new HashSet<>(sources);
        Deque<long[]> queue = new ArrayDeque<>();
        for (Long s : sources) {
            queue.add(new long[]{s, 1});
        }
        while (!queue.isEmpty()) {
            long[] cur = queue.poll();
            int depth = (int) cur[1];
            if (depth > maxDepth) {
                continue;
            }
            for (Edge edge : graph.getOrDefault(cur[0], List.of())) {
                if (Objects.equals(edge.to(), target)) {
                    return depth;
                }
                if (visited.add(edge.to())) {
                    queue.add(new long[]{edge.to(), depth + 1});
                }
            }
        }
        return -1;
    }

    /* ==================== 其它因子 ==================== */

    private record CategoryResult(double score, String detail) {
    }

    private CategoryResult evaluateCategory(Demand demand, String viewerCollege, Map<Long, Skill> skillMap) {
        Skill expected = skillMap.get(demand.getExpectedSkillId());
        if (expected == null) {
            return new CategoryResult(0.3, "技能信息缺失");
        }
        // 发布人所在院系与技能门类的关联只能通过技能本身判断，
        // 此处以"卡片是否跨门类"作为相关度信号：跨门类的卡片更符合平台"打破学科壁垒"的定位，
        // 但同门类的协作成本更低，故同门类给高分、跨门类给中性分。
        Skill offer = demand.getOfferSkillId() == null ? null : skillMap.get(demand.getOfferSkillId());
        if (offer == null) {
            return new CategoryResult(0.5, "「" + expected.getCategoryL1() + "」门类，单科求助");
        }
        boolean sameL1 = Objects.equals(expected.getCategoryL1(), offer.getCategoryL1());
        if (sameL1) {
            return new CategoryResult(0.7, "需求与回馈同属「" + expected.getCategoryL1() + "」，沟通成本较低");
        }
        return new CategoryResult(1.0, "跨门类置换：「" + offer.getCategoryL1() + "」⇄「"
                + expected.getCategoryL1() + "」，正是平台的跨学科价值场景");
    }

    private double evaluateFreshness(Demand demand) {
        if (demand.getCreatedAt() == null) {
            return 0.5;
        }
        long hours = Duration.between(demand.getCreatedAt(), LocalDateTime.now()).toHours();
        if (hours <= 6) {
            return 1.0;
        }
        if (hours <= 24) {
            return 0.9;
        }
        if (hours <= 24 * 3) {
            return 0.75;
        }
        if (hours <= 24 * 7) {
            return 0.6;
        }
        if (hours <= 24 * 14) {
            return 0.4;
        }
        return 0.2;
    }

    private String describeFreshness(Demand demand) {
        if (demand.getCreatedAt() == null) {
            return "发布时间未知";
        }
        long minutes = Duration.between(demand.getCreatedAt(), LocalDateTime.now()).toMinutes();
        if (minutes < 60) {
            return minutes + " 分钟前发布";
        }
        long hours = minutes / 60;
        if (hours < 24) {
            return hours + " 小时前发布";
        }
        return (hours / 24) + " 天前发布";
    }

    private double evaluateActivity(Demand demand) {
        int match = nvl(demand.getMatchCount());
        int view = nvl(demand.getViewCount());
        // 邀约是强信号，浏览是弱信号；上限 1.0
        double s = Math.min(1.0, match * 0.25 + view * 0.02);
        return Math.max(0.1, s);
    }

    /* ==================== 工具 ==================== */

    /**
     * 图谱邻接边。
     *
     * @param to           邻居技能 ID
     * @param relationType 关系类型
     */
    public record Edge(Long to, SkillRelationType relationType) {
    }

    private Set<Long> skillIdsOf(List<UserSkillProfile> profiles, SkillIntent... intents) {
        if (profiles == null || profiles.isEmpty()) {
            return Set.of();
        }
        Set<SkillIntent> wanted = Set.of(intents);
        Set<Long> ids = new HashSet<>();
        for (UserSkillProfile p : profiles) {
            if (p.getSkillId() != null && p.getIntent() != null && wanted.contains(p.getIntent())) {
                ids.add(p.getSkillId());
            }
        }
        return ids;
    }

    private static String nameOf(Map<Long, Skill> skillMap, Long id) {
        if (id == null) {
            return "未知技能";
        }
        Skill s = skillMap.get(id);
        return s == null ? ("#" + id) : s.getName();
    }

    private static int nvl(Integer v) {
        return v == null ? 0 : v;
    }

    private static double clamp(double v) {
        return Math.max(0.0, Math.min(1.0, v));
    }

    private static double round(double v) {
        return BigDecimal.valueOf(v).setScale(4, RoundingMode.HALF_UP).doubleValue();
    }

    /**
     * 由技能列表构建图谱邻接表（无向，双向登记）。
     *
     * @param edges 图谱关系（含两端 ID 与关系类型）
     * @return 邻接表
     */
    public static Map<Long, List<Edge>> buildGraph(List<GraphEdgeRow> edges) {
        Map<Long, List<Edge>> graph = new HashMap<>();
        for (GraphEdgeRow row : edges) {
            graph.computeIfAbsent(row.srcId(), k -> new ArrayList<>())
                    .add(new Edge(row.dstId(), row.relationType()));
            graph.computeIfAbsent(row.dstId(), k -> new ArrayList<>())
                    .add(new Edge(row.srcId(), row.relationType()));
        }
        return graph;
    }

    /**
     * 构建邻接表的输入行。
     *
     * @param srcId        源技能 ID
     * @param dstId        目标技能 ID
     * @param relationType 关系类型
     */
    public record GraphEdgeRow(Long srcId, Long dstId, SkillRelationType relationType) {
    }

    /** 供调试：把因子列表汇总成一句话说明 */
    public static String explain(List<MarketCardVO.MatchFactor> factors) {
        Map<String, String> map = new LinkedHashMap<>();
        factors.forEach(f -> map.put(f.getName(), String.format("%.0f%%（权重 %.0f%%）",
                f.getScore() * 100, f.getWeight() * 100)));
        return map.toString();
    }
}
