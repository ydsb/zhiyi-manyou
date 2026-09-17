package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 技能交换流水 Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface ExchangeRecordMapper extends BaseMapper<ExchangeRecord> {

    /**
     * 统计某学号在"占用配额"状态下的进行中交换数量。
     *
     * @param sno 学号
     * @return 数量
     */
    @Select("SELECT COUNT(*) FROM zy_exchange_record WHERE deleted = 0 "
            + "AND status IN ('NEGOTIATING', 'IN_PROGRESS') "
            + "AND (giver_sno = #{sno} OR taker_sno = #{sno})")
    int countOngoing(@Param("sno") String sno);

    /**
     * 统计一对用户之间已完成的交换次数 —— 用于互刷信用检测。
     *
     * @param snoA 学号 A
     * @param snoB 学号 B
     * @return 已完成次数
     */
    @Select("SELECT COUNT(*) FROM zy_exchange_record WHERE deleted = 0 AND status = 'COMPLETED' "
            + "AND ((giver_sno = #{snoA} AND taker_sno = #{snoB}) "
            + "OR (giver_sno = #{snoB} AND taker_sno = #{snoA}))")
    int countCompletedBetween(@Param("snoA") String snoA, @Param("snoB") String snoB);

    /**
     * 按状态统计交换量（运营看板用）。
     *
     * @return 每行包含 status 与 record_count
     */
    @Select("SELECT status, COUNT(*) AS record_count FROM zy_exchange_record "
            + "WHERE deleted = 0 GROUP BY status")
    List<Map<String, Object>> countGroupByStatus();
}
