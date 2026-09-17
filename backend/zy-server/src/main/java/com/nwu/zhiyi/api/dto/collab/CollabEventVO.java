package com.nwu.zhiyi.api.dto.collab;

import com.nwu.zhiyi.domain.entity.CollabEvent;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 协作时间轴事件视图对象（FR-M5-04）。
 *
 * <p>{@code title} 在写入时已渲染完成，前端直接展示即可；
 * {@code icon} 与 {@code tone} 是给前端的展示提示（无需前端维护事件类型映射表）。
 *
 * @author 李泽宬
 */
@Data
public class CollabEventVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long recordId;
    private String actorSno;
    private String actorName;
    private String eventType;

    /** 已渲染好的时间轴标题 */
    private String title;
    private String detail;

    private String refType;
    private Long refId;

    private LocalDateTime occurredAt;

    /** 展示用图标（emoji，前端直接渲染） */
    private String icon;

    public static CollabEventVO of(CollabEvent event) {
        if (event == null) {
            return null;
        }
        CollabEventVO vo = new CollabEventVO();
        vo.setId(event.getId());
        vo.setRecordId(event.getRecordId());
        vo.setActorSno(event.getActorSno());
        vo.setEventType(event.getEventType());
        vo.setTitle(event.getTitle());
        vo.setDetail(event.getDetail());
        vo.setRefType(event.getRefType());
        vo.setRefId(event.getRefId());
        vo.setOccurredAt(event.getOccurredAt());
        vo.setIcon(iconOf(event.getEventType()));
        return vo;
    }

    /** 事件类型 → 展示图标 */
    public static String iconOf(String eventType) {
        if (eventType == null) {
            return "•";
        }
        switch (eventType) {
            case CollabEvent.TYPE_EXCHANGE_START:
                return "🚀";
            case CollabEvent.TYPE_TASK_CREATE:
                return "📋";
            case CollabEvent.TYPE_TASK_CLAIM:
                return "🙋";
            case CollabEvent.TYPE_TASK_DONE:
                return "✅";
            case CollabEvent.TYPE_TASK_OVERDUE:
                return "⏰";
            case CollabEvent.TYPE_FILE_UPLOAD:
                return "📎";
            case CollabEvent.TYPE_MESSAGE:
                return "💬";
            case CollabEvent.TYPE_STATUS_CHANGE:
                return "🔁";
            case CollabEvent.TYPE_CONFIRM:
                return "🤝";
            default:
                return "•";
        }
    }
}
