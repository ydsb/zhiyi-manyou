-- =============================================================================
--  知驿·漫游 —— 跨学科技能交换与学习记录平台
--  数据库初始化脚本  v1.0
--  数据库：MySQL 8.0+    字符集：utf8mb4
--
--  说明：
--   1. 本脚本幂等，可重复执行（全部使用 CREATE TABLE IF NOT EXISTS）。
--   2. 平台自身业务表统一以 zy_ 前缀命名；与教务系统（STUDENT/GRADE）保持
--      非侵入式只读映射，通过 sno 做逻辑关联，不修改教务库任何结构。
--   3. 导入方式：
--        mysql -uroot -p < 01-schema.sql
--      或在 Navicat / IDEA Database 中直接执行本文件。
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `zhiyi_manyou`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

USE `zhiyi_manyou`;

-- -----------------------------------------------------------------------------
-- 1. 用户（学生）主表
--    与教务基础信息表 STUDENT(sno, sname) 的关系：sno 为逻辑主键来源。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_student`
(
    `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`           VARCHAR(32)  NOT NULL COMMENT '学号（与教务系统一致，逻辑外键）',
    `sname`         VARCHAR(64)  NOT NULL COMMENT '姓名（映射教务 sname）',
    `nickname`      VARCHAR(64)           DEFAULT NULL COMMENT '昵称（对外展示名）',
    `password`      VARCHAR(100)          DEFAULT NULL COMMENT '密码（BCrypt 哈希；统一认证用户可为空）',
    `email`         VARCHAR(128)          DEFAULT NULL COMMENT '邮箱',
    `phone`         VARCHAR(32)           DEFAULT NULL COMMENT '手机号（脱敏展示，加密存储）',
    `college`       VARCHAR(64)           DEFAULT NULL COMMENT '学院',
    `major`         VARCHAR(64)           DEFAULT NULL COMMENT '专业',
    `grade`         VARCHAR(16)           DEFAULT NULL COMMENT '年级，如 2024级',
    `avatar`        VARCHAR(255)          DEFAULT NULL COMMENT '头像地址',
    `intro`         VARCHAR(500)          DEFAULT NULL COMMENT '个人简介',
    `auth_type`     VARCHAR(16)  NOT NULL DEFAULT 'LOCAL' COMMENT '认证方式：CAS/OAUTH2/LOCAL/VERIFY',
    `auth_status`   VARCHAR(16)  NOT NULL DEFAULT 'UNVERIFIED' COMMENT '实名核验状态：UNVERIFIED未核验/PENDING核验中/VERIFIED已核验/FAILED核验失败',
    `role`          VARCHAR(16)  NOT NULL DEFAULT 'USER' COMMENT '角色：USER/ARBITRATOR/ADMIN',
    `credit_score`  INT          NOT NULL DEFAULT 100 COMMENT '信用值（初始 100）',
    `credit_level`  TINYINT      NOT NULL DEFAULT 1 COMMENT '信用等级 1~5',
    `exchange_quota` INT         NOT NULL DEFAULT 5 COMMENT '并发进行中的交换上限（FR-M4-09 默认 5）',
    `status`        TINYINT      NOT NULL DEFAULT 1 COMMENT '账号状态：0禁用 1正常 2注销',
    `last_login_at` DATETIME              DEFAULT NULL COMMENT '最近登录时间',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`       TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0正常 1已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_student_sno` (`sno`),
    KEY `idx_student_college` (`college`),
    KEY `idx_student_major` (`major`),
    KEY `idx_student_credit` (`credit_score`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户（学生）主表';

-- -----------------------------------------------------------------------------
-- 2. 技能标签表（标准化技能本体，三层分类：门类 → 二级学科 → 技能）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_skill`
(
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name`         VARCHAR(128) NOT NULL COMMENT '技能标签名称',
    `alias`        VARCHAR(500)          DEFAULT NULL COMMENT '同义词/别名，逗号分隔（跨域术语映射）',
    `category_l1`  VARCHAR(64)  NOT NULL COMMENT '一级门类，如 工学/艺术学',
    `category_l2`  VARCHAR(64)  NOT NULL COMMENT '二级学科，如 计算机科学与技术',
    `description`  VARCHAR(500)          DEFAULT NULL COMMENT '技能描述',
    `difficulty`   TINYINT      NOT NULL DEFAULT 3 COMMENT '难度 1~5',
    `embedding_id` VARCHAR(64)           DEFAULT NULL COMMENT '向量库中的文档 ID（Elasticsearch）',
    `hot_score`    INT          NOT NULL DEFAULT 0 COMMENT '热度分（用于冷启动排序）',
    `status`       TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：0停用 1启用',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_skill_name` (`name`),
    KEY `idx_skill_category` (`category_l1`, `category_l2`),
    KEY `idx_skill_hot` (`hot_score`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='标准化技能标签表';

-- -----------------------------------------------------------------------------
-- 3. 技能知识图谱关系表（节点=技能，边=先决/互补/同义）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_skill_ontology`
(
    `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `src_skill_id`  BIGINT       NOT NULL COMMENT '源技能 ID',
    `dst_skill_id`  BIGINT       NOT NULL COMMENT '目标技能 ID',
    `relation_type` VARCHAR(16)  NOT NULL COMMENT '关系类型：PREREQUISITE先决 / COMPLEMENT互补 / SYNONYM同义',
    `weight`        DECIMAL(5, 4) NOT NULL DEFAULT 1.0000 COMMENT '关系强度 0~1（随机游走权重）',
    `directed`      TINYINT      NOT NULL DEFAULT 0 COMMENT '是否有向：0无向 1有向',
    `remark`        VARCHAR(255)          DEFAULT NULL COMMENT '备注（如：前端开发 ↔ UI/UX 设计 互补协作）',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_ontology_edge` (`src_skill_id`, `dst_skill_id`, `relation_type`),
    KEY `idx_ontology_src` (`src_skill_id`),
    KEY `idx_ontology_dst` (`dst_skill_id`),
    KEY `idx_ontology_type` (`relation_type`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='技能知识图谱关系表';

-- -----------------------------------------------------------------------------
-- 4. 技能与学科专业映射表（解决跨学科分类问题）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_skill_course_mapping`
(
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `skill_id`    BIGINT       NOT NULL COMMENT '技能 ID',
    `major_code`  VARCHAR(32)           DEFAULT NULL COMMENT '专业代码',
    `major_name`  VARCHAR(64)           DEFAULT NULL COMMENT '专业名称',
    `course_code` VARCHAR(32)           DEFAULT NULL COMMENT '课程代码（教务映射）',
    `course_name` VARCHAR(128)          DEFAULT NULL COMMENT '课程名称',
    `relevance`   DECIMAL(5, 4) NOT NULL DEFAULT 1.0000 COMMENT '相关度 0~1',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_skill_major_course` (`skill_id`, `major_code`, `course_code`),
    KEY `idx_scm_major` (`major_code`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='技能与学科专业映射表';

-- -----------------------------------------------------------------------------
-- 5. 用户技能画像表
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_user_skill_profile`
(
    `id`         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`        VARCHAR(32) NOT NULL COMMENT '学号',
    `skill_id`   BIGINT      NOT NULL COMMENT '技能 ID',
    `level`      TINYINT     NOT NULL DEFAULT 1 COMMENT '掌握等级 1~5',
    `intent`     VARCHAR(16) NOT NULL DEFAULT 'SKILLED' COMMENT '意图：SKILLED我擅长 / RESEARCHING在研 / NEEDED我急需',
    `source`     VARCHAR(16) NOT NULL DEFAULT 'SELF' COMMENT '来源：SELF自评 / PEER互评 / COURSE课程',
    `score`      DECIMAL(6, 2) NOT NULL DEFAULT 0.00 COMMENT '画像得分（由协作与互评累积）',
    `created_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_usp_sno_skill` (`sno`, `skill_id`),
    KEY `idx_usp_skill` (`skill_id`),
    KEY `idx_usp_intent` (`intent`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户技能画像表';

-- -----------------------------------------------------------------------------
-- 6. 技能需求卡片表（供需集市的 Issue 式卡片，FR-M4-01 / FR-M4-02）
--
-- 字段语义（与「以技易技」的对应关系，容易混淆，务必对齐）：
--   expected_skill_id —— 需求方「我急需」的技能（希望有人教我/帮我做）
--   offer_skill_id    —— 需求方「我擅长」、愿意作为回报教给对方的技能
-- 交换记录 zy_exchange_record 中的对应关系：
--   give_skill_id  = expected_skill_id（供给方提供这个技能）
--   learn_skill_id = offer_skill_id   （需求方回馈这个技能）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_demand`
(
    `id`               BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `demand_no`        VARCHAR(32)  NOT NULL COMMENT '业务编号（对外展示，如 DM2026xxxx）',
    `owner_sno`        VARCHAR(32)  NOT NULL COMMENT '发布人学号',
    `title`            VARCHAR(200) NOT NULL COMMENT '标题',
    `description`      TEXT                  DEFAULT NULL COMMENT '需求详述',
    `expected_skill_id` BIGINT      NOT NULL COMMENT '期望技能 ID（我急需，FR-M4-06 的 X→Y 中的被学习方）',
    `offer_skill_id`   BIGINT                DEFAULT NULL COMMENT '回馈技能 ID（我可提供，以技易技的另一半）',
    `expected_hours`   INT                   DEFAULT NULL COMMENT '预计投入时长（小时）',
    `expected_period`  VARCHAR(64)           DEFAULT NULL COMMENT '期望时间段，如 周末下午',
    `visibility`       VARCHAR(16)  NOT NULL DEFAULT 'PUBLIC' COMMENT '可见范围：PUBLIC 全校 / COLLEGE 本院系 / PRIVATE 仅受邀',
    `status`           VARCHAR(16)  NOT NULL DEFAULT 'OPEN' COMMENT '状态：OPEN 招募中 / MATCHED 已匹配 / CLOSED 已关闭',
    `match_count`      INT          NOT NULL DEFAULT 0 COMMENT '收到的交换邀约数',
    `view_count`       INT          NOT NULL DEFAULT 0 COMMENT '浏览次数',
    `audit_status`     VARCHAR(16)  NOT NULL DEFAULT 'PASSED' COMMENT '审核状态：PASSED 通过 / PENDING 待人工复核 / REJECTED 驳回（FR-M4-07）',
    `audit_remark`     VARCHAR(255)          DEFAULT NULL COMMENT '审核说明（命中敏感词/广告特征时记录）',
    `expire_at`        DATETIME              DEFAULT NULL COMMENT '过期时间',
    `created_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`          TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0正常 1已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_demand_no` (`demand_no`),
    KEY `idx_demand_owner` (`owner_sno`),
    KEY `idx_demand_expected_skill` (`expected_skill_id`),
    KEY `idx_demand_offer_skill` (`offer_skill_id`),
    KEY `idx_demand_status_time` (`status`, `created_at`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='技能需求卡片表（供需集市）';

-- -----------------------------------------------------------------------------
-- 7. 需求交换意向表（对某张卡片发起交换邀约的登记）
--    唯一索引保证同一人对同一卡片只能有一条进行中的意向，防止刷单（FR-M4-07）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_demand_interest`
(
    `id`            BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `demand_id`     BIGINT      NOT NULL COMMENT '需求卡片 ID',
    `applicant_sno` VARCHAR(32) NOT NULL COMMENT '申请人学号',
    `record_id`     BIGINT               DEFAULT NULL COMMENT '发起后生成的交换记录 ID',
    `match_score`   DECIMAL(5, 4)        DEFAULT NULL COMMENT '申请时的匹配度快照',
    `status`        VARCHAR(16) NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING 待响应 / ACCEPTED 已接受 / REJECTED 已拒绝 / WITHDRAWN 已撤回',
    `message`       VARCHAR(255)         DEFAULT NULL COMMENT '申请留言',
    `created_at`    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_interest_demand_applicant` (`demand_id`, `applicant_sno`),
    KEY `idx_interest_record` (`record_id`),
    KEY `idx_interest_applicant` (`applicant_sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='需求交换意向表';

-- -----------------------------------------------------------------------------
-- 8. 技能交换流水表（核心业务表）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_exchange_record`
(
    `id`                 BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `record_no`          VARCHAR(32)  NOT NULL COMMENT '业务编号（对外展示，如 ZY2026xxxx）',
    `giver_sno`          VARCHAR(32)  NOT NULL COMMENT '供给方学号（提供技能的一方）',
    `taker_sno`          VARCHAR(32)  NOT NULL COMMENT '需求方学号（学习技能的一方）',
    `give_skill_id`      BIGINT       NOT NULL COMMENT '供给方提供的技能 ID',
    `learn_skill_id`     BIGINT                DEFAULT NULL COMMENT '需求方回馈的技能 ID（以技易技）',
    `title`              VARCHAR(200) NOT NULL COMMENT '交换标题',
    `description`        TEXT                  DEFAULT NULL COMMENT '交换内容详述',
    `status`             VARCHAR(24)  NOT NULL DEFAULT 'PUBLISHED'
        COMMENT '状态：PUBLISHED已发布 / NEGOTIATING洽谈中 / IN_PROGRESS进行中 / PENDING_EVAL待互评 / COMPLETED已完成 / CANCELLED已取消 / DISPUTED争议中',
    `source_demand_id`   BIGINT                DEFAULT NULL COMMENT '来源需求卡片 ID（若由集市邀约产生）',
    `match_score`        DECIMAL(5, 4)         DEFAULT NULL COMMENT '匹配度分值 0~1',
    `expected_hours`     INT                   DEFAULT NULL COMMENT '预计投入时长（小时）',
    `actual_hours`       DECIMAL(8, 2)         DEFAULT NULL COMMENT '实际投入时长（小时）',
    `started_at`         DATETIME              DEFAULT NULL COMMENT '开始时间',
    `deadline_at`        DATETIME              DEFAULT NULL COMMENT '约定完成时间',
    `pending_eval_at`    DATETIME              DEFAULT NULL COMMENT '进入待互评时间',
    `finished_at`        DATETIME              DEFAULT NULL COMMENT '完成时间',
    `created_at`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`            TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0正常 1已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_exchange_no` (`record_no`),
    KEY `idx_ex_giver` (`giver_sno`),
    KEY `idx_ex_taker` (`taker_sno`),
    KEY `idx_ex_status` (`status`),
    KEY `idx_ex_giver_skill` (`give_skill_id`),
    KEY `idx_ex_created` (`created_at`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='技能交换流水表';

-- -----------------------------------------------------------------------------
-- 9. 协作空间任务项表（过程记录，FR-M5-02）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_collab_task`
(
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `record_id`    BIGINT       NOT NULL COMMENT '所属交换记录 ID',
    `title`        VARCHAR(200) NOT NULL COMMENT '任务标题',
    `description`  VARCHAR(500)          DEFAULT NULL COMMENT '任务说明',
    `assignee_sno` VARCHAR(32)           DEFAULT NULL COMMENT '负责人学号（FR-M5-06：用于计算个人过程性指标）',
    `deadline`     DATETIME              DEFAULT NULL COMMENT '截止时间',
    `status`       VARCHAR(16)  NOT NULL DEFAULT 'TODO' COMMENT '状态：TODO/DOING/DONE',
    `evidence_url` VARCHAR(500)          DEFAULT NULL COMMENT '成果证据地址',
    `sort_order`   INT          NOT NULL DEFAULT 0 COMMENT '排序',
    `done_at`      DATETIME              DEFAULT NULL COMMENT '完成时间',
    `created_by`   VARCHAR(32)  NOT NULL COMMENT '创建人学号',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_task_record` (`record_id`),
    KEY `idx_task_status` (`record_id`, `status`),
    KEY `idx_task_assignee` (`assignee_sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='协作空间任务项表';

-- -----------------------------------------------------------------------------
-- 10. 协作空间文件版本表（FR-M5-03 版本回溯 / FR-M5-07 附件）
--
-- 版本模型：group_key 标识"同一个逻辑文件"，每次上传生成一条新记录并
-- version 自增；历史版本保留（is_latest=0），从而支持回溯与 diff 对照。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_collab_file`
(
    `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `record_id`     BIGINT       NOT NULL COMMENT '所属交换记录 ID',
    `group_key`     VARCHAR(64)  NOT NULL COMMENT '逻辑文件标识（同一文件的多版本共享）',
    `version`       INT          NOT NULL DEFAULT 1 COMMENT '版本号，从 1 自增',
    `is_latest`     TINYINT      NOT NULL DEFAULT 1 COMMENT '是否最新版本：1是 0否（历史版本）',
    `file_name`     VARCHAR(255) NOT NULL COMMENT '原始文件名',
    `content_type`  VARCHAR(128)          DEFAULT NULL COMMENT 'MIME 类型',
    `size_bytes`    BIGINT       NOT NULL DEFAULT 0 COMMENT '文件大小（字节）',
    `storage_type`  VARCHAR(16)  NOT NULL DEFAULT 'LOCAL' COMMENT '存储类型：LOCAL 本地 / OSS 对象存储（FR-M9-06）',
    `storage_path`  VARCHAR(500) NOT NULL COMMENT '存储路径或对象键（不对外暴露）',
    `sha256`        CHAR(64)              DEFAULT NULL COMMENT '内容摘要，用于去重与完整性校验',
    `task_id`       BIGINT                DEFAULT NULL COMMENT '关联任务项 ID（可作为该任务的交付物）',
    `uploader_sno`  VARCHAR(32)  NOT NULL COMMENT '上传人学号',
    `remark`        VARCHAR(255)          DEFAULT NULL COMMENT '版本说明（本次改了什么）',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_file_group_version` (`record_id`, `group_key`, `version`),
    KEY `idx_file_record` (`record_id`, `created_at`),
    KEY `idx_file_task` (`task_id`),
    KEY `idx_file_latest` (`record_id`, `group_key`, `is_latest`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='协作空间文件版本表';

-- -----------------------------------------------------------------------------
-- 11. 协作空间留言表（FR-M5-07 在线沟通，聊天记录作为争议证据留存）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_collab_message`
(
    `id`           BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `record_id`    BIGINT      NOT NULL COMMENT '所属交换记录 ID',
    `sender_sno`   VARCHAR(32) NOT NULL COMMENT '发送人学号',
    `content`      VARCHAR(2000)        DEFAULT NULL COMMENT '文字内容',
    `file_id`      BIGINT               DEFAULT NULL COMMENT '附件文件 ID（zy_collab_file）',
    `message_type` VARCHAR(16) NOT NULL DEFAULT 'TEXT' COMMENT '消息类型：TEXT 文字 / FILE 附件 / SYSTEM 系统提示',
    `created_at`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
    PRIMARY KEY (`id`),
    KEY `idx_msg_record_time` (`record_id`, `created_at`),
    KEY `idx_msg_sender` (`sender_sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='协作空间留言表';

-- -----------------------------------------------------------------------------
-- 12. 协作事件表（FR-M5-04 时间轴 / FR-M5-06 过程性评价语料）
--
-- 与 zy_interaction_log 的分工：
--   zy_collab_event  —— 面向"协作进度"的结构化事件，用于时间轴与过程性评价指标；
--                       含 actor_sno 与 occurred_at，可直接聚合出个人指标。
--   zy_interaction_log —— 面向"行为埋点"的原始点击流，量大、用于画像与削峰落盘。
-- 两者互补，不重复。
-- -----------------------------------------------------------------------------
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
-- 13. 全过程行为日志表（点击流埋点，M9 经消息队列削峰落盘）
--
-- 与 zy_collab_event 的分工见上一节的说明：本表存原始埋点，量级大；
-- 协作事件表存面向进度与评价的结构化事件。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_interaction_log`
(
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`         VARCHAR(32) NOT NULL COMMENT '行为主体学号',
    `record_id`   BIGINT               DEFAULT NULL COMMENT '关联交换记录 ID',
    `action_type` VARCHAR(32) NOT NULL COMMENT '行为类型：PUBLISH/VIEW/INVITE/TASK_DONE/UPLOAD/CHAT/EVAL...',
    `target_type` VARCHAR(32)          DEFAULT NULL COMMENT '目标对象类型',
    `target_id`   BIGINT               DEFAULT NULL COMMENT '目标对象 ID',
    `duration`    INT                  DEFAULT NULL COMMENT '停留/处理时长（毫秒）',
    `payload`     JSON                 DEFAULT NULL COMMENT '行为附加数据（无损原始素材）',
    `created_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
    PRIMARY KEY (`id`),
    KEY `idx_log_sno_time` (`sno`, `created_at`),
    KEY `idx_log_record` (`record_id`),
    KEY `idx_log_action` (`action_type`, `created_at`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='全过程行为日志表';

-- -----------------------------------------------------------------------------
-- 14. 双向互评成绩表（提交后不可修改，仅可通过修正记录追加）
--
-- 【存证机制的诚实说明】
--   两级手段：
--     一级 record_hash —— 对评价实质内容计算 SHA-256 并固化，任何字段被改动都会
--          导致 verifyIntegrity() 失败（对应验收项 AC-05）。
--     二级 chain_proof —— 可选的外部锚定（可信时间戳 / 联盟链交易号），
--          技术路线由 S3 阶段确定（需求文档 Q5）。
--   ⚠️ 已知边界：只有哈希固化时，能改库且有权限的人可以连 record_hash 一起重算，
--      使记录重新自洽。要防住它必须依赖二级锚定或数据库权限隔离。
--      结项材料中不应宣称"物理上不可篡改"。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_evaluation_grade`
(
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `record_id`      BIGINT       NOT NULL COMMENT '交换记录 ID',
    `from_sno`       VARCHAR(32)  NOT NULL COMMENT '评价人学号',
    `to_sno`         VARCHAR(32)  NOT NULL COMMENT '被评价人学号',
    `dim_scores`     JSON         NOT NULL COMMENT '维度分：完成度/交付质量/沟通效率/跨专业协作能力',
    `total_score`    DECIMAL(5, 2) NOT NULL COMMENT '加权总分（0~100）',
    `comment`        VARCHAR(1000)         DEFAULT NULL COMMENT '文字评语',
    `anonymous`      TINYINT      NOT NULL DEFAULT 0 COMMENT '是否匿名：0实名 1匿名',
    `record_hash`    CHAR(64)     NOT NULL COMMENT '存证哈希 SHA-256，写入后不可变',
    `hash_payload`   VARCHAR(2000)         DEFAULT NULL COMMENT '哈希原文（用于精确复算，避免格式差异误报篡改）',
    `chain_proof`    VARCHAR(255)          DEFAULT NULL COMMENT '存证凭证（可信时间戳/链上交易号，S3 接入）',
    `evidence_level` VARCHAR(16)  NOT NULL DEFAULT 'HASH' COMMENT '存证等级：HASH 哈希固化 / TIMESTAMP 可信时间戳 / CHAIN 链上锚定',
    `verify_code`    VARCHAR(32)           DEFAULT NULL COMMENT '对外校验码，供《能力鉴定报告》验真',
    `sealed_at`      DATETIME     NOT NULL COMMENT '封存时间（参与哈希计算的时间锚点，独立于 created_at）',
    `dispute_flag`   TINYINT      NOT NULL DEFAULT 0 COMMENT '是否被申诉：0否 1是',
    `timeout_flag`   TINYINT      NOT NULL DEFAULT 0 COMMENT '是否超时默认计分：0否 1是（FR-M6-06）',
    `audit_status`   VARCHAR(16)  NOT NULL DEFAULT 'PASSED' COMMENT '审核状态：PASSED 通过 / PENDING 待人工复核（疑似互刷或含攻击性用语）',
    `audit_remark`   VARCHAR(255)          DEFAULT NULL COMMENT '审核说明（命中的风险特征）',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_eval_record_from` (`record_id`, `from_sno`),
    KEY `idx_eval_to` (`to_sno`),
    KEY `idx_eval_hash` (`record_hash`),
    KEY `idx_eval_verify_code` (`verify_code`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='双向互评成绩表（哈希固化存证）';

-- -----------------------------------------------------------------------------
-- 15. 互评修正记录表（FR-M6-03「仅可追加修正记录」的落地）
--
-- 评价本体写入后禁止 UPDATE；争议裁决需要改分时改为追加一条修正记录
-- （理由与前后分值留在本表可追溯），再由服务端把新分补写到评价表。
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
-- 16. 信用值变动流水表
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_credit_ledger`
(
    `id`            BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`           VARCHAR(32) NOT NULL COMMENT '学号',
    `delta`         INT         NOT NULL COMMENT '变动值（正加负减）',
    `score_after`   INT         NOT NULL COMMENT '变动后信用值',
    `reason`        VARCHAR(64) NOT NULL COMMENT '原因：EXCHANGE_DONE/EVAL_RECEIVED/TIMEOUT/DISPUTE_LOST/BADGE...',
    `ref_record_id` BIGINT               DEFAULT NULL COMMENT '关联交换记录 ID',
    `remark`        VARCHAR(255)         DEFAULT NULL COMMENT '说明',
    `created_at`    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_ledger_sno_time` (`sno`, `created_at`),
    KEY `idx_ledger_reason` (`reason`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='信用值变动流水表';

-- -----------------------------------------------------------------------------
-- 17. 能力画像快照表（FR-M7-03 批处理汇总结果 / FR-M7-07 成长轨迹）
--
-- 【为什么必须落库快照，而不是每次实时算】
--   实时计算只能得到"当前值"，画不出成长曲线 —— 历史状态没有被记录下来。
--   因此定时任务按周期写入快照，成长轨迹读的是快照序列。
--   同一用户同一周期只保留一条（唯一键），重跑批处理不会产生重复点。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_ability_profile`
(
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`            VARCHAR(32)  NOT NULL COMMENT '学号',
    `period`         VARCHAR(16)  NOT NULL COMMENT '快照周期：yyyy-MM（月度）/ yyyy-MM-dd（按需手动刷新）',
    `period_type`    VARCHAR(16)  NOT NULL DEFAULT 'MONTH' COMMENT '周期类型：MONTH 月度 / MANUAL 手动',
    `dims`           JSON         NOT NULL COMMENT '五维得分 {"engineering":88.5,...}，无数据的维度为 null',
    `sample_count`   INT          NOT NULL DEFAULT 0 COMMENT '参与计算的样本数（已完成交换数）',
    `avg_score`      DECIMAL(5, 2)         DEFAULT NULL COMMENT '样本的平均互评总分',
    `total_hours`    DECIMAL(7, 2)         DEFAULT NULL COMMENT '累计协作时长（小时）',
    `raw_inputs`     JSON                  DEFAULT NULL COMMENT '口径说明与原始计数（可解释性依据）',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_profile_sno_period` (`sno`, `period`, `period_type`),
    KEY `idx_profile_sno` (`sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='能力画像快照表（驱动雷达图与成长轨迹）';

-- -----------------------------------------------------------------------------
-- 18. 成长周报表（FR-M7-05）
--
-- 由定时任务每周生成，内容为结构化摘要 + 自然语言文本。
-- 生成后通过通知中心推送（复用 M5 的 NotificationService）。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_growth_report`
(
    `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`           VARCHAR(32)  NOT NULL COMMENT '学号',
    `week_key`      VARCHAR(16)  NOT NULL COMMENT '周标识：yyyy-Www（ISO 周）',
    `week_start`    DATE         NOT NULL COMMENT '周一日期',
    `week_end`      DATE         NOT NULL COMMENT '周日日期',
    `summary`       VARCHAR(2000)         DEFAULT NULL COMMENT '自然语言总结',
    `highlights`    JSON                  DEFAULT NULL COMMENT '本期亮点（结构化）',
    `metrics`       JSON                  DEFAULT NULL COMMENT '本期量化指标',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_report_sno_week` (`sno`, `week_key`),
    KEY `idx_report_sno` (`sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='智能成长周报表';

-- -----------------------------------------------------------------------------
-- 19. 数字勋章定义与授予记录
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_badge`
(
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `code`           VARCHAR(32)  NOT NULL COMMENT '勋章编码',
    `name`           VARCHAR(64)  NOT NULL COMMENT '勋章名称',
    `description`    VARCHAR(255)          DEFAULT NULL COMMENT '获取条件描述',
    `condition_expr` VARCHAR(255)          DEFAULT NULL COMMENT '达成条件表达式（规则引擎解析）',
    `icon`           VARCHAR(255)          DEFAULT NULL COMMENT '像素/体素风格图标地址',
    `level`          TINYINT      NOT NULL DEFAULT 1 COMMENT '勋章等级 1~5',
    `status`         TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：0停用 1启用',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_badge_code` (`code`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='数字勋章定义表';

CREATE TABLE IF NOT EXISTS `zy_user_badge`
(
    `id`         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`        VARCHAR(32) NOT NULL COMMENT '学号',
    `badge_id`   BIGINT      NOT NULL COMMENT '勋章 ID',
    `granted_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授予时间',
    `ref_record_id` BIGINT            DEFAULT NULL COMMENT '触发授予的交换记录 ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_badge` (`sno`, `badge_id`),
    KEY `idx_ub_sno` (`sno`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户勋章授予记录表';

-- -----------------------------------------------------------------------------
-- 20. 争议与仲裁
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_dispute`
(
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `record_id`   BIGINT       NOT NULL COMMENT '争议交换记录 ID',
    `applicant`   VARCHAR(32)  NOT NULL COMMENT '申诉人学号',
    `respondent`  VARCHAR(32)  NOT NULL COMMENT '被申诉人学号',
    `reason`      VARCHAR(500) NOT NULL COMMENT '申诉理由',
    `evidence`    JSON                  DEFAULT NULL COMMENT '证据材料（附件地址数组）',
    `status`      VARCHAR(16)  NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING待受理 / VOTING投票中 / RESOLVED已裁决 / REJECTED已驳回',    `verdict`     VARCHAR(500)          DEFAULT NULL COMMENT '裁决结论',
    `resolved_at` DATETIME              DEFAULT NULL COMMENT '裁决时间',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_dispute_record` (`record_id`),
    KEY `idx_dispute_status` (`status`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='争议申诉表';

CREATE TABLE IF NOT EXISTS `zy_arbitration_vote`
(
    `id`         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `dispute_id` BIGINT      NOT NULL COMMENT '争议 ID',
    `voter_sno`  VARCHAR(32) NOT NULL COMMENT '仲裁委员学号',
    `vote`       VARCHAR(16) NOT NULL COMMENT '投票：APPLICANT支持申诉人 / RESPONDENT支持被申诉人 / ABSTAIN弃权',
    `comment`    VARCHAR(500)         DEFAULT NULL COMMENT '投票说明（匿名公示）',
    `created_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '投票时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_vote_dispute_voter` (`dispute_id`, `voter_sno`),
    KEY `idx_vote_dispute` (`dispute_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='仲裁投票表';

-- -----------------------------------------------------------------------------
-- 21. 通知中心
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `zy_notification`
(
    `id`         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `sno`        VARCHAR(32)  NOT NULL COMMENT '接收人学号',
    `type`       VARCHAR(32)  NOT NULL COMMENT '类型：INVITE/TASK_REMIND/EVAL_REMIND/DISPUTE/BADGE/SYSTEM',
    `title`      VARCHAR(128) NOT NULL COMMENT '标题',
    `content`    VARCHAR(500)          DEFAULT NULL COMMENT '内容',
    `ref_type`   VARCHAR(32)           DEFAULT NULL COMMENT '关联业务类型',
    `ref_id`     BIGINT                DEFAULT NULL COMMENT '关联业务 ID',
    `read_flag`  TINYINT      NOT NULL DEFAULT 0 COMMENT '是否已读：0未读 1已读',
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_notify_sno_read` (`sno`, `read_flag`, `created_at`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='通知中心表';

-- =============================================================================
--  初始化数据
-- =============================================================================

-- 管理员账号（密码 123456 的 BCrypt 哈希，首次登录后请立即修改）
INSERT INTO `zy_student` (`sno`, `sname`, `nickname`, `password`, `college`, `major`, `grade`,
                          `auth_type`, `auth_status`, `role`, `credit_score`, `credit_level`, `exchange_quota`)
VALUES ('admin', '系统管理员', '知驿管理员',
        '$2a$10$MJyq4Y7DyH8hD.wwsFOWWux65d7UEhHYKBeEfnI.b/KlHzYD.2jhO',
        '计算机学院', '计算机科学与技术', '2024级', 'LOCAL', 'VERIFIED', 'ADMIN', 100, 5, 99)
ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

-- 演示用户（密码同为 123456）
INSERT INTO `zy_student` (`sno`, `sname`, `nickname`, `password`, `college`, `major`, `grade`,
                          `auth_type`, `auth_status`, `role`)
VALUES ('2024117420', '李泽宬', '知驿·漫游', '$2a$10$MJyq4Y7DyH8hD.wwsFOWWux65d7UEhHYKBeEfnI.b/KlHzYD.2jhO',
        '计算机学院', '计算机科学与技术', '2024级', 'LOCAL', 'VERIFIED', 'USER'),
       ('2024117421', '吴禹晗', '吴禹晗', '$2a$10$MJyq4Y7DyH8hD.wwsFOWWux65d7UEhHYKBeEfnI.b/KlHzYD.2jhO',
        '软件学院', '软件工程', '2024级', 'LOCAL', 'VERIFIED', 'USER'),
       ('2024117422', '杨渡', '杨渡', '$2a$10$MJyq4Y7DyH8hD.wwsFOWWux65d7UEhHYKBeEfnI.b/KlHzYD.2jhO',
        '计算机学院', '人工智能', '2024级', 'LOCAL', 'VERIFIED', 'USER')
ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

-- 技能标签示例（跨学科示范数据，完整 V1.0 需覆盖 ≥50 个二级学科、≥1000 个标签）
--
-- 关于 alias（别名）字段：它是 FR-M2-07「同义词库 / 跨域术语映射」的落地载体。
-- 填写原则：只要某个说法是学生真实会用的表达、且不是标签名的子串，就必须登记为别名。
-- 反例教训：「数据爬取」是标签「数据爬取与清洗」的最自然叫法，但二者并非子串关系，
--           早期未登记别名时该类描述无法命中，已在 V1.1 补齐。
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `description`, `difficulty`)
VALUES ('Vue 前端开发', '前端,Vue3,H5,页面开发,前端开发,网页开发', '工学', '计算机科学与技术', '基于 Vue 生态的 Web 前端工程开发', 4),
       ('JS 动画与交互实现', '动态交互效果,交互动效,动画库,页面动效,交互动画,动效', '工学', '计算机科学与技术', '使用 JS/GSAP/CSS 实现交互动效', 3),
       ('UI/UX 设计', '界面设计,交互设计,用户体验,视觉设计,UI设计,UX设计,原型设计', '艺术学', '设计学', '产品界面与用户体验设计', 3),
       ('ECharts 数据可视化', '可视化,图表,大屏,数据可视化,可视化图表,数据展示', '工学', '计算机科学与技术', '基于 ECharts 的数据可视化实现', 3),
       ('数据爬取与清洗', '爬虫,数据采集,ETL,数据爬取,数据抓取,数据清洗,采集数据', '工学', '计算机科学与技术', '网络数据采集与预处理', 4),
       ('学术论文写作', '论文,文献综述,写作,论文写作,论文润色,学术写作', '文学', '中国语言文学', '学术论文结构设计与写作规范', 3),
       ('数学建模', '建模,数模,优化,数学建模方法,优化模型', '理学', '数学', '实际问题抽象为数学模型并求解', 5),
       ('英语口语陪练', '口语,雅思,英语交流,英语口语,口语练习,英语对话', '文学', '外国语言文学', '英语口语交流与表达训练', 2),
       ('视频剪辑', 'PR,剪映,后期,视频后期,剪辑,后期制作', '艺术学', '戏剧与影视学', '视频素材剪辑与后期包装', 3),
       ('科研实验设计', '实验方案,对照组,变量控制,实验设计,实验方案设计,科研实验', '理学', '生物学', '实验方案设计与变量控制', 4),
       ('PPT 与汇报表达', '答辩,汇报,演示文稿,PPT制作,汇报材料,答辩材料,演示文稿制作', '艺术学', '设计学', '演示文稿设计与现场表达', 2),
       ('算法与数据结构', '算法,LeetCode,竞赛,数据结构,算法设计,编程竞赛', '工学', '计算机科学与技术', '算法设计与复杂度分析', 5)
-- 重新执行本脚本时同步更新别名与描述（早期只更新 updated_at，导致改别名不生效）
ON DUPLICATE KEY UPDATE `alias`       = VALUES(`alias`),
                        `description` = VALUES(`description`),
                        `difficulty`  = VALUES(`difficulty`),
                        `category_l1` = VALUES(`category_l1`),
                        `category_l2` = VALUES(`category_l2`);

-- 知识图谱关系示例：体现跨学科"互补协作"与"先决条件"
INSERT INTO `zy_skill_ontology` (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, '前端开发 ↔ UI/UX 设计：互补协作，隐性需求挖掘典型边'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.name = 'Vue 前端开发' AND s2.name = 'UI/UX 设计'
ON DUPLICATE KEY UPDATE `weight` = VALUES(`weight`);

INSERT INTO `zy_skill_ontology` (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先决条件：算法基础 → 数据爬取与清洗'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.name = '算法与数据结构' AND s2.name = '数据爬取与清洗'
ON DUPLICATE KEY UPDATE `weight` = VALUES(`weight`);

INSERT INTO `zy_skill_ontology` (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, '同义映射：解决"动态交互效果"与"JS 动画库"的语义鸿沟'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.name = 'JS 动画与交互实现' AND s2.name = 'UI/UX 设计'
ON DUPLICATE KEY UPDATE `weight` = VALUES(`weight`);

-- 需求卡片示例（供需集市，FR-M4-01）
-- 语义提醒：expected_skill_id 是"我急需"，offer_skill_id 是"我可提供"
INSERT INTO `zy_demand` (`demand_no`, `owner_sno`, `title`, `description`,
                         `expected_skill_id`, `offer_skill_id`, `expected_hours`,
                         `expected_period`, `visibility`, `status`)
SELECT 'DM20260701001', '2024117421',
       '需要会做动态交互效果的同学，帮我把作品集页面做得"活"一点',
       '已有 Vue3 静态页面，希望加入滚动视差、卡片翻转与页面过渡动画。我可以教你数学建模，或者帮你做实验数据处理。',
       s1.id, s2.id, 8, '工作日晚间 / 周末下午', 'PUBLIC', 'OPEN'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.name = 'JS 动画与交互实现' AND s2.name = '数学建模'
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `description` = VALUES(`description`);

INSERT INTO `zy_demand` (`demand_no`, `owner_sno`, `title`, `description`,
                         `expected_skill_id`, `offer_skill_id`, `expected_hours`,
                         `expected_period`, `visibility`, `status`)
SELECT 'DM20260701002', '2024117422',
       '毕设需要一组可交互的可视化图表，求 ECharts 指导',
       '数据已清洗完毕，需要指导 ECharts 配置与交互设计。我可以提供英语口语陪练或论文润色。',
       s1.id, s2.id, 6, '周末全天', 'PUBLIC', 'OPEN'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.name = 'ECharts 数据可视化' AND s2.name = '英语口语陪练'
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `description` = VALUES(`description`);

INSERT INTO `zy_demand` (`demand_no`, `owner_sno`, `title`, `description`,
                         `expected_skill_id`, `offer_skill_id`, `expected_hours`,
                         `expected_period`, `visibility`, `status`)
SELECT 'DM20260701003', '2024117420',
       '想学 Python 数据爬取，愿意用视频剪辑交换',
       '需要采集公开论文元数据用于文献综述。我熟悉 PR / 剪映，可以帮你剪竞赛答辩视频。',
       s1.id, s2.id, 10, '寒假期间', 'PUBLIC', 'OPEN'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.name = '数据爬取与清洗' AND s2.name = '视频剪辑'
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `description` = VALUES(`description`);

INSERT INTO `zy_demand` (`demand_no`, `owner_sno`, `title`, `description`,
                         `expected_skill_id`, `offer_skill_id`, `expected_hours`,
                         `expected_period`, `visibility`, `status`)
SELECT 'DM20260701004', '2024117421',
       '求助：实验数据统计方法与图表呈现',
       '生物学实验数据需要合适的统计检验与图表呈现。可提供实验设计辅导作为交换。',
       s1.id, s2.id, 5, '平日下午', 'COLLEGE', 'OPEN'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.name = 'ECharts 数据可视化' AND s2.name = '科研实验设计'
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `description` = VALUES(`description`);

-- 用户技能画像示例
-- 为什么需要它：集市匹配度（FR-M4-03）依赖当前用户的技能画像。
-- 若画像为空，"技能供需匹配"因子恒为 0，集市的排序与高匹配高亮就无从体现。
-- 这里按"工程 / 理学 / 人文"三种学科背景各配一份画像，便于演示跨学科匹配。
INSERT INTO `zy_user_skill_profile` (`sno`, `skill_id`, `level`, `intent`, `source`, `score`)
SELECT '2024117420', s.id, 4, 'SKILLED', 'SELF', 0 FROM `zy_skill` s
WHERE s.name IN ('Vue 前端开发', 'JS 动画与交互实现')
UNION ALL
SELECT '2024117420', s.id, 2, 'NEEDED', 'SELF', 0 FROM `zy_skill` s
WHERE s.name IN ('数学建模')
UNION ALL
SELECT '2024117421', s.id, 4, 'SKILLED', 'SELF', 0 FROM `zy_skill` s
WHERE s.name IN ('数学建模', '科研实验设计')
UNION ALL
SELECT '2024117421', s.id, 2, 'NEEDED', 'SELF', 0 FROM `zy_skill` s
WHERE s.name IN ('JS 动画与交互实现', 'ECharts 数据可视化')
UNION ALL
SELECT '2024117422', s.id, 4, 'SKILLED', 'SELF', 0 FROM `zy_skill` s
WHERE s.name IN ('英语口语陪练', '学术论文写作')
UNION ALL
SELECT '2024117422', s.id, 2, 'NEEDED', 'SELF', 0 FROM `zy_skill` s
WHERE s.name IN ('ECharts 数据可视化')
ON DUPLICATE KEY UPDATE `level` = VALUES(`level`), `intent` = VALUES(`intent`);

-- 勋章定义示例
INSERT INTO `zy_badge` (`code`, `name`, `description`, `condition_expr`, `level`)
VALUES ('FIRST_EXCHANGE', '初次驿动', '完成第一次技能交换', 'completed_exchange >= 1', 1),
       ('CROSS_3_COLLEGE', '跨院漫游者', '与 3 个不同学院的同学完成交换', 'distinct_college >= 3', 2),
       ('SKILL_MASTER', '技能驿主', '单技能被 5 人学习并好评', 'skill_learners >= 5 AND avg_score >= 85', 3),
       ('TRUSTED', '信赖之驿', '信用值达到 150', 'credit_score >= 150', 3)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- =============================================================================
--  校验
-- =============================================================================
SELECT '知驿·漫游 数据库初始化完成' AS message,
       (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'zhiyi_manyou') AS table_count,
       (SELECT COUNT(*) FROM `zy_student`)  AS student_rows,
       (SELECT COUNT(*) FROM `zy_skill`)    AS skill_rows,
       (SELECT COUNT(*) FROM `zy_skill_ontology`) AS ontology_rows,
       (SELECT COUNT(*) FROM `zy_demand`)   AS demand_rows,
       (SELECT COUNT(*) FROM `zy_user_skill_profile`) AS profile_rows,
       (SELECT COUNT(*) FROM `zy_collab_event`) AS collab_event_rows;
