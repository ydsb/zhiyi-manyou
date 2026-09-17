package com.nwu.zhiyi.service.demand;

import com.nwu.zhiyi.api.dto.demand.DemandInterestVO;
import com.nwu.zhiyi.api.dto.demand.MarketCardVO;
import com.nwu.zhiyi.common.enums.DemandVisibility;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.DemandInterest;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.entity.UserSkillProfile;
import com.nwu.zhiyi.domain.mapper.DemandInterestMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.SkillOntologyMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.domain.entity.SkillOntology;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 集市卡片组装器。
 *
 * <p>把 {@link Demand} 实体装配成 {@link MarketCardVO}：补齐发布人信息、技能名、
 * 交换意向，并调用 {@link MatchScoreCalculator} 计算匹配度。
 *
 * <p><b>为什么单独成一个组件</b>：集市列表、卡片详情、交换记录回显都需要这套装配逻辑；
 * 抽出来还能保证"一次查询批量装好"（避免逐条查用户/技能/画像造成 N+1，
 * 对应 NFR-P-02 的响应时间目标）。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DemandCardAssembler {

    private final StudentMapper studentMapper;
    private final SkillMapper skillMapper;
    private final SkillOntologyMapper ontologyMapper;
    private final DemandInterestMapper interestMapper;
    private final MatchScoreCalculator matchScoreCalculator;
    private final com.nwu.zhiyi.domain.mapper.UserSkillProfileMapper profileMapper;

    /**
     * 批量装配卡片。
     *
     * @param demands     需求卡片列表
     * @param viewerSno   当前登录用户学号（可为 null 表示未登录）
     * @param withInterest 是否附带交换意向明细（详情页需要，列表页通常不需要）
     * @return 卡片视图列表
     */
    public List<MarketCardVO> assemble(List<Demand> demands, String viewerSno, boolean withInterest) {
        if (demands == null || demands.isEmpty()) {
            return List.of();
        }

        // ---------- 批量取技能 ----------
        Set<Long> skillIds = new LinkedHashSet<>();
        demands.forEach(d -> {
            if (d.getExpectedSkillId() != null) {
                skillIds.add(d.getExpectedSkillId());
            }
            if (d.getOfferSkillId() != null) {
                skillIds.add(d.getOfferSkillId());
            }
        });
        Map<Long, Skill> skillMap = skillIds.isEmpty() ? Map.of()
                : skillMapper.selectBriefByIds(skillIds).stream()
                .collect(Collectors.toMap(Skill::getId, s -> s, (a, b) -> a, LinkedHashMap::new));

        // ---------- 批量取发布人 ----------
        Set<String> ownerSnos = demands.stream().map(Demand::getOwnerSno)
                .filter(java.util.Objects::nonNull).collect(Collectors.toCollection(LinkedHashSet::new));
        Map<String, Student> ownerMap = ownerSnos.isEmpty() ? Map.of()
                : studentMapper.selectBriefBySnos(ownerSnos).stream()
                .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a, LinkedHashMap::new));

        // ---------- 当前用户画像 + 图谱（匹配度计算依赖） ----------
        List<UserSkillProfile> profiles = viewerSno == null ? List.of()
                : profileMapper.selectList(new LambdaQueryWrapper<UserSkillProfile>()
                .eq(UserSkillProfile::getSno, viewerSno));
        Map<Long, List<MatchScoreCalculator.Edge>> graph = buildGraphForSkills(skillIds, skillMap);

        // ---------- 交换意向 ----------
        Map<Long, List<DemandInterest>> interestMap = new HashMap<>();
        if (withInterest) {
            List<Long> demandIds = demands.stream().map(Demand::getId).collect(Collectors.toList());
            List<DemandInterest> all = interestMapper.selectList(
                    new LambdaQueryWrapper<DemandInterest>().in(DemandInterest::getDemandId, demandIds)
                            .orderByDesc(DemandInterest::getCreatedAt));
            all.forEach(i -> interestMap.computeIfAbsent(i.getDemandId(), k -> new ArrayList<>()).add(i));
        }

        Student viewer = viewerSno == null ? null : ownerMap.get(viewerSno);
        if (viewer == null && viewerSno != null) {
            viewer = studentMapper.selectOne(new LambdaQueryWrapper<Student>().eq(Student::getSno, viewerSno));
        }
        String viewerCollege = viewer == null ? null : viewer.getCollege();

        List<MarketCardVO> result = new ArrayList<>(demands.size());
        for (Demand demand : demands) {
            MarketCardVO vo = new MarketCardVO();
            vo.setId(demand.getId());
            vo.setDemandNo(demand.getDemandNo());
            vo.setTitle(demand.getTitle());
            vo.setDescription(demand.getDescription());
            vo.setOwnerSno(demand.getOwnerSno());

            Student owner = ownerMap.get(demand.getOwnerSno());
            if (owner != null) {
                vo.setOwnerName(owner.displayName());
                vo.setOwnerCollege(owner.getCollege());
                vo.setOwnerCreditScore(owner.getCreditScore() == null ? null : String.valueOf(owner.getCreditScore()));
            }
            vo.setExpectSkill(brief(skillMap.get(demand.getExpectedSkillId())));
            vo.setOfferSkill(brief(skillMap.get(demand.getOfferSkillId())));
            vo.setExpectedHours(demand.getExpectedHours());
            vo.setExpectedPeriod(demand.getExpectedPeriod());

            if (demand.getVisibility() != null) {
                vo.setVisibility(demand.getVisibility().name());
                vo.setVisibilityLabel(demand.getVisibility().getLabel());
            }
            if (demand.getStatus() != null) {
                vo.setStatus(demand.getStatus().name());
                vo.setStatusLabel(demand.getStatus().getLabel());
            }
            if (demand.getAuditStatus() != null) {
                vo.setAuditStatus(demand.getAuditStatus().name());
            }
            vo.setMatchCount(demand.getMatchCount());
            vo.setViewCount(demand.getViewCount());
            vo.setCreatedAt(demand.getCreatedAt());
            vo.setExpireAt(demand.getExpireAt());

            if (withInterest) {
                List<DemandInterestVO> interestVOs = interestMap.getOrDefault(demand.getId(), List.of())
                        .stream().map(DemandInterestVO::of).collect(Collectors.toList());
                // 补齐申请人昵称
                Set<String> applicantSnos = interestVOs.stream().map(DemandInterestVO::getApplicantSno)
                        .filter(java.util.Objects::nonNull).collect(Collectors.toCollection(LinkedHashSet::new));
                if (!applicantSnos.isEmpty()) {
                    Map<String, Student> applicants = studentMapper.selectBriefBySnos(applicantSnos).stream()
                            .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));
                    interestVOs.forEach(v -> {
                        Student a = applicants.get(v.getApplicantSno());
                        if (a != null) {
                            v.setApplicantName(a.displayName());
                            v.setApplicantCollege(a.getCollege());
                        }
                    });
                }
                vo.setInterests(interestVOs);
            }

            // ---------- 匹配度 ----------
            MatchScoreCalculator.Score score = matchScoreCalculator.calculate(
                    demand, viewerSno, viewerCollege, profiles, skillMap, graph);
            vo.setMatchScore(score.score());
            vo.setHighMatch(score.isHighMatch());
            vo.setMatchFactors(score.factors());

            result.add(vo);
        }
        return result;
    }

    /**
     * 装配单张卡片。
     *
     * @param demand       卡片
     * @param viewerSno    当前用户
     * @param withInterest 是否带意向明细
     * @return 卡片视图
     */
    public MarketCardVO assembleOne(Demand demand, String viewerSno, boolean withInterest) {
        List<MarketCardVO> list = assemble(List.of(demand), viewerSno, withInterest);
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * 装配指定用户相关的意向列表（供"我收到的邀约"使用）。
     *
     * @param interests  意向列表
     * @param viewerSno  当前用户
     * @return 带申请人信息的意向视图
     */
    public List<DemandInterestVO> assembleInterests(List<DemandInterest> interests, String viewerSno) {
        if (interests == null || interests.isEmpty()) {
            return List.of();
        }
        List<DemandInterestVO> vos = interests.stream().map(DemandInterestVO::of).collect(Collectors.toList());
        Set<String> snos = vos.stream().map(DemandInterestVO::getApplicantSno)
                .filter(java.util.Objects::nonNull).collect(Collectors.toCollection(LinkedHashSet::new));
        if (!snos.isEmpty()) {
            Map<String, Student> map = studentMapper.selectBriefBySnos(snos).stream()
                    .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));
            vos.forEach(v -> {
                Student a = map.get(v.getApplicantSno());
                if (a != null) {
                    v.setApplicantName(a.displayName());
                    v.setApplicantCollege(a.getCollege());
                }
            });
        }
        return vos;
    }

    /* ==================== 私有工具 ==================== */

    private MarketCardVO.SkillBrief brief(Skill skill) {
        if (skill == null) {
            return null;
        }
        MarketCardVO.SkillBrief b = new MarketCardVO.SkillBrief();
        b.setId(skill.getId());
        b.setName(skill.getName());
        b.setCategoryL1(skill.getCategoryL1());
        b.setCategoryL2(skill.getCategoryL2());
        return b;
    }

    /**
     * 为匹配度计算构建图谱邻接表。
     *
     * <p>为避免把整张图谱载入内存，只查询与本次卡片涉及的技能相关的边。
     */
    private Map<Long, List<MatchScoreCalculator.Edge>> buildGraphForSkills(Collection<Long> skillIds,
                                                                          Map<Long, Skill> skillMap) {
        if (skillIds == null || skillIds.isEmpty()) {
            return Map.of();
        }
        // 取一跳邻域即可满足 1 跳判定；2~3 跳判定会退化为"暂无关联"，
        // 这是可接受的精度/成本折中（图谱规模上千后仍能保持列表响应时间）。
        List<SkillOntology> edges = ontologyMapper.selectList(new LambdaQueryWrapper<SkillOntology>()
                .in(SkillOntology::getSrcSkillId, skillIds)
                .or()
                .in(SkillOntology::getDstSkillId, skillIds));
        List<MatchScoreCalculator.GraphEdgeRow> rows = edges.stream()
                .map(e -> new MatchScoreCalculator.GraphEdgeRow(e.getSrcSkillId(), e.getDstSkillId(),
                        e.getRelationType()))
                .collect(Collectors.toList());
        return MatchScoreCalculator.buildGraph(rows);
    }

    /**
     * 预加载技能字典（供调用方复用，避免重复查询）。
     *
     * @param skillIds 技能 ID 集合
     * @return id → Skill
     */
    public Map<Long, Skill> loadSkills(Collection<Long> skillIds) {
        if (skillIds == null || skillIds.isEmpty()) {
            return Map.of();
        }
        return skillMapper.selectBriefByIds(skillIds).stream()
                .collect(Collectors.toMap(Skill::getId, s -> s, (a, b) -> a, LinkedHashMap::new));
    }

    /**
     * 校验可见性：PRIVATE 卡片只对发布人与已受邀者可见。
     *
     * @param demand 卡片
     * @param viewerSno 当前用户
     * @return 可见返回 true
     */
    public boolean visibleTo(Demand demand, String viewerSno) {
        if (demand == null) {
            return false;
        }
        if (demand.getVisibility() == null || demand.getVisibility() == DemandVisibility.PUBLIC) {
            return true;
        }
        if (demand.isOwnedBy(viewerSno)) {
            return true;
        }
        if (demand.getVisibility() == DemandVisibility.PRIVATE) {
            // 仅受邀：存在对该卡片的意向即视为受邀
            Long count = interestMapper.selectCount(new LambdaQueryWrapper<DemandInterest>()
                    .eq(DemandInterest::getDemandId, demand.getId())
                    .eq(DemandInterest::getApplicantSno, viewerSno));
            return count != null && count > 0;
        }
        // COLLEGE：需与发布人同院系
        if (viewerSno == null) {
            return false;
        }
        Student viewer = studentMapper.selectOne(new LambdaQueryWrapper<Student>().eq(Student::getSno, viewerSno));
        Student owner = studentMapper.selectOne(new LambdaQueryWrapper<Student>().eq(Student::getSno, demand.getOwnerSno()));
        return viewer != null && owner != null && java.util.Objects.equals(viewer.getCollege(), owner.getCollege());
    }
}
