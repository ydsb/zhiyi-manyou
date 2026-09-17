package com.nwu.zhiyi.service.skill;

import com.nwu.zhiyi.api.dto.skill.ParseResultVO;
import com.nwu.zhiyi.api.dto.skill.SkillMatchVO;
import com.nwu.zhiyi.api.dto.skill.SkillSaveRequest;
import com.nwu.zhiyi.api.dto.skill.SkillTreeVO;
import com.nwu.zhiyi.api.dto.skill.SkillVO;

import java.util.List;

/**
 * 技能本体服务（模块 M2）。
 *
 * <p>对应需求：
 * <ul>
 *   <li>FR-M2-01 自然语言发布技能供给/需求</li>
 *   <li>FR-M2-02 抽取 (主体, 动作, 技能实体) 三元组</li>
 *   <li>FR-M2-03 映射标准化标签并支持人工纠正</li>
 *   <li>FR-M2-04 三层分类体系（门类 → 二级学科 → 技能）</li>
 *   <li>FR-M2-07 同义词库维护</li>
 * </ul>
 *
 * @author 李泽宬
 */
public interface SkillService {

    /**
     * 查询三层技能标签树（FR-M2-04）。
     *
     * @param categoryL1 可选，按一级门类过滤
     * @param keyword    可选，按名称/别名模糊过滤
     * @return 标签树
     */
    SkillTreeVO getTree(String categoryL1, String keyword);

    /**
     * 关键词检索技能标签。
     *
     * <p>语义服务不可用时的降级通道（NFR-R-03）。
     *
     * @param keyword    关键词，可空（空则按热度返回）
     * @param categoryL1 可选门类过滤
     * @param limit      返回上限
     * @return 匹配列表
     */
    List<SkillMatchVO> search(String keyword, String categoryL1, int limit);

    /**
     * 按 ID 查询技能标签。
     *
     * @param id 主键
     * @return 技能详情
     */
    SkillVO getById(Long id);

    /**
     * 按门类统计标签数量（覆盖度看板）。
     *
     * @return 统计列表，元素含 name 与 count
     */
    List<CategoryStat> statsByCategory();

    /**
     * 解析非结构化文本为标准化标签（FR-M2-01 ~ FR-M2-03、FR-M2-06）。
     *
     * @param text      用户输入
     * @param limit     返回上限
     * @param withGraph 是否通过知识图谱补充隐性关联标签
     * @return 解析结果
     */
    ParseResultVO parse(String text, int limit, boolean withGraph);

    /**
     * 新增技能标签（FR-M9-02）。
     *
     * @param request 请求体
     * @return 新增后的技能
     */
    SkillVO create(SkillSaveRequest request);

    /**
     * 修改技能标签（FR-M9-02）。
     *
     * @param id      主键
     * @param request 请求体
     * @return 修改后的技能
     */
    SkillVO update(Long id, SkillSaveRequest request);

    /**
     * 删除技能标签（逻辑删除，同时清理其图谱关系）。
     *
     * @param id 主键
     */
    void delete(Long id);

    /**
     * 门类统计项。
     *
     * @param name  门类或学科名
     * @param count 标签数
     */
    record CategoryStat(String name, int count) {
    }
}
