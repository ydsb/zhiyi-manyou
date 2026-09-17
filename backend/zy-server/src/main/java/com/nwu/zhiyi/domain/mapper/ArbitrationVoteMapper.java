package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.ArbitrationVote;
import org.apache.ibatis.annotations.Mapper;

/**
 * 仲裁投票 Mapper（FR-M8-05，匿名表决）
 *
 * @author 李泽宬
 */
@Mapper
public interface ArbitrationVoteMapper extends BaseMapper<ArbitrationVote> {
}