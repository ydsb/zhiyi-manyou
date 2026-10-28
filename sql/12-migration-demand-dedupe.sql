-- 需求卡片并发去重（方案 B：只约束同时处于 OPEN 的相同卡片）。
-- 适用 MySQL 5.7+，可重复执行。
-- 指纹字段由应用按 DemandFingerprint 的规范化规则写入；历史数据在此脚本回填。

SET @dedupe_col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'zy_demand' AND column_name = 'dedupe_hash'
);
SET @dedupe_col_ddl = IF(@dedupe_col_exists = 0,
    'ALTER TABLE `zy_demand` ADD COLUMN `dedupe_hash` CHAR(64) NULL COMMENT ''用户可编辑业务内容的规范化 SHA-256 指纹'' AFTER `demand_no`',
    'SELECT 1');
PREPARE dedupe_col_stmt FROM @dedupe_col_ddl;
EXECUTE dedupe_col_stmt;
DEALLOCATE PREPARE dedupe_col_stmt;

-- 与 Java DemandFingerprint 保持一致：UTF-8 字节长度前缀 + 固定字段顺序 + 0x1F 分隔。
UPDATE `zy_demand`
SET `dedupe_hash` = SHA2(CONCAT(
        'S:', LENGTH(TRIM(`title`)), ':', TRIM(`title`), CHAR(31),
        CASE WHEN `description` IS NULL OR TRIM(`description`) = '' THEN 'N'
             ELSE CONCAT('S:', LENGTH(TRIM(`description`)), ':', TRIM(`description`)) END, CHAR(31),
        'L:', `expected_skill_id`, CHAR(31),
        CASE WHEN `offer_skill_id` IS NULL THEN 'N'
             ELSE CONCAT('L:', `offer_skill_id`) END, CHAR(31),
        CASE WHEN `expected_hours` IS NULL THEN 'N'
             ELSE CONCAT('I:', `expected_hours`) END, CHAR(31),
        CASE WHEN `expected_period` IS NULL OR TRIM(`expected_period`) = '' THEN 'N'
             ELSE CONCAT('S:', LENGTH(TRIM(`expected_period`)), ':', TRIM(`expected_period`)) END, CHAR(31),
        'S:', LENGTH(`visibility`), ':', `visibility`, CHAR(31),
        CASE WHEN `expire_at` IS NULL THEN 'N'
             ELSE CONCAT('S:', LENGTH(DATE_FORMAT(`expire_at`, '%Y-%m-%dT%H:%i:%s')), ':',
                         DATE_FORMAT(`expire_at`, '%Y-%m-%dT%H:%i:%s')) END
    ), 256)
WHERE `dedupe_hash` IS NULL OR `dedupe_hash` = '';

ALTER TABLE `zy_demand`
    MODIFY COLUMN `dedupe_hash` CHAR(64) NOT NULL COMMENT '用户可编辑业务内容的规范化 SHA-256 指纹';

SET @active_col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'zy_demand' AND column_name = 'active_dedupe_hash'
);
SET @active_col_ddl = IF(@active_col_exists = 0,
    'ALTER TABLE `zy_demand` ADD COLUMN `active_dedupe_hash` CHAR(64) GENERATED ALWAYS AS (CASE WHEN `status` = ''OPEN'' AND `deleted` = 0 THEN `dedupe_hash` ELSE NULL END) STORED COMMENT ''仅开放卡片参与的活跃去重指纹''',
    'SELECT 1');
PREPARE active_col_stmt FROM @active_col_ddl;
EXECUTE active_col_stmt;
DEALLOCATE PREPARE active_col_stmt;

SET @dedupe_idx_exists = (
    SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'zy_demand'
      AND index_name = 'uk_demand_owner_active_dedupe'
);
SET @dedupe_idx_ddl = IF(@dedupe_idx_exists = 0,
    'ALTER TABLE `zy_demand` ADD UNIQUE KEY `uk_demand_owner_active_dedupe` (`owner_sno`, `active_dedupe_hash`)',
    'SELECT 1');
PREPARE dedupe_idx_stmt FROM @dedupe_idx_ddl;
EXECUTE dedupe_idx_stmt;
DEALLOCATE PREPARE dedupe_idx_stmt;
