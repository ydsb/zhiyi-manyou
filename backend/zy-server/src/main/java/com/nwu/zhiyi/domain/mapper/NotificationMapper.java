package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

/**
 * 通知中心 Mapper（FR-M5-05）。
 *
 * @author 李泽宬
 */
@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {

    /**
     * 未读数量（用于顶栏红点）。
     *
     * @param sno 学号
     * @return 未读条数
     */
    @Select("SELECT COUNT(*) FROM zy_notification WHERE sno = #{sno} AND read_flag = 0")
    int countUnread(@Param("sno") String sno);

    /**
     * 全部标记为已读。
     *
     * @param sno 学号
     * @return 影响行数
     */
    @Update("UPDATE zy_notification SET read_flag = 1 WHERE sno = #{sno} AND read_flag = 0")
    int markAllRead(@Param("sno") String sno);

    /**
     * 幂等去重：判断某业务对象上的同类通知是否已存在（避免重复提醒）。
     *
     * @param sno     接收人
     * @param type    通知类型
     * @param refType 关联业务类型
     * @param refId   关联业务 ID
     * @return 已存在返回 true
     */
    @Select("SELECT EXISTS(SELECT 1 FROM zy_notification "
            + "WHERE sno = #{sno} AND type = #{type} AND ref_type = #{refType} AND ref_id = #{refId})")
    boolean exists(@Param("sno") String sno, @Param("type") String type,
                   @Param("refType") String refType, @Param("refId") Long refId);
}
