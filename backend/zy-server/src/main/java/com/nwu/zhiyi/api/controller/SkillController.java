package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.skill.ParseResultVO;
import com.nwu.zhiyi.api.dto.skill.SkillMatchVO;
import com.nwu.zhiyi.api.dto.skill.SkillParseRequest;
import com.nwu.zhiyi.api.dto.skill.SkillTreeVO;
import com.nwu.zhiyi.api.dto.skill.SkillVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.service.skill.SkillService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import java.util.List;

/**
 * 技能本体接口（模块 M2）。
 *
 * <p>鉴权约定（见 SecurityConfig）：
 * <ul>
 *   <li>{@code /api/skills/tree}、{@code /api/skills/search} —— 匿名开放，
 *       供集市与技能图谱页在未登录时浏览</li>
 *   <li>其余接口需登录</li>
 * </ul>
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/skills")
@RequiredArgsConstructor
public class SkillController {

    private final SkillService skillService;

    /**
     * 三层技能标签树（FR-M2-04）。
     *
     * <pre>GET /api/skills/tree?categoryL1=工学&amp;keyword=前端</pre>
     */
    @GetMapping("/tree")
    public ApiResponse<SkillTreeVO> tree(
            @RequestParam(required = false) String categoryL1,
            @RequestParam(required = false) String keyword) {
        return ApiResponse.success(skillService.getTree(categoryL1, keyword));
    }

    /**
     * 关键词检索技能标签 —— 语义服务不可用时的降级匹配通道（NFR-R-03）。
     *
     * <pre>GET /api/skills/search?keyword=动画&amp;limit=20</pre>
     */
    @GetMapping("/search")
    public ApiResponse<List<SkillMatchVO>> search(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String categoryL1,
            @RequestParam(defaultValue = "20") int limit) {
        return ApiResponse.success(skillService.search(keyword, categoryL1, limit));
    }

    /**
     * 门类覆盖度统计（知识图谱建设进度看板）。
     *
     * <pre>GET /api/skills/stats</pre>
     */
    @GetMapping("/stats")
    public ApiResponse<List<SkillService.CategoryStat>> stats() {
        return ApiResponse.success(skillService.statsByCategory());
    }

    /**
     * 非结构化文本解析为标准化标签（FR-M2-01 ~ FR-M2-03）。
     *
     * <p>返回结果带匹配依据与三元组，前端据此做"回显确认 + 手工纠正"。
     *
     * <pre>POST /api/skills/parse</pre>
     */
    @PostMapping("/parse")
    public ApiResponse<ParseResultVO> parse(@Valid @RequestBody SkillParseRequest request) {
        int limit = request.getLimit() == null ? 10 : request.getLimit();
        boolean withGraph = request.getWithGraph() == null || request.getWithGraph();
        return ApiResponse.success(skillService.parse(request.getText(), limit, withGraph));
    }

    /**
     * 技能标签详情。
     *
     * <pre>GET /api/skills/{id}</pre>
     */
    @GetMapping("/{id}")
    public ApiResponse<SkillVO> detail(@PathVariable Long id) {
        return ApiResponse.success(skillService.getById(id));
    }
}
