package com.nwu.zhiyi.domain.mapper;

import com.nwu.zhiyi.domain.entity.NotificationOutboxEvent;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface NotificationOutboxMapper {
    @Insert("INSERT INTO zy_notification_outbox (sno,type,title,content,ref_type,ref_id,idempotency_key,status,attempts,next_attempt_at) " +
            "VALUES (#{sno},#{type},#{title},#{content},#{refType},#{refId},#{idempotencyKey},'PENDING',0,NOW()) " +
            "ON DUPLICATE KEY UPDATE id=id")
    int enqueue(@Param("sno") String sno, @Param("type") String type, @Param("title") String title,
                @Param("content") String content, @Param("refType") String refType, @Param("refId") Long refId,
                @Param("idempotencyKey") String idempotencyKey);

    @Select("SELECT id,sno,type,title,content,ref_type AS refType,ref_id AS refId,idempotency_key AS idempotencyKey," +
            "status,attempts,next_attempt_at AS nextAttemptAt,last_error AS lastError " +
            "FROM zy_notification_outbox WHERE status='PENDING' AND next_attempt_at<=NOW() " +
            "ORDER BY id LIMIT #{limit} FOR UPDATE SKIP LOCKED")
    List<NotificationOutboxEvent> lockNextBatch(@Param("limit") int limit);

    @Update("UPDATE zy_notification_outbox SET status='PROCESSING',locked_at=NOW() WHERE id=#{id} AND status='PENDING'")
    int markProcessing(@Param("id") long id);

    @Update("UPDATE zy_notification_outbox SET status='SENT',sent_at=NOW(),locked_at=NULL,last_error=NULL WHERE id=#{id}")
    int markSent(@Param("id") long id);

    @Update("UPDATE zy_notification_outbox SET attempts=attempts+1, " +
            "status=CASE WHEN attempts+1>=#{maxAttempts} THEN 'FAILED' ELSE 'PENDING' END, " +
            "next_attempt_at=DATE_ADD(NOW(), INTERVAL LEAST(3600, POW(2, LEAST(attempts,10))*5) SECOND), " +
            "locked_at=NULL,last_error=#{error} WHERE id=#{id}")
    int markFailed(@Param("id") long id, @Param("error") String error, @Param("maxAttempts") int maxAttempts);

    @Update("UPDATE zy_notification_outbox SET status='PENDING',locked_at=NULL,next_attempt_at=NOW() " +
            "WHERE status='PROCESSING' AND locked_at < DATE_SUB(NOW(), INTERVAL 10 MINUTE)")
    int recoverAbandoned();
}
