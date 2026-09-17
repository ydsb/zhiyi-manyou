package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 技能与学科专业映射实体 —— 对应表 {@code zy_skill_course_mapping}。
 *
 * <p>用于解决跨学科分类问题：把标准化技能标签挂接到专业代码与教务课程上，
 * 为"以课程为切入场景"的试点运营提供依据。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_skill_course_mapping")
public class SkillCourseMapping implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private Long skillId;

    /** 专业代码 */
    private String majorCode;

    /** 专业名称 */
    private String majorName;

    /** 课程代码（教务映射） */
    private String courseCode;

    /** 课程名称 */
    private String courseName;

    /** 相关度 0~1 */
    private BigDecimal relevance;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
