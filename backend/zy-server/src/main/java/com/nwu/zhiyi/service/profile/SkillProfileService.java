package com.nwu.zhiyi.service.profile;

import com.nwu.zhiyi.api.dto.profile.SkillProfileSaveRequest;
import com.nwu.zhiyi.api.dto.profile.SkillProfileVO;

/**
 * 用户技能画像服务（FR-M1-03 新手漫游导引 / FR-M2-02 标签落库）。
 *
 * <p><b>为什么需要独立的服务</b>：技能画像 {@code zy_user_skill_profile} 是
 * 平台多条主线的公共输入 —— 集市匹配度（FR-M4-03）、供需匹配因子、
 * 能力雷达图、首登判断都读它。新手导引和个人中心都会通过本服务保存画像，
 * 避免前端各自维护一套写入语义；
 * 保存后的画像会同时供首登判断、集市匹配和能力雷达图使用。
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
