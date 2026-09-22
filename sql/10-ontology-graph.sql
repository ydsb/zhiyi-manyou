-- =============================================================================
--  知驿·漫游 —— 技能知识图谱关系
--
--  本文件由 nlp-service/gen_graph.py 生成，请勿手工修改：
--  改内容请改生成器里的 COMPLEMENT / PREREQUISITE / SYNONYM 三张表，
--  再按生成器文件头的命令重新生成，否则下次生成会覆盖手工改动。
--
--  应用方式：
--      mysql --default-character-set=utf8mb4 -uroot -p zhiyi_manyou \
--            < 10-ontology-graph.sql
--  幂等：可重复执行。已存在的边只刷新 weight/remark，不会重复插入。
--
--  relation_type 语义：
--    COMPLEMENT   互补协作，无向（directed=0）—— 隐性需求挖掘只采信这类边
--    PREREQUISITE 先决条件，有向（directed=1，src 先于 dst）—— 用于学习路径
--    SYNONYM      同义映射，无向 —— 用于消解跨域术语差异
-- =============================================================================

USE `zhiyi_manyou`;

-- 本批 590 条边：COMPLEMENT 423 / PREREQUISITE 150 / SYNONYM 17


-- --------------------------------------------------------------------------
-- COMPLEMENT
-- --------------------------------------------------------------------------

-- 1. UI/UX 设计 (艺术学) ↔ Vue 前端开发 (工学)  [跨门类]
--    做一个可交付的网页界面：工程实现与视觉方案必须同时到位
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '做一个可交付的网页界面：工程实现与视觉方案必须同时到位'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'UI/UX 设计'
  AND s2.`name` = 'Vue 前端开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'UI/UX 设计'
JOIN `zy_skill` s2 ON s2.`name` = 'Vue 前端开发'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '做一个可交付的网页界面：工程实现与视觉方案必须同时到位'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 2. Figma 界面设计与协作 (艺术学) ↔ Vue 前端开发 (工学)  [跨门类]
--    前端按 Figma 稿还原页面，是设计到开发的标准交接链路
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '前端按 Figma 稿还原页面，是设计到开发的标准交接链路'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Figma 界面设计与协作'
  AND s2.`name` = 'Vue 前端开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Figma 界面设计与协作'
JOIN `zy_skill` s2 ON s2.`name` = 'Vue 前端开发'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '前端按 Figma 稿还原页面，是设计到开发的标准交接链路'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 3. Vue 前端开发 (工学) ↔ 交互原型设计 (艺术学)  [跨门类]
--    原型定下交互逻辑后前端才动手实现
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '原型定下交互逻辑后前端才动手实现'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Vue 前端开发'
  AND s2.`name` = '交互原型设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Vue 前端开发'
JOIN `zy_skill` s2 ON s2.`name` = '交互原型设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '原型定下交互逻辑后前端才动手实现'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 4. Axure 原型设计 (工学) ↔ Vue 前端开发 (工学)
--    Axure 产出的可点击原型是前端实现依据
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, 'Axure 产出的可点击原型是前端实现依据'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Axure 原型设计'
  AND s2.`name` = 'Vue 前端开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Axure 原型设计'
JOIN `zy_skill` s2 ON s2.`name` = 'Vue 前端开发'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = 'Axure 产出的可点击原型是前端实现依据'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 5. React 前端开发 (工学) ↔ 设计系统与组件库 (艺术学)  [跨门类]
--    设计系统落地为前端组件库才有工程意义
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '设计系统落地为前端组件库才有工程意义'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'React 前端开发'
  AND s2.`name` = '设计系统与组件库'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'React 前端开发'
JOIN `zy_skill` s2 ON s2.`name` = '设计系统与组件库'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '设计系统落地为前端组件库才有工程意义'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 6. React 前端开发 (工学) ↔ 交互原型设计 (艺术学)  [跨门类]
--    原型驱动开发，避免实现与预期不符
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '原型驱动开发，避免实现与预期不符'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'React 前端开发'
  AND s2.`name` = '交互原型设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'React 前端开发'
JOIN `zy_skill` s2 ON s2.`name` = '交互原型设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '原型驱动开发，避免实现与预期不符'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 7. JS 动画与交互实现 (工学) ↔ 动效设计规范 (艺术学)  [跨门类]
--    动效规范给参数，前端负责让它真的动起来
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '动效规范给参数，前端负责让它真的动起来'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'JS 动画与交互实现'
  AND s2.`name` = '动效设计规范'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'JS 动画与交互实现'
JOIN `zy_skill` s2 ON s2.`name` = '动效设计规范'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '动效规范给参数，前端负责让它真的动起来'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 8. JS 动画与交互实现 (工学) ↔ 界面动效实现 (艺术学)  [跨门类]
--    同一件事的规范侧与实现侧，必须配对
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '同一件事的规范侧与实现侧，必须配对'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'JS 动画与交互实现'
  AND s2.`name` = '界面动效实现'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'JS 动画与交互实现'
JOIN `zy_skill` s2 ON s2.`name` = '界面动效实现'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '同一件事的规范侧与实现侧，必须配对'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 9. Web3D 与 Three.js (工学) ↔ 界面动效实现 (艺术学)  [跨门类]
--    三维网页动效靠 WebGL 落地
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '三维网页动效靠 WebGL 落地'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Web3D 与 Three.js'
  AND s2.`name` = '界面动效实现'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Web3D 与 Three.js'
JOIN `zy_skill` s2 ON s2.`name` = '界面动效实现'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '三维网页动效靠 WebGL 落地'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 10. CSS 样式与响应式布局 (工学) ↔ 版式设计与排版 (艺术学)  [跨门类]
--    排版规则要靠 CSS 落地，缺一方页面就散
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '排版规则要靠 CSS 落地，缺一方页面就散'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'CSS 样式与响应式布局'
  AND s2.`name` = '版式设计与排版'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'CSS 样式与响应式布局'
JOIN `zy_skill` s2 ON s2.`name` = '版式设计与排版'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '排版规则要靠 CSS 落地，缺一方页面就散'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 11. CSS 样式与响应式布局 (工学) ↔ 无障碍与包容性设计 (艺术学)  [跨门类]
--    无障碍要求最终由样式与语义标签兑现
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '无障碍要求最终由样式与语义标签兑现'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'CSS 样式与响应式布局'
  AND s2.`name` = '无障碍与包容性设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'CSS 样式与响应式布局'
JOIN `zy_skill` s2 ON s2.`name` = '无障碍与包容性设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '无障碍要求最终由样式与语义标签兑现'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 12. ECharts 数据可视化 (工学) ↔ 信息图表设计 (艺术学)  [跨门类]
--    数据可视化既要图表库实现也要图形表达设计
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '数据可视化既要图表库实现也要图形表达设计'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'ECharts 数据可视化'
  AND s2.`name` = '信息图表设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'ECharts 数据可视化'
JOIN `zy_skill` s2 ON s2.`name` = '信息图表设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '数据可视化既要图表库实现也要图形表达设计'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 13. ECharts 数据可视化 (工学) ↔ 数据新闻与可视化 (文学)  [跨门类]
--    数据新闻的图表部分依赖可视化库落地
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '数据新闻的图表部分依赖可视化库落地'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'ECharts 数据可视化'
  AND s2.`name` = '数据新闻与可视化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'ECharts 数据可视化'
JOIN `zy_skill` s2 ON s2.`name` = '数据新闻与可视化'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '数据新闻的图表部分依赖可视化库落地'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 14. ECharts 数据可视化 (工学) ↔ 报表自动化与看板 (理学)  [跨门类]
--    看板与报表是可视化能力在业务侧的出口
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '看板与报表是可视化能力在业务侧的出口'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'ECharts 数据可视化'
  AND s2.`name` = '报表自动化与看板'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'ECharts 数据可视化'
JOIN `zy_skill` s2 ON s2.`name` = '报表自动化与看板'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '看板与报表是可视化能力在业务侧的出口'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 15. 信息图表设计 (艺术学) ↔ 数据可视化图表设计 (工学)  [跨门类]
--    图表设计能力与图形设计能力互为表里
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '图表设计能力与图形设计能力互为表里'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '信息图表设计'
  AND s2.`name` = '数据可视化图表设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '信息图表设计'
JOIN `zy_skill` s2 ON s2.`name` = '数据可视化图表设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '图表设计能力与图形设计能力互为表里'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 16. Matplotlib 绘图 (工学) ↔ 数据可视化图表设计 (工学)
--    科研图表大量由 matplotlib 产出
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '科研图表大量由 matplotlib 产出'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Matplotlib 绘图'
  AND s2.`name` = '数据可视化图表设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Matplotlib 绘图'
JOIN `zy_skill` s2 ON s2.`name` = '数据可视化图表设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '科研图表大量由 matplotlib 产出'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 17. Matplotlib 绘图 (工学) ↔ 实验数据处理与作图 (理学)  [跨门类]
--    实验数据出图是科研的固定动作
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '实验数据出图是科研的固定动作'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Matplotlib 绘图'
  AND s2.`name` = '实验数据处理与作图'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Matplotlib 绘图'
JOIN `zy_skill` s2 ON s2.`name` = '实验数据处理与作图'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '实验数据出图是科研的固定动作'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 18. UI/UX 设计 (艺术学) ↔ 小程序开发 (工学)  [跨门类]
--    小程序同样需要界面方案
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '小程序同样需要界面方案'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'UI/UX 设计'
  AND s2.`name` = '小程序开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'UI/UX 设计'
JOIN `zy_skill` s2 ON s2.`name` = '小程序开发'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '小程序同样需要界面方案'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 19. 企业微信客户运营 (工学) ↔ 小程序开发 (工学)
--    小程序是企业微信私域运营的落地载体
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '小程序是企业微信私域运营的落地载体'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '企业微信客户运营'
  AND s2.`name` = '小程序开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '企业微信客户运营'
JOIN `zy_skill` s2 ON s2.`name` = '小程序开发'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '小程序是企业微信私域运营的落地载体'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 20. 交互原型设计 (艺术学) ↔ 移动端 App 开发 (工学)  [跨门类]
--    移动端交互细节多，原型先行
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '移动端交互细节多，原型先行'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '交互原型设计'
  AND s2.`name` = '移动端 App 开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '交互原型设计'
JOIN `zy_skill` s2 ON s2.`name` = '移动端 App 开发'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '移动端交互细节多，原型先行'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 21. Flutter 跨端开发 (工学) ↔ UI/UX 设计 (艺术学)  [跨门类]
--    跨端框架同样要还原设计稿
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '跨端框架同样要还原设计稿'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Flutter 跨端开发'
  AND s2.`name` = 'UI/UX 设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Flutter 跨端开发'
JOIN `zy_skill` s2 ON s2.`name` = 'UI/UX 设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '跨端框架同样要还原设计稿'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 22. Uni-app 跨端开发 (工学) ↔ 小程序开发 (工学)
--    uni-app 的主要用途之一就是一套代码出多端小程序
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'uni-app 的主要用途之一就是一套代码出多端小程序'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Uni-app 跨端开发'
  AND s2.`name` = '小程序开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Uni-app 跨端开发'
JOIN `zy_skill` s2 ON s2.`name` = '小程序开发'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'uni-app 的主要用途之一就是一套代码出多端小程序'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 23. Nginx 配置与反向代理 (工学) ↔ 云计算与服务器部署 (工学)
--    线上部署里反向代理与云主机配置是一套动作
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '线上部署里反向代理与云主机配置是一套动作'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Nginx 配置与反向代理'
  AND s2.`name` = '云计算与服务器部署'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Nginx 配置与反向代理'
JOIN `zy_skill` s2 ON s2.`name` = '云计算与服务器部署'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '线上部署里反向代理与云主机配置是一套动作'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 24. Docker 容器化部署 (工学) ↔ Linux 服务器运维 (工学)
--    容器跑在 Linux 上，运维与容器化互为前提
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '容器跑在 Linux 上，运维与容器化互为前提'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Docker 容器化部署'
  AND s2.`name` = 'Linux 服务器运维'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Docker 容器化部署'
JOIN `zy_skill` s2 ON s2.`name` = 'Linux 服务器运维'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '容器跑在 Linux 上，运维与容器化互为前提'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 25. Docker Compose 编排 (工学) ↔ Docker 容器化部署 (工学)
--    Compose 是容器化的编排层，通常一起用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'Compose 是容器化的编排层，通常一起用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Docker Compose 编排'
  AND s2.`name` = 'Docker 容器化部署'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Docker Compose 编排'
JOIN `zy_skill` s2 ON s2.`name` = 'Docker 容器化部署'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'Compose 是容器化的编排层，通常一起用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 26. Kubernetes 容器编排 (工学) ↔ 微服务架构设计 (工学)
--    微服务的规模化运行依赖容器编排
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '微服务的规模化运行依赖容器编排'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Kubernetes 容器编排'
  AND s2.`name` = '微服务架构设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Kubernetes 容器编排'
JOIN `zy_skill` s2 ON s2.`name` = '微服务架构设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '微服务的规模化运行依赖容器编排'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 27. Redis 缓存应用 (工学) ↔ Spring Boot 应用开发 (工学)
--    业务服务接缓存是性能优化的常规手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '业务服务接缓存是性能优化的常规手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Redis 缓存应用'
  AND s2.`name` = 'Spring Boot 应用开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Redis 缓存应用'
JOIN `zy_skill` s2 ON s2.`name` = 'Spring Boot 应用开发'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '业务服务接缓存是性能优化的常规手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 28. MySQL 数据库设计与优化 (工学) ↔ Spring Boot 应用开发 (工学)
--    服务端开发必然伴随表结构与查询设计
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '服务端开发必然伴随表结构与查询设计'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'MySQL 数据库设计与优化'
  AND s2.`name` = 'Spring Boot 应用开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'MySQL 数据库设计与优化'
JOIN `zy_skill` s2 ON s2.`name` = 'Spring Boot 应用开发'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '服务端开发必然伴随表结构与查询设计'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 29. Java 后端开发 (工学) ↔ MySQL 数据库设计与优化 (工学)
--    后端业务数据落地在关系库
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '后端业务数据落地在关系库'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Java 后端开发'
  AND s2.`name` = 'MySQL 数据库设计与优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Java 后端开发'
JOIN `zy_skill` s2 ON s2.`name` = 'MySQL 数据库设计与优化'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '后端业务数据落地在关系库'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 30. Java 后端开发 (工学) ↔ RESTful 接口设计 (工学)
--    后端对外提供的就是接口契约
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '后端对外提供的就是接口契约'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Java 后端开发'
  AND s2.`name` = 'RESTful 接口设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Java 后端开发'
JOIN `zy_skill` s2 ON s2.`name` = 'RESTful 接口设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '后端对外提供的就是接口契约'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 31. RESTful 接口设计 (工学) ↔ 接口文档与联调 (工学)
--    接口写完就要出文档并跟前端联调
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '接口写完就要出文档并跟前端联调'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'RESTful 接口设计'
  AND s2.`name` = '接口文档与联调'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'RESTful 接口设计'
JOIN `zy_skill` s2 ON s2.`name` = '接口文档与联调'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '接口写完就要出文档并跟前端联调'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 32. 产品需求文档撰写 (工学) ↔ 接口文档与联调 (工学)
--    联调依据是需求文档里定义的业务流
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '联调依据是需求文档里定义的业务流'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '产品需求文档撰写'
  AND s2.`name` = '接口文档与联调'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '产品需求文档撰写'
JOIN `zy_skill` s2 ON s2.`name` = '接口文档与联调'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '联调依据是需求文档里定义的业务流'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 33. Python 后端开发 (工学) ↔ 数据爬取与清洗 (工学)
--    Python 既是服务端也是数据采集的主力工具
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, 'Python 既是服务端也是数据采集的主力工具'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Python 后端开发'
  AND s2.`name` = '数据爬取与清洗'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Python 后端开发'
JOIN `zy_skill` s2 ON s2.`name` = '数据爬取与清洗'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = 'Python 既是服务端也是数据采集的主力工具'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 34. 并发编程与线程安全 (工学) ↔ 消息队列应用 (工学)
--    异步与并发问题通常一起用消息队列解耦
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '异步与并发问题通常一起用消息队列解耦'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '并发编程与线程安全'
  AND s2.`name` = '消息队列应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '并发编程与线程安全'
JOIN `zy_skill` s2 ON s2.`name` = '消息队列应用'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '异步与并发问题通常一起用消息队列解耦'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 35. Elasticsearch 全文检索 (工学) ↔ 推荐系统实现 (工学)
--    检索与推荐常在同一产品里共存
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '检索与推荐常在同一产品里共存'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Elasticsearch 全文检索'
  AND s2.`name` = '推荐系统实现'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Elasticsearch 全文检索'
JOIN `zy_skill` s2 ON s2.`name` = '推荐系统实现'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '检索与推荐常在同一产品里共存'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 36. RAG 检索增强生成 (工学) ↔ 向量数据库应用 (工学)
--    RAG 的检索层就是向量库
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'RAG 的检索层就是向量库'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'RAG 检索增强生成'
  AND s2.`name` = '向量数据库应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'RAG 检索增强生成'
JOIN `zy_skill` s2 ON s2.`name` = '向量数据库应用'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'RAG 的检索层就是向量库'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 37. AI 提示词工程 (工学) ↔ 大模型 API 应用开发 (工学)
--    提示工程最终通过 API 调用落地
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '提示工程最终通过 API 调用落地'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'AI 提示词工程'
  AND s2.`name` = '大模型 API 应用开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'AI 提示词工程'
JOIN `zy_skill` s2 ON s2.`name` = '大模型 API 应用开发'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '提示工程最终通过 API 调用落地'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 38. AI 辅助写作与润色 (工学) ↔ 公众号排版与运营 (工学)
--    图文运营的文案环节已普遍使用 AI 辅助
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '图文运营的文案环节已普遍使用 AI 辅助'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'AI 辅助写作与润色'
  AND s2.`name` = '公众号排版与运营'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'AI 辅助写作与润色'
JOIN `zy_skill` s2 ON s2.`name` = '公众号排版与运营'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '图文运营的文案环节已普遍使用 AI 辅助'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 39. AI 辅助编程 (工学) ↔ 代码重构与整洁代码 (工学)
--    AI 生成代码后需要人工重构与把关
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, 'AI 生成代码后需要人工重构与把关'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'AI 辅助编程'
  AND s2.`name` = '代码重构与整洁代码'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'AI 辅助编程'
JOIN `zy_skill` s2 ON s2.`name` = '代码重构与整洁代码'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = 'AI 生成代码后需要人工重构与把关'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 40. Python 科学计算 (理学) ↔ 数学建模 (理学)
--    建模题最终都要落到数值计算代码
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '建模题最终都要落到数值计算代码'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Python 科学计算'
  AND s2.`name` = '数学建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Python 科学计算'
JOIN `zy_skill` s2 ON s2.`name` = '数学建模'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '建模题最终都要落到数值计算代码'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 41. Python 科学计算 (理学) ↔ Python 统计建模 (理学)
--    科学计算与统计建模共用同一套工具链
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '科学计算与统计建模共用同一套工具链'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Python 科学计算'
  AND s2.`name` = 'Python 统计建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Python 科学计算'
JOIN `zy_skill` s2 ON s2.`name` = 'Python 统计建模'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '科学计算与统计建模共用同一套工具链'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 42. MATLAB 数值计算与仿真 (理学) ↔ 数学建模 (理学)
--    仿真与建模是数模竞赛的两条腿
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '仿真与建模是数模竞赛的两条腿'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'MATLAB 数值计算与仿真'
  AND s2.`name` = '数学建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'MATLAB 数值计算与仿真'
JOIN `zy_skill` s2 ON s2.`name` = '数学建模'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '仿真与建模是数模竞赛的两条腿'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 43. MATLAB 数值计算与仿真 (理学) ↔ 偏微分方程数值解 (理学)
--    数值解法的实现平台通常是 MATLAB
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '数值解法的实现平台通常是 MATLAB'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'MATLAB 数值计算与仿真'
  AND s2.`name` = '偏微分方程数值解'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'MATLAB 数值计算与仿真'
JOIN `zy_skill` s2 ON s2.`name` = '偏微分方程数值解'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '数值解法的实现平台通常是 MATLAB'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 44. MATLAB 工具箱应用 (理学) ↔ 通信原理与信号处理 (工学)  [跨门类]
--    信号处理依赖工具箱函数
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '信号处理依赖工具箱函数'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'MATLAB 工具箱应用'
  AND s2.`name` = '通信原理与信号处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'MATLAB 工具箱应用'
JOIN `zy_skill` s2 ON s2.`name` = '通信原理与信号处理'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '信号处理依赖工具箱函数'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 45. MATLAB 工具箱应用 (理学) ↔ 物理仿真软件应用 (理学)
--    物理仿真常用 MATLAB 实现
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '物理仿真常用 MATLAB 实现'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'MATLAB 工具箱应用'
  AND s2.`name` = '物理仿真软件应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'MATLAB 工具箱应用'
JOIN `zy_skill` s2 ON s2.`name` = '物理仿真软件应用'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '物理仿真常用 MATLAB 实现'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 46. LaTeX 论文排版 (工学) ↔ 数学建模竞赛实战 (理学)  [跨门类]
--    数模最后交的是论文，建模与排版缺一不可
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '数模最后交的是论文，建模与排版缺一不可'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'LaTeX 论文排版'
  AND s2.`name` = '数学建模竞赛实战'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'LaTeX 论文排版'
JOIN `zy_skill` s2 ON s2.`name` = '数学建模竞赛实战'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '数模最后交的是论文，建模与排版缺一不可'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 47. 数学建模竞赛实战 (理学) ↔ 竞赛备赛与团队组织 (管理学)  [跨门类]
--    三人一队的分工与节奏本身就是竞赛能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '三人一队的分工与节奏本身就是竞赛能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数学建模竞赛实战'
  AND s2.`name` = '竞赛备赛与团队组织'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数学建模竞赛实战'
JOIN `zy_skill` s2 ON s2.`name` = '竞赛备赛与团队组织'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '三人一队的分工与节奏本身就是竞赛能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 48. 技术文档写作 (工学) ↔ 数学建模竞赛实战 (理学)  [跨门类]
--    竞赛与项目都需要把方案写清楚
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '竞赛与项目都需要把方案写清楚'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '技术文档写作'
  AND s2.`name` = '数学建模竞赛实战'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '技术文档写作'
JOIN `zy_skill` s2 ON s2.`name` = '数学建模竞赛实战'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '竞赛与项目都需要把方案写清楚'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 49. 数学建模竞赛实战 (理学) ↔ 数据可视化图表设计 (工学)  [跨门类]
--    论文里的图决定评委第一印象
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '论文里的图决定评委第一印象'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数学建模竞赛实战'
  AND s2.`name` = '数据可视化图表设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数学建模竞赛实战'
JOIN `zy_skill` s2 ON s2.`name` = '数据可视化图表设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '论文里的图决定评委第一印象'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 50. 时间序列分析 (理学) ↔ 金融数据分析 (经济学)  [跨门类]
--    金融时序预测是时间序列方法的典型应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '金融时序预测是时间序列方法的典型应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '时间序列分析'
  AND s2.`name` = '金融数据分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '时间序列分析'
JOIN `zy_skill` s2 ON s2.`name` = '金融数据分析'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '金融时序预测是时间序列方法的典型应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 51. 时间序列分析 (理学) ↔ 经济数据获取与清洗 (经济学)  [跨门类]
--    时序建模前置工作是取数与清洗
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '时序建模前置工作是取数与清洗'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '时间序列分析'
  AND s2.`name` = '经济数据获取与清洗'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '时间序列分析'
JOIN `zy_skill` s2 ON s2.`name` = '经济数据获取与清洗'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '时序建模前置工作是取数与清洗'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 52. 时间序列分析 (理学) ↔ 气候统计与诊断 (理学)
--    气候诊断大量使用时序方法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '气候诊断大量使用时序方法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '时间序列分析'
  AND s2.`name` = '气候统计与诊断'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '时间序列分析'
JOIN `zy_skill` s2 ON s2.`name` = '气候统计与诊断'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '气候诊断大量使用时序方法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 53. 统计计算与模拟 (理学) ↔ 随机过程与模拟 (理学)
--    随机过程的主要落地手段就是统计模拟
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '随机过程的主要落地手段就是统计模拟'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '统计计算与模拟'
  AND s2.`name` = '随机过程与模拟'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '统计计算与模拟'
JOIN `zy_skill` s2 ON s2.`name` = '随机过程与模拟'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '随机过程的主要落地手段就是统计模拟'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 54. 金融风险管理 (经济学) ↔ 随机过程与模拟 (理学)  [跨门类]
--    风险度量常用随机过程建模
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '风险度量常用随机过程建模'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '金融风险管理'
  AND s2.`name` = '随机过程与模拟'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '金融风险管理'
JOIN `zy_skill` s2 ON s2.`name` = '随机过程与模拟'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '风险度量常用随机过程建模'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 55. 概率论与数理统计 (理学) ↔ 统计分析软件应用 (理学)
--    统计方法要靠软件算出来
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '统计方法要靠软件算出来'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '概率论与数理统计'
  AND s2.`name` = '统计分析软件应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '概率论与数理统计'
JOIN `zy_skill` s2 ON s2.`name` = '统计分析软件应用'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '统计方法要靠软件算出来'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 56. 卫生统计与spss (医学) ↔ 概率论与数理统计 (理学)  [跨门类]
--    医学统计是统计理论在公卫领域的应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '医学统计是统计理论在公卫领域的应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '卫生统计与spss'
  AND s2.`name` = '概率论与数理统计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '卫生统计与spss'
JOIN `zy_skill` s2 ON s2.`name` = '概率论与数理统计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '医学统计是统计理论在公卫领域的应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 57. 心理测量与量表分析 (理学) ↔ 概率论与数理统计 (理学)
--    量表信效度检验本质是统计问题
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '量表信效度检验本质是统计问题'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '心理测量与量表分析'
  AND s2.`name` = '概率论与数理统计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '心理测量与量表分析'
JOIN `zy_skill` s2 ON s2.`name` = '概率论与数理统计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '量表信效度检验本质是统计问题'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 58. R 语言统计分析 (理学) ↔ 多元统计分析 (理学)
--    多元统计的落地工具主要是 R
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '多元统计的落地工具主要是 R'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'R 语言统计分析'
  AND s2.`name` = '多元统计分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'R 语言统计分析'
JOIN `zy_skill` s2 ON s2.`name` = '多元统计分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '多元统计的落地工具主要是 R'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 59. 回归分析与建模 (理学) ↔ 计量经济学分析 (经济学)  [跨门类]
--    计量经济学的方法主体就是回归
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '计量经济学的方法主体就是回归'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '回归分析与建模'
  AND s2.`name` = '计量经济学分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '回归分析与建模'
JOIN `zy_skill` s2 ON s2.`name` = '计量经济学分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '计量经济学的方法主体就是回归'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 60. 方差分析与实验设计 (理学) ↔ 科研实验设计 (理学)
--    实验设计决定了方差分析能不能用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '实验设计决定了方差分析能不能用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '方差分析与实验设计'
  AND s2.`name` = '科研实验设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '方差分析与实验设计'
JOIN `zy_skill` s2 ON s2.`name` = '科研实验设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '实验设计决定了方差分析能不能用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 61. A/B 测试与实验设计 (工学) ↔ 方差分析与实验设计 (理学)  [跨门类]
--    A/B 测试是企业侧的实验设计
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'A/B 测试是企业侧的实验设计'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'A/B 测试与实验设计'
  AND s2.`name` = '方差分析与实验设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'A/B 测试与实验设计'
JOIN `zy_skill` s2 ON s2.`name` = '方差分析与实验设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'A/B 测试是企业侧的实验设计'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 62. 抽样调查设计 (理学) ↔ 问卷调查与数据编码 (理学)
--    抽样方案与问卷工具必须配套
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '抽样方案与问卷工具必须配套'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '抽样调查设计'
  AND s2.`name` = '问卷调查与数据编码'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '抽样调查设计'
JOIN `zy_skill` s2 ON s2.`name` = '问卷调查与数据编码'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '抽样方案与问卷工具必须配套'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 63. 在线问卷与数据回收 (工学) ↔ 问卷调查与数据编码 (理学)  [跨门类]
--    问卷设计要靠工具发放回收
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '问卷设计要靠工具发放回收'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '在线问卷与数据回收'
  AND s2.`name` = '问卷调查与数据编码'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '在线问卷与数据回收'
JOIN `zy_skill` s2 ON s2.`name` = '问卷调查与数据编码'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '问卷设计要靠工具发放回收'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 64. 机器学习建模 (工学) ↔ 贝叶斯统计方法 (理学)  [跨门类]
--    贝叶斯方法是建模范式之一
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '贝叶斯方法是建模范式之一'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机器学习建模'
  AND s2.`name` = '贝叶斯统计方法'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机器学习建模'
JOIN `zy_skill` s2 ON s2.`name` = '贝叶斯统计方法'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '贝叶斯方法是建模范式之一'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 65. 业务流程优化 (经济学) ↔ 运筹学与最优化 (理学)  [跨门类]
--    流程优化问题最终表述为最优化问题
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '流程优化问题最终表述为最优化问题'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '业务流程优化'
  AND s2.`name` = '运筹学与最优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '业务流程优化'
JOIN `zy_skill` s2 ON s2.`name` = '运筹学与最优化'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '流程优化问题最终表述为最优化问题'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 66. 供应链与物流管理 (经济学) ↔ 运筹学与最优化 (理学)  [跨门类]
--    供应链优化的底座是运筹模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '供应链优化的底座是运筹模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '供应链与物流管理'
  AND s2.`name` = '运筹学与最优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '供应链与物流管理'
JOIN `zy_skill` s2 ON s2.`name` = '运筹学与最优化'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '供应链优化的底座是运筹模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 67. 图论与网络优化 (理学) ↔ 运筹学与最优化 (理学)
--    网络流、最短路是运筹的核心题型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '网络流、最短路是运筹的核心题型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '图论与网络优化'
  AND s2.`name` = '运筹学与最优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '图论与网络优化'
JOIN `zy_skill` s2 ON s2.`name` = '运筹学与最优化'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '网络流、最短路是运筹的核心题型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 68. 数值计算方法 (理学) ↔ 计算物理与数值模拟 (理学)
--    计算物理的算法基础就是数值方法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '计算物理的算法基础就是数值方法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数值计算方法'
  AND s2.`name` = '计算物理与数值模拟'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数值计算方法'
