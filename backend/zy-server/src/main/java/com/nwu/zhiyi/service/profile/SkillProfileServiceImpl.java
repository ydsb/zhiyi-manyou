package com.nwu.zhiyi.service.profile;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.profile.SkillProfileSaveRequest;
import com.nwu.zhiyi.api.dto.profile.SkillProfileVO;
import com.nwu.zhiyi.api.dto.skill.SkillVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.SkillIntent;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.UserSkillProfile;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.UserSkillProfileMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 用户技能画像服务实现（FR-M1-03 / FR-M2-02）。
 *
 * <p>核心是 {@link #save} 的<b>三方合并策略</b>，这里把设计取舍写清楚，
 * 因为它直接决定用户能不能改掉选错的标签、以及好不容易攒的互评分数会不会丢：
 *
 * <table border="1">
 *   <caption>覆盖式写入时对已有记录的处理</caption>
 *   <tr><th>已有记录</th><th>是否在本次提交中</th><th>处理</th><th>理由</th></tr>
 *   <tr><td>SELF 自评</td><td>是</td><td>更新 intent / level</td><td>用户改了意图要生效</td></tr>
 *   <tr><td>SELF 自评</td><td>否</td><td><b>删除</b></td><td>取消勾选必须真的移除</td></tr>
 *   <tr><td>PEER 互评</td><td>是</td><td>只更新 intent，<b>保留 score 与 source</b></td>
 *       <td>分数是协作成果，不能因用户改一次自评就被清空</td></tr>
 *   <tr><td>PEER 互评</td><td>否</td><td><b>保留</b></td>
 *       <td>同上 —— 用户没勾选它，不代表要把别人给的评价删掉</td></tr>
 * </table>
 *
 * <p>若不做这个区分、直接"全删再全插"，一次导引就会把所有互评累积分抹平，
 * 而用户完全无从察觉 —— 这类静默数据损失比报错危险得多。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SkillProfileServiceImpl implements SkillProfileService {

    /** 单次提交的标签数上限，与请求 DTO 的校验保持一致（防绕过） */
    private static final int MAX_ITEMS = 60;

    /** 未显式指定等级时的默认值：擅长默认 4，在研/急需默认 2 */
    private static final int DEFAULT_LEVEL_SKILLED = 4;
    private static final int DEFAULT_LEVEL_OTHER = 2;

    private final UserSkillProfileMapper profileMapper;
    private final SkillMapper skillMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SkillProfileVO save(String sno, SkillProfileSaveRequest request) {
        List<SkillProfileSaveRequest.Item> items =
                request == null || request.getItems() == null ? List.of() : request.getItems();

        if (items.size() > MAX_ITEMS) {
            throw new BusinessException(ErrorCode.SKILL_PROFILE_TOO_MANY);
        }

        /*
         * 允许提交空集合 —— 那是"清空我的自评画像"。
         * 但不允许"一个都没传"和"传了空数组"混为一谈：前者是调用方写错了，
         * 后者是用户的真实意图（把标签全取消掉）。
         * 这里靠 request.getItems() == null 与 isEmpty() 区分，
         * null 已被 DTO 的 @NotNull 拦下，走到这里能安全按空集合处理。
         */

        // 1) 解析意图 + 按 skillId 去重
        Map<Long, SkillIntent> wanted = resolveIntents(items);

        // 2) 校验技能存在且启用（避免画像里挂上已删除的标签）
        Map<Long, Skill> skills = loadActiveSkills(wanted.keySet());

        // 3) 读已有记录，按 skillId 建索引
        List<UserSkillProfile> existing = profileMapper.selectList(
                new LambdaQueryWrapper<UserSkillProfile>().eq(UserSkillProfile::getSno, sno));
        Map<Long, UserSkillProfile> existingBySkill = new LinkedHashMap<>();
        for (UserSkillProfile p : existing) {
            existingBySkill.put(p.getSkillId(), p);
        }

        int inserted = 0;
        int updated = 0;
        int removed = 0;

        // 4) 提交内容写入（存在则更新，不存在则插入）
        for (Map.Entry<Long, SkillIntent> e : wanted.entrySet()) {
            Long skillId = e.getKey();
            SkillIntent intent = e.getValue();
            UserSkillProfile old = existingBySkill.get(skillId);

            if (old == null) {
                profileMapper.insert(new UserSkillProfile()
                        .setSno(sno)
                        .setSkillId(skillId)
                        .setIntent(intent)
                        .setLevel(defaultLevel(intent))
                        .setSource("SELF")
                        .setScore(BigDecimal.ZERO));
                inserted++;
            } else {
                old.setIntent(intent);
                /*
                 * 只在自评记录上更新等级：互评/课程记录的 level 有独立来源，
                 * 不该被导引页的默认值覆盖。
                 */
                if ("SELF".equals(old.getSource())) {
                    old.setLevel(defaultLevel(intent));
                }
                profileMapper.updateById(old);
                updated++;
            }
        }

        // 5) 删除本次未提交的 SELF 记录（取消勾选生效），保留 PEER / COURSE
        for (UserSkillProfile p : existing) {
            boolean selfOwned = p.getSource() == null || "SELF".equals(p.getSource());
            if (selfOwned && !wanted.containsKey(p.getSkillId())) {
                profileMapper.deleteById(p.getId());
                removed++;
            }
        }

        log.info("[技能画像] sno={} 提交={} 新增={} 更新={} 移除={}（互评/课程记录保留 {} 条）",
                sno, wanted.size(), inserted, updated, removed,
                existing.size() - removed - updated);

        return assemble(sno);
    }

    @Override
    public SkillProfileVO mine(String sno) {
        return assemble(sno);
    }

    /* ------------------------------------------------------------------ */
    /* 内部实现                                                            */
    /* ------------------------------------------------------------------ */

    /**
     * 解析并去重意图。
     *
     * <p>同一技能被同时选进"我擅长"和"我急需"是真实场景（例如"我会一点 Python，
     * 但也想找人一起深入"）。而表上有唯一键 {@code uk_usp_sno_skill}，
     * 同一 (sno, skill_id) 只能有一行，所以必须挑一个意图落库。
     *
     * <p>优先级 {@code SKILLED > RESEARCHING > NEEDED}：
     * "我擅长"是可被他人检索到的<b>供给</b>，信息价值最高；
     * 冲突时丢一个需求比丢一个供给更可接受。
     */
    private Map<Long, SkillIntent> resolveIntents(List<SkillProfileSaveRequest.Item> items) {
        Map<Long, SkillIntent> wanted = new LinkedHashMap<>();
        for (SkillProfileSaveRequest.Item item : items) {
            if (item == null || item.getSkillId() == null) {
                throw new BusinessException(ErrorCode.PARAM_INVALID, "技能 ID 不能为空");
            }
            SkillIntent intent = parseIntent(item.getIntent());
            SkillIntent old = wanted.get(item.getSkillId());
            if (old == null || priority(intent) > priority(old)) {
                wanted.put(item.getSkillId(), intent);
            }
        }
        return wanted;
    }

    /**
     * 把枚举名解析为 {@link SkillIntent}。
     *
     * <p>不用 {@code valueOf} 直接抛：那会抛出 {@link IllegalArgumentException}，
     * 被全局异常处理器兜成 5xxx「系统异常」，把用户输入错误报成服务端故障，
     * 排查时会误导方向。
     */
    private SkillIntent parseIntent(String name) {
        if (name == null || name.isBlank()) {
            throw new BusinessException(ErrorCode.SKILL_PROFILE_INTENT_ILLEGAL);
        }
        try {
            return SkillIntent.valueOf(name.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            throw new BusinessException(ErrorCode.SKILL_PROFILE_INTENT_ILLEGAL,
                    "无法识别的技能意图：" + name);
        }
    }

    /** 意图优先级，用于同一技能多意图冲突时的取舍 */
    private int priority(SkillIntent intent) {
        return switch (intent) {
            case SKILLED -> 3;
            case RESEARCHING -> 2;
            case NEEDED -> 1;
        };
    }

    /** 导引页不采集熟练度，按意图给一个合理的默认值 */
    private int defaultLevel(SkillIntent intent) {
        return intent == SkillIntent.SKILLED ? DEFAULT_LEVEL_SKILLED : DEFAULT_LEVEL_OTHER;
    }

    /**
     * 批量加载技能并校验可用性。
     *
     * <p>一次 {@code IN} 查询而不是循环单查：导引三步最多 18 个标签，
     * 循环查会产生 18 次往返，在局域网环境下体感差异明显。
     */
    private Map<Long, Skill> loadActiveSkills(Set<Long> skillIds) {
        if (skillIds.isEmpty()) {
            return Map.of();
        }
        List<Skill> found = skillMapper.selectList(
                new LambdaQueryWrapper<Skill>().in(Skill::getId, skillIds));

        Map<Long, Skill> map = new LinkedHashMap<>();
        for (Skill s : found) {
            map.put(s.getId(), s);
        }
        for (Long id : skillIds) {
            if (!map.containsKey(id)) {
                throw new BusinessException(ErrorCode.SKILL_NOT_FOUND, "技能标签不存在：ID " + id);
            }
        }
        return map;
    }

    /**
     * 组装画像视图：按意图分组，并补齐技能本体信息。
     */
    private SkillProfileVO assemble(String sno) {
        List<UserSkillProfile> rows = profileMapper.selectList(
                new LambdaQueryWrapper<UserSkillProfile>()
                        .eq(UserSkillProfile::getSno, sno)
                        .orderByDesc(UserSkillProfile::getScore));

        Set<Long> skillIds = rows.stream()
                .map(UserSkillProfile::getSkillId)
                .collect(Collectors.toCollection(LinkedHashSet::new));

        Map<Long, Skill> skillMap = skillIds.isEmpty() ? Map.of()
                : skillMapper.selectList(new LambdaQueryWrapper<Skill>().in(Skill::getId, skillIds))
                .stream().collect(Collectors.toMap(Skill::getId, s -> s, (a, b) -> a,
                        LinkedHashMap::new));

        List<SkillProfileVO.Entry> skilled = new ArrayList<>();
        List<SkillProfileVO.Entry> researching = new ArrayList<>();
        List<SkillProfileVO.Entry> needed = new ArrayList<>();

        for (UserSkillProfile row : rows) {
            Skill skill = skillMap.get(row.getSkillId());
            if (skill == null) {
                // 技能被删除的情况：跳过而不是返回 name=null 的脏条目
                log.warn("[技能画像] sno={} 引用了不存在的技能 ID={}，已跳过", sno, row.getSkillId());
                continue;
            }
            SkillProfileVO.Entry entry = new SkillProfileVO.Entry();
            entry.setSkill(SkillVO.of(skill));
            entry.setLevel(row.getLevel());
            entry.setSource(row.getSource());
            entry.setScore(row.getScore());

            SkillIntent intent = row.getIntent() == null ? SkillIntent.SKILLED : row.getIntent();
            switch (intent) {
                case SKILLED -> skilled.add(entry);
                case RESEARCHING -> researching.add(entry);
                case NEEDED -> needed.add(entry);
            }
        }

        // 分组内按"来源可信度 + 得分"排序：互评 > 课程 > 自评，让有实证的排前面
        Comparator<SkillProfileVO.Entry> byEvidence = Comparator
                .comparingInt((SkillProfileVO.Entry e) -> sourceWeight(e.getSource())).reversed()
                .thenComparing(e -> e.getScore() == null ? BigDecimal.ZERO : e.getScore(),
                        Comparator.reverseOrder());
        skilled.sort(byEvidence);
        researching.sort(byEvidence);
        needed.sort(byEvidence);

        SkillProfileVO vo = new SkillProfileVO();
        vo.setSkilled(skilled);
        vo.setResearching(researching);
        vo.setNeeded(needed);
        vo.setTotal(skilled.size() + researching.size() + needed.size());
        // 与 AuthService 首登判断保持同一口径：没有任何画像即为首次登录
        vo.setFirstLogin(vo.getTotal() == 0);
        return vo;
    }

    private int sourceWeight(String source) {
        if (source == null) {
            return 0;
        }
        return switch (source) {
            case "PEER" -> 2;
            case "COURSE" -> 1;
            default -> 0;
        };
    }
}
