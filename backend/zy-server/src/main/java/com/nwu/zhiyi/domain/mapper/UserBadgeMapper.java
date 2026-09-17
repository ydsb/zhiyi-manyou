package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.UserBadge;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户勋章授予记录 Mapper（FR-M7-04）。
 *
 * @author 李泽宬
 */
@Mapper
public interface UserBadgeMapper extends BaseMapper<UserBadge> {
}
