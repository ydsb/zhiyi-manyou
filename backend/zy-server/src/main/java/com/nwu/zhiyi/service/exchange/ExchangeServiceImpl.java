package com.nwu.zhiyi.service.exchange;

import com.nwu.zhiyi.security.RequireVerified;
import cn.hutool.core.util.RandomUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.exchange.ExchangeApplyRequest;
import com.nwu.zhiyi.api.dto.exchange.ExchangeVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.DemandInterestStatus;
import com.nwu.zhiyi.common.enums.DemandStatus;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.DemandInterest;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.DemandInterestMapper;
import com.nwu.zhiyi.domain.mapper.DemandMapper;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.collab.WorkspaceService;
import com.nwu.zhiyi.service.demand.DemandService;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 技能交换服务实现。
 *
 * <p><b>技能归属约定（务必对齐，容易搞反）</b>：
 * <pre>
 *   giver（供给方 = 申请人） 提供 demand.expectedSkillId  → exchange.giveSkillId
 *   taker（需求方 = 卡片发布人）提供 demand.offerSkillId   → exchange.learnSkillId
 * </pre>
 * 即 {@code giveSkillId} 是"被学习"的技能、{@code learnSkillId} 是"作为回报"的技能，
 * 二者共同构成 FR-M4-06 的「以技易技」双向置换。
 *
 * <p><b>配额规则</b>（FR-M4-09）：进入 {@code NEGOTIATING} 与 {@code IN_PROGRESS}
 * 状态的交换占用并发配额，上限取用户 {@code exchangeQuota}（默认 5）。
 * 这样"networking 中的邀约"也会占用配额，可有效抑制批量刷邀约的行为。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ExchangeServiceImpl implements ExchangeService {

    private final ExchangeRecordMapper exchangeMapper;
    private final DemandMapper demandMapper;
    private final DemandInterestMapper interestMapper;
    private final SkillMapper skillMapper;
    private final StudentMapper studentMapper;
    private final EvaluationGradeMapper evaluationMapper;
    private final DemandService demandService;
    private final WorkspaceService workspaceService;
    private final NotificationService notificationService;

    private static final DateTimeFormatter NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");

    /* ==================== 发起邀约 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    @RequireVerified
    public Map<String, Object> apply(String applicantSno, ExchangeApplyRequest request) {
        // 1. 卡片校验（存在、开放、非本人发布、可见）
        Demand demand = demandService.requireApplicable(request.getDemandId(), applicantSno);

        // 2. 重复申请校验（唯一索引兜底，这里给出友好提示）
        Long dup = interestMapper.selectCount(new LambdaQueryWrapper<DemandInterest>()
                .eq(DemandInterest::getDemandId, demand.getId())
                .eq(DemandInterest::getApplicantSno, applicantSno));
        if (dup != null && dup > 0) {
            throw new BusinessException(ErrorCode.INTEREST_ALREADY_EXISTS);
        }

        // 3. 待响应邀约数量上限（防刷单，FR-M4-07）
        demandService.checkPendingInterestLimit(applicantSno);

        // 4. 并发交换配额（FR-M4-09）
        checkExchangeQuota(applicantSno);
        checkExchangeQuota(demand.getOwnerSno());

        // 5. 创建交换记录（初始状态：洽谈中）
        ExchangeRecord record = new ExchangeRecord()
                .setRecordNo(generateRecordNo())
                .setGiverSno(applicantSno)
                .setTakerSno(demand.getOwnerSno())
                .setGiveSkillId(demand.getExpectedSkillId())
                .setLearnSkillId(demand.getOfferSkillId())
                .setTitle(demand.getTitle())
                .setDescription(demand.getDescription())
                .setStatus(ExchangeStatus.PUBLISHED)
                .setSourceDemandId(demand.getId())
                .setExpectedHours(demand.getExpectedHours())
                .setDeadlineAt(parseDateTime(request.getDeadlineAt()));
        // 用状态机的流转方法进入洽谈中，保证时间戳等副作用一致
        record.transferTo(ExchangeStatus.NEGOTIATING);
        exchangeMapper.insert(record);

        // 6. 登记意向
        DemandInterest interest = new DemandInterest()
                .setDemandId(demand.getId())
                .setApplicantSno(applicantSno)
                .setRecordId(record.getId())
                .setStatus(DemandInterestStatus.PENDING)
                .setMessage(trimToNull(request.getMessage()));
        try {
            interestMapper.insert(interest);
        } catch (DuplicateKeyException e) {
            // 并发请求可能同时通过预检查，唯一索引是最终防线。
            throw new BusinessException(ErrorCode.INTEREST_ALREADY_EXISTS);
        }

        // 7. 卡片邀约数 +1
        demandService.incrementMatchCount(demand.getId());

        // 8. 通知卡片发布人（FR-M5-05）
        notificationService.sendOnce(demand.getOwnerSno(), NotificationType.INVITE,
                "收到新的交换邀约",
                String.format("%s 对你的需求「%s」发起了交换，请到「我的交换」处理",
                        displayName(applicantSno), demand.getTitle()),
                "INTEREST", interest.getId());

        log.info("[交换邀约] record={} demand={} giver={} taker={} 提供技能={} 回馈技能={}",
                record.getRecordNo(), demand.getDemandNo(), applicantSno, demand.getOwnerSno(),
                record.getGiveSkillId(), record.getLearnSkillId());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("interestId", interest.getId());
        result.put("recordId", record.getId());
        result.put("recordNo", record.getRecordNo());
        result.put("status", record.getStatus().name());
        result.put("message", "邀约已发送，等待对方响应");
        return result;
    }

    /* ==================== 响应邀约 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> respond(String operator, Long interestId, boolean accept, String reason) {
        DemandInterest interest = interestMapper.selectById(interestId);
        if (interest == null) {
            throw new BusinessException(ErrorCode.INTEREST_NOT_FOUND);
        }
        if (!interest.isPending()) {
            throw new BusinessException(ErrorCode.INTEREST_NOT_PENDING,
                    "该邀约当前状态为「" + interest.getStatus().getLabel() + "」");
        }
        Demand demand = demandMapper.selectById(interest.getDemandId());
        if (demand == null) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_FOUND);
        }
        if (!demand.isOwnedBy(operator)) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_OWNER);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("interestId", interestId);
        result.put("accepted", accept);

        if (!accept) {
            if (interestMapper.rejectIfPending(interestId) != 1) {
                throw stateConflict("邀约已被其他请求处理");
            }
            ExchangeRecord record = interest.getRecordId() == null ? null
                    : exchangeMapper.selectById(interest.getRecordId());
            if (record == null) {
                throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND,
                        "邀约关联的交换记录不存在");
            }
            if (record.getStatus() != ExchangeStatus.NEGOTIATING) {
                throw stateConflict("交换记录已被其他请求处理");
            }
            transitionRecordCas(record, ExchangeStatus.CANCELLED, null, operator);

            notificationService.sendOnce(interest.getApplicantSno(), NotificationType.INVITE_RESULT,
                    "交换邀约被拒绝",
                    StringUtils.hasText(reason) ? ("对方拒绝了你的邀约：" + reason) : "对方拒绝了你的邀约",
                    "INTEREST", interestId);
            result.put("message", StringUtils.hasText(reason) ? ("已拒绝：" + reason) : "已拒绝该邀约");
            log.info("[邀约拒绝] interest={} by={} reason={}", interestId, operator, reason);
            return result;
        }

        ExchangeRecord record = interest.getRecordId() == null ? null
                : exchangeMapper.selectById(interest.getRecordId());
        if (record == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND, "邀约关联的交换记录不存在");
        }
        if (record.getStatus() != ExchangeStatus.NEGOTIATING) {
            throw stateConflict(String.format("该交换当前状态为「%s」，无法接受邀约",
                    record.getStatus() == null ? "未知" : record.getStatus().getLabel()));
        }

        // 需求 OPEN → MATCHED 是接受操作的全局唯一闸门：
        // 两个用户并发接受同一张卡片时，只有一个请求能拿到影响行数 1。
        if (demandMapper.markMatchedIfOpen(demand.getId()) != 1) {
            throw stateConflict("该需求已被其他人接受或已关闭");
        }
        if (interestMapper.acceptIfPending(interestId) != 1) {
            throw stateConflict("该邀约已被其他请求处理");
        }

        // 先取出其他待响应邀约，再推进当前交换。
        List<DemandInterest> others = interestMapper.selectList(new LambdaQueryWrapper<DemandInterest>()
                .eq(DemandInterest::getDemandId, demand.getId())
                .eq(DemandInterest::getStatus, DemandInterestStatus.PENDING)
                .ne(DemandInterest::getId, interestId));

        transitionRecordCas(record, ExchangeStatus.IN_PROGRESS, null, operator);

        interestMapper.rejectOtherPending(demand.getId(), interestId);
        for (DemandInterest other : others) {
            if (other.getRecordId() != null) {
                ExchangeRecord otherRecord = exchangeMapper.selectById(other.getRecordId());
                if (otherRecord != null && otherRecord.getStatus() == ExchangeStatus.NEGOTIATING) {
                    cancelNegotiatingRecord(otherRecord);
                }
            }
        }
        if (!others.isEmpty()) {
            log.info("[邀约接受] 同卡片另外 {} 条邀约已自动拒绝：demand={}", others.size(), demand.getDemandNo());
        }

        result.put("recordId", record.getId());
        result.put("recordNo", record.getRecordNo());
        result.put("status", record.getStatus().name());
        result.put("workspaceReady", true);
        result.put("message", "已接受邀约，协作空间已生成");

        workspaceService.recordEvent(record.getId(), operator,
                com.nwu.zhiyi.domain.entity.CollabEvent.TYPE_EXCHANGE_START,
                "交换正式开始",
                String.format("%s 与 %s 达成交换，协作空间开启",
                        displayName(record.getGiverSno()), displayName(record.getTakerSno())),
                "EXCHANGE", record.getId());
        notificationService.sendOnce(record.getGiverSno(), NotificationType.INVITE_RESULT,
                "邀约已被接受",
                "对方接受了你的交换邀约，协作空间已开启，可以开始拆解任务了",
                "EXCHANGE", record.getId());

        log.info("[邀约接受] record={} 进入进行中，giver={} taker={}",
                record.getRecordNo(), record.getGiverSno(), record.getTakerSno());
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void withdraw(String applicantSno, Long interestId) {
        DemandInterest interest = interestMapper.selectById(interestId);
        if (interest == null) {
            throw new BusinessException(ErrorCode.INTEREST_NOT_FOUND);
        }
        if (!applicantSno.equals(interest.getApplicantSno())) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "只能撤回自己发起的邀约");
        }
        if (!interest.isPending()) {
            throw new BusinessException(ErrorCode.INTEREST_NOT_PENDING);
        }
        if (interestMapper.withdrawIfPending(interestId, applicantSno) != 1) {
            throw stateConflict("该邀约已被其他请求处理");
        }
        if (interest.getRecordId() != null) {
            ExchangeRecord record = exchangeMapper.selectById(interest.getRecordId());
            if (record != null) {
                if (record.getStatus() != ExchangeStatus.NEGOTIATING) {
                    throw stateConflict("交换记录已被其他请求处理");
                }
                transitionRecordCas(record, ExchangeStatus.CANCELLED, null, applicantSno);
            }
        }
        log.info("[邀约撤回] interest={} by={}", interestId, applicantSno);
    }

    /* ==================== 状态流转 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ExchangeVO changeStatus(String operator, Long recordId, String targetStatus, Double actualHours) {
        ExchangeRecord record = requireRecord(recordId);
        if (!record.isParticipant(operator)) {
            throw new BusinessException(ErrorCode.NOT_PARTICIPANT);
        }
        ExchangeStatus target = parseTargetStatus(targetStatus);

        /*
         * 公开状态接口只承载“进行中 → 待互评”等参与者操作。
         * IN_PROGRESS 必须由接受邀约统一完成兴趣、需求和交换三方联动；
         * COMPLETED 必须由双方互评流程触发；DISPUTED 必须由治理流程创建案件后触发。
         * 否则 changeStatus 会成为绕过业务前置条件的后门。
         */
        if (target == ExchangeStatus.IN_PROGRESS) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL,
                    "请通过接受交换邀约进入进行中状态");
        }
        if (target == ExchangeStatus.COMPLETED) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL,
                    "双方互评完成后由系统自动完成交换");
        }
        if (target == ExchangeStatus.DISPUTED) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL,
                    "请通过争议治理流程发起争议");
        }
        if (target != ExchangeStatus.PENDING_EVAL && target != ExchangeStatus.CANCELLED) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL,
                    "该状态只能由对应业务流程自动推进");
        }
        if (target == ExchangeStatus.CANCELLED && record.getStatus() != ExchangeStatus.IN_PROGRESS) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL,
                    "洽谈中的邀约请通过拒绝或撤回处理");
        }
        if (actualHours != null && target != ExchangeStatus.PENDING_EVAL) {
            throw BusinessException.paramInvalid("只有进入待互评时才能填写实际投入时长");
        }
        return applyTransition(record, target, actualHours, operator);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ExchangeVO completeAfterEvaluation(String operator, Long recordId) {
        ExchangeRecord record = requireRecord(recordId);
        if (!record.isParticipant(operator)) {
            throw new BusinessException(ErrorCode.NOT_PARTICIPANT);
        }
        if (record.getStatus() != ExchangeStatus.PENDING_EVAL) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL,
                    "只有待互评状态才能由互评流程完成交换");
        }
        if (evaluationMapper.countByRecord(recordId) < 2) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL,
                    "双方评价尚未全部提交，不能完成交换");
        }
        return applyTransition(record, ExchangeStatus.COMPLETED, null, operator);
    }

    private ExchangeVO applyTransition(ExchangeRecord record, ExchangeStatus target,
                                       Double actualHours, String operator) {
        Long recordId = record.getId();
        ExchangeStatus previous = record.getStatus();
        transitionRecordCas(record, target, actualHours, operator);

        workspaceService.recordEvent(recordId, operator,
                com.nwu.zhiyi.domain.entity.CollabEvent.TYPE_STATUS_CHANGE,
                String.format("交换状态变更：%s → %s", label(previous), target.getLabel()),
                actualHours == null ? null : ("实际投入 " + actualHours + " 小时"),
                "EXCHANGE", recordId);

        if (target == ExchangeStatus.PENDING_EVAL) {
            notificationService.sendToExchangeParties(recordId, null, NotificationType.EVAL_REMIND,
                    "交换已进入待互评",
                    "请到「我的交换」完成双向互评，评价提交后将生成不可篡改的存证记录");
        }

        log.info("[交换流转] record={} {} → {} by={}", record.getRecordNo(),
                label(previous), target.getLabel(), operator);
        return detail(recordId, operator);
    }

    /**
     * 内存状态机校验 + 数据库状态 CAS。affected=0 说明读取后状态已被其他事务修改。
     */
    private void transitionRecordCas(ExchangeRecord record, ExchangeStatus target,
                                     Double actualHours, String operator) {
        Long recordId = record.getId();
        ExchangeStatus previous = record.getStatus();
        record.transferTo(target);
        if (actualHours != null) {
            record.setActualHours(BigDecimal.valueOf(actualHours));
        }
        int affected = exchangeMapper.updateStatusCas(
                recordId, previous.name(), target.name(),
                record.getStartedAt(), record.getPendingEvalAt(), record.getFinishedAt(),
                record.getActualHours());
        if (affected != 1) {
            throw stateConflict("交换状态已被其他请求修改，请刷新后重试");
        }

        // 只有已进入协作的交换被取消才需要重新开放需求；洽谈中邀约被拒绝/撤回不得影响卡片。
        if (target == ExchangeStatus.CANCELLED && previous == ExchangeStatus.IN_PROGRESS
                && record.getSourceDemandId() != null) {
            demandMapper.reopenAfterCancellation(record.getSourceDemandId());
        }
        if (target == ExchangeStatus.COMPLETED && record.getSourceDemandId() != null) {
            demandMapper.closeAfterCompletion(record.getSourceDemandId());
        }
    }

    /**
     * 接受一条邀约时取消其他竞争交换。其他请求可能已经先一步处理，CAS 失败只记录日志。
     */
    private void cancelNegotiatingRecord(ExchangeRecord record) {
        record.transferTo(ExchangeStatus.CANCELLED);
        int affected = exchangeMapper.updateStatusCas(
                record.getId(), ExchangeStatus.NEGOTIATING.name(), ExchangeStatus.CANCELLED.name(),
                record.getStartedAt(), record.getPendingEvalAt(), record.getFinishedAt(),
                record.getActualHours());
        if (affected == 0) {
            log.debug("[邀约接受] 竞争交换已被其他请求处理：record={}", record.getId());
        }
    }

    private static BusinessException stateConflict(String message) {
        return new BusinessException(ErrorCode.EXCHANGE_STATE_CONFLICT, message);
    }

    private ExchangeRecord requireRecord(Long recordId) {
        ExchangeRecord record = exchangeMapper.selectById(recordId);
        if (record == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND);
        }
        return record;
    }

    private ExchangeStatus parseTargetStatus(String targetStatus) {
        ExchangeStatus target = ExchangeStatus.of(targetStatus);
        if (target == null) {
            throw BusinessException.paramInvalid("目标状态不合法：" + targetStatus);
        }
        return target;
    }

    /** 状态标签（previous 可能为 null，做兜底） */
    private static String label(ExchangeStatus status) {
        return status == null ? "未知" : status.getLabel();
    }

    /* ==================== 查询 ==================== */

    @Override
    public List<ExchangeVO> myExchanges(String sno, String status) {
        LambdaQueryWrapper<ExchangeRecord> wrapper = new LambdaQueryWrapper<ExchangeRecord>()
                .and(w -> w.eq(ExchangeRecord::getGiverSno, sno).or().eq(ExchangeRecord::getTakerSno, sno));
        if (StringUtils.hasText(status)) {
            ExchangeStatus s = ExchangeStatus.of(status);
            if (s == null) {
                throw BusinessException.paramInvalid("状态不合法：" + status);
            }
            wrapper.eq(ExchangeRecord::getStatus, s);
        }
        wrapper.orderByDesc(ExchangeRecord::getCreatedAt);
        List<ExchangeRecord> records = exchangeMapper.selectList(wrapper);
        return assemble(records, sno);
    }

    @Override
    public ExchangeVO detail(Long recordId, String viewerSno) {
        ExchangeRecord record = exchangeMapper.selectById(recordId);
        if (record == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND);
        }
        if (!record.isParticipant(viewerSno)) {
            throw new BusinessException(ErrorCode.NOT_PARTICIPANT);
        }
        List<ExchangeVO> list = assemble(List.of(record), viewerSno);
        return list.isEmpty() ? null : list.get(0);
    }

    /* ==================== 私有：装配 ==================== */

    /**
     * 批量装配交换视图：一次查出技能与用户，避免 N+1。
     */
    private List<ExchangeVO> assemble(List<ExchangeRecord> records, String viewerSno) {
        if (records == null || records.isEmpty()) {
            return List.of();
        }
        Set<Long> skillIds = new LinkedHashSet<>();
        Set<String> snos = new LinkedHashSet<>();
        for (ExchangeRecord r : records) {
            if (r.getGiveSkillId() != null) {
                skillIds.add(r.getGiveSkillId());
            }
            if (r.getLearnSkillId() != null) {
                skillIds.add(r.getLearnSkillId());
            }
            if (r.getGiverSno() != null) {
                snos.add(r.getGiverSno());
            }
            if (r.getTakerSno() != null) {
                snos.add(r.getTakerSno());
            }
        }
        Map<Long, Skill> skillMap = skillIds.isEmpty() ? Map.of()
                : skillMapper.selectBriefByIds(skillIds).stream()
                .collect(Collectors.toMap(Skill::getId, s -> s, (a, b) -> a));
        Map<String, Student> studentMap = snos.isEmpty() ? Map.of()
                : studentMapper.selectBriefBySnos(snos).stream()
                .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));

        List<ExchangeVO> list = new ArrayList<>(records.size());
        for (ExchangeRecord r : records) {
            ExchangeVO vo = ExchangeVO.of(r);
            vo.setGiver(buildParty(r.getGiverSno(), r.getGiveSkillId(), r.getLearnSkillId(), studentMap, skillMap));
            vo.setTaker(buildParty(r.getTakerSno(), r.getLearnSkillId(), r.getGiveSkillId(), studentMap, skillMap));
            vo.setMyRole(resolveRole(r, viewerSno));
            fillPermissions(vo, r, viewerSno);
            list.add(vo);
        }
        return list;
    }

    private ExchangeVO.PartySkill buildParty(String sno, Long provideSkillId, Long acquireSkillId,
                                             Map<String, Student> studentMap, Map<Long, Skill> skillMap) {
        ExchangeVO.PartySkill party = new ExchangeVO.PartySkill();
        party.setSno(sno);
        Student student = studentMap.get(sno);
        if (student != null) {
            party.setName(student.displayName());
            party.setCollege(student.getCollege());
        }
        party.setProvideSkillId(provideSkillId);
        party.setProvideSkillName(nameOf(skillMap, provideSkillId));
        party.setAcquireSkillId(acquireSkillId);
        party.setAcquireSkillName(nameOf(skillMap, acquireSkillId));
        return party;
    }

    private String resolveRole(ExchangeRecord r, String viewerSno) {
        if (viewerSno == null) {
            return "OBSERVER";
        }
        if (viewerSno.equals(r.getGiverSno())) {
            return "GIVER";
        }
        if (viewerSno.equals(r.getTakerSno())) {
            return "TAKER";
        }
        return "OBSERVER";
    }

    /**
     * 填充"当前用户可执行的操作"，让前端不必硬编码状态机。
     */
    private void fillPermissions(ExchangeVO vo, ExchangeRecord r, String viewerSno) {
        boolean isTaker = viewerSno != null && viewerSno.equals(r.getTakerSno());
        boolean isGiver = viewerSno != null && viewerSno.equals(r.getGiverSno());
        boolean participant = isTaker || isGiver;
        ExchangeStatus status = r.getStatus() == null ? ExchangeStatus.PUBLISHED : r.getStatus();

        // 接受/拒绝走邀约接口，开始协作由 accept 内部完成，不允许通过通用状态接口绕过。
        vo.setCanAccept(isTaker && status == ExchangeStatus.NEGOTIATING);
        vo.setCanReject(isTaker && status == ExchangeStatus.NEGOTIATING);
        vo.setCanStart(false);
        vo.setCanCancel(participant && status == ExchangeStatus.IN_PROGRESS);
        vo.setCanSubmitEval(participant && status == ExchangeStatus.PENDING_EVAL);
        vo.setCanDispute(participant
                && (status == ExchangeStatus.IN_PROGRESS || status == ExchangeStatus.PENDING_EVAL));

        /*
         * 只暴露 Controller 真正允许的公开流转。
         * IN_PROGRESS 必须由接受邀约完成，COMPLETED 必须由互评完成，
         * DISPUTED 必须通过治理流程创建案件，因此都不能由通用状态按钮触发。
         */
        List<String> manualNext = new ArrayList<>();
        if (status == ExchangeStatus.IN_PROGRESS) {
            manualNext.add(ExchangeStatus.PENDING_EVAL.name());
            manualNext.add(ExchangeStatus.CANCELLED.name());
        }
        vo.setAllowedNextStatus(manualNext);
    }

    /* ==================== 私有：校验与工具 ==================== */

    /**
     * 校验并发交换配额（FR-M4-09）。
     *
     * <p>占用配额的是"洽谈中"与"进行中"两种状态，上限取用户自身配置
     * （默认 5，管理员可单独调整）。
     */
    private void checkExchangeQuota(String sno) {
        if (sno == null) {
            return;
        }
        Student student = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getExchangeQuota)
                .eq(Student::getSno, sno));
        int quota = (student == null || student.getExchangeQuota() == null) ? 5 : student.getExchangeQuota();
        int ongoing = exchangeMapper.countOngoing(sno);
        if (ongoing >= quota) {
            throw new BusinessException(ErrorCode.EXCHANGE_QUOTA_EXCEEDED,
                    String.format("进行中的交换已达上限（%d/%d），请先完成或取消现有交换", ongoing, quota));
        }
    }

    private String generateRecordNo() {
        return "ZY" + LocalDateTime.now().format(NO_FORMATTER) + RandomUtil.randomNumbers(4);
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

    private static String nameOf(Map<Long, Skill> skillMap, Long id) {
        if (id == null) {
            return null;
        }
        Skill s = skillMap.get(id);
        return s == null ? null : s.getName();
    }

    /** 学号 → 展示名（用于通知文案，失败时退化为学号） */
    private String displayName(String sno) {
        if (!StringUtils.hasText(sno)) {
            return "对方";
        }
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getSname, Student::getNickname)
                .eq(Student::getSno, sno));
        return s == null ? sno : s.displayName();
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String t = value.trim();
        return t.isEmpty() ? null : t;
    }
}
