package com.nwu.zhiyi.service.profile;

import com.nwu.zhiyi.api.dto.profile.SkillProfileSaveRequest;
import com.nwu.zhiyi.api.dto.profile.SkillProfileVO;

/**
 * 用户技能画像服务（FR-M1-03 新手漫游导引 / FR-M2-02 标签落库）。
 *
 * <p><b>为什么需要独立的服务</b>：技能画像 {@code zy_user_skill_profile} 是
 * 平台多条主线的公共输入 —— 集市匹配度（FR-M4-03）、供需匹配因子、
 * 能力雷达图、首登判断都读它。但在补齐本服务之前，
 * <b>全平台没有任何接口能往这张表里写</b>：
 * <ul>
 *   <li>新手导引页只有 12 个硬编码标签，{@code finish()} 里是一句 TODO，
 *       选完不落库；</li>
 *   <li>于是真实注册用户永远没有画像 → {@code firstLogin} 恒为 true，
 *       每次登录都被强制拉回导引页；</li>
 *   <li>集市匹配的"技能供需"因子恒为 0，排序失去依据。</li>
 * </ul>
 * 这个缺口不会报错，只会让功能"看起来有、实际没用"，因此单列服务并配测试。
 *
 * @author 李泽宬
 */
public interface SkillProfileService {

    /**
     * 保存（整体覆盖）我的自评技能画像。
     *
     * <p>语义是覆盖而非追加：提交内容替换掉 {@code source='SELF'} 的旧记录，
     * 使"取消勾选"真正生效。{@code source} 为 {@code PEER} / {@code COURSE}
     * 的记录不会被删除。
     *
     * @param sno     学号
     * @param request 三步选择的结果
     * @return 保存后的完整画像
     */
    SkillProfileVO save(String sno, SkillProfileSaveRequest request);

    /**
     * 查询我的技能画像，按三类意图分组。
     *
     * @param sno 学号
     * @return 画像（无任何记录时三组均为空、{@code firstLogin=true}）
     */
    SkillProfileVO mine(String sno);
}
