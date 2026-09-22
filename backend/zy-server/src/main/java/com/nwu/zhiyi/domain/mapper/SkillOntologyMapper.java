package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.SkillOntology;
import lombok.Data;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
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
     * 查询给定技能集合的互补协作邻居，带上每条边的权重与"由哪个种子技能连过来"。
     *
     * <p>返回 {@code seed_id} 是为了让调用方能统计"某个候选标签能被几个不同的已命中
     * 技能连到" —— 这是图谱补全排序时最有效的相关性信号：能被多个种子共同指向的
     * 标签，比只被一个种子偶然连到的标签更可能是用户真正需要的。
     * 权重也要取出来：{@code augment()} 的分数公式依赖它。
     *
     * <p>本方法取代了早先的 {@code selectComplementNeighbors}（只返回邻居 ID）。
     * 那个版本的问题不只是丢信息：调用方拿到 ID 后还要对每个种子再调一次
     * {@code selectNeighbors}，等于把同一批边查了两遍。已删除，避免留下一条
     * 会再次被误用的"看起来能用但信息不全"的查询。
     *
     * @param skillIds 技能 ID 列表
     * @return 每行含 neighbor_id / seed_id / weight
     */
    @Select("<script>"
            + "SELECT CASE WHEN src_skill_id IN "
            + "<foreach collection='skillIds' item='id' open='(' separator=',' close=')'>#{id}</foreach>"
            + " THEN dst_skill_id ELSE src_skill_id END AS neighbor_id, "
            + "CASE WHEN src_skill_id IN "
            + "<foreach collection='skillIds' item='id' open='(' separator=',' close=')'>#{id}</foreach>"
            + " THEN src_skill_id ELSE dst_skill_id END AS seed_id, "
            + "weight AS weight "
            + "FROM zy_skill_ontology "
            + "WHERE relation_type = 'COMPLEMENT' AND (src_skill_id IN "
            + "<foreach collection='skillIds' item='id' open='(' separator=',' close=')'>#{id}</foreach>"
            + " OR dst_skill_id IN "
            + "<foreach collection='skillIds' item='id' open='(' separator=',' close=')'>#{id}</foreach>)"
            + "</script>")
    List<ComplementNeighborRow> selectComplementNeighborRows(@Param("skillIds") List<Long> skillIds);

    /**
     * 互补邻居查询的一行结果。
     *
     * <p>必须是**具体类**，不能是接口。MyBatis 通过无参构造 + setter 实例化结果对象，
     * 接口没有 {@code <init>()}，实测会抛
     * {@code ReflectionException: Error instantiating interface ... Cause:
     * NoSuchMethodException} —— 而且它被包装成 {@code MyBatisSystemException: null}
     * 抛到 GlobalExceptionHandler，日志里连原因都看不出来，只能靠翻 cause 链。
     * 单纯为了少写几行而用 Map 也不划算：列名写错时 Map 会静默给出 null，
     * 而这里会在启动/查询时直接报错。
     */
    @Data
    class ComplementNeighborRow {
        /** 候选邻居技能 ID（列名 neighbor_id） */
        private Long neighborId;

        /** 连到该邻居的种子技能 ID（列名 seed_id） */
        private Long seedId;

        /** 该条边的权重（列名 weight） */
        private BigDecimal weight;
    }
}
