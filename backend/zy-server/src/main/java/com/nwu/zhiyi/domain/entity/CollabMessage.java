package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 协作空间留言实体 —— 对应表 {@code zy_collab_message}（FR-M5-07）。
 *
 * <p>在线沟通的文字与附件记录会<b>永久留存</b>，一方面用于计算过程性指标
 * （沟通频次、响应时长），另一方面在发生争议时可作为仲裁证据
 * （FR-M8-04 的"系统抽取全过程交互数据生成卷宗"）。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_collab_message")
public class CollabMessage implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 消息类型常量 */
    public static final String TYPE_TEXT = "TEXT";
    public static final String TYPE_FILE = "FILE";
    public static final String TYPE_SYSTEM = "SYSTEM";

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 所属交换记录 ID */
    private Long recordId;

    /** 发送人学号（系统消息为 null 或用 SYSTEM） */
    private String senderSno;

    /** 文字内容 */
    private String content;

    /** 附件文件 ID */
    private Long fileId;

    private String messageType;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 是否为系统消息 */
    public boolean isSystem() {
        return TYPE_SYSTEM.equals(messageType);
    }
}
