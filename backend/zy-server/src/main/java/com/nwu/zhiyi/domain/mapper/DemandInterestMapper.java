package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.DemandInterest;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 需求交换意向 Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface DemandInterestMapper extends BaseMapper<DemandInterest> {

    /**
     * 统计某人发起过、且仍处于待响应状态的邀约数 —— 用于限制同时申请数量。
     *
     * @param sno 申请人学号
     * @return 数量
     */
    @Select("SELECT COUNT(*) FROM zy_demand_interest WHERE applicant_sno = #{sno} AND status = 'PENDING'")
    int countPendingByApplicant(@Param("sno") String sno);
}