JOIN `zy_skill` s2 ON s2.`name` = '计算物理与数值模拟'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '计算物理的算法基础就是数值方法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 69. 数值计算方法 (理学) ↔ 有限元分析 (工学)  [跨门类]
--    有限元是数值方法在结构工程的应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '有限元是数值方法在结构工程的应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数值计算方法'
  AND s2.`name` = '有限元分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数值计算方法'
JOIN `zy_skill` s2 ON s2.`name` = '有限元分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '有限元是数值方法在结构工程的应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 70. 有限元分析 (工学) ↔ 线性代数与矩阵论 (理学)  [跨门类]
--    结构分析本质是大规模矩阵求解
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '结构分析本质是大规模矩阵求解'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '有限元分析'
  AND s2.`name` = '线性代数与矩阵论'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '有限元分析'
JOIN `zy_skill` s2 ON s2.`name` = '线性代数与矩阵论'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '结构分析本质是大规模矩阵求解'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 71. 大学物理实验 (理学) ↔ 高等数学与微积分 (理学)
--    物理实验的数据处理依赖微积分与误差分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '物理实验的数据处理依赖微积分与误差分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '大学物理实验'
  AND s2.`name` = '高等数学与微积分'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '大学物理实验'
JOIN `zy_skill` s2 ON s2.`name` = '高等数学与微积分'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '物理实验的数据处理依赖微积分与误差分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 72. 大学物理实验 (理学) ↔ 实验数据处理与作图 (理学)
--    物理实验的核心产出是处理后的数据与图
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '物理实验的核心产出是处理后的数据与图'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '大学物理实验'
  AND s2.`name` = '实验数据处理与作图'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '大学物理实验'
JOIN `zy_skill` s2 ON s2.`name` = '实验数据处理与作图'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '物理实验的核心产出是处理后的数据与图'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 73. Origin 数据作图 (理学) ↔ 实验数据处理与作图 (理学)
--    科研作图的主要工具就是 Origin
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '科研作图的主要工具就是 Origin'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Origin 数据作图'
  AND s2.`name` = '实验数据处理与作图'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Origin 数据作图'
JOIN `zy_skill` s2 ON s2.`name` = '实验数据处理与作图'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '科研作图的主要工具就是 Origin'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 74. 数据挖掘与关联规则 (理学) ↔ 数据清洗与特征构造 (理学)
--    挖掘前必须先做特征与清洗
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '挖掘前必须先做特征与清洗'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据挖掘与关联规则'
  AND s2.`name` = '数据清洗与特征构造'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据挖掘与关联规则'
JOIN `zy_skill` s2 ON s2.`name` = '数据清洗与特征构造'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '挖掘前必须先做特征与清洗'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 75. Pandas 数据处理 (工学) ↔ 数据清洗与特征构造 (理学)  [跨门类]
--    清洗与特征工程的主要工具是 pandas
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '清洗与特征工程的主要工具是 pandas'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Pandas 数据处理'
  AND s2.`name` = '数据清洗与特征构造'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Pandas 数据处理'
JOIN `zy_skill` s2 ON s2.`name` = '数据清洗与特征构造'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '清洗与特征工程的主要工具是 pandas'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 76. Jupyter Notebook 数据分析 (工学) ↔ Pandas 数据处理 (工学)
--    数据分析的工作环境就是 Notebook
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '数据分析的工作环境就是 Notebook'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Jupyter Notebook 数据分析'
  AND s2.`name` = 'Pandas 数据处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Jupyter Notebook 数据分析'
JOIN `zy_skill` s2 ON s2.`name` = 'Pandas 数据处理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '数据分析的工作环境就是 Notebook'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 77. NumPy 数值计算 (工学) ↔ Pandas 数据处理 (工学)
--    pandas 建立在 numpy 数组之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'pandas 建立在 numpy 数组之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'NumPy 数值计算'
  AND s2.`name` = 'Pandas 数据处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'NumPy 数值计算'
JOIN `zy_skill` s2 ON s2.`name` = 'Pandas 数据处理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'pandas 建立在 numpy 数组之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 78. 数据标注与质量校验 (工学) ↔ 机器学习建模 (工学)
--    监督学习离不开标注数据与其质量校验
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '监督学习离不开标注数据与其质量校验'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据标注与质量校验'
  AND s2.`name` = '机器学习建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据标注与质量校验'
JOIN `zy_skill` s2 ON s2.`name` = '机器学习建模'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '监督学习离不开标注数据与其质量校验'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 79. 机器学习建模 (工学) ↔ 模型评估与调参 (工学)
--    模型效果七成靠评估与调参
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '模型效果七成靠评估与调参'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机器学习建模'
  AND s2.`name` = '模型评估与调参'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机器学习建模'
JOIN `zy_skill` s2 ON s2.`name` = '模型评估与调参'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '模型效果七成靠评估与调参'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 80. 深度学习入门 (工学) ↔ 计算机视觉应用 (工学)
--    视觉任务的入门载体就是深度模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '视觉任务的入门载体就是深度模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '深度学习入门'
  AND s2.`name` = '计算机视觉应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '深度学习入门'
JOIN `zy_skill` s2 ON s2.`name` = '计算机视觉应用'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '视觉任务的入门载体就是深度模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 81. 深度学习入门 (工学) ↔ 自然语言处理 (工学)
--    NLP 主流方案同样是深度模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'NLP 主流方案同样是深度模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '深度学习入门'
  AND s2.`name` = '自然语言处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '深度学习入门'
JOIN `zy_skill` s2 ON s2.`name` = '自然语言处理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'NLP 主流方案同样是深度模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 82. 知识图谱与图数据库 (工学) ↔ 自然语言处理 (工学)
--    图谱构建的实体抽取环节依赖 NLP
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '图谱构建的实体抽取环节依赖 NLP'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '知识图谱与图数据库'
  AND s2.`name` = '自然语言处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '知识图谱与图数据库'
JOIN `zy_skill` s2 ON s2.`name` = '自然语言处理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '图谱构建的实体抽取环节依赖 NLP'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 83. 信息组织与元数据 (管理学) ↔ 知识图谱与图数据库 (工学)  [跨门类]
--    图谱需要元数据规范来定义实体与关系
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '图谱需要元数据规范来定义实体与关系'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '信息组织与元数据'
  AND s2.`name` = '知识图谱与图数据库'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '信息组织与元数据'
JOIN `zy_skill` s2 ON s2.`name` = '知识图谱与图数据库'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '图谱需要元数据规范来定义实体与关系'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 84. 自然语言处理 (工学) ↔ 舆情分析与监测 (文学)  [跨门类]
--    舆情监测的自动化部分靠 NLP
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '舆情监测的自动化部分靠 NLP'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '自然语言处理'
  AND s2.`name` = '舆情分析与监测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '自然语言处理'
JOIN `zy_skill` s2 ON s2.`name` = '舆情分析与监测'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '舆情监测的自动化部分靠 NLP'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 85. 语音识别与合成 (工学) ↔ 音频处理 Audition (艺术学)  [跨门类]
--    语音处理成果常要在音频工具里验收
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '语音处理成果常要在音频工具里验收'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '语音识别与合成'
  AND s2.`name` = '音频处理 Audition'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '语音识别与合成'
JOIN `zy_skill` s2 ON s2.`name` = '音频处理 Audition'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '语音处理成果常要在音频工具里验收'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 86. AI 绘画与图像生成 (工学) ↔ 多模态模型应用 (工学)
--    图像生成是多模态模型的典型应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '图像生成是多模态模型的典型应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'AI 绘画与图像生成'
  AND s2.`name` = '多模态模型应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'AI 绘画与图像生成'
JOIN `zy_skill` s2 ON s2.`name` = '多模态模型应用'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '图像生成是多模态模型的典型应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 87. 模型微调与训练 (工学) ↔ 深度学习入门 (工学)
--    微调建立在深度模型理解之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '微调建立在深度模型理解之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '模型微调与训练'
  AND s2.`name` = '深度学习入门'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '模型微调与训练'
JOIN `zy_skill` s2 ON s2.`name` = '深度学习入门'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '微调建立在深度模型理解之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 88. 低代码平台搭建 (工学) ↔ 智能体与工作流编排 (工学)
--    智能体编排与低代码都在做流程自动化
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '智能体编排与低代码都在做流程自动化'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '低代码平台搭建'
  AND s2.`name` = '智能体与工作流编排'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '低代码平台搭建'
JOIN `zy_skill` s2 ON s2.`name` = '智能体与工作流编排'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '智能体编排与低代码都在做流程自动化'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 89. AI 产品设计与评估 (工学) ↔ 数据标注 (工学)
--    标注质量直接决定 AI 产品的可用性
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '标注质量直接决定 AI 产品的可用性'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'AI 产品设计与评估'
  AND s2.`name` = '数据标注'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'AI 产品设计与评估'
JOIN `zy_skill` s2 ON s2.`name` = '数据标注'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '标注质量直接决定 AI 产品的可用性'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 90. 云计算与服务器部署 (工学) ↔ 服务器自动化运维 (工学)
--    云上规模化运维必须自动化
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '云上规模化运维必须自动化'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '云计算与服务器部署'
  AND s2.`name` = '服务器自动化运维'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '云计算与服务器部署'
JOIN `zy_skill` s2 ON s2.`name` = '服务器自动化运维'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '云上规模化运维必须自动化'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 91. 渗透测试与漏洞挖掘 (工学) ↔ 网络安全基础 (工学)
--    攻防两端必须一起学才成立
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '攻防两端必须一起学才成立'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '渗透测试与漏洞挖掘'
  AND s2.`name` = '网络安全基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '渗透测试与漏洞挖掘'
JOIN `zy_skill` s2 ON s2.`name` = '网络安全基础'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '攻防两端必须一起学才成立'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 92. 密码学应用 (工学) ↔ 网络安全基础 (工学)
--    安全防护的底座是密码学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '安全防护的底座是密码学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '密码学应用'
  AND s2.`name` = '网络安全基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '密码学应用'
JOIN `zy_skill` s2 ON s2.`name` = '网络安全基础'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '安全防护的底座是密码学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 93. 密码学应用 (工学) ↔ 数论与密码数学 (理学)  [跨门类]
--    公钥体系建立在数论难题上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '公钥体系建立在数论难题上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '密码学应用'
  AND s2.`name` = '数论与密码数学'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '密码学应用'
JOIN `zy_skill` s2 ON s2.`name` = '数论与密码数学'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '公钥体系建立在数论难题上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 94. Web 安全与防护 (工学) ↔ 渗透测试与漏洞挖掘 (工学)
--    漏洞挖掘与防护加固是同一能力的两面
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '漏洞挖掘与防护加固是同一能力的两面'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Web 安全与防护'
  AND s2.`name` = '渗透测试与漏洞挖掘'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Web 安全与防护'
JOIN `zy_skill` s2 ON s2.`name` = '渗透测试与漏洞挖掘'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '漏洞挖掘与防护加固是同一能力的两面'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 95. 数据加密与脱敏 (工学) ↔ 数据合规与个人信息保护 (法学)  [跨门类]
--    脱敏是数据合规的技术兑现手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '脱敏是数据合规的技术兑现手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据加密与脱敏'
  AND s2.`name` = '数据合规与个人信息保护'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据加密与脱敏'
JOIN `zy_skill` s2 ON s2.`name` = '数据合规与个人信息保护'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '脱敏是数据合规的技术兑现手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 96. 数字取证与应急响应 (工学) ↔ 日志分析与异常定位 (工学)
--    取证的核心材料就是日志
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '取证的核心材料就是日志'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数字取证与应急响应'
  AND s2.`name` = '日志分析与异常定位'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数字取证与应急响应'
JOIN `zy_skill` s2 ON s2.`name` = '日志分析与异常定位'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '取证的核心材料就是日志'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 97. 日志采集与监控告警 (工学) ↔ 服务器自动化运维 (工学)
--    可观测性是自动化运维的前提
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '可观测性是自动化运维的前提'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '日志采集与监控告警'
  AND s2.`name` = '服务器自动化运维'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '日志采集与监控告警'
JOIN `zy_skill` s2 ON s2.`name` = '服务器自动化运维'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '可观测性是自动化运维的前提'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 98. JVM 调优 (工学) ↔ 性能压测与调优 (工学)
--    压测定位到 JVM 层就要做调优
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '压测定位到 JVM 层就要做调优'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'JVM 调优'
  AND s2.`name` = '性能压测与调优'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'JVM 调优'
JOIN `zy_skill` s2 ON s2.`name` = '性能压测与调优'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '压测定位到 JVM 层就要做调优'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 99. 分库分表与读写分离 (工学) ↔ 数据库索引与慢查询优化 (工学)
--    索引优化不够时才上分库分表
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '索引优化不够时才上分库分表'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '分库分表与读写分离'
  AND s2.`name` = '数据库索引与慢查询优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '分库分表与读写分离'
JOIN `zy_skill` s2 ON s2.`name` = '数据库索引与慢查询优化'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '索引优化不够时才上分库分表'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 100. 持续集成与持续部署 (工学) ↔ 灰度发布与回滚 (工学)
--    灰度是 CD 流程里的发布策略
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '灰度是 CD 流程里的发布策略'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '持续集成与持续部署'
  AND s2.`name` = '灰度发布与回滚'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '持续集成与持续部署'
JOIN `zy_skill` s2 ON s2.`name` = '灰度发布与回滚'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '灰度是 CD 流程里的发布策略'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 101. 自动化测试框架 (工学) ↔ 软件测试与质量保障 (工学)
--    自动化测试是质量保障的执行手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '自动化测试是质量保障的执行手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '自动化测试框架'
  AND s2.`name` = '软件测试与质量保障'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '自动化测试框架'
JOIN `zy_skill` s2 ON s2.`name` = '软件测试与质量保障'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '自动化测试是质量保障的执行手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 102. 代码评审与规范落地 (工学) ↔ 软件测试与质量保障 (工学)
--    评审与测试共同守住质量门禁
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '评审与测试共同守住质量门禁'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '代码评审与规范落地'
  AND s2.`name` = '软件测试与质量保障'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '代码评审与规范落地'
JOIN `zy_skill` s2 ON s2.`name` = '软件测试与质量保障'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '评审与测试共同守住质量门禁'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 103. 代码评审与规范落地 (工学) ↔ 静态代码分析与质量门禁 (工学)
--    静态扫描是评审的自动化补充
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '静态扫描是评审的自动化补充'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '代码评审与规范落地'
  AND s2.`name` = '静态代码分析与质量门禁'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '代码评审与规范落地'
JOIN `zy_skill` s2 ON s2.`name` = '静态代码分析与质量门禁'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '静态扫描是评审的自动化补充'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 104. A/B 测试与实验设计 (工学) ↔ 埋点方案与数据采集 (工学)
--    没有埋点就没有可分析的实验数据
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '没有埋点就没有可分析的实验数据'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'A/B 测试与实验设计'
  AND s2.`name` = '埋点方案与数据采集'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'A/B 测试与实验设计'
JOIN `zy_skill` s2 ON s2.`name` = '埋点方案与数据采集'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '没有埋点就没有可分析的实验数据'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 105. 埋点方案与数据采集 (工学) ↔ 数据可视化图表设计 (工学)
--    埋点数据最终以看板形式被人消费
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '埋点数据最终以看板形式被人消费'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '埋点方案与数据采集'
  AND s2.`name` = '数据可视化图表设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '埋点方案与数据采集'
JOIN `zy_skill` s2 ON s2.`name` = '数据可视化图表设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '埋点数据最终以看板形式被人消费'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 106. 传感器数据采集 (工学) ↔ 单片机与嵌入式开发 (工学)
--    嵌入式系统必须有传感器输入
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '嵌入式系统必须有传感器输入'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '传感器数据采集'
  AND s2.`name` = '单片机与嵌入式开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '传感器数据采集'
JOIN `zy_skill` s2 ON s2.`name` = '单片机与嵌入式开发'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '嵌入式系统必须有传感器输入'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 107. 单片机与嵌入式开发 (工学) ↔ 电路原理与仿真 (工学)
--    硬件功能要先在电路层面验证
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '硬件功能要先在电路层面验证'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '单片机与嵌入式开发'
  AND s2.`name` = '电路原理与仿真'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '单片机与嵌入式开发'
JOIN `zy_skill` s2 ON s2.`name` = '电路原理与仿真'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '硬件功能要先在电路层面验证'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 108. 传感器数据采集 (工学) ↔ 信号采集与滤波 (工学)
--    采集之后必须做滤波才可用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '采集之后必须做滤波才可用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '传感器数据采集'
  AND s2.`name` = '信号采集与滤波'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '传感器数据采集'
JOIN `zy_skill` s2 ON s2.`name` = '信号采集与滤波'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '采集之后必须做滤波才可用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 109. RTOS 实时系统 (工学) ↔ 嵌入式 C 编程 (工学)
--    实时系统编程建立在 C 语言能力上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '实时系统编程建立在 C 语言能力上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'RTOS 实时系统'
  AND s2.`name` = '嵌入式 C 编程'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'RTOS 实时系统'
JOIN `zy_skill` s2 ON s2.`name` = '嵌入式 C 编程'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '实时系统编程建立在 C 语言能力上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 110. FPGA 与数字逻辑 (工学) ↔ 数字电路设计 (工学)
--    FPGA 是数字逻辑的实现载体
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'FPGA 是数字逻辑的实现载体'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'FPGA 与数字逻辑'
  AND s2.`name` = '数字电路设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'FPGA 与数字逻辑'
JOIN `zy_skill` s2 ON s2.`name` = '数字电路设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'FPGA 是数字逻辑的实现载体'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 111. PCB 设计与制板 (工学) ↔ 电路原理与仿真 (工学)
--    先仿真验证再画板打样
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '先仿真验证再画板打样'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'PCB 设计与制板'
  AND s2.`name` = '电路原理与仿真'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'PCB 设计与制板'
JOIN `zy_skill` s2 ON s2.`name` = '电路原理与仿真'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '先仿真验证再画板打样'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 112. PCB 信号完整性 (工学) ↔ PCB 设计与制板 (工学)
--    高速板设计必须考虑信号完整性
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '高速板设计必须考虑信号完整性'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'PCB 信号完整性'
  AND s2.`name` = 'PCB 设计与制板'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'PCB 信号完整性'
JOIN `zy_skill` s2 ON s2.`name` = 'PCB 设计与制板'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '高速板设计必须考虑信号完整性'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 113. 电子焊接与装配 (工学) ↔ 示波器与仪器使用 (工学)
--    调试与装配是硬件打样的连续动作
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '调试与装配是硬件打样的连续动作'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '电子焊接与装配'
  AND s2.`name` = '示波器与仪器使用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '电子焊接与装配'
JOIN `zy_skill` s2 ON s2.`name` = '示波器与仪器使用'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '调试与装配是硬件打样的连续动作'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 114. 机器人控制与编程 (工学) ↔ 机电一体化系统 (工学)
--    机器人控制是机电一体化的典型场景
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '机器人控制是机电一体化的典型场景'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机器人控制与编程'
  AND s2.`name` = '机电一体化系统'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机器人控制与编程'
JOIN `zy_skill` s2 ON s2.`name` = '机电一体化系统'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '机器人控制是机电一体化的典型场景'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 115. 工业机器人编程 (工学) ↔ 机器人控制与编程 (工学)
--    工业机器人与通用机器人控制技术相通
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '工业机器人与通用机器人控制技术相通'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '工业机器人编程'
  AND s2.`name` = '机器人控制与编程'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '工业机器人编程'
JOIN `zy_skill` s2 ON s2.`name` = '机器人控制与编程'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '工业机器人与通用机器人控制技术相通'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 116. 无人机调试与飞控 (工学) ↔ 飞行动力学与仿真 (工学)
--    飞控参数要依据动力学特性调
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '飞控参数要依据动力学特性调'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '无人机调试与飞控'
  AND s2.`name` = '飞行动力学与仿真'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '无人机调试与飞控'
JOIN `zy_skill` s2 ON s2.`name` = '飞行动力学与仿真'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '飞控参数要依据动力学特性调'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 117. 无人机航测 (工学) ↔ 无人机调试与飞控 (工学)
--    航测作业依赖飞行平台调试能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '航测作业依赖飞行平台调试能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '无人机航测'
  AND s2.`name` = '无人机调试与飞控'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '无人机航测'
JOIN `zy_skill` s2 ON s2.`name` = '无人机调试与飞控'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '航测作业依赖飞行平台调试能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 118. SolidWorks 三维建模 (工学) ↔ 机械制图与公差配合 (工学)
--    二维制图与三维建模是机械设计的标配工具链
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '二维制图与三维建模是机械设计的标配工具链'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'SolidWorks 三维建模'
  AND s2.`name` = '机械制图与公差配合'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'SolidWorks 三维建模'
JOIN `zy_skill` s2 ON s2.`name` = '机械制图与公差配合'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '二维制图与三维建模是机械设计的标配工具链'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 119. SolidWorks 三维建模 (工学) ↔ 有限元分析 (工学)
--    建模之后就要做强度校核
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '建模之后就要做强度校核'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'SolidWorks 三维建模'
  AND s2.`name` = '有限元分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'SolidWorks 三维建模'
JOIN `zy_skill` s2 ON s2.`name` = '有限元分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '建模之后就要做强度校核'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 120. 机械原理与机构设计 (工学) ↔ 机械振动与噪声控制 (工学)
--    机构设计必须评估振动与噪声
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '机构设计必须评估振动与噪声'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机械原理与机构设计'
  AND s2.`name` = '机械振动与噪声控制'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机械原理与机构设计'
JOIN `zy_skill` s2 ON s2.`name` = '机械振动与噪声控制'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '机构设计必须评估振动与噪声'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 121. 数控加工与编程 (工学) ↔ 机械制造工艺 (工学)
--    加工实现依赖工艺方案
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '加工实现依赖工艺方案'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数控加工与编程'
  AND s2.`name` = '机械制造工艺'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数控加工与编程'
JOIN `zy_skill` s2 ON s2.`name` = '机械制造工艺'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '加工实现依赖工艺方案'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 122. 材料制备与合成 (工学) ↔ 逆向工程与3D打印 (工学)
--    打印件性能取决于材料选择
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '打印件性能取决于材料选择'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '材料制备与合成'
  AND s2.`name` = '逆向工程与3D打印'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '材料制备与合成'
JOIN `zy_skill` s2 ON s2.`name` = '逆向工程与3D打印'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '打印件性能取决于材料选择'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 123. 工程材料与选材 (工学) ↔ 机械产品结构设计 (工学)
--    结构设计必须结合材料选型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '结构设计必须结合材料选型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '工程材料与选材'
  AND s2.`name` = '机械产品结构设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '工程材料与选材'
JOIN `zy_skill` s2 ON s2.`name` = '机械产品结构设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '结构设计必须结合材料选型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 124. 数控加工与编程 (工学) ↔ 机械产品结构设计 (工学)
--    可加工性是结构设计必须考虑的约束
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '可加工性是结构设计必须考虑的约束'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数控加工与编程'
  AND s2.`name` = '机械产品结构设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数控加工与编程'
JOIN `zy_skill` s2 ON s2.`name` = '机械产品结构设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '可加工性是结构设计必须考虑的约束'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 125. 机械制图与公差配合 (工学) ↔ 精密测量与误差分析 (工学)
--    图纸标注要靠测量来验证
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '图纸标注要靠测量来验证'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机械制图与公差配合'
  AND s2.`name` = '精密测量与误差分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机械制图与公差配合'
JOIN `zy_skill` s2 ON s2.`name` = '精密测量与误差分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '图纸标注要靠测量来验证'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 126. SketchUp 建筑建模 (工学) ↔ 建筑方案设计与表达 (工学)
--    体块模型是建筑方案推敲的基本手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '体块模型是建筑方案推敲的基本手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'SketchUp 建筑建模'
  AND s2.`name` = '建筑方案设计与表达'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'SketchUp 建筑建模'
JOIN `zy_skill` s2 ON s2.`name` = '建筑方案设计与表达'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '体块模型是建筑方案推敲的基本手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 127. 建筑方案设计与表达 (工学) ↔ 建筑设计表现图 (工学)
--    方案要出表现图才说得清
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '方案要出表现图才说得清'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '建筑方案设计与表达'
  AND s2.`name` = '建筑设计表现图'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '建筑方案设计与表达'
JOIN `zy_skill` s2 ON s2.`name` = '建筑设计表现图'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '方案要出表现图才说得清'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 128. Lumion 建筑渲染 (艺术学) ↔ SketchUp 建筑建模 (工学)  [跨门类]
--    建筑方案表现的标准组合
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '建筑方案表现的标准组合'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Lumion 建筑渲染'
  AND s2.`name` = 'SketchUp 建筑建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Lumion 建筑渲染'
JOIN `zy_skill` s2 ON s2.`name` = 'SketchUp 建筑建模'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '建筑方案表现的标准组合'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 129. CAD 工程制图 (工学) ↔ Revit BIM 建模 (工学)
--    BIM 建模建立在制图与识图能力上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'BIM 建模建立在制图与识图能力上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'CAD 工程制图'
  AND s2.`name` = 'Revit BIM 建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'CAD 工程制图'
JOIN `zy_skill` s2 ON s2.`name` = 'Revit BIM 建模'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'BIM 建模建立在制图与识图能力上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 130. BIM 施工模拟 (工学) ↔ Revit BIM 建模 (工学)
--    施工模拟直接跑在 BIM 模型上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '施工模拟直接跑在 BIM 模型上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'BIM 施工模拟'
  AND s2.`name` = 'Revit BIM 建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'BIM 施工模拟'
JOIN `zy_skill` s2 ON s2.`name` = 'Revit BIM 建模'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '施工模拟直接跑在 BIM 模型上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 131. Revit BIM 建模 (工学) ↔ 项目管理与进度把控 (工学)
--    BIM 价值之一就是施工协同与进度管理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, 'BIM 价值之一就是施工协同与进度管理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Revit BIM 建模'
  AND s2.`name` = '项目管理与进度把控'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Revit BIM 建模'
JOIN `zy_skill` s2 ON s2.`name` = '项目管理与进度把控'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = 'BIM 价值之一就是施工协同与进度管理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 132. 建筑物理与环境模拟 (工学) ↔ 绿色建筑与节能 (工学)
--    节能设计依据是建筑物理模拟结果
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '节能设计依据是建筑物理模拟结果'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '建筑物理与环境模拟'
  AND s2.`name` = '绿色建筑与节能'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '建筑物理与环境模拟'
JOIN `zy_skill` s2 ON s2.`name` = '绿色建筑与节能'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '节能设计依据是建筑物理模拟结果'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 133. 建筑物理与环境模拟 (工学) ↔ 暖通空调设计 (工学)
--    暖通负荷计算就是建筑物理的一部分
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '暖通负荷计算就是建筑物理的一部分'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '建筑物理与环境模拟'
  AND s2.`name` = '暖通空调设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '建筑物理与环境模拟'
JOIN `zy_skill` s2 ON s2.`name` = '暖通空调设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '暖通负荷计算就是建筑物理的一部分'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 134. PKPM 结构设计 (工学) ↔ 结构力学与受力分析 (工学)
--    结构设计要靠力学分析与软件复核
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '结构设计要靠力学分析与软件复核'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'PKPM 结构设计'
  AND s2.`name` = '结构力学与受力分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'PKPM 结构设计'
JOIN `zy_skill` s2 ON s2.`name` = '结构力学与受力分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '结构设计要靠力学分析与软件复核'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 135. 混凝土结构设计 (工学) ↔ 结构力学与受力分析 (工学)
--    混凝土构件设计建立在受力分析上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '混凝土构件设计建立在受力分析上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '混凝土结构设计'
  AND s2.`name` = '结构力学与受力分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '混凝土结构设计'
JOIN `zy_skill` s2 ON s2.`name` = '结构力学与受力分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '混凝土构件设计建立在受力分析上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 136. 结构力学与受力分析 (工学) ↔ 钢结构设计与节点 (工学)
--    节点设计必须做受力验算
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '节点设计必须做受力验算'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '结构力学与受力分析'
  AND s2.`name` = '钢结构设计与节点'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '结构力学与受力分析'
JOIN `zy_skill` s2 ON s2.`name` = '钢结构设计与节点'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '节点设计必须做受力验算'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 137. 土力学与基础工程 (工学) ↔ 岩土与地基处理 (工学)
--    地基处理方案依据土力学计算
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '地基处理方案依据土力学计算'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '土力学与基础工程'
  AND s2.`name` = '岩土与地基处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '土力学与基础工程'
JOIN `zy_skill` s2 ON s2.`name` = '岩土与地基处理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '地基处理方案依据土力学计算'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 138. 大地测量与GPS (工学) ↔ 工程测量与放线 (工学)
--    施工放线使用测量仪器与方法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '施工放线使用测量仪器与方法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '大地测量与GPS'
  AND s2.`name` = '工程测量与放线'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '大地测量与GPS'
JOIN `zy_skill` s2 ON s2.`name` = '工程测量与放线'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '施工放线使用测量仪器与方法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 139. 大地测量与GPS (工学) ↔ 摄影测量与三维重建 (工学)
--    测量与摄影测量同属测绘技术体系
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '测量与摄影测量同属测绘技术体系'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '大地测量与GPS'
  AND s2.`name` = '摄影测量与三维重建'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '大地测量与GPS'
JOIN `zy_skill` s2 ON s2.`name` = '摄影测量与三维重建'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '测量与摄影测量同属测绘技术体系'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 140. GIS 二次开发 (工学) ↔ 摄影测量与三维重建 (工学)
--    三维重建成果常进入 GIS 平台管理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '三维重建成果常进入 GIS 平台管理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'GIS 二次开发'
  AND s2.`name` = '摄影测量与三维重建'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'GIS 二次开发'
JOIN `zy_skill` s2 ON s2.`name` = '摄影测量与三维重建'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '三维重建成果常进入 GIS 平台管理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 141. 摄影测量与三维重建 (工学) ↔ 无人机航测 (工学)
--    无人机航测的产物就是三维重建成果
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '无人机航测的产物就是三维重建成果'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '摄影测量与三维重建'
  AND s2.`name` = '无人机航测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '摄影测量与三维重建'
JOIN `zy_skill` s2 ON s2.`name` = '无人机航测'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '无人机航测的产物就是三维重建成果'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 142. GIS 二次开发 (工学) ↔ 空间数据格式与转换 (理学)  [跨门类]
--    数据格式处理是 GIS 开发的基础环节
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '数据格式处理是 GIS 开发的基础环节'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'GIS 二次开发'
  AND s2.`name` = '空间数据格式与转换'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'GIS 二次开发'
JOIN `zy_skill` s2 ON s2.`name` = '空间数据格式与转换'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '数据格式处理是 GIS 开发的基础环节'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 143. GIS 空间分析 (理学) ↔ 地理信息系统建库 (理学)
--    空间分析的前提是有可用的空间数据库
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '空间分析的前提是有可用的空间数据库'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'GIS 空间分析'
  AND s2.`name` = '地理信息系统建库'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'GIS 空间分析'
