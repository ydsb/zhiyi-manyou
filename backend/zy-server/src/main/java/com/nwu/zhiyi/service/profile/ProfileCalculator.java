package com.nwu.zhiyi.service.profile;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.common.enums.AbilityDimension;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 能力画像聚合计算器（FR-M7-01 ~ FR-M7-03）。
 *
 * <p><b>算法</b>：
 * <ol>
 *   <li>取该用户所有<b>已完成</b>交换，以及别人给他的互评记录；</li>
 *   <li>按<b>他提供出去的技能</b>的学科门类归入能力维度
 *       （"我教别人什么"才体现我的能力，"我学了什么"不体现）；</li>
 *   <li><b>先按技能聚合，再按维度聚合</b>（见下方说明）；</li>
 *   <li>「沟通协作」直接取互评的 {@code communication} 维度分。</li>
 * </ol>
 *
 * <p><b>为什么"先按技能聚合"而不是逐次交换平均</b>：
 * 同一技能可能被交换多次（例如 ECharts 换过 3 次）。若逐次平均，
 * 同一技能出现 3 次就与"另一个只换过 1 次的技能"等权，
 * 导致维度分被重复计数扭曲。先算"每个技能的加权平均分与总时长"，
 * 再按技能时长加权到维度，才能真实反映投入分布。
 *
 * <p><b>三个刻意的设计选择</b>：
 * <ul>
 *   <li><b>按"我提供的技能"归类</b>：一次交换里我提供 Vue、学到数学建模，
 *       能证明的是我的工程能力，不是数学能力。</li>
 *   <li><b>按时长加权</b>：投入 20 小时与 1 小时的权重不应相同，
 *       否则刷次数就能拉高画像。</li>
 *   <li><b>无互评的交换照常计入时长，但不出质量分</b>：互评是双向的，
 *       "我提供技能"与"我收到评价"并不总是同时成立。早期实现把这类交换
 *       直接丢弃，导致已完成的真实协作在画像上毫无体现 —— 这是错误的，
 *       协作事实已经发生。</li>
 * </ul>
 *
 * <p>纯粹的领域计算，只依赖 Mapper，便于单元测试。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ProfileCalculator {

    private final ExchangeRecordMapper exchangeMapper;
    private final EvaluationGradeMapper evaluationMapper;
    private final SkillMapper skillMapper;

    /**
     * 一次交换归入某维度后的原始记录。
     *
     * @param record    交换记录
     * @param skillName 我提供出去的技能名
     * @param category  该技能的学科门类
     * @param dimension 归入的能力维度
     * @param score     别人给我的互评总分；<b>null 表示本次尚未收到互评</b>
     * @param commScore 别人给我的「沟通效率」维度分；可为 null
     * @param hours     协作时长（小时）
     */
    public record Sample(ExchangeRecord record, String skillName, String category,
                         AbilityDimension dimension, BigDecimal score,
                         BigDecimal commScore, BigDecimal hours) {

        /** 是否有质量分（收到互评） */
        public boolean hasScore() {
            return score != null;
        }
    }

    /**
     * 单个技能在其维度上的聚合结果。
     *
     * @param skillName  技能名
     * @param category   学科门类
     * @param times      交换次数
     * @param hours      累计时长
     * @param avgScore   按次加权的平均总分；无互评时为 null
     * @param avgComm    按次加权的平均沟通效率分；无互评时为 null
     * @param scoredTimes 收到互评的次数
     */
    public record SkillAggregate(String skillName, String category, int times,
                                 BigDecimal hours, BigDecimal avgScore,
                                 BigDecimal avgComm, int scoredTimes) {
    }

    /**
     * 计算结果。
     *
     * @param samples       原始样本（逐次交换）
     * @param skillAggs     按技能聚合结果
     * @param dimScores     维度 → 得分（无样本的维度为 null）
     * @param dimEvidence   维度 → 出处说明
     * @param dimSkills     维度 → 贡献技能名（按时长降序）
     * @param dimCounts     维度 → 参与计算的交换次数
     * @param totalHours    累计协作时长
     * @param avgScore      样本平均总分（仅统计收到互评的）
     * @param overall       有数据维度的均值
     * @param exchangeCount 参与计算的已完成交换数
     */
    public record Result(List<Sample> samples,
                         Map<String, List<SkillAggregate>> skillAggs,
                         Map<String, BigDecimal> dimScores,
                         Map<String, String> dimEvidence,
                         Map<String, List<String>> dimSkills,
                         Map<String, Integer> dimCounts,
                         BigDecimal totalHours,
                         BigDecimal avgScore,
                         BigDecimal overall,
                         int exchangeCount) {
    }

    /**
     * 计算某用户的能力画像。
     *
     * @param sno 学号
     * @return 计算结果
     */
    public Result compute(String sno) {
        List<Sample> samples = collectSamples(sno);

        // 按维度 → 技能两级聚合
        Map<String, List<Sample>> byDimension = new LinkedHashMap<>();
        for (AbilityDimension d : AbilityDimension.values()) {
            byDimension.put(d.getKey(), new ArrayList<>());
        }
        for (Sample s : samples) {
            byDimension.get(s.dimension().getKey()).add(s);
        }

        Map<String, BigDecimal> scores = new LinkedHashMap<>();
        Map<String, String> evidence = new LinkedHashMap<>();
        Map<String, List<String>> skills = new LinkedHashMap<>();
        Map<String, Integer> counts = new LinkedHashMap<>();
        Map<String, List<SkillAggregate>> allAggs = new LinkedHashMap<>();

        for (AbilityDimension d : AbilityDimension.values()) {
            /*
             * 「沟通协作」特殊处理：它不由学科门类推导，而是取自互评的
             * communication 维度分。而 communication 分只有在"我收到了互评"的
             * 交换上才有，与"该交换归入哪个学科维度"无关。
             *
             * 因此它的样本来源是 samples 里所有"有沟通效率分"的记录，
             * 不能只看归入本维度的那部分 —— 否则任何学科门类的交换都会
             * 让沟通协作显示"样本 0 次、无数据"（早期实现的缺陷）。
             */
            if (d == AbilityDimension.COMMUNICATION) {
                List<Sample> commSamples = samples.stream()
                        .filter(s -> s.commScore() != null).toList();
                counts.put(d.getKey(), commSamples.size());
                skills.put(d.getKey(), commSamples.stream()
                        .map(Sample::skillName).distinct().toList());
                if (commSamples.isEmpty()) {
                    scores.put(d.getKey(), null);
                    evidence.put(d.getKey(),
                            "暂无数据：还没有收到包含「沟通效率」评分的互评记录");
                    continue;
                }
                BigDecimal commValue = mean(commSamples, Sample::commScore);
                scores.put(d.getKey(), commValue);
                evidence.put(d.getKey(), String.format(
                        "「沟通协作」%.2f 分，取自 %d 次交换中互评的「沟通效率」维度分（直接平均，"
                                + "不按学科归类）",
                        commValue, commSamples.size()));
                continue;
            }

            List<Sample> list = byDimension.get(d.getKey());
            List<SkillAggregate> aggs = aggregateBySkill(list);
            allAggs.put(d.getKey(), aggs);

            counts.put(d.getKey(), list.size());
            // 技能按累计时长降序（投入最多的排前面）
            skills.put(d.getKey(), aggs.stream()
                    .sorted((a, b) -> b.hours().compareTo(a.hours()))
                    .map(SkillAggregate::skillName).toList());

            // 无任何"有质量分"的技能 → 该维度无数据，返回 null（不是 0）
            boolean hasQuality = aggs.stream().anyMatch(a -> a.avgScore() != null);
            if (!hasQuality) {
                scores.put(d.getKey(), null);
                evidence.put(d.getKey(), buildNoDataEvidence(d, aggs));
                continue;
            }

            BigDecimal value = weightedBySkill(aggs, SkillAggregate::avgScore);
            scores.put(d.getKey(), value);
            evidence.put(d.getKey(), buildEvidence(d, aggs, value));
        }

        BigDecimal totalHours = samples.stream()
                .map(Sample::hours)
                .filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(1, RoundingMode.HALF_UP);

        List<Sample> scored = samples.stream().filter(Sample::hasScore).toList();
        BigDecimal avgScore = scored.isEmpty() ? null
                : scored.stream().map(Sample::score)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(scored.size()), 2, RoundingMode.HALF_UP);

        List<BigDecimal> valid = scores.values().stream()
                .filter(java.util.Objects::nonNull).toList();
        BigDecimal overall = valid.isEmpty() ? null
                : valid.stream().reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(valid.size()), 2, RoundingMode.HALF_UP);

        return new Result(samples, allAggs, scores, evidence, skills, counts,
                totalHours, avgScore, overall, samples.size());
    }

    /**
     * 把同一维度下的逐次样本，按技能聚合成"每技能一行"。
     *
     * <p>这是避免"同一技能换多次被重复计数"的关键步骤。
     *
     * @param list 该维度下的全部样本
     * @return 技能聚合列表（无样本返回空列表）
     */
    private List<SkillAggregate> aggregateBySkill(List<Sample> list) {
        if (list.isEmpty()) {
            return List.of();
        }
        Map<String, List<Sample>> bySkill = new LinkedHashMap<>();
        for (Sample s : list) {
            bySkill.computeIfAbsent(s.skillName(), k -> new ArrayList<>()).add(s);
        }
        List<SkillAggregate> aggs = new ArrayList<>();
        for (Map.Entry<String, List<Sample>> e : bySkill.entrySet()) {
            List<Sample> group = e.getValue();
            BigDecimal hours = group.stream().map(Sample::hours)
                    .reduce(BigDecimal.ZERO, BigDecimal::add)
                    .setScale(1, RoundingMode.HALF_UP);
            List<Sample> withScore = group.stream().filter(Sample::hasScore).toList();
            aggs.add(new SkillAggregate(
                    e.getKey(),
                    group.get(0).category(),
                    group.size(),
                    hours,
                    mean(withScore, Sample::score),
                    mean(withScore, Sample::commScore),
                    withScore.size()));
        }
        return aggs;
    }

    /** 算术平均（组内各次等权，因为时长已经在这一层体现） */
    private BigDecimal mean(List<Sample> list, java.util.function.Function<Sample, BigDecimal> picker) {
        List<BigDecimal> values = list.stream().map(picker)
                .filter(java.util.Objects::nonNull).toList();
        if (values.isEmpty()) {
            return null;
        }
        return values.stream().reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(values.size()), 2, RoundingMode.HALF_UP);
    }

    /**
     * 技能 → 维度：按各技能的累计时长加权。
     *
     * <p>若所有技能时长都为 0（用户未填写工时），退化为技能间算术平均，
     * 否则会除以 0。时长缺失时按个数均分是更合理的降级口径。
     */
    private BigDecimal weightedBySkill(List<SkillAggregate> aggs,
                                       java.util.function.Function<SkillAggregate, BigDecimal> picker) {
        List<SkillAggregate> valid = aggs.stream()
                .filter(a -> picker.apply(a) != null).toList();
        if (valid.isEmpty()) {
            return null;
        }
        BigDecimal weightSum = BigDecimal.ZERO;
        BigDecimal acc = BigDecimal.ZERO;
        for (SkillAggregate a : valid) {
            BigDecimal w = a.hours() == null ? BigDecimal.ZERO : a.hours();
            if (w.compareTo(BigDecimal.ZERO) > 0) {
                acc = acc.add(picker.apply(a).multiply(w));
                weightSum = weightSum.add(w);
            }
        }
        if (weightSum.compareTo(BigDecimal.ZERO) > 0) {
            return acc.divide(weightSum, 2, RoundingMode.HALF_UP);
        }
        // 时长全缺失：退化为技能间算术平均
        return valid.stream().map(picker)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(valid.size()), 2, RoundingMode.HALF_UP);
    }

    /**
     * 收集样本：已完成交换中"我提供技能"归属的能力维度 + 别人给我的互评分。
     *
     * @param sno 学号
     * @return 样本列表
     */
    private List<Sample> collectSamples(String sno) {
        List<ExchangeRecord> records = exchangeMapper.selectList(new LambdaQueryWrapper<ExchangeRecord>()
                .eq(ExchangeRecord::getStatus, ExchangeStatus.COMPLETED)
                .and(w -> w.eq(ExchangeRecord::getGiverSno, sno).or().eq(ExchangeRecord::getTakerSno, sno)));
        if (records.isEmpty()) {
            return List.of();
        }

        Set<Long> recordIds = new LinkedHashSet<>();
        records.forEach(r -> recordIds.add(r.getId()));
        Map<Long, EvaluationGrade> received = new LinkedHashMap<>();
        evaluationMapper.selectList(new LambdaQueryWrapper<EvaluationGrade>()
                        .eq(EvaluationGrade::getToSno, sno)
                        .in(EvaluationGrade::getRecordId, recordIds))
                .forEach(g -> received.put(g.getRecordId(), g));

        Set<Long> skillIds = new LinkedHashSet<>();
        for (ExchangeRecord r : records) {
            Long provided = providedSkillId(r, sno);
            if (provided != null) {
                skillIds.add(provided);
            }
        }
        Map<Long, Skill> skills = new LinkedHashMap<>();
        if (!skillIds.isEmpty()) {
            skillMapper.selectBatchIds(skillIds).forEach(s -> skills.put(s.getId(), s));
        }

        List<Sample> samples = new ArrayList<>();
        for (ExchangeRecord r : records) {
            Long providedId = providedSkillId(r, sno);
            Skill skill = providedId == null ? null : skills.get(providedId);
            if (skill == null) {
                continue;
            }
            AbilityDimension dim = AbilityDimension.ofCategory(skill.getCategoryL1());
            if (dim == null) {
                log.debug("[能力画像] 技能「{}」的门类「{}」未映射到能力维度，已跳过",
                        skill.getName(), skill.getCategoryL1());
                continue;
            }
            /*
             * 互评是双向的：本条交换里"我提供技能"与"我收到评价"并不总是同时成立
             * （例如我提供 UI/UX 设计，该由对方评价我，但对方未评）。
             *
             * 口径：
             *   - 有时长 → 计入 totalHours（协作事实成立）；
             *   - 有互评分 → 计入质量分；
             *   - 无互评分 → score 为 null，不拉低也不虚高维度分，
             *     并在 evidence 里如实说明"该次尚未收到互评"。
             */
            EvaluationGrade grade = received.get(r.getId());
            BigDecimal score = grade == null ? null : grade.getTotalScore();
            BigDecimal commScore = grade == null ? null : extractCommunication(grade);
            samples.add(new Sample(r, skill.getName(), skill.getCategoryL1(), dim,
                    score, commScore, resolveHours(r)));
        }
        return samples;
    }

    /** 我在这条交换里"提供出去"的技能 ID */
    private Long providedSkillId(ExchangeRecord r, String sno) {
        return sno.equals(r.getGiverSno()) ? r.getGiveSkillId() : r.getLearnSkillId();
    }

    /** 从互评记录中取「沟通效率」维度分 */
    private BigDecimal extractCommunication(EvaluationGrade grade) {
        if (grade.getDimScores() == null) {
            return null;
        }
        try {
            cn.hutool.json.JSONObject obj = cn.hutool.json.JSONUtil.parseObj(grade.getDimScores());
            Object v = obj.get("communication");
            return v == null ? null : new BigDecimal(String.valueOf(v));
        } catch (Exception e) {
            return null;
        }
    }

    /** 时长：优先实际投入，缺失则用预计时长，都没有给 0 */
    private BigDecimal resolveHours(ExchangeRecord r) {
        if (r.getActualHours() != null && r.getActualHours().compareTo(BigDecimal.ZERO) > 0) {
            return r.getActualHours();
        }
        if (r.getExpectedHours() != null && r.getExpectedHours() > 0) {
            return BigDecimal.valueOf(r.getExpectedHours());
        }
        return BigDecimal.ZERO;
    }

    /**
     * 生成可读的分数出处说明（可解释性的落地）。
     *
     * <p>用户能看到分数由哪些技能、换过几次、共多少小时、多少分构成，
     * 以及哪些交换还没收到互评。
     */
    private String buildEvidence(AbilityDimension d, List<SkillAggregate> aggs, BigDecimal score) {
        StringBuilder sb = new StringBuilder();
        sb.append(String.format("「%s」%.2f 分，由以下技能按累计时长加权得出：", d.getLabel(), score));
        List<SkillAggregate> sorted = aggs.stream()
                .sorted((a, b) -> b.hours().compareTo(a.hours())).toList();
        int shown = 0;
        for (SkillAggregate a : sorted) {
            if (a.avgScore() == null && a.times() == 0) {
                continue;
            }
            if (shown++ > 0) {
                sb.append("；");
            }
            sb.append(String.format("「%s」（%s）", a.skillName(), a.category()));
            if (a.avgScore() == null) {
                sb.append(String.format("换过 %d 次、共 %s 小时，但尚未收到互评，暂不计分",
                        a.times(), strip(a.hours())));
            } else {
                sb.append(String.format("换过 %d 次、共 %s 小时，平均 %s 分",
                        a.times(), strip(a.hours()), a.avgScore().toPlainString()));
                if (a.scoredTimes() < a.times()) {
                    sb.append(String.format("（其中 %d 次已收到互评）", a.scoredTimes()));
                }
            }
            if (shown >= 4 && sorted.size() > 4) {
                sb.append("；等 ").append(sorted.size()).append(" 项技能");
                break;
            }
        }
        return sb.toString();
    }

    /** 无质量分时的出处说明：如实说明"有协作但尚未收到互评" */
    private String buildNoDataEvidence(AbilityDimension d, List<SkillAggregate> aggs) {
        if (aggs.isEmpty()) {
            return "暂无数据：还没有归入「" + d.getLabel() + "」的已完成交换";
        }
        long times = aggs.stream().mapToInt(SkillAggregate::times).sum();
        BigDecimal hours = aggs.stream().map(SkillAggregate::hours)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return String.format("「%s」已换过 %d 次、共 %s 小时，但对方尚未提交互评，"
                        + "因此暂时没有质量分。协作时长已计入统计。",
                d.getLabel(), times, strip(hours));
    }

    private static String strip(BigDecimal v) {
        return v == null ? "0" : v.stripTrailingZeros().toPlainString();
    }
}
