package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.Student;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * 用户（学生）Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface StudentMapper extends BaseMapper<Student> {

    /**
     * 按学院统计用户分布（运营看板用）。
     *
     * @return 每行包含 college 与 user_count
     */
    @Select("SELECT college, COUNT(*) AS user_count FROM zy_student "
            + "WHERE deleted = 0 AND college IS NOT NULL GROUP BY college ORDER BY user_count DESC")
    List<Map<String, Object>> countGroupByCollege();

    /**
     * 原子增减信用值，避免并发覆盖。
     *
     * @param sno   学号
     * @param delta 变动值
     * @return 影响行数
     */
    @Update("UPDATE zy_student SET credit_score = credit_score + #{delta}, updated_at = NOW() "
            + "WHERE sno = #{sno} AND deleted = 0")
    int addCreditScore(@Param("sno") String sno, @Param("delta") int delta);

    /**
     * 批量按学号查询用户 —— 集市卡片需要展示发布人昵称与院系，避免逐条查询（N+1）。
     *
     * @param snos 学号集合
     * @return 用户列表
     */
    @Select("<script>"
            + "SELECT sno, sname, nickname, college, major, credit_score, credit_level FROM zy_student "
            + "WHERE deleted = 0 AND sno IN "
            + "<foreach collection='snos' item='s' open='(' separator=',' close=')'>#{s}</foreach>"
            + "</script>")
    List<Student> selectBriefBySnos(@Param("snos") Collection<String> snos);
}