JOIN `zy_skill` s2 ON s2.`name` = '地理信息系统建库'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '空间分析的前提是有可用的空间数据库'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 144. GIS 空间分析 (理学) ↔ 城市规划与场地分析 (工学)  [跨门类]
--    规划分析的核心工具就是空间分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '规划分析的核心工具就是空间分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'GIS 空间分析'
  AND s2.`name` = '城市规划与场地分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'GIS 空间分析'
JOIN `zy_skill` s2 ON s2.`name` = '城市规划与场地分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '规划分析的核心工具就是空间分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 145. 城市地理与空间结构 (理学) ↔ 城市规划与场地分析 (工学)  [跨门类]
--    城市空间研究直接服务规划分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '城市空间研究直接服务规划分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '城市地理与空间结构'
  AND s2.`name` = '城市规划与场地分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '城市地理与空间结构'
JOIN `zy_skill` s2 ON s2.`name` = '城市规划与场地分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '城市空间研究直接服务规划分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 146. 生态调查与采样 (理学) ↔ 遥感影像解译 (理学)
--    生态调查常用遥感做面状信息提取
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '生态调查常用遥感做面状信息提取'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '生态调查与采样'
  AND s2.`name` = '遥感影像解译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '生态调查与采样'
JOIN `zy_skill` s2 ON s2.`name` = '遥感影像解译'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '生态调查常用遥感做面状信息提取'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 147. 自然灾害风险评估 (理学) ↔ 遥感影像解译 (理学)
--    灾害风险评估大量依赖遥感解译结果
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '灾害风险评估大量依赖遥感解译结果'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '自然灾害风险评估'
  AND s2.`name` = '遥感影像解译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '自然灾害风险评估'
JOIN `zy_skill` s2 ON s2.`name` = '遥感影像解译'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '灾害风险评估大量依赖遥感解译结果'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 148. 水质检测与分析 (工学) ↔ 污水处理工艺设计 (工学)
--    工艺效果必须靠水质检测验证
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '工艺效果必须靠水质检测验证'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '水质检测与分析'
  AND s2.`name` = '污水处理工艺设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '水质检测与分析'
JOIN `zy_skill` s2 ON s2.`name` = '污水处理工艺设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '工艺效果必须靠水质检测验证'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 149. 分析化学与滴定 (理学) ↔ 水质检测与分析 (工学)  [跨门类]
--    水质检测方法来自分析化学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '水质检测方法来自分析化学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '分析化学与滴定'
  AND s2.`name` = '水质检测与分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '分析化学与滴定'
JOIN `zy_skill` s2 ON s2.`name` = '水质检测与分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '水质检测方法来自分析化学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 150. 大气污染监测 (工学) ↔ 大气环境与污染扩散 (理学)  [跨门类]
--    监测数据用于校准扩散模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '监测数据用于校准扩散模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '大气污染监测'
  AND s2.`name` = '大气环境与污染扩散'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '大气污染监测'
JOIN `zy_skill` s2 ON s2.`name` = '大气环境与污染扩散'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '监测数据用于校准扩散模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 151. 碳排放核算 (工学) ↔ 绿色建筑与节能 (工学)
--    建筑节能是碳核算的重要科目
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '建筑节能是碳核算的重要科目'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '碳排放核算'
  AND s2.`name` = '绿色建筑与节能'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '碳排放核算'
JOIN `zy_skill` s2 ON s2.`name` = '绿色建筑与节能'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '建筑节能是碳核算的重要科目'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 152. 环境影响评价 (工学) ↔ 环境规划与管理 (工学)
--    环评是环境管理的制度工具
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '环评是环境管理的制度工具'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '环境影响评价'
  AND s2.`name` = '环境规划与管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '环境影响评价'
JOIN `zy_skill` s2 ON s2.`name` = '环境规划与管理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '环评是环境管理的制度工具'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 153. 化学信息与结构解析 (理学) ↔ 有机化学合成 (理学)
--    合成产物必须靠结构解析确认
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '合成产物必须靠结构解析确认'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '化学信息与结构解析'
  AND s2.`name` = '有机化学合成'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '化学信息与结构解析'
JOIN `zy_skill` s2 ON s2.`name` = '有机化学合成'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '合成产物必须靠结构解析确认'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 154. ChemDraw 结构绘制 (理学) ↔ 化学信息与结构解析 (理学)
--    结构解析成果以 ChemDraw 图呈现
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '结构解析成果以 ChemDraw 图呈现'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'ChemDraw 结构绘制'
  AND s2.`name` = '化学信息与结构解析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'ChemDraw 结构绘制'
JOIN `zy_skill` s2 ON s2.`name` = '化学信息与结构解析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '结构解析成果以 ChemDraw 图呈现'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 155. 仪器分析与检测 (工学) ↔ 药物分析与检测 (医学)  [跨门类]
--    药检的核心手段就是仪器分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '药检的核心手段就是仪器分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '仪器分析与检测'
  AND s2.`name` = '药物分析与检测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '仪器分析与检测'
JOIN `zy_skill` s2 ON s2.`name` = '药物分析与检测'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '药检的核心手段就是仪器分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 156. 材料失效分析 (工学) ↔ 材料表征与测试 (工学)
--    表征数据用来解释失效机制
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '表征数据用来解释失效机制'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '材料失效分析'
  AND s2.`name` = '材料表征与测试'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '材料失效分析'
JOIN `zy_skill` s2 ON s2.`name` = '材料表征与测试'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '表征数据用来解释失效机制'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 157. 无损检测技术 (工学) ↔ 材料表征与测试 (工学)
--    无损检测是表征手段在工程现场的应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '无损检测是表征手段在工程现场的应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '无损检测技术'
  AND s2.`name` = '材料表征与测试'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '无损检测技术'
JOIN `zy_skill` s2 ON s2.`name` = '材料表征与测试'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '无损检测是表征手段在工程现场的应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 158. 材料制备与合成 (工学) ↔ 电池与储能材料 (工学)
--    储能材料进步依赖制备工艺改进
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '储能材料进步依赖制备工艺改进'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '材料制备与合成'
  AND s2.`name` = '电池与储能材料'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '材料制备与合成'
JOIN `zy_skill` s2 ON s2.`name` = '电池与储能材料'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '储能材料进步依赖制备工艺改进'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 159. 电化学与电池 (理学) ↔ 电池与储能材料 (工学)  [跨门类]
--    电池机理研究属于电化学范畴
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '电池机理研究属于电化学范畴'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '电化学与电池'
  AND s2.`name` = '电池与储能材料'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '电化学与电池'
JOIN `zy_skill` s2 ON s2.`name` = '电池与储能材料'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '电池机理研究属于电化学范畴'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 160. 新能源发电技术 (工学) ↔ 电化学与电池 (理学)  [跨门类]
--    储能与新能源发电属于同一系统
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '储能与新能源发电属于同一系统'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '新能源发电技术'
  AND s2.`name` = '电化学与电池'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '新能源发电技术'
JOIN `zy_skill` s2 ON s2.`name` = '电化学与电池'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '储能与新能源发电属于同一系统'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 161. 复合材料设计 (工学) ↔ 高分子材料加工 (工学)
--    复合材料成型依赖高分子加工工艺
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '复合材料成型依赖高分子加工工艺'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '复合材料设计'
  AND s2.`name` = '高分子材料加工'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '复合材料设计'
JOIN `zy_skill` s2 ON s2.`name` = '高分子材料加工'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '复合材料成型依赖高分子加工工艺'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 162. 材料失效分析 (工学) ↔ 金属热处理工艺 (工学)
--    热处理不当是失效的常见原因
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '热处理不当是失效的常见原因'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '材料失效分析'
  AND s2.`name` = '金属热处理工艺'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '材料失效分析'
JOIN `zy_skill` s2 ON s2.`name` = '金属热处理工艺'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '热处理不当是失效的常见原因'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 163. 化工流程模拟 (工学) ↔ 化工设计与图纸 (工学)
--    流程模拟结果是化工设计的输入
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '流程模拟结果是化工设计的输入'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '化工流程模拟'
  AND s2.`name` = '化工设计与图纸'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '化工流程模拟'
JOIN `zy_skill` s2 ON s2.`name` = '化工设计与图纸'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '流程模拟结果是化工设计的输入'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 164. 化工安全与风险评估 (工学) ↔ 化工实验操作 (工学)
--    实验操作必须配套安全评估
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '实验操作必须配套安全评估'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '化工安全与风险评估'
  AND s2.`name` = '化工实验操作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '化工安全与风险评估'
JOIN `zy_skill` s2 ON s2.`name` = '化工实验操作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '实验操作必须配套安全评估'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 165. 传质与分离工程 (工学) ↔ 污水处理工艺设计 (工学)
--    水处理大量使用传质分离单元
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '水处理大量使用传质分离单元'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '传质与分离工程'
  AND s2.`name` = '污水处理工艺设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '传质与分离工程'
JOIN `zy_skill` s2 ON s2.`name` = '污水处理工艺设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '水处理大量使用传质分离单元'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 166. 催化剂与反应工程 (工学) ↔ 绿色化学与催化 (理学)  [跨门类]
--    催化是绿色化学的主要技术路径
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '催化是绿色化学的主要技术路径'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '催化剂与反应工程'
  AND s2.`name` = '绿色化学与催化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '催化剂与反应工程'
JOIN `zy_skill` s2 ON s2.`name` = '绿色化学与催化'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '催化是绿色化学的主要技术路径'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 167. 化学品管理与安全 (理学) ↔ 化学实验室安全 (理学)
--    实验室安全的核心是化学品管理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '实验室安全的核心是化学品管理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '化学品管理与安全'
  AND s2.`name` = '化学实验室安全'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '化学品管理与安全'
JOIN `zy_skill` s2 ON s2.`name` = '化学实验室安全'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '实验室安全的核心是化学品管理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 168. 分子生物学实验 (理学) ↔ 细胞培养技术 (理学)
--    分子实验绝大多数要在细胞体系里做
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '分子实验绝大多数要在细胞体系里做'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '分子生物学实验'
  AND s2.`name` = '细胞培养技术'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '分子生物学实验'
JOIN `zy_skill` s2 ON s2.`name` = '细胞培养技术'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '分子实验绝大多数要在细胞体系里做'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 169. 分子生物学实验 (理学) ↔ 医学分子生物学 (医学)  [跨门类]
--    医学方向的分子实验是同一套技术
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '医学方向的分子实验是同一套技术'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '分子生物学实验'
  AND s2.`name` = '医学分子生物学'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '分子生物学实验'
JOIN `zy_skill` s2 ON s2.`name` = '医学分子生物学'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '医学方向的分子实验是同一套技术'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 170. 免疫学实验技术 (医学) ↔ 细胞培养技术 (理学)  [跨门类]
--    免疫实验常用细胞与抗体体系
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '免疫实验常用细胞与抗体体系'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '免疫学实验技术'
  AND s2.`name` = '细胞培养技术'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '免疫学实验技术'
JOIN `zy_skill` s2 ON s2.`name` = '细胞培养技术'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '免疫实验常用细胞与抗体体系'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 171. 生物信息学分析 (理学) ↔ 遗传学与基因编辑 (理学)
--    基因编辑结果要靠生信分析验证
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '基因编辑结果要靠生信分析验证'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '生物信息学分析'
  AND s2.`name` = '遗传学与基因编辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '生物信息学分析'
JOIN `zy_skill` s2 ON s2.`name` = '遗传学与基因编辑'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '基因编辑结果要靠生信分析验证'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 172. 生物信息学分析 (理学) ↔ 生物统计与R应用 (理学)
--    生信结果的统计检验与绘图依赖 R
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '生信结果的统计检验与绘图依赖 R'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '生物信息学分析'
  AND s2.`name` = '生物统计与R应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '生物信息学分析'
JOIN `zy_skill` s2 ON s2.`name` = '生物统计与R应用'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '生信结果的统计检验与绘图依赖 R'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 173. 实验数据处理与作图 (理学) ↔ 生物统计与作图 (理学)
--    生物实验数据出图是论文的固定环节
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '生物实验数据出图是论文的固定环节'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '实验数据处理与作图'
  AND s2.`name` = '生物统计与作图'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '实验数据处理与作图'
JOIN `zy_skill` s2 ON s2.`name` = '生物统计与作图'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '生物实验数据出图是论文的固定环节'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 174. 显微成像与观察 (理学) ↔ 显微镜操作与制片 (理学)
--    制片质量决定成像结果
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '制片质量决定成像结果'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '显微成像与观察'
  AND s2.`name` = '显微镜操作与制片'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '显微成像与观察'
JOIN `zy_skill` s2 ON s2.`name` = '显微镜操作与制片'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '制片质量决定成像结果'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 175. 显微成像与观察 (理学) ↔ 生物绘图与示意图 (理学)
--    成像结果常需重绘为示意图
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '成像结果常需重绘为示意图'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '显微成像与观察'
  AND s2.`name` = '生物绘图与示意图'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '显微成像与观察'
JOIN `zy_skill` s2 ON s2.`name` = '生物绘图与示意图'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '成像结果常需重绘为示意图'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 176. 分子生物学实验 (理学) ↔ 蛋白质表达与纯化 (理学)
--    表达纯化是分子实验的核心环节
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '表达纯化是分子实验的核心环节'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '分子生物学实验'
  AND s2.`name` = '蛋白质表达与纯化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '分子生物学实验'
JOIN `zy_skill` s2 ON s2.`name` = '蛋白质表达与纯化'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '表达纯化是分子实验的核心环节'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 177. 植物组织培养 (理学) ↔ 细胞培养技术 (理学)
--    植物组培与动物细胞培养技术同源
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '植物组培与动物细胞培养技术同源'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '植物组织培养'
  AND s2.`name` = '细胞培养技术'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '植物组织培养'
JOIN `zy_skill` s2 ON s2.`name` = '细胞培养技术'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '植物组培与动物细胞培养技术同源'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 178. 临床数据分析 (医学) ↔ 医学统计学 (医学)
--    临床研究的数据分析就是医学统计
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '临床研究的数据分析就是医学统计'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '临床数据分析'
  AND s2.`name` = '医学统计学'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '临床数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '医学统计学'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '临床研究的数据分析就是医学统计'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 179. 医学统计学 (医学) ↔ 流行病学调查 (医学)
--    流调结论必须做统计检验
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '流调结论必须做统计检验'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医学统计学'
  AND s2.`name` = '流行病学调查'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医学统计学'
JOIN `zy_skill` s2 ON s2.`name` = '流行病学调查'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '流调结论必须做统计检验'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 180. 卫生检验与检疫 (医学) ↔ 流行病学调查 (医学)
--    流调结论依赖检验结果支撑
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '流调结论依赖检验结果支撑'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '卫生检验与检疫'
  AND s2.`name` = '流行病学调查'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '卫生检验与检疫'
JOIN `zy_skill` s2 ON s2.`name` = '流行病学调查'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '流调结论依赖检验结果支撑'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 181. 临床数据分析 (医学) ↔ 卫生统计与spss (医学)
--    临床数据处理常用 SPSS 完成
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '临床数据处理常用 SPSS 完成'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '临床数据分析'
  AND s2.`name` = '卫生统计与spss'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '临床数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '卫生统计与spss'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '临床数据处理常用 SPSS 完成'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 182. 医学文献检索与综述 (医学) ↔ 文献检索与信息素养 (管理学)  [跨门类]
--    检索能力是综述写作的前提
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '检索能力是综述写作的前提'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医学文献检索与综述'
  AND s2.`name` = '文献检索与信息素养'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医学文献检索与综述'
JOIN `zy_skill` s2 ON s2.`name` = '文献检索与信息素养'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '检索能力是综述写作的前提'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 183. 医学文献检索与综述 (医学) ↔ 医学文献阅读与循证 (医学)
--    循证医学建立在文献综述之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '循证医学建立在文献综述之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医学文献检索与综述'
  AND s2.`name` = '医学文献阅读与循证'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医学文献检索与综述'
JOIN `zy_skill` s2 ON s2.`name` = '医学文献阅读与循证'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '循证医学建立在文献综述之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 184. 医学术语与英文文献 (医学) ↔ 学术英语写作 (文学)  [跨门类]
--    读英文文献与写英文论文是同一能力两侧
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '读英文文献与写英文论文是同一能力两侧'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医学术语与英文文献'
  AND s2.`name` = '学术英语写作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医学术语与英文文献'
JOIN `zy_skill` s2 ON s2.`name` = '学术英语写作'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '读英文文献与写英文论文是同一能力两侧'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 185. 影像诊断读片 (医学) ↔ 病理学读片 (医学)
--    病理与影像共同支撑诊断结论
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '病理与影像共同支撑诊断结论'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '影像诊断读片'
  AND s2.`name` = '病理学读片'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '影像诊断读片'
JOIN `zy_skill` s2 ON s2.`name` = '病理学读片'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '病理与影像共同支撑诊断结论'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 186. 医学图像处理 (工学) ↔ 影像诊断读片 (医学)  [跨门类]
--    影像读片与影像组学分析相互印证
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '影像读片与影像组学分析相互印证'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医学图像处理'
  AND s2.`name` = '影像诊断读片'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医学图像处理'
JOIN `zy_skill` s2 ON s2.`name` = '影像诊断读片'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '影像读片与影像组学分析相互印证'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 187. 医学图像处理 (工学) ↔ 计算机视觉应用 (工学)
--    医学图像分析是视觉技术的医学落点
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '医学图像分析是视觉技术的医学落点'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医学图像处理'
  AND s2.`name` = '计算机视觉应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医学图像处理'
JOIN `zy_skill` s2 ON s2.`name` = '计算机视觉应用'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '医学图像分析是视觉技术的医学落点'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 188. 信号采集与滤波 (工学) ↔ 生物信号采集与分析 (工学)
--    生理信号处理与通用信号处理同源
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '生理信号处理与通用信号处理同源'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '信号采集与滤波'
  AND s2.`name` = '生物信号采集与分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '信号采集与滤波'
JOIN `zy_skill` s2 ON s2.`name` = '生物信号采集与分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '生理信号处理与通用信号处理同源'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 189. 医疗仪器原理与维护 (工学) ↔ 生物信号采集与分析 (工学)
--    信号采集是医疗仪器的核心功能
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '信号采集是医疗仪器的核心功能'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医疗仪器原理与维护'
  AND s2.`name` = '生物信号采集与分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医疗仪器原理与维护'
JOIN `zy_skill` s2 ON s2.`name` = '生物信号采集与分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '信号采集是医疗仪器的核心功能'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 190. 康复辅具设计 (工学) ↔ 生物材料与植入体 (工学)
--    植入体与辅具同属生物医学工程产品
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '植入体与辅具同属生物医学工程产品'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '康复辅具设计'
  AND s2.`name` = '生物材料与植入体'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '康复辅具设计'
JOIN `zy_skill` s2 ON s2.`name` = '生物材料与植入体'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '植入体与辅具同属生物医学工程产品'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 191. 急救与心肺复苏 (医学) ↔ 急救技能普及培训 (医学)
--    急救能力要通过普及培训扩散出去
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '急救能力要通过普及培训扩散出去'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '急救与心肺复苏'
  AND s2.`name` = '急救技能普及培训'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '急救与心肺复苏'
JOIN `zy_skill` s2 ON s2.`name` = '急救技能普及培训'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '急救能力要通过普及培训扩散出去'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 192. 急救与心肺复苏 (医学) ↔ 急救护理 (医学)
--    护理急救与临床急救标准一致
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '护理急救与临床急救标准一致'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '急救与心肺复苏'
  AND s2.`name` = '急救护理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '急救与心肺复苏'
JOIN `zy_skill` s2 ON s2.`name` = '急救护理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '护理急救与临床急救标准一致'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 193. 基础护理操作 (医学) ↔ 护理文书书写 (医学)
--    护理操作必须留下规范记录
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '护理操作必须留下规范记录'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '基础护理操作'
  AND s2.`name` = '护理文书书写'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '基础护理操作'
JOIN `zy_skill` s2 ON s2.`name` = '护理文书书写'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '护理操作必须留下规范记录'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 194. 医患沟通技巧 (医学) ↔ 心理护理与沟通 (医学)
--    沟通技巧在护理与临床是同一能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '沟通技巧在护理与临床是同一能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医患沟通技巧'
  AND s2.`name` = '心理护理与沟通'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医患沟通技巧'
JOIN `zy_skill` s2 ON s2.`name` = '心理护理与沟通'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '沟通技巧在护理与临床是同一能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 195. 健康科普内容创作 (医学) ↔ 医患沟通技巧 (医学)
--    科普创作是医患沟通的延伸形式
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '科普创作是医患沟通的延伸形式'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '健康科普内容创作'
  AND s2.`name` = '医患沟通技巧'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '健康科普内容创作'
JOIN `zy_skill` s2 ON s2.`name` = '医患沟通技巧'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '科普创作是医患沟通的延伸形式'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 196. 健康科普内容创作 (医学) ↔ 视频号内容制作 (工学)  [跨门类]
--    健康科普的主要传播渠道是短视频
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '健康科普的主要传播渠道是短视频'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '健康科普内容创作'
  AND s2.`name` = '视频号内容制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '健康科普内容创作'
JOIN `zy_skill` s2 ON s2.`name` = '视频号内容制作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '健康科普的主要传播渠道是短视频'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 197. 健康科普内容创作 (医学) ↔ 公众号排版与运营 (工学)  [跨门类]
--    图文科普依赖公众号这类载体
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '图文科普依赖公众号这类载体'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '健康科普内容创作'
  AND s2.`name` = '公众号排版与运营'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '健康科普内容创作'
JOIN `zy_skill` s2 ON s2.`name` = '公众号排版与运营'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '图文科普依赖公众号这类载体'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 198. 健康教育与促进 (医学) ↔ 健康科普内容创作 (医学)
--    科普是健康教育的主要产出形态
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '科普是健康教育的主要产出形态'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '健康教育与促进'
  AND s2.`name` = '健康科普内容创作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '健康教育与促进'
JOIN `zy_skill` s2 ON s2.`name` = '健康科普内容创作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '科普是健康教育的主要产出形态'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 199. 临床用药监护 (医学) ↔ 药理学与用药指导 (医学)
--    用药指导与用药监护是同一条链路
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '用药指导与用药监护是同一条链路'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '临床用药监护'
  AND s2.`name` = '药理学与用药指导'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '临床用药监护'
JOIN `zy_skill` s2 ON s2.`name` = '药理学与用药指导'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '用药指导与用药监护是同一条链路'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 200. 药剂学与制剂制备 (医学) ↔ 药物合成与工艺 (医学)
--    制剂与合成是药物研发的两个环节
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '制剂与合成是药物研发的两个环节'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '药剂学与制剂制备'
  AND s2.`name` = '药物合成与工艺'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '药剂学与制剂制备'
JOIN `zy_skill` s2 ON s2.`name` = '药物合成与工艺'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '制剂与合成是药物研发的两个环节'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 201. 药事管理与法规 (医学) ↔ 食品安全与检测 (医学)
--    食药监管法规体系高度联动
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '食药监管法规体系高度联动'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '药事管理与法规'
  AND s2.`name` = '食品安全与检测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '药事管理与法规'
JOIN `zy_skill` s2 ON s2.`name` = '食品安全与检测'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '食药监管法规体系高度联动'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 202. 中药鉴定与炮制 (医学) ↔ 无机化学与配位 (理学)  [跨门类]
--    药材鉴定需要化学分析手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '药材鉴定需要化学分析手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '中药鉴定与炮制'
  AND s2.`name` = '无机化学与配位'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '中药鉴定与炮制'
JOIN `zy_skill` s2 ON s2.`name` = '无机化学与配位'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '药材鉴定需要化学分析手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 203. 营养与食品卫生 (医学) ↔ 食品营养与配方设计 (农学)  [跨门类]
--    配方设计要以营养学为依据
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '配方设计要以营养学为依据'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '营养与食品卫生'
  AND s2.`name` = '食品营养与配方设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '营养与食品卫生'
JOIN `zy_skill` s2 ON s2.`name` = '食品营养与配方设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '配方设计要以营养学为依据'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 204. 作物栽培与田间管理 (农学) ↔ 土壤污染修复 (工学)  [跨门类]
--    栽培方案要结合土壤质量制定
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '栽培方案要结合土壤质量制定'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '作物栽培与田间管理'
  AND s2.`name` = '土壤污染修复'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '作物栽培与田间管理'
JOIN `zy_skill` s2 ON s2.`name` = '土壤污染修复'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '栽培方案要结合土壤质量制定'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 205. 作物栽培与田间管理 (农学) ↔ 天气分析与预报 (理学)  [跨门类]
--    农事安排高度依赖天气预报
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '农事安排高度依赖天气预报'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '作物栽培与田间管理'
  AND s2.`name` = '天气分析与预报'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '作物栽培与田间管理'
JOIN `zy_skill` s2 ON s2.`name` = '天气分析与预报'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '农事安排高度依赖天气预报'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 206. 作物栽培与田间管理 (农学) ↔ 农业遥感与估产 (农学)
--    长势监测与估产依据遥感数据
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '长势监测与估产依据遥感数据'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '作物栽培与田间管理'
  AND s2.`name` = '农业遥感与估产'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '作物栽培与田间管理'
JOIN `zy_skill` s2 ON s2.`name` = '农业遥感与估产'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '长势监测与估产依据遥感数据'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 207. 农业遥感与估产 (农学) ↔ 遥感影像解译 (理学)  [跨门类]
--    农情估产直接调用遥感解译能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '农情估产直接调用遥感解译能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '农业遥感与估产'
  AND s2.`name` = '遥感影像解译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '农业遥感与估产'
JOIN `zy_skill` s2 ON s2.`name` = '遥感影像解译'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '农情估产直接调用遥感解译能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 208. 作物育种与良种繁育 (农学) ↔ 遗传学与基因编辑 (理学)  [跨门类]
--    育种的理论基础是遗传学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '育种的理论基础是遗传学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '作物育种与良种繁育'
  AND s2.`name` = '遗传学与基因编辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '作物育种与良种繁育'
JOIN `zy_skill` s2 ON s2.`name` = '遗传学与基因编辑'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '育种的理论基础是遗传学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 209. 微生物培养与鉴定 (理学) ↔ 植物病理与诊断 (农学)  [跨门类]
--    病原鉴定依赖微生物培养技术
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '病原鉴定依赖微生物培养技术'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '微生物培养与鉴定'
  AND s2.`name` = '植物病理与诊断'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '微生物培养与鉴定'
JOIN `zy_skill` s2 ON s2.`name` = '植物病理与诊断'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '病原鉴定依赖微生物培养技术'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 210. 水文观测与计算 (理学) ↔ 自然灾害风险评估 (理学)
--    洪涝风险评估以水文计算为基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '洪涝风险评估以水文计算为基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '水文观测与计算'
  AND s2.`name` = '自然灾害风险评估'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '水文观测与计算'
JOIN `zy_skill` s2 ON s2.`name` = '自然灾害风险评估'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '洪涝风险评估以水文计算为基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 211. 农产品品牌与电商 (农学) ↔ 电子商务运营 (经济学)  [跨门类]
--    农产品上行靠电商运营能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '农产品上行靠电商运营能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '农产品品牌与电商'
  AND s2.`name` = '电子商务运营'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '农产品品牌与电商'
JOIN `zy_skill` s2 ON s2.`name` = '电子商务运营'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '农产品上行靠电商运营能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 212. 农产品品牌与电商 (农学) ↔ 营销策划与推广 (经济学)  [跨门类]
--    品牌打造需要营销方案
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '品牌打造需要营销方案'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '农产品品牌与电商'
  AND s2.`name` = '营销策划与推广'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '农产品品牌与电商'
JOIN `zy_skill` s2 ON s2.`name` = '营销策划与推广'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '品牌打造需要营销方案'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 213. 休闲农业与乡村旅游 (农学) ↔ 城市规划与场地分析 (工学)  [跨门类]
--    乡村旅游项目需要场地与规划分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '乡村旅游项目需要场地与规划分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '休闲农业与乡村旅游'
  AND s2.`name` = '城市规划与场地分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '休闲农业与乡村旅游'
JOIN `zy_skill` s2 ON s2.`name` = '城市规划与场地分析'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '乡村旅游项目需要场地与规划分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 214. 农业技术推广 (农学) ↔ 社会调查与统计分析 (管理学)  [跨门类]
--    推广效果要靠下乡调研数据验证
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '推广效果要靠下乡调研数据验证'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '农业技术推广'
  AND s2.`name` = '社会调查与统计分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '农业技术推广'
JOIN `zy_skill` s2 ON s2.`name` = '社会调查与统计分析'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '推广效果要靠下乡调研数据验证'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 215. 森林生态与碳汇 (农学) ↔ 碳排放核算 (工学)  [跨门类]
--    林业碳汇是碳核算的重要科目
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '林业碳汇是碳核算的重要科目'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '森林生态与碳汇'
  AND s2.`name` = '碳排放核算'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '森林生态与碳汇'
JOIN `zy_skill` s2 ON s2.`name` = '碳排放核算'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '林业碳汇是碳核算的重要科目'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 216. 森林资源调查 (农学) ↔ 遥感影像解译 (理学)  [跨门类]
--    林地调查大量使用遥感判读
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '林地调查大量使用遥感判读'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '森林资源调查'
  AND s2.`name` = '遥感影像解译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '森林资源调查'
JOIN `zy_skill` s2 ON s2.`name` = '遥感影像解译'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '林地调查大量使用遥感判读'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 217. 园林景观设计 (农学) ↔ 园林植物造景 (农学)
--    植物造景是景观设计的落地手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '植物造景是景观设计的落地手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '园林景观设计'
  AND s2.`name` = '园林植物造景'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '园林景观设计'
JOIN `zy_skill` s2 ON s2.`name` = '园林植物造景'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '植物造景是景观设计的落地手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 218. 园林植物造景 (农学) ↔ 苗木繁育与养护 (农学)
--    造景效果取决于苗木质量与养护
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '造景效果取决于苗木质量与养护'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '园林植物造景'
  AND s2.`name` = '苗木繁育与养护'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '园林植物造景'
JOIN `zy_skill` s2 ON s2.`name` = '苗木繁育与养护'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '造景效果取决于苗木质量与养护'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 219. 食品加工工艺 (农学) ↔ 食品工程原理 (农学)
--    加工工艺建立在工程原理上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '加工工艺建立在工程原理上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '食品加工工艺'
  AND s2.`name` = '食品工程原理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '食品加工工艺'
