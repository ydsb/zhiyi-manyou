package com.nwu.zhiyi.service.exchange;

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
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.collab.WorkspaceService;
import com.nwu.zhiyi.service.demand.DemandService;
import com.nwu.zhiyi.service.notify.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
    private final DemandService demandService;
    private final WorkspaceService workspaceService;
    private final NotificationService notificationService;

    private static final DateTimeFormatter NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");

    /* ==================== 发起邀约 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
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
        interestMapper.insert(interest);

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
        // 只有卡片发布人可以接受/拒绝
        if (!demand.isOwnedBy(operator)) {
            throw new BusinessException(ErrorCode.DEMAND_NOT_OWNER);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("interestId", interestId);
        result.put("accepted", accept);

        if (!accept) {
            interestMapper.updateById(new DemandInterest().setId(interestId)
                    .setStatus(DemandInterestStatus.REJECTED));
            ExchangeRecord record = interest.getRecordId() == null ? null
                    : exchangeMapper.selectById(interest.getRecordId());
            if (record != null && record.getStatus() == ExchangeStatus.NEGOTIATING) {
                record.transferTo(ExchangeStatus.CANCELLED);
                exchangeMapper.updateById(record);
            }
            // 通知申请人（FR-M5-05）
            notificationService.sendOnce(interest.getApplicantSno(), NotificationType.INVITE_RESULT,
                    "交换邀约被拒绝",
                    StringUtils.hasText(reason) ? ("对方拒绝了你的邀约：" + reason) : "对方拒绝了你的邀约",
                    "INTEREST", interestId);
            result.put("message", StringUtils.hasText(reason) ? ("已拒绝：" + reason) : "已拒绝该邀约");
            log.info("[邀约拒绝] interest={} by={} reason={}", interestId, operator, reason);
            return result;
        }

        // 接受：交换进入进行中，卡片标记为已匹配。
        //
        // 注意：这里刻意【不】再校验并发配额。
        // 「发起邀约」时该交换已进入 NEGOTIATING 并占用配额，接受只是把同一条交换
        // 从洽谈中推进到进行中，不产生新的占用。若在此重复校验，
        // checkExchangeQuota 会把这条交换自己也算进 ongoing，
        // 导致"配额已满时永远无法接受邀约"（曾出现的缺陷）。
        ExchangeRecord record = interest.getRecordId() == null ? null
                : exchangeMapper.selectById(interest.getRecordId());
        if (record == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND, "邀约关联的交换记录不存在");
        }
        if (record.getStatus() != ExchangeStatus.NEGOTIATING) {
            throw new BusinessException(ErrorCode.EXCHANGE_STATUS_ILLEGAL,
                    String.format("该交换当前状态为「%s」，无法接受邀约",
                            record.getStatus() == null ? "未知" : record.getStatus().getLabel()));
        }

        record.transferTo(ExchangeStatus.IN_PROGRESS);
        exchangeMapper.updateById(record);

        interestMapper.updateById(new DemandInterest().setId(interestId)
                .setStatus(DemandInterestStatus.ACCEPTED));
        demandService.markMatched(demand.getId());

        // 同一卡片上的其他待响应邀约自动拒绝：一张卡片对应一次交换，避免一对多重复占用
        List<DemandInterest> others = interestMapper.selectList(new LambdaQueryWrapper<DemandInterest>()
                .eq(DemandInterest::getDemandId, demand.getId())
                .eq(DemandInterest::getStatus, DemandInterestStatus.PENDING)
                .ne(DemandInterest::getId, interestId));
        for (DemandInterest other : others) {
            interestMapper.updateById(new DemandInterest().setId(other.getId())
                    .setStatus(DemandInterestStatus.REJECTED));
            if (other.getRecordId() != null) {
                ExchangeRecord otherRecord = exchangeMapper.selectById(other.getRecordId());
                if (otherRecord != null && otherRecord.getStatus() == ExchangeStatus.NEGOTIATING) {
                    otherRecord.transferTo(ExchangeStatus.CANCELLED);
                    exchangeMapper.updateById(otherRecord);
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

        // 写协作事件起点（FR-M5-04 时间轴的第一条）+ 通知申请人（FR-M5-05）
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
        interestMapper.updateById(new DemandInterest().setId(interestId)
                .setStatus(DemandInterestStatus.WITHDRAWN));
        if (interest.getRecordId() != null) {
            ExchangeRecord record = exchangeMapper.selectById(interest.getRecordId());
            if (record != null && record.getStatus() == ExchangeStatus.NEGOTIATING) {
                record.transferTo(ExchangeStatus.CANCELLED);
                exchangeMapper.updateById(record);
            }
        }
        log.info("[邀约撤回] interest={} by={}", interestId, applicantSno);
    }

    /* ==================== 状态流转 ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ExchangeVO changeStatus(String operator, Long recordId, String targetStatus, Double actualHours) {
        ExchangeRecord record = exchangeMapper.selectById(recordId);
        if (record == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND);
        }
        if (!record.isParticipant(operator)) {
            throw new BusinessException(ErrorCode.NOT_PARTICIPANT);
        }
        ExchangeStatus target = ExchangeStatus.of(targetStatus);
        if (target == null) {
            throw BusinessException.paramInvalid("目标状态不合法：" + targetStatus);
        }

        // 状态机校验 + 副作用（时间戳）
        ExchangeStatus previous = record.getStatus();
        record.transferTo(target);
        if (actualHours != null) {
            record.setActualHours(BigDecimal.valueOf(actualHours));
        }
        exchangeMapper.updateById(record);

        // 写协作事件（FR-M5-04 时间轴）
        workspaceService.recordEvent(recordId, operator,
                com.nwu.zhiyi.domain.entity.CollabEvent.TYPE_STATUS_CHANGE,
                String.format("交换状态变更：%s → %s", label(previous), target.getLabel()),
                actualHours == null ? null : ("实际投入 " + actualHours + " 小时"),
                "EXCHANGE", recordId);

        // 进入待互评时提醒双方（FR-M5-05 互评提醒）
        if (target == ExchangeStatus.PENDING_EVAL) {
            notificationService.sendToExchangeParties(recordId, null, NotificationType.EVAL_REMIND,
                    "交换已进入待互评",
                    "请到「我的交换」完成双向互评，评价提交后将生成不可篡改的存证记录");
        }

        // 取消时释放卡片，让它重新可招募
        if (target == ExchangeStatus.CANCELLED && record.getSourceDemandId() != null) {
            Demand demand = demandMapper.selectById(record.getSourceDemandId());
            if (demand != null && demand.getStatus() == DemandStatus.MATCHED) {
                demandMapper.updateById(new Demand().setId(demand.getId()).setStatus(DemandStatus.OPEN));
            }
        }

        log.info("[交换流转] record={} {} → {} by={}",
                record.getRecordNo(), label(previous), target.getLabel(), operator);

        return detail(recordId, operator);
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

        vo.setCanAccept(participant && status == ExchangeStatus.NEGOTIATING);
        vo.setCanReject(participant && status == ExchangeStatus.NEGOTIATING);
        vo.setCanCancel(participant && !status.isFinal());
        vo.setCanStart(participant && status == ExchangeStatus.NEGOTIATING);
        vo.setCanSubmitEval(participant && status == ExchangeStatus.PENDING_EVAL);
        vo.setCanDispute(participant && !status.isFinal());
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
