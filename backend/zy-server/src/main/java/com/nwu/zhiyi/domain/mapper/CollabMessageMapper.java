package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.CollabMessage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 协作空间留言 Mapper（FR-M5-07）。
 *
 * @author 李泽宬
 */
@Mapper
public interface CollabMessageMapper extends BaseMapper<CollabMessage> {

    /**
     * 统计某交换内某人的留言条数（过程性指标：沟通频次）。
     *
     * <p><b>注意</b>：注解式 {@code @Select} 是纯字符串，<b>不经过 XML 解析</b>，
     * 因此不能写 {@code &lt;&gt;} 这类 XML 实体，否则会被原样发给数据库导致语法错误
     * （本项目踩过：{@code near '&gt; 'SYSTEM''}）。这里直接用 {@code <>}。
     *
     * @param recordId  交换记录 ID
     * @param senderSno 发送人学号
     * @return 条数
     */
    @Select("SELECT COUNT(*) FROM zy_collab_message "
            + "WHERE record_id = #{recordId} AND sender_sno = #{senderSno} AND message_type <> 'SYSTEM'")
    int countBySender(@Param("recordId") Long recordId, @Param("senderSno") String senderSno);

    /**
     * 某交换内最后一条真实留言的时间 —— 用于计算"未回复时长"。
     *
     * @param recordId 交换记录 ID
     * @return 时间，无留言返回 null
     */
    @Select("SELECT MAX(created_at) FROM zy_collab_message "
            + "WHERE record_id = #{recordId} AND message_type <> 'SYSTEM'")
    java.time.LocalDateTime selectLastMessageAt(@Param("recordId") Long recordId);
}
