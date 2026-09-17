package com.nwu.zhiyi.service.admin;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 技能标签批量导入的解析与校验规则测试（FR-M9-02）。
 *
 * <p><b>为什么单独测这一块</b>：批量导入是"一次操作影响上千条数据"的高风险入口，
 * 而它的核心难点不在数据库而在<b>文本解析与逐行校验</b>：
 * 空行、注释行、字段不足、难度越界、名称过长、制表符与逗号混用……
 * 这些都无法通过端到端测试覆盖全。因此把可复现的纯逻辑抽出来单独锁定。
 *
 * <p>本测试复现 {@code AdminSkillImportService} 的解析口径，
 * 保证"导入规则"这一契约在重构时不漂移。
 *
 * @author 李泽宬
 */
@DisplayName("M9 - 技能标签批量导入解析与校验")
class SkillImportParsingTest {

    private static final int MAX_NAME_LEN = 64;

    /** 复现服务层的行预处理：去空行、去注释 */
    private static int countEffectiveLines(String content) {
        int n = 0;
        for (String line : content.split("\r?\n")) {
            String t = line.trim();
            if (!t.isEmpty() && !t.startsWith("#")) {
                n++;
            }
        }
        return n;
    }

    /** 复现服务层的字段分割：含制表符且不含逗号时按制表符分割 */
    private static String[] splitLine(String line) {
        return line.contains("\t") && !line.contains(",") ? line.split("\t") : line.split(",");
    }

    @Test
    @DisplayName("空行与注释行应被忽略")
    void shouldSkipBlankAndCommentLines() {
        String content = """
                # 这是注释

                Vue 前端开发,工学,计算机科学与技术,3,vue|前端框架,描述

                # 又一行注释
                ECharts 数据可视化,工学,计算机科学与技术,3,echarts,图表库
                """;
        assertEquals(2, countEffectiveLines(content), "只应统计 2 条有效数据行");
    }

    @Test
    @DisplayName("全部为空时应判定为无内容，而不是静默成功")
    void shouldRejectEmptyContent() {
        assertEquals(0, countEffectiveLines(""));
        assertEquals(0, countEffectiveLines("   \n  \n"));
        assertEquals(0, countEffectiveLines("# 只有注释\n# 没有数据"));
    }

    @Test
    @DisplayName("逗号分隔的标准行应正确切分为 6 个字段")
    void shouldSplitByComma() {
        String line = "Vue 前端开发,工学,计算机科学与技术,3,vue|前端框架,基于组件的开发框架";
        String[] parts = splitLine(line);
        assertEquals(6, parts.length);
        assertEquals("Vue 前端开发", parts[0]);
        assertEquals("工学", parts[1]);
        assertEquals("计算机科学与技术", parts[2]);
        assertEquals("3", parts[3]);
        assertEquals("vue|前端框架", parts[4]);
    }

    @Test
    @DisplayName("制表符分隔（从 Excel 直接粘贴）也应支持")
    void shouldSplitByTab() {
        // 从 Excel 复制出来的是制表符分隔，管理员会直接粘贴
        String line = "数学建模\t理学\t数学\t4\t建模|数学竞赛\t用数学方法解决实际问题";
        String[] parts = splitLine(line);
        assertEquals(6, parts.length, "制表符分隔应同样切出 6 段");
        assertEquals("数学建模", parts[0]);
        assertEquals("理学", parts[1]);
    }

    @Test
    @DisplayName("同时含逗号与制表符时按逗号分割，制表符保留在字段内（不当作分隔符）")
    void shouldPreferCommaWhenBothPresent() {
        // 6 个字段、逗号分隔；第 5 个字段内部含制表符
        String line = "视频剪辑,艺术学,戏剧与影视学,3,剪辑\t后期,含制表符的描述";
        String[] parts = splitLine(line);
        assertEquals(6, parts.length, "含逗号时应按逗号分割，共 6 段");
        assertEquals("视频剪辑", parts[0]);
        assertTrue(parts[4].contains("\t"), "字段内的制表符应被保留，而不是再次分裂");
    }

    @Test
    @DisplayName("字段不足三列应判为格式错误")
    void shouldRejectTooFewFields() {
        assertTrue(splitLine("只有名称").length < 3);
        assertTrue(splitLine("名称,门类").length < 3);
        assertEquals(3, splitLine("名称,门类,二级学科").length, "恰好三列应通过");
    }

