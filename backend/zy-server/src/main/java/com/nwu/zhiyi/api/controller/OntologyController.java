package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.skill.SkillRelationVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.service.skill.graph.SkillGraphService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 技能知识图谱接口（FR-M2-05 / FR-M2-08）。
 *
 * <p>{@code /api/ontology/**} 在 SecurityConfig 中为匿名开放，供技能图谱页展示。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/ontology")
@RequiredArgsConstructor
public class OntologyController {

    private final SkillGraphService graphService;

    /**
     * 全量图谱关系（可视化用）。
     *
     * <pre>GET /api/ontology/graph</pre>
     */
    @GetMapping("/graph")
    public ApiResponse<List<SkillRelationVO>> graph() {
        return ApiResponse.success(graphService.getAllRelations());
    }

    /**
     * 某技能的直接相邻关系。
     *
     * <pre>GET /api/ontology/skills/{skillId}/relations?relationType=COMPLEMENT</pre>
     */
    @GetMapping("/skills/{skillId}/relations")
    public ApiResponse<List<SkillRelationVO>> relationsOf(
            @PathVariable Long skillId,
            @RequestParam(required = false) String relationType) {
        return ApiResponse.success(graphService.getRelationsOf(skillId, relationType));
    }
}
