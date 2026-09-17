package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.SkillOntology;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 技能知识图谱关系 Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface SkillOntologyMapper extends BaseMapper<SkillOntology> {

    /**
     * 查询与给定技能直接相邻的边（双向，含无向边）。
     *
     * @param skillId 技能 ID
     * @return 相邻关系列表
     */
    @Select("SELECT * FROM zy_skill_ontology WHERE src_skill_id = #{skillId} OR dst_skill_id = #{skillId}")
    List<SkillOntology> selectNeighbors(@Param("skillId") Long skillId);

    /**
     * 查询给定技能集合的互补协作邻居技能 ID —— 用于挖掘隐性跨学科需求。
     *
     * @param skillIds 技能 ID 列表
     * @return 邻居技能 ID 列表
     */
    @Select("<script>"
            + "SELECT DISTINCT CASE WHEN src_skill_id IN "
            + "<foreach collection='skillIds' item='id' open='(' separator=',' close=')'>#{id}</foreach>"
            + " THEN dst_skill_id ELSE src_skill_id END AS neighbor_id "
            + "FROM zy_skill_ontology "
            + "WHERE relation_type = 'COMPLEMENT' AND (src_skill_id IN "
            + "<foreach collection='skillIds' item='id' open='(' separator=',' close=')'>#{id}</foreach>"
            + " OR dst_skill_id IN "
            + "<foreach collection='skillIds' item='id' open='(' separator=',' close=')'>#{id}</foreach>)"
            + "</script>")
    List<Long> selectComplementNeighbors(@Param("skillIds") List<Long> skillIds);
}
