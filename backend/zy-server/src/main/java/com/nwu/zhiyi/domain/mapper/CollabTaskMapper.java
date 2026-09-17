package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.CollabTask;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

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
}
