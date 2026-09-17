package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.Badge;
import org.apache.ibatis.annotations.Mapper;

/**
 * 数字勋章定义 Mapper（FR-M7-04）。
 *
 * @author 李泽宬
 */
@Mapper
public interface BadgeMapper extends BaseMapper<Badge> {
}
