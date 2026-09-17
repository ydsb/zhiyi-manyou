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
 * 技能标签导入批次 —— 对应表 {@code zy_skill_import_batch}（FR-M9-02）。
 *
 * <p>批量导入是高风险操作（一次可能写入上千条），必须能回答
 * "这批错误标签是谁在什么时候导进来的"。失败明细以 JSON 存储，
 * 供管理员一次性修正全部问题行。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_skill_import_batch")
public class SkillImportBatch implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String batchNo;

    private String operatorSno;

    private Integer totalCount;

    private Integer successCount;

    private Integer failCount;

    /** 失败明细 JSON（行号 + 内容 + 原因） */
    private String errors;

    /** 来源：ADMIN_UI / API / SEED */
    private String source;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
