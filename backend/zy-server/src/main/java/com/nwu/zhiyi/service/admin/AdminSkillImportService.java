package com.nwu.zhiyi.service.admin;

import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.entity.SkillImportBatch;
import com.nwu.zhiyi.domain.mapper.SkillImportBatchMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 技能标签批量导入服务（FR-M9-02）。
 *
 * <p><b>为什么批量导入要记批次</b>：这是高风险操作（一次可能写入上千条标签）。
 * 有了批次记录才能回答"这批错误标签是谁什么时候导进来的"，并支持整体回溯。
 * 因此每次导入都写入 {@code zy_skill_import_batch}，并把失败明细一并存下来。
 *
 * <p><b>为什么逐行校验而不是整体失败</b>：一次导入 500 行，若有 3 行格式不对
 * 就整批回滚，管理员要反复试错。更实用的做法是<b>跳过错误行、导入正确行、
 * 返回错误明细</b>，让管理员一次就修正全部问题。
 *
 * <p>导入格式（每行一条，逗号或制表符分隔）：
 * <pre>
 *   名称,门类,二级学科,难度,别名1|别名2,描述
 *   Vue 前端开发,工学,计算机科学与技术,3,vue|前端框架,基于组件的前端开发框架
 * </pre>
 * 必填：名称、门类、二级学科。难度 1~5，默认 3。别名用 {@code |} 分隔。
 *
 * @author 李泽宬
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminSkillImportService {

    private final SkillMapper skillMapper;
    private final SkillImportBatchMapper batchMapper;

    /** 单次导入上限 —— 防止一次请求写入过多数据拖垮服务 */
    private static final int MAX_ROWS = 2000;

    /** 名称最长长度（与 DDL 对齐） */
    private static final int MAX_NAME_LEN = 64;

    /**
     * 批量导入技能标签。
     *
     * @param content  导入内容（每行一条）
     * @param operator 操作人
     * @param source   来源标识
     * @return 批次结果（含逐行错误明细）
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> importSkills(String content, String operator, String source) {
        if (!StringUtils.hasText(content)) {
            throw new BusinessException(ErrorCode.IMPORT_FILE_EMPTY);
        }
        String[] rawLines = content.split("\r?\n");
        List<String> lines = new ArrayList<>();
        for (String line : rawLines) {
            String t = line.trim();
            // 跳过空行与注释行（便于管理员在文件里写说明）
            if (!t.isEmpty() && !t.startsWith("#")) {
                lines.add(t);
            }
        }
        if (lines.isEmpty()) {
            throw new BusinessException(ErrorCode.IMPORT_FILE_EMPTY);
        }
        if (lines.size() > MAX_ROWS) {
            throw new BusinessException(ErrorCode.IMPORT_TOO_MANY_ROWS,
                    String.format("单次最多导入 %d 条，当前 %d 条", MAX_ROWS, lines.size()));
        }

        // 已存在的名称，用于识别"更新"还是"新增"
        Map<String, Skill> existing = new LinkedHashMap<>();
        skillMapper.selectList(new LambdaQueryWrapper<Skill>()).forEach(s -> existing.put(s.getName(), s));

        int success = 0;
        int updated = 0;
        List<Map<String, Object>> errors = new ArrayList<>();

        for (int i = 0; i < lines.size(); i++) {
            int lineNo = i + 1;
            try {
                String[] parts = splitLine(lines.get(i));
                if (parts.length < 3) {
                    errors.add(err(lineNo, lines.get(i), "字段不足，至少需要：名称,门类,二级学科"));
                    continue;
                }
                String name = parts[0].trim();
                String categoryL1 = parts[1].trim();
                String categoryL2 = parts[2].trim();
                String difficulty = parts.length > 3 ? parts[3].trim() : "";
                String alias = parts.length > 4 ? parts[4].trim() : "";
                String description = parts.length > 5 ? parts[5].trim() : "";

                if (name.isEmpty() || categoryL1.isEmpty() || categoryL2.isEmpty()) {
                    errors.add(err(lineNo, lines.get(i), "名称/门类/二级学科不能为空"));
                    continue;
                }
                if (name.length() > MAX_NAME_LEN) {
                    errors.add(err(lineNo, name, "名称超过 " + MAX_NAME_LEN + " 字"));
                    continue;
                }
                int diff = 3;
                if (!difficulty.isEmpty()) {
                    try {
                        diff = Integer.parseInt(difficulty);
                    } catch (NumberFormatException e) {
                        errors.add(err(lineNo, name, "难度应为 1~5 的整数，当前为「" + difficulty + "」"));
                        continue;
                    }
                    if (diff < 1 || diff > 5) {
                        errors.add(err(lineNo, name, "难度应在 1~5 之间，当前为 " + diff));
                        continue;
                    }
                }

                Skill old = existing.get(name);
                if (old != null) {
                    // 同名视为更新：保留 id 与历史引用，只更新可维护字段
                    old.setCategoryL1(categoryL1);
                    old.setCategoryL2(categoryL2);
                    old.setDifficulty(diff);
                    if (!alias.isEmpty()) {
                        old.setAlias(alias);
                    }
                    if (!description.isEmpty()) {
                        old.setDescription(description);
                    }
                    skillMapper.updateById(old);
                    updated++;
                } else {
                    Skill skill = new Skill()
                            .setName(name)
                            .setCategoryL1(categoryL1)
                            .setCategoryL2(categoryL2)
                            .setDifficulty(diff)
                            .setAlias(alias.isEmpty() ? null : alias)
                            .setDescription(description.isEmpty() ? null : description)
                            .setHotScore(0)
                            .setStatus(1);
                    skillMapper.insert(skill);
                    existing.put(name, skill);
                    success++;
                }
            } catch (Exception e) {
                errors.add(err(lineNo, lines.get(i), "处理失败：" + e.getMessage()));
            }
        }

        String batchNo = "SKB" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        SkillImportBatch batch = new SkillImportBatch()
                .setBatchNo(batchNo)
                .setOperatorSno(operator)
                .setTotalCount(lines.size())
                .setSuccessCount(success + updated)
                .setFailCount(errors.size())
                .setErrors(errors.isEmpty() ? null : JSONUtil.toJsonStr(errors))
                .setSource(StringUtils.hasText(source) ? source : "ADMIN_UI");
        batchMapper.insert(batch);

        log.info("[技能导入] 批次 {} 由 {} 执行：提交 {} 行，新增 {}，更新 {}，失败 {}",
                batchNo, operator, lines.size(), success, updated, errors.size());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("batchNo", batchNo);
        result.put("total", lines.size());
        result.put("created", success);
        result.put("updated", updated);
        result.put("failed", errors.size());
        result.put("errors", errors);
        return result;
    }

    /**
     * 导入批次历史（可追溯"这批标签是谁什么时候导的"）。
     *
     * @param limit 条数
     * @return 批次列表
     */
    public List<Map<String, Object>> batchHistory(int limit) {
        int max = Math.min(50, Math.max(1, limit <= 0 ? 10 : limit));
        return batchMapper.selectList(new LambdaQueryWrapper<SkillImportBatch>()
                        .orderByDesc(SkillImportBatch::getCreatedAt)
                        .last("LIMIT " + max)).stream()
                .map(b -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("id", b.getId());
                    m.put("batchNo", b.getBatchNo());
                    m.put("operatorSno", b.getOperatorSno());
                    m.put("total", b.getTotalCount());
                    m.put("success", b.getSuccessCount());
                    m.put("failed", b.getFailCount());
                    m.put("source", b.getSource());
                    m.put("createdAt", b.getCreatedAt());
                    m.put("errors", b.getErrors() == null ? List.of()
                            : JSONUtil.toList(b.getErrors(), Map.class));
                    return m;
                }).toList();
    }

    /** 导出当前全部标签为同样的导入格式（便于"导出→修改→再导入"的运维循环） */
    public String exportSkills() {
        List<Skill> all = skillMapper.selectList(new LambdaQueryWrapper<Skill>()
                .orderByAsc(Skill::getCategoryL1).orderByAsc(Skill::getId));
        StringBuilder sb = new StringBuilder();
        sb.append("# 知驿·漫游 技能标签导出\n");
        sb.append("# 格式：名称,门类,二级学科,难度,别名(用|分隔),描述\n");
        for (Skill s : all) {
            sb.append(nvl(s.getName())).append(',')
                    .append(nvl(s.getCategoryL1())).append(',')
                    .append(nvl(s.getCategoryL2())).append(',')
                    .append(s.getDifficulty() == null ? 3 : s.getDifficulty()).append(',')
                    .append(nvl(s.getAlias())).append(',')
                    .append(nvl(s.getDescription()))
                    .append('\n');
        }
        return sb.toString();
    }

    /** 按逗号或制表符分割，逗号优先 */
    private static String[] splitLine(String line) {
        return line.contains("\t") && !line.contains(",") ? line.split("\t") : line.split(",");
    }

    private static Map<String, Object> err(int lineNo, String content, String reason) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("line", lineNo);
        m.put("content", content.length() > 80 ? content.substring(0, 80) + "…" : content);
        m.put("reason", reason);
        return m;
    }

    private static String nvl(String v) {
        return v == null ? "" : v.replace(",", "，");
    }
}
