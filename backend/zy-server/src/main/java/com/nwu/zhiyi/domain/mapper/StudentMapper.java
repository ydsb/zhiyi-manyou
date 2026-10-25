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

    /**
     * 当前账号的鉴权状态（status + role）—— JWT 认证时实时读取。
     *
     * <p><b>为什么连 role 一起读</b>：令牌里的 role 是<b>签发时的快照</b>。管理员降级或
     * 升权后，旧令牌仍会带着旧角色直到自然过期（最长一个访问令牌有效期）。把角色一并读出
     * 并以库为准，就把"权限变更的生效延迟"从「令牌有效期」压到了「下一次请求」。
     *
     * <p><b>为什么返回 Map 而不是实体</b>：这是一次只取两列的投影查询，返回部分填充的
     * {@link Student} 会让人误以为拿到了完整实体；本文件已有 countGroupByCollege()
     * 返回 Map 的先例。
     *
     * <p>注意 {@code status} 是 TINYINT，MyBatis 映射进 Map 时可能是 Byte，
     * 调用方请通过 Number 读取，不要直接强转 Integer。
     *
     * @param sno 学号
     * @return {@code {status=1, role=ADMIN}}；账号不存在或已逻辑删除时返回 null
     */
    @Select("SELECT status, role FROM zy_student WHERE sno = #{sno} AND deleted = 0 LIMIT 1")
    Map<String, Object> selectAuthStateBySno(@Param("sno") String sno);
    /** 当前账号的实名核验状态；受限业务操作前校验（auth_status）。 */
    @Select("SELECT auth_status FROM zy_student WHERE sno = #{sno} AND deleted = 0 LIMIT 1")
    String selectAuthStatusBySno(@Param("sno") String sno);

    /**
     * 按学号统计用户数 —— <b>包含已逻辑删除的记录</b>。
     *
     * <p><b>为什么不能用 selectCount + LambdaQueryWrapper</b>：{@link Student} 的
     * {@code deleted} 字段标注了 {@code @TableLogic}，MyBatis-Plus 会自动追加
     * {@code deleted = 0}。于是「已被逻辑删除的学号」查重会通过，但 insert 时仍会撞上
     * 全表唯一索引 {@code uk_student_sno}，最终返回 500 而不是 3002。
     *
     * <p>注册查重必须看到历史记录，否则无法给出正确的业务提示。
     *
     * @param sno 学号
     * @return 匹配行数（0 表示可注册）
     */
    @Select("SELECT COUNT(*) FROM zy_student WHERE sno = #{sno}")
    Long countBySnoIncludingDeleted(@Param("sno") String sno);
}
