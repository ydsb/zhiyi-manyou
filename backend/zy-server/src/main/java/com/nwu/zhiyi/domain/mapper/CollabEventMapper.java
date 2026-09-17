package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.CollabEvent;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 协作事件 Mapper（FR-M5-04 / FR-M5-06）。
 *
 * @author 李泽宬
 */
@Mapper
public interface CollabEventMapper extends BaseMapper<CollabEvent> {

    /**
     * 按事件类型统计某人参与的所有交换中的事件数 —— 过程性指标的基础聚合。
     *
     * @param actorSno 学号
     * @param recordId 交换记录 ID
     * @return 每行包含 event_type 与 event_count
     */
    @Select("SELECT event_type, COUNT(*) AS event_count FROM zy_collab_event "
            + "WHERE actor_sno = #{actorSno} AND record_id = #{recordId} GROUP BY event_type")
    List<Map<String, Object>> countByActorAndRecord(@Param("actorSno") String actorSno,
                                                    @Param("recordId") Long recordId);

    /**
     * 某人参与的所有交换上的事件总数（跨交换的活跃度画像）。
     *
     * @param actorSno 学号
     * @return 每行包含 event_type 与 event_count
     */
    @Select("SELECT event_type, COUNT(*) AS event_count FROM zy_collab_event "
            + "WHERE actor_sno = #{actorSno} GROUP BY event_type")
    List<Map<String, Object>> countByActor(@Param("actorSno") String actorSno);

    /**
     * 取某交换内指定类型事件的最新一条时间 —— 用于"多久没动静了"这类逾期判断。
     *
     * @param recordId  交换记录 ID
     * @param eventType 事件类型
     * @return 最后发生时间，无记录返回 null
     */
    @Select("SELECT MAX(occurred_at) FROM zy_collab_event WHERE record_id = #{recordId} AND event_type = #{eventType}")
    java.time.LocalDateTime selectLastOccurredAt(@Param("recordId") Long recordId,
                                                 @Param("eventType") String eventType);
}
