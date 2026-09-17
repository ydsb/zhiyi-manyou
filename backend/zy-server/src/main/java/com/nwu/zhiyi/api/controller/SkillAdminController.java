package com.nwu.zhiyi.api.controller;

import com.nwu.zhiyi.api.dto.skill.SkillRelationSaveRequest;
import com.nwu.zhiyi.api.dto.skill.SkillRelationVO;
import com.nwu.zhiyi.api.dto.skill.SkillSaveRequest;
import com.nwu.zhiyi.api.dto.skill.SkillVO;
import com.nwu.zhiyi.common.api.ApiResponse;
import com.nwu.zhiyi.service.skill.SkillService;
import com.nwu.zhiyi.service.skill.graph.SkillGraphService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

/**
 * 技能本体与图谱维护接口（管理端，FR-M9-02）。
 *
 * <p>{@code /api/admin/**} 需要 ADMIN 角色（见 SecurityConfig）。
 *
 * @author 李泽宬
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class SkillAdminController {

    private final SkillService skillService;
    private final SkillGraphService graphService;

    /**
     * 新增技能标签。
     *
     * <pre>POST /api/admin/skills</pre>
     */
    @PostMapping("/skills")
    public ApiResponse<SkillVO> create(@Valid @RequestBody SkillSaveRequest request) {
        return ApiResponse.success("技能标签已新增", skillService.create(request));
    }

    /**
     * 修改技能标签。
     *
     * <pre>PUT /api/admin/skills/{id}</pre>
     */
    @PutMapping("/skills/{id}")
    public ApiResponse<SkillVO> update(@PathVariable Long id, @Valid @RequestBody SkillSaveRequest request) {
        return ApiResponse.success("技能标签已更新", skillService.update(id, request));
    }

    /**
     * 删除技能标签（逻辑删除，并清理其图谱关系）。
     *
     * <pre>DELETE /api/admin/skills/{id}</pre>
     */
    @DeleteMapping("/skills/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        skillService.delete(id);
        return ApiResponse.success("技能标签已删除", null);
    }

    /**
     * 新增图谱关系。
     *
     * <pre>POST /api/admin/ontology/relations</pre>
     */
    @PostMapping("/ontology/relations")
    public ApiResponse<SkillRelationVO> createRelation(@Valid @RequestBody SkillRelationSaveRequest request) {
        SkillRelationVO vo = graphService.createRelation(
                request.getSrcSkillId(),
                request.getDstSkillId(),
                request.getRelationType(),
                request.getWeight(),
                request.getRemark());
        return ApiResponse.success("图谱关系已新增", vo);
    }

    /**
     * 删除图谱关系。
     *
     * <pre>DELETE /api/admin/ontology/relations/{id}</pre>
     */
    @DeleteMapping("/ontology/relations/{id}")
    public ApiResponse<Void> deleteRelation(@PathVariable Long id) {
        graphService.deleteRelation(id);
        return ApiResponse.success("图谱关系已删除", null);
    }
}
