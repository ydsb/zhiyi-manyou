-- =============================================================================
--  M5 增量迁移：阶段性成果的双向确认（FR-M5-08）
--
--  需求原文：「阶段性成果支持互相同步确认，避免单方面宣称完成」。
--
--  ---------------------------------------------------------------------------
--  为什么是"另加确认维度"而不是改状态机
--  ---------------------------------------------------------------------------
--  现有 TaskStatus 只有 TODO / DOING / DONE，其中 DONE 是"打卡即置位" ——
--  任何一方点一下就把任务标成完成，另一方没有任何参与机会。
--
--  一个直觉方案是把 DONE 改造成"待确认 → 已确认"两态。但没有这么做，原因：
--    1. 状态机是 M5/M6/M7 的公共输入：WorkspaceVO 的任务分组、
--       M7 过程性指标（taskDone/taskCompletionRate）、M6 互评语料都读它，
--       改语义会让这些既有口径全部需要重新定义；
--    2. "我完成了"与"对方认可我完成了"本来就是两个独立事实，
--       硬塞进同一个字段会让两者互相覆盖 —— 撤回重做时无法保留
--       "曾被认可过"这一历史。
--
--  因此保持 TaskStatus 不变，另加一组确认字段。这样：
--    - 已完成的语义不变（向后兼容，历史数据无需回填）；
--    - 确认是增量信息，未确认即"仅自述完成"；
--    - 撤回重做时清空确认，语义清晰。
--
--  ---------------------------------------------------------------------------
--  为什么确认人可以是负责人，也可以是创建人
--  ---------------------------------------------------------------------------
--  任务允许没有负责人（共同负责，assignee_sno 为空），此时"对方"就是创建人。
--  因此服务端的判定规则是：确认人必须是该任务的 assignee_sno 或 created_by
--  之一，且不能是打卡者本人（自己确认自己等于没有确认）。
--
--  本脚本幂等：与 02-migration-m5.sql 一致，用存储过程判断列是否存在。
-- =============================================================================

USE `zhiyi_manyou`;

DROP PROCEDURE IF EXISTS `zy_add_column_if_absent`;

DELIMITER $$
CREATE PROCEDURE `zy_add_column_if_absent`(
    IN p_table VARCHAR(64),
    IN p_column VARCHAR(64),
    IN p_definition VARCHAR(500)
)
BEGIN
    IF NOT EXISTS(SELECT 1
                  FROM information_schema.COLUMNS
                  WHERE TABLE_SCHEMA = DATABASE()
                    AND TABLE_NAME = p_table
                    AND COLUMN_NAME = p_column) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN `', p_column, '` ', p_definition);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

-- 是否已被对方确认（FR-M5-08）
CALL zy_add_column_if_absent('zy_collab_task', 'confirmed',
    'TINYINT NOT NULL DEFAULT 0 COMMENT ''对方是否已确认该阶段成果：0未确认 1已确认''');

-- 确认人学号（用于审计与展示"谁确认的"）
CALL zy_add_column_if_absent('zy_collab_task', 'confirmed_by',
    'VARCHAR(32) DEFAULT NULL COMMENT ''确认人学号''');

-- 确认时间
CALL zy_add_column_if_absent('zy_collab_task', 'confirmed_at',
    'DATETIME DEFAULT NULL COMMENT ''确认时间''');

-- 确认备注（可以提出"与预期不符"的具体说明，而不只是通过/驳回）
CALL zy_add_column_if_absent('zy_collab_task', 'confirm_remark',
    'VARCHAR(255) DEFAULT NULL COMMENT ''确认或提出异议的说明''');

-- 打卡人学号：记录"是谁宣称完成的"，用于判定"对方"是谁
-- （assignee 可能为空 → 退化为创建人；但打卡人未必是负责人）
CALL zy_add_column_if_absent('zy_collab_task', 'done_by',
    'VARCHAR(32) DEFAULT NULL COMMENT ''标记完成的人学号（打卡者）''');

DROP PROCEDURE IF EXISTS `zy_add_column_if_absent`;

-- 校验
SELECT 'M5 迁移（双向确认）完成' AS message,
       (SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'zy_collab_task'
          AND COLUMN_NAME IN ('confirmed', 'confirmed_by', 'confirmed_at', 'confirm_remark', 'done_by')
       ) AS added_columns;