JOIN `zy_skill` s2 ON s2.`name` = '食品工程原理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '加工工艺建立在工程原理上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 220. 食品安全与检测 (医学) ↔ 食品微生物检验 (农学)  [跨门类]
--    食品检测的核心项就是微生物
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '食品检测的核心项就是微生物'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '食品安全与检测'
  AND s2.`name` = '食品微生物检验'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '食品安全与检测'
JOIN `zy_skill` s2 ON s2.`name` = '食品微生物检验'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '食品检测的核心项就是微生物'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 221. 食品安全与检测 (医学) ↔ 食品法规与标准 (农学)  [跨门类]
--    检测判定依据来自标准与法规
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '检测判定依据来自标准与法规'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '食品安全与检测'
  AND s2.`name` = '食品法规与标准'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '食品安全与检测'
JOIN `zy_skill` s2 ON s2.`name` = '食品法规与标准'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '检测判定依据来自标准与法规'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 222. 感官评价与品评 (农学) ↔ 消费者行为分析 (经济学)  [跨门类]
--    感官品评是消费者偏好的实验化表达
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '感官品评是消费者偏好的实验化表达'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '感官评价与品评'
  AND s2.`name` = '消费者行为分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '感官评价与品评'
JOIN `zy_skill` s2 ON s2.`name` = '消费者行为分析'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '感官品评是消费者偏好的实验化表达'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 223. 农产品贮藏与加工 (农学) ↔ 食品加工工艺 (农学)
--    贮藏与加工是同一条产业链
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '贮藏与加工是同一条产业链'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '农产品贮藏与加工'
  AND s2.`name` = '食品加工工艺'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '农产品贮藏与加工'
JOIN `zy_skill` s2 ON s2.`name` = '食品加工工艺'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '贮藏与加工是同一条产业链'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 224. 口语发音纠正 (文学) ↔ 英语口语陪练 (文学)
--    纠音与陪练是口语训练的两个环节
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '纠音与陪练是口语训练的两个环节'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '口语发音纠正'
  AND s2.`name` = '英语口语陪练'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '口语发音纠正'
JOIN `zy_skill` s2 ON s2.`name` = '英语口语陪练'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '纠音与陪练是口语训练的两个环节'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 225. 英语写作与润色 (文学) ↔ 英语口语陪练 (文学)
--    口语与写作同属语言输出能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '口语与写作同属语言输出能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '英语写作与润色'
  AND s2.`name` = '英语口语陪练'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '英语写作与润色'
JOIN `zy_skill` s2 ON s2.`name` = '英语口语陪练'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '口语与写作同属语言输出能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 226. 英汉互译 (文学) ↔ 英语写作与润色 (文学)
--    写作与翻译在语言服务里是同一能力组
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '写作与翻译在语言服务里是同一能力组'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '英汉互译'
  AND s2.`name` = '英语写作与润色'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '英汉互译'
JOIN `zy_skill` s2 ON s2.`name` = '英语写作与润色'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '写作与翻译在语言服务里是同一能力组'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 227. 商务英语函电 (文学) ↔ 国际贸易实务 (经济学)  [跨门类]
--    外贸函电就是国际贸易的日常书面沟通
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '外贸函电就是国际贸易的日常书面沟通'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '商务英语函电'
  AND s2.`name` = '国际贸易实务'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '商务英语函电'
JOIN `zy_skill` s2 ON s2.`name` = '国际贸易实务'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '外贸函电就是国际贸易的日常书面沟通'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 228. 商务英语函电 (文学) ↔ 跨文化交际 (文学)
--    对外沟通必须处理文化差异
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '对外沟通必须处理文化差异'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '商务英语函电'
  AND s2.`name` = '跨文化交际'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '商务英语函电'
JOIN `zy_skill` s2 ON s2.`name` = '跨文化交际'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '对外沟通必须处理文化差异'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 229. 口译与交替传译 (文学) ↔ 跨文化交际 (文学)
--    口译现场必须处理文化差异
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '口译现场必须处理文化差异'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '口译与交替传译'
  AND s2.`name` = '跨文化交际'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '口译与交替传译'
JOIN `zy_skill` s2 ON s2.`name` = '跨文化交际'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '口译现场必须处理文化差异'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 230. 字幕制作与打轴 (文学) ↔ 字幕翻译与本地化 (文学)
--    字幕翻译与时间轴制作必须配套
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '字幕翻译与时间轴制作必须配套'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '字幕制作与打轴'
  AND s2.`name` = '字幕翻译与本地化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '字幕制作与打轴'
JOIN `zy_skill` s2 ON s2.`name` = '字幕翻译与本地化'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '字幕翻译与时间轴制作必须配套'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 231. 学术英语写作 (文学) ↔ 英文文献阅读 (文学)
--    读文献与写论文是科研英语的两个方向
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '读文献与写论文是科研英语的两个方向'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '学术英语写作'
  AND s2.`name` = '英文文献阅读'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '学术英语写作'
JOIN `zy_skill` s2 ON s2.`name` = '英文文献阅读'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '读文献与写论文是科研英语的两个方向'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 232. 学术引用格式规范 (文学) ↔ 学术英语写作 (文学)
--    英文论文同样受引注规范约束
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '英文论文同样受引注规范约束'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '学术引用格式规范'
  AND s2.`name` = '学术英语写作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '学术引用格式规范'
JOIN `zy_skill` s2 ON s2.`name` = '学术英语写作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '英文论文同样受引注规范约束'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 233. 参考文献管理与规范 (管理学) ↔ 学术引用格式规范 (文学)  [跨门类]
--    引注格式的落地工具就是文献管理器
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '引注格式的落地工具就是文献管理器'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '参考文献管理与规范'
  AND s2.`name` = '学术引用格式规范'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '参考文献管理与规范'
JOIN `zy_skill` s2 ON s2.`name` = '学术引用格式规范'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '引注格式的落地工具就是文献管理器'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 234. 参考文献管理与规范 (管理学) ↔ 开题与文献综述撰写 (管理学)
--    综述写作必然伴随文献管理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '综述写作必然伴随文献管理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '参考文献管理与规范'
  AND s2.`name` = '开题与文献综述撰写'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '参考文献管理与规范'
JOIN `zy_skill` s2 ON s2.`name` = '开题与文献综述撰写'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '综述写作必然伴随文献管理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 235. 开题与文献综述撰写 (管理学) ↔ 文献检索与信息素养 (管理学)
--    不会检索就写不出综述
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '不会检索就写不出综述'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '开题与文献综述撰写'
  AND s2.`name` = '文献检索与信息素养'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '开题与文献综述撰写'
JOIN `zy_skill` s2 ON s2.`name` = '文献检索与信息素养'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '不会检索就写不出综述'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 236. LaTeX 论文排版 (工学) ↔ 数学公式编辑与排版 (理学)  [跨门类]
--    公式排版是 LaTeX 的核心场景
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '公式排版是 LaTeX 的核心场景'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'LaTeX 论文排版'
  AND s2.`name` = '数学公式编辑与排版'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'LaTeX 论文排版'
JOIN `zy_skill` s2 ON s2.`name` = '数学公式编辑与排版'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '公式排版是 LaTeX 的核心场景'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 237. 产品需求文档撰写 (工学) ↔ 技术文档写作 (工学)
--    需求文档是技术文档的一种
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '需求文档是技术文档的一种'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '产品需求文档撰写'
  AND s2.`name` = '技术文档写作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '产品需求文档撰写'
JOIN `zy_skill` s2 ON s2.`name` = '技术文档写作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '需求文档是技术文档的一种'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 238. 公文写作与行政事务 (管理学) ↔ 技术文档写作 (工学)  [跨门类]
--    结构化写作能力在两个场景通用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '结构化写作能力在两个场景通用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '公文写作与行政事务'
  AND s2.`name` = '技术文档写作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '公文写作与行政事务'
JOIN `zy_skill` s2 ON s2.`name` = '技术文档写作'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '结构化写作能力在两个场景通用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 239. 公文写作与行政事务 (管理学) ↔ 公文格式与排版规范 (文学)  [跨门类]
--    公文写作必须遵守格式规范
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '公文写作必须遵守格式规范'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '公文写作与行政事务'
  AND s2.`name` = '公文格式与排版规范'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '公文写作与行政事务'
JOIN `zy_skill` s2 ON s2.`name` = '公文格式与排版规范'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '公文写作必须遵守格式规范'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 240. 培训课件与讲义制作 (教育学) ↔ 教学设计 (教育学)
--    设计要落成课件才算完整
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '设计要落成课件才算完整'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '培训课件与讲义制作'
  AND s2.`name` = '教学设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '培训课件与讲义制作'
JOIN `zy_skill` s2 ON s2.`name` = '教学设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '设计要落成课件才算完整'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 241. 微课与在线课程制作 (教育学) ↔ 教学设计 (教育学)
--    在线课程是教学设计的交付形态
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '在线课程是教学设计的交付形态'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '微课与在线课程制作'
  AND s2.`name` = '教学设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '微课与在线课程制作'
JOIN `zy_skill` s2 ON s2.`name` = '教学设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '在线课程是教学设计的交付形态'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 242. 微课与在线课程制作 (教育学) ↔ 视频剪辑 (艺术学)  [跨门类]
--    微课后期常用剪辑软件完成
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '微课后期常用剪辑软件完成'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '微课与在线课程制作'
  AND s2.`name` = '视频剪辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '微课与在线课程制作'
JOIN `zy_skill` s2 ON s2.`name` = '视频剪辑'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '微课后期常用剪辑软件完成'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 243. 在线教学平台使用 (教育学) ↔ 微课与在线课程制作 (教育学)
--    课程要发布到平台上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '课程要发布到平台上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '在线教学平台使用'
  AND s2.`name` = '微课与在线课程制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '在线教学平台使用'
JOIN `zy_skill` s2 ON s2.`name` = '微课与在线课程制作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '课程要发布到平台上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 244. PPT 与汇报表达 (艺术学) ↔ 教学课件制作 (教育学)  [跨门类]
--    课件与汇报互为表里
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '课件与汇报互为表里'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'PPT 与汇报表达'
  AND s2.`name` = '教学课件制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'PPT 与汇报表达'
JOIN `zy_skill` s2 ON s2.`name` = '教学课件制作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '课件与汇报互为表里'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 245. 一对一辅导技巧 (教育学) ↔ 知识点讲解与拆解 (教育学)
--    讲解能力在辅导场景里兑现
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '讲解能力在辅导场景里兑现'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '一对一辅导技巧'
  AND s2.`name` = '知识点讲解与拆解'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '一对一辅导技巧'
JOIN `zy_skill` s2 ON s2.`name` = '知识点讲解与拆解'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '讲解能力在辅导场景里兑现'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 246. 习题设计与讲评 (教育学) ↔ 教育测量与评价 (教育学)
--    习题是测评工具的具体形态
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '习题是测评工具的具体形态'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '习题设计与讲评'
  AND s2.`name` = '教育测量与评价'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '习题设计与讲评'
JOIN `zy_skill` s2 ON s2.`name` = '教育测量与评价'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '习题是测评工具的具体形态'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 247. 心理测量与量表分析 (理学) ↔ 教育测量与评价 (教育学)  [跨门类]
--    教育测评与心理测量方法同源
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '教育测评与心理测量方法同源'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '心理测量与量表分析'
  AND s2.`name` = '教育测量与评价'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '心理测量与量表分析'
JOIN `zy_skill` s2 ON s2.`name` = '教育测量与评价'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '教育测评与心理测量方法同源'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 248. 心理咨询基本技术 (理学) ↔ 教育心理学应用 (教育学)  [跨门类]
--    教育场景普遍需要心理沟通技术
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '教育场景普遍需要心理沟通技术'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '心理咨询基本技术'
  AND s2.`name` = '教育心理学应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '心理咨询基本技术'
JOIN `zy_skill` s2 ON s2.`name` = '教育心理学应用'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '教育场景普遍需要心理沟通技术'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 249. AI 辅助写作与润色 (工学) ↔ 教育技术工具应用 (教育学)  [跨门类]
--    教育技术实践已普遍引入 AI 工具
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '教育技术实践已普遍引入 AI 工具'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'AI 辅助写作与润色'
  AND s2.`name` = '教育技术工具应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'AI 辅助写作与润色'
JOIN `zy_skill` s2 ON s2.`name` = '教育技术工具应用'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '教育技术实践已普遍引入 AI 工具'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 250. 学习效率与刻意练习 (管理学) ↔ 认知心理学范式 (理学)  [跨门类]
--    学习方法的依据是认知心理学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '学习方法的依据是认知心理学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '学习效率与刻意练习'
  AND s2.`name` = '认知心理学范式'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '学习效率与刻意练习'
JOIN `zy_skill` s2 ON s2.`name` = '认知心理学范式'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '学习方法的依据是认知心理学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 251. 用户体验心理研究 (理学) ↔ 用户体验研究方法 (艺术学)  [跨门类]
--    心理机制研究与需求洞察相互支撑
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '心理机制研究与需求洞察相互支撑'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '用户体验心理研究'
  AND s2.`name` = '用户体验研究方法'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '用户体验心理研究'
JOIN `zy_skill` s2 ON s2.`name` = '用户体验研究方法'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '心理机制研究与需求洞察相互支撑'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 252. 实验心理学设计 (理学) ↔ 用户体验研究方法 (艺术学)  [跨门类]
--    用研方法大量借自实验心理学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '用研方法大量借自实验心理学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '实验心理学设计'
  AND s2.`name` = '用户体验研究方法'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '实验心理学设计'
JOIN `zy_skill` s2 ON s2.`name` = '用户体验研究方法'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '用研方法大量借自实验心理学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 253. 市场调研与用户洞察 (经济学) ↔ 用户体验研究方法 (艺术学)  [跨门类]
--    用研与市场调研常配合使用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '用研与市场调研常配合使用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '市场调研与用户洞察'
  AND s2.`name` = '用户体验研究方法'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '市场调研与用户洞察'
JOIN `zy_skill` s2 ON s2.`name` = '用户体验研究方法'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '用研与市场调研常配合使用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 254. 实验心理学设计 (理学) ↔ 认知心理学范式 (理学)
--    认知范式要靠实验设计来验证
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '认知范式要靠实验设计来验证'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '实验心理学设计'
  AND s2.`name` = '认知心理学范式'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '实验心理学设计'
JOIN `zy_skill` s2 ON s2.`name` = '认知心理学范式'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '认知范式要靠实验设计来验证'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 255. 消费者行为分析 (经济学) ↔ 用户体验心理研究 (理学)  [跨门类]
--    消费决策与用户体验研究共享行为科学基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '消费决策与用户体验研究共享行为科学基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '消费者行为分析'
  AND s2.`name` = '用户体验心理研究'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '消费者行为分析'
JOIN `zy_skill` s2 ON s2.`name` = '用户体验心理研究'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '消费决策与用户体验研究共享行为科学基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 256. 心理咨询基本技术 (理学) ↔ 心理护理与沟通 (医学)  [跨门类]
--    咨询技术与护理沟通同源
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '咨询技术与护理沟通同源'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '心理咨询基本技术'
  AND s2.`name` = '心理护理与沟通'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '心理咨询基本技术'
JOIN `zy_skill` s2 ON s2.`name` = '心理护理与沟通'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '咨询技术与护理沟通同源'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 257. 组织行为与团队建设 (经济学) ↔ 跨专业沟通与转译 (管理学)  [跨门类]
--    组织协作的核心难题就是专业间转译
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '组织协作的核心难题就是专业间转译'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '组织行为与团队建设'
  AND s2.`name` = '跨专业沟通与转译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '组织行为与团队建设'
JOIN `zy_skill` s2 ON s2.`name` = '跨专业沟通与转译'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '组织协作的核心难题就是专业间转译'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 258. 体育赛事组织与裁判 (教育学) ↔ 项目管理与进度把控 (工学)  [跨门类]
--    赛事组织本质是项目管理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '赛事组织本质是项目管理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '体育赛事组织与裁判'
  AND s2.`name` = '项目管理与进度把控'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '体育赛事组织与裁判'
JOIN `zy_skill` s2 ON s2.`name` = '项目管理与进度把控'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '赛事组织本质是项目管理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 259. 急救与心肺复苏 (医学) ↔ 运动损伤防护 (教育学)  [跨门类]
--    运动伤情处理直接依赖急救能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '运动伤情处理直接依赖急救能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '急救与心肺复苏'
  AND s2.`name` = '运动损伤防护'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '急救与心肺复苏'
JOIN `zy_skill` s2 ON s2.`name` = '运动损伤防护'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '运动伤情处理直接依赖急救能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 260. 康复辅具设计 (工学) ↔ 运动损伤防护 (教育学)  [跨门类]
--    运动康复方案涉及辅具适配
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '运动康复方案涉及辅具适配'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '康复辅具设计'
  AND s2.`name` = '运动损伤防护'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '康复辅具设计'
JOIN `zy_skill` s2 ON s2.`name` = '运动损伤防护'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '运动康复方案涉及辅具适配'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 261. 健身与体能训练 (教育学) ↔ 运动营养指导 (教育学)
--    训练效果与营养方案必须配套
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '训练效果与营养方案必须配套'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '健身与体能训练'
  AND s2.`name` = '运动营养指导'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '健身与体能训练'
JOIN `zy_skill` s2 ON s2.`name` = '运动营养指导'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '训练效果与营养方案必须配套'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 262. 项目管理 PMP (经济学) ↔ 项目管理与进度把控 (工学)  [跨门类]
--    同一套项目管理知识体系的两侧
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '同一套项目管理知识体系的两侧'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '项目管理 PMP'
  AND s2.`name` = '项目管理与进度把控'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '项目管理 PMP'
JOIN `zy_skill` s2 ON s2.`name` = '项目管理与进度把控'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '同一套项目管理知识体系的两侧'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 263. 敏捷开发与迭代管理 (工学) ↔ 项目管理与进度把控 (工学)
--    敏捷是项目管理在软件领域的落地形态
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '敏捷是项目管理在软件领域的落地形态'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '敏捷开发与迭代管理'
  AND s2.`name` = '项目管理与进度把控'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '敏捷开发与迭代管理'
JOIN `zy_skill` s2 ON s2.`name` = '项目管理与进度把控'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '敏捷是项目管理在软件领域的落地形态'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 264. 敏捷估算与燃尽图 (工学) ↔ 敏捷开发与迭代管理 (工学)
--    估算是敏捷迭代的核心动作
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '估算是敏捷迭代的核心动作'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '敏捷估算与燃尽图'
  AND s2.`name` = '敏捷开发与迭代管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '敏捷估算与燃尽图'
JOIN `zy_skill` s2 ON s2.`name` = '敏捷开发与迭代管理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '估算是敏捷迭代的核心动作'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 265. 团队协作与冲突处理 (管理学) ↔ 组织行为与团队建设 (经济学)  [跨门类]
--    团队管理的实践面与理论面
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '团队管理的实践面与理论面'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '团队协作与冲突处理'
  AND s2.`name` = '组织行为与团队建设'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '团队协作与冲突处理'
JOIN `zy_skill` s2 ON s2.`name` = '组织行为与团队建设'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '团队管理的实践面与理论面'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 266. UI/UX 设计 (艺术学) ↔ 跨专业沟通与转译 (管理学)  [跨门类]
--    设计与开发之间的转译是跨专业沟通的典型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '设计与开发之间的转译是跨专业沟通的典型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'UI/UX 设计'
  AND s2.`name` = '跨专业沟通与转译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'UI/UX 设计'
JOIN `zy_skill` s2 ON s2.`name` = '跨专业沟通与转译'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '设计与开发之间的转译是跨专业沟通的典型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 267. 技术文档写作 (工学) ↔ 跨专业沟通与转译 (管理学)  [跨门类]
--    转译结果要靠文档固定下来
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '转译结果要靠文档固定下来'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '技术文档写作'
  AND s2.`name` = '跨专业沟通与转译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '技术文档写作'
JOIN `zy_skill` s2 ON s2.`name` = '跨专业沟通与转译'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '转译结果要靠文档固定下来'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 268. 公文写作与行政事务 (管理学) ↔ 法律文书写作 (法学)  [跨门类]
--    公文与法律文书共享规范写作功底
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '公文与法律文书共享规范写作功底'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '公文写作与行政事务'
  AND s2.`name` = '法律文书写作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '公文写作与行政事务'
JOIN `zy_skill` s2 ON s2.`name` = '法律文书写作'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '公文与法律文书共享规范写作功底'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 269. 商业数据分析 (经济学) ↔ 市场调研与用户洞察 (经济学)
--    调研结论要靠数据分析支撑
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '调研结论要靠数据分析支撑'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '商业数据分析'
  AND s2.`name` = '市场调研与用户洞察'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '商业数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '市场调研与用户洞察'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '调研结论要靠数据分析支撑'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 270. Excel 数据处理与函数 (工学) ↔ 商业数据分析 (经济学)  [跨门类]
--    业务分析日常在 Excel 里完成
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '业务分析日常在 Excel 里完成'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Excel 数据处理与函数'
  AND s2.`name` = '商业数据分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Excel 数据处理与函数'
JOIN `zy_skill` s2 ON s2.`name` = '商业数据分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '业务分析日常在 Excel 里完成'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 271. Pandas 数据处理 (工学) ↔ 商业数据分析 (经济学)  [跨门类]
--    稍大规模的分析转到 pandas 做
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '稍大规模的分析转到 pandas 做'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Pandas 数据处理'
  AND s2.`name` = '商业数据分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Pandas 数据处理'
JOIN `zy_skill` s2 ON s2.`name` = '商业数据分析'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '稍大规模的分析转到 pandas 做'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 272. 商业数据分析 (经济学) ↔ 报表自动化与看板 (理学)  [跨门类]
--    分析的交付形态就是报表与看板
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '分析的交付形态就是报表与看板'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '商业数据分析'
  AND s2.`name` = '报表自动化与看板'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '商业数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '报表自动化与看板'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '分析的交付形态就是报表与看板'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 273. 业务流程优化 (经济学) ↔ 业务流程建模 BPMN (管理学)  [跨门类]
--    流程优化前必须先把流程画清楚
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '流程优化前必须先把流程画清楚'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '业务流程优化'
  AND s2.`name` = '业务流程建模 BPMN'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '业务流程优化'
JOIN `zy_skill` s2 ON s2.`name` = '业务流程建模 BPMN'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '流程优化前必须先把流程画清楚'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 274. 供应链与物流管理 (经济学) ↔ 供应链建模与仿真 (管理学)  [跨门类]
--    供应链管理的问题用建模来量化
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '供应链管理的问题用建模来量化'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '供应链与物流管理'
  AND s2.`name` = '供应链建模与仿真'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '供应链与物流管理'
JOIN `zy_skill` s2 ON s2.`name` = '供应链建模与仿真'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '供应链管理的问题用建模来量化'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 275. 创业与商业模式设计 (经济学) ↔ 商业计划书撰写 (经济学)
--    商业模式最终要写成计划书拿出去
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '商业模式最终要写成计划书拿出去'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '创业与商业模式设计'
  AND s2.`name` = '商业计划书撰写'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '创业与商业模式设计'
JOIN `zy_skill` s2 ON s2.`name` = '商业计划书撰写'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '商业模式最终要写成计划书拿出去'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 276. 创业与商业模式设计 (经济学) ↔ 竞赛备赛与团队组织 (管理学)  [跨门类]
--    创业赛事的备赛过程就是模式打磨过程
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '创业赛事的备赛过程就是模式打磨过程'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '创业与商业模式设计'
  AND s2.`name` = '竞赛备赛与团队组织'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '创业与商业模式设计'
JOIN `zy_skill` s2 ON s2.`name` = '竞赛备赛与团队组织'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '创业赛事的备赛过程就是模式打磨过程'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 277. Excel 财务建模 (经济学) ↔ 财务报表分析 (经济学)
--    报表分析的主要工具就是 Excel 建模
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '报表分析的主要工具就是 Excel 建模'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Excel 财务建模'
  AND s2.`name` = '财务报表分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Excel 财务建模'
JOIN `zy_skill` s2 ON s2.`name` = '财务报表分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '报表分析的主要工具就是 Excel 建模'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 278. 会计实务与记账 (经济学) ↔ 税务申报实务 (经济学)
--    记账与报税是财务岗位的连续动作
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '记账与报税是财务岗位的连续动作'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '会计实务与记账'
  AND s2.`name` = '税务申报实务'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '会计实务与记账'
JOIN `zy_skill` s2 ON s2.`name` = '税务申报实务'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '记账与报税是财务岗位的连续动作'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 279. 审计与内控 (经济学) ↔ 财务报表分析 (经济学)
--    审计以报表为对象
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '审计以报表为对象'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '审计与内控'
  AND s2.`name` = '财务报表分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '审计与内控'
JOIN `zy_skill` s2 ON s2.`name` = '财务报表分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '审计以报表为对象'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 280. Python 金融数据分析 (经济学) ↔ 金融数据分析 (经济学)
--    同一件事的方法侧与工具侧
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '同一件事的方法侧与工具侧'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Python 金融数据分析'
  AND s2.`name` = '金融数据分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Python 金融数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '金融数据分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '同一件事的方法侧与工具侧'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 281. Wind 与金融数据终端 (经济学) ↔ 金融数据分析 (经济学)
--    金融数据的主要来源就是终端
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '金融数据的主要来源就是终端'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Wind 与金融数据终端'
  AND s2.`name` = '金融数据分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Wind 与金融数据终端'
JOIN `zy_skill` s2 ON s2.`name` = '金融数据分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '金融数据的主要来源就是终端'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 282. 投资理财与资产配置 (经济学) ↔ 证券投资分析 (经济学)
--    配置决策建立在证券分析之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '配置决策建立在证券分析之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '投资理财与资产配置'
  AND s2.`name` = '证券投资分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '投资理财与资产配置'
JOIN `zy_skill` s2 ON s2.`name` = '证券投资分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '配置决策建立在证券分析之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 283. Python 金融数据分析 (经济学) ↔ 量化投资策略 (经济学)
--    量化策略必须用编程实现与回测
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '量化策略必须用编程实现与回测'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Python 金融数据分析'
  AND s2.`name` = '量化投资策略'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Python 金融数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '量化投资策略'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '量化策略必须用编程实现与回测'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 284. 量化投资策略 (经济学) ↔ 金融风险管理 (经济学)
--    策略收益与风险度量必须成对评估
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '策略收益与风险度量必须成对评估'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '量化投资策略'
  AND s2.`name` = '金融风险管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '量化投资策略'
JOIN `zy_skill` s2 ON s2.`name` = '金融风险管理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '策略收益与风险度量必须成对评估'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 285. 保险精算基础 (经济学) ↔ 概率论与数理统计 (理学)  [跨门类]
--    精算的数学底座就是概率统计
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '精算的数学底座就是概率统计'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '保险精算基础'
  AND s2.`name` = '概率论与数理统计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '保险精算基础'
JOIN `zy_skill` s2 ON s2.`name` = '概率论与数理统计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '精算的数学底座就是概率统计'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 286. 保险精算基础 (经济学) ↔ 生存分析与可靠性 (理学)  [跨门类]
--    寿险精算的核心方法就是生存分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '寿险精算的核心方法就是生存分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '保险精算基础'
  AND s2.`name` = '生存分析与可靠性'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '保险精算基础'
JOIN `zy_skill` s2 ON s2.`name` = '生存分析与可靠性'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '寿险精算的核心方法就是生存分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 287. 金融风险管理 (经济学) ↔ 银行信贷与风控实务 (经济学)
--    信贷风控是风险管理在银行的具体形态
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '信贷风控是风险管理在银行的具体形态'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '金融风险管理'
  AND s2.`name` = '银行信贷与风控实务'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '金融风险管理'
JOIN `zy_skill` s2 ON s2.`name` = '银行信贷与风控实务'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '信贷风控是风险管理在银行的具体形态'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 288. 微观与宏观经济学 (经济学) ↔ 计量经济学分析 (经济学)
--    经济学实证研究靠计量
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '经济学实证研究靠计量'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '微观与宏观经济学'
  AND s2.`name` = '计量经济学分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '微观与宏观经济学'
JOIN `zy_skill` s2 ON s2.`name` = '计量经济学分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '经济学实证研究靠计量'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 289. 经济学论文与建模 (经济学) ↔ 计量经济学分析 (经济学)
--    计量结果是经济学论文的核心证据
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '计量结果是经济学论文的核心证据'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '经济学论文与建模'
  AND s2.`name` = '计量经济学分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '经济学论文与建模'
JOIN `zy_skill` s2 ON s2.`name` = '计量经济学分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '计量结果是经济学论文的核心证据'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 290. 产业分析与行业研究 (经济学) ↔ 情报分析与竞争情报 (管理学)  [跨门类]
--    产业研究与竞争情报方法高度重叠
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '产业研究与竞争情报方法高度重叠'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '产业分析与行业研究'
  AND s2.`name` = '情报分析与竞争情报'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '产业分析与行业研究'
JOIN `zy_skill` s2 ON s2.`name` = '情报分析与竞争情报'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '产业研究与竞争情报方法高度重叠'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 291. 数字经济与平台经济 (经济学) ↔ 电子商务运营 (经济学)
--    平台经济理论对应电商实操
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '平台经济理论对应电商实操'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数字经济与平台经济'
  AND s2.`name` = '电子商务运营'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数字经济与平台经济'
JOIN `zy_skill` s2 ON s2.`name` = '电子商务运营'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '平台经济理论对应电商实操'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 292. 方差分析与实验设计 (理学) ↔ 质量管理与六西格玛 (经济学)  [跨门类]
--    六西格玛的统计工具来自实验设计
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '六西格玛的统计工具来自实验设计'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '方差分析与实验设计'
  AND s2.`name` = '质量管理与六西格玛'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '方差分析与实验设计'
JOIN `zy_skill` s2 ON s2.`name` = '质量管理与六西格玛'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '六西格玛的统计工具来自实验设计'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 293. 知识产权法实务 (法学) ↔ 知识产权申请实务 (法学)
--    法律实务与申请实务是一条链路两端
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '法律实务与申请实务是一条链路两端'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '知识产权法实务'
  AND s2.`name` = '知识产权申请实务'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '知识产权法实务'
JOIN `zy_skill` s2 ON s2.`name` = '知识产权申请实务'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '法律实务与申请实务是一条链路两端'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 294. 合同法与合同审查 (法学) ↔ 合同起草与风险条款 (法学)
--    审查与起草是同一能力的两侧
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '审查与起草是同一能力的两侧'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '合同法与合同审查'
  AND s2.`name` = '合同起草与风险条款'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '合同法与合同审查'
