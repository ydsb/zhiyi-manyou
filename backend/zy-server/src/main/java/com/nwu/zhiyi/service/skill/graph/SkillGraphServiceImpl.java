package com.nwu.zhiyi.service.skill.graph;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.skill.ParseResultVO;
import com.nwu.zhiyi.api.dto.skill.SkillMatchVO;
import com.nwu.zhiyi.api.dto.skill.SkillRelationVO;
import com.nwu.zhiyi.api.dto.skill.SkillVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.SkillRelationType;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.SkillOntology;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.SkillOntologyMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 技能知识图谱服务实现。
 *
 * <p><b>依赖方向说明</b>：本类只依赖 {@link SkillMapper} 与 {@link SkillOntologyMapper}，
 * <b>不</b>注入 {@code SkillService}。因为 {@code SkillServiceImpl} 需要调用
 * {@link #augment} 做图谱补全，若此处反向依赖 {@code SkillService} 会形成
 * 循环依赖（Spring Boot 2.6+ 默认禁止）。按 ID 批量查标签本就是一个简单的
 * 数据访问操作，直接用 Mapper 既断开环也更直接。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SkillGraphServiceImpl implements SkillGraphService {

    private final SkillOntologyMapper ontologyMapper;
    private final SkillMapper skillMapper;

    /** 图谱补全时，邻居标签的分数折扣系数 */
    private static final double NEIGHBOR_SCORE_FACTOR = 0.85;

    /** 单次补全最多新增的标签数 */
    private static final int MAX_AUGMENT = 5;

    @Override
    public void augment(ParseResultVO result, int limit) {
        if (result == null || result.getMatched() == null || result.getMatched().isEmpty()) {
            return;
        }
        Set<Long> existingIds = result.getMatched().stream()
                .map(SkillMatchVO::getSkillId)
                .collect(Collectors.toCollection(LinkedHashSet::new));

        List<Long> seedIds = new ArrayList<>(existingIds);
        // 只有互补协作边参与隐性需求挖掘：先决条件属于学习路径规划（M3），同义已在词典层处理。
        //
        // 一次查询同时拿到 邻居 / 连过来的种子 / 权重 三样东西。
        // 早先的写法是"先查一遍邻居 ID，再对每个种子各查一次 selectNeighbors"——
        // 两次查询返回同一批边，而且后者还丢掉了 seed 信息，导致无法判断
        // "某个候选能被几个已命中技能连到"（见下方排序说明）。
        List<SkillOntologyMapper.ComplementNeighborRow> rows =
                ontologyMapper.selectComplementNeighborRows(seedIds);
        if (rows == null || rows.isEmpty()) {
            return;
        }

        // 候选邻居：排除已经命中的技能（不要自我重复）
        LinkedHashSet<Long> neighborIds = new LinkedHashSet<>();
        for (SkillOntologyMapper.ComplementNeighborRow row : rows) {
            if (row.getNeighborId() != null && !existingIds.contains(row.getNeighborId())) {
                neighborIds.add(row.getNeighborId());
            }
        }
        if (neighborIds.isEmpty()) {
            return;
        }

        Map<Long, Skill> neighborSkills = listSkillsByIds(neighborIds).stream()
                .collect(Collectors.toMap(Skill::getId, s -> s, (a, b) -> a, LinkedHashMap::new));

        // 关系强度用于排序与折扣。
        //
        // 排序不能只看权重。当 weight 相同时（本图谱里绝大多数互补边都是 0.8/0.9
        // 这两档，一个种子技能的所有邻居几乎全部并列），"按权重取前 N 个"等价于
        // 任意取 N 个 —— 实测会出现"前端页面"补出 SolidWorks 三维建模这种噪音。
        //
        // 更有效的相关性信号是**被多少个不同的种子技能连到**：能被多个已命中技能
        // 共同指向的标签，比只被一个种子偶然连到的标签更可能切题。
        // 因此按 (种子数, 权重, ID) 三级排序，ID 兜底保证结果稳定可复现。
        Map<Long, BigDecimal> weights = new LinkedHashMap<>();
        Map<Long, Set<Long>> seedHits = new LinkedHashMap<>();
        for (SkillOntologyMapper.ComplementNeighborRow row : rows) {
            Long neighbor = row.getNeighborId();
            Long seed = row.getSeedId();
            if (neighbor == null || seed == null || !neighborSkills.containsKey(neighbor)) {
                continue;
            }
            weights.merge(neighbor, row.getWeight() == null ? BigDecimal.ONE : row.getWeight(), BigDecimal::max);
            seedHits.computeIfAbsent(neighbor, k -> new LinkedHashSet<>()).add(seed);
        }

        // 基准分：取当前匹配结果的最低分，邻居标签不超过它（避免喧宾夺主）
        double baseScore = result.getMatched().stream()
                .map(SkillMatchVO::getScore)
                .filter(java.util.Objects::nonNull)
                .mapToDouble(BigDecimal::doubleValue)
                .min().orElse(0.7);

        List<SkillMatchVO> augmented = weights.entrySet().stream()
                .sorted(Comparator
                        .comparingInt((Map.Entry<Long, BigDecimal> e) ->
                                seedHits.getOrDefault(e.getKey(), java.util.Collections.emptySet()).size())
                        .reversed()
                        .thenComparing(Map.Entry.<Long, BigDecimal>comparingByValue().reversed())
                        .thenComparing(Map.Entry.comparingByKey()))
                .limit(MAX_AUGMENT)
                .map(entry -> {
                    Skill skill = neighborSkills.get(entry.getKey());
                    SkillVO vo = SkillVO.of(skill);
                    double score = Math.min(1.0, baseScore * NEIGHBOR_SCORE_FACTOR
                            * entry.getValue().doubleValue());
                    int hits = seedHits.getOrDefault(entry.getKey(), java.util.Collections.emptySet()).size();
                    String reason = "知识图谱互补协作关联（非字面命中）"
                            + (hits > 1 ? "，与 " + hits + " 个已命中技能均存在协作关系" : "");
                    return SkillMatchVO.of(vo, "RESEARCHING", score, SkillMatchVO.MatchType.GRAPH, reason);
                })
                .collect(Collectors.toList());

        if (augmented.isEmpty()) {
            return;
        }
        List<SkillMatchVO> merged = new ArrayList<>(result.getMatched());
        for (SkillMatchVO add : augmented) {
            if (merged.size() >= limit) {
                break;
            }
            boolean duplicated = merged.stream().anyMatch(m -> m.getSkillId().equals(add.getSkillId()));
            if (!duplicated) {
                merged.add(add);
            }
        }
        result.setMatched(merged);

        // 三元组同步补充
        Set<String> tripleObjects = result.getTriples().stream()
                .map(ParseResultVO.Triple::getObject)
                .collect(Collectors.toCollection(HashSet::new));
        for (SkillMatchVO add : augmented) {
            if (tripleObjects.add(add.getName())) {
                result.getTriples().add(new ParseResultVO.Triple("我", "关联", add.getName()));
            }
        }
        result.setHint(String.format("已返回 %d 个字面命中标签，并由图谱补充 %d 个跨学科关联标签",
                existingIds.size(), augmented.size()));
        log.debug("[图谱补全] seeds={} added={}", existingIds, augmented.stream()
                .map(SkillMatchVO::getName).collect(Collectors.toList()));
    }

    @Override
    @Cacheable(cacheNames = "ontologyGraph", key = "'all'")
    public List<SkillRelationVO> getAllRelations() {
        List<SkillOntology> edges = ontologyMapper.selectList(
                new LambdaQueryWrapper<SkillOntology>().orderByAsc(SkillOntology::getId));
        return toVO(edges);
    }

    @Override
    public List<SkillRelationVO> getRelationsOf(Long skillId, String relationType) {
        if (skillMapper.selectById(skillId) == null) {
            throw new BusinessException(ErrorCode.SKILL_NOT_FOUND);
        }
        LambdaQueryWrapper<SkillOntology> wrapper = new LambdaQueryWrapper<SkillOntology>()
                .and(w -> w.eq(SkillOntology::getSrcSkillId, skillId).or().eq(SkillOntology::getDstSkillId, skillId));
        if (StringUtils.hasText(relationType)) {
            SkillRelationType type = SkillRelationType.valueOf(relationType.trim().toUpperCase());
            wrapper.eq(SkillOntology::getRelationType, type);
        }
        return toVO(ontologyMapper.selectList(wrapper));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    @CacheEvict(cacheNames = {"ontologyGraph"}, allEntries = true)
    public SkillRelationVO createRelation(Long srcSkillId, Long dstSkillId, String relationType,
                                         BigDecimal weight, String remark) {
        if (srcSkillId.equals(dstSkillId)) {
            throw BusinessException.paramInvalid("源技能与目标技能不能相同");
        }
        Skill src = skillMapper.selectById(srcSkillId);
        if (src == null) {
            throw new BusinessException(ErrorCode.SKILL_NOT_FOUND, "源技能不存在：" + srcSkillId);
        }
        Skill dst = skillMapper.selectById(dstSkillId);
        if (dst == null) {
            throw new BusinessException(ErrorCode.SKILL_NOT_FOUND, "目标技能不存在：" + dstSkillId);
        }

        SkillRelationType type;
        try {
            type = SkillRelationType.valueOf(relationType.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw BusinessException.paramInvalid("关系类型不合法，应为 PREREQUISITE / COMPLEMENT / SYNONYM");
        }

        Long dup = ontologyMapper.selectCount(new LambdaQueryWrapper<SkillOntology>()
                .eq(SkillOntology::getSrcSkillId, srcSkillId)
                .eq(SkillOntology::getDstSkillId, dstSkillId)
                .eq(SkillOntology::getRelationType, type));
        if (dup != null && dup > 0) {
            throw BusinessException.paramInvalid("该关系已存在");
        }

        SkillOntology edge = new SkillOntology()
                .setSrcSkillId(srcSkillId)
                .setDstSkillId(dstSkillId)
                .setRelationType(type)
                .setWeight(weight == null ? BigDecimal.valueOf(0.8) : weight)
                .setDirected(type.isDirected() ? 1 : 0)
                .setRemark(StringUtils.hasText(remark) ? remark.trim() : null);
        ontologyMapper.insert(edge);

        log.info("[图谱关系新增] {} --{}--> {}", src.getName(), type, dst.getName());
        return SkillRelationVO.of(edge, src.getName(), dst.getName());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    @CacheEvict(cacheNames = {"ontologyGraph"}, allEntries = true)
    public void deleteRelation(Long relationId) {
        SkillOntology edge = ontologyMapper.selectById(relationId);
        if (edge == null) {
            throw BusinessException.notFound("图谱关系不存在：" + relationId);
        }
        ontologyMapper.deleteById(relationId);
        log.info("[图谱关系删除] id={}", relationId);
    }

    /* ==================== 私有工具 ==================== */

    /**
     * 按 ID 批量取技能标签（图谱补全与关系转 VO 时使用，避免 N+1）。
     *
     * <p>直接用 Mapper 而非 {@code SkillService.listByIds}，以断开循环依赖。
     *
     * @param ids 主键集合
     * @return 技能列表
     */
    private List<Skill> listSkillsByIds(Set<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        return skillMapper.selectBatchIds(new LinkedHashSet<>(ids));
    }

    /**
     * 批量把实体边转为视图对象，技能名一次性查出，避免 N+1。
     */
    private List<SkillRelationVO> toVO(List<SkillOntology> edges) {
        if (edges == null || edges.isEmpty()) {
            return List.of();
        }
        Set<Long> ids = new LinkedHashSet<>();
        edges.forEach(e -> {
            ids.add(e.getSrcSkillId());
            ids.add(e.getDstSkillId());
        });
        Map<Long, String> nameMap = listSkillsByIds(ids).stream()
                .collect(Collectors.toMap(Skill::getId, Skill::getName, (a, b) -> a));

        return edges.stream()
                .sorted(Comparator.comparing(SkillOntology::getId))
                .map(e -> SkillRelationVO.of(e, nameMap.get(e.getSrcSkillId()), nameMap.get(e.getDstSkillId())))
                .collect(Collectors.toList());
    }
}
