package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.GovernanceAudit;
import org.apache.ibatis.annotations.Mapper;

/**
 * 治理操作审计日志 Mapper（FR-M8-07 / FR-M8-08）
 *
 * @author 李泽宬
 */
@Mapper
public interface GovernanceAuditMapper extends BaseMapper<GovernanceAudit> {
}