JOIN `zy_skill` s2 ON s2.`name` = '合同起草与风险条款'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '审查与起草是同一能力的两侧'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 295. 模拟法庭与辩论 (法学) ↔ 法律文书写作 (法学)
--    文书与庭辩是法律实务的两项基本功
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '文书与庭辩是法律实务的两项基本功'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '模拟法庭与辩论'
  AND s2.`name` = '法律文书写作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '模拟法庭与辩论'
JOIN `zy_skill` s2 ON s2.`name` = '法律文书写作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '文书与庭辩是法律实务的两项基本功'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 296. 模拟法庭与辩论 (法学) ↔ 演讲与公开表达 (管理学)  [跨门类]
--    庭辩能力本质是公开表达训练
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '庭辩能力本质是公开表达训练'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '模拟法庭与辩论'
  AND s2.`name` = '演讲与公开表达'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '模拟法庭与辩论'
JOIN `zy_skill` s2 ON s2.`name` = '演讲与公开表达'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '庭辩能力本质是公开表达训练'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 297. 演讲与公开表达 (管理学) ↔ 答辩与面试技巧 (管理学)
--    答辩与面试都是结构化表达场景
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '答辩与面试都是结构化表达场景'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '演讲与公开表达'
  AND s2.`name` = '答辩与面试技巧'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '演讲与公开表达'
JOIN `zy_skill` s2 ON s2.`name` = '答辩与面试技巧'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '答辩与面试都是结构化表达场景'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 298. 答辩与面试技巧 (管理学) ↔ 简历撰写与优化 (管理学)
--    求职链路上面试与简历必须配套
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '求职链路上面试与简历必须配套'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '答辩与面试技巧'
  AND s2.`name` = '简历撰写与优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '答辩与面试技巧'
JOIN `zy_skill` s2 ON s2.`name` = '简历撰写与优化'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '求职链路上面试与简历必须配套'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 299. 社会调查与统计分析 (管理学) ↔ 问卷调查与数据编码 (理学)  [跨门类]
--    调查工具的设计决定数据质量
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '调查工具的设计决定数据质量'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '社会调查与统计分析'
  AND s2.`name` = '问卷调查与数据编码'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '社会调查与统计分析'
JOIN `zy_skill` s2 ON s2.`name` = '问卷调查与数据编码'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '调查工具的设计决定数据质量'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 300. 公共政策分析 (管理学) ↔ 政府绩效评估 (管理学)
--    政策效果要靠绩效评估检验
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '政策效果要靠绩效评估检验'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '公共政策分析'
  AND s2.`name` = '政府绩效评估'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '公共政策分析'
JOIN `zy_skill` s2 ON s2.`name` = '政府绩效评估'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '政策效果要靠绩效评估检验'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 301. 应急管理与预案编制 (管理学) ↔ 突发公共卫生事件处置 (医学)  [跨门类]
--    公共卫生应急是应急预案的专门场景
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '公共卫生应急是应急预案的专门场景'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '应急管理与预案编制'
  AND s2.`name` = '突发公共卫生事件处置'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '应急管理与预案编制'
JOIN `zy_skill` s2 ON s2.`name` = '突发公共卫生事件处置'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '公共卫生应急是应急预案的专门场景'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 302. 社区治理与志愿服务 (管理学) ↔ 非营利组织管理 (管理学)
--    社区服务多由社会组织承接
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '社区服务多由社会组织承接'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '社区治理与志愿服务'
  AND s2.`name` = '非营利组织管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '社区治理与志愿服务'
JOIN `zy_skill` s2 ON s2.`name` = '非营利组织管理'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '社区服务多由社会组织承接'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 303. 公共政策分析 (管理学) ↔ 社会保障政策分析 (管理学)
--    社保政策是公共政策的一个领域
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '社保政策是公共政策的一个领域'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '公共政策分析'
  AND s2.`name` = '社会保障政策分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '公共政策分析'
JOIN `zy_skill` s2 ON s2.`name` = '社会保障政策分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '社保政策是公共政策的一个领域'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 304. 信息安全与隐私保护意识 (管理学) ↔ 数据合规与个人信息保护 (法学)  [跨门类]
--    合规要求最终落到技术防护措施
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '合规要求最终落到技术防护措施'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '信息安全与隐私保护意识'
  AND s2.`name` = '数据合规与个人信息保护'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '信息安全与隐私保护意识'
JOIN `zy_skill` s2 ON s2.`name` = '数据合规与个人信息保护'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '合规要求最终落到技术防护措施'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 305. 数据合规与个人信息保护 (法学) ↔ 科技哲学与伦理 (哲学)  [跨门类]
--    数据伦理是科技伦理的核心议题
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '数据伦理是科技伦理的核心议题'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据合规与个人信息保护'
  AND s2.`name` = '科技哲学与伦理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据合规与个人信息保护'
JOIN `zy_skill` s2 ON s2.`name` = '科技哲学与伦理'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '数据伦理是科技伦理的核心议题'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 306. Premiere 视频剪辑 (艺术学) ↔ 视频剪辑 (艺术学)
--    剪辑能力与剪辑工具是同一件事两侧
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '剪辑能力与剪辑工具是同一件事两侧'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Premiere 视频剪辑'
  AND s2.`name` = '视频剪辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Premiere 视频剪辑'
JOIN `zy_skill` s2 ON s2.`name` = '视频剪辑'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '剪辑能力与剪辑工具是同一件事两侧'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 307. 剪映快速剪辑 (艺术学) ↔ 视频剪辑 (艺术学)
--    轻量剪辑用剪映完成
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '轻量剪辑用剪映完成'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '剪映快速剪辑'
  AND s2.`name` = '视频剪辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '剪映快速剪辑'
JOIN `zy_skill` s2 ON s2.`name` = '视频剪辑'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '轻量剪辑用剪映完成'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 308. 影视剪辑节奏把控 (艺术学) ↔ 视频剪辑 (艺术学)
--    节奏感是剪辑的核心判断力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '节奏感是剪辑的核心判断力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '影视剪辑节奏把控'
  AND s2.`name` = '视频剪辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '影视剪辑节奏把控'
JOIN `zy_skill` s2 ON s2.`name` = '视频剪辑'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '节奏感是剪辑的核心判断力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 309. 视频调色与色彩管理 (艺术学) ↔ 达芬奇调色 (艺术学)
--    调色能力的专业工具就是达芬奇
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '调色能力的专业工具就是达芬奇'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '视频调色与色彩管理'
  AND s2.`name` = '达芬奇调色'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '视频调色与色彩管理'
JOIN `zy_skill` s2 ON s2.`name` = '达芬奇调色'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '调色能力的专业工具就是达芬奇'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 310. 色彩管理与屏幕校准 (艺术学) ↔ 视频调色与色彩管理 (艺术学)
--    调色前提是屏幕色彩可信
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '调色前提是屏幕色彩可信'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '色彩管理与屏幕校准'
  AND s2.`name` = '视频调色与色彩管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '色彩管理与屏幕校准'
JOIN `zy_skill` s2 ON s2.`name` = '视频调色与色彩管理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '调色前提是屏幕色彩可信'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 311. 色彩理论与配色 (艺术学) ↔ 色彩管理与屏幕校准 (艺术学)
--    配色理论落地需要准确的色彩环境
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '配色理论落地需要准确的色彩环境'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '色彩理论与配色'
  AND s2.`name` = '色彩管理与屏幕校准'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '色彩理论与配色'
JOIN `zy_skill` s2 ON s2.`name` = '色彩管理与屏幕校准'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '配色理论落地需要准确的色彩环境'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 312. 色彩理论与配色 (艺术学) ↔ 视觉传达与版式编辑 (文学)  [跨门类]
--    配色与版式是视觉传达的两根支柱
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '配色与版式是视觉传达的两根支柱'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '色彩理论与配色'
  AND s2.`name` = '视觉传达与版式编辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '色彩理论与配色'
JOIN `zy_skill` s2 ON s2.`name` = '视觉传达与版式编辑'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '配色与版式是视觉传达的两根支柱'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 313. After Effects 动效制作 (艺术学) ↔ 影视特效与合成 (艺术学)
--    特效合成主要靠 AE 完成
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '特效合成主要靠 AE 完成'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'After Effects 动效制作'
  AND s2.`name` = '影视特效与合成'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'After Effects 动效制作'
JOIN `zy_skill` s2 ON s2.`name` = '影视特效与合成'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '特效合成主要靠 AE 完成'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 314. Blender 三维创作 (艺术学) ↔ 三维动画与建模 (艺术学)
--    三维动画的常用工具是 Blender
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '三维动画的常用工具是 Blender'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Blender 三维创作'
  AND s2.`name` = '三维动画与建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Blender 三维创作'
JOIN `zy_skill` s2 ON s2.`name` = '三维动画与建模'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '三维动画的常用工具是 Blender'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 315. C4D 三维动效 (艺术学) ↔ 三维动画与建模 (艺术学)
--    商业三维动效常用 C4D
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '商业三维动效常用 C4D'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'C4D 三维动效'
  AND s2.`name` = '三维动画与建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'C4D 三维动效'
JOIN `zy_skill` s2 ON s2.`name` = '三维动画与建模'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '商业三维动效常用 C4D'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 316. 剧本创作与分镜 (艺术学) ↔ 动画分镜与节奏 (艺术学)
--    分镜是剧本到影像的中间产物
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '分镜是剧本到影像的中间产物'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '剧本创作与分镜'
  AND s2.`name` = '动画分镜与节奏'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '剧本创作与分镜'
JOIN `zy_skill` s2 ON s2.`name` = '动画分镜与节奏'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '分镜是剧本到影像的中间产物'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 317. 剧本创作与分镜 (艺术学) ↔ 短视频选题策划 (艺术学)
--    短视频同样需要脚本与分镜
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '短视频同样需要脚本与分镜'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '剧本创作与分镜'
  AND s2.`name` = '短视频选题策划'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '剧本创作与分镜'
JOIN `zy_skill` s2 ON s2.`name` = '短视频选题策划'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '短视频同样需要脚本与分镜'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 318. 短视频创作与运营 (艺术学) ↔ 短视频选题策划 (艺术学)
--    选题是短视频运营的起点
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '选题是短视频运营的起点'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '短视频创作与运营'
  AND s2.`name` = '短视频选题策划'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '短视频创作与运营'
JOIN `zy_skill` s2 ON s2.`name` = '短视频选题策划'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '选题是短视频运营的起点'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 319. 短视频创作与运营 (艺术学) ↔ 视频号内容制作 (工学)  [跨门类]
--    多平台运营是同一套内容能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '多平台运营是同一套内容能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '短视频创作与运营'
  AND s2.`name` = '视频号内容制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '短视频创作与运营'
JOIN `zy_skill` s2 ON s2.`name` = '视频号内容制作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '多平台运营是同一套内容能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 320. 公众号排版与运营 (工学) ↔ 视频号内容制作 (工学)
--    图文与视频账号通常一起运营
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '图文与视频账号通常一起运营'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '公众号排版与运营'
  AND s2.`name` = '视频号内容制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '公众号排版与运营'
JOIN `zy_skill` s2 ON s2.`name` = '视频号内容制作'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '图文与视频账号通常一起运营'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 321. 公众号排版与运营 (工学) ↔ 版式设计与排版 (艺术学)  [跨门类]
--    推文排版依赖版式设计功底
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '推文排版依赖版式设计功底'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '公众号排版与运营'
  AND s2.`name` = '版式设计与排版'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '公众号排版与运营'
JOIN `zy_skill` s2 ON s2.`name` = '版式设计与排版'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '推文排版依赖版式设计功底'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 322. 小红书内容运营 (工学) ↔ 短视频创作与运营 (艺术学)  [跨门类]
--    图文与短视频运营方法互相迁移
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '图文与短视频运营方法互相迁移'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '小红书内容运营'
  AND s2.`name` = '短视频创作与运营'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '小红书内容运营'
JOIN `zy_skill` s2 ON s2.`name` = '短视频创作与运营'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '图文与短视频运营方法互相迁移'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 323. B站视频制作与运营 (工学) ↔ 视频剪辑 (艺术学)  [跨门类]
--    中长视频制作直接依赖剪辑能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '中长视频制作直接依赖剪辑能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'B站视频制作与运营'
  AND s2.`name` = '视频剪辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'B站视频制作与运营'
JOIN `zy_skill` s2 ON s2.`name` = '视频剪辑'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '中长视频制作直接依赖剪辑能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 324. 公众号排版与运营 (工学) ↔ 搜索引擎优化 SEO (工学)
--    内容运营与搜索流量优化常配合做
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '内容运营与搜索流量优化常配合做'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '公众号排版与运营'
  AND s2.`name` = '搜索引擎优化 SEO'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '公众号排版与运营'
JOIN `zy_skill` s2 ON s2.`name` = '搜索引擎优化 SEO'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '内容运营与搜索流量优化常配合做'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 325. 摄影摄像基础 (艺术学) ↔ 新闻摄影与图片编辑 (文学)  [跨门类]
--    新闻摄影是摄影的专门应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '新闻摄影是摄影的专门应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '摄影摄像基础'
  AND s2.`name` = '新闻摄影与图片编辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '摄影摄像基础'
JOIN `zy_skill` s2 ON s2.`name` = '新闻摄影与图片编辑'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '新闻摄影是摄影的专门应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 326. Photoshop 图像处理 (艺术学) ↔ 摄影摄像基础 (艺术学)
--    摄影后期离不开图像处理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '摄影后期离不开图像处理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Photoshop 图像处理'
  AND s2.`name` = '摄影摄像基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Photoshop 图像处理'
JOIN `zy_skill` s2 ON s2.`name` = '摄影摄像基础'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '摄影后期离不开图像处理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 327. Photoshop 图像处理 (艺术学) ↔ 平面设计基础 (艺术学)
--    平面设计的主要生产工具就是 PS
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '平面设计的主要生产工具就是 PS'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Photoshop 图像处理'
  AND s2.`name` = '平面设计基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Photoshop 图像处理'
JOIN `zy_skill` s2 ON s2.`name` = '平面设计基础'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '平面设计的主要生产工具就是 PS'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 328. Illustrator 矢量绘图 (艺术学) ↔ 平面设计基础 (艺术学)
--    矢量图形是平面设计的另一条主线
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '矢量图形是平面设计的另一条主线'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Illustrator 矢量绘图'
  AND s2.`name` = '平面设计基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Illustrator 矢量绘图'
JOIN `zy_skill` s2 ON s2.`name` = '平面设计基础'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '矢量图形是平面设计的另一条主线'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 329. InDesign 排版设计 (艺术学) ↔ 印刷工艺与落地 (艺术学)
--    排版必须按印刷工艺来设置
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '排版必须按印刷工艺来设置'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'InDesign 排版设计'
  AND s2.`name` = '印刷工艺与落地'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'InDesign 排版设计'
JOIN `zy_skill` s2 ON s2.`name` = '印刷工艺与落地'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '排版必须按印刷工艺来设置'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 330. 版式设计与排版 (艺术学) ↔ 视觉传达与版式编辑 (文学)  [跨门类]
--    版式能力在设计学与新闻学两侧
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '版式能力在设计学与新闻学两侧'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '版式设计与排版'
  AND s2.`name` = '视觉传达与版式编辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '版式设计与排版'
JOIN `zy_skill` s2 ON s2.`name` = '视觉传达与版式编辑'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '版式能力在设计学与新闻学两侧'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 331. 二维码与物料制作 (艺术学) ↔ 平面设计基础 (艺术学)
--    宣传物料制作是平面设计能力的常见落地场景
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '宣传物料制作是平面设计能力的常见落地场景'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '二维码与物料制作'
  AND s2.`name` = '平面设计基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '二维码与物料制作'
JOIN `zy_skill` s2 ON s2.`name` = '平面设计基础'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '宣传物料制作是平面设计能力的常见落地场景'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 332. 包装设计 (艺术学) ↔ 品牌视觉与 VI 设计 (艺术学)
--    包装是品牌视觉的实物载体
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '包装是品牌视觉的实物载体'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '包装设计'
  AND s2.`name` = '品牌视觉与 VI 设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '包装设计'
JOIN `zy_skill` s2 ON s2.`name` = '品牌视觉与 VI 设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '包装是品牌视觉的实物载体'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 333. 品牌视觉与 VI 设计 (艺术学) ↔ 营销策划与推广 (经济学)  [跨门类]
--    品牌视觉服务于营销传播
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '品牌视觉服务于营销传播'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '品牌视觉与 VI 设计'
  AND s2.`name` = '营销策划与推广'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '品牌视觉与 VI 设计'
JOIN `zy_skill` s2 ON s2.`name` = '营销策划与推广'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '品牌视觉服务于营销传播'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 334. Procreate 数字绘画 (艺术学) ↔ 插画与手绘表达 (艺术学)
--    数字插画的主要工具是 Procreate
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '数字插画的主要工具是 Procreate'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Procreate 数字绘画'
  AND s2.`name` = '插画与手绘表达'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Procreate 数字绘画'
JOIN `zy_skill` s2 ON s2.`name` = '插画与手绘表达'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '数字插画的主要工具是 Procreate'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 335. AI 绘画与图像生成 (工学) ↔ 插画与手绘表达 (艺术学)  [跨门类]
--    AI 出图已进入插画工作流
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, 'AI 出图已进入插画工作流'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'AI 绘画与图像生成'
  AND s2.`name` = '插画与手绘表达'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'AI 绘画与图像生成'
JOIN `zy_skill` s2 ON s2.`name` = '插画与手绘表达'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = 'AI 出图已进入插画工作流'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 336. 字体设计与选择 (艺术学) ↔ 版式设计与排版 (艺术学)
--    字体选择是版式设计的核心决策
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '字体选择是版式设计的核心决策'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '字体设计与选择'
  AND s2.`name` = '版式设计与排版'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '字体设计与选择'
JOIN `zy_skill` s2 ON s2.`name` = '版式设计与排版'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '字体选择是版式设计的核心决策'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 337. 三维产品渲染 (艺术学) ↔ 虚拟展陈设计 (艺术学)
--    展陈效果图依赖渲染能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '展陈效果图依赖渲染能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '三维产品渲染'
  AND s2.`name` = '虚拟展陈设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '三维产品渲染'
JOIN `zy_skill` s2 ON s2.`name` = '虚拟展陈设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '展陈效果图依赖渲染能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 338. 室内空间设计 (工学) ↔ 虚拟展陈设计 (艺术学)  [跨门类]
--    室内与展陈空间设计方法高度相通
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '室内与展陈空间设计方法高度相通'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '室内空间设计'
  AND s2.`name` = '虚拟展陈设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '室内空间设计'
JOIN `zy_skill` s2 ON s2.`name` = '虚拟展陈设计'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '室内与展陈空间设计方法高度相通'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 339. 服务设计 (艺术学) ↔ 设计调研与竞品分析 (艺术学)
--    服务设计以调研洞察为前提
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '服务设计以调研洞察为前提'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '服务设计'
  AND s2.`name` = '设计调研与竞品分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '服务设计'
JOIN `zy_skill` s2 ON s2.`name` = '设计调研与竞品分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '服务设计以调研洞察为前提'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 340. 舞台灯光设计 (艺术学) ↔ 舞台表演与形体 (艺术学)
--    灯光与表演共同构成舞台效果
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '灯光与表演共同构成舞台效果'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '舞台灯光设计'
  AND s2.`name` = '舞台表演与形体'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '舞台灯光设计'
JOIN `zy_skill` s2 ON s2.`name` = '舞台表演与形体'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '灯光与表演共同构成舞台效果'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 341. 舞台化妆与造型 (艺术学) ↔ 舞台表演与形体 (艺术学)
--    造型是舞台呈现的一部分
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '造型是舞台呈现的一部分'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '舞台化妆与造型'
  AND s2.`name` = '舞台表演与形体'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '舞台化妆与造型'
JOIN `zy_skill` s2 ON s2.`name` = '舞台表演与形体'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '造型是舞台呈现的一部分'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 342. 合唱指挥与排练 (艺术学) ↔ 舞蹈编创与排练 (艺术学)
--    编创与排练组织是表演类工作的共性
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '编创与排练组织是表演类工作的共性'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '合唱指挥与排练'
  AND s2.`name` = '舞蹈编创与排练'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '合唱指挥与排练'
JOIN `zy_skill` s2 ON s2.`name` = '舞蹈编创与排练'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '编创与排练组织是表演类工作的共性'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 343. 乐器演奏 (艺术学) ↔ 乐理与视唱练耳 (艺术学)
--    演奏水平受乐理与听觉训练制约
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '演奏水平受乐理与听觉训练制约'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '乐器演奏'
  AND s2.`name` = '乐理与视唱练耳'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '乐器演奏'
JOIN `zy_skill` s2 ON s2.`name` = '乐理与视唱练耳'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '演奏水平受乐理与听觉训练制约'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 344. Logic Pro 音乐制作 (艺术学) ↔ 编曲与音乐制作 (艺术学)
--    编曲的主要生产工具是 DAW
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '编曲的主要生产工具是 DAW'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Logic Pro 音乐制作'
  AND s2.`name` = '编曲与音乐制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Logic Pro 音乐制作'
JOIN `zy_skill` s2 ON s2.`name` = '编曲与音乐制作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '编曲的主要生产工具是 DAW'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 345. FL Studio 编曲 (艺术学) ↔ 编曲与音乐制作 (艺术学)
--    FL Studio 是电子编曲的常用工具
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'FL Studio 是电子编曲的常用工具'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'FL Studio 编曲'
  AND s2.`name` = '编曲与音乐制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'FL Studio 编曲'
JOIN `zy_skill` s2 ON s2.`name` = '编曲与音乐制作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'FL Studio 是电子编曲的常用工具'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 346. 音乐录音与混音 (艺术学) ↔ 音频后期与配乐 (艺术学)
--    录音混音与后期配乐是同一流程
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '录音混音与后期配乐是同一流程'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '音乐录音与混音'
  AND s2.`name` = '音频后期与配乐'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '音乐录音与混音'
JOIN `zy_skill` s2 ON s2.`name` = '音频后期与配乐'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '录音混音与后期配乐是同一流程'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 347. 音乐录音与混音 (艺术学) ↔ 音频处理 Audition (艺术学)
--    录音混音的主要工具就是音频工作站
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '录音混音的主要工具就是音频工作站'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '音乐录音与混音'
  AND s2.`name` = '音频处理 Audition'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '音乐录音与混音'
JOIN `zy_skill` s2 ON s2.`name` = '音频处理 Audition'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '录音混音的主要工具就是音频工作站'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 348. 音频后期与配乐 (艺术学) ↔ 音频处理 Audition (艺术学)
--    音频后期常用 Audition 完成
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '音频后期常用 Audition 完成'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '音频后期与配乐'
  AND s2.`name` = '音频处理 Audition'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '音频后期与配乐'
JOIN `zy_skill` s2 ON s2.`name` = '音频处理 Audition'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '音频后期常用 Audition 完成'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 349. After Effects 动效制作 (艺术学) ↔ 栏目包装与片头设计 (艺术学)
--    片头包装主要靠 AE 制作
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '片头包装主要靠 AE 制作'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'After Effects 动效制作'
  AND s2.`name` = '栏目包装与片头设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'After Effects 动效制作'
JOIN `zy_skill` s2 ON s2.`name` = '栏目包装与片头设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '片头包装主要靠 AE 制作'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 350. OBS 直播推流 (艺术学) ↔ 直播技术导播 (艺术学)
--    推流与导播是直播的两端
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '推流与导播是直播的两端'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'OBS 直播推流'
  AND s2.`name` = '直播技术导播'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'OBS 直播推流'
JOIN `zy_skill` s2 ON s2.`name` = '直播技术导播'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '推流与导播是直播的两端'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 351. 影视特效与合成 (艺术学) ↔ 虚拟演播与绿幕抠像 (艺术学)
--    抠像是合成的基础操作
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '抠像是合成的基础操作'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '影视特效与合成'
  AND s2.`name` = '虚拟演播与绿幕抠像'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '影视特效与合成'
JOIN `zy_skill` s2 ON s2.`name` = '虚拟演播与绿幕抠像'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '抠像是合成的基础操作'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 352. 影视录音与同期声 (艺术学) ↔ 音频后期与配乐 (艺术学)
--    同期声要进后期处理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '同期声要进后期处理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '影视录音与同期声'
  AND s2.`name` = '音频后期与配乐'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '影视录音与同期声'
JOIN `zy_skill` s2 ON s2.`name` = '音频后期与配乐'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '同期声要进后期处理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 353. 深度报道与调查 (文学) ↔ 纪录片拍摄与采访 (艺术学)  [跨门类]
--    纪录片与调查报道方法论相通
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '纪录片与调查报道方法论相通'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '深度报道与调查'
  AND s2.`name` = '纪录片拍摄与采访'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '深度报道与调查'
JOIN `zy_skill` s2 ON s2.`name` = '纪录片拍摄与采访'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '纪录片与调查报道方法论相通'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 354. 口述历史与纪录片 (历史学) ↔ 纪录片拍摄与采访 (艺术学)  [跨门类]
--    口述史项目普遍以纪录片形式呈现
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '口述史项目普遍以纪录片形式呈现'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '口述历史与纪录片'
  AND s2.`name` = '纪录片拍摄与采访'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '口述历史与纪录片'
JOIN `zy_skill` s2 ON s2.`name` = '纪录片拍摄与采访'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '口述史项目普遍以纪录片形式呈现'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 355. 影视制片与统筹 (艺术学) ↔ 项目管理与进度把控 (工学)  [跨门类]
--    制片统筹本质是项目管理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '制片统筹本质是项目管理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '影视制片与统筹'
  AND s2.`name` = '项目管理与进度把控'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '影视制片与统筹'
JOIN `zy_skill` s2 ON s2.`name` = '项目管理与进度把控'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '制片统筹本质是项目管理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 356. 传播学理论与研究方法 (文学) ↔ 舆情分析与监测 (文学)
--    舆情研究建立在传播学方法上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '舆情研究建立在传播学方法上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '传播学理论与研究方法'
  AND s2.`name` = '舆情分析与监测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '传播学理论与研究方法'
JOIN `zy_skill` s2 ON s2.`name` = '舆情分析与监测'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '舆情研究建立在传播学方法上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 357. 广告创意与策划 (文学) ↔ 营销策划与推广 (经济学)  [跨门类]
--    广告是营销传播的执行环节
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '广告是营销传播的执行环节'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '广告创意与策划'
  AND s2.`name` = '营销策划与推广'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '广告创意与策划'
JOIN `zy_skill` s2 ON s2.`name` = '营销策划与推广'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '广告是营销传播的执行环节'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 358. Photoshop 图像处理 (艺术学) ↔ 广告创意与策划 (文学)  [跨门类]
--    广告物料制作依赖设计工具
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '广告物料制作依赖设计工具'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Photoshop 图像处理'
  AND s2.`name` = '广告创意与策划'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Photoshop 图像处理'
JOIN `zy_skill` s2 ON s2.`name` = '广告创意与策划'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '广告物料制作依赖设计工具'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 359. 媒体融合与全媒体运营 (文学) ↔ 数据新闻与可视化 (文学)
--    全媒体运营需要数据叙事能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '全媒体运营需要数据叙事能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '媒体融合与全媒体运营'
  AND s2.`name` = '数据新闻与可视化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '媒体融合与全媒体运营'
JOIN `zy_skill` s2 ON s2.`name` = '数据新闻与可视化'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '全媒体运营需要数据叙事能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 360. 新闻采访与写作 (文学) ↔ 深度报道与调查 (文学)
--    深度报道是采访写作的高阶形态
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '深度报道是采访写作的高阶形态'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '新闻采访与写作'
  AND s2.`name` = '深度报道与调查'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '新闻采访与写作'
JOIN `zy_skill` s2 ON s2.`name` = '深度报道与调查'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '深度报道是采访写作的高阶形态'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 361. 播音主持与配音 (文学) ↔ 音频处理 Audition (艺术学)  [跨门类]
--    播音作品需要音频后期处理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '播音作品需要音频后期处理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '播音主持与配音'
  AND s2.`name` = '音频处理 Audition'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '播音主持与配音'
JOIN `zy_skill` s2 ON s2.`name` = '音频处理 Audition'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '播音作品需要音频后期处理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 362. 播音主持与配音 (文学) ↔ 舞台表演与形体 (艺术学)  [跨门类]
--    台词与形体的基本功在两个场景通用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '台词与形体的基本功在两个场景通用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '播音主持与配音'
  AND s2.`name` = '舞台表演与形体'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '播音主持与配音'
JOIN `zy_skill` s2 ON s2.`name` = '舞台表演与形体'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '台词与形体的基本功在两个场景通用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 363. 美学与艺术哲学 (哲学) ↔ 美术史与作品鉴赏 (艺术学)  [跨门类]
--    理论框架用于解释具体作品
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '理论框架用于解释具体作品'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '美学与艺术哲学'
  AND s2.`name` = '美术史与作品鉴赏'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '美学与艺术哲学'
JOIN `zy_skill` s2 ON s2.`name` = '美术史与作品鉴赏'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '理论框架用于解释具体作品'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 364. 文物鉴赏与断代 (历史学) ↔ 美术史与作品鉴赏 (艺术学)  [跨门类]
--    美术史功底是文物断代的前提
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '美术史功底是文物断代的前提'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '文物鉴赏与断代'
  AND s2.`name` = '美术史与作品鉴赏'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '文物鉴赏与断代'
JOIN `zy_skill` s2 ON s2.`name` = '美术史与作品鉴赏'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '美术史功底是文物断代的前提'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 365. AI 绘画与图像生成 (工学) ↔ 美术史与作品鉴赏 (艺术学)  [跨门类]
--    生成式图像的审美判断依赖美术史素养
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '生成式图像的审美判断依赖美术史素养'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'AI 绘画与图像生成'
  AND s2.`name` = '美术史与作品鉴赏'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'AI 绘画与图像生成'
JOIN `zy_skill` s2 ON s2.`name` = '美术史与作品鉴赏'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '生成式图像的审美判断依赖美术史素养'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 366. 历史文献数字化 (历史学) ↔ 数字人文与文本挖掘 (管理学)  [跨门类]
--    文献数字化是数字人文的数据基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '文献数字化是数字人文的数据基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '历史文献数字化'
  AND s2.`name` = '数字人文与文本挖掘'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '历史文献数字化'
JOIN `zy_skill` s2 ON s2.`name` = '数字人文与文本挖掘'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '文献数字化是数字人文的数据基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 367. 信息组织与元数据 (管理学) ↔ 档案整理与数字化 (管理学)
--    档案著录依赖元数据标准
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '档案著录依赖元数据标准'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '信息组织与元数据'
  AND s2.`name` = '档案整理与数字化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '信息组织与元数据'
