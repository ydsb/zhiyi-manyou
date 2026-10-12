-- Durable notification outbox. Safe to rerun on MySQL 8.
CREATE TABLE IF NOT EXISTS `zy_notification_outbox`
(
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `sno` VARCHAR(32) NOT NULL,
    `type` VARCHAR(32) NOT NULL,
    `title` VARCHAR(128) NOT NULL,
    `content` VARCHAR(500) DEFAULT NULL,
    `ref_type` VARCHAR(32) DEFAULT NULL,
    `ref_id` BIGINT DEFAULT NULL,
    `idempotency_key` CHAR(64) DEFAULT NULL,
    `status` VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    `attempts` INT NOT NULL DEFAULT 0,
    `next_attempt_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `locked_at` DATETIME DEFAULT NULL,
    `sent_at` DATETIME DEFAULT NULL,
    `last_error` VARCHAR(500) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_notification_outbox_idempotency` (`idempotency_key`),
    KEY `idx_notification_outbox_pending` (`status`,`next_attempt_at`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知事务 outbox 与重试队列';

SET @outbox_id_column_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema=DATABASE() AND table_name='zy_notification' AND column_name='outbox_id'
);
SET @outbox_id_ddl = IF(@outbox_id_column_exists=0,
    'ALTER TABLE `zy_notification` ADD COLUMN `outbox_id` BIGINT DEFAULT NULL COMMENT ''来源 outbox 事件'' AFTER `read_flag`',
    'SELECT 1');
PREPARE outbox_id_stmt FROM @outbox_id_ddl;
EXECUTE outbox_id_stmt;
DEALLOCATE PREPARE outbox_id_stmt;

SET @outbox_idx_exists = (
    SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema=DATABASE() AND table_name='zy_notification' AND index_name='uk_notification_outbox_id'
);
SET @outbox_idx_ddl = IF(@outbox_idx_exists=0,
    'ALTER TABLE `zy_notification` ADD UNIQUE KEY `uk_notification_outbox_id` (`outbox_id`)',
    'SELECT 1');
PREPARE outbox_idx_stmt FROM @outbox_idx_ddl;
EXECUTE outbox_idx_stmt;
DEALLOCATE PREPARE outbox_idx_stmt;
