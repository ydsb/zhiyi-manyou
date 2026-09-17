package com.nwu.zhiyi.api.dto.profile;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 用户技能画像批量保存请求（FR-M1-03 / FR-M2-02）。
 *
 * <p>对应新手漫游导引的三步选择，也用于「技能画像」页面的后续编辑：
 * 一次性提交用户当前的完整技能意图集合。
 *
 * <p><b>语义是"整体覆盖"而不是"增量追加"</b>：服务端把
 * {@code source='SELF'}（用户自评）的旧记录整体替换为本次提交的内容。
 * 这样用户取消勾选某个标签才真的会被移除 —— 若做成增量追加，
 * 用户永远删不掉自己选错的标签。
 *
 * <p>但 {@code source} 为 {@code PEER}（互评）/ {@code COURSE}（课程）的记录
 * <b>不会被删除</b>：那些分数是协作成果累积出来的，不能因为用户改了一次
 * 自评就被清空。详见 {@code SkillProfileServiceImpl} 的合并策略。
 *
 * @author 李泽宬
 */
@Data
public class SkillProfileSaveRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 技能标签集合，允许跨意图重复出现（服务端会按优先级去重）。
     *
     * <p>上限 60 是为了防滥用：导引每步限 6 个、三步 18 个，
     * 手动编辑放宽到 60 已经足够，再多也不符合"画像"的定位。
     */
    @NotNull(message = "技能标签集合不能为空")
    @Size(max = 60, message = "单次最多保存 60 个技能标签")
    @Valid
    private List<Item> items;

    /**
     * 单个技能标签及其意图。
     */
    @Data
    public static class Item implements Serializable {

        private static final long serialVersionUID = 1L;

        @NotNull(message = "技能 ID 不能为空")
        private Long skillId;

        /**
         * 意图枚举名：{@code SKILLED} / {@code RESEARCHING} / {@code NEEDED}。
         *
         * <p>这里用 {@link String} 而不是直接声明为 {@code SkillIntent}：
         * 传错值时 Jackson 会在反序列化阶段抛出难以定位的 400，
         * 而本项目约定业务错误走「HTTP 200 + 非零 code」，
         * 所以由 Service 层显式校验并返回 {@code SKILL_PROFILE_INTENT_ILLEGAL}。
         */
        @NotNull(message = "技能意图不能为空")
        private String intent;

        /**
         * 掌握等级 1~5，可空。
         *
         * <p>导引页不采集等级（三步选择只问"是什么"不问"多熟"），
         * 因此为空时按意图给默认值：擅长默认 4，在研/急需默认 2。
         * 让用户一进导引就面对 18 个"请选择熟练度"是糟糕的首次体验。
         */
        private Integer level;
    }
}
