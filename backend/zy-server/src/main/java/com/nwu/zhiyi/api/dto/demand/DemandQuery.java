package com.nwu.zhiyi.api.dto.demand;

import lombok.Data;

import java.io.Serializable;

/**
 * 需求卡片查询条件（FR-M4-02）。
 *
 * <p>匹配度排序依赖"当前登录用户的技能画像"，因此该条件在服务端按
 * {@code SecurityUtils} 的当前用户自动应用，不通过请求参数传入。
 *
 * @author 李泽宬
 */
@Data
public class DemandQuery implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 关键词（标题 / 描述模糊匹配） */
    private String keyword;

    /** 学科门类过滤（对应期望技能的 categoryL1） */
    private String categoryL1;

    /** 技能标签过滤（期望技能 ID） */
    private Long skillId;

    /** 状态过滤：OPEN / MATCHED / CLOSED；为空默认只返回 OPEN */
    private String status;

    /** 可见范围过滤 */
    private String visibility;

    /**
     * 排序方式：
     * <ul>
     *   <li>{@code MATCH} 匹配度降序（默认，FR-M4-03 高匹配置顶）</li>
     *   <li>{@code LATEST} 最新发布</li>
     *   <li>{@code HOT} 邀约数 + 浏览数</li>
     * </ul>
     */
    private String sort = "MATCH";

    /** 只看高匹配（≥ 阈值） */
    private Boolean onlyHighMatch;

    /** 只看我发布的 */
    private Boolean mine;

    private Integer page = 1;

    private Integer size = 10;
}