JOIN `zy_skill` s2 ON s2.`name` = '档案整理与数字化'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '档案著录依赖元数据标准'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 368. 信息组织与元数据 (管理学) ↔ 文献检索与信息素养 (管理学)
--    信息组织决定了检索的可能性
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '信息组织决定了检索的可能性'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '信息组织与元数据'
  AND s2.`name` = '文献检索与信息素养'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '信息组织与元数据'
JOIN `zy_skill` s2 ON s2.`name` = '文献检索与信息素养'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '信息组织决定了检索的可能性'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 369. 情报分析与竞争情报 (管理学) ↔ 舆情分析与监测 (文学)  [跨门类]
--    开源情报大量来自舆情数据
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '开源情报大量来自舆情数据'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '情报分析与竞争情报'
  AND s2.`name` = '舆情分析与监测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '情报分析与竞争情报'
JOIN `zy_skill` s2 ON s2.`name` = '舆情分析与监测'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '开源情报大量来自舆情数据'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 370. 学术出版与开放获取 (管理学) ↔ 学术引用格式规范 (文学)  [跨门类]
--    出版流程要求符合引注规范
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '出版流程要求符合引注规范'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '学术出版与开放获取'
  AND s2.`name` = '学术引用格式规范'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '学术出版与开放获取'
JOIN `zy_skill` s2 ON s2.`name` = '学术引用格式规范'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '出版流程要求符合引注规范'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 371. 博物馆展陈设计 (历史学) ↔ 虚拟展陈设计 (艺术学)  [跨门类]
--    数字展陈是博物馆陈列的新形态
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '数字展陈是博物馆陈列的新形态'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '博物馆展陈设计'
  AND s2.`name` = '虚拟展陈设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '博物馆展陈设计'
JOIN `zy_skill` s2 ON s2.`name` = '虚拟展陈设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '数字展陈是博物馆陈列的新形态'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 372. 文物保护技术 (历史学) ↔ 文物修复与保护 (历史学)
--    保护技术是修复作业的方法基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '保护技术是修复作业的方法基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '文物保护技术'
  AND s2.`name` = '文物修复与保护'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '文物保护技术'
JOIN `zy_skill` s2 ON s2.`name` = '文物修复与保护'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '保护技术是修复作业的方法基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 373. 文物保护技术 (历史学) ↔ 材料失效分析 (工学)  [跨门类]
--    文物劣化机理分析借用材料失效方法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '文物劣化机理分析借用材料失效方法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '文物保护技术'
  AND s2.`name` = '材料失效分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '文物保护技术'
JOIN `zy_skill` s2 ON s2.`name` = '材料失效分析'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '文物劣化机理分析借用材料失效方法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 374. 摄影测量与三维重建 (工学) ↔ 考古绘图与摄影 (历史学)  [跨门类]
--    器物与遗址记录已普遍使用三维重建
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '器物与遗址记录已普遍使用三维重建'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '摄影测量与三维重建'
  AND s2.`name` = '考古绘图与摄影'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '摄影测量与三维重建'
JOIN `zy_skill` s2 ON s2.`name` = '考古绘图与摄影'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '器物与遗址记录已普遍使用三维重建'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 375. 考古绘图与摄影 (历史学) ↔ 遥感影像解译 (理学)  [跨门类]
--    遗址遥感判读为考古调查提供线索
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '遗址遥感判读为考古调查提供线索'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '考古绘图与摄影'
  AND s2.`name` = '遥感影像解译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '考古绘图与摄影'
JOIN `zy_skill` s2 ON s2.`name` = '遥感影像解译'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '遗址遥感判读为考古调查提供线索'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 376. 器物描述与类型学 (历史学) ↔ 档案整理与数字化 (管理学)  [跨门类]
--    器物记录与档案整理方法相通
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '器物记录与档案整理方法相通'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '器物描述与类型学'
  AND s2.`name` = '档案整理与数字化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '器物描述与类型学'
JOIN `zy_skill` s2 ON s2.`name` = '档案整理与数字化'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '器物记录与档案整理方法相通'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 377. 史料整理与考据 (历史学) ↔ 数字人文与文本挖掘 (管理学)  [跨门类]
--    史料数字化后可做文本挖掘
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '史料数字化后可做文本挖掘'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '史料整理与考据'
  AND s2.`name` = '数字人文与文本挖掘'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '史料整理与考据'
JOIN `zy_skill` s2 ON s2.`name` = '数字人文与文本挖掘'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '史料数字化后可做文本挖掘'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 378. 中国近代史研究 (历史学) ↔ 史料整理与考据 (历史学)
--    近代史研究以史料考据为方法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '近代史研究以史料考据为方法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '中国近代史研究'
  AND s2.`name` = '史料整理与考据'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '中国近代史研究'
JOIN `zy_skill` s2 ON s2.`name` = '史料整理与考据'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '近代史研究以史料考据为方法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 379. 口述史采访与整理 (历史学) ↔ 深度报道与调查 (文学)  [跨门类]
--    口述史与调查报道都依赖访谈方法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '口述史与调查报道都依赖访谈方法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '口述史采访与整理'
  AND s2.`name` = '深度报道与调查'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '口述史采访与整理'
JOIN `zy_skill` s2 ON s2.`name` = '深度报道与调查'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '口述史与调查报道都依赖访谈方法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 380. 历史地理与地图解读 (历史学) ↔ 地方志与族谱研究 (历史学)
--    方志研究大量使用历史地图
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '方志研究大量使用历史地图'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '历史地理与地图解读'
  AND s2.`name` = '地方志与族谱研究'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '历史地理与地图解读'
JOIN `zy_skill` s2 ON s2.`name` = '地方志与族谱研究'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '方志研究大量使用历史地图'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 381. 中国哲学与儒家思想 (哲学) ↔ 哲学论文写作 (哲学)
--    思想研究最终以论文形式产出
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '思想研究最终以论文形式产出'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '中国哲学与儒家思想'
  AND s2.`name` = '哲学论文写作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '中国哲学与儒家思想'
JOIN `zy_skill` s2 ON s2.`name` = '哲学论文写作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '思想研究最终以论文形式产出'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 382. 哲学论文写作 (哲学) ↔ 西方哲学与德国古典 (哲学)
--    哲学研究的产出形态就是论文
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '哲学研究的产出形态就是论文'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '哲学论文写作'
  AND s2.`name` = '西方哲学与德国古典'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '哲学论文写作'
JOIN `zy_skill` s2 ON s2.`name` = '西方哲学与德国古典'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '哲学研究的产出形态就是论文'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 383. 批判性思维训练 (哲学) ↔ 逻辑学与论证分析 (哲学)
--    论证分析与批判性思维是同一能力两侧
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '论证分析与批判性思维是同一能力两侧'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '批判性思维训练'
  AND s2.`name` = '逻辑学与论证分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '批判性思维训练'
JOIN `zy_skill` s2 ON s2.`name` = '逻辑学与论证分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '论证分析与批判性思维是同一能力两侧'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 384. 模拟法庭与辩论 (法学) ↔ 逻辑学与论证分析 (哲学)  [跨门类]
--    辩论的底层能力是论证分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '辩论的底层能力是论证分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '模拟法庭与辩论'
  AND s2.`name` = '逻辑学与论证分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '模拟法庭与辩论'
JOIN `zy_skill` s2 ON s2.`name` = '逻辑学与论证分析'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '辩论的底层能力是论证分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 385. 信息安全与隐私保护意识 (管理学) ↔ 科技哲学与伦理 (哲学)  [跨门类]
--    数据伦理与隐私保护同属科技伦理议题
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '数据伦理与隐私保护同属科技伦理议题'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '信息安全与隐私保护意识'
  AND s2.`name` = '科技哲学与伦理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '信息安全与隐私保护意识'
JOIN `zy_skill` s2 ON s2.`name` = '科技哲学与伦理'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '数据伦理与隐私保护同属科技伦理议题'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 386. 课程思政设计 (教育学) ↔ 马克思主义哲学原理 (哲学)  [跨门类]
--    课程思政把理论融入教学设计
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '课程思政把理论融入教学设计'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '课程思政设计'
  AND s2.`name` = '马克思主义哲学原理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '课程思政设计'
JOIN `zy_skill` s2 ON s2.`name` = '马克思主义哲学原理'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '课程思政把理论融入教学设计'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 387. 宗教学基础 (哲学) ↔ 跨文化交际 (文学)  [跨门类]
--    理解宗教背景是跨文化沟通的前提
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '理解宗教背景是跨文化沟通的前提'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '宗教学基础'
  AND s2.`name` = '跨文化交际'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '宗教学基础'
JOIN `zy_skill` s2 ON s2.`name` = '跨文化交际'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '理解宗教背景是跨文化沟通的前提'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 388. 深度学习入门 (工学) ↔ 病理学读片 (医学)  [跨门类]
--    病理 AI 辅助诊断需要深度模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '病理 AI 辅助诊断需要深度模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '深度学习入门'
  AND s2.`name` = '病理学读片'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '深度学习入门'
JOIN `zy_skill` s2 ON s2.`name` = '病理学读片'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '病理 AI 辅助诊断需要深度模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 389. 深度学习入门 (工学) ↔ 药物合成与工艺 (医学)  [跨门类]
--    AI 辅助药物筛选是深度学习的前沿应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, 'AI 辅助药物筛选是深度学习的前沿应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '深度学习入门'
  AND s2.`name` = '药物合成与工艺'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '深度学习入门'
JOIN `zy_skill` s2 ON s2.`name` = '药物合成与工艺'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = 'AI 辅助药物筛选是深度学习的前沿应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 390. 机器学习建模 (工学) ↔ 金融风险管理 (经济学)  [跨门类]
--    风控模型是机器学习在金融的核心落点
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '风控模型是机器学习在金融的核心落点'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机器学习建模'
  AND s2.`name` = '金融风险管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机器学习建模'
JOIN `zy_skill` s2 ON s2.`name` = '金融风险管理'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '风控模型是机器学习在金融的核心落点'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 391. 机器学习建模 (工学) ↔ 流行病学调查 (医学)  [跨门类]
--    传染病建模与预测是流行病学的新手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '传染病建模与预测是流行病学的新手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机器学习建模'
  AND s2.`name` = '流行病学调查'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机器学习建模'
JOIN `zy_skill` s2 ON s2.`name` = '流行病学调查'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '传染病建模与预测是流行病学的新手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 392. 农业遥感与估产 (农学) ↔ 机器学习建模 (工学)  [跨门类]
--    产量预测模型建立在遥感特征上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '产量预测模型建立在遥感特征上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '农业遥感与估产'
  AND s2.`name` = '机器学习建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '农业遥感与估产'
JOIN `zy_skill` s2 ON s2.`name` = '机器学习建模'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '产量预测模型建立在遥感特征上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 393. 体育赛事组织与裁判 (教育学) ↔ 机器学习建模 (工学)  [跨门类]
--    赛事数据分析与技战术统计依赖建模
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '赛事数据分析与技战术统计依赖建模'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '体育赛事组织与裁判'
  AND s2.`name` = '机器学习建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '体育赛事组织与裁判'
JOIN `zy_skill` s2 ON s2.`name` = '机器学习建模'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '赛事数据分析与技战术统计依赖建模'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 394. 数据挖掘与关联规则 (理学) ↔ 消费者行为分析 (经济学)  [跨门类]
--    消费行为洞察常用关联规则挖掘
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '消费行为洞察常用关联规则挖掘'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据挖掘与关联规则'
  AND s2.`name` = '消费者行为分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据挖掘与关联规则'
JOIN `zy_skill` s2 ON s2.`name` = '消费者行为分析'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '消费行为洞察常用关联规则挖掘'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 395. 客户关系管理 (经济学) ↔ 数据挖掘与关联规则 (理学)  [跨门类]
--    挖掘结果直接支撑客户分层与经营策略
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '挖掘结果直接支撑客户分层与经营策略'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '客户关系管理'
  AND s2.`name` = '数据挖掘与关联规则'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '客户关系管理'
JOIN `zy_skill` s2 ON s2.`name` = '数据挖掘与关联规则'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '挖掘结果直接支撑客户分层与经营策略'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 396. AI 辅助写作与润色 (工学) ↔ 英汉互译 (文学)  [跨门类]
--    翻译与润色工具已进入同一工作流
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.7000, 0, '翻译与润色工具已进入同一工作流'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'AI 辅助写作与润色'
  AND s2.`name` = '英汉互译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'AI 辅助写作与润色'
JOIN `zy_skill` s2 ON s2.`name` = '英汉互译'
SET o.`weight` = 0.7000, o.`directed` = 0,
    o.`remark` = '翻译与润色工具已进入同一工作流'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 397. 数字人文与文本挖掘 (管理学) ↔ 自然语言处理 (工学)  [跨门类]
--    古籍与史料处理开始使用 NLP 方法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '古籍与史料处理开始使用 NLP 方法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数字人文与文本挖掘'
  AND s2.`name` = '自然语言处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数字人文与文本挖掘'
JOIN `zy_skill` s2 ON s2.`name` = '自然语言处理'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '古籍与史料处理开始使用 NLP 方法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 398. 数字人文与文本挖掘 (管理学) ↔ 知识图谱与图数据库 (工学)  [跨门类]
--    人文知识图谱是数字人文的高级形态
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '人文知识图谱是数字人文的高级形态'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数字人文与文本挖掘'
  AND s2.`name` = '知识图谱与图数据库'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数字人文与文本挖掘'
JOIN `zy_skill` s2 ON s2.`name` = '知识图谱与图数据库'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '人文知识图谱是数字人文的高级形态'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 399. 地理信息系统建库 (理学) ↔ 环境监测数据分析 (工学)  [跨门类]
--    环境数据大量带空间属性
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '环境数据大量带空间属性'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '地理信息系统建库'
  AND s2.`name` = '环境监测数据分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '地理信息系统建库'
JOIN `zy_skill` s2 ON s2.`name` = '环境监测数据分析'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '环境数据大量带空间属性'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 400. 气候数据处理 (理学) ↔ 气象数据分析 (理学)
--    气候与气象数据共享处理流程
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '气候与气象数据共享处理流程'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '气候数据处理'
  AND s2.`name` = '气象数据分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '气候数据处理'
JOIN `zy_skill` s2 ON s2.`name` = '气象数据分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '气候与气象数据共享处理流程'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 401. 数值天气预报 (理学) ↔ 气象数据分析 (理学)
--    预报模式输出需要专门的数据分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '预报模式输出需要专门的数据分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数值天气预报'
  AND s2.`name` = '气象数据分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数值天气预报'
JOIN `zy_skill` s2 ON s2.`name` = '气象数据分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '预报模式输出需要专门的数据分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 402. 地球物理勘探 (理学) ↔ 自然灾害风险评估 (理学)
--    地球物理探测用于灾害隐患识别
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '地球物理探测用于灾害隐患识别'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '地球物理勘探'
  AND s2.`name` = '自然灾害风险评估'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '地球物理勘探'
JOIN `zy_skill` s2 ON s2.`name` = '自然灾害风险评估'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '地球物理探测用于灾害隐患识别'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 403. 工程测量与变形监测 (工学) ↔ 构造地质分析 (理学)  [跨门类]
--    构造分析成果服务于工程变形监测选址
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '构造分析成果服务于工程变形监测选址'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '工程测量与变形监测'
  AND s2.`name` = '构造地质分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '工程测量与变形监测'
JOIN `zy_skill` s2 ON s2.`name` = '构造地质分析'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '构造分析成果服务于工程变形监测选址'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 404. 生态建模与simulation (理学) ↔ 碳排放核算 (工学)  [跨门类]
--    碳汇与排放核算使用生态模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '碳汇与排放核算使用生态模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '生态建模与simulation'
  AND s2.`name` = '碳排放核算'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '生态建模与simulation'
JOIN `zy_skill` s2 ON s2.`name` = '碳排放核算'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '碳汇与排放核算使用生态模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 405. 森林生态与碳汇 (农学) ↔ 生态调查与采样 (理学)  [跨门类]
--    生态调查是碳汇计量的数据来源
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '生态调查是碳汇计量的数据来源'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '森林生态与碳汇'
  AND s2.`name` = '生态调查与采样'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '森林生态与碳汇'
JOIN `zy_skill` s2 ON s2.`name` = '生态调查与采样'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '生态调查是碳汇计量的数据来源'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 406. 海洋数据分析 (理学) ↔ 物理海洋学基础 (理学)
--    海洋物理过程研究以数据分析为手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '海洋物理过程研究以数据分析为手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '海洋数据分析'
  AND s2.`name` = '物理海洋学基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '海洋数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '物理海洋学基础'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '海洋物理过程研究以数据分析为手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 407. 半导体物理 (理学) ↔ 模拟电路设计 (工学)  [跨门类]
--    模拟器件设计必须理解半导体机理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '模拟器件设计必须理解半导体机理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '半导体物理'
  AND s2.`name` = '模拟电路设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '半导体物理'
JOIN `zy_skill` s2 ON s2.`name` = '模拟电路设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '模拟器件设计必须理解半导体机理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 408. 固体物理与材料性能 (理学) ↔ 材料计算与模拟 (工学)  [跨门类]
--    材料模拟建立在固体物理理论之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '材料模拟建立在固体物理理论之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '固体物理与材料性能'
  AND s2.`name` = '材料计算与模拟'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '固体物理与材料性能'
JOIN `zy_skill` s2 ON s2.`name` = '材料计算与模拟'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '材料模拟建立在固体物理理论之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 409. 计算化学入门 (理学) ↔ 量子力学基础 (理学)
--    量子化学计算的理论基础就是量子力学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '量子化学计算的理论基础就是量子力学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '计算化学入门'
  AND s2.`name` = '量子力学基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '计算化学入门'
JOIN `zy_skill` s2 ON s2.`name` = '量子力学基础'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '量子化学计算的理论基础就是量子力学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 410. 理论力学与动力学 (理学) ↔ 飞行动力学与仿真 (工学)  [跨门类]
--    飞行力学是理论力学的专门应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '飞行力学是理论力学的专门应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '理论力学与动力学'
  AND s2.`name` = '飞行动力学与仿真'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '理论力学与动力学'
JOIN `zy_skill` s2 ON s2.`name` = '飞行动力学与仿真'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '飞行力学是理论力学的专门应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 411. 气动分析与CFD (工学) ↔ 流体力学基础 (理学)  [跨门类]
--    CFD 本质是流体力学方程的数值解
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, 'CFD 本质是流体力学方程的数值解'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '气动分析与CFD'
  AND s2.`name` = '流体力学基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '气动分析与CFD'
JOIN `zy_skill` s2 ON s2.`name` = '流体力学基础'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = 'CFD 本质是流体力学方程的数值解'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 412. 制冷与低温技术 (工学) ↔ 热力学与统计物理 (理学)  [跨门类]
--    制冷循环的理论基础是热力学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '制冷循环的理论基础是热力学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '制冷与低温技术'
  AND s2.`name` = '热力学与统计物理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '制冷与低温技术'
JOIN `zy_skill` s2 ON s2.`name` = '热力学与统计物理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '制冷循环的理论基础是热力学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 413. 内燃机原理与标定 (工学) ↔ 热力学与统计物理 (理学)  [跨门类]
--    内燃机热效率分析依赖热力学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '内燃机热效率分析依赖热力学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '内燃机原理与标定'
  AND s2.`name` = '热力学与统计物理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '内燃机原理与标定'
JOIN `zy_skill` s2 ON s2.`name` = '热力学与统计物理'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '内燃机热效率分析依赖热力学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 414. 无线通信模块调试 (工学) ↔ 电磁场与电磁波 (理学)  [跨门类]
--    射频调试必须理解电磁场理论
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '射频调试必须理解电磁场理论'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '无线通信模块调试'
  AND s2.`name` = '电磁场与电磁波'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '无线通信模块调试'
JOIN `zy_skill` s2 ON s2.`name` = '电磁场与电磁波'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '射频调试必须理解电磁场理论'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 415. 光学与激光技术 (理学) ↔ 激光切割与结构制作 (工学)  [跨门类]
--    激光加工设备基于激光技术
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '激光加工设备基于激光技术'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '光学与激光技术'
  AND s2.`name` = '激光切割与结构制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '光学与激光技术'
JOIN `zy_skill` s2 ON s2.`name` = '激光切割与结构制作'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '激光加工设备基于激光技术'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 416. 催化剂与反应工程 (工学) ↔ 无机化学与配位 (理学)  [跨门类]
--    催化剂设计属于配位化学的应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '催化剂设计属于配位化学的应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '催化剂与反应工程'
  AND s2.`name` = '无机化学与配位'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '催化剂与反应工程'
JOIN `zy_skill` s2 ON s2.`name` = '无机化学与配位'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '催化剂设计属于配位化学的应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 417. 化学反应工程 (理学) ↔ 物理化学与热力学 (理学)
--    反应工程的计算基础是物理化学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '反应工程的计算基础是物理化学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '化学反应工程'
  AND s2.`name` = '物理化学与热力学'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '化学反应工程'
JOIN `zy_skill` s2 ON s2.`name` = '物理化学与热力学'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '反应工程的计算基础是物理化学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 418. 实验数据处理与作图 (理学) ↔ 科研实验设计 (理学)
--    实验设计决定了数据能不能支撑结论
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '实验设计决定了数据能不能支撑结论'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '实验数据处理与作图'
  AND s2.`name` = '科研实验设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '实验数据处理与作图'
JOIN `zy_skill` s2 ON s2.`name` = '科研实验设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '实验设计决定了数据能不能支撑结论'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 419. 新能源发电技术 (工学) ↔ 电池与储能材料 (工学)
--    新能源并网必须配套储能
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '新能源并网必须配套储能'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '新能源发电技术'
  AND s2.`name` = '电池与储能材料'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '新能源发电技术'
JOIN `zy_skill` s2 ON s2.`name` = '电池与储能材料'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '新能源并网必须配套储能'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 420. 新能源发电技术 (工学) ↔ 电源与电源管理 (工学)
--    发电与用电两端都要电源管理
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '发电与用电两端都要电源管理'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '新能源发电技术'
  AND s2.`name` = '电源与电源管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '新能源发电技术'
JOIN `zy_skill` s2 ON s2.`name` = '电源与电源管理'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '发电与用电两端都要电源管理'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 421. 复合材料结构分析 (工学) ↔ 飞行器总体设计 (工学)
--    飞行器减重依赖复合材料与结构分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '飞行器减重依赖复合材料与结构分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '复合材料结构分析'
  AND s2.`name` = '飞行器总体设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '复合材料结构分析'
JOIN `zy_skill` s2 ON s2.`name` = '飞行器总体设计'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '飞行器减重依赖复合材料与结构分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 422. 地理调查与问卷 (理学) ↔ 社会调查与统计分析 (管理学)  [跨门类]
--    地理调查与社科调查方法同源
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.9000, 0, '地理调查与社科调查方法同源'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '地理调查与问卷'
  AND s2.`name` = '社会调查与统计分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '地理调查与问卷'
JOIN `zy_skill` s2 ON s2.`name` = '社会调查与统计分析'
SET o.`weight` = 0.9000, o.`directed` = 0,
    o.`remark` = '地理调查与社科调查方法同源'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- 423. 材料表征与测试 (工学) ↔ 食品安全与检测 (医学)  [跨门类]
--    食品掺假鉴别依赖材料与成分表征手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'COMPLEMENT', 0.8000, 0, '食品掺假鉴别依赖材料与成分表征手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '材料表征与测试'
  AND s2.`name` = '食品安全与检测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'COMPLEMENT');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '材料表征与测试'
JOIN `zy_skill` s2 ON s2.`name` = '食品安全与检测'
SET o.`weight` = 0.8000, o.`directed` = 0,
    o.`remark` = '食品掺假鉴别依赖材料与成分表征手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'COMPLEMENT';

-- --------------------------------------------------------------------------
-- PREREQUISITE
-- --------------------------------------------------------------------------

-- 424. CSS 样式与响应式布局 (工学) → Vue 前端开发 (工学)
--    不会布局就写不出页面结构
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '不会布局就写不出页面结构'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'CSS 样式与响应式布局'
  AND s2.`name` = 'Vue 前端开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'CSS 样式与响应式布局'
JOIN `zy_skill` s2 ON s2.`name` = 'Vue 前端开发'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '不会布局就写不出页面结构'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 425. Vue 前端开发 (工学) → 前端性能优化 (工学)
--    先能写出来，才谈得上优化
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先能写出来，才谈得上优化'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Vue 前端开发'
  AND s2.`name` = '前端性能优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Vue 前端开发'
JOIN `zy_skill` s2 ON s2.`name` = '前端性能优化'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先能写出来，才谈得上优化'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 426. 浏览器渲染与调试 (工学) → 前端性能优化 (工学)
--    不懂渲染管线无法定位性能瓶颈
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '不懂渲染管线无法定位性能瓶颈'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '浏览器渲染与调试'
  AND s2.`name` = '前端性能优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '浏览器渲染与调试'
JOIN `zy_skill` s2 ON s2.`name` = '前端性能优化'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '不懂渲染管线无法定位性能瓶颈'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 427. Webpack 与前端工程化 (工学) → 前端性能优化 (工学)
--    产物优化建立在构建配置之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '产物优化建立在构建配置之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Webpack 与前端工程化'
  AND s2.`name` = '前端性能优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Webpack 与前端工程化'
JOIN `zy_skill` s2 ON s2.`name` = '前端性能优化'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '产物优化建立在构建配置之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 428. Vue 前端开发 (工学) → TypeScript 类型化开发 (工学)
--    先掌握框架再看类型系统收益更直观
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先掌握框架再看类型系统收益更直观'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Vue 前端开发'
  AND s2.`name` = 'TypeScript 类型化开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Vue 前端开发'
JOIN `zy_skill` s2 ON s2.`name` = 'TypeScript 类型化开发'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先掌握框架再看类型系统收益更直观'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 429. TypeScript 类型化开发 (工学) → 代码重构与整洁代码 (工学)
--    大型工程需要类型系统兜底
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.7000, 1, '大型工程需要类型系统兜底'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'TypeScript 类型化开发'
  AND s2.`name` = '代码重构与整洁代码'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'TypeScript 类型化开发'
JOIN `zy_skill` s2 ON s2.`name` = '代码重构与整洁代码'
SET o.`weight` = 0.7000, o.`directed` = 1,
    o.`remark` = '大型工程需要类型系统兜底'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 430. JS 动画与交互实现 (工学) → Web3D 与 Three.js (工学)
--    先掌握基础动效再进三维渲染
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先掌握基础动效再进三维渲染'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'JS 动画与交互实现'
  AND s2.`name` = 'Web3D 与 Three.js'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'JS 动画与交互实现'
JOIN `zy_skill` s2 ON s2.`name` = 'Web3D 与 Three.js'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先掌握基础动效再进三维渲染'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 431. 计算机网络基础 (工学) → RESTful 接口设计 (工学)
--    不懂 HTTP 就设计不好接口
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '不懂 HTTP 就设计不好接口'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '计算机网络基础'
  AND s2.`name` = 'RESTful 接口设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '计算机网络基础'
JOIN `zy_skill` s2 ON s2.`name` = 'RESTful 接口设计'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '不懂 HTTP 就设计不好接口'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 432. 计算机网络基础 (工学) → 网络协议抓包分析 (工学)
--    抓包分析以协议知识为前提
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '抓包分析以协议知识为前提'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '计算机网络基础'
  AND s2.`name` = '网络协议抓包分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '计算机网络基础'
JOIN `zy_skill` s2 ON s2.`name` = '网络协议抓包分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '抓包分析以协议知识为前提'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 433. 网络协议抓包分析 (工学) → 日志分析与异常定位 (工学)
--    定位线上问题常用抓包与日志对照
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '定位线上问题常用抓包与日志对照'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '网络协议抓包分析'
  AND s2.`name` = '日志分析与异常定位'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '网络协议抓包分析'
JOIN `zy_skill` s2 ON s2.`name` = '日志分析与异常定位'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '定位线上问题常用抓包与日志对照'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 434. 计算机网络基础 (工学) → Linux 服务器运维 (工学)
--    排障必须理解网络协议
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '排障必须理解网络协议'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '计算机网络基础'
  AND s2.`name` = 'Linux 服务器运维'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '计算机网络基础'
JOIN `zy_skill` s2 ON s2.`name` = 'Linux 服务器运维'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '排障必须理解网络协议'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 435. 算法与数据结构 (工学) → Java 后端开发 (工学)
--    后端业务代码离不开基本数据结构
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '后端业务代码离不开基本数据结构'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '算法与数据结构'
  AND s2.`name` = 'Java 后端开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '算法与数据结构'
JOIN `zy_skill` s2 ON s2.`name` = 'Java 后端开发'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '后端业务代码离不开基本数据结构'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 436. Java 后端开发 (工学) → Spring Boot 应用开发 (工学)
--    Spring Boot 是 Java 后端的框架层
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, 'Spring Boot 是 Java 后端的框架层'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Java 后端开发'
  AND s2.`name` = 'Spring Boot 应用开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Java 后端开发'
JOIN `zy_skill` s2 ON s2.`name` = 'Spring Boot 应用开发'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = 'Spring Boot 是 Java 后端的框架层'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 437. RESTful 接口设计 (工学) → Spring Boot 应用开发 (工学)
--    先定契约再写实现
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先定契约再写实现'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'RESTful 接口设计'
  AND s2.`name` = 'Spring Boot 应用开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'RESTful 接口设计'
JOIN `zy_skill` s2 ON s2.`name` = 'Spring Boot 应用开发'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先定契约再写实现'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 438. MySQL 数据库设计与优化 (工学) → Spring Boot 应用开发 (工学)
--    服务端必然要落库
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '服务端必然要落库'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'MySQL 数据库设计与优化'
  AND s2.`name` = 'Spring Boot 应用开发'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'MySQL 数据库设计与优化'
JOIN `zy_skill` s2 ON s2.`name` = 'Spring Boot 应用开发'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '服务端必然要落库'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 439. MySQL 数据库设计与优化 (工学) → 数据库索引与慢查询优化 (工学)
--    先会建库建表才谈得上调优
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '先会建库建表才谈得上调优'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'MySQL 数据库设计与优化'
  AND s2.`name` = '数据库索引与慢查询优化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'MySQL 数据库设计与优化'
JOIN `zy_skill` s2 ON s2.`name` = '数据库索引与慢查询优化'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '先会建库建表才谈得上调优'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 440. 数据库索引与慢查询优化 (工学) → 分库分表与读写分离 (工学)
--    单库优化到极限才上分片
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '单库优化到极限才上分片'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据库索引与慢查询优化'
  AND s2.`name` = '分库分表与读写分离'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据库索引与慢查询优化'
