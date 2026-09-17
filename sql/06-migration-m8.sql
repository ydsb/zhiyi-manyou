-- =============================================================================
--  知驿·漫游 —— 增量迁移  M8 信用体系与社区治理
--  数据库：MySQL 8.0+    字符集：utf8mb4
--
--  M8 涉及两类改动：
--    1. 给已有的 zy_dispute / zy_arbitration_vote 补仲裁流程所需字段
--       （表决截止时间、匿名投票的哈希、裁决执行留痕）
--    2. 新增操作审计日志表，承载 FR-M8-07（治理过程可追溯）
--       与 FR-M8-08（管理员紧急干预须留痕并公示）
--
--  导入方式：mysql -uroot -p < 06-migration-m8.sql
-- =============================================================================

USE `zhiyi_manyou`;

-- -----------------------------------------------------------------------------
-- 通用过程：幂等补列
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `zy_add_col_m8`;
DELIMITER $$
CREATE PROCEDURE `zy_add_col_m8`(IN p_table VARCHAR(64), IN p_col VARCHAR(64), IN p_def VARCHAR(500))
BEGIN
    DECLARE v INT DEFAULT 0;
    SELECT COUNT(*) INTO v FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_table AND COLUMN_NAME = p_col;
    IF v = 0 THEN
        SET @d = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN `', p_col, '` ', p_def);
        PREPARE s FROM @d; EXECUTE s; DEALLOCATE PREPARE s;
        SELECT CONCAT('added: ', p_table, '.', p_col) AS note;
    ELSE
        SELECT CONCAT('skip: ', p_table, '.', p_col) AS note;
    END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- 1. zy_dispute 补仲裁所需字段
-- -----------------------------------------------------------------------------

-- 争议类型：便于统计"哪类问题最多"，也是治理规则迭代的依据
CALL zy_add_col_m8('zy_dispute', 'dispute_type',
    'VARCHAR(32) DEFAULT NULL COMMENT ''争议类型：NO_SHOW 未履约 / QUALITY 交付质量 / EVAL_UNFAIR 评价不公 / PLAGIARISM 抄袭 / OTHER''');

-- 证据说明（evidence 字段存附件数组，这里存文字陈述）
CALL zy_add_col_m8('zy_dispute', 'statement',
    'VARCHAR(1000) DEFAULT NULL COMMENT ''申诉人陈述''');

-- 被申诉人答辩（给被告申辩机会，避免单方陈述即定罪）
CALL zy_add_col_m8('zy_dispute', 'defense',
    'VARCHAR(1000) DEFAULT NULL COMMENT ''被申诉人答辩''');

-- 表决截止时间
CALL zy_add_col_m8('zy_dispute', 'vote_deadline',
    'DATETIME DEFAULT NULL COMMENT ''仲裁表决截止时间''');

-- 卷宗快照：后台抽取的全过程交互数据（FR-M8-04）
-- 存快照而不是每次实时拼，是为了保证"委员看到的内容"与"裁决依据"一致、可追溯
CALL zy_add_col_m8('zy_dispute', 'case_file',
    'JSON DEFAULT NULL COMMENT ''卷宗快照：协作过程数据、互评记录、时间轴摘要''');

-- 裁决执行结果记录（FR-M8-06）
CALL zy_add_col_m8('zy_dispute', 'execution_log',
    'JSON DEFAULT NULL COMMENT ''裁决执行明细：信用变动、评价修正、账号处置''');

-- 裁决方式：委员会投票 / 管理员紧急处置（后者须留痕公示）
CALL zy_add_col_m8('zy_dispute', 'resolved_by',
    'VARCHAR(16) DEFAULT NULL COMMENT ''裁决方式：VOTE 委员会投票 / ADMIN 管理员干预''');

-- 仲裁委员人数与票数统计（避免实时 count 造成列表页 N+1）
CALL zy_add_col_m8('zy_dispute', 'arbitrator_count',
    'INT NOT NULL DEFAULT 0 COMMENT ''应参与仲裁的委员数''');
