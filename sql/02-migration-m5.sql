-- =============================================================================
--  知驿·漫游 —— 增量迁移脚本  M5 协作工作台
--  数据库：MySQL 8.0+    字符集：utf8mb4
--
--  为什么需要这个文件：
--    01-schema.sql 全部使用 CREATE TABLE IF NOT EXISTS，对**新建**的库是幂等的，
--    但它不会给**已存在**的表补列。当表结构演进时（例如给 zy_collab_task 增加
--    assignee_sno），旧库需要单独的 ALTER。MySQL 8 不支持
--    `ADD COLUMN IF NOT EXISTS`，因此这里用 information_schema 判断 + 动态 SQL
--    实现幂等，重复执行安全。
--
--  新库无需执行本脚本（01-schema.sql 已含最新结构）。
--
--  导入方式：
--      mysql -uroot -p < 02-migration-m5.sql
-- =============================================================================

USE `zhiyi_manyou`;

-- -----------------------------------------------------------------------------
-- 1. zy_collab_task.assignee_sno —— 任务负责人
--
-- FR-M5-06 要求把"任务拆解粒度、按期率"等落到**个人**维度，用于过程性评价。
-- 只有 created_by 无法区分"谁负责做"，因此补一个负责人字段。
-- -----------------------------------------------------------------------------
SET @exists := (SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'zy_collab_task'
                  AND COLUMN_NAME = 'assignee_sno');
SET @ddl := IF(@exists = 0,
    'ALTER TABLE `zy_collab_task` ADD COLUMN `assignee_sno` VARCHAR(32) DEFAULT NULL COMMENT ''负责人学号（FR-M5-06：用于计算个人过程性指标）'' AFTER `description`',
    'SELECT ''skip: assignee_sno already exists'' AS migrate_note');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx := (SELECT COUNT(*) FROM information_schema.STATISTICS
             WHERE TABLE_SCHEMA = DATABASE()
               AND TABLE_NAME = 'zy_collab_task'
               AND INDEX_NAME = 'idx_task_assignee');
SET @ddl := IF(@idx = 0,
    'ALTER TABLE `zy_collab_task` ADD INDEX `idx_task_assignee` (`assignee_sno`)',
    'SELECT ''skip: idx_task_assignee already exists'' AS migrate_note');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------------------------------
-- 2. 新建 M5 表（若已由 01-schema.sql 创建则跳过）
--    这里重复一份最小定义，方便只跑迁移脚本的旧库也能对齐结构。
--    结构与 01-schema.sql 完全一致，二者不会冲突。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_collab_file`
(
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `record_id`    BIGINT       NOT NULL COMMENT '所属交换记录 ID',
    `group_key`    VARCHAR(64)  NOT NULL COMMENT '逻辑文件标识（同一文件的多版本共享）',
    `version`      INT          NOT NULL DEFAULT 1 COMMENT '版本号，从 1 自增',
    `is_latest`    TINYINT      NOT NULL DEFAULT 1 COMMENT '是否最新版本：1是 0否（历史版本）',
    `file_name`    VARCHAR(255) NOT NULL COMMENT '原始文件名',
    `content_type` VARCHAR(128)          DEFAULT NULL COMMENT 'MIME 类型',
    `size_bytes`   BIGINT       NOT NULL DEFAULT 0 COMMENT '文件大小（字节）',
    `storage_type` VARCHAR(16)  NOT NULL DEFAULT 'LOCAL' COMMENT '存储类型：LOCAL 本地 / OSS 对象存储（FR-M9-06）',
    `storage_path` VARCHAR(500) NOT NULL COMMENT '存储路径或对象键（不对外暴露）',
    `sha256`       CHAR(64)              DEFAULT NULL COMMENT '内容摘要，用于去重与完整性校验',
    `task_id`      BIGINT                DEFAULT NULL COMMENT '关联任务项 ID（可作为该任务的交付物）',
    `uploader_sno` VARCHAR(32)  NOT NULL COMMENT '上传人学号',
    `remark`       VARCHAR(255)          DEFAULT NULL COMMENT '版本说明（本次改了什么）',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_file_group_version` (`record_id`, `group_key`, `version`),
    KEY `idx_file_record` (`record_id`, `created_at`),
    KEY `idx_file_task` (`task_id`),
    KEY `idx_file_latest` (`record_id`, `group_key`, `is_latest`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='协作空间文件版本表';

CREATE TABLE IF NOT EXISTS `zy_collab_message`
(
    `id`           BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
    `record_id`    BIGINT        NOT NULL COMMENT '所属交换记录 ID',
    `sender_sno`   VARCHAR(32)   NOT NULL COMMENT '发送人学号',
    `content`      VARCHAR(2000)          DEFAULT NULL COMMENT '文字内容',
    `file_id`      BIGINT                 DEFAULT NULL COMMENT '附件文件 ID（zy_collab_file）',
    `message_type` VARCHAR(16)   NOT NULL DEFAULT 'TEXT' COMMENT '消息类型：TEXT 文字 / FILE 附件 / SYSTEM 系统提示',
    `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
    PRIMARY KEY (`id`),
    KEY `idx_msg_record_time` (`record_id`, `created_at`),
    KEY `idx_msg_sender` (`sender_sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='协作空间留言表';

CREATE TABLE IF NOT EXISTS `zy_collab_event`
(
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `record_id`   BIGINT       NOT NULL COMMENT '所属交换记录 ID',
    `actor_sno`   VARCHAR(32)           DEFAULT NULL COMMENT '行为主体学号（系统事件可为空）',
    `event_type`  VARCHAR(32)  NOT NULL COMMENT '事件类型：EXCHANGE_START/TASK_CREATE/TASK_CLAIM/TASK_DONE/TASK_OVERDUE/FILE_UPLOAD/MESSAGE/STATUS_CHANGE/CONFIRM',
    `title`       VARCHAR(200) NOT NULL COMMENT '时间轴标题（已渲染完毕，前端直接展示）',
    `detail`      VARCHAR(500)          DEFAULT NULL COMMENT '补充说明',
    `ref_type`    VARCHAR(32)           DEFAULT NULL COMMENT '关联对象类型：TASK/FILE/MESSAGE/EXCHANGE',
    `ref_id`      BIGINT                DEFAULT NULL COMMENT '关联对象 ID',
    `occurred_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
    PRIMARY KEY (`id`),
    KEY `idx_event_record_time` (`record_id`, `occurred_at`),
    KEY `idx_event_actor` (`actor_sno`, `occurred_at`),
    KEY `idx_event_type` (`event_type`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='协作事件表（时间轴与过程性评价语料）';

-- -----------------------------------------------------------------------------
-- 校验
-- -----------------------------------------------------------------------------
SELECT 'M5 migration completed' AS message,
       (SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME IN ('zy_collab_task', 'zy_collab_file', 'zy_collab_message', 'zy_collab_event')) AS m5_table_count,
       (SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'zy_collab_task' AND COLUMN_NAME = 'assignee_sno') AS assignee_column;
