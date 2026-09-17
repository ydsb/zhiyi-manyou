-- =============================================================================
--  知驿·漫游 —— 增量迁移  M9 管理后台
--  数据库：MySQL 8.0+    字符集：utf8mb4
--
--  M9 补齐四块缺失的管理能力：
--    1. 内容举报（FR-M9-03）：用户可举报卡片/留言/评价，进入审核队列
--    2. 技能标签批量导入批次（FR-M9-02）：可追溯"这批标签是谁什么时候导的"
--    3. 运营看板快照（FR-M9-04）：日活等指标按日落库，避免看板每次都全表扫描
--    4. 用户管理所需的补充字段已在 zy_student 内（status / role / auth_status），无需新增
--
--  注：M9-05 行为日志（zy_interaction_log）已在 01-schema.sql 建表；
--      M9-07/08 的开放接口不涉及新表。
--
--  导入方式：mysql -uroot -p < 07-migration-m9.sql
-- =============================================================================

USE `zhiyi_manyou`;

-- -----------------------------------------------------------------------------
-- 1. 内容举报表（FR-M9-03）
--
-- 为什么单独建表而不是复用 zy_dispute：
--   dispute 针对的是**交换履约争议**（有当事人双方、走仲裁委员会流程）；
--   举报针对的是**内容违规**（广告、辱骂、虚假信息），由管理员直接处置。
--   两者的处理主体、时限与后果完全不同，混在一张表里会让两种流程互相干扰。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_content_report`
(
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `reporter_sno`   VARCHAR(32)  NOT NULL COMMENT '举报人学号',
    `target_type`    VARCHAR(32)  NOT NULL COMMENT '被举报对象类型：DEMAND 需求卡片 / MESSAGE 协作留言 / EVALUATION 互评 / SKILL 技能标签',
    `target_id`      BIGINT       NOT NULL COMMENT '被举报对象 ID',
    `reason_type`    VARCHAR(32)  NOT NULL COMMENT '举报类型：AD 广告营销 / ABUSE 辱骂攻击 / FAKE 虚假信息 / PLAGIARISM 抄袭 / OTHER 其他',
    `detail`         VARCHAR(500) DEFAULT NULL COMMENT '补充说明',
    `status`         VARCHAR(16)  NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING 待处理 / ACCEPTED 举报成立 / REJECTED 举报不成立',
    `handler_sno`    VARCHAR(32)  DEFAULT NULL COMMENT '处理人学号',
    `handle_remark`  VARCHAR(500) DEFAULT NULL COMMENT '处理说明（必填，写入审计）',
    `handled_at`     DATETIME     DEFAULT NULL COMMENT '处理时间',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '举报时间',
    PRIMARY KEY (`id`),
    KEY `idx_report_status` (`status`),
    KEY `idx_report_target` (`target_type`, `target_id`),
    KEY `idx_report_reporter` (`reporter_sno`),
    -- 同一人对同一对象只能举报一次，避免刷举报
    UNIQUE KEY `uk_report_reporter_target` (`reporter_sno`, `target_type`, `target_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='内容举报表（FR-M9-03 审核队列）';

-- -----------------------------------------------------------------------------
-- 2. 技能标签导入批次（FR-M9-02）
--
-- 为什么要记录批次：批量导入是高风险操作（一次可能写入上千条标签）。
-- 有了批次记录才能回答"这批错误标签是谁在什么时候导进来的"，并支持按批次回溯。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_skill_import_batch`
(
    `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `batch_no`      VARCHAR(40)  NOT NULL COMMENT '批次号',
    `operator_sno`  VARCHAR(32)  NOT NULL COMMENT '操作人学号',
    `total_count`   INT          NOT NULL DEFAULT 0 COMMENT '提交条数',
    `success_count` INT          NOT NULL DEFAULT 0 COMMENT '成功条数',
    `fail_count`    INT          NOT NULL DEFAULT 0 COMMENT '失败条数',
    `errors`        JSON         DEFAULT NULL COMMENT '失败明细（行号 + 原因）',
    `source`        VARCHAR(32)  NOT NULL DEFAULT 'ADMIN_UI' COMMENT '来源：ADMIN_UI 后台导入 / API 接口 / SEED 初始化',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '导入时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_batch_no` (`batch_no`),
    KEY `idx_batch_operator` (`operator_sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='技能标签批量导入批次表（FR-M9-02）';

-- -----------------------------------------------------------------------------
-- 3. 运营看板日快照（FR-M9-04）
--
-- 看板指标（日活、完成量、匹配成功率）需要按日对比趋势。
-- 若每次都实时聚合，随着数据增长会越来越慢，且历史趋势无法回溯
-- （例如"上周三的日活"在数据变化后就算不出来了）。因此按日落库快照。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_dashboard_snapshot`
(
    `id`                BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `stat_date`         DATE         NOT NULL COMMENT '统计日期',
    `active_users`      INT          NOT NULL DEFAULT 0 COMMENT '当日活跃用户数（有登录或行为记录）',
    `new_users`         INT          NOT NULL DEFAULT 0 COMMENT '当日新增用户',
    `demand_published`  INT          NOT NULL DEFAULT 0 COMMENT '当日发布卡片数',
    `exchange_started`  INT          NOT NULL DEFAULT 0 COMMENT '当日开始的交换数',
    `exchange_finished` INT          NOT NULL DEFAULT 0 COMMENT '当日完成的交换数',
    `match_success_rate` DECIMAL(5, 2) DEFAULT NULL COMMENT '匹配成功率：发出邀约中被接受的比率',
    `metrics`           JSON         DEFAULT NULL COMMENT '扩展指标：学科分布、信用分布等',
    `created_at`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_snapshot_date` (`stat_date`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='运营看板日快照表（FR-M9-04）';

-- -----------------------------------------------------------------------------
-- 4. 校验
-- -----------------------------------------------------------------------------
SELECT 'M9 migration completed' AS message,
       (SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME IN ('zy_content_report', 'zy_skill_import_batch', 'zy_dashboard_snapshot')) AS created_tables,
       (SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'zy_interaction_log') AS interaction_log_exists;
