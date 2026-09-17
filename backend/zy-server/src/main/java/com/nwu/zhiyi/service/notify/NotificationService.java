package com.nwu.zhiyi.service.notify;

import com.nwu.zhiyi.api.dto.collab.NotificationVO;
import com.nwu.zhiyi.common.enums.NotificationType;

import java.util.List;

/**
 * 通知中心服务（FR-M5-05）。
 *
 * <p>覆盖需求要求的四类提醒：邀约、打卡提醒、互评提醒、裁决通知，
 * 另外补了任务动态、新留言、收到评价、勋章与系统通知。
 *
 * <p><b>依赖方向</b>：本服务只依赖 Mapper 层，<b>不</b>注入 M4/M5 的业务服务。
 * 因为交换与协作服务都需要发通知，如果通知服务反过来依赖它们就会形成循环依赖
 * （Spring Boot 2.6+ 默认禁止）。需要参与方信息时直接查 {@code ExchangeRecordMapper}。
 *
 * @author 李泽宬
 */
public interface NotificationService {

    /**
     * 发送通知。
     *
     * @param sno     接收人学号
     * @param type    通知类型
     * @param title   标题
     * @param content 内容
     * @param refType 关联业务类型
     * @param refId   关联业务 ID
     */
    void send(String sno, NotificationType type, String title, String content, String refType, Long refId);

    /**
     * 幂等发送：同一接收人 + 同一通知类型 + 同一业务对象只发一次。
     *
     * <p>用于"邀约已发送""提醒打卡"这类可能被重复触发的场景，避免骚扰。
     *
     * @param sno     接收人
     * @param type    通知类型
     * @param title   标题
     * @param content 内容
     * @param refType 关联业务类型
     * @param refId   关联业务 ID
     * @return 实际发送返回 true，因已存在而跳过返回 false
     */
    boolean sendOnce(String sno, NotificationType type, String title, String content, String refType, Long refId);

    /**
     * 通知交换的双方。
     *
     * @param recordId  交换记录 ID
     * @param exceptSno 排除的学号（通常是操作人自己）
     * @param type      通知类型
     * @param title     标题
     * @param content   内容
     */
    void sendToExchangeParties(Long recordId, String exceptSno, NotificationType type,
                               String title, String content);

    /**
     * 我的通知列表（最新的在前）。
     *
     * @param sno       学号
     * @param onlyUnread 是否只看未读
     * @param limit     返回上限
     * @return 通知列表
     */
    List<NotificationVO> list(String sno, boolean onlyUnread, int limit);

    /**
     * 未读数量。
     *
     * @param sno 学号
     * @return 未读数
     */
    int unreadCount(String sno);

    /**
     * 标记单条已读。
     *
     * @param sno 学号
     * @param id  通知 ID
     */
    void markRead(String sno, Long id);

    /**
     * 全部标记已读。
     *
     * @param sno 学号
     * @return 影响行数
     */
    int markAllRead(String sno);
}
