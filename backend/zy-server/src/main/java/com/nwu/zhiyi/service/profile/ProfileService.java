package com.nwu.zhiyi.service.profile;

import com.nwu.zhiyi.api.dto.profile.AbilityReportVO;
import com.nwu.zhiyi.api.dto.profile.BadgeVO;
import com.nwu.zhiyi.api.dto.profile.GrowthTrendVO;
import com.nwu.zhiyi.api.dto.profile.RadarChartVO;

import java.util.List;

/**
 * 数字档案与能力画像服务（模块 M7）。
 *
 * <p>对应需求：
 * <ul>
 *   <li>FR-M7-01/02 个人能力雷达图（登录后主页）</li>
 *   <li>FR-M7-03 批处理汇总协作时长与质量得分，驱动雷达图更新</li>
 *   <li>FR-M7-04 数字勋章体系，按成果达成自动授予</li>
 *   <li>FR-M7-05 智能成长周报</li>
 *   <li>FR-M7-06/08 一键导出带验证码的《跨学科协作能力鉴定报告》</li>
 *   <li>FR-M7-07 成长轨迹时间线（历史变化曲线）</li>
 * </ul>
 *
 * @author 李泽宬
 */
public interface ProfileService {

    /**
     * 能力雷达图数据（FR-M7-01 / FR-M7-02）。
     *
     * <p>实时计算，保证 AC-06「雷达图随协作数据变化正确刷新」。
     *
     * @param sno 学号
     * @return 雷达图数据（含每个维度的分数出处说明）
     */
    RadarChartVO radar(String sno);

    /**
     * 生成并保存一次能力画像快照（FR-M7-03）。
     *
     * @param sno        学号
     * @param period     周期标识
     * @param periodType MONTH / MANUAL
     * @return 落库的快照 ID；无样本时返回 null
     */
    Long snapshot(String sno, String period, String periodType);

    /**
     * 成长轨迹（FR-M7-07）：读快照序列。
     *
     * @param sno   学号
     * @param limit 最多返回多少个时间点
     * @return 轨迹数据
     */
    GrowthTrendVO growthTrend(String sno, int limit);

    /**
     * 勋章列表（FR-M7-04）：已解锁与未解锁都返回，未解锁带进度提示。
     *
     * @param sno 学号
     * @return 勋章列表
     */
    List<BadgeVO> badges(String sno);

    /**
     * 评估并授予勋章（FR-M7-04 自动授予）。
     *
     * @param sno 学号
     * @return 本次新授予的勋章
     */
    List<BadgeVO> grantBadges(String sno);

    /**
     * 生成《跨学科协作能力鉴定报告》（FR-M7-06 / FR-M7-08）。
     *
     * @param sno 学号
     * @return 报告数据（结构化，前端排版为 PDF）
     */
    AbilityReportVO report(String sno);

    /**
     * 生成某用户的成长周报（FR-M7-05）。
     *
     * @param sno 学号
     * @return 周报 ID
     */
    Long generateWeeklyReport(String sno);

    /**
     * 读取我的周报列表（FR-M7-05）。
     *
     * @param sno   学号
     * @param limit 条数
     * @return 周报列表
     */
    List<java.util.Map<String, Object>> weeklyReports(String sno, int limit);
}
