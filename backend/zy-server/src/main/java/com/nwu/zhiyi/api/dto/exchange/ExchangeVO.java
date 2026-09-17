package com.nwu.zhiyi.api.dto.exchange;

import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 交换记录视图对象（FR-M4-04 / FR-M4-05 / FR-M4-06）。
 *
 * @author 李泽宬
 */
@Data
public class ExchangeVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private String recordNo;
    private String title;
    private String description;

    /* ---------------- 以技易技的双向描述 ---------------- */
    private PartySkill giver;
    private PartySkill taker;

    private String status;
    private String statusLabel;

    /** 当前状态下允许流转到的目标状态（前端据此渲染操作按钮） */
    private List<String> allowedNextStatus;

    /** 当前登录用户在本记录中的角色：GIVER / TAKER / OBSERVER */
    private String myRole;

    /** 当前登录用户可否执行的操作 */
    private Boolean canAccept;
    private Boolean canReject;
    private Boolean canCancel;
    private Boolean canStart;
    private Boolean canSubmitEval;
    private Boolean canDispute;

    private Long sourceDemandId;
    private Double matchScore;
    private Integer expectedHours;
    private Double actualHours;

    /**
     * 各阶段时间戳。
     *
     * <p>用 {@link LocalDateTime} 而非 String：全局 Jackson 配置已为该类型注册
     * {@code yyyy-MM-dd HH:mm:ss} 序列化器，声明为 String 会绕过它并产出 ISO 格式
     * （{@code 2026-09-17T20:36:49}），导致前端日期解析失败。
     */
    private LocalDateTime startedAt;
    private LocalDateTime deadlineAt;
    private LocalDateTime pendingEvalAt;
    private LocalDateTime finishedAt;
    private LocalDateTime createdAt;

    /** 参与方技能信息 */
    @Data
    public static class PartySkill {
        private String sno;
        private String name;
        private String college;
        /** 该方提供的技能 */
        private Long provideSkillId;
        private String provideSkillName;
        /** 该方获得的技能 */
        private Long acquireSkillId;
        private String acquireSkillName;
    }

    /**
     * 基础字段转换（技能名、参与方信息由服务层补齐）。
     *
     * @param record 交换记录
     * @return 视图对象
     */
    public static ExchangeVO of(ExchangeRecord record) {
        if (record == null) {
            return null;
        }
        ExchangeVO vo = new ExchangeVO();
        vo.setId(record.getId());
        vo.setRecordNo(record.getRecordNo());
        vo.setTitle(record.getTitle());
        vo.setDescription(record.getDescription());
        if (record.getStatus() != null) {
            vo.setStatus(record.getStatus().name());
            vo.setStatusLabel(record.getStatus().getLabel());
            vo.setAllowedNextStatus(record.getStatus().allowedNext().stream()
                    .map(Enum::name).sorted().collect(java.util.stream.Collectors.toList()));
        }
        vo.setSourceDemandId(record.getSourceDemandId());
        vo.setMatchScore(record.getMatchScore() == null ? null : record.getMatchScore().doubleValue());
        vo.setExpectedHours(record.getExpectedHours());
        vo.setActualHours(record.getActualHours() == null ? null : record.getActualHours().doubleValue());
        vo.setStartedAt(record.getStartedAt());
        vo.setDeadlineAt(record.getDeadlineAt());
        vo.setPendingEvalAt(record.getPendingEvalAt());
        vo.setFinishedAt(record.getFinishedAt());
        vo.setCreatedAt(record.getCreatedAt());
        return vo;
    }
}
