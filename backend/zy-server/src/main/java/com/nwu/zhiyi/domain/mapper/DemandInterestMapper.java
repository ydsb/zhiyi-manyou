package com.nwu.zhiyi.domain.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nwu.zhiyi.domain.entity.DemandInterest;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

/**
 * 需求交换意向 Mapper。
 *
 * @author 李泽宬
 */
@Mapper
public interface DemandInterestMapper extends BaseMapper<DemandInterest> {

    /** PENDING → ACCEPTED；返回 0 表示邀约已被其他请求处理。 */
    @Update("UPDATE zy_demand_interest SET status = 'ACCEPTED' WHERE id = #{interestId} AND status = 'PENDING'")
    int acceptIfPending(@Param("interestId") Long interestId);

    /** PENDING → REJECTED。 */
    @Update("UPDATE zy_demand_interest SET status = 'REJECTED' WHERE id = #{interestId} AND status = 'PENDING'")
    int rejectIfPending(@Param("interestId") Long interestId);

    /** 只有申请人本人可以把 PENDING 邀约撤回。 */
    @Update("UPDATE zy_demand_interest SET status = 'WITHDRAWN' "
            + "WHERE id = #{interestId} AND applicant_sno = #{applicantSno} AND status = 'PENDING'")
    int withdrawIfPending(@Param("interestId") Long interestId,
                          @Param("applicantSno") String applicantSno);

    /** 接受一条邀约后，将同一卡片上的其他待响应邀约批量拒绝。 */
    @Update("UPDATE zy_demand_interest SET status = 'REJECTED' "
            + "WHERE demand_id = #{demandId} AND id <> #{acceptedInterestId} AND status = 'PENDING'")
    int rejectOtherPending(@Param("demandId") Long demandId,
                           @Param("acceptedInterestId") Long acceptedInterestId);

    /**
     * 统计某人发起过、且仍处于待响应状态的邀约数 —— 用于限制同时申请数量。
     *
     * @param sno 申请人学号
     * @return 数量
     */
    @Select("SELECT COUNT(*) FROM zy_demand_interest WHERE applicant_sno = #{sno} AND status = 'PENDING'")
    int countPendingByApplicant(@Param("sno") String sno);
}
