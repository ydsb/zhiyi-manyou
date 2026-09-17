package com.nwu.zhiyi.api.dto.collab;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.Serializable;

/**
 * 发送协作留言请求（FR-M5-07）。
 *
 * @author 李泽宬
 */
@Data
public class MessageSendRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 文字内容（与附件二选一，不能都为空） */
    @Size(max = 2000, message = "留言不能超过 2000 字")
    private String content;

    /** 已上传的附件文件 ID（先用文件上传接口拿到 id，再发消息引用） */
    private Long fileId;
}
