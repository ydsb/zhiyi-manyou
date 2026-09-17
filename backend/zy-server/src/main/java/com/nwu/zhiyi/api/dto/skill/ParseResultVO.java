package com.nwu.zhiyi.api.dto.skill;

import lombok.Data;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * 非结构化文本解析结果（FR-M2-02 / FR-M2-03）。
 *
 * <p>把用户的口语化描述解析为标准化技能标签，供前端回显确认与手工纠正。
 *
 * @author 李泽宬
 */
@Data
public class ParseResultVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 原始输入文本 */
    private String text;

    /** 主体（"我会…"中的"我"所指的人，缺省为空） */
    private String subject;

    /** 命中的标准化技能标签 */
    private List<SkillMatchVO> matched = new ArrayList<>();

    /** 抽取出的三元组 (主体, 动作, 技能实体) */
    private List<Triple> triples = new ArrayList<>();

    /**
     * 解析引擎：
     * RULE_LEXICON 词典规则匹配（S2 阶段，离线可用）
     * NLP_MODEL 预训练模型抽取（S3 阶段接入）
     */
    private String engine;

    /** 是否为降级结果（语义服务不可用时为 true，对应 ErrorCode 4001 的降级语义） */
    private boolean degraded;

    /** 提示信息 */
    private String hint;

    /** 三元组结构 */
    @Data
    public static class Triple implements Serializable {

        private static final long serialVersionUID = 1L;

        /** 主体，如 "我" */
        private String subject;

        /** 动作，如 "擅长" / "想学" / "需要" */
        private String action;

        /** 技能实体（标准化标签名） */
        private String object;

        public Triple() {
        }

        public Triple(String subject, String action, String object) {
            this.subject = subject;
            this.action = action;
            this.object = object;
        }
    }
}
