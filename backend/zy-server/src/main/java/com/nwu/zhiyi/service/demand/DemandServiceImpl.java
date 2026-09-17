package com.nwu.zhiyi.service.demand;

import cn.hutool.core.util.RandomUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.demand.DemandCreateRequest;
import com.nwu.zhiyi.api.dto.demand.DemandInterestVO;
import com.nwu.zhiyi.api.dto.demand.DemandQuery;
import com.nwu.zhiyi.api.dto.demand.DemandUpdateRequest;
import com.nwu.zhiyi.api.dto.demand.MarketCardVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.api.PageResult;
import com.nwu.zhiyi.common.enums.AuditStatus;
import com.nwu.zhiyi.common.enums.DemandInterestStatus;
import com.nwu.zhiyi.common.enums.DemandStatus;
import com.nwu.zhiyi.common.enums.DemandVisibility;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.DemandInterest;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.DemandInterestMapper;
import com.nwu.zhiyi.domain.mapper.DemandMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 供需集市服务实现。
 *
 * <p><b>排序策略</b>（FR-M4-02 / FR-M4-03）：
 * <ul>
 *   <li>{@code MATCH}（默认）—— 在候选集上计算匹配度后排序，并把 ≥0.75 的高匹配卡片置顶。
 *       由于匹配度依赖用户画像，无法在 SQL 内完成，因此采用"SQL 粗筛 + 内存精排"：
 *       先用数据库过滤条件把候选集压到 {@link #MAX_MATCH_CANDIDATES} 以内，再算分排序。
 *       标签规模上千后仍能保持列表响应时间（NFR-P-02）。</li>
 *   <li>{@code LATEST} —— 纯 SQL 排序，可承载全量数据</li>
 *   <li>{@code HOT} —— 按邀约数/浏览数排序</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DemandServiceImpl implements DemandService {

    private final DemandMapper demandMapper;
    private final DemandInterestMapper interestMapper;
    private final SkillMapper skillMapper;
    private final StudentMapper studentMapper;
    private final DemandCardAssembler assembler;
    private final DemandContentAuditor auditor;

    /** 匹配度精排时的最大候选集（防止全表载入内存） */
    private static final int MAX_MATCH_CANDIDATES = 300;

    /** 分页上限 */
    private static final int MAX_PAGE_SIZE = 50;

    /** 单用户最多同时持有的待响应邀约数（防刷单，FR-M4-07） */
    private static final int MAX_PENDING_INTERESTS = 10;

    private static final DateTimeFormatter NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");

    /* ==================== 发布 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MarketCardVO create(String ownerSno, DemandCreateRequest request) {
        Skill expected = requireSkill(request.getExpectedSkillId(), "期望技能");
        Skill offer = request.getOfferSkillId() == null ? null
                : requireSkill(request.getOfferSkillId(), "回馈技能");

        if (offer != null && offer.getId().equals(expected.getId())) {
            throw new BusinessException(ErrorCode.EXCHANGE_SKILL_REQUIRED,
                    "期望技能与回馈技能不能相同，否则不构成「以技易技」");
        }

        DemandVisibility visibility = parseVisibility(request.getVisibility());

        // 内容审核（FR-M4-07）
        DemandContentAuditor.Result audit = auditor.audit(request.getTitle(), request.getDescription());
        if (audit.status() == AuditStatus.REJECTED) {
            throw new BusinessException(ErrorCode.DEMAND_CONTENT_REJECTED, audit.remark());
        }

        Demand demand = new Demand()
                .setDemandNo(generateDemandNo())
                .setOwnerSno(ownerSno)
                .setTitle(request.getTitle().trim())
                .setDescription(trimToNull(request.getDescription()))
                .setExpectedSkillId(expected.getId())
                .setOfferSkillId(offer == null ? null : offer.getId())
                .setExpectedHours(request.getExpectedHours())
                .setExpectedPeriod(trimToNull(request.getExpectedPeriod()))
                .setVisibility(visibility)
                .setStatus(DemandStatus.OPEN)
                .setMatchCount(0)
                .setViewCount(0)
                .setAuditStatus(audit.status())
                .setAuditRemark(audit.remark())
                .setExpireAt(parseDateTime(request.getExpireAt()));
        demandMapper.insert(demand);

        log.info("[需求发布] no={} owner={} 期望={} 回馈={} 审核={}",
                demand.getDemandNo(), ownerSno, expected.getName(),
                offer == null ? "-" : offer.getName(), audit.status());

        return assembler.assembleOne(demand, ownerSno, false);
    }

    /* ==================== 信息流 ==================== */

    @Override
    public PageResult<MarketCardVO> feed(String viewerSno, DemandQuery query) {
        DemandQuery q = query == null ? new DemandQuery() : query;
        long page = Math.max(1, q.getPage() == null ? 1 : q.getPage());
        long size = Math.min(MAX_PAGE_SIZE, Math.max(1, q.getSize() == null ? 10 : q.getSize()));
        String sort = StringUtils.hasText(q.getSort()) ? q.getSort().toUpperCase() : "MATCH";

        LambdaQueryWrapper<Demand> wrapper = new LambdaQueryWrapper<>();

        // 状态：默认只看招募中
        if (StringUtils.hasText(q.getStatus())) {
            wrapper.eq(Demand::getStatus, parseStatus(q.getStatus()));
        } else {
            wrapper.eq(Demand::getStatus, DemandStatus.OPEN);
        }
        // 只展示审核通过的卡片（待复核/驳回不进公开信息流）
        wrapper.eq(Demand::getAuditStatus, AuditStatus.PASSED);

        if (Boolean.TRUE.equals(q.getMine())) {
            if (viewerSno == null) {
                return PageResult.empty(page, size);
            }
            wrapper.eq(Demand::getOwnerSno, viewerSno);
        }
        if (StringUtils.hasText(q.getVisibility())) {
            wrapper.eq(Demand::getVisibility, parseVisibility(q.getVisibility()));
        }
        if (q.getSkillId() != null) {
            wrapper.eq(Demand::getExpectedSkillId, q.getSkillId());
        }

        // 学科门类：先查出该门类下的技能 ID，再过滤（避免 join）
        if (StringUtils.hasText(q.getCategoryL1())) {
            List<Long> skillIds = skillMapper.selectList(new LambdaQueryWrapper<Skill>()
                            .eq(Skill::getCategoryL1, q.getCategoryL1().trim()))
                    .stream().map(Skill::getId).collect(Collectors.toList());
            if (skillIds.isEmpty()) {
                return PageResult.empty(page, size);
            }
            wrapper.in(Demand::getExpectedSkillId, skillIds);
        }

        // 关键词：命中标题/描述，或命中技能名（先解析出技能 ID）
        if (StringUtils.hasText(q.getKeyword())) {
            String kw = q.getKeyword().trim();
            List<Long> skillIds = skillMapper.selectList(new LambdaQueryWrapper<Skill>()
                            .like(Skill::getName, kw).or().like(Skill::getAlias, kw))
                    .stream().map(Skill::getId).collect(Collectors.toList());
            wrapper.and(w -> {
                w.like(Demand::getTitle, kw).or().like(Demand::getDescription, kw);
                if (!skillIds.isEmpty()) {
                    w.or().in(Demand::getExpectedSkillId, skillIds);
                }
            });
        }

        // 排序与取数
        if ("LATEST".equals(sort)) {
            wrapper.orderByDesc(Demand::getCreatedAt);
            return pageFromDb(wrapper, viewerSno, page, size);
        }
        if ("HOT".equals(sort)) {
            wrapper.orderByDesc(Demand::getMatchCount).orderByDesc(Demand::getViewCount)
                    .orderByDesc(Demand::getCreatedAt);
            return pageFromDb(wrapper, viewerSno, page, size);
        }

        // MATCH：粗筛后内存精排
        wrapper.orderByDesc(Demand::getCreatedAt).last("LIMIT " + MAX_MATCH_CANDIDATES);
        List<Demand> candidates = demandMapper.selectList(wrapper);
        if (candidates.isEmpty()) {
            return PageResult.empty(page, size);
        }

        List<MarketCardVO> cards = assembler.assemble(candidates, viewerSno, false);
        // 过滤掉不可见的（COLLEGE / PRIVATE 范围）
        cards = cards.stream().filter(c -> {
            Demand d = candidates.stream().filter(x -> x.getId().equals(c.getId())).findFirst().orElse(null);
            return d != null && assembler.visibleTo(d, viewerSno);
        }).collect(Collectors.toList());

        if (Boolean.TRUE.equals(q.getOnlyHighMatch())) {
            cards = cards.stream().filter(c -> Boolean.TRUE.equals(c.getHighMatch()))
                    .collect(Collectors.toList());
        }

        // 高匹配优先，其次匹配度，最后时效（新的在前）
        cards.sort(Comparator
                .comparing((MarketCardVO c) -> Boolean.TRUE.equals(c.getHighMatch()) ? 0 : 1)
                .thenComparing(c -> -(c.getMatchScore() == null ? 0 : c.getMatchScore()))
                .thenComparing(MarketCardVO::getCreatedAt,
                        Comparator.nullsLast(Comparator.reverseOrder())));

        long total = cards.size();
        int from = (int) Math.min((page - 1) * size, total);
        int to = (int) Math.min(from + size, total);
        return PageResult.of(new ArrayList<>(cards.subList(from, to)), total, page, size);
    }

    @Override
    public MarketCardVO detail(Long demandId, String viewerSno) {
        Demand demand = demandMapper.selectById(demandId);
        if (demand == null) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_FOUND);
        }
        if (!assembler.visibleTo(demand, viewerSno)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "该需求卡片未对你开放");
        }
        // 浏览次数用原子自增，避免读-改-写丢更新
        demandMapper.incrementViewCount(demandId);
        return assembler.assembleOne(demand, viewerSno, true);
    }

    /* ==================== 修改与关闭 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MarketCardVO update(Long demandId, String operator, DemandUpdateRequest request) {
        Demand demand = requireOwnedDemand(demandId, operator);
        if (demand.getStatus() == DemandStatus.CLOSED) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_OPEN, "已关闭的卡片不可修改");
        }

        Demand update = new Demand().setId(demandId);
        if (StringUtils.hasText(request.getTitle())) {
            update.setTitle(request.getTitle().trim());
        }
        if (request.getDescription() != null) {
            update.setDescription(trimToNull(request.getDescription()));
        }
        if (request.getOfferSkillId() != null) {
            Skill offer = requireSkill(request.getOfferSkillId(), "回馈技能");
            if (offer.getId().equals(demand.getExpectedSkillId())) {
                throw new BusinessException(ErrorCode.EXCHANGE_SKILL_REQUIRED);
            }
            update.setOfferSkillId(offer.getId());
        }
        if (request.getExpectedHours() != null) {
            update.setExpectedHours(request.getExpectedHours());
        }
        if (request.getExpectedPeriod() != null) {
            update.setExpectedPeriod(trimToNull(request.getExpectedPeriod()));
        }
        if (StringUtils.hasText(request.getVisibility())) {
            update.setVisibility(parseVisibility(request.getVisibility()));
        }

        // 标题或详述变更时重新审核
        if (StringUtils.hasText(request.getTitle()) || request.getDescription() != null) {
            String title = StringUtils.hasText(request.getTitle()) ? request.getTitle() : demand.getTitle();
            String desc = request.getDescription() != null ? request.getDescription() : demand.getDescription();
            DemandContentAuditor.Result audit = auditor.audit(title, desc);
            if (audit.status() == AuditStatus.REJECTED) {
                throw new BusinessException(ErrorCode.DEMAND_CONTENT_REJECTED, audit.remark());
            }
            update.setAuditStatus(audit.status()).setAuditRemark(audit.remark());
        }

        demandMapper.updateById(update);
        log.info("[需求修改] id={} operator={}", demandId, operator);
        return assembler.assembleOne(demandMapper.selectById(demandId), operator, true);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void close(Long demandId, String operator) {
        requireOwnedDemand(demandId, operator);
        demandMapper.updateById(new Demand().setId(demandId).setStatus(DemandStatus.CLOSED));
        log.info("[需求关闭] id={} operator={}", demandId, operator);
    }

    /* ==================== 查询 ==================== */

    @Override
    public List<MarketCardVO> myDemands(String ownerSno) {
        List<Demand> list = demandMapper.selectList(new LambdaQueryWrapper<Demand>()
                .eq(Demand::getOwnerSno, ownerSno)
                .orderByDesc(Demand::getCreatedAt));
        return assembler.assemble(list, ownerSno, true);
    }

    @Override
    public List<DemandInterestVO> receivedInterests(String ownerSno) {
        // 先取我发布的卡片，再取这些卡片上收到的意向
        List<Long> demandIds = demandMapper.selectList(new LambdaQueryWrapper<Demand>()
                        .select(Demand::getId).eq(Demand::getOwnerSno, ownerSno))
                .stream().map(Demand::getId).collect(Collectors.toList());
        if (demandIds.isEmpty()) {
            return List.of();
        }
        List<DemandInterest> interests = interestMapper.selectList(new LambdaQueryWrapper<DemandInterest>()
                .in(DemandInterest::getDemandId, demandIds)
                .orderByDesc(DemandInterest::getCreatedAt));
        List<DemandInterestVO> vos = assembler.assembleInterests(interests, ownerSno);

        // 补齐所在卡片标题与编号，便于前端直接渲染
        Map<Long, Demand> demandMap = demandMapper.selectList(
                        new LambdaQueryWrapper<Demand>().in(Demand::getId, demandIds)).stream()
                .collect(Collectors.toMap(Demand::getId, d -> d, (a, b) -> a));
        vos.forEach(v -> {
            Demand d = demandMap.get(v.getDemandId());
            if (d != null) {
                v.setDemandTitle(d.getTitle());
                v.setDemandNo(d.getDemandNo());
            }
        });
        return vos;
    }

    @Override
    public List<DemandInterestVO> sentInterests(String applicantSno) {
        List<DemandInterest> interests = interestMapper.selectList(new LambdaQueryWrapper<DemandInterest>()
                .eq(DemandInterest::getApplicantSno, applicantSno)
                .orderByDesc(DemandInterest::getCreatedAt));
        List<DemandInterestVO> vos = assembler.assembleInterests(interests, applicantSno);

        // 补齐我申请的目标卡片标题。
        // 刻意使用 selectIncludingDeletedByIds：卡片被发布人删除后，历史邀约仍应
        // 能看到当时的卡片信息，否则前端会显示空标题（踩过的坑）。
        Set<Long> demandIds = interests.stream().map(DemandInterest::getDemandId)
                .collect(Collectors.toCollection(LinkedHashSet::new));
        if (!demandIds.isEmpty()) {
            Map<Long, Demand> demandMap = demandMapper.selectIncludingDeletedByIds(demandIds).stream()
                    .collect(Collectors.toMap(Demand::getId, d -> d, (a, b) -> a));
            vos.forEach(v -> {
                Demand d = demandMap.get(v.getDemandId());
                if (d != null) {
                    v.setDemandTitle(d.getTitle());
                    v.setDemandNo(d.getDemandNo());
                } else {
                    v.setDemandTitle("（该需求卡片已被发布人移除）");
                }
            });
        }
        return vos;
    }

    /* ==================== 供交换服务调用的内部方法 ==================== */

    /**
     * 取卡片并校验可发起交换（供 {@code ExchangeService} 调用）。
     *
     * @param demandId 卡片 ID
     * @param applicantSno 申请人
     * @return 卡片
     */
    @Override
    public Demand requireApplicable(Long demandId, String applicantSno) {
        Demand demand = demandMapper.selectById(demandId);
        if (demand == null) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_FOUND);
        }
        if (demand.isOwnedBy(applicantSno)) {
            throw new BusinessException(ErrorCode.DEMAND_OWNER_CANNOT_APPLY);
        }
        if (!demand.isAvailable()) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_OPEN);
        }
        if (demand.isExpired()) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_OPEN, "该需求已过期");
        }
        if (!assembler.visibleTo(demand, applicantSno)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "该需求卡片未对你开放");
        }
        return demand;
    }

    /**
     * 校验待响应邀约数量上限（防刷单，FR-M4-07）。
     *
     * @param applicantSno 申请人
     */
    @Override
    public void checkPendingInterestLimit(String applicantSno) {
        int pending = interestMapper.countPendingByApplicant(applicantSno);
        if (pending >= MAX_PENDING_INTERESTS) {
            throw new BusinessException(ErrorCode.PENDING_INTEREST_LIMIT,
                    String.format("你已有 %d 条待响应邀约，上限 %d 条", pending, MAX_PENDING_INTERESTS));
        }
    }

    /**
     * 标记卡片为已匹配（交换进入进行中时调用）。
     *
     * @param demandId 卡片 ID
     */
    @Override
    public void markMatched(Long demandId) {
        if (demandId == null) {
            return;
        }
        demandMapper.updateById(new Demand().setId(demandId).setStatus(DemandStatus.MATCHED));
    }

    /**
     * 递增卡片的邀约数。
     *
     * @param demandId 卡片 ID
     */
    @Override
    public void incrementMatchCount(Long demandId) {
        demandMapper.incrementMatchCount(demandId);
    }

    /* ==================== 私有工具 ==================== */

    private PageResult<MarketCardVO> pageFromDb(LambdaQueryWrapper<Demand> wrapper, String viewerSno,
                                                long page, long size) {
        Long total = demandMapper.selectCount(wrapper);
        long t = total == null ? 0 : total;
        if (t == 0) {
            return PageResult.empty(page, size);
        }
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<Demand> list = demandMapper.selectList(wrapper);
        list = list.stream().filter(d -> assembler.visibleTo(d, viewerSno)).collect(Collectors.toList());
        return PageResult.of(assembler.assemble(list, viewerSno, false), t, page, size);
    }

    private Demand requireOwnedDemand(Long demandId, String operator) {
        Demand demand = demandMapper.selectById(demandId);
        if (demand == null) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_FOUND);
        }
        if (!demand.isOwnedBy(operator)) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_OWNER);
        }
        return demand;
    }

    private Skill requireSkill(Long skillId, String label) {
        if (skillId == null) {
            throw new BusinessException(ErrorCode.SKILL_NOT_FOUND, label + "不能为空");
        }
        Skill skill = skillMapper.selectById(skillId);
        if (skill == null) {
            throw new BusinessException(ErrorCode.SKILL_NOT_FOUND, label + "不存在：" + skillId);
        }
        if (skill.getStatus() != null && skill.getStatus() == 0) {
            throw new BusinessException(ErrorCode.SKILL_NOT_FOUND, label + "已停用：" + skill.getName());
        }
        return skill;
    }

    private DemandVisibility parseVisibility(String value) {
        if (!StringUtils.hasText(value)) {
            return DemandVisibility.PUBLIC;
        }
        try {
            return DemandVisibility.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw BusinessException.paramInvalid("可见范围不合法，应为 PUBLIC / COLLEGE / PRIVATE");
        }
    }

    private DemandStatus parseStatus(String value) {
        try {
            return DemandStatus.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw BusinessException.paramInvalid("状态不合法，应为 OPEN / MATCHED / CLOSED");
        }
    }

    private LocalDateTime parseDateTime(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        try {
            return LocalDateTime.parse(value.trim().replace(' ', 'T'));
        } catch (Exception e) {
            throw BusinessException.paramInvalid("时间格式不正确，应为 yyyy-MM-dd HH:mm:ss");
        }
    }

    /** 生成业务编号：DM + yyyyMMdd + 4 位随机（唯一索引兜底） */
    private String generateDemandNo() {
        return "DM" + LocalDateTime.now().format(NO_FORMATTER) + RandomUtil.randomNumbers(4);
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String t = value.trim();
        return t.isEmpty() ? null : t;
    }

    /** 供控制器暴露给前端：当前用户可见的状态说明 */
    public static List<String> interestStatusLabels() {
        return java.util.Arrays.stream(DemandInterestStatus.values())
                .map(Enum::name).collect(Collectors.toList());
    }
}
