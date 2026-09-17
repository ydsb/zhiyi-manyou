package com.nwu.zhiyi.service.notify;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.api.dto.collab.NotificationVO;
import com.nwu.zhiyi.common.enums.NotificationType;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.entity.Notification;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.NotificationMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 通知中心服务实现。
 *
 * <p><b>失败隔离</b>：通知是业务操作的<b>副作用</b>，发送失败不应该让主流程回滚
 * （例如"接受邀约"成功但通知写库失败，用户不该看到接受失败）。
 * 因此所有发送方法都自行捕获异常并记日志，不向外抛出。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationMapper notificationMapper;
    private final ExchangeRecordMapper exchangeMapper;

    /** 单次列表返回上限，防止一次性拉爆 */
    private static final int MAX_LIST_SIZE = 200;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void send(String sno, NotificationType type, String title, String content,
                     String refType, Long refId) {
        if (!StringUtils.hasText(sno)) {
            return;
        }
        try {
            Notification n = new Notification()
                    .setSno(sno)
                    .setType(type.code())
                    .setTitle(title)
                    .setContent(content)
                    .setRefType(refType)
                    .setRefId(refId)
                    .setReadFlag(0);
            notificationMapper.insert(n);
            log.debug("[通知] → {} | {} | {}", sno, type.getLabel(), title);
        } catch (Exception e) {
            // 通知失败不影响主流程
            log.warn("[通知] 发送失败（已忽略）：sno={} type={} - {}", sno, type, e.getMessage());
        }
    }

    @Override
    public boolean sendOnce(String sno, NotificationType type, String title, String content,
                            String refType, Long refId) {
        if (!StringUtils.hasText(sno)) {
            return false;
        }
        try {
            if (notificationMapper.exists(sno, type.code(), refType, refId)) {
                return false;
            }
        } catch (Exception e) {
            log.warn("[通知] 去重查询失败，改为直接发送：{}", e.getMessage());
        }
        send(sno, type, title, content, refType, refId);
        return true;
    }

    @Override
    public void sendToExchangeParties(Long recordId, String exceptSno, NotificationType type,
                                      String title, String content) {
        if (recordId == null) {
            return;
        }
        ExchangeRecord record = exchangeMapper.selectById(recordId);
        if (record == null) {
            log.warn("[通知] 交换记录不存在，跳过：recordId={}", recordId);
            return;
        }
        for (String sno : new String[]{record.getGiverSno(), record.getTakerSno()}) {
            if (!StringUtils.hasText(sno) || sno.equals(exceptSno)) {
                continue;
            }
            send(sno, type, title, content, "EXCHANGE", recordId);
        }
    }

    @Override
    public List<NotificationVO> list(String sno, boolean onlyUnread, int limit) {
        int max = Math.min(MAX_LIST_SIZE, Math.max(1, limit));
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<Notification>()
                .eq(Notification::getSno, sno)
                .orderByDesc(Notification::getCreatedAt);
        if (onlyUnread) {
            wrapper.eq(Notification::getReadFlag, 0);
        }
        wrapper.last("LIMIT " + max);
        return notificationMapper.selectList(wrapper).stream()
                .map(NotificationVO::of)
                .collect(Collectors.toList());
    }

    @Override
    public int unreadCount(String sno) {
        return notificationMapper.countUnread(sno);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markRead(String sno, Long id) {
        Notification n = notificationMapper.selectById(id);
        if (n == null) {
            throw BusinessException.notFound("通知不存在：" + id);
        }
        if (!sno.equals(n.getSno())) {
            throw new BusinessException(com.nwu.zhiyi.common.api.ErrorCode.FORBIDDEN, "只能操作自己的通知");
        }
        if (n.getReadFlag() != null && n.getReadFlag() == 1) {
            return;
        }
        notificationMapper.updateById(new Notification().setId(id).setReadFlag(1));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markAllRead(String sno) {
        return notificationMapper.markAllRead(sno);
    }
}
