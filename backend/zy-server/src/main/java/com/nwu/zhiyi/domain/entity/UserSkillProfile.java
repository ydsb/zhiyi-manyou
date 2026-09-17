package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.nwu.zhiyi.common.enums.SkillIntent;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户技能画像实体 —— 对应表 {@code zy_user_skill_profile}。
 *
 * <p>同一用户对同一技能只有一条记录，{@code intent} 区分"我擅长/我在研究/我急需"，
 * {@code score} 由协作完成度与互评结果累积，是能力雷达图的数据来源。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_user_skill_profile")
public class UserSkillProfile implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 学号 */
    private String sno;

    private Long skillId;

    /** 掌握等级 1~5 */
    private Integer level;

    /** 意图（数据库以枚举名存储） */
    private SkillIntent intent;

    /** 来源：SELF 自评 / PEER 互评 / COURSE 课程 */
    private String source;

    /** 画像得分，由协作与互评累积 */
    private BigDecimal score;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
