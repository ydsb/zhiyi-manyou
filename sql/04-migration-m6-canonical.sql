-- =============================================================================
--  知驿·漫游 —— 增量迁移  M6 修正版：为互评存证引入"规范化维度串"
--
--  背景（这是一个必须记录的设计修正）：
--    M6 首版把 dim_scores（MySQL JSON 列）的原始字符串直接纳入哈希计算。
--    但 JSON 是"规范化存储"——写入的紧凑串与读回的表示可能不同
--    （会加空格、按内部顺序重排），导致按实体重建原文时<b>永远无法逐字节重现</b>，
--    结果连未被篡改的记录也会被校验接口误报为"已改动"。
--
--    修正方案：另存一列 dim_canonical，内容为只由数值决定的确定性字符串
--    （固定 key 顺序、固定一位小数、固定分隔符），它可逐字节重现，
--    用它参与哈希即可同时满足"未改动能通过"与"被改动能检出"。
--
--  注意：本脚本会重算所有历史互评记录的哈希 —— 因为哈希原文的构成变了。
--        重算后历史记录同样受新机制保护（这是自有数据的合理迁移）。
--
--  导入方式：mysql -uroot -p < 04-migration-m6-canonical.sql
-- =============================================================================

USE `zhiyi_manyou`;

-- -----------------------------------------------------------------------------
-- 1. 增加 dim_canonical 列
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `zy_add_col`;
DELIMITER $$
CREATE PROCEDURE `zy_add_col`(IN p_table VARCHAR(64), IN p_col VARCHAR(64), IN p_def VARCHAR(500))
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

CALL zy_add_col('zy_evaluation_grade', 'dim_canonical',
    'VARCHAR(255) DEFAULT NULL COMMENT ''维度分规范串（确定性、逐字节可重现，参与哈希）'' AFTER `dim_scores`');

DROP PROCEDURE IF EXISTS `zy_add_col`;

-- -----------------------------------------------------------------------------
-- 2. 回填 dim_canonical
--
-- 由 dim_scores 的数值生成规范串。顺序与 Java 端 Enum 声明一致：
--   task_completion;delivery_quality;communication;cross_discipline
-- 数值统一一位小数（Java 端用 setScale(1, HALF_UP)）。
-- -----------------------------------------------------------------------------
UPDATE `zy_evaluation_grade`
SET `dim_canonical` = CONCAT(
        'task_completion=',   FORMAT(JSON_EXTRACT(`dim_scores`, '$.task_completion'),   1), ';',
        'delivery_quality=',  FORMAT(JSON_EXTRACT(`dim_scores`, '$.delivery_quality'),  1), ';',
        'communication=',     FORMAT(JSON_EXTRACT(`dim_scores`, '$.communication'),     1), ';',
        'cross_discipline=',  FORMAT(JSON_EXTRACT(`dim_scores`, '$.cross_discipline'),  1)
    )
WHERE `dim_canonical` IS NULL AND `dim_scores` IS NOT NULL;

-- FORMAT() 会加千分位逗号（如 1,000.0），维度分最大 100 不会触发，
-- 但为稳妥仍做一次清理，保证与 Java 输出完全一致。
UPDATE `zy_evaluation_grade`
SET `dim_canonical` = REPLACE(`dim_canonical`, ',', '')
WHERE `dim_canonical` LIKE '%,%';

-- -----------------------------------------------------------------------------
-- 3. 重算哈希
--
-- 新原文格式：record_id|from|to|dim_canonical|total(2位小数)|comment|sealed_at(秒)
-- 用 SHA2(..., 256) 与 Java 的 SHA-256 结果一致（都是小写十六进制）。
-- -----------------------------------------------------------------------------
UPDATE `zy_evaluation_grade`
SET `hash_payload` = CONCAT_WS('|',
        `record_id`,
        `from_sno`,
        `to_sno`,
        `dim_canonical`,
        FORMAT(`total_score`, 2),
        IFNULL(`comment`, '-'),
        DATE_FORMAT(`sealed_at`, '%Y-%m-%d %H:%i:%s'))
WHERE `sealed_at` IS NOT NULL AND `dim_canonical` IS NOT NULL;

UPDATE `zy_evaluation_grade`
SET `hash_payload` = REPLACE(`hash_payload`, ',', '')
WHERE `hash_payload` LIKE '%,%';

UPDATE `zy_evaluation_grade`
SET `record_hash` = SHA2(`hash_payload`, 256),
    `verify_code` = UPPER(LEFT(SHA2(`hash_payload`, 256), 8))
WHERE `hash_payload` IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 校验
-- -----------------------------------------------------------------------------
SELECT 'M6 canonical migration completed' AS message,
       (SELECT COUNT(*) FROM `zy_evaluation_grade`) AS total_rows,
       (SELECT COUNT(*) FROM `zy_evaluation_grade` WHERE `dim_canonical` IS NULL) AS missing_canonical,
       (SELECT COUNT(*) FROM `zy_evaluation_grade` WHERE `record_hash` IS NULL) AS missing_hash;

SELECT id, dim_canonical, total_score, LEFT(record_hash, 12) AS hash_head
FROM `zy_evaluation_grade` ORDER BY id LIMIT 3;
