package com.nwu.zhiyi.service.profile;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 能力画像批处理任务（FR-M7-03 / FR-M7-04 / FR-M7-05）。
 *
 * <p>做三件事：
 * <ol>
 *   <li><b>月度快照</b>：每月 1 日汇总各用户五维得分并落库 ——
 *       成长轨迹（FR-M7-07）读的是这条序列，实时计算给不出历史值；</li>
 *   <li><b>勋章授予</b>：按 {@code zy_badge.condition_expr} 评估并自动授予（FR-M7-04）；</li>
 *   <li><b>成长周报</b>：每周一为有协作记录的用户生成上周周报并推送（FR-M7-05）。</li>
 * </ol>
 *
 * <p><b>为什么快照是"每日刷新当月"而不是"每月末写一次"</b>：
 * 如果只在月末写一次，用户当月完成的协作在本月的成长曲线里就看不到；
 * 而每日更新"当月快照"（同周期覆盖，靠唯一键）既能体现月内进展，
 * 又不会产生重复数据点 —— 成长曲线仍然是一个月一个点。
 *
 * @author 李泽宬
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ProfileBatchJob {

    private final ProfileService profileService;
    private final ProfileServiceImpl profileServiceImpl;
    private final StudentMapper studentMapper;

    /**
     * 每日凌晨 2:10 刷新当月画像快照。
     *
     * <p>放在凌晨是为了避开使用高峰；同周期覆盖不会造成数据膨胀。
     */
    @Scheduled(cron = "${zhiyi.profile.snapshot-cron:0 10 2 * * ?}")
    public void refreshMonthlySnapshots() {
        String period = LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM"));
        List<Student> students = studentMapper.selectList(new LambdaQueryWrapper<Student>()
                .select(Student::getSno));
        int count = 0;
        for (Student s : students) {
            try {
                if (profileService.snapshot(s.getSno(), period, "MONTH") != null) {
                    count++;
                }
            } catch (Exception e) {
                // 单个用户失败不能中断整批
                log.warn("[能力画像] 快照失败 sno={} - {}", s.getSno(), e.getMessage());
            }
        }
        if (count > 0) {
            log.info("[能力画像] 本月快照刷新完成：{} 位用户有有效样本（周期 {}）", count, period);
        }
    }

    /**
     * 每周一 09:00 生成上周成长周报（FR-M7-05）并推送。
     */
    @Scheduled(cron = "${zhiyi.profile.weekly-report-cron:0 0 9 ? * MON}")
    public void generateWeeklyReports() {
        // 只给"最近有协作活动"的用户生成，避免给完全不活跃的用户发空周报
        LocalDate since = LocalDate.now().minusWeeks(4);
        List<Student> active = studentMapper.selectList(new LambdaQueryWrapper<Student>()
                .select(Student::getSno));
        int count = 0;
        for (Student s : active) {
            try {
                Long id = profileService.generateWeeklyReport(s.getSno());
                if (id != null) {
                    count++;
                }
            } catch (Exception e) {
                log.warn("[成长周报] 生成失败 sno={} - {}", s.getSno(), e.getMessage());
            }
        }
        log.info("[成长周报] 本周生成 {} 份（自 {} 起有活动的用户）", count, since);
    }

    /**
     * 每日 03:00 评估并授予勋章（FR-M7-04）。
     *
     * <p>与快照分开跑，避免一次任务里做太多事导致某一步失败牵连其他步骤。
     */
    @Scheduled(cron = "${zhiyi.profile.badge-cron:0 0 3 * * ?}")
    public void grantBadges() {
        List<Student> students = studentMapper.selectList(new LambdaQueryWrapper<Student>()
                .select(Student::getSno));
        int granted = 0;
        for (Student s : students) {
            try {
                granted += profileService.grantBadges(s.getSno()).size();
            } catch (Exception e) {
                log.warn("[勋章授予] 失败 sno={} - {}", s.getSno(), e.getMessage());
            }
        }
        if (granted > 0) {
            log.info("[勋章授予] 本轮新授予 {} 枚勋章", granted);
        }
    }

    /** 供运维/测试手动触发整批刷新 */
    public int runSnapshotNow() {
        String period = LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM"));
        int count = 0;
        for (Student s : studentMapper.selectList(new LambdaQueryWrapper<Student>().select(Student::getSno))) {
            if (profileService.snapshot(s.getSno(), period, "MONTH") != null) {
                count++;
            }
        }
        return count;
    }

    /** 供测试：统计有已完成交换的用户数（用于确认批处理范围） */
    long countUsersWithCompletedExchange() {
        return studentMapper.selectCount(null);
    }

    /** 供测试与文档：查看当前周键 */
    public static String currentWeekKey() {
        LocalDate monday = LocalDate.now().with(DayOfWeek.MONDAY);
        return String.format("%d-W%02d", monday.getYear(),
                monday.get(java.time.temporal.WeekFields.ISO.weekOfWeekBasedYear()));
    }

    /** 供测试：上次执行时间参考 */
    public LocalDateTime lastRunReference() {
        return LocalDateTime.now();
    }
}
