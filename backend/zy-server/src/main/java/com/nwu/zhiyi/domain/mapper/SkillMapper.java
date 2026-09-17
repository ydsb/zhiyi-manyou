package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.Skill;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * 技能标签 Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface SkillMapper extends BaseMapper<Skill> {

    /**
     * 按一级门类统计标签数量（知识图谱覆盖度看板用）。
     *
     * @return 每行包含 category_l1 与 skill_count
     */
    @Select("SELECT category_l1, COUNT(*) AS skill_count FROM zy_skill "
            + "WHERE status = 1 GROUP BY category_l1 ORDER BY skill_count DESC")
    List<Map<String, Object>> countGroupByCategoryL1();

    /**
     * 关键词/别名模糊检索 —— 语义服务不可用时的降级匹配通道。
     *
     * @param keyword 关键词
     * @param limit   返回条数
     * @return 命中技能列表
     */
    @Select("SELECT * FROM zy_skill WHERE status = 1 AND (name LIKE CONCAT('%', #{keyword}, '%') "
            + "OR alias LIKE CONCAT('%', #{keyword}, '%') OR description LIKE CONCAT('%', #{keyword}, '%')) "
            + "ORDER BY hot_score DESC LIMIT #{limit}")
    List<Skill> searchByKeyword(@Param("keyword") String keyword, @Param("limit") int limit);

    /**
     * 增加技能热度分（发布/匹配命中时调用）。
     *
     * @param skillId 技能 ID
     * @param delta   增量
     * @return 影响行数
     */
    @Update("UPDATE zy_skill SET hot_score = hot_score + #{delta}, updated_at = NOW() WHERE id = #{skillId}")
    int addHotScore(@Param("skillId") Long skillId, @Param("delta") int delta);

    /**
     * 批量按 ID 查询技能（含停用标签）—— 集市卡片与交换记录需要回显技能名，
     * 即使标签后来被停用也要能显示历史记录，故此处不过滤 status。
     *
     * @param ids 技能 ID 集合
     * @return 技能列表
     */
    @Select("<script>"
            + "SELECT id, name, alias, category_l1, category_l2, description, difficulty, hot_score, status "
            + "FROM zy_skill WHERE id IN "
            + "<foreach collection='ids' item='i' open='(' separator=',' close=')'>#{i}</foreach>"
            + "</script>")
    List<Skill> selectBriefByIds(@Param("ids") Collection<Long> ids);
}
