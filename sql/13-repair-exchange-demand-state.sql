-- 修复“通过通用状态接口跳过接受邀约”造成的历史状态不一致。
-- 正常修复后的流程会由 respond(accept) 和 completeAfterEvaluation 同步维护这些状态。
-- 可重复执行。

-- 1) 已完成的交换：来源需求正式关闭，避免继续出现在集市。
UPDATE `zy_demand` d
JOIN `zy_exchange_record` e
  ON e.`source_demand_id` = d.`id` AND e.`deleted` = 0 AND e.`status` = 'COMPLETED'
SET d.`status` = 'CLOSED'
WHERE d.`deleted` = 0 AND d.`status` IN ('OPEN', 'MATCHED');

-- 2) 进行中、待互评、争议中：来源需求应为已匹配，但不应继续招募。
UPDATE `zy_demand` d
JOIN `zy_exchange_record` e
  ON e.`source_demand_id` = d.`id` AND e.`deleted` = 0
 AND e.`status` IN ('IN_PROGRESS', 'PENDING_EVAL', 'DISPUTED')
SET d.`status` = 'MATCHED'
WHERE d.`deleted` = 0 AND d.`status` = 'OPEN';

-- 3) 已匹配/已完成/争议的需求上，其他仍待响应的邀约不再有效。
UPDATE `zy_demand_interest` i
JOIN `zy_demand` d ON d.`id` = i.`demand_id` AND d.`deleted` = 0
SET i.`status` = 'REJECTED'
WHERE i.`status` = 'PENDING'
  AND d.`status` IN ('MATCHED', 'CLOSED');

-- 4) 最终把真正关联活跃交换的那一条邀约修复为已接受。
--    必须放在“拒绝其他待响应邀约”之后，避免修复结果被后续批量更新覆盖。
UPDATE `zy_demand_interest` i
JOIN `zy_exchange_record` e ON e.`id` = i.`record_id` AND e.`deleted` = 0
SET i.`status` = 'ACCEPTED'
WHERE e.`status` IN ('IN_PROGRESS', 'PENDING_EVAL', 'COMPLETED', 'DISPUTED');
