-- 修复“通过通用状态接口跳过接受/互评”造成的历史状态不一致。
-- 正常修复后的流程会由 respond(accept) 和 completeAfterEvaluation 同步维护这些状态。
-- 可重复执行。

-- 1) COMPLETED 但评价不足两份，说明历史上绕过了双方互评：退回待互评。
UPDATE `zy_exchange_record` e
LEFT JOIN (
    SELECT `record_id`, COUNT(*) AS eval_count
    FROM `zy_evaluation_grade`
    GROUP BY `record_id`
) g ON g.`record_id` = e.`id`
SET e.`status` = 'PENDING_EVAL',
    e.`finished_at` = NULL,
    e.`pending_eval_at` = COALESCE(e.`pending_eval_at`, NOW())
WHERE e.`deleted` = 0
  AND e.`status` = 'COMPLETED'
  AND COALESCE(g.`eval_count`, 0) < 2;

-- 2) 已完成的交换：来源需求正式关闭，避免继续出现在集市。
UPDATE `zy_demand` d
JOIN `zy_exchange_record` e
  ON e.`source_demand_id` = d.`id` AND e.`deleted` = 0 AND e.`status` = 'COMPLETED'
SET d.`status` = 'CLOSED'
WHERE d.`deleted` = 0 AND d.`status` IN ('OPEN', 'MATCHED');

-- 3) 进行中、待互评、争议中：来源需求应为已匹配，但不应继续招募。
UPDATE `zy_demand` d
JOIN `zy_exchange_record` e
  ON e.`source_demand_id` = d.`id` AND e.`deleted` = 0
 AND e.`status` IN ('IN_PROGRESS', 'PENDING_EVAL', 'DISPUTED')
SET d.`status` = 'MATCHED'
WHERE d.`deleted` = 0 AND d.`status` = 'OPEN';

-- 4) 已匹配/已完成/争议的需求上，其他仍待响应的邀约不再有效。
UPDATE `zy_demand_interest` i
JOIN `zy_demand` d ON d.`id` = i.`demand_id` AND d.`deleted` = 0
SET i.`status` = 'REJECTED'
WHERE i.`status` = 'PENDING'
  AND d.`status` IN ('MATCHED', 'CLOSED');

-- 5) 最终把真正关联活跃交换的那一条邀约修复为已接受。
--    必须放在“拒绝其他待响应邀约”之后，避免修复结果被后续批量更新覆盖。
UPDATE `zy_demand_interest` i
JOIN `zy_exchange_record` e ON e.`id` = i.`record_id` AND e.`deleted` = 0
SET i.`status` = 'ACCEPTED'
WHERE e.`status` IN ('IN_PROGRESS', 'PENDING_EVAL', 'COMPLETED', 'DISPUTED');
