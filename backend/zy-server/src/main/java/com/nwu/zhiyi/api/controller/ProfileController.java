package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.UserInfoVO;
import com.nwu.zhiyi.api.dto.profile.AbilityReportVO;
import com.nwu.zhiyi.api.dto.profile.BadgeVO;
import com.nwu.zhiyi.api.dto.profile.DataExportVO;
import com.nwu.zhiyi.api.dto.profile.GrowthTrendVO;
import com.nwu.zhiyi.api.dto.profile.ProfileUpdateRequest;
import com.nwu.zhiyi.api.dto.profile.RadarChartVO;
import com.nwu.zhiyi.api.dto.profile.SkillProfileSaveRequest;
import com.nwu.zhiyi.api.dto.profile.SkillProfileVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.security.SecurityUtils;
import com.nwu.zhiyi.service.AuthService;
import com.nwu.zhiyi.service.profile.DataExportService;
import com.nwu.zhiyi.service.profile.ProfileService;
import com.nwu.zhiyi.service.profile.SkillProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;

/**
 * 数字档案与能力画像接口（模块 M7）。
 *
 * <p>全部返回"我的"数据，因此学号一律取自登录态，不接受前端传入 ——
 * 避免越权查看他人画像。
 *
 * <p>{@code PUT /api/profile} 落在本控制器是因为它同属"我的资料"这一族；
 * 实现委托给 {@link AuthService}（资料本体归 M1 认证模块维护），
 * 避免把 Student 的写逻辑散到两处。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;
    private final SkillProfileService skillProfileService;
    private final DataExportService dataExportService;
    private final AuthService authService;

    /**
     * 导出我的全部个人数据（FR-M1-07）。
     *
     * <p>返回结构化 JSON，供用户备份、迁移或自行分析。
     * 与《能力鉴定报告》（给第三方看的凭证）分工不同 —— 报告面向简历与测评，
     * 本接口面向用户自己的完整底稿。
     *
     * <p>隐私边界：只含关于我的数据；不含我对他人的评价原文、
     * 不含他人学号与联系方式；匿名互评保持匿名。
     *
     * <pre>GET /api/profile/export</pre>
     */
    @GetMapping("/export")
    public ApiResponse<DataExportVO> exportData() {
        DataExportVO data = dataExportService.export(SecurityUtils.currentSno());
        int total = data.getCounts() == null ? 0
                : data.getCounts().values().stream().mapToInt(Integer::intValue).sum();
        return ApiResponse.success("已导出 " + total + " 条个人数据", data);
    }

    /**
     * 修改个人资料（FR-M1-05）。
     *
     * <p>可改：昵称、学院、专业、年级、头像、简介。
     * 学号、姓名、角色、信用值、核验状态不可经此接口改动 —— 见
     * {@code ProfileUpdateRequest} 的字段说明。
     *
     * <p>字段为 null 表示不修改；传空串表示清空。
     *
     * <pre>PUT /api/profile</pre>
     */
    @PutMapping
    public ApiResponse<UserInfoVO> updateProfile(@Valid @RequestBody ProfileUpdateRequest request) {
        return ApiResponse.success("资料已保存",
                authService.updateProfile(SecurityUtils.currentSno(), request));
    }

    /**
     * 我的技能画像（FR-M1-03 / FR-M2-02）。
     *
     * <p>按「我擅长 / 我正在研究 / 我急需」三组返回，供导引页回显与后续编辑。
     * {@code firstLogin=true} 表示尚无画像，前端应引导至导引页 ——
     * 该字段在登录响应里也有，但刷新页面后登录响应就丢了，
     * 所以这里再提供一次，让"是否已完成导引"的判断不依赖前端内存状态。
     *
     * <pre>GET /api/profile/skills</pre>
     */
    @GetMapping("/skills")
    public ApiResponse<SkillProfileVO> mySkills() {
        return ApiResponse.success(skillProfileService.mine(SecurityUtils.currentSno()));
    }

    /**
     * 保存我的技能画像（FR-M1-03），整体覆盖自评部分。
     *
     * <p>导引页三步选择与「技能画像」页的编辑共用本接口。
     * 互评（PEER）与课程（COURSE）来源的记录不会被覆盖删除，见服务实现说明。
     *
     * <pre>POST /api/profile/skills</pre>
     */
    @PostMapping("/skills")
    public ApiResponse<SkillProfileVO> saveSkills(@Valid @RequestBody SkillProfileSaveRequest request) {
        String sno = SecurityUtils.currentSno();
        SkillProfileVO vo = skillProfileService.save(sno, request);
        return ApiResponse.success(
                "已保存 " + vo.getTotal() + " 个技能标签，画像已更新", vo);
    }

    /**
     * 能力雷达图（FR-M7-01 / FR-M7-02 / AC-06）。
     *
     * <p>实时计算，保证完成一次交换后立即反映在雷达图上。
     *
     * <pre>GET /api/profile/radar</pre>
     */
    @GetMapping("/radar")
    public ApiResponse<RadarChartVO> radar() {
        return ApiResponse.success(profileService.radar(SecurityUtils.currentSno()));
    }

    /**
     * 成长轨迹（FR-M7-07）：基于月度快照的历史曲线。
     *
     * <pre>GET /api/profile/growth?limit=12</pre>
     */
    @GetMapping("/growth")
    public ApiResponse<GrowthTrendVO> growth(@RequestParam(defaultValue = "12") int limit) {
        return ApiResponse.success(profileService.growthTrend(SecurityUtils.currentSno(), limit));
    }

    /**
     * 勋章列表（FR-M7-04）：已解锁与未解锁都返回，未解锁带进度提示。
     *
     * <pre>GET /api/profile/badges</pre>
     */
    @GetMapping("/badges")
    public ApiResponse<List<BadgeVO>> badges() {
        return ApiResponse.success(profileService.badges(SecurityUtils.currentSno()));
    }

    /**
     * 手动刷新能力画像并落快照（FR-M7-03）。
     *
     * <p>主页雷达图是实时计算，这个接口用于把当前值固化为一个历史数据点，
     * 让成长轨迹立刻能看到变化（不必等月度批处理）。
     *
     * <pre>POST /api/profile/snapshot</pre>
     */
    @PostMapping("/snapshot")
    public ApiResponse<Map<String, Object>> snapshot() {
        String sno = SecurityUtils.currentSno();
        String period = java.time.LocalDate.now().toString();
        Long id = profileService.snapshot(sno, period, "MANUAL");
        Map<String, Object> data = new java.util.LinkedHashMap<>();
        data.put("snapshotId", id);
        data.put("period", period);
        data.put("message", id == null
                ? "暂无已完成且有互评的交换，未生成快照"
                : "已固化当前画像为快照点，可在成长轨迹中查看");
        return ApiResponse.success(data.get("message").toString(), data);
    }

    /**
     * 一键生成《跨学科协作能力鉴定报告》（FR-M7-06 / FR-M7-08）。
     *
     * <p>返回结构化报告数据，前端据此排版为 PDF；报告带 M6 校验码可在线验真。
     *
     * <pre>GET /api/profile/report</pre>
     */
    @GetMapping("/report")
    public ApiResponse<AbilityReportVO> report() {
        return ApiResponse.success(profileService.report(SecurityUtils.currentSno()));
    }

    /**
     * 我的成长周报列表（FR-M7-05）。
     *
     * <pre>GET /api/profile/weekly-reports?limit=12</pre>
     */
    @GetMapping("/weekly-reports")
    public ApiResponse<List<Map<String, Object>>> weeklyReports(@RequestParam(defaultValue = "12") int limit) {
        return ApiResponse.success(profileService.weeklyReports(SecurityUtils.currentSno(), limit));
    }
}
