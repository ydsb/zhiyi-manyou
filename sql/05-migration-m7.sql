-- =============================================================================
--  知驿·漫游 —— 增量迁移  M7 数字档案与能力画像
--  数据库：MySQL 8.0+    字符集：utf8mb4
--
--  新增两张表：
--    zy_ability_profile  能力画像快照（驱动雷达图与成长轨迹）
--    zy_growth_report    智能成长周报
--
--  为什么需要快照表（设计说明）：
--    实时计算只能得到"当前值"，画不出成长曲线 —— 历史状态没有被记录。
--    因此定时任务按周期写入快照，成长轨迹读的是快照序列。
--    主页雷达图仍走实时计算，以保证 AC-06「雷达图随协作数据变化正确刷新」。
--    两者共用同一个计算器（ProfileCalculator），口径天然一致。
--
--  导入方式：mysql -uroot -p < 05-migration-m7.sql
-- =============================================================================

USE `zhiyi_manyou`;

-- -----------------------------------------------------------------------------
-- 1. 能力画像快照表
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_ability_profile`
(
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`          VARCHAR(32)  NOT NULL COMMENT '学号',
    `period`       VARCHAR(16)  NOT NULL COMMENT '快照周期：yyyy-MM（月度）/ yyyy-MM-dd（手动刷新）',
    `period_type`  VARCHAR(16)  NOT NULL DEFAULT 'MONTH' COMMENT '周期类型：MONTH 月度 / MANUAL 手动',
    `dims`         JSON         NOT NULL COMMENT '五维得分，无数据的维度为 null',
    `sample_count` INT          NOT NULL DEFAULT 0 COMMENT '参与计算的样本数（已完成且有互评的交换数）',
    `avg_score`    DECIMAL(5, 2)         DEFAULT NULL COMMENT '样本的平均互评总分',
    `total_hours`  DECIMAL(7, 2)         DEFAULT NULL COMMENT '累计协作时长（小时）',
    `raw_inputs`   JSON                  DEFAULT NULL COMMENT '口径说明与原始计数（可解释性依据）',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_profile_sno_period` (`sno`, `period`, `period_type`),
    KEY `idx_profile_sno` (`sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='能力画像快照表（驱动雷达图与成长轨迹）';

-- -----------------------------------------------------------------------------
-- 2. 成长周报表
--
-- 用 ISO 周（yyyy-Www）做唯一键：自然周会跨越月份与年份边界
-- （12 月 31 日可能属于次年第 1 周），用月份做键会重复或遗漏。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_growth_report`
(
    `id`         BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`        VARCHAR(32)   NOT NULL COMMENT '学号',
    `week_key`   VARCHAR(16)   NOT NULL COMMENT '周标识：yyyy-Www（ISO 周）',
    `week_start` DATE          NOT NULL COMMENT '周一日期',
    `week_end`   DATE          NOT NULL COMMENT '周日日期',
    `summary`    VARCHAR(2000)          DEFAULT NULL COMMENT '自然语言总结',
    `highlights` JSON                   DEFAULT NULL COMMENT '本期亮点（结构化）',
    `metrics`    JSON                   DEFAULT NULL COMMENT '本期量化指标',
    `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_report_sno_week` (`sno`, `week_key`),
    KEY `idx_report_sno` (`sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='智能成长周报表';

-- -----------------------------------------------------------------------------
-- 3. 校验
-- -----------------------------------------------------------------------------
SELECT 'M7 migration completed' AS message,
       (SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME IN ('zy_ability_profile', 'zy_growth_report')) AS created_tables;

-- 勋章定义（若 01-schema.sql 已插入则忽略）
INSERT INTO `zy_badge` (`code`, `name`, `description`, `condition_expr`, `icon`, `level`, `status`)
VALUES ('FIRST_EXCHANGE', '初次驿动', '完成第一次技能交换，正式成为驿友', 'completed_exchange >= 1', '🚀', 1, 1),
       ('CROSS_3_COLLEGE', '跨院漫游者', '与来自 3 个不同学院的同学完成过协作', 'distinct_college >= 3', '🧭', 2, 1),
       ('SKILL_MASTER', '技能驿主', '教会 5 位同学你的技能，且平均互评不低于 85 分',
        'skill_learners >= 5 AND avg_score >= 85', '👑', 3, 1),
       ('TRUSTED', '信赖之驿', '信用值达到 150，成为社区可信成员', 'credit_score >= 150', '🛡️', 3, 1),
       ('DATA_VOYAGER', '数据远航者', '在数学与数据相关领域完成 2 次协作', 'completed_exchange >= 2', '📊', 2, 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `description` = VALUES(`description`),
                        `condition_expr` = VALUES(`condition_expr`), `icon` = VALUES(`icon`);

SELECT id, code, name, condition_expr FROM `zy_badge` ORDER BY id;
