-- =============================================================================
--  知驿·漫游 —— 增量迁移脚本  M6 双向互评
--  数据库：MySQL 8.0+    字符集：utf8mb4
--
--  背景：01-schema.sql 全部使用 CREATE TABLE IF NOT EXISTS，对新建库幂等，
--        但不会给已存在的表补列。M6 给 zy_evaluation_grade 增加了存证相关列，
--        旧库需要执行本脚本。新库无需执行。
--
--  ⚠️ 重要：sealed_at 是"非空且无默认值"的列，而 MyBatis-Plus 的 insert 会把
--     实体全部字段（含 null）写进 SQL，因此必须由实体在 seal() 里显式赋值，
--     不能依赖数据库填充（否则报 Column 'sealed_at' cannot be null）。
--
--  导入方式：
--      mysql -uroot -p < 03-migration-m6.sql
-- =============================================================================

USE `zhiyi_manyou`;

-- -----------------------------------------------------------------------------
-- 通用过程：幂等地补列。MySQL 8 不支持 ADD COLUMN IF NOT EXISTS，
-- 因此用 information_schema 判断 + 动态 SQL。
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `zy_add_column_if_absent`;
DELIMITER $$
CREATE PROCEDURE `zy_add_column_if_absent`(
    IN p_table VARCHAR(64),
    IN p_column VARCHAR(64),
    IN p_definition VARCHAR(500)
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_table AND COLUMN_NAME = p_column;
    IF v_exists = 0 THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN `', p_column, '` ', p_definition);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('added: ', p_table, '.', p_column) AS migrate_note;
    ELSE
        SELECT CONCAT('skip (exists): ', p_table, '.', p_column) AS migrate_note;
    END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- zy_evaluation_grade：存证与超时相关列
-- -----------------------------------------------------------------------------

-- 哈希原文：用于精确复算校验，避免因日期格式/小数位差异造成"误报篡改"
CALL zy_add_column_if_absent('zy_evaluation_grade', 'hash_payload',
    'VARCHAR(2000) DEFAULT NULL COMMENT ''哈希原文（用于精确复算校验）'' AFTER `record_hash`');

-- 存证等级：如实表达可信程度（HASH / TIMESTAMP / CHAIN）
CALL zy_add_column_if_absent('zy_evaluation_grade', 'evidence_level',
    'VARCHAR(16) NOT NULL DEFAULT ''HASH'' COMMENT ''存证等级：HASH/TIMESTAMP/CHAIN'' AFTER `chain_proof`');

-- 封存时间：哈希时间锚点，独立于 created_at（created_at 由自动填充生成，
-- 与 seal 时刻可能有微秒差异，用它做锚点会导致校验必然失败）
CALL zy_add_column_if_absent('zy_evaluation_grade', 'sealed_at',
    'DATETIME NULL COMMENT ''封存时间（哈希时间锚点）'' AFTER `verify_code`');

-- 超时默认计分标识（FR-M6-06）
CALL zy_add_column_if_absent('zy_evaluation_grade', 'timeout_flag',
    'TINYINT NOT NULL DEFAULT 0 COMMENT ''是否超时默认计分：0否 1是'' AFTER `dispute_flag`');

-- 审核状态（疑似互刷或含攻击性用语时转人工复核）
CALL zy_add_column_if_absent('zy_evaluation_grade', 'audit_status',
    'VARCHAR(16) NOT NULL DEFAULT ''PASSED'' COMMENT ''审核状态：PASSED/PENDING'' AFTER `timeout_flag`');
CALL zy_add_column_if_absent('zy_evaluation_grade', 'audit_remark',
    'VARCHAR(255) DEFAULT NULL COMMENT ''审核说明（命中的风险特征）'' AFTER `audit_status`');

-- 既有历史数据回填 sealed_at（用 created_at 兜底），随后收紧为非空。
-- 顺序很重要：先加可空列 → 回填 → 改非空，否则已有行会因 NOT NULL 无默认值而失败。
UPDATE `zy_evaluation_grade` SET `sealed_at` = `created_at` WHERE `sealed_at` IS NULL;

SET @nullable := (SELECT IS_NULLABLE FROM information_schema.COLUMNS
                  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'zy_evaluation_grade'
                    AND COLUMN_NAME = 'sealed_at');
SET @ddl := IF(@nullable = 'YES',
    'ALTER TABLE `zy_evaluation_grade` MODIFY COLUMN `sealed_at` DATETIME NOT NULL COMMENT ''封存时间（哈希时间锚点，参与哈希计算）''',
    'SELECT ''skip: sealed_at already NOT NULL'' AS migrate_note');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 校验码索引：证书验真是匿名高频入口，需要索引
SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'zy_evaluation_grade'
               AND INDEX_NAME = 'idx_eval_verify_code');
SET @ddl := IF(@idx = 0,
    'ALTER TABLE `zy_evaluation_grade` ADD INDEX `idx_eval_verify_code` (`verify_code`)',
    'SELECT ''skip: idx_eval_verify_code already exists'' AS migrate_note');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------------------------------
-- 新建互评修正记录表（结构同 01-schema.sql，二者不冲突）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_evaluation_amendment`
(
    `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `evaluation_id` BIGINT       NOT NULL COMMENT '被修正的评价记录 ID',
    `record_id`     BIGINT       NOT NULL COMMENT '交换记录 ID（冗余，便于按交换查询）',
    `reason`        VARCHAR(500) NOT NULL COMMENT '修正原因（如：争议裁决 / 笔误更正）',
    `changes`       JSON                  DEFAULT NULL COMMENT '变更明细快照',
    `score_before`  DECIMAL(5, 2)         DEFAULT NULL COMMENT '修正前总分',
    `score_after`   DECIMAL(5, 2)         DEFAULT NULL COMMENT '修正后总分',
    `operator`      VARCHAR(32)  NOT NULL COMMENT '操作人学号（管理员/仲裁委员）',
    `dispute_id`    BIGINT                DEFAULT NULL COMMENT '关联争议 ID（若源于裁决）',
    `status`        VARCHAR(16)  NOT NULL DEFAULT 'EFFECTIVE' COMMENT '状态：EFFECTIVE 已生效 / REVOKED 已撤销',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_amend_eval` (`evaluation_id`),
    KEY `idx_amend_record` (`record_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='互评修正记录表（追加式，不覆盖历史）';

-- -----------------------------------------------------------------------------
-- 清理临时过程
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `zy_add_column_if_absent`;

-- -----------------------------------------------------------------------------
-- 校验
-- -----------------------------------------------------------------------------
SELECT 'M6 migration completed' AS message,
       (SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'zy_evaluation_grade'
          AND COLUMN_NAME IN ('hash_payload', 'evidence_level', 'sealed_at',
                              'timeout_flag', 'audit_status', 'audit_remark')) AS added_columns,
       (SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'zy_evaluation_amendment') AS amendment_table,
       (SELECT COUNT(*) FROM `zy_evaluation_grade` WHERE `sealed_at` IS NULL) AS rows_without_sealed_at;
