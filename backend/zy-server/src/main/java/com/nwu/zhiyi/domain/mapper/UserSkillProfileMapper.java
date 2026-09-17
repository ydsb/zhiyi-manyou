package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.UserSkillProfile;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 用户技能画像 Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface UserSkillProfileMapper extends BaseMapper<UserSkillProfile> {

    /**
     * 判断用户是否已完成新手导引（是否已建立任何技能画像）。
     *
     * @param sno 学号
     * @return 存在返回 true
     */
    @Select("SELECT EXISTS(SELECT 1 FROM zy_user_skill_profile WHERE sno = #{sno})")
    boolean existsBySno(@Param("sno") String sno);
}
