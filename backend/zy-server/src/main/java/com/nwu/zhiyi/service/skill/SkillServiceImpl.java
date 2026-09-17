package com.nwu.zhiyi.service.skill;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.skill.ParseResultVO;
import com.nwu.zhiyi.api.dto.skill.SkillMatchVO;
import com.nwu.zhiyi.api.dto.skill.SkillSaveRequest;
import com.nwu.zhiyi.api.dto.skill.SkillTreeVO;
import com.nwu.zhiyi.api.dto.skill.SkillVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.SkillOntology;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.SkillOntologyMapper;
import com.nwu.zhiyi.service.skill.graph.SkillGraphService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 技能本体服务实现（模块 M2）。
 *
 * <p>缓存策略（见 {@link com.nwu.zhiyi.config.CacheConfig}）：
 * <ul>
 *   <li>{@code skillSnapshot} —— 全量启用标签，解析引擎的词典来源</li>
 *   <li>{@code skillTree} —— 标签树</li>
 *   <li>{@code skillSearch} —— 关键词检索结果</li>
 * </ul>
 * 任何写操作都会清空以上缓存，保证与数据库一致。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SkillServiceImpl implements SkillService {

    private final SkillMapper skillMapper;
    private final SkillOntologyMapper ontologyMapper;
    private final SkillTextParser parser;
    private final SkillGraphService graphService;

    /** 解析命中一次累加的热度分 */
    private static final int HOT_DELTA_PER_HIT = 3;

    /* ==================== 查询 ==================== */

    @Override
    public SkillTreeVO getTree(String categoryL1, String keyword) {
        String kw = normalizeKeyword(keyword);
        List<Skill> snapshot = filter(snapshot(), categoryL1, kw);

        // 门类 → 二级学科 → 技能
        Map<String, Map<String, List<Skill>>> grouped = new LinkedHashMap<>();
        for (Skill skill : snapshot) {
            grouped.computeIfAbsent(skill.getCategoryL1(), k -> new LinkedHashMap<>())
                    .computeIfAbsent(skill.getCategoryL2(), k -> new ArrayList<>())
                    .add(skill);
        }

        SkillTreeVO result = new SkillTreeVO();
        List<SkillTreeVO.CategoryNode> tree = new ArrayList<>();
        int subCount = 0;
        for (Map.Entry<String, Map<String, List<Skill>>> l1 : grouped.entrySet()) {
            SkillTreeVO.CategoryNode categoryNode = new SkillTreeVO.CategoryNode();
            categoryNode.setName(l1.getKey());

            List<SkillTreeVO.SubCategoryNode> children = new ArrayList<>();
            int categoryTotal = 0;
            for (Map.Entry<String, List<Skill>> l2 : l1.getValue().entrySet()) {
                SkillTreeVO.SubCategoryNode subNode = new SkillTreeVO.SubCategoryNode();
                subNode.setName(l2.getKey());
                subNode.setSkillCount(l2.getValue().size());
                subNode.setSkills(l2.getValue().stream()
                        .sorted(Comparator.comparing(Skill::getHotScore, Comparator.nullsLast(Comparator.reverseOrder())))
                        .map(SkillVO::of)
                        .collect(Collectors.toList()));
                children.add(subNode);
                categoryTotal += l2.getValue().size();
                subCount++;
            }
            categoryNode.setChildren(children);
            categoryNode.setSkillCount(categoryTotal);
            tree.add(categoryNode);
        }

        result.setTree(tree);
        result.setCategoryCount(tree.size());
        result.setSubCategoryCount(subCount);
        result.setSkillCount(snapshot.size());
        return result;
    }

    @Override
    public List<SkillMatchVO> search(String keyword, String categoryL1, int limit) {
        int max = Math.max(1, Math.min(limit, 100));
        String kw = normalizeKeyword(keyword);

        List<Skill> pool;
        if (kw == null) {
            // 无关键词：按热度返回，用于集市首屏与冷启动
            pool = snapshot().stream()
                    .filter(s -> matchCategory(s, categoryL1))
                    .collect(Collectors.toList());
        } else {
            // 阶段一：名称 / 别名 / 描述包含关键词
            pool = snapshot().stream()
                    .filter(s -> matchCategory(s, categoryL1))
                    .filter(s -> containsIgnoreCase(s.getName(), kw)
                            || containsIgnoreCase(s.getAlias(), kw)
                            || containsIgnoreCase(s.getDescription(), kw))
                    .collect(Collectors.toList());

            // 阶段二（降级递归）：仅有学科/专业命中时返回该学科下的标签
            if (pool.isEmpty()) {
                pool = snapshot().stream()
                        .filter(s -> containsIgnoreCase(s.getCategoryL2(), kw)
                                || containsIgnoreCase(s.getCategoryL1(), kw))
                        .collect(Collectors.toList());
            }
        }

        List<SkillMatchVO> result = pool.stream()
                .sorted(Comparator.comparing(Skill::getHotScore, Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(max)
                .map(s -> {
                    // 关键词精确等于标签名或别名时给高分，否则给关键词分
                    boolean exact = kw != null && kw.equalsIgnoreCase(normalize(s.getName()));
                    boolean aliasHit = kw != null && s.aliasContains(kw);
                    SkillMatchVO.MatchType type = exact ? SkillMatchVO.MatchType.EXACT
                            : aliasHit ? SkillMatchVO.MatchType.ALIAS
                            : SkillMatchVO.MatchType.KEYWORD;
                    String reason = exact ? "名称精确匹配"
                            : aliasHit ? "同义词匹配"
                            : kw == null ? "按热度推荐" : "关键词命中";
                    double score = type.getBaseWeight()
                            + Math.min(0.05, (s.getHotScore() == null ? 0 : s.getHotScore()) / 2000.0);
                    return SkillMatchVO.of(SkillVO.of(s), null, Math.min(1.0, score), type, reason);
                })
                .collect(Collectors.toList());

        // 命中热度累计：一次检索中命中的标签统一 +3
        if (kw != null && !result.isEmpty()) {
            result.forEach(m -> skillMapper.addHotScore(m.getSkillId(), HOT_DELTA_PER_HIT));
        }
        return result;
    }

    @Override
    public SkillVO getById(Long id) {
        Skill skill = skillMapper.selectById(id);
        if (skill == null) {
            throw new BusinessException(ErrorCode.SKILL_NOT_FOUND);
        }
        return SkillVO.of(skill);
    }

    @Override
    public List<CategoryStat> statsByCategory() {
        return skillMapper.countGroupByCategoryL1().stream()
                .map(row -> new CategoryStat(
                        String.valueOf(row.get("category_l1")),
                        ((Number) row.get("skill_count")).intValue()))
                .collect(Collectors.toList());
    }

    /* ==================== 解析 ==================== */

    @Override
    public ParseResultVO parse(String text, int limit, boolean withGraph) {
        int max = Math.max(1, Math.min(limit, 50));
        ParseResultVO result = parser.parse(text, snapshot(), max, withGraph);

        // 图谱补全（FR-M2-06）：挖掘字面匹配之外的隐性互补需求
        if (withGraph && !result.getMatched().isEmpty() && result.getMatched().size() < max) {
            graphService.augment(result, max);
        }

        // 解析命中的标签累计热度
        result.getMatched().forEach(m -> {
            if (m.getSkillId() != null) {
                skillMapper.addHotScore(m.getSkillId(), HOT_DELTA_PER_HIT);
            }
        });

        log.debug("[技能解析] engine={} matched={} triples={}",
                result.getEngine(), result.getMatched().size(), result.getTriples().size());
        return result;
    }

    /* ==================== 管理端写操作 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    @CacheEvict(cacheNames = {"skillSnapshot", "skillTree", "skillSearch"}, allEntries = true)
    public SkillVO create(SkillSaveRequest request) {
        Long exists = skillMapper.selectCount(new LambdaQueryWrapper<Skill>()
                .eq(Skill::getName, request.getName().trim()));
        if (exists != null && exists > 0) {
            throw new BusinessException(ErrorCode.SKILL_ALREADY_EXISTS);
        }

        Skill skill = new Skill()
                .setName(request.getName().trim())
                .setAlias(trimToNull(request.getAlias()))
                .setCategoryL1(request.getCategoryL1().trim())
                .setCategoryL2(request.getCategoryL2().trim())
                .setDescription(trimToNull(request.getDescription()))
                .setDifficulty(request.getDifficulty() == null ? 3 : request.getDifficulty())
                .setHotScore(0)
                .setStatus(request.getStatus() == null ? 1 : request.getStatus());
        skillMapper.insert(skill);

        log.info("[技能标签新增] id={} name={} {} / {}",
                skill.getId(), skill.getName(), skill.getCategoryL1(), skill.getCategoryL2());
        return SkillVO.of(skill);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    @CacheEvict(cacheNames = {"skillSnapshot", "skillTree", "skillSearch"}, allEntries = true)
    public SkillVO update(Long id, SkillSaveRequest request) {
        Skill existing = skillMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException(ErrorCode.SKILL_NOT_FOUND);
        }
        // 名称改动需检查唯一性
        if (!existing.getName().equals(request.getName().trim())) {
            Long dup = skillMapper.selectCount(new LambdaQueryWrapper<Skill>()
                    .eq(Skill::getName, request.getName().trim()));
            if (dup != null && dup > 0) {
                throw new BusinessException(ErrorCode.SKILL_ALREADY_EXISTS);
            }
        }

        Skill update = new Skill()
                .setId(id)
                .setName(request.getName().trim())
                .setAlias(trimToNull(request.getAlias()))
                .setCategoryL1(request.getCategoryL1().trim())
                .setCategoryL2(request.getCategoryL2().trim())
                .setDescription(trimToNull(request.getDescription()))
                .setDifficulty(request.getDifficulty())
                .setStatus(request.getStatus());
        skillMapper.updateById(update);

        log.info("[技能标签修改] id={} name={}", id, request.getName());
        return SkillVO.of(skillMapper.selectById(id));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    @CacheEvict(cacheNames = {"skillSnapshot", "skillTree", "skillSearch", "ontologyGraph"}, allEntries = true)
    public void delete(Long id) {
        Skill existing = skillMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException(ErrorCode.SKILL_NOT_FOUND);
        }
        // 先清理图谱关系，避免留下悬挂边
        ontologyMapper.delete(new LambdaQueryWrapper<SkillOntology>()
                .eq(SkillOntology::getSrcSkillId, id)
                .or()
                .eq(SkillOntology::getDstSkillId, id));
        skillMapper.deleteById(id);
        log.info("[技能标签删除] id={} name={}（含图谱关系清理）", id, existing.getName());
    }

    /* ==================== 缓存与工具 ==================== */

    /**
     * 全量启用标签快照 —— 作为解析词典与检索池。
     *
     * <p>规模预期为 1000 左右标签，单次查询成本低，缓存后解析完全走内存
     * （对应 NFR-P-01 的响应时间目标）。
     */
    @Cacheable(cacheNames = "skillSnapshot", key = "'enabled'")
    public List<Skill> snapshot() {
        return skillMapper.selectList(new LambdaQueryWrapper<Skill>()
                .eq(Skill::getStatus, 1)
                .orderByDesc(Skill::getHotScore));
    }

    /**
     * 批量按 ID 取标签（图谱补全时使用，避免 N+1）。
     *
     * @param ids 主键集合
     * @return 技能列表
     */
    public List<Skill> listByIds(Set<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        return skillMapper.selectBatchIds(new LinkedHashSet<>(ids));
    }

    private List<Skill> filter(List<Skill> source, String categoryL1, String keyword) {
        return source.stream()
                .filter(s -> matchCategory(s, categoryL1))
                .filter(s -> keyword == null
                        || containsIgnoreCase(s.getName(), keyword)
                        || containsIgnoreCase(s.getAlias(), keyword))
                .collect(Collectors.toList());
    }

    private boolean matchCategory(Skill skill, String categoryL1) {
        return categoryL1 == null || categoryL1.isBlank()
                || categoryL1.trim().equals(skill.getCategoryL1());
    }

    private static String normalizeKeyword(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return null;
        }
        return keyword.trim().toLowerCase();
    }

    private static boolean containsIgnoreCase(String source, String keyword) {
        return source != null && keyword != null && source.toLowerCase().contains(keyword);
    }

    private static String normalize(String value) {
        return value == null ? "" : value.toLowerCase().trim();
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