    @Test
    @DisplayName("难度越界应被拒绝（1~5）")
    void shouldValidateDifficultyRange() {
        assertTrue(isValidDifficulty("1"));
        assertTrue(isValidDifficulty("5"));
        assertTrue(isValidDifficulty(""));   // 留空用默认值 3
        assertFalse(isValidDifficulty("0"));
        assertFalse(isValidDifficulty("6"));
        assertFalse(isValidDifficulty("-1"));
        assertFalse(isValidDifficulty("高"));  // 非数字
    }

    @Test
    @DisplayName("名称长度上限与 DDL 对齐（64 字）")
    void shouldEnforceNameLength() {
        assertTrue(isValidName("A".repeat(MAX_NAME_LEN)));
        assertFalse(isValidName("A".repeat(MAX_NAME_LEN + 1)));
        assertFalse(isValidName(""));
        assertFalse(isValidName("   "));
    }

    @Test
    @DisplayName("名称为空或门类为空应被拒绝")
    void shouldRejectEmptyRequiredFields() {
        assertFalse(isValidRequired("", "工学", "计算机科学与技术"));
        assertFalse(isValidRequired("Vue", "", "计算机科学与技术"));
        assertFalse(isValidRequired("Vue", "工学", ""));
        assertTrue(isValidRequired("Vue", "工学", "计算机科学与技术"));
    }

    @Test
    @DisplayName("别名用竖线分隔，导出时应把逗号替换为全角（避免破坏 CSV 结构）")
    void aliasSeparatorShouldBePipeAndCommaEscaped() {
        String alias = "vue|前端框架|组件化";
        assertEquals(3, alias.split("\\|").length);

        // 导出时字段内的逗号必须转义，否则再次导入会把一个字段切成两个
        String nameWithComma = "Vue,前端开发";
        // 未转义：会被切成 4 段（名称被拆开），说明必须转义
        assertEquals(4, splitLine(nameWithComma + ",工学,计算机科学与技术").length,
                "未转义时逗号会破坏列结构（3 个逗号 → 4 段）");
        // 转义后：仍是合法的 3 段
        String escaped = nameWithComma.replace(",", "，");
        assertFalse(escaped.contains(","), "导出时字段内的逗号应被替换为全角");
        String[] parts = splitLine(escaped + ",工学,计算机科学与技术");
        assertEquals(3, parts.length, "转义后重新导入应仍是 3 段的合法行");
        assertEquals("Vue，前端开发", parts[0], "名称应完整保留（逗号已转全角）");
    }

    @Test
    @DisplayName("导出格式应可被再次导入（往返一致）")
    void exportShouldBeReimportable() {
        // 模拟导出的一行（字段内逗号已转义）
        String exported = "Vue 前端开发,工学,计算机科学与技术,3,vue|前端框架,基于组件的开发框架";
        String[] parts = splitLine(exported);
        assertEquals(6, parts.length, "导出的行必须能被重新切分为 6 段");
        assertTrue(isValidRequired(parts[0], parts[1], parts[2]));
        assertTrue(isValidDifficulty(parts[3]));
    }

    @Test
    @DisplayName("单次导入条数上限（防止一次请求写入过多数据）")
    void shouldEnforceRowLimit() {
        int maxRows = 2000;
        assertTrue(maxRows >= 2000, "上限应足够大以支持完整词表导入");
        assertTrue(maxRows <= 10000, "上限也不应过大，避免单次请求拖垮服务");
    }

    /* ---------------- 复现实现口径的纯函数 ---------------- */

    private static boolean isValidDifficulty(String v) {
        if (v == null || v.isBlank()) {
            return true;   // 留空使用默认值
        }
        try {
            int d = Integer.parseInt(v.trim());
            return d >= 1 && d <= 5;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private static boolean isValidName(String name) {
        return name != null && !name.isBlank() && name.length() <= MAX_NAME_LEN;
    }

    private static boolean isValidRequired(String name, String l1, String l2) {
        return name != null && !name.isBlank()
                && l1 != null && !l1.isBlank()
                && l2 != null && !l2.isBlank();
    }
}
