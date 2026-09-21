package com.nwu.zhiyi.service.collab;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.collab.CollabEventVO;
import com.nwu.zhiyi.api.dto.collab.CollabFileVO;
import com.nwu.zhiyi.api.dto.collab.CollabMessageVO;
import com.nwu.zhiyi.api.dto.collab.CollabTaskVO;
import com.nwu.zhiyi.api.dto.collab.TaskConfirmRequest;
import com.nwu.zhiyi.api.dto.collab.MessageSendRequest;
import com.nwu.zhiyi.api.dto.collab.ProcessSummaryVO;
import com.nwu.zhiyi.api.dto.collab.TaskCreateRequest;
import com.nwu.zhiyi.api.dto.collab.TaskUpdateRequest;
import com.nwu.zhiyi.api.dto.collab.WorkspaceVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.common.enums.TaskStatus;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.CollabEvent;
import com.nwu.zhiyi.domain.entity.CollabFile;
import com.nwu.zhiyi.domain.entity.CollabMessage;
import com.nwu.zhiyi.domain.entity.CollabTask;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.CollabEventMapper;
import com.nwu.zhiyi.domain.mapper.CollabFileMapper;
import com.nwu.zhiyi.domain.mapper.CollabMessageMapper;
import com.nwu.zhiyi.domain.mapper.CollabTaskMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.notify.NotificationService;
import com.nwu.zhiyi.service.storage.FileStorage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 协作工作台服务实现（模块 M5）。
 *
 * <p><b>访问控制</b>：所有接口入口都过 {@link #requireParticipant}，
 * 只有交换参与方（以及管理员，用于争议调查）能读写工作台内容 ——
 * 这是 FR-M5-01「专属协作空间，仅双方及必要时的仲裁员可见」的落点。
 *
 * <p><b>过程性语料（FR-M5-06）</b>：每次读写都会顺带写入 {@code zy_collab_event}，
 * 事件带 {@code actorSno} 与 {@code occurredAt}，因此 {@link #processSummary}
 * 可以直接聚合出个人维度的完成率、按期率、活跃度，不需要额外批处理任务。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class WorkspaceServiceImpl implements WorkspaceService {

    private final ExchangeRecordMapper exchangeMapper;
    private final CollabTaskMapper taskMapper;
    private final CollabFileMapper fileMapper;
    private final CollabMessageMapper messageMapper;
    private final CollabEventMapper eventMapper;
    private final StudentMapper studentMapper;
    private final SkillMapper skillMapper;
    private final FileStorage fileStorage;
    private final NotificationService notificationService;

    /** 留言列表默认与最大返回条数 */
    private static final int DEFAULT_MESSAGE_LIMIT = 50;
    private static final int MAX_MESSAGE_LIMIT = 200;

    /** 时间轴最大返回条数 */
    private static final int MAX_TIMELINE_LIMIT = 300;

    /* ==================== 访问控制 ==================== */

    /**
     * 校验访问者是否为该交换的参与方（管理员放行，用于争议调查）。
     *
     * @param recordId  交换记录 ID
     * @param viewerSno 访问者
     * @return 交换记录
     */
    private ExchangeRecord requireParticipant(Long recordId, String viewerSno) {
        ExchangeRecord record = exchangeMapper.selectById(recordId);
        if (record == null) {
            throw new BusinessException(ErrorCode.EXCHANGE_NOT_FOUND);
        }
        if (viewerSno == null) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED);
        }
        if (record.isParticipant(viewerSno) || isAdmin(viewerSno)) {
            return record;
        }
        throw new BusinessException(ErrorCode.NOT_PARTICIPANT, "你不是该交换的参与方，无法访问协作空间");
    }

    /**
     * 校验协作是否已进入可操作阶段。
     *
     * <p>需求：洽谈中还不能拆解任务（双方尚未确认合作），
     * 所以协作内容的生产从「进行中」开始；只读查看则更宽松（见 overview）。
     */
    private ExchangeRecord requireActiveCollaboration(Long recordId, String viewerSno) {
        ExchangeRecord record = requireParticipant(recordId, viewerSno);
        ExchangeStatus status = record.getStatus();
        boolean writable = status == ExchangeStatus.IN_PROGRESS
                || status == ExchangeStatus.PENDING_EVAL
                || status == ExchangeStatus.DISPUTED;
        if (!writable) {
            throw new BusinessException(ErrorCode.WORKSPACE_NOT_AVAILABLE,
                    String.format("当前交换状态为「%s」，协作空间在交换进入「进行中」后才可写入",
                            status == null ? "未知" : status.getLabel()));
        }
        return record;
    }

    private boolean isAdmin(String sno) {
        Student student = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getRole)
                .eq(Student::getSno, sno));
        return student != null && student.getRole() == com.nwu.zhiyi.common.enums.UserRole.ADMIN;
    }

    /* ==================== 工作台总览（FR-M5-01） ==================== */

    @Override
    public WorkspaceVO overview(Long recordId, String viewerSno) {
        ExchangeRecord record = requireParticipant(recordId, viewerSno);

        WorkspaceVO vo = new WorkspaceVO();
        vo.setRecordId(record.getId());
        vo.setRecordNo(record.getRecordNo());
        vo.setTitle(record.getTitle());
        vo.setDescription(record.getDescription());
        if (record.getStatus() != null) {
            vo.setStatus(record.getStatus().name());
            vo.setStatusLabel(record.getStatus().getLabel());
            vo.setAllowedNextStatus(record.getStatus().allowedNext().stream()
                    .map(Enum::name).sorted().collect(Collectors.toList()));
        }
        vo.setStartedAt(record.getStartedAt());
        vo.setDeadlineAt(record.getDeadlineAt());
        vo.setExpectedHours(record.getExpectedHours());
        vo.setActualHours(record.getActualHours() == null ? null : record.getActualHours().doubleValue());

        ExchangeStatus status = record.getStatus();
        /*
         * 写权限：只有协作进行中才能改。
         *
         * 洽谈中还不能拆解任务（双方尚未确认合作），交换结束后更不该再改动 ——
         * 已完成交换的任务、留言与文件是**协作证据**，M6 互评与 M7 画像都引用它们，
         * 允许事后修改会让证据失去意义。
         */
        boolean active = status == ExchangeStatus.IN_PROGRESS
                || status == ExchangeStatus.PENDING_EVAL
                || status == ExchangeStatus.DISPUTED;
        vo.setCollaborationActive(active);

        /*
         * 读权限：范围比写权限大 —— 已完成/已取消的交换**只读可查**。
         *
         * 这里修的是一个真实缺陷：原先回显内容也挂在 active 上，
         * 于是交换一进入「已完成」，双方就再也看不到自己做过什么 ——
         * 任务清单、交付文件、沟通留言、协作时间轴全部消失，
         * 而"学习记录与过程留痕"恰恰是本模块（FR-M5）最核心的价值。
         * 列表页也因此不显示工作台入口，等于这批数据被凭空封存。
         *
         * 区分三种情形：
         *   - NEGOTIATING / PUBLISHED / CANCELLED 前：协作还没开始，确实没有内容可看；
         *   - 进行中三态：可读可写；
         *   - 已完成（也含已取消）：**可读不可写**，作为历史记录保留。
         */
        boolean readable = active
                || status == ExchangeStatus.COMPLETED
                || status == ExchangeStatus.CANCELLED;
        vo.setCollaborationReadable(readable);

        // 参与方与技能
        vo.setGiver(party(record.getGiverSno(), record.getGiveSkillId(), record.getLearnSkillId()));
        vo.setTaker(party(record.getTakerSno(), record.getLearnSkillId(), record.getGiveSkillId()));

        String role = viewerSno.equals(record.getGiverSno()) ? "GIVER"
                : viewerSno.equals(record.getTakerSno()) ? "TAKER" : "OBSERVER";
        vo.setMyRole(role);
        vo.setCanManageTasks(active && !"OBSERVER".equals(role));
        vo.setCanUpload(active && !"OBSERVER".equals(role));
        vo.setCanSendMessage(active && !"OBSERVER".equals(role));
        vo.setCanSubmitEval(status == ExchangeStatus.PENDING_EVAL);

        // 内容：只要交换开始过就回显（已完成/已取消为只读），未开始时返回空集合供前端展示引导态
        vo.setTasks(readable ? buildTaskVOs(recordId, viewerSno, record) : List.of());
        vo.setFiles(readable ? buildLatestFileVOs(recordId) : List.of());
        vo.setMessages(readable ? buildMessageVOs(recordId, viewerSno, DEFAULT_MESSAGE_LIMIT) : List.of());
        vo.setTimeline(readable ? buildTimeline(recordId, viewerSno, 100) : List.of());
        if (readable) {
            vo.setProcessSummary(computeProcessSummary(record));
        }
        return vo;
    }

    private WorkspaceVO.Party party(String sno, Long provideSkillId, Long acquireSkillId) {
        WorkspaceVO.Party p = new WorkspaceVO.Party();
        p.setSno(sno);
        if (sno != null) {
            Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>().eq(Student::getSno, sno));
            if (s != null) {
                p.setName(s.displayName());
                p.setCollege(s.getCollege());
            }
        }
        Set<Long> skillIds = new LinkedHashSet<>();
        if (provideSkillId != null) {
            skillIds.add(provideSkillId);
        }
        if (acquireSkillId != null) {
            skillIds.add(acquireSkillId);
        }
        Map<Long, String> names = skillIds.isEmpty() ? Map.of()
                : skillMapper.selectBriefByIds(skillIds).stream()
                .collect(Collectors.toMap(Skill::getId, Skill::getName, (a, b) -> a));
        p.setProvideSkillName(provideSkillId == null ? null : names.get(provideSkillId));
        p.setAcquireSkillName(acquireSkillId == null ? null : names.get(acquireSkillId));
        return p;
    }

    /* ==================== 任务（FR-M5-02） ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CollabTaskVO createTask(Long recordId, String operator, TaskCreateRequest request) {
        ExchangeRecord record = requireActiveCollaboration(recordId, operator);
        String assignee = resolveAssignee(record, request.getAssigneeSno());

        CollabTask task = new CollabTask()
                .setRecordId(recordId)
                .setTitle(request.getTitle().trim())
                .setDescription(trimToNull(request.getDescription()))
                .setAssigneeSno(assignee)
                .setDeadline(parseDateTime(request.getDeadline()))
                .setStatus(TaskStatus.TODO)
                .setSortOrder(request.getSortOrder() == null ? 0 : request.getSortOrder())
                .setCreatedBy(operator);
        taskMapper.insert(task);

        // 时间轴 + 通知对方
        String who = assignee == null ? "双方共同负责" : ("负责人：" + displayName(assignee));
        recordEvent(recordId, operator, CollabEvent.TYPE_TASK_CREATE,
                "新建任务「" + task.getTitle() + "」", who, "TASK", task.getId());
        notificationService.sendToExchangeParties(recordId, operator,
                NotificationType.TASK_DONE, "协作方新建了任务",
                "「" + task.getTitle() + "」" + (assignee == null ? "" : "（" + who + "）"));

        log.info("[协作任务] 新建 record={} task={} assignee={}", record.getRecordNo(), task.getId(), assignee);
        return enrichAssignee(toTaskVO(task, operator, record));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CollabTaskVO updateTask(Long recordId, Long taskId, String operator, TaskUpdateRequest request) {
        ExchangeRecord record = requireActiveCollaboration(recordId, operator);
        CollabTask task = taskMapper.selectById(taskId);
        if (task == null || !recordId.equals(task.getRecordId())) {
            throw new BusinessException(ErrorCode.TASK_NOT_FOUND);
        }

        CollabTask update = new CollabTask().setId(taskId);
        if (StringUtils.hasText(request.getTitle())) {
            update.setTitle(request.getTitle().trim());
        }
        if (request.getDescription() != null) {
            update.setDescription(trimToNull(request.getDescription()));
        }
        if (request.getAssigneeSno() != null) {
            update.setAssigneeSno(resolveAssignee(record, request.getAssigneeSno()));
        }
        if (request.getDeadline() != null) {
            update.setDeadline(parseDateTime(request.getDeadline()));
        }
        if (request.getEvidenceUrl() != null) {
            update.setEvidenceUrl(trimToNull(request.getEvidenceUrl()));
        }
        if (request.getSortOrder() != null) {
            update.setSortOrder(request.getSortOrder());
        }

        TaskStatus previous = task.getStatus();
        boolean becameDone = false;
        boolean revertedFromDone = false;
        if (StringUtils.hasText(request.getStatus())) {
            TaskStatus target = parseTaskStatus(request.getStatus());
            if (target == previous && target != TaskStatus.DONE) {
                // 状态没变，无需处理
            } else if (target == TaskStatus.DONE) {
                if (previous == TaskStatus.DONE) {
                    throw new BusinessException(ErrorCode.TASK_ALREADY_DONE);
                }
                // 打卡：记录完成时间（按期率的计算依据）与打卡人（FR-M5-08 判定"谁有权确认"）
                update.setStatus(TaskStatus.DONE).setDoneAt(LocalDateTime.now()).setDoneBy(operator);
                becameDone = true;
            } else {
                if (previous == TaskStatus.DONE) {
                    /*
                     * 允许从已完成退回。
                     *
                     * 原先这里直接抛异常（"已完成的任务不能退回未完成状态"），
                     * 后果是误点"完成"后用户无法自救 —— 只能找管理员改库。
                     * 现在放行，但必须清空确认状态：成果已经改变，
                     * 对方此前对旧成果的认可对新成果不再成立。
                     *
                     * 清空用显式 SQL 而不是"设为 null 后 updateById"：
                     * MP 的默认策略会跳过 null 字段，那样只会把 confirmed 置 0，
                     * 而 confirmed_by / confirmed_at 仍留着旧值 ——
                     * 审计时会看到"未确认却带着确认人"的自相矛盾数据。
                     * （端到端验证发现了这个残留，单测覆盖不到。）
                     */
                    update.setStatus(target);
                    revertedFromDone = true;
                } else {
                    update.setStatus(target);
                }
            }
        }

        if (revertedFromDone) {
            taskMapper.updateById(update);
            taskMapper.clearConfirmation(taskId);
        } else {
            taskMapper.updateById(update);
        }
        CollabTask fresh = taskMapper.selectById(taskId);

        if (revertedFromDone) {
            recordEvent(recordId, operator, CollabEvent.TYPE_TASK_CREATE,
                    "撤回任务「" + fresh.getTitle() + "」的完成状态",
                    "该任务此前的对方确认已同时清空（成果已变更，原确认不再适用）", "TASK", taskId);
            log.info("[协作任务] 撤回完成 record={} task={}", record.getRecordNo(), taskId);
        }

        if (becameDone) {
            // 按期与否
            boolean onTime = fresh.getDeadline() == null || !fresh.getDoneAt().isAfter(fresh.getDeadline());
            String detail = onTime ? "按期完成" : "逾期完成"
                    + "（截止 " + fresh.getDeadline() + "，实际 " + fresh.getDoneAt() + "）";
            if (fresh.getEvidenceUrl() != null) {
                detail += "；已提交证据";
            }
            recordEvent(recordId, operator, CollabEvent.TYPE_TASK_DONE,
                    "完成任务「" + fresh.getTitle() + "」", detail, "TASK", taskId);
            notificationService.sendToExchangeParties(recordId, operator,
                    NotificationType.TASK_DONE, "协作方完成任务打卡",
                    "「" + fresh.getTitle() + "」" + (onTime ? "已按期完成" : "已逾期完成"));
            log.info("[协作任务] 打卡 record={} task={} onTime={}", record.getRecordNo(), taskId, onTime);
        }
        return enrichAssignee(toTaskVO(fresh, operator, record));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CollabTaskVO confirmTask(Long recordId, Long taskId, String operator, TaskConfirmRequest request) {
        ExchangeRecord record = requireActiveCollaboration(recordId, operator);
        CollabTask task = taskMapper.selectById(taskId);
        if (task == null || !recordId.equals(task.getRecordId())) {
            throw new BusinessException(ErrorCode.TASK_NOT_FOUND);
        }

        /*
         * 只有"已标记完成"的成果才需要被确认。
         * 未完成就去确认没有意义：对方还没交付任何东西。
         */
        if (task.getStatus() != TaskStatus.DONE) {
            throw new BusinessException(ErrorCode.TASK_NOT_DONE_YET,
                    "任务「" + task.getTitle() + "」当前状态为「"
                            + task.getStatus().getLabel() + "」，需先由协作方标记完成");
        }
        if (CollabTask.isConfirmed(task)) {
            throw new BusinessException(ErrorCode.TASK_ALREADY_CONFIRMED,
                    "该任务已由 " + task.getConfirmedBy() + " 于 " + task.getConfirmedAt() + " 确认");
        }

        /*
         * 权限判定（FR-M5-08 的核心）。
         *
         * 必须由协作方确认，且不能是自己确认自己。分两步给不同错误码，
         * 因为两种情形的处置方式完全不同：
         *   - 打卡者确认自己 → 用户操作错误，提示"需由协作方确认"；
         *   - 非本次交换的参与方 → 无权操作。
         * 合成一个"无权确认"会让人以为是权限配置问题。
         */
        if (operator.equals(task.getDoneBy())) {
            throw new BusinessException(ErrorCode.TASK_CONFIRM_SELF_FORBIDDEN,
                    "「" + task.getTitle() + "」由你标记完成，需由协作方确认后才计入确认完成的成果");
        }
        if (!task.canBeConfirmedBy(operator, record.getGiverSno(), record.getTakerSno())) {
            throw new BusinessException(ErrorCode.TASK_CONFIRM_NOT_ALLOWED);
        }

        CollabTask update = new CollabTask().setId(taskId);
        update.markConfirmed(operator, trimToNull(request == null ? null : request.getRemark()));
        taskMapper.updateById(update);
        CollabTask fresh = taskMapper.selectById(taskId);

        recordEvent(recordId, operator, CollabEvent.TYPE_TASK_DONE,
                "确认任务「" + fresh.getTitle() + "」的阶段成果",
                fresh.getConfirmRemark() == null ? "确认无异议" : "确认说明：" + fresh.getConfirmRemark(),
                "TASK", taskId);
        notificationService.sendToExchangeParties(recordId, operator,
                NotificationType.TASK_DONE, "协作方确认了你的成果",
                "「" + fresh.getTitle() + "」已获对方确认");
        log.info("[协作任务] 确认成果 record={} task={} by={}",
                record.getRecordNo(), taskId, operator);

        return enrichAssignee(toTaskVO(fresh, operator, record));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTask(Long recordId, Long taskId, String operator) {
        requireActiveCollaboration(recordId, operator);
        CollabTask task = taskMapper.selectById(taskId);
        if (task == null || !recordId.equals(task.getRecordId())) {
            throw new BusinessException(ErrorCode.TASK_NOT_FOUND);
        }
        if (task.getStatus() == TaskStatus.DONE) {
            throw new BusinessException(ErrorCode.TASK_STATUS_ILLEGAL,
                    "已完成的任务不能删除：它是过程性评价的依据，请保留记录");
        }
        taskMapper.deleteById(taskId);
        recordEvent(recordId, operator, CollabEvent.TYPE_TASK_CREATE,
                "删除任务「" + task.getTitle() + "」", null, "TASK", taskId);
    }

    @Override
    public List<CollabTaskVO> listTasks(Long recordId, String viewerSno) {
        ExchangeRecord record = requireParticipant(recordId, viewerSno);
        return buildTaskVOs(recordId, viewerSno, record);
    }

    private List<CollabTaskVO> buildTaskVOs(Long recordId, String viewerSno, ExchangeRecord record) {
        List<CollabTask> tasks = taskMapper.selectList(new LambdaQueryWrapper<CollabTask>()
                .eq(CollabTask::getRecordId, recordId)
                .orderByAsc(CollabTask::getSortOrder)
                .orderByAsc(CollabTask::getId));
        if (tasks.isEmpty()) {
            return List.of();
        }
        Set<String> snos = tasks.stream().map(CollabTask::getAssigneeSno)
                .filter(StringUtils::hasText).collect(Collectors.toCollection(LinkedHashSet::new));
        // 确认人姓名与负责人姓名一次性批量取，避免 N+1（任务是列表渲染热点）
        tasks.stream().map(CollabTask::getConfirmedBy)
                .filter(StringUtils::hasText).forEach(snos::add);
        Map<String, Student> students = snos.isEmpty() ? Map.of()
                : studentMapper.selectBriefBySnos(snos).stream()
                .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));

        return tasks.stream().map(t -> {
            CollabTaskVO vo = toTaskVO(t, viewerSno, record);
            Student s = t.getAssigneeSno() == null ? null : students.get(t.getAssigneeSno());
            if (s != null) {
                vo.setAssigneeName(s.displayName());
                vo.setAssigneeCollege(s.getCollege());
            }
            Student confirmer = t.getConfirmedBy() == null ? null : students.get(t.getConfirmedBy());
            if (confirmer != null) {
                vo.setConfirmedByName(confirmer.displayName());
            }
            return vo;
        }).collect(Collectors.toList());
    }

    /**
     * 补齐负责人姓名与院系。
     *
     * <p>列表接口 {@code buildTaskVOs} 是批量补齐的（避免 N+1）；
     * 而创建/修改任务只返回单个对象，这里单独补一次 —— 否则前端在"刚建完任务"
     * 的响应里拿不到负责人名字，只能等下一次列表刷新，体验上会闪一下。
     */
    private CollabTaskVO enrichAssignee(CollabTaskVO vo) {
        if (vo == null) {
            return null;
        }
        Set<String> need = new LinkedHashSet<>();
        if (StringUtils.hasText(vo.getAssigneeSno())) {
            need.add(vo.getAssigneeSno());
        }
        if (StringUtils.hasText(vo.getConfirmedBy())) {
            need.add(vo.getConfirmedBy());
        }
        if (need.isEmpty()) {
            return vo;
        }
        Map<String, Student> students = studentMapper.selectBriefBySnos(need).stream()
                .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));
        Student s = vo.getAssigneeSno() == null ? null : students.get(vo.getAssigneeSno());
        if (s != null) {
            vo.setAssigneeName(s.displayName());
            vo.setAssigneeCollege(s.getCollege());
        }
        Student confirmer = vo.getConfirmedBy() == null ? null : students.get(vo.getConfirmedBy());
        if (confirmer != null) {
            vo.setConfirmedByName(confirmer.displayName());
        }
        return vo;
    }
    private CollabTaskVO toTaskVO(CollabTask task, String viewerSno, ExchangeRecord record) {
        CollabTaskVO vo = CollabTaskVO.of(task);
        if (vo == null) {
            return null;
        }
        if (task.getAssigneeSno() != null) {
            vo.setMine(task.getAssigneeSno().equals(viewerSno));
        }
        /*
         * canConfirm 由服务端算好下发，而不是让前端自己判断。
         * 规则是"是本次交换的参与方，且不是打卡者" ——
         * 前端复刻一遍必然会与后端走样，而走样的后果是
         * 用户看到可点的按钮、点下去却报错。
         */
        vo.setCanConfirm(task.getStatus() == TaskStatus.DONE
                && !CollabTask.isConfirmed(task)
                && task.canBeConfirmedBy(viewerSno,
                        record == null ? null : record.getGiverSno(),
                        record == null ? null : record.getTakerSno()));
        return vo;
    }

    /**
     * 校验负责人必须是本次交换的参与方。
     *
     * @param record    交换记录
     * @param assignee  传入的负责人学号（可为空 = 共同负责）
     * @return 规范化后的负责人学号
     */
    private String resolveAssignee(ExchangeRecord record, String assignee) {
        if (!StringUtils.hasText(assignee)) {
            return null;
        }
        String sno = assignee.trim();
        if (!record.isParticipant(sno)) {
            throw new BusinessException(ErrorCode.PARAM_INVALID,
                    "负责人必须是本次交换的参与方，不能指派给：" + sno);
        }
        return sno;
    }

    private TaskStatus parseTaskStatus(String value) {
        try {
            return TaskStatus.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw BusinessException.paramInvalid("任务状态不合法，应为 TODO / DOING / DONE");
        }
    }

    /* ==================== 文件（FR-M5-03） ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CollabFileVO upload(Long recordId, String uploaderSno, MultipartFile file,
                               String groupKey, Long taskId, String remark) {
        ExchangeRecord record = requireActiveCollaboration(recordId, uploaderSno);

        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.FILE_EMPTY);
        }
        String originalName = StringUtils.hasText(file.getOriginalFilename())
                ? file.getOriginalFilename() : "unnamed";
        // 存储层负责大小/类型校验与安全重命名
        fileStorage.validate(originalName, file.getSize());

        // 关联任务校验（可选）
        if (taskId != null) {
            CollabTask task = taskMapper.selectById(taskId);
            if (task == null || !recordId.equals(task.getRecordId())) {
                throw new BusinessException(ErrorCode.TASK_NOT_FOUND, "关联的任务项不存在或不属于本次交换");
            }
        }

        // 版本号：同一 groupKey 自增；未指定 groupKey 视为新文件
        String key = StringUtils.hasText(groupKey) ? groupKey.trim()
                : "f_" + UUID.randomUUID().toString().replace("-", "").substring(0, 16);
        Integer maxVersion = fileMapper.selectMaxVersion(recordId, key);
        int version = (maxVersion == null ? 0 : maxVersion) + 1;
        if (version > 1) {
            // 有新版本了，旧版本摘掉"最新"标记
            fileMapper.clearLatestFlag(recordId, key);
        }

        FileStorage.StoredFile stored;
        try {
            stored = fileStorage.store(file.getInputStream(), originalName,
                    file.getContentType(), file.getSize());
        } catch (IOException e) {
            throw new BusinessException(ErrorCode.FILE_UPLOAD_ERROR, "读取上传文件失败：" + e.getMessage());
        }

        CollabFile entity = new CollabFile()
                .setRecordId(recordId)
                .setGroupKey(key)
                .setVersion(version)
                .setIsLatest(1)
                .setFileName(originalName)
                .setContentType(file.getContentType())
                .setSizeBytes(stored.sizeBytes())
                .setStorageType(fileStorage.storageType())
                .setStoragePath(stored.storagePath())
                .setSha256(stored.sha256())
                .setTaskId(taskId)
                .setUploaderSno(uploaderSno)
                .setRemark(trimToNull(remark));
        fileMapper.insert(entity);

        String versionNote = version > 1 ? "第 " + version + " 版" : "新文件";
        recordEvent(recordId, uploaderSno, CollabEvent.TYPE_FILE_UPLOAD,
                "上传文件「" + originalName + "」",
                versionNote + "，" + CollabFileVO.humanSize(stored.sizeBytes())
                        + (StringUtils.hasText(remark) ? "；" + remark.trim() : ""),
                "FILE", entity.getId());
        notificationService.sendToExchangeParties(recordId, uploaderSno,
                NotificationType.TASK_DONE, "协作方上传了文件",
                "「" + originalName + "」" + versionNote);

        log.info("[协作文件] 上传 record={} key={} v{} {} ({} 字节)",
                record.getRecordNo(), key, version, originalName, stored.sizeBytes());
        return withVersionInfo(entity, recordId, key);
    }

    @Override
    public List<CollabFileVO> listFiles(Long recordId, String viewerSno, String groupKey) {
        requireParticipant(recordId, viewerSno);
        if (StringUtils.hasText(groupKey)) {
            // 指定逻辑文件 → 返回其全部历史版本（倒序，最新在前）
            List<CollabFile> versions = fileMapper.selectList(new LambdaQueryWrapper<CollabFile>()
                    .eq(CollabFile::getRecordId, recordId)
                    .eq(CollabFile::getGroupKey, groupKey.trim())
                    .orderByDesc(CollabFile::getVersion));
            Integer latest = versions.isEmpty() ? null : versions.get(0).getVersion();
            return versions.stream()
                    .map(f -> {
                        CollabFileVO vo = CollabFileVO.of(f);
                        vo.setLatestVersion(latest);
                        vo.setVersionCount(versions.size());
                        return vo;
                    }).collect(Collectors.toList());
        }
        return buildLatestFileVOs(recordId);
    }

    private List<CollabFileVO> buildLatestFileVOs(Long recordId) {
        List<CollabFile> latest = fileMapper.selectLatestByRecord(recordId);
        if (latest.isEmpty()) {
            return List.of();
        }
        // 统计每个逻辑文件的版本总数（一次查询搞定，避免 N+1）
        List<CollabFile> all = fileMapper.selectList(new LambdaQueryWrapper<CollabFile>()
                .eq(CollabFile::getRecordId, recordId)
                .select(CollabFile::getGroupKey, CollabFile::getVersion));
        Map<String, Integer> countMap = all.stream().collect(Collectors.toMap(
                CollabFile::getGroupKey, CollabFile::getVersion, Math::max));

        // 上传人显示名
        Set<String> snos = latest.stream().map(CollabFile::getUploaderSno)
                .filter(StringUtils::hasText).collect(Collectors.toCollection(LinkedHashSet::new));
        Map<String, Student> students = snos.isEmpty() ? Map.of()
                : studentMapper.selectBriefBySnos(snos).stream()
                .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));

        /*
         * 关联任务标题。
         *
         * 注意两处坑：
         *  1) taskId 可能为 null（例如给已有文件上传新版本时未传 taskId）。
         *     Map.of() 返回 Java 不可变 Map，其 get(null) 会抛 NullPointerException
         *     而不是返回 null —— 本项目踩过（文件列表接口 500）。
         *  2) 用 selectBatchIds 按原始 id 集合查询，会把 null 也带进 IN 子句，
         *     因此先剔除 null 再查；结果用可变 Map 装载，取用前再判空。
         */
        Set<Long> taskIds = latest.stream().map(CollabFile::getTaskId)
                .filter(java.util.Objects::nonNull).collect(Collectors.toCollection(LinkedHashSet::new));
        Map<Long, String> taskTitles = new LinkedHashMap<>();
        if (!taskIds.isEmpty()) {
            taskMapper.selectList(new LambdaQueryWrapper<CollabTask>()
                            .select(CollabTask::getId, CollabTask::getTitle)
                            .in(CollabTask::getId, taskIds))
                    .forEach(t -> taskTitles.put(t.getId(), t.getTitle()));
        }

        return latest.stream().map(f -> {
            CollabFileVO vo = withVersionInfo(f, recordId, f.getGroupKey());
            vo.setVersionCount(countMap.getOrDefault(f.getGroupKey(), f.getVersion()));
            Student s = students.get(f.getUploaderSno());
            if (s != null) {
                vo.setUploaderName(s.displayName());
            }
            if (f.getTaskId() != null) {
                vo.setTaskTitle(taskTitles.get(f.getTaskId()));
            }
            return vo;
        }).collect(Collectors.toList());
    }

    private CollabFileVO withVersionInfo(CollabFile file, Long recordId, String groupKey) {
        CollabFileVO vo = CollabFileVO.of(file);
        Integer max = fileMapper.selectMaxVersion(recordId, groupKey);
        vo.setLatestVersion(max == null ? file.getVersion() : max);
        return vo;
    }

    @Override
    public CollabFile requireDownloadable(Long fileId, String viewerSno) {
        CollabFile file = fileMapper.selectById(fileId);
        if (file == null) {
            throw new BusinessException(ErrorCode.FILE_NOT_FOUND);
        }
        // 下载同样受协作空间访问控制约束，避免拿到 id 就能拖走文件
        requireParticipant(file.getRecordId(), viewerSno);
        return file;
    }

    /* ==================== 留言（FR-M5-07） ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CollabMessageVO sendMessage(Long recordId, String senderSno, MessageSendRequest request) {
        ExchangeRecord record = requireActiveCollaboration(recordId, senderSno);

        boolean hasText = StringUtils.hasText(request.getContent());
        boolean hasFile = request.getFileId() != null;
        if (!hasText && !hasFile) {
            throw new BusinessException(ErrorCode.MESSAGE_EMPTY, "留言内容与附件不能同时为空");
        }

        if (hasFile) {
            CollabFile file = fileMapper.selectById(request.getFileId());
            if (file == null || !recordId.equals(file.getRecordId())) {
                throw new BusinessException(ErrorCode.FILE_NOT_FOUND, "附件不存在或不属于本次交换");
            }
        }

        CollabMessage message = new CollabMessage()
                .setRecordId(recordId)
                .setSenderSno(senderSno)
                .setContent(hasText ? request.getContent().trim() : null)
                .setFileId(request.getFileId())
                .setMessageType(hasFile ? CollabMessage.TYPE_FILE : CollabMessage.TYPE_TEXT);
        messageMapper.insert(message);

        // 时间轴只记录一句摘要，完整内容在留言流里
        String summary = hasText
                ? abbreviate(request.getContent().trim(), 60)
                : "[附件] " + (fileMapper.selectById(request.getFileId()) == null
                        ? "文件" : fileMapper.selectById(request.getFileId()).getFileName());
        recordEvent(recordId, senderSno, CollabEvent.TYPE_MESSAGE, "留言：" + summary, null, "MESSAGE", message.getId());
        notificationService.sendToExchangeParties(recordId, senderSno,
                NotificationType.NEW_MESSAGE, "协作空间有新留言",
                displayName(senderSno) + "：" + summary);

        return toMessageVO(message, senderSno, null, null);
    }

    @Override
    public List<CollabMessageVO> listMessages(Long recordId, String viewerSno, int limit) {
        requireParticipant(recordId, viewerSno);
        int max = Math.min(MAX_MESSAGE_LIMIT, Math.max(1, limit <= 0 ? DEFAULT_MESSAGE_LIMIT : limit));
        return buildMessageVOs(recordId, viewerSno, max);
    }

    private List<CollabMessageVO> buildMessageVOs(Long recordId, String viewerSno, int limit) {
        // 取最近 limit 条（倒序查），再反转成正序给前端渲染聊天流
        List<CollabMessage> messages = messageMapper.selectList(new LambdaQueryWrapper<CollabMessage>()
                .eq(CollabMessage::getRecordId, recordId)
                .orderByDesc(CollabMessage::getCreatedAt)
                .last("LIMIT " + limit));
        if (messages.isEmpty()) {
            return List.of();
        }

        Set<String> snos = messages.stream().map(CollabMessage::getSenderSno)
                .filter(StringUtils::hasText).collect(Collectors.toCollection(LinkedHashSet::new));
        Map<String, Student> students = snos.isEmpty() ? Map.of()
                : studentMapper.selectBriefBySnos(snos).stream()
                .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));

        Set<Long> fileIds = messages.stream().map(CollabMessage::getFileId)
                .filter(java.util.Objects::nonNull).collect(Collectors.toCollection(LinkedHashSet::new));
        Map<Long, CollabFile> files = fileIds.isEmpty() ? Map.of()
                : fileMapper.selectBatchIds(fileIds).stream()
                .collect(Collectors.toMap(CollabFile::getId, f -> f, (a, b) -> a));

        List<CollabMessageVO> list = messages.stream()
                .map(m -> toMessageVO(m, viewerSno, students, files))
                .collect(Collectors.toList());
        // 反转为时间正序
        List<CollabMessageVO> ordered = new ArrayList<>(list);
        ordered.sort(Comparator.comparing(CollabMessageVO::getCreatedAt));
        return ordered;
    }

    private CollabMessageVO toMessageVO(CollabMessage message, String viewerSno,
                                        Map<String, Student> students, Map<Long, CollabFile> files) {
        CollabMessageVO vo = CollabMessageVO.of(message);
        if (vo == null) {
            return null;
        }
        vo.setMine(message.getSenderSno() != null && message.getSenderSno().equals(viewerSno));
        if (students != null) {
            Student s = students.get(message.getSenderSno());
            if (s != null) {
                vo.setSenderName(s.displayName());
                vo.setSenderCollege(s.getCollege());
            }
        } else if (StringUtils.hasText(message.getSenderSno())) {
            vo.setSenderName(displayName(message.getSenderSno()));
        }
        if (message.getFileId() != null) {
            CollabFile f = files != null ? files.get(message.getFileId()) : fileMapper.selectById(message.getFileId());
            if (f != null) {
                vo.setFileName(f.getFileName());
                vo.setFileSizeBytes(f.getSizeBytes());
            }
        }
        return vo;
    }

    /* ==================== 协作事件与时间轴（FR-M5-04） ==================== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void recordEvent(Long recordId, String actorSno, String eventType, String title,
                            String detail, String refType, Long refId) {
        if (recordId == null || !StringUtils.hasText(eventType) || !StringUtils.hasText(title)) {
            return;
        }
        try {
            CollabEvent event = new CollabEvent()
                    .setRecordId(recordId)
                    .setActorSno(actorSno)
                    .setEventType(eventType)
                    .setTitle(title)
                    .setDetail(trimToNull(detail))
                    .setRefType(refType)
                    .setRefId(refId);
            eventMapper.insert(event);
        } catch (Exception e) {
            // 时间轴是辅助信息，写失败不能影响主流程
            log.warn("[协作事件] 写入失败（已忽略）：record={} type={} - {}", recordId, eventType, e.getMessage());
        }
    }

    @Override
    public List<CollabEventVO> timeline(Long recordId, String viewerSno, int limit) {
        requireParticipant(recordId, viewerSno);
        return buildTimeline(recordId, viewerSno, limit);
    }

    private List<CollabEventVO> buildTimeline(Long recordId, String viewerSno, int limit) {
        int max = Math.min(MAX_TIMELINE_LIMIT, Math.max(1, limit <= 0 ? 100 : limit));
        List<CollabEvent> events = eventMapper.selectList(new LambdaQueryWrapper<CollabEvent>()
                .eq(CollabEvent::getRecordId, recordId)
                .orderByDesc(CollabEvent::getOccurredAt)
                .orderByDesc(CollabEvent::getId)
                .last("LIMIT " + max));
        if (events.isEmpty()) {
            return List.of();
        }
        Set<String> snos = events.stream().map(CollabEvent::getActorSno)
                .filter(StringUtils::hasText).collect(Collectors.toCollection(LinkedHashSet::new));
        Map<String, Student> students = snos.isEmpty() ? Map.of()
                : studentMapper.selectBriefBySnos(snos).stream()
                .collect(Collectors.toMap(Student::getSno, s -> s, (a, b) -> a));

        return events.stream().map(e -> {
            CollabEventVO vo = CollabEventVO.of(e);
            Student s = e.getActorSno() == null ? null : students.get(e.getActorSno());
            if (s != null) {
                vo.setActorName(s.displayName());
            }
            return vo;
        }).collect(Collectors.toList());
    }

    /* ==================== 过程性指标（FR-M5-06） ==================== */

    @Override
    public ProcessSummaryVO processSummary(Long recordId, String viewerSno) {
        ExchangeRecord record = requireParticipant(recordId, viewerSno);
        return computeProcessSummary(record);
    }

    /**
     * 计算过程性评价语料。
     *
     * <p><b>这些指标为什么重要</b>：创新点 1 的立论是"把无法在成绩单上体现的
     * 复合型隐性技能转化为可视化数字档案"。互评（M6）是主观判断，而这些指标是
     * 客观行为，两者并列呈现能显著压缩"凭印象打分"与"互刷好评"的空间。
     *
     * <p><b>为什么只给原始计数、不给综合评分</b>：加权口径应与 M6 的评价维度
     * 对齐并落库为不可篡改记录（FR-M6-03）。若在此处算分，会出现两套口径、
     * 无法追溯。因此这里只做可解释的聚合。
     */
    private ProcessSummaryVO computeProcessSummary(ExchangeRecord record) {
        Long recordId = record.getId();
        ProcessSummaryVO vo = new ProcessSummaryVO();
        vo.setRecordId(recordId);
        vo.setRecordNo(record.getRecordNo());
        if (record.getStatus() != null) {
            vo.setStatus(record.getStatus().name());
            vo.setStatusLabel(record.getStatus().getLabel());
        }
        vo.setStartedAt(record.getStartedAt());
        if (record.getStartedAt() != null) {
            vo.setDurationMinutes(Duration.between(record.getStartedAt(), LocalDateTime.now()).toMinutes());
        }

        /* ---------- 任务维度 ---------- */
        List<CollabTask> tasks = taskMapper.selectList(new LambdaQueryWrapper<CollabTask>()
                .eq(CollabTask::getRecordId, recordId));
        int total = tasks.size();
        int done = (int) tasks.stream().filter(t -> t.getStatus() == TaskStatus.DONE).count();
        // 已被协作方确认的任务数（FR-M5-08）—— 与 done 分开统计，见 ProcessSummaryVO 的说明
        int confirmed = (int) tasks.stream().filter(CollabTask::isConfirmed).count();
        int doing = (int) tasks.stream().filter(t -> t.getStatus() == TaskStatus.DOING).count();
        int todo = (int) tasks.stream().filter(t -> t.getStatus() == TaskStatus.TODO).count();
        int overdue = (int) tasks.stream().filter(CollabTask::isOverdue).count();

        vo.setTaskTotal(total);
        vo.setTaskDone(done);
        vo.setTaskConfirmed(confirmed);
        vo.setTaskDoing(doing);
        vo.setTaskTodo(todo);
        vo.setTaskOverdue(overdue);
        vo.setTaskCompletionRate(ratio(done, total));

        // 按期率：只统计"有截止时间且已完成"的任务，无截止时间的不进分母（否则会虚高）
        List<CollabTask> deadlined = tasks.stream()
                .filter(t -> t.getDeadline() != null && t.getStatus() == TaskStatus.DONE)
                .collect(Collectors.toList());
        long onTime = deadlined.stream()
                .filter(t -> t.getDoneAt() != null && !t.getDoneAt().isAfter(t.getDeadline()))
                .count();
        vo.setOnTimeRate(deadlined.isEmpty() ? null : ratio((int) onTime, deadlined.size()));

        // 拆解粒度：任务数 / 参与人数（2 人交换，所以等效于任务数的一半）
        int partyCount = (record.hasBothParties() ? 2 : 1);
        vo.setDecompositionGranularity(total == 0 ? 0.0 : round2(total * 1.0 / partyCount));

        /* ---------- 沟通维度 ---------- */
        int messageTotal = messageMapper.selectCount(new LambdaQueryWrapper<CollabMessage>()
                .eq(CollabMessage::getRecordId, recordId)
                .ne(CollabMessage::getMessageType, CollabMessage.TYPE_SYSTEM)).intValue();
        vo.setMessageTotal(messageTotal);

        // 启动速度：交换开始 → 第一个任务创建（或第一条留言）的小时数
        LocalDateTime firstTaskAt = tasks.stream().map(CollabTask::getCreatedAt)
                .filter(java.util.Objects::nonNull).min(LocalDateTime::compareTo).orElse(null);
        LocalDateTime firstMessageAt = messageMapper.selectList(new LambdaQueryWrapper<CollabMessage>()
                        .eq(CollabMessage::getRecordId, recordId)
                        .ne(CollabMessage::getMessageType, CollabMessage.TYPE_SYSTEM)
                        .orderByAsc(CollabMessage::getCreatedAt).last("LIMIT 1")).stream()
                .map(CollabMessage::getCreatedAt).findFirst().orElse(null);
        LocalDateTime firstAction = earliest(firstTaskAt, firstMessageAt);
        if (record.getStartedAt() != null && firstAction != null) {
            vo.setFirstActionDelayHours(round2(
                    Duration.between(record.getStartedAt(), firstAction).toMinutes() / 60.0));
        }

        // 停滞程度：最后一次协作动作距现在多久
        LocalDateTime lastActivity = eventMapper.selectList(new LambdaQueryWrapper<CollabEvent>()
                        .eq(CollabEvent::getRecordId, recordId)
                        .orderByDesc(CollabEvent::getOccurredAt).last("LIMIT 1")).stream()
                .map(CollabEvent::getOccurredAt).findFirst().orElse(null);
        if (lastActivity != null) {
            vo.setIdleMinutes(Duration.between(lastActivity, LocalDateTime.now()).toMinutes());
        }

        /* ---------- 交付维度 ---------- */
        vo.setFileUploadTotal(fileMapper.countUploads(recordId, null));
        vo.setFileGroupTotal((int) fileMapper.selectList(new LambdaQueryWrapper<CollabFile>()
                .eq(CollabFile::getRecordId, recordId)
                .select(CollabFile::getGroupKey)).stream()
                .map(CollabFile::getGroupKey).distinct().count());

        /* ---------- 按参与方拆分 ---------- */
        List<ProcessSummaryVO.ParticipantMetrics> participants = new ArrayList<>();
        if (StringUtils.hasText(record.getGiverSno())) {
            participants.add(participantMetrics(record.getGiverSno(), "GIVER", tasks, recordId));
        }
        if (StringUtils.hasText(record.getTakerSno())) {
            participants.add(participantMetrics(record.getTakerSno(), "TAKER", tasks, recordId));
        }
        vo.setParticipants(participants);
        return vo;
    }

    /**
     * 单个参与方的过程性指标。
     *
     * @param sno      学号
     * @param role     GIVER / TAKER
     * @param tasks    本次交换的全部任务（复用，避免重复查询）
     * @param recordId 交换记录 ID
     * @return 该方指标
     */
    private ProcessSummaryVO.ParticipantMetrics participantMetrics(String sno, String role,
                                                                   List<CollabTask> tasks, Long recordId) {
        ProcessSummaryVO.ParticipantMetrics m = new ProcessSummaryVO.ParticipantMetrics();
        m.setSno(sno);
        m.setRole(role);
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getSname, Student::getNickname, Student::getCollege)
                .eq(Student::getSno, sno));
        if (s != null) {
            m.setName(s.displayName());
            m.setCollege(s.getCollege());
        }

        List<CollabTask> assigned = tasks.stream()
                .filter(t -> sno.equals(t.getAssigneeSno()))
                .collect(Collectors.toList());
        int assignedDone = (int) assigned.stream().filter(t -> t.getStatus() == TaskStatus.DONE).count();
        m.setAssignedTasks(assigned.size());
        m.setDoneTasks(assignedDone);
        m.setCompletionRate(assigned.isEmpty() ? null : ratio(assignedDone, assigned.size()));
        m.setOverdueTasks((int) assigned.stream().filter(CollabTask::isOverdue).count());
        m.setSharedTasks((int) tasks.stream().filter(t -> t.getAssigneeSno() == null).count());

        m.setMessages(messageMapper.countBySender(recordId, sno));
        m.setFileUploads(fileMapper.countUploads(recordId, sno));

        int eventCount = eventMapper.selectList(new LambdaQueryWrapper<CollabEvent>()
                .eq(CollabEvent::getRecordId, recordId)
                .eq(CollabEvent::getActorSno, sno)).size();
        m.setEventCount(eventCount);

        m.setDigest(buildDigest(m));
        return m;
    }

    /** 生成一句话小结，供互评页面直接展示 */
    private String buildDigest(ProcessSummaryVO.ParticipantMetrics m) {
        StringBuilder sb = new StringBuilder();
        if (m.getAssignedTasks() == null || m.getAssignedTasks() == 0) {
            sb.append("暂未负责任务");
        } else {
            sb.append("负责任务 ").append(m.getAssignedTasks()).append(" 项，完成 ")
                    .append(m.getDoneTasks()).append(" 项");
            if (m.getCompletionRate() != null) {
                sb.append("（").append(Math.round(m.getCompletionRate() * 100)).append("%）");
            }
        }
        if (m.getOverdueTasks() != null && m.getOverdueTasks() > 0) {
            sb.append("，其中逾期 ").append(m.getOverdueTasks()).append(" 项");
        }
        sb.append("；留言 ").append(nvl(m.getMessages())).append(" 条")
                .append("，上传文件 ").append(nvl(m.getFileUploads())).append(" 次");
        return sb.toString();
    }

    /* ==================== 工具 ==================== */

    private String displayName(String sno) {
        if (!StringUtils.hasText(sno)) {
            return "未知用户";
        }
        Student s = studentMapper.selectOne(new LambdaQueryWrapper<Student>()
                .select(Student::getSno, Student::getSname, Student::getNickname)
                .eq(Student::getSno, sno));
        return s == null ? sno : s.displayName();
    }

    private static LocalDateTime earliest(LocalDateTime a, LocalDateTime b) {
        if (a == null) {
            return b;
        }
        if (b == null) {
            return a;
        }
        return a.isBefore(b) ? a : b;
    }

    private static Double ratio(int numerator, int denominator) {
        if (denominator <= 0) {
            return null;
        }
        return round2(numerator * 1.0 / denominator);
    }

    private static double round2(double v) {
        return Math.round(v * 100) / 100.0;
    }

    private static int nvl(Integer v) {
        return v == null ? 0 : v;
    }

    private static String abbreviate(String text, int max) {
        if (text == null) {
            return "";
        }
        return text.length() <= max ? text : text.substring(0, max) + "…";
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String t = value.trim();
        return t.isEmpty() ? null : t;
    }

    private static LocalDateTime parseDateTime(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        try {
            return LocalDateTime.parse(value.trim().replace(' ', 'T'));
        } catch (Exception e) {
            throw BusinessException.paramInvalid("时间格式不正确，应为 yyyy-MM-dd HH:mm:ss");
        }
    }
}
