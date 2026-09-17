package com.nwu.zhiyi.api.dto.demand;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 供需集市卡片视图对象（FR-M4-02 / FR-M4-03）。
 *
 * <p>在需求卡片基础上附加两类信息：
 * <ul>
 *   <li><b>匹配度</b>：{@code matchScore} + {@code matchFactors} 拆解，
 *       用于「算法自动把匹配度极高的卡片高亮置顶」（FR-M4-03）</li>
 *   <li><b>双向技能置换描述</b>：{@code expectSkill} / {@code offerSkill}，
 *       对应「我提供 X ⇄ 我学习 Y」（FR-M4-06）</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Data
public class MarketCardVO {

    /* ---------------- 卡片基础信息 ---------------- */
    private Long id;
    private String demandNo;
    private String title;
    private String description;

    /** 发布人学号（脱敏展示时前端只显示昵称与院系） */
    private String ownerSno;
    private String ownerName;
    private String ownerCollege;
    private String ownerCreditScore;

    /* ---------------- 以技易技的双向描述 ---------------- */
    /** 我急需（期望技能） */
    private SkillBrief expectSkill;
    /** 我可提供（回馈技能） */
    private SkillBrief offerSkill;

    private Integer expectedHours;
    private String expectedPeriod;

    private String visibility;
    private String visibilityLabel;
    private String status;
    private String statusLabel;
    private String auditStatus;

    private Integer matchCount;
    private Integer viewCount;

    private List<DemandInterestVO> interests;

    /* ---------------- 匹配度（FR-M4-03） ---------------- */
    /** 综合匹配度 0~1，null 表示当前视角无法计算（如未登录或无技能画像） */
    private Double matchScore;

    /** 是否高匹配（达到阈值，前端据此高亮置顶） */
    private Boolean highMatch;

    /** 匹配度拆解，让推荐结果可解释（FR-M3-03） */
    private List<MatchFactor> matchFactors;

    /**
     * 发布时间与过期时间。
     *
     * <p>刻意使用 {@link LocalDateTime} 而不是 String：全局 Jackson 配置已为
     * {@code LocalDateTime} 注册 {@code yyyy-MM-dd HH:mm:ss} 序列化器，
     * 声明为 String 会绕过它（早期实现用 {@code toString()} 手工转换，
     * 结果是 ISO 的 {@code 2026-09-17T20:36:49}，前端 {@code new Date()} 解析失败）。
     */
    private LocalDateTime createdAt;

    private LocalDateTime expireAt;

    /** 技能简要信息 */
    @Data
    public static class SkillBrief {
        private Long id;
        private String name;
        private String categoryL1;
        private String categoryL2;
    }

    /** 匹配度因子 */
    @Data
    public static class MatchFactor {
        /** 因子名称 */
        private String name;
        /** 因子得分 0~1 */
        private Double score;
        /** 权重 */
        private Double weight;
        /** 加权贡献 */
        private Double contribution;
        /** 说明 */
        private String detail;

        public MatchFactor() {
        }

        public MatchFactor(String name, double score, double weight, String detail) {
            this.name = name;
            this.score = score;
            this.weight = weight;
            this.contribution = score * weight;
            this.detail = detail;
        }
    }
}