JOIN `zy_skill` s2 ON s2.`name` = '分库分表与读写分离'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '单库优化到极限才上分片'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 441. Linux 服务器运维 (工学) → Docker 容器化部署 (工学)
--    容器要在 Linux 上跑起来
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '容器要在 Linux 上跑起来'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Linux 服务器运维'
  AND s2.`name` = 'Docker 容器化部署'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Linux 服务器运维'
JOIN `zy_skill` s2 ON s2.`name` = 'Docker 容器化部署'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '容器要在 Linux 上跑起来'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 442. Docker 容器化部署 (工学) → Kubernetes 容器编排 (工学)
--    先懂容器再学编排
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '先懂容器再学编排'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Docker 容器化部署'
  AND s2.`name` = 'Kubernetes 容器编排'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Docker 容器化部署'
JOIN `zy_skill` s2 ON s2.`name` = 'Kubernetes 容器编排'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '先懂容器再学编排'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 443. Docker 容器化部署 (工学) → 云计算与服务器部署 (工学)
--    云上部署普遍以容器为载体
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '云上部署普遍以容器为载体'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Docker 容器化部署'
  AND s2.`name` = '云计算与服务器部署'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Docker 容器化部署'
JOIN `zy_skill` s2 ON s2.`name` = '云计算与服务器部署'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '云上部署普遍以容器为载体'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 444. 操作系统原理 (工学) → Linux 服务器运维 (工学)
--    运维排障需要操作系统知识
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '运维排障需要操作系统知识'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '操作系统原理'
  AND s2.`name` = 'Linux 服务器运维'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '操作系统原理'
JOIN `zy_skill` s2 ON s2.`name` = 'Linux 服务器运维'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '运维排障需要操作系统知识'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 445. 操作系统原理 (工学) → 并发编程与线程安全 (工学)
--    并发问题本质是操作系统调度问题
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '并发问题本质是操作系统调度问题'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '操作系统原理'
  AND s2.`name` = '并发编程与线程安全'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '操作系统原理'
JOIN `zy_skill` s2 ON s2.`name` = '并发编程与线程安全'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '并发问题本质是操作系统调度问题'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 446. 计算机网络基础 (工学) → Web 安全与防护 (工学)
--    Web 攻击面就是协议实现细节
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, 'Web 攻击面就是协议实现细节'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '计算机网络基础'
  AND s2.`name` = 'Web 安全与防护'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '计算机网络基础'
JOIN `zy_skill` s2 ON s2.`name` = 'Web 安全与防护'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = 'Web 攻击面就是协议实现细节'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 447. Web 安全与防护 (工学) → 渗透测试与漏洞挖掘 (工学)
--    先懂防护原理再打靶
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先懂防护原理再打靶'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Web 安全与防护'
  AND s2.`name` = '渗透测试与漏洞挖掘'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Web 安全与防护'
JOIN `zy_skill` s2 ON s2.`name` = '渗透测试与漏洞挖掘'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先懂防护原理再打靶'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 448. 数论与密码数学 (理学) → 密码学应用 (工学)  [跨门类]
--    公钥算法建立在数论基础上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '公钥算法建立在数论基础上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数论与密码数学'
  AND s2.`name` = '密码学应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数论与密码数学'
JOIN `zy_skill` s2 ON s2.`name` = '密码学应用'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '公钥算法建立在数论基础上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 449. 密码学应用 (工学) → 区块链与数字货币基础 (经济学)  [跨门类]
--    区块链的信任机制来自密码学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '区块链的信任机制来自密码学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '密码学应用'
  AND s2.`name` = '区块链与数字货币基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '密码学应用'
JOIN `zy_skill` s2 ON s2.`name` = '区块链与数字货币基础'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '区块链的信任机制来自密码学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 450. 软件测试与质量保障 (工学) → 自动化测试框架 (工学)
--    先懂测试理论再上框架
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '先懂测试理论再上框架'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '软件测试与质量保障'
  AND s2.`name` = '自动化测试框架'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '软件测试与质量保障'
JOIN `zy_skill` s2 ON s2.`name` = '自动化测试框架'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '先懂测试理论再上框架'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 451. 单元测试与测试驱动 (工学) → 自动化测试框架 (工学)
--    单元测试是自动化测试的基础层
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '单元测试是自动化测试的基础层'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '单元测试与测试驱动'
  AND s2.`name` = '自动化测试框架'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '单元测试与测试驱动'
JOIN `zy_skill` s2 ON s2.`name` = '自动化测试框架'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '单元测试是自动化测试的基础层'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 452. 软件需求与架构设计 (工学) → 领域驱动设计 (工学)
--    DDD 是架构设计的一种方法论
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, 'DDD 是架构设计的一种方法论'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '软件需求与架构设计'
  AND s2.`name` = '领域驱动设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '软件需求与架构设计'
JOIN `zy_skill` s2 ON s2.`name` = '领域驱动设计'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = 'DDD 是架构设计的一种方法论'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 453. 软件需求与架构设计 (工学) → 技术方案评审 (工学)
--    评审对象就是架构方案
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '评审对象就是架构方案'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '软件需求与架构设计'
  AND s2.`name` = '技术方案评审'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '软件需求与架构设计'
JOIN `zy_skill` s2 ON s2.`name` = '技术方案评审'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '评审对象就是架构方案'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 454. 软件需求与架构设计 (工学) → 微服务架构设计 (工学)
--    微服务是架构设计的一种风格
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '微服务是架构设计的一种风格'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '软件需求与架构设计'
  AND s2.`name` = '微服务架构设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '软件需求与架构设计'
JOIN `zy_skill` s2 ON s2.`name` = '微服务架构设计'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '微服务是架构设计的一种风格'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 455. 高等数学与微积分 (理学) → 线性代数与矩阵论 (理学)
--    矩阵分析需要微积分基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.7000, 1, '矩阵分析需要微积分基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '高等数学与微积分'
  AND s2.`name` = '线性代数与矩阵论'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '高等数学与微积分'
JOIN `zy_skill` s2 ON s2.`name` = '线性代数与矩阵论'
SET o.`weight` = 0.7000, o.`directed` = 1,
    o.`remark` = '矩阵分析需要微积分基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 456. 线性代数与矩阵论 (理学) → 机器学习建模 (工学)  [跨门类]
--    模型推导全是矩阵运算
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '模型推导全是矩阵运算'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '线性代数与矩阵论'
  AND s2.`name` = '机器学习建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '线性代数与矩阵论'
JOIN `zy_skill` s2 ON s2.`name` = '机器学习建模'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '模型推导全是矩阵运算'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 457. 概率论与数理统计 (理学) → 机器学习建模 (工学)  [跨门类]
--    没有概率统计基础无法理解模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '没有概率统计基础无法理解模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '概率论与数理统计'
  AND s2.`name` = '机器学习建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '概率论与数理统计'
JOIN `zy_skill` s2 ON s2.`name` = '机器学习建模'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '没有概率统计基础无法理解模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 458. 高等数学与微积分 (理学) → 数值计算方法 (理学)
--    数值方法建立在微积分与误差分析上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '数值方法建立在微积分与误差分析上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '高等数学与微积分'
  AND s2.`name` = '数值计算方法'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '高等数学与微积分'
JOIN `zy_skill` s2 ON s2.`name` = '数值计算方法'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '数值方法建立在微积分与误差分析上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 459. 线性代数与矩阵论 (理学) → 数值计算方法 (理学)
--    数值算法大量是矩阵分解
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '数值算法大量是矩阵分解'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '线性代数与矩阵论'
  AND s2.`name` = '数值计算方法'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '线性代数与矩阵论'
JOIN `zy_skill` s2 ON s2.`name` = '数值计算方法'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '数值算法大量是矩阵分解'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 460. Python 科学计算 (理学) → 机器学习建模 (工学)  [跨门类]
--    建模实践以 Python 为载体
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '建模实践以 Python 为载体'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Python 科学计算'
  AND s2.`name` = '机器学习建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Python 科学计算'
JOIN `zy_skill` s2 ON s2.`name` = '机器学习建模'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '建模实践以 Python 为载体'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 461. NumPy 数值计算 (工学) → Pandas 数据处理 (工学)
--    pandas 建立在 numpy 之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, 'pandas 建立在 numpy 之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'NumPy 数值计算'
  AND s2.`name` = 'Pandas 数据处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'NumPy 数值计算'
JOIN `zy_skill` s2 ON s2.`name` = 'Pandas 数据处理'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = 'pandas 建立在 numpy 之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 462. Pandas 数据处理 (工学) → 数据清洗与特征构造 (理学)  [跨门类]
--    清洗与特征工程在 pandas 里完成
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '清洗与特征工程在 pandas 里完成'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Pandas 数据处理'
  AND s2.`name` = '数据清洗与特征构造'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Pandas 数据处理'
JOIN `zy_skill` s2 ON s2.`name` = '数据清洗与特征构造'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '清洗与特征工程在 pandas 里完成'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 463. 数据爬取与清洗 (工学) → 数据清洗与特征构造 (理学)  [跨门类]
--    先取到数据才能清洗
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '先取到数据才能清洗'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据爬取与清洗'
  AND s2.`name` = '数据清洗与特征构造'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据爬取与清洗'
JOIN `zy_skill` s2 ON s2.`name` = '数据清洗与特征构造'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '先取到数据才能清洗'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 464. 数据标注与质量校验 (工学) → 机器学习建模 (工学)
--    数据准备是建模前一步
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '数据准备是建模前一步'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据标注与质量校验'
  AND s2.`name` = '机器学习建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据标注与质量校验'
JOIN `zy_skill` s2 ON s2.`name` = '机器学习建模'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '数据准备是建模前一步'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 465. 机器学习建模 (工学) → 深度学习入门 (工学)
--    先懂经典模型才能理解深度模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '先懂经典模型才能理解深度模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机器学习建模'
  AND s2.`name` = '深度学习入门'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机器学习建模'
JOIN `zy_skill` s2 ON s2.`name` = '深度学习入门'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '先懂经典模型才能理解深度模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 466. 深度学习入门 (工学) → 模型微调与训练 (工学)
--    微调建立在深度模型理解之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '微调建立在深度模型理解之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '深度学习入门'
  AND s2.`name` = '模型微调与训练'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '深度学习入门'
JOIN `zy_skill` s2 ON s2.`name` = '模型微调与训练'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '微调建立在深度模型理解之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 467. 深度学习入门 (工学) → 自然语言处理 (工学)
--    NLP 主流实现基于深度模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, 'NLP 主流实现基于深度模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '深度学习入门'
  AND s2.`name` = '自然语言处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '深度学习入门'
JOIN `zy_skill` s2 ON s2.`name` = '自然语言处理'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = 'NLP 主流实现基于深度模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 468. 深度学习入门 (工学) → 计算机视觉应用 (工学)
--    CV 主流实现基于深度模型
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, 'CV 主流实现基于深度模型'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '深度学习入门'
  AND s2.`name` = '计算机视觉应用'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '深度学习入门'
JOIN `zy_skill` s2 ON s2.`name` = '计算机视觉应用'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = 'CV 主流实现基于深度模型'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 469. 自然语言处理 (工学) → RAG 检索增强生成 (工学)
--    先理解检索与语言任务再谈 RAG
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先理解检索与语言任务再谈 RAG'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '自然语言处理'
  AND s2.`name` = 'RAG 检索增强生成'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '自然语言处理'
JOIN `zy_skill` s2 ON s2.`name` = 'RAG 检索增强生成'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先理解检索与语言任务再谈 RAG'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 470. 向量数据库应用 (工学) → RAG 检索增强生成 (工学)
--    RAG 的检索层依赖向量库
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, 'RAG 的检索层依赖向量库'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '向量数据库应用'
  AND s2.`name` = 'RAG 检索增强生成'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '向量数据库应用'
JOIN `zy_skill` s2 ON s2.`name` = 'RAG 检索增强生成'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = 'RAG 的检索层依赖向量库'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 471. 大模型 API 应用开发 (工学) → 智能体与工作流编排 (工学)
--    智能体编排建立在大模型调用之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '智能体编排建立在大模型调用之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '大模型 API 应用开发'
  AND s2.`name` = '智能体与工作流编排'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '大模型 API 应用开发'
JOIN `zy_skill` s2 ON s2.`name` = '智能体与工作流编排'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '智能体编排建立在大模型调用之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 472. 线性代数与矩阵论 (理学) → 信号采集与滤波 (工学)  [跨门类]
--    滤波与变换的数学基础是线性代数
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.7000, 1, '滤波与变换的数学基础是线性代数'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '线性代数与矩阵论'
  AND s2.`name` = '信号采集与滤波'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '线性代数与矩阵论'
JOIN `zy_skill` s2 ON s2.`name` = '信号采集与滤波'
SET o.`weight` = 0.7000, o.`directed` = 1,
    o.`remark` = '滤波与变换的数学基础是线性代数'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 473. 概率论与数理统计 (理学) → 随机过程与模拟 (理学)
--    随机过程以概率论为前置
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '随机过程以概率论为前置'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '概率论与数理统计'
  AND s2.`name` = '随机过程与模拟'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '概率论与数理统计'
JOIN `zy_skill` s2 ON s2.`name` = '随机过程与模拟'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '随机过程以概率论为前置'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 474. 概率论与数理统计 (理学) → 时间序列分析 (理学)
--    时序建模依赖统计推断
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '时序建模依赖统计推断'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '概率论与数理统计'
  AND s2.`name` = '时间序列分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '概率论与数理统计'
JOIN `zy_skill` s2 ON s2.`name` = '时间序列分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '时序建模依赖统计推断'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 475. 回归分析与建模 (理学) → 计量经济学分析 (经济学)  [跨门类]
--    计量经济学的起点是回归
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '计量经济学的起点是回归'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '回归分析与建模'
  AND s2.`name` = '计量经济学分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '回归分析与建模'
JOIN `zy_skill` s2 ON s2.`name` = '计量经济学分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '计量经济学的起点是回归'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 476. 运筹学与最优化 (理学) → 供应链与物流管理 (经济学)  [跨门类]
--    供应链优化的模型来自运筹
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '供应链优化的模型来自运筹'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '运筹学与最优化'
  AND s2.`name` = '供应链与物流管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '运筹学与最优化'
JOIN `zy_skill` s2 ON s2.`name` = '供应链与物流管理'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '供应链优化的模型来自运筹'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 477. 数学建模 (理学) → 数学建模竞赛实战 (理学)
--    先掌握方法再进竞赛强度训练
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '先掌握方法再进竞赛强度训练'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数学建模'
  AND s2.`name` = '数学建模竞赛实战'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数学建模'
JOIN `zy_skill` s2 ON s2.`name` = '数学建模竞赛实战'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '先掌握方法再进竞赛强度训练'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 478. Python 科学计算 (理学) → 数学建模竞赛实战 (理学)
--    竞赛需要快速编程实现能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '竞赛需要快速编程实现能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Python 科学计算'
  AND s2.`name` = '数学建模竞赛实战'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Python 科学计算'
JOIN `zy_skill` s2 ON s2.`name` = '数学建模竞赛实战'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '竞赛需要快速编程实现能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 479. MATLAB 数值计算与仿真 (理学) → 数学建模竞赛实战 (理学)
--    竞赛常用 MATLAB 求解
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '竞赛常用 MATLAB 求解'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'MATLAB 数值计算与仿真'
  AND s2.`name` = '数学建模竞赛实战'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'MATLAB 数值计算与仿真'
JOIN `zy_skill` s2 ON s2.`name` = '数学建模竞赛实战'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '竞赛常用 MATLAB 求解'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 480. 色彩理论与配色 (艺术学) → 平面设计基础 (艺术学)
--    配色是平面设计的基本功
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '配色是平面设计的基本功'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '色彩理论与配色'
  AND s2.`name` = '平面设计基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '色彩理论与配色'
JOIN `zy_skill` s2 ON s2.`name` = '平面设计基础'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '配色是平面设计的基本功'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 481. 平面设计基础 (艺术学) → 版式设计与排版 (艺术学)
--    排版在平面设计基础上专门化
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '排版在平面设计基础上专门化'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '平面设计基础'
  AND s2.`name` = '版式设计与排版'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '平面设计基础'
JOIN `zy_skill` s2 ON s2.`name` = '版式设计与排版'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '排版在平面设计基础上专门化'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 482. 版式设计与排版 (艺术学) → InDesign 排版设计 (艺术学)
--    工具要建立在排版判断力之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '工具要建立在排版判断力之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '版式设计与排版'
  AND s2.`name` = 'InDesign 排版设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '版式设计与排版'
JOIN `zy_skill` s2 ON s2.`name` = 'InDesign 排版设计'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '工具要建立在排版判断力之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 483. 平面设计基础 (艺术学) → 品牌视觉与 VI 设计 (艺术学)
--    VI 是平面设计的高阶应用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, 'VI 是平面设计的高阶应用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '平面设计基础'
  AND s2.`name` = '品牌视觉与 VI 设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '平面设计基础'
JOIN `zy_skill` s2 ON s2.`name` = '品牌视觉与 VI 设计'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = 'VI 是平面设计的高阶应用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 484. UI/UX 设计 (艺术学) → 设计系统与组件库 (艺术学)
--    先有设计判断再谈系统化沉淀
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '先有设计判断再谈系统化沉淀'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'UI/UX 设计'
  AND s2.`name` = '设计系统与组件库'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'UI/UX 设计'
JOIN `zy_skill` s2 ON s2.`name` = '设计系统与组件库'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '先有设计判断再谈系统化沉淀'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 485. UI/UX 设计 (艺术学) → 用户体验研究方法 (艺术学)
--    先会做设计再系统研究方法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先会做设计再系统研究方法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'UI/UX 设计'
  AND s2.`name` = '用户体验研究方法'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'UI/UX 设计'
JOIN `zy_skill` s2 ON s2.`name` = '用户体验研究方法'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先会做设计再系统研究方法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 486. UI/UX 设计 (艺术学) → 交互原型设计 (艺术学)
--    原型是界面设计的表达手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '原型是界面设计的表达手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'UI/UX 设计'
  AND s2.`name` = '交互原型设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'UI/UX 设计'
JOIN `zy_skill` s2 ON s2.`name` = '交互原型设计'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '原型是界面设计的表达手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 487. UI/UX 设计 (艺术学) → 无障碍与包容性设计 (艺术学)
--    包容性设计是 UX 的专门要求
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '包容性设计是 UX 的专门要求'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'UI/UX 设计'
  AND s2.`name` = '无障碍与包容性设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'UI/UX 设计'
JOIN `zy_skill` s2 ON s2.`name` = '无障碍与包容性设计'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '包容性设计是 UX 的专门要求'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 488. 设计调研与竞品分析 (艺术学) → 服务设计 (艺术学)
--    服务设计以调研洞察为起点
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '服务设计以调研洞察为起点'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '设计调研与竞品分析'
  AND s2.`name` = '服务设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '设计调研与竞品分析'
JOIN `zy_skill` s2 ON s2.`name` = '服务设计'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '服务设计以调研洞察为起点'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 489. 手绘草图与快速表达 (艺术学) → 插画与手绘表达 (艺术学)
--    草图能力是插画的基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '草图能力是插画的基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '手绘草图与快速表达'
  AND s2.`name` = '插画与手绘表达'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '手绘草图与快速表达'
JOIN `zy_skill` s2 ON s2.`name` = '插画与手绘表达'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '草图能力是插画的基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 490. 三维产品渲染 (艺术学) → 虚拟展陈设计 (艺术学)
--    展陈表现需要三维渲染能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '展陈表现需要三维渲染能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '三维产品渲染'
  AND s2.`name` = '虚拟展陈设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '三维产品渲染'
JOIN `zy_skill` s2 ON s2.`name` = '虚拟展陈设计'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '展陈表现需要三维渲染能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 491. Photoshop 图像处理 (艺术学) → UI/UX 设计 (艺术学)
--    图像处理是界面设计的工具基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.7000, 1, '图像处理是界面设计的工具基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Photoshop 图像处理'
  AND s2.`name` = 'UI/UX 设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Photoshop 图像处理'
JOIN `zy_skill` s2 ON s2.`name` = 'UI/UX 设计'
SET o.`weight` = 0.7000, o.`directed` = 1,
    o.`remark` = '图像处理是界面设计的工具基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 492. 摄影摄像基础 (艺术学) → 视频剪辑 (艺术学)
--    没有可用素材就无从剪辑
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '没有可用素材就无从剪辑'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '摄影摄像基础'
  AND s2.`name` = '视频剪辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '摄影摄像基础'
JOIN `zy_skill` s2 ON s2.`name` = '视频剪辑'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '没有可用素材就无从剪辑'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 493. 视频剪辑 (艺术学) → 视频调色与色彩管理 (艺术学)
--    先剪顺再调色是行业常规顺序
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先剪顺再调色是行业常规顺序'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '视频剪辑'
  AND s2.`name` = '视频调色与色彩管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '视频剪辑'
JOIN `zy_skill` s2 ON s2.`name` = '视频调色与色彩管理'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先剪顺再调色是行业常规顺序'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 494. 视频剪辑 (艺术学) → 影视特效与合成 (艺术学)
--    剪辑是合成的前置环节
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '剪辑是合成的前置环节'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '视频剪辑'
  AND s2.`name` = '影视特效与合成'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '视频剪辑'
JOIN `zy_skill` s2 ON s2.`name` = '影视特效与合成'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '剪辑是合成的前置环节'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 495. 剧本创作与分镜 (艺术学) → 影视制片与统筹 (艺术学)
--    没有剧本无法统筹拍摄
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '没有剧本无法统筹拍摄'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '剧本创作与分镜'
  AND s2.`name` = '影视制片与统筹'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '剧本创作与分镜'
JOIN `zy_skill` s2 ON s2.`name` = '影视制片与统筹'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '没有剧本无法统筹拍摄'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 496. 乐理与视唱练耳 (艺术学) → 编曲与音乐制作 (艺术学)
--    不懂乐理无法编配
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '不懂乐理无法编配'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '乐理与视唱练耳'
  AND s2.`name` = '编曲与音乐制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '乐理与视唱练耳'
JOIN `zy_skill` s2 ON s2.`name` = '编曲与音乐制作'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '不懂乐理无法编配'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 497. 编曲与音乐制作 (艺术学) → 音乐录音与混音 (艺术学)
--    先有编曲才谈录制混音
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先有编曲才谈录制混音'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '编曲与音乐制作'
  AND s2.`name` = '音乐录音与混音'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '编曲与音乐制作'
JOIN `zy_skill` s2 ON s2.`name` = '音乐录音与混音'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先有编曲才谈录制混音'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 498. 乐理与视唱练耳 (艺术学) → 乐器演奏 (艺术学)
--    乐理是演奏的理论基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '乐理是演奏的理论基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '乐理与视唱练耳'
  AND s2.`name` = '乐器演奏'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '乐理与视唱练耳'
JOIN `zy_skill` s2 ON s2.`name` = '乐器演奏'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '乐理是演奏的理论基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 499. 舞蹈基础训练 (艺术学) → 舞蹈编创与排练 (艺术学)
--    没有基本功无法编创
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '没有基本功无法编创'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '舞蹈基础训练'
  AND s2.`name` = '舞蹈编创与排练'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '舞蹈基础训练'
JOIN `zy_skill` s2 ON s2.`name` = '舞蹈编创与排练'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '没有基本功无法编创'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 500. 解剖学与标本辨识 (医学) → 临床技能操作 (医学)
--    不懂解剖做不了临床操作
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '不懂解剖做不了临床操作'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '解剖学与标本辨识'
  AND s2.`name` = '临床技能操作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '解剖学与标本辨识'
JOIN `zy_skill` s2 ON s2.`name` = '临床技能操作'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '不懂解剖做不了临床操作'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 501. 解剖学与标本辨识 (医学) → 外科基本操作 (医学)
--    外科操作必须清楚解剖层次
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '外科操作必须清楚解剖层次'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '解剖学与标本辨识'
  AND s2.`name` = '外科基本操作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '解剖学与标本辨识'
JOIN `zy_skill` s2 ON s2.`name` = '外科基本操作'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '外科操作必须清楚解剖层次'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 502. 生理学实验 (医学) → 病理学读片 (医学)
--    先懂正常生理再理解病理改变
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先懂正常生理再理解病理改变'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '生理学实验'
  AND s2.`name` = '病理学读片'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '生理学实验'
JOIN `zy_skill` s2 ON s2.`name` = '病理学读片'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先懂正常生理再理解病理改变'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 503. 病理学读片 (医学) → 内科病例分析 (医学)
--    病例分析以病理机制为据
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '病例分析以病理机制为据'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '病理学读片'
  AND s2.`name` = '内科病例分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '病理学读片'
JOIN `zy_skill` s2 ON s2.`name` = '内科病例分析'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '病例分析以病理机制为据'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 504. 病史采集与体格检查 (医学) → 内科病例分析 (医学)
--    病史与查体是诊断的起点
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '病史与查体是诊断的起点'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '病史采集与体格检查'
  AND s2.`name` = '内科病例分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '病史采集与体格检查'
JOIN `zy_skill` s2 ON s2.`name` = '内科病例分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '病史与查体是诊断的起点'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 505. 医学统计学 (医学) → 流行病学调查 (医学)
--    流调结论必须做统计检验
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '流调结论必须做统计检验'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医学统计学'
  AND s2.`name` = '流行病学调查'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医学统计学'
JOIN `zy_skill` s2 ON s2.`name` = '流行病学调查'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '流调结论必须做统计检验'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 506. 医学统计学 (医学) → 医学文献阅读与循证 (医学)
--    读懂临床研究结论需要统计学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '读懂临床研究结论需要统计学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '医学统计学'
  AND s2.`name` = '医学文献阅读与循证'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '医学统计学'
JOIN `zy_skill` s2 ON s2.`name` = '医学文献阅读与循证'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '读懂临床研究结论需要统计学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 507. 生物化学实验 (医学) → 分子生物学实验 (理学)  [跨门类]
--    分子实验建立在生化原理上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '分子实验建立在生化原理上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '生物化学实验'
  AND s2.`name` = '分子生物学实验'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '生物化学实验'
JOIN `zy_skill` s2 ON s2.`name` = '分子生物学实验'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '分子实验建立在生化原理上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 508. 细胞培养技术 (理学) → 分子生物学实验 (理学)
--    细胞体系是分子实验的载体
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '细胞体系是分子实验的载体'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '细胞培养技术'
  AND s2.`name` = '分子生物学实验'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '细胞培养技术'
JOIN `zy_skill` s2 ON s2.`name` = '分子生物学实验'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '细胞体系是分子实验的载体'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 509. 分子生物学实验 (理学) → 蛋白质表达与纯化 (理学)
--    表达纯化是分子实验的核心流程
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '表达纯化是分子实验的核心流程'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '分子生物学实验'
  AND s2.`name` = '蛋白质表达与纯化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '分子生物学实验'
JOIN `zy_skill` s2 ON s2.`name` = '蛋白质表达与纯化'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '表达纯化是分子实验的核心流程'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 510. 药理学与用药指导 (医学) → 临床用药监护 (医学)
--    不懂药理无法监护用药
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '不懂药理无法监护用药'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '药理学与用药指导'
  AND s2.`name` = '临床用药监护'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '药理学与用药指导'
JOIN `zy_skill` s2 ON s2.`name` = '临床用药监护'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '不懂药理无法监护用药'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 511. 药物合成与工艺 (医学) → 药物分析与检测 (医学)
--    合成产物必须做质量分析
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '合成产物必须做质量分析'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '药物合成与工艺'
  AND s2.`name` = '药物分析与检测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '药物合成与工艺'
JOIN `zy_skill` s2 ON s2.`name` = '药物分析与检测'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '合成产物必须做质量分析'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 512. 基础护理操作 (医学) → 急救护理 (医学)
--    急救护理在基础护理之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '急救护理在基础护理之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '基础护理操作'
  AND s2.`name` = '急救护理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '基础护理操作'
JOIN `zy_skill` s2 ON s2.`name` = '急救护理'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '急救护理在基础护理之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 513. 微生物培养与鉴定 (理学) → 免疫学实验技术 (医学)  [跨门类]
--    免疫实验常需培养与鉴定微生物
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.7000, 1, '免疫实验常需培养与鉴定微生物'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '微生物培养与鉴定'
  AND s2.`name` = '免疫学实验技术'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '微生物培养与鉴定'
JOIN `zy_skill` s2 ON s2.`name` = '免疫学实验技术'
SET o.`weight` = 0.7000, o.`directed` = 1,
    o.`remark` = '免疫实验常需培养与鉴定微生物'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 514. 遗传学与基因编辑 (理学) → 蛋白质表达与纯化 (理学)
--    编辑效果要通过蛋白层面验证
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '编辑效果要通过蛋白层面验证'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '遗传学与基因编辑'
  AND s2.`name` = '蛋白质表达与纯化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '遗传学与基因编辑'
JOIN `zy_skill` s2 ON s2.`name` = '蛋白质表达与纯化'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '编辑效果要通过蛋白层面验证'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 515. 土壤污染修复 (工学) → 作物栽培与田间管理 (农学)  [跨门类]
--    栽培方案要依据土壤条件
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '栽培方案要依据土壤条件'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '土壤污染修复'
  AND s2.`name` = '作物栽培与田间管理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '土壤污染修复'
JOIN `zy_skill` s2 ON s2.`name` = '作物栽培与田间管理'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '栽培方案要依据土壤条件'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 516. 遗传学与基因编辑 (理学) → 作物育种与良种繁育 (农学)  [跨门类]
--    育种的理论与工具来自遗传学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '育种的理论与工具来自遗传学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '遗传学与基因编辑'
  AND s2.`name` = '作物育种与良种繁育'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '遗传学与基因编辑'
JOIN `zy_skill` s2 ON s2.`name` = '作物育种与良种繁育'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '育种的理论与工具来自遗传学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 517. 微生物培养与鉴定 (理学) → 植物病理与诊断 (农学)  [跨门类]
--    病原诊断依赖微生物培养
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '病原诊断依赖微生物培养'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '微生物培养与鉴定'
  AND s2.`name` = '植物病理与诊断'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '微生物培养与鉴定'
JOIN `zy_skill` s2 ON s2.`name` = '植物病理与诊断'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '病原诊断依赖微生物培养'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 518. 水文观测与计算 (理学) → 农业遥感与估产 (农学)  [跨门类]
--    农情分析需要水文与气象数据
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '农情分析需要水文与气象数据'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '水文观测与计算'
  AND s2.`name` = '农业遥感与估产'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '水文观测与计算'
