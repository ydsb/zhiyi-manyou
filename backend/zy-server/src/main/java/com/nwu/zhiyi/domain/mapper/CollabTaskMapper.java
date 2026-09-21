package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.CollabTask;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.Map;

/**
 * 协作空间任务项 Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface CollabTaskMapper extends BaseMapper<CollabTask> {

    /**
     * 统计某交换记录的任务完成情况（过程性评价指标）。
     *
     * @param recordId 交换记录 ID
     * @return 每行包含 total_count 与 done_count
     */
    @Select("SELECT COUNT(*) AS total_count, "
            + "SUM(CASE WHEN status = 'DONE' THEN 1 ELSE 0 END) AS done_count "
            + "FROM zy_collab_task WHERE record_id = #{recordId}")
    Map<String, Object> selectProgress(@Param("recordId") Long recordId);

    /**
     * 清除任务的确认状态与打卡标记（撤回重做时调用，FR-M5-08）。
     *
     * <p><b>为什么必须写成显式 SQL 而不能用 {@code updateById} 传 null</b>：
     * MyBatis-Plus 的默认更新策略会<b>跳过值为 null 的字段</b>
     * （{@code FieldStrategy.NOT_NULL}），因此把 {@code confirmedBy} 等设为 null
     * 再 {@code updateById}，这些列实际上不会被写 —— 结果是
     * {@code confirmed = 0} 但 {@code confirmed_by} 仍留着上一次的确认人，
     * 审计时会看到"未确认却带着确认人"的自相矛盾数据。
     *
     * <p>这个问题由端到端验证发现（撤回后 {@code confirmedBy} 仍有残留），
     * 单测覆盖不到是因为假 Mapper 不模拟 MP 的 null 跳过策略。
     *
     * @param taskId 任务 ID
     * @return 影响行数
     */
    @Update("UPDATE zy_collab_task SET "
            + "confirmed = 0, confirmed_by = NULL, confirmed_at = NULL, confirm_remark = NULL, "
            + "done_by = NULL, done_at = NULL "
            + "WHERE id = #{taskId}")
    int clearConfirmation(@Param("taskId") Long taskId);
}
