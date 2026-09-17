package com.nwu.zhiyi.api.dto.demand;

import com.nwu.zhiyi.domain.entity.DemandInterest;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 交换意向视图对象（FR-M4-05）。
 *
 * @author 李泽宬
 */
@Data
public class DemandInterestVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long demandId;

    /** 目标卡片标题与编号（服务层补齐，便于前端直接渲染） */
    private String demandTitle;
    private String demandNo;

    private String applicantSno;
    private String applicantName;
    private String applicantCollege;

    /** 发起后生成的交换记录 ID */
    private Long recordId;
    private String recordNo;

    private Double matchScore;
    private String status;
    private String statusLabel;
    private String message;
    /** 申请时间（用 LocalDateTime 以复用全局时间格式，见 MarketCardVO 的说明） */
    private LocalDateTime createdAt;

    public static DemandInterestVO of(DemandInterest interest) {
        if (interest == null) {
            return null;
        }
        DemandInterestVO vo = new DemandInterestVO();
        vo.setId(interest.getId());
        vo.setDemandId(interest.getDemandId());
        vo.setApplicantSno(interest.getApplicantSno());
        vo.setRecordId(interest.getRecordId());
        vo.setMatchScore(interest.getMatchScore() == null ? null : interest.getMatchScore().doubleValue());
        if (interest.getStatus() != null) {
            vo.setStatus(interest.getStatus().name());
            vo.setStatusLabel(interest.getStatus().getLabel());
        }
        vo.setMessage(interest.getMessage());
        vo.setCreatedAt(interest.getCreatedAt());
        return vo;
    }
}