JOIN `zy_skill` s2 ON s2.`name` = '农业遥感与估产'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '农情分析需要水文与气象数据'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 519. 森林资源调查 (农学) → 森林生态与碳汇 (农学)
--    碳汇计量建立在资源调查数据上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '碳汇计量建立在资源调查数据上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '森林资源调查'
  AND s2.`name` = '森林生态与碳汇'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '森林资源调查'
JOIN `zy_skill` s2 ON s2.`name` = '森林生态与碳汇'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '碳汇计量建立在资源调查数据上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 520. 食品工程原理 (农学) → 食品加工工艺 (农学)
--    加工工艺建立在工程原理上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '加工工艺建立在工程原理上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '食品工程原理'
  AND s2.`name` = '食品加工工艺'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '食品工程原理'
JOIN `zy_skill` s2 ON s2.`name` = '食品加工工艺'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '加工工艺建立在工程原理上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 521. 食品微生物检验 (农学) → 食品安全与检测 (医学)  [跨门类]
--    微生物检验是食安检测的核心项
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '微生物检验是食安检测的核心项'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '食品微生物检验'
  AND s2.`name` = '食品安全与检测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '食品微生物检验'
JOIN `zy_skill` s2 ON s2.`name` = '食品安全与检测'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '微生物检验是食安检测的核心项'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 522. 微观与宏观经济学 (经济学) → 计量经济学分析 (经济学)
--    计量模型要有经济学理论支撑
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '计量模型要有经济学理论支撑'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '微观与宏观经济学'
  AND s2.`name` = '计量经济学分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '微观与宏观经济学'
JOIN `zy_skill` s2 ON s2.`name` = '计量经济学分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '计量模型要有经济学理论支撑'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 523. 概率论与数理统计 (理学) → 计量经济学分析 (经济学)  [跨门类]
--    计量推断完全是统计推断
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '计量推断完全是统计推断'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '概率论与数理统计'
  AND s2.`name` = '计量经济学分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '概率论与数理统计'
JOIN `zy_skill` s2 ON s2.`name` = '计量经济学分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '计量推断完全是统计推断'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 524. 会计实务与记账 (经济学) → 财务报表分析 (经济学)
--    先会记账才读得懂报表
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '先会记账才读得懂报表'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '会计实务与记账'
  AND s2.`name` = '财务报表分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '会计实务与记账'
JOIN `zy_skill` s2 ON s2.`name` = '财务报表分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '先会记账才读得懂报表'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 525. 财务报表分析 (经济学) → 投资理财与资产配置 (经济学)
--    基本面分析以报表为据
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '基本面分析以报表为据'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '财务报表分析'
  AND s2.`name` = '投资理财与资产配置'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '财务报表分析'
JOIN `zy_skill` s2 ON s2.`name` = '投资理财与资产配置'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '基本面分析以报表为据'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 526. 证券投资分析 (经济学) → 量化投资策略 (经济学)
--    量化策略是投资分析的程序化
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '量化策略是投资分析的程序化'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '证券投资分析'
  AND s2.`name` = '量化投资策略'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '证券投资分析'
JOIN `zy_skill` s2 ON s2.`name` = '量化投资策略'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '量化策略是投资分析的程序化'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 527. Python 金融数据分析 (经济学) → 量化投资策略 (经济学)
--    策略实现依赖数据处理能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '策略实现依赖数据处理能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Python 金融数据分析'
  AND s2.`name` = '量化投资策略'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Python 金融数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '量化投资策略'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '策略实现依赖数据处理能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 528. 概率论与数理统计 (理学) → 保险精算基础 (经济学)  [跨门类]
--    精算以概率统计为数学底座
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '精算以概率统计为数学底座'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '概率论与数理统计'
  AND s2.`name` = '保险精算基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '概率论与数理统计'
JOIN `zy_skill` s2 ON s2.`name` = '保险精算基础'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '精算以概率统计为数学底座'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 529. 项目管理 PMP (经济学) → 项目管理与进度把控 (工学)  [跨门类]
--    PMP 体系是项目管理的知识框架
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, 'PMP 体系是项目管理的知识框架'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '项目管理 PMP'
  AND s2.`name` = '项目管理与进度把控'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '项目管理 PMP'
JOIN `zy_skill` s2 ON s2.`name` = '项目管理与进度把控'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = 'PMP 体系是项目管理的知识框架'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 530. 市场调研与用户洞察 (经济学) → 营销策划与推广 (经济学)
--    没有洞察就没有有效策划
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '没有洞察就没有有效策划'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '市场调研与用户洞察'
  AND s2.`name` = '营销策划与推广'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '市场调研与用户洞察'
JOIN `zy_skill` s2 ON s2.`name` = '营销策划与推广'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '没有洞察就没有有效策划'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 531. 人力资源管理 (经济学) → 组织行为与团队建设 (经济学)
--    人力资源管理以组织行为学为基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '人力资源管理以组织行为学为基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '人力资源管理'
  AND s2.`name` = '组织行为与团队建设'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '人力资源管理'
JOIN `zy_skill` s2 ON s2.`name` = '组织行为与团队建设'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '人力资源管理以组织行为学为基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 532. 商业数据分析 (经济学) → 报表自动化与看板 (理学)  [跨门类]
--    分析成果最终以看板交付
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '分析成果最终以看板交付'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '商业数据分析'
  AND s2.`name` = '报表自动化与看板'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '商业数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '报表自动化与看板'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '分析成果最终以看板交付'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 533. Excel 数据处理与函数 (工学) → Excel 财务建模 (经济学)  [跨门类]
--    财务建模建立在表格函数能力上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '财务建模建立在表格函数能力上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Excel 数据处理与函数'
  AND s2.`name` = 'Excel 财务建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Excel 数据处理与函数'
JOIN `zy_skill` s2 ON s2.`name` = 'Excel 财务建模'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '财务建模建立在表格函数能力上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 534. 教育心理学应用 (教育学) → 教学设计 (教育学)
--    教学设计要符合学习规律
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '教学设计要符合学习规律'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '教育心理学应用'
  AND s2.`name` = '教学设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '教育心理学应用'
JOIN `zy_skill` s2 ON s2.`name` = '教学设计'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '教学设计要符合学习规律'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 535. 教学设计 (教育学) → 说课与试讲 (教育学)
--    先会设计再会讲
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '先会设计再会讲'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '教学设计'
  AND s2.`name` = '说课与试讲'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '教学设计'
JOIN `zy_skill` s2 ON s2.`name` = '说课与试讲'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '先会设计再会讲'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 536. 教育测量与评价 (教育学) → 教学反思与改进 (教育学)
--    没有测评数据无法判断改进方向
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '没有测评数据无法判断改进方向'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '教育测量与评价'
  AND s2.`name` = '教学反思与改进'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '教育测量与评价'
JOIN `zy_skill` s2 ON s2.`name` = '教学反思与改进'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '没有测评数据无法判断改进方向'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 537. 文献检索与信息素养 (管理学) → 开题与文献综述撰写 (管理学)
--    检索是综述的前置技能
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '检索是综述的前置技能'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '文献检索与信息素养'
  AND s2.`name` = '开题与文献综述撰写'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '文献检索与信息素养'
JOIN `zy_skill` s2 ON s2.`name` = '开题与文献综述撰写'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '检索是综述的前置技能'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 538. 开题与文献综述撰写 (管理学) → 学术英语写作 (文学)  [跨门类]
--    综述是论文写作的第一章
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '综述是论文写作的第一章'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '开题与文献综述撰写'
  AND s2.`name` = '学术英语写作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '开题与文献综述撰写'
JOIN `zy_skill` s2 ON s2.`name` = '学术英语写作'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '综述是论文写作的第一章'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 539. 信息组织与元数据 (管理学) → 档案整理与数字化 (管理学)
--    档案著录依赖元数据规范
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '档案著录依赖元数据规范'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '信息组织与元数据'
  AND s2.`name` = '档案整理与数字化'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '信息组织与元数据'
JOIN `zy_skill` s2 ON s2.`name` = '档案整理与数字化'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '档案著录依赖元数据规范'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 540. 历史文献数字化 (历史学) → 数字人文与文本挖掘 (管理学)  [跨门类]
--    数字化是文本挖掘的前提
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '数字化是文本挖掘的前提'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '历史文献数字化'
  AND s2.`name` = '数字人文与文本挖掘'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '历史文献数字化'
JOIN `zy_skill` s2 ON s2.`name` = '数字人文与文本挖掘'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '数字化是文本挖掘的前提'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 541. 史料整理与考据 (历史学) → 史学理论与方法 (历史学)
--    考据实践需要史学方法论支撑
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '考据实践需要史学方法论支撑'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '史料整理与考据'
  AND s2.`name` = '史学理论与方法'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '史料整理与考据'
JOIN `zy_skill` s2 ON s2.`name` = '史学理论与方法'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '考据实践需要史学方法论支撑'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 542. 逻辑学与论证分析 (哲学) → 哲学论文写作 (哲学)
--    哲学写作以论证分析为基本功
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '哲学写作以论证分析为基本功'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '逻辑学与论证分析'
  AND s2.`name` = '哲学论文写作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '逻辑学与论证分析'
JOIN `zy_skill` s2 ON s2.`name` = '哲学论文写作'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '哲学写作以论证分析为基本功'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 543. 口语发音纠正 (文学) → 英语口语陪练 (文学)
--    先纠正发音再进入陪练
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '先纠正发音再进入陪练'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '口语发音纠正'
  AND s2.`name` = '英语口语陪练'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '口语发音纠正'
JOIN `zy_skill` s2 ON s2.`name` = '英语口语陪练'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '先纠正发音再进入陪练'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 544. 英语口语陪练 (文学) → 口译与交替传译 (文学)
--    口译建立在口语流利度之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '口译建立在口语流利度之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '英语口语陪练'
  AND s2.`name` = '口译与交替传译'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '英语口语陪练'
JOIN `zy_skill` s2 ON s2.`name` = '口译与交替传译'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '口译建立在口语流利度之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 545. 机械制图与公差配合 (工学) → SolidWorks 三维建模 (工学)
--    三维建模前必须会读图与制图
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '三维建模前必须会读图与制图'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机械制图与公差配合'
  AND s2.`name` = 'SolidWorks 三维建模'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机械制图与公差配合'
JOIN `zy_skill` s2 ON s2.`name` = 'SolidWorks 三维建模'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '三维建模前必须会读图与制图'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 546. SolidWorks 三维建模 (工学) → 有限元分析 (工学)
--    仿真需要几何模型作为输入
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '仿真需要几何模型作为输入'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'SolidWorks 三维建模'
  AND s2.`name` = '有限元分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'SolidWorks 三维建模'
JOIN `zy_skill` s2 ON s2.`name` = '有限元分析'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '仿真需要几何模型作为输入'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 547. 理论力学与动力学 (理学) → 结构力学与受力分析 (工学)  [跨门类]
--    结构力学建立在理论力学之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '结构力学建立在理论力学之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '理论力学与动力学'
  AND s2.`name` = '结构力学与受力分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '理论力学与动力学'
JOIN `zy_skill` s2 ON s2.`name` = '结构力学与受力分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '结构力学建立在理论力学之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 548. 结构力学与受力分析 (工学) → 有限元分析 (工学)
--    有限元用于求解结构力学问题
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '有限元用于求解结构力学问题'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '结构力学与受力分析'
  AND s2.`name` = '有限元分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '结构力学与受力分析'
JOIN `zy_skill` s2 ON s2.`name` = '有限元分析'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '有限元用于求解结构力学问题'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 549. 流体力学基础 (理学) → 气动分析与CFD (工学)  [跨门类]
--    CFD 是流体力学方程的数值解法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, 'CFD 是流体力学方程的数值解法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '流体力学基础'
  AND s2.`name` = '气动分析与CFD'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '流体力学基础'
JOIN `zy_skill` s2 ON s2.`name` = '气动分析与CFD'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = 'CFD 是流体力学方程的数值解法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 550. 流体力学基础 (理学) → 暖通空调设计 (工学)  [跨门类]
--    暖通气流组织分析依赖流体计算
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '暖通气流组织分析依赖流体计算'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '流体力学基础'
  AND s2.`name` = '暖通空调设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '流体力学基础'
JOIN `zy_skill` s2 ON s2.`name` = '暖通空调设计'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '暖通气流组织分析依赖流体计算'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 551. 热力学与统计物理 (理学) → 暖通空调设计 (工学)  [跨门类]
--    暖通负荷计算直接来自传热与热力学
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '暖通负荷计算直接来自传热与热力学'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '热力学与统计物理'
  AND s2.`name` = '暖通空调设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '热力学与统计物理'
JOIN `zy_skill` s2 ON s2.`name` = '暖通空调设计'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '暖通负荷计算直接来自传热与热力学'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 552. 数字电路设计 (工学) → FPGA 与数字逻辑 (工学)
--    FPGA 是数字逻辑的实现载体
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, 'FPGA 是数字逻辑的实现载体'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数字电路设计'
  AND s2.`name` = 'FPGA 与数字逻辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数字电路设计'
JOIN `zy_skill` s2 ON s2.`name` = 'FPGA 与数字逻辑'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = 'FPGA 是数字逻辑的实现载体'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 553. 电路原理与仿真 (工学) → 模拟电路设计 (工学)
--    模拟设计建立在电路分析基础上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '模拟设计建立在电路分析基础上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '电路原理与仿真'
  AND s2.`name` = '模拟电路设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '电路原理与仿真'
JOIN `zy_skill` s2 ON s2.`name` = '模拟电路设计'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '模拟设计建立在电路分析基础上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 554. 模拟电路设计 (工学) → PCB 设计与制板 (工学)
--    原理图验证后才画板
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '原理图验证后才画板'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '模拟电路设计'
  AND s2.`name` = 'PCB 设计与制板'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '模拟电路设计'
JOIN `zy_skill` s2 ON s2.`name` = 'PCB 设计与制板'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '原理图验证后才画板'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 555. 通信原理与信号处理 (工学) → 无线通信模块调试 (工学)
--    射频调试需要通信原理基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '射频调试需要通信原理基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '通信原理与信号处理'
  AND s2.`name` = '无线通信模块调试'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '通信原理与信号处理'
JOIN `zy_skill` s2 ON s2.`name` = '无线通信模块调试'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '射频调试需要通信原理基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 556. 通信原理与信号处理 (工学) → 信号采集与滤波 (工学)
--    滤波是信号处理的基本操作
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '滤波是信号处理的基本操作'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '通信原理与信号处理'
  AND s2.`name` = '信号采集与滤波'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '通信原理与信号处理'
JOIN `zy_skill` s2 ON s2.`name` = '信号采集与滤波'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '滤波是信号处理的基本操作'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 557. 机器人控制与编程 (工学) → 工业机器人编程 (工学)
--    工业机器人是机器人控制的专门平台
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '工业机器人是机器人控制的专门平台'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机器人控制与编程'
  AND s2.`name` = '工业机器人编程'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机器人控制与编程'
JOIN `zy_skill` s2 ON s2.`name` = '工业机器人编程'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '工业机器人是机器人控制的专门平台'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 558. 理论力学与动力学 (理学) → 机器人控制与编程 (工学)  [跨门类]
--    机器人运动学建立在理论力学上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '机器人运动学建立在理论力学上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '理论力学与动力学'
  AND s2.`name` = '机器人控制与编程'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '理论力学与动力学'
JOIN `zy_skill` s2 ON s2.`name` = '机器人控制与编程'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '机器人运动学建立在理论力学上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 559. 有机化学合成 (理学) → 化工实验操作 (工学)  [跨门类]
--    合成是化工实验的核心操作之一
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '合成是化工实验的核心操作之一'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '有机化学合成'
  AND s2.`name` = '化工实验操作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '有机化学合成'
JOIN `zy_skill` s2 ON s2.`name` = '化工实验操作'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '合成是化工实验的核心操作之一'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 560. 分析化学与滴定 (理学) → 仪器分析与检测 (工学)  [跨门类]
--    仪器分析是分析化学的仪器化
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '仪器分析是分析化学的仪器化'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '分析化学与滴定'
  AND s2.`name` = '仪器分析与检测'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '分析化学与滴定'
JOIN `zy_skill` s2 ON s2.`name` = '仪器分析与检测'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '仪器分析是分析化学的仪器化'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 561. 无机化学与配位 (理学) → 材料制备与合成 (工学)  [跨门类]
--    材料制备大量是无机化学过程
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '材料制备大量是无机化学过程'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '无机化学与配位'
  AND s2.`name` = '材料制备与合成'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '无机化学与配位'
JOIN `zy_skill` s2 ON s2.`name` = '材料制备与合成'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '材料制备大量是无机化学过程'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 562. 物理化学与热力学 (理学) → 电化学与电池 (理学)
--    电池机理属于电化学范畴
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '电池机理属于电化学范畴'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '物理化学与热力学'
  AND s2.`name` = '电化学与电池'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '物理化学与热力学'
JOIN `zy_skill` s2 ON s2.`name` = '电化学与电池'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '电池机理属于电化学范畴'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 563. 大学物理实验 (理学) → 材料表征与测试 (工学)  [跨门类]
--    表征数据处理依赖实验数据处理能力
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.7000, 1, '表征数据处理依赖实验数据处理能力'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '大学物理实验'
  AND s2.`name` = '材料表征与测试'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '大学物理实验'
JOIN `zy_skill` s2 ON s2.`name` = '材料表征与测试'
SET o.`weight` = 0.7000, o.`directed` = 1,
    o.`remark` = '表征数据处理依赖实验数据处理能力'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 564. 遗传学与基因编辑 (理学) → 生物信息学分析 (理学)
--    测序结果必须放在遗传学框架里解读
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '测序结果必须放在遗传学框架里解读'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '遗传学与基因编辑'
  AND s2.`name` = '生物信息学分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '遗传学与基因编辑'
JOIN `zy_skill` s2 ON s2.`name` = '生物信息学分析'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '测序结果必须放在遗传学框架里解读'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 565. 地理信息系统建库 (理学) → GIS 空间分析 (理学)
--    空间分析需要可用的空间数据库
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '空间分析需要可用的空间数据库'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '地理信息系统建库'
  AND s2.`name` = 'GIS 空间分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '地理信息系统建库'
JOIN `zy_skill` s2 ON s2.`name` = 'GIS 空间分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '空间分析需要可用的空间数据库'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 566. 地图制图与可视化 (理学) → GIS 空间分析 (理学)
--    空间分析的产出是专题地图
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '空间分析的产出是专题地图'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '地图制图与可视化'
  AND s2.`name` = 'GIS 空间分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '地图制图与可视化'
JOIN `zy_skill` s2 ON s2.`name` = 'GIS 空间分析'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '空间分析的产出是专题地图'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 567. 构造地质分析 (理学) → 野外地质与地貌考察 (理学)
--    野外考察需要构造分析框架
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '野外考察需要构造分析框架'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '构造地质分析'
  AND s2.`name` = '野外地质与地貌考察'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '构造地质分析'
JOIN `zy_skill` s2 ON s2.`name` = '野外地质与地貌考察'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '野外考察需要构造分析框架'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 568. 水文地质调查 (理学) → 地球物理勘探 (理学)
--    地质调查常配合物探手段
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.7000, 1, '地质调查常配合物探手段'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '水文地质调查'
  AND s2.`name` = '地球物理勘探'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '水文地质调查'
JOIN `zy_skill` s2 ON s2.`name` = '地球物理勘探'
SET o.`weight` = 0.7000, o.`directed` = 1,
    o.`remark` = '地质调查常配合物探手段'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 569. 天气分析与预报 (理学) → 数值天气预报 (理学)
--    数值预报建立在天气分析之上
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '数值预报建立在天气分析之上'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '天气分析与预报'
  AND s2.`name` = '数值天气预报'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '天气分析与预报'
JOIN `zy_skill` s2 ON s2.`name` = '数值天气预报'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '数值预报建立在天气分析之上'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 570. 气象数据分析 (理学) → 气候统计与诊断 (理学)
--    气候诊断以气象数据处理为前置
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '气候诊断以气象数据处理为前置'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '气象数据分析'
  AND s2.`name` = '气候统计与诊断'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '气象数据分析'
JOIN `zy_skill` s2 ON s2.`name` = '气候统计与诊断'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '气候诊断以气象数据处理为前置'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 571. 海洋调查与观测 (理学) → 海洋数据分析 (理学)
--    观测数据是海洋分析的数据来源
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '观测数据是海洋分析的数据来源'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '海洋调查与观测'
  AND s2.`name` = '海洋数据分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '海洋调查与观测'
JOIN `zy_skill` s2 ON s2.`name` = '海洋数据分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '观测数据是海洋分析的数据来源'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 572. 实验心理学设计 (理学) → 心理测量与量表分析 (理学)
--    量表编制需要实验与测量学基础
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.8000, 1, '量表编制需要实验与测量学基础'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '实验心理学设计'
  AND s2.`name` = '心理测量与量表分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '实验心理学设计'
JOIN `zy_skill` s2 ON s2.`name` = '心理测量与量表分析'
SET o.`weight` = 0.8000, o.`directed` = 1,
    o.`remark` = '量表编制需要实验与测量学基础'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- 573. 抽样调查设计 (理学) → 社会调查与统计分析 (管理学)  [跨门类]
--    调查方案决定分析的可能性
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'PREREQUISITE', 0.9000, 1, '调查方案决定分析的可能性'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '抽样调查设计'
  AND s2.`name` = '社会调查与统计分析'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'PREREQUISITE');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '抽样调查设计'
JOIN `zy_skill` s2 ON s2.`name` = '社会调查与统计分析'
SET o.`weight` = 0.9000, o.`directed` = 1,
    o.`remark` = '调查方案决定分析的可能性'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'PREREQUISITE';

-- --------------------------------------------------------------------------
-- SYNONYM
-- --------------------------------------------------------------------------

-- 574. JS 动画与交互实现 (工学) ↔ 界面动效实现 (艺术学)  [跨门类]
--    同一能力的描述侧与实现侧叫法不同
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '同一能力的描述侧与实现侧叫法不同'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'JS 动画与交互实现'
  AND s2.`name` = '界面动效实现'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'JS 动画与交互实现'
JOIN `zy_skill` s2 ON s2.`name` = '界面动效实现'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '同一能力的描述侧与实现侧叫法不同'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 575. 剪映快速剪辑 (艺术学) ↔ 视频剪辑 (艺术学)
--    轻量工具与通用剪辑能力指向同一件事
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '轻量工具与通用剪辑能力指向同一件事'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '剪映快速剪辑'
  AND s2.`name` = '视频剪辑'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '剪映快速剪辑'
JOIN `zy_skill` s2 ON s2.`name` = '视频剪辑'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '轻量工具与通用剪辑能力指向同一件事'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 576. Photoshop 图像处理 (艺术学) ↔ 平面设计基础 (艺术学)
--    在有 PS 底子的语境里两者常被当作同一技能
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '在有 PS 底子的语境里两者常被当作同一技能'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Photoshop 图像处理'
  AND s2.`name` = '平面设计基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Photoshop 图像处理'
JOIN `zy_skill` s2 ON s2.`name` = '平面设计基础'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '在有 PS 底子的语境里两者常被当作同一技能'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 577. Illustrator 矢量绘图 (艺术学) ↔ 平面设计基础 (艺术学)
--    矢量绘制是平面设计的主要实现方式
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '矢量绘制是平面设计的主要实现方式'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Illustrator 矢量绘图'
  AND s2.`name` = '平面设计基础'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Illustrator 矢量绘图'
JOIN `zy_skill` s2 ON s2.`name` = '平面设计基础'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '矢量绘制是平面设计的主要实现方式'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 578. Figma 界面设计 (艺术学) ↔ Sketch 与设计交付 (艺术学)
--    两者都是界面设计工具，能力等价
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '两者都是界面设计工具，能力等价'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Figma 界面设计'
  AND s2.`name` = 'Sketch 与设计交付'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Figma 界面设计'
JOIN `zy_skill` s2 ON s2.`name` = 'Sketch 与设计交付'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '两者都是界面设计工具，能力等价'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 579. Figma 界面设计与协作 (艺术学) ↔ UI/UX 设计 (艺术学)
--    工具名与能力名互指
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '工具名与能力名互指'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Figma 界面设计与协作'
  AND s2.`name` = 'UI/UX 设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Figma 界面设计与协作'
JOIN `zy_skill` s2 ON s2.`name` = 'UI/UX 设计'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '工具名与能力名互指'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 580. 数学建模 (理学) ↔ 数学建模竞赛实战 (理学)
--    方法能力与竞赛强度训练指向同一技能
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '方法能力与竞赛强度训练指向同一技能'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数学建模'
  AND s2.`name` = '数学建模竞赛实战'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数学建模'
JOIN `zy_skill` s2 ON s2.`name` = '数学建模竞赛实战'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '方法能力与竞赛强度训练指向同一技能'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 581. 数据爬取与清洗 (工学) ↔ 爬虫与网页数据采集 (工学)
--    同一流程的两种命名
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '同一流程的两种命名'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据爬取与清洗'
  AND s2.`name` = '爬虫与网页数据采集'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据爬取与清洗'
JOIN `zy_skill` s2 ON s2.`name` = '爬虫与网页数据采集'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '同一流程的两种命名'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 582. 数据结构与算法 (工学) ↔ 算法与数据结构 (工学)
--    同一门课的两种叫法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '同一门课的两种叫法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '数据结构与算法'
  AND s2.`name` = '算法与数据结构'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '数据结构与算法'
JOIN `zy_skill` s2 ON s2.`name` = '算法与数据结构'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '同一门课的两种叫法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 583. ECharts 数据可视化 (工学) ↔ 数据可视化图表设计 (工学)
--    库名与能力名互指
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '库名与能力名互指'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'ECharts 数据可视化'
  AND s2.`name` = '数据可视化图表设计'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'ECharts 数据可视化'
JOIN `zy_skill` s2 ON s2.`name` = '数据可视化图表设计'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '库名与能力名互指'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 584. Jupyter Notebook 数据分析 (工学) ↔ Python 科学计算 (理学)  [跨门类]
--    同一套工具链的不同表述
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '同一套工具链的不同表述'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = 'Jupyter Notebook 数据分析'
  AND s2.`name` = 'Python 科学计算'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = 'Jupyter Notebook 数据分析'
JOIN `zy_skill` s2 ON s2.`name` = 'Python 科学计算'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '同一套工具链的不同表述'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 585. 机器学习建模 (工学) ↔ 模型评估与调参 (工学)
--    在项目语境里两者常被当作同一环节
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '在项目语境里两者常被当作同一环节'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '机器学习建模'
  AND s2.`name` = '模型评估与调参'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '机器学习建模'
JOIN `zy_skill` s2 ON s2.`name` = '模型评估与调参'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '在项目语境里两者常被当作同一环节'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 586. 大模型 API 应用开发 (工学) ↔ 自然语言处理 (工学)
--    应用侧常用后者指代前者
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '应用侧常用后者指代前者'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '大模型 API 应用开发'
  AND s2.`name` = '自然语言处理'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '大模型 API 应用开发'
JOIN `zy_skill` s2 ON s2.`name` = '自然语言处理'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '应用侧常用后者指代前者'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 587. 知识图谱与图数据库 (工学) ↔ 知识图谱构建 (管理学)  [跨门类]
--    同一能力的两种称法
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '同一能力的两种称法'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '知识图谱与图数据库'
  AND s2.`name` = '知识图谱构建'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '知识图谱与图数据库'
JOIN `zy_skill` s2 ON s2.`name` = '知识图谱构建'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '同一能力的两种称法'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 588. 工程测量与变形监测 (工学) ↔ 工程测量与放线 (工学)
--    测量能力的两个应用场景常被合并称呼
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '测量能力的两个应用场景常被合并称呼'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '工程测量与变形监测'
  AND s2.`name` = '工程测量与放线'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '工程测量与变形监测'
JOIN `zy_skill` s2 ON s2.`name` = '工程测量与放线'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '测量能力的两个应用场景常被合并称呼'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 589. 视频号与新媒体运营 (文学) ↔ 视频号内容制作 (工学)  [跨门类]
--    制作与运营在岗位名称上常混用
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '制作与运营在岗位名称上常混用'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '视频号与新媒体运营'
  AND s2.`name` = '视频号内容制作'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '视频号与新媒体运营'
JOIN `zy_skill` s2 ON s2.`name` = '视频号内容制作'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '制作与运营在岗位名称上常混用'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- 590. 参考文献管理与规范 (管理学) ↔ 学术引用格式规范 (文学)  [跨门类]
--    引注格式与文献管理在写作流程里是一件事
INSERT INTO `zy_skill_ontology`
    (`src_skill_id`, `dst_skill_id`, `relation_type`, `weight`, `directed`, `remark`)
SELECT s1.id, s2.id, 'SYNONYM', 1.0000, 0, '引注格式与文献管理在写作流程里是一件事'
FROM `zy_skill` s1, `zy_skill` s2
WHERE s1.`name` = '参考文献管理与规范'
  AND s2.`name` = '学术引用格式规范'
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.`src_skill_id` = s1.id
                    AND o.`dst_skill_id` = s2.id
                    AND o.`relation_type` = 'SYNONYM');
UPDATE `zy_skill_ontology` o
JOIN `zy_skill` s1 ON s1.`name` = '参考文献管理与规范'
JOIN `zy_skill` s2 ON s2.`name` = '学术引用格式规范'
SET o.`weight` = 1.0000, o.`directed` = 0,
    o.`remark` = '引注格式与文献管理在写作流程里是一件事'
WHERE o.`src_skill_id` = s1.id AND o.`dst_skill_id` = s2.id
  AND o.`relation_type` = 'SYNONYM';

-- =============================================================================
-- 统计核对
-- =============================================================================
SELECT `relation_type`, COUNT(*) AS edges,
       SUM(CASE WHEN `directed` = 1 THEN 1 ELSE 0 END) AS directed_edges
FROM `zy_skill_ontology` GROUP BY `relation_type` ORDER BY edges DESC;

-- 跨门类边占比（体现"跨学科"是否真的落到数据上）
SELECT SUM(CASE WHEN a.category_l1 <> b.category_l1 THEN 1 ELSE 0 END) AS cross_category,
       COUNT(*) AS total,
       ROUND(100.0 * SUM(CASE WHEN a.category_l1 <> b.category_l1 THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS cross_pct
FROM `zy_skill_ontology` o
JOIN `zy_skill` a ON a.id = o.src_skill_id
JOIN `zy_skill` b ON b.id = o.dst_skill_id;

-- 孤点技能数：完全没有任何边的技能，就是图谱里看不见的节点
SELECT COUNT(*) AS isolated_skills FROM `zy_skill` s
WHERE s.`status` = 1
  AND NOT EXISTS (SELECT 1 FROM `zy_skill_ontology` o
                  WHERE o.src_skill_id = s.id OR o.dst_skill_id = s.id);
