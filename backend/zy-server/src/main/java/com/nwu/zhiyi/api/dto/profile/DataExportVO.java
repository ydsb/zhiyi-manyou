package com.nwu.zhiyi.api.dto.profile;

import com.nwu.zhiyi.api.dto.UserInfoVO;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 个人数据导出（FR-M1-07）。
 *
 * <p><b>目的</b>：让用户拿得走自己在平台上产生的全部数据。
 * 这既是需求要求，也是"数字档案归用户所有"这一产品主张的兑现 ——
 * 如果数据只能看不能带走，档案就只是平台的资产而不是用户的。
 *
 * <p><b>为什么用 JSON 而不是直接生成 PDF</b>：FR-M1-07 写的是
 * "导出个人学习档案为 PDF/JSON"。两份档案的用途完全不同：
 * <ul>
 *   <li><b>《能力鉴定报告》PDF</b>（已实现，FR-M7-08）—— 给第三方看的<b>凭证</b>，
 *       带校验码可验真，面向简历与综合素质测评；</li>
 *   <li><b>本导出 JSON</b> —— 给用户自己的<b>完整底稿</b>，含全部原始明细，
 *       用于备份、迁移、或自行分析。</li>
 * </ul>
 * 把两者合并成一份 PDF 会两头不讨好：凭证需要克制与正式，
 * 底稿需要完整与机器可读。
 *
 * <p><b>隐私边界（重要）</b>：只导出<b>关于我</b>的数据。
 * 具体地说：
 * <ul>
 *   <li>互评记录导出<b>我收到</b>的评价内容（那是关于我的），
 *       但不导出我<b>给出</b>的评价原文 —— 那是我对他人的评价，
 *       属于对方的数据，且平台对评价有匿名与可见性规则（FR-M6-05），
 *       导出会绕过这些规则；</li>
 *   <li>协作对方的姓名只保留展示名（平台内公开信息），不含学号、联系方式；</li>
 *   <li>私信内容属于双方共同产生的对话，导出我方可见的部分。</li>
 * </ul>
 *
 * @author 李泽宬
 */
@Data
public class DataExportVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 导出格式版本 —— 便于日后解析方识别结构变化 */
    private String formatVersion = "zhiyi-export/1.0";

    /** 导出时间 */
    private LocalDateTime exportedAt;

    /** 数据主体（即导出人）学号 */
    private String sno;

    /** 导出说明（前端展示与文件内附注，讲清包含什么、不含什么） */
    private String note;

    /** 一、账号与资料 */
    private UserInfoVO account;

    /** 二、技能画像（按三类意图分组） */
    private SkillProfileVO skills;

    /** 三、能力画像（雷达维度 + 综合值） */
    private AbilityProfile ability;

    /** 四、我发布的需求卡片 */
    private List<DemandItem> demands;

    /** 五、我的交换记录（全部状态） */
    private List<ExchangeItem> exchanges;

    /** 六、我收到的互评 */
    private List<ReceivedEvaluation> receivedEvaluations;

    /** 七、信用流水 */
    private List<CreditItem> creditLedger;

    /** 八、数字勋章 */
    private List<Map<String, Object>> badges;

    /** 九、我发出的协作留言（协作空间内公开沟通） */
    private List<MessageItem> messages;

    /** 各板块条目数汇总，便于用户一眼确认导出是否完整 */
    private Map<String, Integer> counts;

    /** 能力画像摘要 */
    @Data
    public static class AbilityProfile implements Serializable {
        private static final long serialVersionUID = 1L;
        /** 维度中文名 → 得分；null 表示该维度暂无样本 */
        private Map<String, BigDecimal> dimensionScores;
        /** 维度中文名 → 分数出处说明 */
        private Map<String, String> dimensionEvidence;
        private BigDecimal overallScore;
        private Integer sampleCount;
        private BigDecimal totalHours;
        private BigDecimal avgScore;
        private String caliberNote;
    }

    /** 我发布的卡片 */
    @Data
    public static class DemandItem implements Serializable {
        private static final long serialVersionUID = 1L;
        private String demandNo;
        private String title;
        private String description;
        private String expectedSkill;
        private String offerSkill;
        private String statusLabel;
        private String auditStatus;
        private Integer expectedHours;
        private Integer matchCount;
        private Integer viewCount;
        private LocalDateTime createdAt;
    }

    /** 我的交换记录 */
    @Data
    public static class ExchangeItem implements Serializable {
        private static final long serialVersionUID = 1L;
        private String recordNo;
        private String title;
        /** 我在这次交换中的角色：GIVER 供给方 / TAKER 需求方 */
        private String myRole;
        private String statusLabel;
        /** 我提供的技能 */
        private String providedSkill;
        /** 我学到的技能 */
        private String acquiredSkill;
        private String peerName;
        private Integer expectedHours;
        private BigDecimal actualHours;
        private LocalDateTime startedAt;
        private LocalDateTime finishedAt;
        private LocalDateTime createdAt;
    }

    /** 我收到的互评 */
    @Data
    public static class ReceivedEvaluation implements Serializable {
        private static final long serialVersionUID = 1L;
        private String recordNo;
        private String recordTitle;
        /** 评价人展示名；匿名评价时为「匿名同学」 */
        private String fromName;
        private Boolean anonymous;
        private BigDecimal totalScore;
        /** 维度分原样保留，便于用户自行分析 */
        private Map<String, Object> dimensionScores;
        private String comment;
        private LocalDateTime sealedAt;
        /** 存证校验码，可凭此在平台外验真 */
        private String verifyCode;
        /** 存证等级 */
        private String evidenceLevel;
        /** 是否被申诉 */
        private Integer disputeFlag;
    }

    /** 信用流水 */
    @Data
    public static class CreditItem implements Serializable {
        private static final long serialVersionUID = 1L;
        private Integer delta;
        private Integer scoreAfter;
        private String reason;
        private String remark;
        private LocalDateTime createdAt;
    }

    /** 协作留言 */
    @Data
    public static class MessageItem implements Serializable {
        private static final long serialVersionUID = 1L;
        private String recordNo;
        private String content;
        private String fileName;
        private LocalDateTime createdAt;
    }
}
