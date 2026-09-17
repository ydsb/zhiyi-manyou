package com.nwu.zhiyi.api.dto.collab;

import com.nwu.zhiyi.domain.entity.CollabMessage;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 协作留言视图对象（FR-M5-07）。
 *
 * @author 李泽宬
 */
@Data
public class CollabMessageVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long recordId;
    private String senderSno;
    private String senderName;
    private String senderCollege;
    private String content;
    private Long fileId;
    private String fileName;
    private Long fileSizeBytes;
    private String messageType;
    private LocalDateTime createdAt;

    /** 是否为当前用户发出的（前端据此左右分栏显示） */
    private Boolean mine;

    public static CollabMessageVO of(CollabMessage message) {
        if (message == null) {
            return null;
        }
        CollabMessageVO vo = new CollabMessageVO();
        vo.setId(message.getId());
        vo.setRecordId(message.getRecordId());
        vo.setSenderSno(message.getSenderSno());
        vo.setContent(message.getContent());
        vo.setFileId(message.getFileId());
        vo.setMessageType(message.getMessageType());
        vo.setCreatedAt(message.getCreatedAt());
        return vo;
    }
}
