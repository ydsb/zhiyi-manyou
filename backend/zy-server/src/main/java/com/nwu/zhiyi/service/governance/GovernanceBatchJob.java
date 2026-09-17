package com.nwu.zhiyi.service.governance;

import com.nwu.zhiyi.service.credit.CreditService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 治理批处理任务（FR-M8-05 表决时限 / FR-M8-01 信用重算）。
 *
 * <p>两件事：
 * <ol>
 *   <li><b>结算超时争议</b>：表决时限到了必须有结果，否则争议无限期悬置 ——
 *       对当事人不公平，也让治理显得失效；</li>
 *   <li><b>批量重算信用</b>：交换完成、评价提交、裁决执行都会触发单点重算，
 *       但为了覆盖"没有触发点的变化"（例如争议结案改变了败诉率），
 *       每日兜底重算一次。</li>
 * </ol>
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class GovernanceBatchJob {

    private final ArbitrationService arbitrationService;
    private final CreditService creditService;
    private final StudentMapper studentMapper;

    /**
     * 每 30 分钟检查一次是否有超时的仲裁表决需要结算。
     *
     * <p>频率比信用重算高得多：表决超时是**用户可感知**的挂起状态，
     * 拖久了当事人会认为平台不处理。
     */
    @Scheduled(initialDelay = 150_000, fixedDelay = 1_800_000)
    public void settleExpiredDisputes() {
        try {
            int n = arbitrationService.settleExpired();
            if (n > 0) {
                log.info("[治理] 本轮结算 {} 起超时争议", n);
            }
        } catch (Exception e) {
            log.warn("[治理] 超时争议结算失败：{}", e.getMessage());
        }
    }

    /**
     * 每日 03:30 兜底重算全部用户信用值。
     *
     * <p>放在凌晨 3:30（勋章授予任务在 3:00）之后，避免两个批处理互相争抢资源。
     */
    @Scheduled(cron = "${zhiyi.governance.credit-cron:0 30 3 * * ?}")
    public void recalculateAllCredit() {
        List<Student> students = studentMapper.selectList(new LambdaQueryWrapper<Student>()
                .select(Student::getSno));
        int changed = 0;
        for (Student s : students) {
            try {
                if (creditService.recalculate(s.getSno(), "DAILY_BATCH").changed()) {
                    changed++;
                }
            } catch (Exception e) {
                log.warn("[信用] 重算失败 sno={} - {}", s.getSno(), e.getMessage());
            }
        }
        if (changed > 0) {
            log.info("[信用] 每日批量重算完成：{} 位用户信用值发生变化", changed);
        }
    }
}
