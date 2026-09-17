package com.nwu.zhiyi.domain.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.nwu.zhiyi.common.enums.EvidenceLevel;
import com.nwu.zhiyi.common.util.HashUtils;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 双向互评成绩实体 —— 对应表 {@code zy_evaluation_grade}。
 *
 * <p><b>存证机制</b>（FR-M6-03 / 验收项 AC-05）：
 * <ol>
 *   <li>{@link #seal()} 在提交时生成"哈希原文"（{@link #hashPayload}）并计算 SHA-256
 *       存入 {@link #recordHash}；</li>
 *   <li>{@link #verifyIntegrity()} 重新拼出原文并比对，可检出<b>字段级</b>篡改；</li>
 *   <li>同时留存 {@code hashPayload} 原文，避免因日期格式、小数位等实现差异
 *       造成"误报篡改"——早期实现直接重算 {@code toString()}，极易误报。</li>
 * </ol>
 *
 * <p><b>已知边界（不夸大能力）</b>：只做哈希固化时，能改库且有权限的人可以连
 * {@link #recordHash} 一起重算，使记录重新自洽。要真正抗篡改需要外部锚定，
 * 由 {@link #evidenceLevel} 与 {@link #chainProof} 表达（S3 阶段接入可信时间戳或联盟链）。
 * 因此对外一律表述为"可检出篡改"，而非"物理上不可篡改"。
 *
 * <p><b>时间锚点为什么用 sealedAt 而不是 createdAt</b>：{@code createdAt} 由
 * MyBatis 的自动填充在 insert 时生成，与 seal 时刻可能存在微秒级差异，
 * 导致落库值与算哈希时的值不一致、校验必然失败。因此引入独立的
 * {@link #sealedAt}，落库时显式写入（DDL 未给它默认值，避免被自动填充覆盖）。
 *
 * @author 李泽宬
 */
@Data
@Accessors(chain = true)
@TableName("zy_evaluation_grade")
public class EvaluationGrade implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 哈希原文中的时间格式，固定不可变更（改了会导致历史记录全部校验失败） */
    public static final DateTimeFormatter HASH_TIME_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /** 无内容占位符，保证字段为空时原文仍然稳定 */
    private static final String EMPTY = "-";

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private Long recordId;

    /** 评价人学号 */
    private String fromSno;

    /** 被评价人学号 */
    private String toSno;

    /**
     * 维度分（JSON），维度键见 {@code EvaluationDimension}：
     * task_completion / delivery_quality / communication / cross_discipline。
     *
     * <p>仅用于展示与查询。<b>不参与哈希</b>，因为它是 MySQL JSON 列，
     * 读写往返会改变字符串表示，无法逐字节重现。
     */
    private String dimScores;

    /**
     * 维度分的<b>规范化串</b>，参与哈希计算。
     *
     * <p>由 {@code DimensionScoreCalculator.toCanonical()} 生成：固定 key 顺序、
     * 固定一位小数、固定分隔符，只由数值决定，与存储格式无关，
     * 因此可以逐字节重现，适合作为存证依据。
     */
    private String dimCanonical;

    /** 加权总分 0~100 */
    private BigDecimal totalScore;

    private String comment;

    /** 是否匿名：0实名 1匿名 */
    private Integer anonymous;

    /** 存证哈希 SHA-256，写入后不可变 */
    private String recordHash;

    /** 哈希原文（用于精确复算校验） */
    private String hashPayload;

    /** 存证凭证（可信时间戳 / 链上交易号） */
    private String chainProof;

    /** 存证等级 */
    private EvidenceLevel evidenceLevel;

    /** 对外校验码，供《能力鉴定报告》验真 */
    private String verifyCode;

    /** 封存时间（哈希时间锚点） */
    private LocalDateTime sealedAt;

    /** 是否被申诉：0否 1是 */
    private Integer disputeFlag;

    /** 是否超时默认计分：0否 1是 */
    private Integer timeoutFlag;

    /** 审核状态：PASSED 通过 / PENDING 待人工复核（疑似互刷或含攻击性用语） */
    private String auditStatus;

    /** 审核说明（命中的风险特征） */
    private String auditRemark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /* ==================== 领域行为 ==================== */

    /**
     * 拼装哈希原文。
     *
     * <p>格式一旦确定<b>不可再改</b>：所有历史记录的校验都依赖它。
     * 若未来确需扩展参与字段，必须新增一个 hashVersion 字段并在原文里带上版本号，
     * 而不是直接修改本方法。
     *
     * @return 哈希原文
     */
    public String buildHashPayload() {
        return String.join("|",
                String.valueOf(recordId),
                orEmpty(fromSno),
                orEmpty(toSno),
                // 用规范化维度串而不是 dimScores 原串：后者存于 JSON 列，
                // 读写往返会改变字符串表示，无法逐字节重现（详见 dimCanonical 的说明）
                orEmpty(dimCanonical),
                totalScore == null ? EMPTY
                        : totalScore.setScale(2, RoundingMode.HALF_UP).toPlainString(),
                orEmpty(comment),
                sealedAt == null ? EMPTY : sealedAt.format(HASH_TIME_FORMAT));
    }

    /**
     * 提交前固化存证：生成时间锚点、哈希原文、SHA-256 与校验码。
     *
     * <p><b>时间锚点一律截断到秒</b>：哈希原文使用秒级格式，而 MySQL 的 DATETIME
     * 默认也不保存小数秒。若实体保留纳秒，就会出现"内存对象 / 哈希原文 / 落库值"
     * 三者精度不一致（虽然重建原文时同样按秒格式化、校验恰好仍能通过，但这是隐患）。
     * 统一截断可以让三者完全一致。
     *
     * @return 自身，便于链式调用
     */
    public EvaluationGrade seal() {
        if (this.sealedAt == null) {
            this.sealedAt = LocalDateTime.now();
        }
        // 无论 sealedAt 是自动生成还是调用方显式传入，都截断到秒
        this.sealedAt = this.sealedAt.withNano(0);
        // 规范化评语，避免两端空白导致同一内容算出不同哈希
        if (this.comment != null) {
            this.comment = this.comment.trim();
        }
        this.hashPayload = buildHashPayload();
        this.recordHash = HashUtils.sha256Hex(this.hashPayload);
        if (this.verifyCode == null) {
            this.verifyCode = HashUtils.shortVerifyCode(this.recordHash);
        }
        if (this.evidenceLevel == null) {
            this.evidenceLevel = EvidenceLevel.HASH;
        }
        return this;
    }

    /**
     * 校验完整性。
     *
     * <p><b>校验基准是"重建原文"</b>：参与哈希的字段（{@link #dimCanonical}、
     * {@link #totalScore}、{@link #comment}、时间锚点）都具备<b>逐字节可重现</b>的特性 ——
     * 规范串只由数值决定、总分统一两位小数、评语在封存时已 trim、时间截断到秒。
     * 因此未改动的记录重建结果必然与封存时一致，任何字段被改都会导致不一致。
     *
     * <p>{@link #hashPayload}（封存时的原文）作为<b>交叉参考</b>返回给审计人员比对：
     * 若它与重建结果不同，说明字段的表示形式发生变化（可能是篡改，也可能是
     * 早期版本的格式差异），此时以重建结果为准判定是否通过。
     *
     * <p>为什么不直接信任 hashPayload：它只是封存时的快照，若只用它比对，
     * 字段被改动而原文未变就会漏报（早期实现正是这个错误）。
     *
     * @return 未被篡改返回 true
     */
    public boolean verifyIntegrity() {
        if (this.recordHash == null || this.recordHash.isBlank()) {
            return false;
        }
        String rebuilt = buildHashPayload();
        return this.recordHash.equalsIgnoreCase(HashUtils.sha256Hex(rebuilt));
    }

    /**
     * 封存时的原文与当前字段重建的原文是否一致。
     *
     * <p>不一致并不必然意味着篡改（也可能是历史数据的格式差异），
     * 因此单独暴露给审计与排查使用，不参与 {@link #verifyIntegrity()} 的判定。
     *
     * @return 一致返回 true
     */
    public boolean isPayloadReplayable() {
        return this.hashPayload != null && !this.hashPayload.isBlank()
                && this.hashPayload.equals(buildHashPayload());
    }

    /**
     * 诊断用：暴露重建原文，便于排查校验异常。
     *
     * @return 按当前字段重建的哈希原文
     */
    public String rebuiltHashPayload() {
        return buildHashPayload();
    }

    /** 是否为超时默认计分产生的记录 */
    public boolean isTimeoutScored() {
        return timeoutFlag != null && timeoutFlag == 1;
    }

    /**
     * 是否匿名提交。
     *
     * <p><b>命名注意</b>：不能叫 {@code isAnonymous()} —— 字段是
     * {@code Integer anonymous}，Lombok 会生成 {@code getAnonymous()}，
     * 而 {@code isAnonymous()} 返回 {@code boolean}，两者构成
     * "Illegal overloaded getter method with ambiguous type"，
     * 会让 MyBatis 在解析属性时直接抛 ReflectionException（本项目踩过）。
     * 因此改用不会与 JavaBean 规范冲突的名字。
     *
     * @return 匿名返回 true
     */
    public boolean anonymousSubmission() {
        return anonymous != null && anonymous == 1;
    }

    private static String orEmpty(String value) {
        return value == null || value.isBlank() ? EMPTY : value;
    }
}
