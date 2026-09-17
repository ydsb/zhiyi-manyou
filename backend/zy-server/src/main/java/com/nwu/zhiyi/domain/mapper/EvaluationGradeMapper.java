package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.EvaluationGrade;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Map;

/**
 * 双向互评成绩 Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface EvaluationGradeMapper extends BaseMapper<EvaluationGrade> {

    /**
     * 统计某交换记录已提交的评价数量（用于判断双方是否都已完成互评）。
     *
     * @param recordId 交换记录 ID
     * @return 已提交评价数（0/1/2）
     */
    @Select("SELECT COUNT(*) FROM zy_evaluation_grade WHERE record_id = #{recordId}")
    int countByRecord(@Param("recordId") Long recordId);

    /**
     * 统计某用户收到的评价均分与数量 —— 能力画像与信用计算的数据源。
     *
     * @param sno 被评价人学号
     * @return 每行包含 avg_score 与 eval_count
     */
    @Select("SELECT IFNULL(ROUND(AVG(total_score), 2), 0) AS avg_score, COUNT(*) AS eval_count "
            + "FROM zy_evaluation_grade WHERE to_sno = #{sno}")
    Map<String, Object> selectReceivedSummary(@Param("sno") String sno);
}
