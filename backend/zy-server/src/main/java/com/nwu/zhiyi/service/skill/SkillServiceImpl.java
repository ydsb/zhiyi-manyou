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
import com.nwu.zhiyi.service.match.SemanticMatchClient;
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
    private final SemanticMatchClient semanticClient;

    /** 解析命中一次累加的热度分 */
    private static final int HOT_DELTA_PER_HIT = 3;

    /**
     * 规则命中少于该数量时启用语义兜底。
     *
     * <p>取 2 而不是 1：只有 1 条规则命中通常意味着用户输入里的其他技能词
     * 都没被词典覆盖，正需要语义补充；而 2 条以上说明词典已经工作得不错，
     * 此时引入向量结果反而会稀释精度。
     */
    private static final int SEMANTIC_FALLBACK_THRESHOLD = 2;

    /**
     * 语义结果的最低分阈值。
     *
     * <p><b>这个值必须实测标定，不能凭感觉设</b>。实测分数分布：
     * <table border="1">
     *   <tr><th>类型</th><th>top1 分数</th><th>例子</th></tr>
     *   <tr><td>明确相关</td><td>0.68 ~ 0.92</td>
     *       <td>求带机器学习 → 机器学习建模 0.897</td></tr>
     *   <tr><td>弱相关（可接受）</td><td>0.37 ~ 0.60</td>
     *       <td>我会剪视频想学做PPT → 短视频创作与运营 0.379</td></tr>
     *   <tr><td>无关（噪声）</td><td>0.05 ~ 0.16</td>
     *       <td>帮忙订火车票 → 化学实验数据处理 0.036</td></tr>
     * </table>
     *
     * <p>取 0.30：既保住"弱相关"那一档（0.37 起），又把噪声挡在门外。
     *
     * <p><b>早期设 0.15 时踩过的坑</b>：一批无关查询返回了相同的
     * JVM 调优 / Matplotlib 绘图 / 数据标注，分数稳定在 0.65~0.68 而全部通过了阈值。
     * 根因不在阈值 —— 是 NLP 服务对"分词为空"的查询用平均向量兜底，
     * 使所有表外查询得到同一个向量、因而返回同一批文档（已在
     * {@code nlpservice/nlp/embedder.py} 的 {@code has_known_terms} 修复）。
     * 这也说明：<b>阈值只能拦"分数低"的噪声，拦不住"分数高但无意义"的退化结果</b>，
     * 后者必须在向量化源头处理。
     */
    private static final double SEMANTIC_MIN_SCORE = 0.30;

    /**
     * 何时值得做"图谱关系扩展"的第二遍检索。
     *
     * <p>第一遍 top1 低于该值时，说明字面重叠不足、绝对分被压低，
     * 此时用候选当种子接图谱关系往往能把正确答案提上来（实测 0.095 → 0.366）。
     * 若第一遍已经很自信（≥ 该值），再做一遍只是白花一次调用。
     */
    private static final double RELATION_EXPAND_BELOW = 0.30;

    /**
     * 图谱扩展时取前几个候选当种子。
     *
     * <p>候选带噪声，种子越多错误加成越可能把无关标签顶上来。保守取 3。
     */
    private static final int RELATION_SEED_LIMIT = 3;

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

        /*
         * 语义兜底（S3 · FR-M3-02 / NFR-R-03）。
         *
         * <p><b>为什么必须有这一步</b>：规则解析器只认字面命中 —— 技能名、别名、
         * 关键词出现才匹配。实测这句话"急需一位会界面设计的同学"在 788 个标签上
         * 零命中，而语义通道能给到 0.725「Figma 界面设计」、0.572「UI/UX 设计」。
         * 更糟的是图谱补全也要求"已有匹配"才触发，于是零命中时整条流水线
         * 没有任何兜底，用户看到的就是"这个功能用不了"。
         *
         * <p><b>什么时候兜底</b>：只在规则命中不足（少于 2 条）时补充。
         * 规则命中已经可靠时引入向量结果反而会稀释精度 —— 用户输入里明确提到的
         * 技能标签，不应该被"语义上有点像"的标签挤掉。
         *
         * <p><b>意图如何处置</b>：语义命中不猜意图。规则解析器能从"我会/我急需/我想学"
         * 这类线索判定 intent，而向量相似度只说明"意思相近"，无法判断用户是
         * 想教还是想学。硬塞一个 intent 会让它出现在错误的分组里，
         * 因此这里明确留空，由前端按所在步骤归属。
         */
        if (result.getMatched().size() < SEMANTIC_FALLBACK_THRESHOLD) {
            augmentWithSemantic(result, text, max);
        }

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

    /**
     * 用语义检索补充规则未命中的标签。
     *
     * <p>只做"追加"不做"重排"：规则命中的结果保持原有顺序与依据，
     * 语义结果按分数插入其后，且不覆盖已有标签。
     *
     * @param result 规则解析结果（就地修改）
     * @param text   用户输入原文
     * @param max    结果上限
     */
    private void augmentWithSemantic(ParseResultVO result, String text, int max) {
        int need = max - result.getMatched().size();
        if (need <= 0) {
            return;
        }
        SemanticMatchClient.SearchResult search;
        try {
            // topK 取 need 的 2 倍：其中一部分会与规则命中重复，需要留出余量
            search = semanticClient.search(text, Math.min(50, need * 2), "SKILL", null);
        } catch (Exception ex) {
            // 语义通道异常绝不能影响解析本身：规则结果已经可用
            log.warn("[技能解析] 语义兜底失败，保留规则结果：{}", ex.getMessage());
            return;
        }
        if (!search.available() || search.hits().isEmpty()) {
            return;
        }

        /*
         * 第二遍：借"第一遍的候选"接上图谱关系，解决字面鸿沟。
         *
         * <p><b>为什么需要两遍</b>：关系加成必须传 seedSkillIds，而解析时用户还没选任何标签，
         * 于是本体里那些为"语义鸿沟"精心建的边全都用不上。最典型的一条是
         * {@code JS 动画与交互实现 —SYNONYM→ UI/UX 设计}，其备注原文就是
         * "解决'动态交互效果'与'JS 动画库'的语义鸿沟"。
         *
         * <p>实测"我需要会做动态交互效果的同学，帮我把作品集页面做得活一点"：
         * <ul>
         *   <li>不传 seed：目标标签 0.0946，被 0.30 阈值切掉；</li>
         *   <li>以第一遍 top 候选为 seed：**0.3662**，正常入选。</li>
         * </ul>
         * 也就是说模型其实认得出，只是字面重叠太少导致绝对分低；
         * 而"该标签与用户已提及的领域存在图谱关系"是一个独立且有力的证据。
         *
         * <p>种子只取前几个高分候选：候选有噪声时，种子越多，错误加成越可能把
         * 无关标签顶上来。当前本体只有 3 条边，爆炸半径很小，但仍按保守取 3 个。
         */
        if (search.hits().size() > 0 && search.hits().get(0).score() < RELATION_EXPAND_BELOW) {
            List<Integer> seeds = search.hits().stream()
                    .limit(RELATION_SEED_LIMIT)
                    .map(SemanticMatchClient.Hit::skillId)
                    .filter(java.util.Objects::nonNull)
                    .distinct()
                    .collect(Collectors.toList());
            if (!seeds.isEmpty()) {
                try {
                    SemanticMatchClient.SearchResult expanded =
                            semanticClient.search(text, Math.min(50, need * 2), "SKILL", seeds);
                    // 只在确实带来更高分时才采用，避免"图谱加成反而降低召回"
                    if (expanded.available() && !expanded.hits().isEmpty()
                            && expanded.hits().get(0).score() > search.hits().get(0).score()) {
                        log.debug("[技能解析] 图谱关系扩展生效：{} -> {}（seeds={}）",
                                search.hits().get(0).score(), expanded.hits().get(0).score(), seeds);
                        search = expanded;
                    }
                } catch (Exception ex) {
                    log.warn("[技能解析] 图谱关系扩展失败，沿用原结果：{}", ex.getMessage());
                }
            }
        }

        Set<Long> existing = result.getMatched().stream()
                .map(SkillMatchVO::getSkillId)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toCollection(LinkedHashSet::new));

        // 批量取标签，避免逐条查询（Hit.skillId() 是 Integer，统一转 Long）
        List<Long> ids = search.hits().stream()
                .map(SemanticMatchClient.Hit::skillId)
                .filter(java.util.Objects::nonNull)
                .map(Integer::longValue)
                .filter(id -> !existing.contains(id))
                .distinct()
                .collect(Collectors.toList());
        if (ids.isEmpty()) {
            return;
        }
        Map<Long, Skill> skills = skillMapper.selectBriefByIds(ids).stream()
                .collect(Collectors.toMap(Skill::getId, s -> s, (a, b) -> a, LinkedHashMap::new));

        int added = 0;
        // 记录被阈值挡掉的最高分：用于区分"完全没信号"与"有点接近但不够"，给出不同提示
        double bestRejected = 0;
        for (SemanticMatchClient.Hit hit : search.hits()) {
            if (added >= need) {
                break;
            }
            Integer rawId = hit.skillId();
            if (rawId == null) {
                continue;
            }
            Long id = rawId.longValue();
            Skill skill = skills.get(id);
            if (skill == null || existing.contains(id)) {
                continue;
            }
            /*
             * 阈值过滤：余弦相似度天然偏低，不设下限会把明显无关的标签也带进来。
             * 0.15 是实测出来的下限 —— "求带机器学习"命中 0.897、
             * "急需界面设计"命中 0.725，而噪声通常在 0.05 以下。
             *
             * 注意不要为了"让某个样例能解析出来"而压低这个值：
             * 阈值调低会把噪声带进**所有**输入，是典型的过拟合单个测试用例。
             * 灰色区间（有信号但不够强）的正确处置是给用户可操作的提示，
             * 见下方 hint 的分级文案。
             */
            double score = hit.score();
            if (score < SEMANTIC_MIN_SCORE) {
                bestRejected = Math.max(bestRejected, score);
                continue;
            }
            String reason = hit.relationBoost() > 0
                    ? "语义相近（" + Math.round(score * 100) + "%），并命中已有标签的图谱邻居"
                    : "语义相近（" + Math.round(score * 100) + "%）：字面未命中，但表达的意思与「"
                    + skill.getName() + "」最接近";
            result.getMatched().add(SkillMatchVO.of(
                    SkillVO.of(skill), null, score, SkillMatchVO.MatchType.SEMANTIC, reason));
            existing.add(id);
            added++;
        }

        if (added == 0) {
            /*
             * 一条都没补上时，hint 必须能区分两种情况 —— 否则用户看到的是
             * 一模一样的"未匹配到"，却不知道自己是"说得太笼统"还是"平台确实没有这个标签"。
             */
            if (bestRejected > 0) {
                result.setHint("你的描述与平台标签只有 " + Math.round(bestRejected * 100)
                        + "% 接近，还不够明确。试着直接写出技能名称或常见叫法"
                        + "（例如把「做动态交互效果」写成「JS 动画」），也可以在下方手工挑选标签。");
            } else {
                result.setHint("没有找到与这段描述相近的技能标签。可以换成更具体的技能名称，"
                        + "或在下方按学科门类手工挑选。");
            }
            return;
        }

        if (added > 0) {
            /*
             * 如实标注引擎：结果里含向量召回，就不该再自称 RULE_LEXICON。
             * 前端与验收方据此判断"这次解析用到了语义能力"。
             */
            result.setEngine(result.getEngine() + "+SEMANTIC");
            result.setDegraded(false);
            log.debug("[技能解析] 语义兜底补充 {} 个标签（通道={}，耗时 {}ms）",
                    added, search.channel(), search.tookMs());
        }
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
