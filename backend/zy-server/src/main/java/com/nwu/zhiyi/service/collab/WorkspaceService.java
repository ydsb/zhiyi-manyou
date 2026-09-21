package com.nwu.zhiyi.service.collab;

import com.nwu.zhiyi.api.dto.collab.CollabFileVO;
import com.nwu.zhiyi.api.dto.collab.CollabMessageVO;
import com.nwu.zhiyi.api.dto.collab.CollabTaskVO;
import com.nwu.zhiyi.api.dto.collab.TaskConfirmRequest;
import com.nwu.zhiyi.api.dto.collab.MessageSendRequest;
import com.nwu.zhiyi.api.dto.collab.ProcessSummaryVO;
import com.nwu.zhiyi.api.dto.collab.TaskCreateRequest;
import com.nwu.zhiyi.api.dto.collab.TaskUpdateRequest;
import com.nwu.zhiyi.api.dto.collab.WorkspaceVO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 协作工作台服务（模块 M5）。
 *
 * <p>对应需求：
 * <ul>
 *   <li>FR-M5-01 专属协作空间与访问控制</li>
 *   <li>FR-M5-02 阶段性任务拆解与打卡</li>
 *   <li>FR-M5-03 文件版本传输与历史回溯</li>
 *   <li>FR-M5-04 时间轴视图</li>
 *   <li>FR-M5-06 过程性评价语料</li>
 *   <li>FR-M5-07 在线沟通（文字 + 附件）</li>
 * </ul>
 *
 * @author 李泽宬
 */
public interface WorkspaceService {

    /**
     * 工作台总览（一次返回任务、文件、留言、时间轴与过程指标）。
     *
     * @param recordId  交换记录 ID
     * @param viewerSno 访问者学号
     * @return 工作台数据
     */
    WorkspaceVO overview(Long recordId, String viewerSno);

    /* ==================== 任务（FR-M5-02） ==================== */

    /**
     * 新增任务项。
     *
     * @param recordId 交换记录 ID
     * @param operator 操作人
     * @param request  请求体
     * @return 新增后的任务
     */
    CollabTaskVO createTask(Long recordId, String operator, TaskCreateRequest request);

    /**
     * 修改任务项（含状态流转与打卡）。
     *
     * @param recordId 交换记录 ID
     * @param taskId   任务 ID
     * @param operator 操作人
     * @param request  请求体
     * @return 修改后的任务
     */
    CollabTaskVO updateTask(Long recordId, Long taskId, String operator, TaskUpdateRequest request);

    /**
     * 确认阶段性成果（FR-M5-08）。
     *
     * <p>需求原文：「阶段性成果支持互相同步确认，避免单方面宣称完成」。
     * 任务被标记完成后，须由<b>协作方</b>（负责人或创建人中不是打卡者的那个）
     * 确认，才算"双方认可的成果"；打卡者不能确认自己。
     *
     * @param recordId 交换记录 ID
     * @param taskId   任务 ID
     * @param operator 操作人（确认人）
     * @param request  确认说明，可为 null
     * @return 确认后的任务视图
     */
    CollabTaskVO confirmTask(Long recordId, Long taskId, String operator, TaskConfirmRequest request);

    /**
     * 删除任务项。
     *
     * @param recordId 交换记录 ID
     * @param taskId   任务 ID
     * @param operator 操作人
     */
    void deleteTask(Long recordId, Long taskId, String operator);

    /**
     * 任务列表。
     *
     * @param recordId 交换记录 ID
     * @param viewerSno 访问者
     * @return 任务列表
     */
    List<CollabTaskVO> listTasks(Long recordId, String viewerSno);

    /* ==================== 文件（FR-M5-03） ==================== */

    /**
     * 上传文件；同一 {@code groupKey} 重复上传会自动生成新版本。
     *
     * @param recordId     交换记录 ID
     * @param uploaderSno  上传人
     * @param file         上传的文件
     * @param groupKey     逻辑文件标识；为空表示新文件（自动生成）
     * @param taskId       关联任务项（可选，作为该任务的交付物）
     * @param remark       版本说明
     * @return 文件记录
     */
    CollabFileVO upload(Long recordId, String uploaderSno, MultipartFile file,
                        String groupKey, Long taskId, String remark);

    /**
     * 文件列表。
     *
     * @param recordId  交换记录 ID
     * @param viewerSno 访问者
     * @param groupKey  可选，只看某逻辑文件的历史版本（为空则返回各文件的最新版本）
     * @return 文件列表
     */
    List<CollabFileVO> listFiles(Long recordId, String viewerSno, String groupKey);

    /**
     * 校验并返回文件记录（供下载接口使用，内含参与者校验）。
     *
     * @param fileId    文件 ID
     * @param viewerSno 访问者
     * @return 文件记录（含 storagePath）
     */
    com.nwu.zhiyi.domain.entity.CollabFile requireDownloadable(Long fileId, String viewerSno);

    /* ==================== 留言（FR-M5-07） ==================== */

    /**
     * 发送留言（文字或引用已上传的附件）。
     *
     * @param recordId 交换记录 ID
     * @param senderSno 发送人
     * @param request  请求体
     * @return 留言
     */
    CollabMessageVO sendMessage(Long recordId, String senderSno, MessageSendRequest request);

    /**
     * 留言列表（按时间正序，便于前端直接渲染聊天流）。
     *
     * @param recordId  交换记录 ID
     * @param viewerSno 访问者
     * @param limit     返回上限
     * @return 留言列表
     */
    List<CollabMessageVO> listMessages(Long recordId, String viewerSno, int limit);

    /* ==================== 过程性指标（FR-M5-06） ==================== */

    /**
     * 协作过程性指标汇总。
     *
     * <p>该结果是 M6 双向互评页面的"客观行为参考"，也是 M7 能力画像的输入。
     *
     * @param recordId  交换记录 ID
     * @param viewerSno 访问者
     * @return 指标汇总
     */
    ProcessSummaryVO processSummary(Long recordId, String viewerSno);

    /* ==================== 协作事件（FR-M5-04） ==================== */

    /**
     * 追加一条协作事件（供其它模块调用，如交换状态变更时）。
     *
     * @param recordId  交换记录 ID
     * @param actorSno  行为主体
     * @param eventType 事件类型
     * @param title     时间轴标题
     * @param detail    补充说明
     * @param refType   关联对象类型
     * @param refId     关联对象 ID
     */
    void recordEvent(Long recordId, String actorSno, String eventType, String title,
                     String detail, String refType, Long refId);

    /**
     * 时间轴（最新在前）。
     *
     * @param recordId  交换记录 ID
     * @param viewerSno 访问者
     * @param limit     返回上限
     * @return 事件列表
     */
    List<com.nwu.zhiyi.api.dto.collab.CollabEventVO> timeline(Long recordId, String viewerSno, int limit);
}
