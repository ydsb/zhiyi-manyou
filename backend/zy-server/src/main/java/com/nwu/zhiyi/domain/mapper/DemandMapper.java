package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.Demand;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Map;

/**
 * 技能需求卡片 Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface DemandMapper extends BaseMapper<Demand> {

    /**
     * 原子递增浏览次数，避免读-改-写造成并发覆盖。
     *
     * @param demandId 卡片 ID
     * @return 影响行数
     */
    @Update("UPDATE zy_demand SET view_count = view_count + 1 WHERE id = #{demandId} AND deleted = 0")
    int incrementViewCount(@Param("demandId") Long demandId);

    /**
     * 原子递增邀约数。
     *
     * @param demandId 卡片 ID
     * @return 影响行数
     */
    @Update("UPDATE zy_demand SET match_count = match_count + 1 WHERE id = #{demandId} AND deleted = 0")
    int incrementMatchCount(@Param("demandId") Long demandId);

    /**
     * 按状态统计卡片数量（运营看板）。
     *
     * @return 每行包含 status 与 demand_count
     */
    @org.apache.ibatis.annotations.Select("SELECT status, COUNT(*) AS demand_count FROM zy_demand "
            + "WHERE deleted = 0 GROUP BY status")
    List<Map<String, Object>> countGroupByStatus();

    /**
     * 按 ID 批量查询卡片，<b>包含已逻辑删除的记录</b>。
     *
     * <p>为什么需要绕过逻辑删除：交换意向（{@code zy_demand_interest}）是历史凭证，
     * 卡片被发布人删除后，意向记录依然存在。若这里走逻辑删除过滤，
     * 历史邀约就会丢失标题等上下文（表现为前端显示空标题）。
     * 用户查看自己的历史邀约时应当仍能看到当时申请的是哪张卡片。
     *
     * @param ids 卡片 ID 集合
     * @return 卡片列表（含已删除）
     */
    @org.apache.ibatis.annotations.Select("<script>"
            + "SELECT id, demand_no, owner_sno, title, description, expected_skill_id, offer_skill_id, "
            + "expected_hours, expected_period, visibility, status, match_count, view_count, "
            + "audit_status, audit_remark, expire_at, created_at, updated_at "
            + "FROM zy_demand WHERE id IN "
            + "<foreach collection='ids' item='i' open='(' separator=',' close=')'>#{i}</foreach>"
            + "</script>")
    List<Demand> selectIncludingDeletedByIds(@Param("ids") java.util.Collection<Long> ids);
}
