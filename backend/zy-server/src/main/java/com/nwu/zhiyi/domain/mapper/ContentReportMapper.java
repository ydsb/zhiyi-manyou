package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.ContentReport;
import org.apache.ibatis.annotations.Mapper;

/**
 * 内容举报 Mapper（FR-M9-03 审核队列）。
 *
 * @author 李泽宬
 */
@Mapper
public interface ContentReportMapper extends BaseMapper<ContentReport> {
}