CALL zy_add_col_m8('zy_dispute', 'vote_count',
    'INT NOT NULL DEFAULT 0 COMMENT ''已投票数''');

-- -----------------------------------------------------------------------------
-- 2. zy_arbitration_vote 补匿名投票所需字段（FR-M8-05）
-- -----------------------------------------------------------------------------

-- 投票内容哈希：把"谁投了什么"加密存证，公示时只暴露票数，
-- 事后如需核查（例如出现舞弊指控）可用哈希验证票未被篡改
CALL zy_add_col_m8('zy_arbitration_vote', 'vote_hash',
    'CHAR(64) DEFAULT NULL COMMENT ''投票内容 SHA-256（匿名表决的可核查存证）''');

-- 委员抽取来源标识：记录该委员是被随机抽取的（保证程序正义可追溯）
CALL zy_add_col_m8('zy_arbitration_vote', 'selection_reason',
    'VARCHAR(255) DEFAULT NULL COMMENT ''委员抽取依据（如：信用 132、跨 3 个学院、非当事人）''');

-- -----------------------------------------------------------------------------
-- 3. 新增操作审计日志表（FR-M8-07 / FR-M8-08）
--
-- 设计要点：
--   - 只追加、不修改不删除。治理过程的公信力来自"能查"。
--   - target_type/target_id 用通用结构，便于覆盖 信用变动/裁决/封禁/评价修正 等各类操作。
--   - visible 控制是否公示：大多数操作公示，涉及隐私的（如个人信息）不公示但要留痕。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_governance_audit`
(
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `action`         VARCHAR(48)  NOT NULL COMMENT '操作类型：CREDIT_ADJUST / DISPUTE_RESOLVE / EVALUATION_AMEND / ACCOUNT_BAN / RULE_UPDATE / ADMIN_INTERVENE',
    `actor_sno`      VARCHAR(32)  NOT NULL COMMENT '操作人学号；SYSTEM 表示系统自动执行',
    `actor_role`     VARCHAR(16)  NOT NULL COMMENT '操作人身份：USER 用户 / ARBITRATOR 仲裁委员 / ADMIN 管理员 / SYSTEM 系统',
    `target_type`    VARCHAR(32)  DEFAULT NULL COMMENT '对象类型：STUDENT / EXCHANGE / EVALUATION / DISPUTE / DEMAND',
    `target_id`      VARCHAR(64)  DEFAULT NULL COMMENT '对象标识（学号或 ID）',
    `summary`        VARCHAR(500) NOT NULL COMMENT '操作摘要（人类可读，公示页直接展示）',
    `detail`         JSON         DEFAULT NULL COMMENT '操作明细（变更前后值、依据等）',
    `reason`         VARCHAR(500) DEFAULT NULL COMMENT '操作理由；管理员紧急干预时必填',
    `visible`        TINYINT      NOT NULL DEFAULT 1 COMMENT '是否在治理公示页展示：1是 0否（隐私相关仍留痕但不公示）',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    PRIMARY KEY (`id`),
    KEY `idx_audit_action` (`action`),
    KEY `idx_audit_actor` (`actor_sno`),
    KEY `idx_audit_target` (`target_type`, `target_id`),
    KEY `idx_audit_created` (`created_at`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='治理操作审计日志（只追加，承载 FR-M8-07/08）';

-- -----------------------------------------------------------------------------
-- 4. 清理临时过程并校验
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `zy_add_col_m8`;

SELECT 'M8 migration completed' AS message,
       (SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'zy_dispute'
          AND COLUMN_NAME IN ('dispute_type', 'statement', 'defense', 'vote_deadline',
                              'case_file', 'execution_log', 'resolved_by',
                              'arbitrator_count', 'vote_count')) AS dispute_new_cols,
       (SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'zy_arbitration_vote'
          AND COLUMN_NAME IN ('vote_hash', 'selection_reason')) AS vote_new_cols,
       (SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'zy_governance_audit') AS audit_table;
