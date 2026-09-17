-- =============================================================================
--  知驿·漫游 —— 技能本体种子数据（由 gen_ontology.py 生成，请勿手工修改）
--
--  规模：见文件末尾统计。覆盖 13 个学科门类、多个二级学科。
--  别名（alias）是 FR-M2-07「同义词库 / 跨域术语映射」的载体，
--  登记原则：只要某个说法是学生真实会用的表达、且不是标签名的子串，就登记。
--
--  幂等：同名技能已存在时只更新别名/描述/难度/门类，不重复插入。
-- =============================================================================

USE `zhiyi_manyou`;

INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Vue 前端开发', 'vue|vue3|vue.js|前端框架', '工学', '计算机科学与技术', 3, '基于组件化的前端框架，构建交互式网页应用', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Vue 前端开发');
UPDATE `zy_skill` SET `alias` = 'vue|vue3|vue.js|前端框架', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '基于组件化的前端框架，构建交互式网页应用' WHERE `name` = 'Vue 前端开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'React 前端开发', 'react|reactjs|前端框架|jsx', '工学', '计算机科学与技术', 3, '用 React 构建组件化单页应用与状态管理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'React 前端开发');
UPDATE `zy_skill` SET `alias` = 'react|reactjs|前端框架|jsx', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 React 构建组件化单页应用与状态管理' WHERE `name` = 'React 前端开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'JS 动画与交互实现', 'js动画|前端动效|交互动效|滚动动画', '工学', '计算机科学与技术', 3, '用 JavaScript 实现页面动效、滚动动画与交互反馈', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'JS 动画与交互实现');
UPDATE `zy_skill` SET `alias` = 'js动画|前端动效|交互动效|滚动动画', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 JavaScript 实现页面动效、滚动动画与交互反馈' WHERE `name` = 'JS 动画与交互实现' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'CSS 样式与响应式布局', 'css|样式|flex|grid|响应式|适配', '工学', '计算机科学与技术', 2, '用 CSS 完成页面布局、响应式适配与视觉还原', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'CSS 样式与响应式布局');
UPDATE `zy_skill` SET `alias` = 'css|样式|flex|grid|响应式|适配', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '用 CSS 完成页面布局、响应式适配与视觉还原' WHERE `name` = 'CSS 样式与响应式布局' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'TypeScript 类型化开发', 'ts|typescript|类型系统', '工学', '计算机科学与技术', 3, '为 JavaScript 项目引入静态类型，提升可维护性', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'TypeScript 类型化开发');
UPDATE `zy_skill` SET `alias` = 'ts|typescript|类型系统', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '为 JavaScript 项目引入静态类型，提升可维护性' WHERE `name` = 'TypeScript 类型化开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Webpack 与前端工程化', 'webpack|vite|打包构建|工程化', '工学', '计算机科学与技术', 4, '配置构建工具、代码分割与产物优化', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Webpack 与前端工程化');
UPDATE `zy_skill` SET `alias` = 'webpack|vite|打包构建|工程化', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '配置构建工具、代码分割与产物优化' WHERE `name` = 'Webpack 与前端工程化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '前端性能优化', '性能优化|首屏优化|lighthouse|加载速度', '工学', '计算机科学与技术', 4, '分析并优化首屏时间、打包体积与运行时性能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '前端性能优化');
UPDATE `zy_skill` SET `alias` = '性能优化|首屏优化|lighthouse|加载速度', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '分析并优化首屏时间、打包体积与运行时性能' WHERE `name` = '前端性能优化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '浏览器渲染与调试', '浏览器原理|渲染机制|devtools|调试', '工学', '计算机科学与技术', 4, '理解渲染管线，用开发者工具定位布局与性能问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '浏览器渲染与调试');
UPDATE `zy_skill` SET `alias` = '浏览器原理|渲染机制|devtools|调试', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '理解渲染管线，用开发者工具定位布局与性能问题' WHERE `name` = '浏览器渲染与调试' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Java 后端开发', 'java|spring|后端开发|服务端', '工学', '计算机科学与技术', 3, '用 Java 与 Spring 生态实现服务端业务逻辑', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Java 后端开发');
UPDATE `zy_skill` SET `alias` = 'java|spring|后端开发|服务端', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Java 与 Spring 生态实现服务端业务逻辑' WHERE `name` = 'Java 后端开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Spring Boot 应用开发', 'springboot|spring boot|微服务基础', '工学', '计算机科学与技术', 3, '用 Spring Boot 快速搭建 REST 服务与数据访问层', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Spring Boot 应用开发');
UPDATE `zy_skill` SET `alias` = 'springboot|spring boot|微服务基础', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Spring Boot 快速搭建 REST 服务与数据访问层' WHERE `name` = 'Spring Boot 应用开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Python 后端开发', 'python后端|django|flask|fastapi', '工学', '计算机科学与技术', 3, '用 Python 框架实现 Web 服务与脚本工具', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Python 后端开发');
UPDATE `zy_skill` SET `alias` = 'python后端|django|flask|fastapi', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Python 框架实现 Web 服务与脚本工具' WHERE `name` = 'Python 后端开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Go 语言后端开发', 'golang|go|高并发服务', '工学', '计算机科学与技术', 4, '用 Go 编写高并发网络服务与工具', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Go 语言后端开发');
UPDATE `zy_skill` SET `alias` = 'golang|go|高并发服务', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '用 Go 编写高并发网络服务与工具' WHERE `name` = 'Go 语言后端开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'RESTful 接口设计', 'rest|api设计|接口规范', '工学', '计算机科学与技术', 3, '设计清晰一致的 HTTP 接口与错误约定', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'RESTful 接口设计');
UPDATE `zy_skill` SET `alias` = 'rest|api设计|接口规范', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '设计清晰一致的 HTTP 接口与错误约定' WHERE `name` = 'RESTful 接口设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'MySQL 数据库设计与优化', 'mysql|数据库设计|索引优化|sql调优', '工学', '计算机科学与技术', 4, '设计表结构、索引与慢查询优化', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'MySQL 数据库设计与优化');
UPDATE `zy_skill` SET `alias` = 'mysql|数据库设计|索引优化|sql调优', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '设计表结构、索引与慢查询优化' WHERE `name` = 'MySQL 数据库设计与优化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Redis 缓存应用', 'redis|缓存|分布式锁', '工学', '计算机科学与技术', 3, '用 Redis 做缓存、计数与分布式锁', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Redis 缓存应用');
UPDATE `zy_skill` SET `alias` = 'redis|缓存|分布式锁', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Redis 做缓存、计数与分布式锁' WHERE `name` = 'Redis 缓存应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据结构与算法', '算法|数据结构|leetcode|刷题', '工学', '计算机科学与技术', 4, '掌握常见算法思想与复杂度分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据结构与算法');
UPDATE `zy_skill` SET `alias` = '算法|数据结构|leetcode|刷题', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '掌握常见算法思想与复杂度分析' WHERE `name` = '数据结构与算法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '算法竞赛训练', 'acm|icpc|算法竞赛|蓝桥杯', '工学', '计算机科学与技术', 5, '针对程序设计竞赛的算法强度训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '算法竞赛训练');
UPDATE `zy_skill` SET `alias` = 'acm|icpc|算法竞赛|蓝桥杯', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '针对程序设计竞赛的算法强度训练' WHERE `name` = '算法竞赛训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '操作系统原理', '操作系统|os|进程调度|内存管理', '工学', '计算机科学与技术', 4, '理解进程、内存、文件系统与并发', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '操作系统原理');
UPDATE `zy_skill` SET `alias` = '操作系统|os|进程调度|内存管理', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '理解进程、内存、文件系统与并发' WHERE `name` = '操作系统原理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '计算机网络基础', '计算机网络|tcp/ip|网络协议', '工学', '计算机科学与技术', 3, '理解 TCP/IP 协议栈与常见网络问题排查', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '计算机网络基础');
UPDATE `zy_skill` SET `alias` = '计算机网络|tcp/ip|网络协议', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '理解 TCP/IP 协议栈与常见网络问题排查' WHERE `name` = '计算机网络基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Linux 服务器运维', 'linux|shell|运维|服务器', '工学', '计算机科学与技术', 3, '在 Linux 上部署服务、排查故障与写脚本', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Linux 服务器运维');
UPDATE `zy_skill` SET `alias` = 'linux|shell|运维|服务器', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '在 Linux 上部署服务、排查故障与写脚本' WHERE `name` = 'Linux 服务器运维' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Docker 容器化部署', 'docker|容器|镜像|compose', '工学', '计算机科学与技术', 3, '把应用打包为容器并编排部署', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Docker 容器化部署');
UPDATE `zy_skill` SET `alias` = 'docker|容器|镜像|compose', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '把应用打包为容器并编排部署' WHERE `name` = 'Docker 容器化部署' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Git 版本控制与协作', 'git|github|版本控制|协作流程', '工学', '计算机科学与技术', 2, '分支管理、代码评审与协作规范', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Git 版本控制与协作');
UPDATE `zy_skill` SET `alias` = 'git|github|版本控制|协作流程', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '分支管理、代码评审与协作规范' WHERE `name` = 'Git 版本控制与协作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '单元测试与测试驱动', '单元测试|junit|pytest|tdd', '工学', '计算机科学与技术', 3, '编写可维护的自动化测试', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '单元测试与测试驱动');
UPDATE `zy_skill` SET `alias` = '单元测试|junit|pytest|tdd', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '编写可维护的自动化测试' WHERE `name` = '单元测试与测试驱动' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '软件需求与架构设计', '需求分析|系统设计|架构|uml', '工学', '计算机科学与技术', 4, '把业务需求转为可实现的系统设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '软件需求与架构设计');
UPDATE `zy_skill` SET `alias` = '需求分析|系统设计|架构|uml', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '把业务需求转为可实现的系统设计' WHERE `name` = '软件需求与架构设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '爬虫与网页数据采集', '爬虫|数据采集|scrapy|反爬', '工学', '计算机科学与技术', 3, '抓取网页数据并处理分页、登录与反爬', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '爬虫与网页数据采集');
UPDATE `zy_skill` SET `alias` = '爬虫|数据采集|scrapy|反爬', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '抓取网页数据并处理分页、登录与反爬' WHERE `name` = '爬虫与网页数据采集' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据爬取与清洗', '数据爬取|爬虫|数据采集|数据清洗', '工学', '计算机科学与技术', 3, '抓取数据并做去重、缺失值处理等清洗工作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据爬取与清洗');
UPDATE `zy_skill` SET `alias` = '数据爬取|爬虫|数据采集|数据清洗', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '抓取数据并做去重、缺失值处理等清洗工作' WHERE `name` = '数据爬取与清洗' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '移动端 App 开发', 'android|ios|app开发|移动端', '工学', '计算机科学与技术', 3, '开发原生或跨平台移动应用', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '移动端 App 开发');
UPDATE `zy_skill` SET `alias` = 'android|ios|app开发|移动端', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '开发原生或跨平台移动应用' WHERE `name` = '移动端 App 开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '小程序开发', '微信小程序|小程序|wxml', '工学', '计算机科学与技术', 3, '开发微信小程序前端与云开发后端', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '小程序开发');
UPDATE `zy_skill` SET `alias` = '微信小程序|小程序|wxml', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '开发微信小程序前端与云开发后端' WHERE `name` = '小程序开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '游戏开发入门', 'unity|游戏开发|godot', '工学', '计算机科学与技术', 4, '用引擎实现小游戏逻辑与交互', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '游戏开发入门');
UPDATE `zy_skill` SET `alias` = 'unity|游戏开发|godot', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '用引擎实现小游戏逻辑与交互' WHERE `name` = '游戏开发入门' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '网络安全基础', '网络安全|渗透测试|ctf|漏洞', '工学', '计算机科学与技术', 4, '理解常见漏洞原理与基本防护手段', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '网络安全基础');
UPDATE `zy_skill` SET `alias` = '网络安全|渗透测试|ctf|漏洞', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '理解常见漏洞原理与基本防护手段' WHERE `name` = '网络安全基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '区块链与智能合约', '区块链|solidity|智能合约|web3', '工学', '计算机科学与技术', 5, '编写与部署智能合约，理解链上机制', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '区块链与智能合约');
UPDATE `zy_skill` SET `alias` = '区块链|solidity|智能合约|web3', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '编写与部署智能合约，理解链上机制' WHERE `name` = '区块链与智能合约' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '云计算与服务器部署', '云服务器|阿里云|ecs|nginx', '工学', '计算机科学与技术', 3, '在云主机上部署与配置服务', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '云计算与服务器部署');
UPDATE `zy_skill` SET `alias` = '云服务器|阿里云|ecs|nginx', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '在云主机上部署与配置服务' WHERE `name` = '云计算与服务器部署' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Node.js 服务端开发', 'nodejs|node|express|koa', '工学', '计算机科学与技术', 3, '用 Node.js 实现服务端接口与中间件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Node.js 服务端开发');
UPDATE `zy_skill` SET `alias` = 'nodejs|node|express|koa', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Node.js 实现服务端接口与中间件' WHERE `name` = 'Node.js 服务端开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Nginx 配置与反向代理', 'nginx|反向代理|负载均衡|静态资源', '工学', '计算机科学与技术', 3, '配置反向代理、负载均衡与静态托管', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Nginx 配置与反向代理');
UPDATE `zy_skill` SET `alias` = 'nginx|反向代理|负载均衡|静态资源', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '配置反向代理、负载均衡与静态托管' WHERE `name` = 'Nginx 配置与反向代理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '消息队列应用', 'mq|kafka|rabbitmq|rocketmq', '工学', '计算机科学与技术', 4, '用消息队列解耦服务与削峰', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '消息队列应用');
UPDATE `zy_skill` SET `alias` = 'mq|kafka|rabbitmq|rocketmq', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '用消息队列解耦服务与削峰' WHERE `name` = '消息队列应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '微服务架构设计', '微服务|服务拆分|注册中心|网关', '工学', '计算机科学与技术', 5, '拆分服务并设计注册发现与网关', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '微服务架构设计');
UPDATE `zy_skill` SET `alias` = '微服务|服务拆分|注册中心|网关', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '拆分服务并设计注册发现与网关' WHERE `name` = '微服务架构设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Elasticsearch 全文检索', 'es|elasticsearch|全文检索|倒排索引', '工学', '计算机科学与技术', 4, '搭建全文检索与聚合分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Elasticsearch 全文检索');
UPDATE `zy_skill` SET `alias` = 'es|elasticsearch|全文检索|倒排索引', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '搭建全文检索与聚合分析' WHERE `name` = 'Elasticsearch 全文检索' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Docker Compose 编排', 'compose|多容器|编排', '工学', '计算机科学与技术', 3, '用 Compose 编排多容器应用', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Docker Compose 编排');
UPDATE `zy_skill` SET `alias` = 'compose|多容器|编排', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Compose 编排多容器应用' WHERE `name` = 'Docker Compose 编排' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Kubernetes 容器编排', 'k8s|kubernetes|集群|pod', '工学', '计算机科学与技术', 5, '在 K8s 上部署与运维服务', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Kubernetes 容器编排');
UPDATE `zy_skill` SET `alias` = 'k8s|kubernetes|集群|pod', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '在 K8s 上部署与运维服务' WHERE `name` = 'Kubernetes 容器编排' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Linux 性能排查', '性能排查|top|火焰图|strace', '工学', '计算机科学与技术', 5, '定位 CPU、内存与 IO 瓶颈', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Linux 性能排查');
UPDATE `zy_skill` SET `alias` = '性能排查|top|火焰图|strace', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '定位 CPU、内存与 IO 瓶颈' WHERE `name` = 'Linux 性能排查' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据库索引与慢查询优化', '慢查询|索引|explain|sql优化', '工学', '计算机科学与技术', 4, '用执行计划定位并优化慢查询', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据库索引与慢查询优化');
UPDATE `zy_skill` SET `alias` = '慢查询|索引|explain|sql优化', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '用执行计划定位并优化慢查询' WHERE `name` = '数据库索引与慢查询优化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '分库分表与读写分离', '分库分表|读写分离|sharding', '工学', '计算机科学与技术', 5, '设计数据分片与读写分离方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '分库分表与读写分离');
UPDATE `zy_skill` SET `alias` = '分库分表|读写分离|sharding', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '设计数据分片与读写分离方案' WHERE `name` = '分库分表与读写分离' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '分布式事务', '分布式事务|两阶段|最终一致', '工学', '计算机科学与技术', 5, '处理跨服务的数据一致性', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '分布式事务');
UPDATE `zy_skill` SET `alias` = '分布式事务|两阶段|最终一致', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '处理跨服务的数据一致性' WHERE `name` = '分布式事务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '接口幂等与限流', '幂等|限流|熔断|降级', '工学', '计算机科学与技术', 4, '设计幂等接口与限流熔断策略', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '接口幂等与限流');
UPDATE `zy_skill` SET `alias` = '幂等|限流|熔断|降级', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '设计幂等接口与限流熔断策略' WHERE `name` = '接口幂等与限流' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '日志采集与监控告警', '日志|elk|prometheus|告警', '工学', '计算机科学与技术', 4, '搭建日志采集与指标监控', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '日志采集与监控告警');
UPDATE `zy_skill` SET `alias` = '日志|elk|prometheus|告警', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '搭建日志采集与指标监控' WHERE `name` = '日志采集与监控告警' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'JVM 调优', 'jvm|gc|内存模型|调优', '工学', '计算机科学与技术', 5, '分析 GC 日志并优化 JVM 参数', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'JVM 调优');
UPDATE `zy_skill` SET `alias` = 'jvm|gc|内存模型|调优', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '分析 GC 日志并优化 JVM 参数' WHERE `name` = 'JVM 调优' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '并发编程与线程安全', '并发|多线程|锁|线程池', '工学', '计算机科学与技术', 5, '编写正确的并发程序', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '并发编程与线程安全');
UPDATE `zy_skill` SET `alias` = '并发|多线程|锁|线程池', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '编写正确的并发程序' WHERE `name` = '并发编程与线程安全' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '设计模式应用', '设计模式|重构|架构模式', '工学', '计算机科学与技术', 4, '在业务代码中恰当应用设计模式', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '设计模式应用');
UPDATE `zy_skill` SET `alias` = '设计模式|重构|架构模式', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '在业务代码中恰当应用设计模式' WHERE `name` = '设计模式应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'GraphQL 接口设计', 'graphql|查询语言', '工学', '计算机科学与技术', 4, '设计按需查询的 GraphQL 接口', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'GraphQL 接口设计');
UPDATE `zy_skill` SET `alias` = 'graphql|查询语言', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '设计按需查询的 GraphQL 接口' WHERE `name` = 'GraphQL 接口设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'WebSocket 实时通信', 'websocket|长连接|实时推送', '工学', '计算机科学与技术', 4, '实现实时消息推送', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'WebSocket 实时通信');
UPDATE `zy_skill` SET `alias` = 'websocket|长连接|实时推送', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '实现实时消息推送' WHERE `name` = 'WebSocket 实时通信' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'OAuth2 与单点登录', 'oauth2|sso|单点登录|鉴权', '工学', '计算机科学与技术', 4, '实现统一鉴权与单点登录', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'OAuth2 与单点登录');
UPDATE `zy_skill` SET `alias` = 'oauth2|sso|单点登录|鉴权', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '实现统一鉴权与单点登录' WHERE `name` = 'OAuth2 与单点登录' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据加密与脱敏', '加密|脱敏|国密|aes', '工学', '计算机科学与技术', 4, '实现敏感数据加密与展示脱敏', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据加密与脱敏');
UPDATE `zy_skill` SET `alias` = '加密|脱敏|国密|aes', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '实现敏感数据加密与展示脱敏' WHERE `name` = '数据加密与脱敏' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '自动化测试框架', '自动化测试|selenium|cypress|playwright', '工学', '计算机科学与技术', 4, '搭建端到端自动化测试', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '自动化测试框架');
UPDATE `zy_skill` SET `alias` = '自动化测试|selenium|cypress|playwright', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '搭建端到端自动化测试' WHERE `name` = '自动化测试框架' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '灰度发布与回滚', '灰度|蓝绿|回滚|发布策略', '工学', '计算机科学与技术', 4, '设计安全的发布与回滚方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '灰度发布与回滚');
UPDATE `zy_skill` SET `alias` = '灰度|蓝绿|回滚|发布策略', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '设计安全的发布与回滚方案' WHERE `name` = '灰度发布与回滚' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '静态代码分析与质量门禁', 'sonarqube|代码扫描|质量门禁', '工学', '计算机科学与技术', 3, '配置静态扫描与质量阈值', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '静态代码分析与质量门禁');
UPDATE `zy_skill` SET `alias` = 'sonarqube|代码扫描|质量门禁', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '配置静态扫描与质量阈值' WHERE `name` = '静态代码分析与质量门禁' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '小程序云开发', '云开发|cloudbase|云函数', '工学', '计算机科学与技术', 3, '用云开发实现小程序后端', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '小程序云开发');
UPDATE `zy_skill` SET `alias` = '云开发|cloudbase|云函数', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用云开发实现小程序后端' WHERE `name` = '小程序云开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Flutter 跨端开发', 'flutter|dart|跨平台', '工学', '计算机科学与技术', 4, '用 Flutter 开发多端应用', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Flutter 跨端开发');
UPDATE `zy_skill` SET `alias` = 'flutter|dart|跨平台', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '用 Flutter 开发多端应用' WHERE `name` = 'Flutter 跨端开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Uni-app 跨端开发', 'uniapp|跨端|多端发布', '工学', '计算机科学与技术', 3, '一套代码发布多端', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Uni-app 跨端开发');
UPDATE `zy_skill` SET `alias` = 'uniapp|跨端|多端发布', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '一套代码发布多端' WHERE `name` = 'Uni-app 跨端开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Web3D 与 Three.js', 'threejs|webgl|三维展示', '工学', '计算机科学与技术', 4, '在网页中实现三维可视化', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Web3D 与 Three.js');
UPDATE `zy_skill` SET `alias` = 'threejs|webgl|三维展示', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '在网页中实现三维可视化' WHERE `name` = 'Web3D 与 Three.js' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '音视频处理与流媒体', '音视频|ffmpeg|流媒体|hls', '工学', '计算机科学与技术', 5, '处理音视频转码与流式播放', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '音视频处理与流媒体');
UPDATE `zy_skill` SET `alias` = '音视频|ffmpeg|流媒体|hls', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '处理音视频转码与流式播放' WHERE `name` = '音视频处理与流媒体' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '推荐系统实现', '推荐|协同过滤|召回排序', '工学', '计算机科学与技术', 5, '实现召回与排序两阶段推荐', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '推荐系统实现');
UPDATE `zy_skill` SET `alias` = '推荐|协同过滤|召回排序', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '实现召回与排序两阶段推荐' WHERE `name` = '推荐系统实现' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '爬虫反爬对抗', '反爬|验证码|代理池|风控', '工学', '计算机科学与技术', 5, '处理验证码、限流与代理池', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '爬虫反爬对抗');
UPDATE `zy_skill` SET `alias` = '反爬|验证码|代理池|风控', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '处理验证码、限流与代理池' WHERE `name` = '爬虫反爬对抗' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Office 办公套件进阶', 'office|word|excel|powerpoint', '工学', '计算机科学与技术', 2, '用 Office 高效完成文档表格与演示', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Office 办公套件进阶');
UPDATE `zy_skill` SET `alias` = 'office|word|excel|powerpoint', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '用 Office 高效完成文档表格与演示' WHERE `name` = 'Office 办公套件进阶' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Excel 数据处理与函数', 'excel|函数|透视表|vlookup', '工学', '计算机科学与技术', 3, '用 Excel 做数据整理、透视与统计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Excel 数据处理与函数');
UPDATE `zy_skill` SET `alias` = 'excel|函数|透视表|vlookup', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Excel 做数据整理、透视与统计' WHERE `name` = 'Excel 数据处理与函数' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'WPS 办公应用', 'wps|金山办公|文档协作', '工学', '计算机科学与技术', 2, '用 WPS 完成日常办公与协作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'WPS 办公应用');
UPDATE `zy_skill` SET `alias` = 'wps|金山办公|文档协作', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '用 WPS 完成日常办公与协作' WHERE `name` = 'WPS 办公应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Markdown 文档写作', 'markdown|md|文档排版', '工学', '计算机科学与技术', 2, '用 Markdown 撰写结构化技术文档', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Markdown 文档写作');
UPDATE `zy_skill` SET `alias` = 'markdown|md|文档排版', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '用 Markdown 撰写结构化技术文档' WHERE `name` = 'Markdown 文档写作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'LaTeX 论文排版', 'latex|tex|公式排版|参考文献', '工学', '计算机科学与技术', 4, '用 LaTeX 排版学术论文与公式', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'LaTeX 论文排版');
UPDATE `zy_skill` SET `alias` = 'latex|tex|公式排版|参考文献', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '用 LaTeX 排版学术论文与公式' WHERE `name` = 'LaTeX 论文排版' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '正则表达式应用', '正则|regex|文本匹配', '工学', '计算机科学与技术', 3, '用正则做文本匹配与批量替换', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '正则表达式应用');
UPDATE `zy_skill` SET `alias` = '正则|regex|文本匹配', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用正则做文本匹配与批量替换' WHERE `name` = '正则表达式应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Shell 脚本自动化', 'shell|bash|脚本|自动化', '工学', '计算机科学与技术', 3, '用 Shell 脚本批量处理与定时任务', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Shell 脚本自动化');
UPDATE `zy_skill` SET `alias` = 'shell|bash|脚本|自动化', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Shell 脚本批量处理与定时任务' WHERE `name` = 'Shell 脚本自动化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Python 自动化办公', 'python办公|openpyxl|自动化脚本', '工学', '计算机科学与技术', 3, '用 Python 批量处理表格文档邮件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Python 自动化办公');
UPDATE `zy_skill` SET `alias` = 'python办公|openpyxl|自动化脚本', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Python 批量处理表格文档邮件' WHERE `name` = 'Python 自动化办公' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据可视化图表设计', '图表|可视化|echarts|matplotlib', '工学', '计算机科学与技术', 3, '把数据设计成清晰易读的图表', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据可视化图表设计');
UPDATE `zy_skill` SET `alias` = '图表|可视化|echarts|matplotlib', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '把数据设计成清晰易读的图表' WHERE `name` = '数据可视化图表设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Jupyter Notebook 数据分析', 'jupyter|notebook|交互分析', '工学', '计算机科学与技术', 3, '用 Notebook 做可复现的数据分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Jupyter Notebook 数据分析');
UPDATE `zy_skill` SET `alias` = 'jupyter|notebook|交互分析', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Notebook 做可复现的数据分析' WHERE `name` = 'Jupyter Notebook 数据分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Pandas 数据处理', 'pandas|数据框|数据清洗', '工学', '计算机科学与技术', 4, '用 Pandas 完成数据清洗与聚合', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Pandas 数据处理');
UPDATE `zy_skill` SET `alias` = 'pandas|数据框|数据清洗', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '用 Pandas 完成数据清洗与聚合' WHERE `name` = 'Pandas 数据处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'NumPy 数值计算', 'numpy|数组运算|科学计算', '工学', '计算机科学与技术', 4, '用 NumPy 做向量化数值计算', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'NumPy 数值计算');
UPDATE `zy_skill` SET `alias` = 'numpy|数组运算|科学计算', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '用 NumPy 做向量化数值计算' WHERE `name` = 'NumPy 数值计算' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Matplotlib 绘图', 'matplotlib|绘图|可视化', '工学', '计算机科学与技术', 3, '用 Matplotlib 绘制统计图表', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Matplotlib 绘图');
UPDATE `zy_skill` SET `alias` = 'matplotlib|绘图|可视化', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Matplotlib 绘制统计图表' WHERE `name` = 'Matplotlib 绘图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '网络协议抓包分析', '抓包|wireshark|协议分析', '工学', '计算机科学与技术', 4, '抓包分析网络通信问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '网络协议抓包分析');
UPDATE `zy_skill` SET `alias` = '抓包|wireshark|协议分析', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '抓包分析网络通信问题' WHERE `name` = '网络协议抓包分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '服务器自动化运维', 'ansible|自动化运维|批量部署', '工学', '计算机科学与技术', 5, '用工具批量管理服务器', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '服务器自动化运维');
UPDATE `zy_skill` SET `alias` = 'ansible|自动化运维|批量部署', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 5, `description` = '用工具批量管理服务器' WHERE `name` = '服务器自动化运维' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '性能压测与调优', '压测|jmeter|locust|qps', '工学', '计算机科学与技术', 4, '对系统做压力测试并定位瓶颈', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '性能压测与调优');
UPDATE `zy_skill` SET `alias` = '压测|jmeter|locust|qps', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '对系统做压力测试并定位瓶颈' WHERE `name` = '性能压测与调优' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '日志分析与异常定位', '日志分析|grep|awk|排查', '工学', '计算机科学与技术', 3, '从日志中定位异常与根因', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '日志分析与异常定位');
UPDATE `zy_skill` SET `alias` = '日志分析|grep|awk|排查', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '从日志中定位异常与根因' WHERE `name` = '日志分析与异常定位' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'A/B 测试与实验设计', 'ab测试|实验|假设检验|灰度', '工学', '计算机科学与技术', 4, '设计并分析线上实验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'A/B 测试与实验设计');
UPDATE `zy_skill` SET `alias` = 'ab测试|实验|假设检验|灰度', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '设计并分析线上实验' WHERE `name` = 'A/B 测试与实验设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '埋点方案与数据采集', '埋点|数据采集|事件模型', '工学', '计算机科学与技术', 4, '设计产品埋点与数据采集方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '埋点方案与数据采集');
UPDATE `zy_skill` SET `alias` = '埋点|数据采集|事件模型', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 4, `description` = '设计产品埋点与数据采集方案' WHERE `name` = '埋点方案与数据采集' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '产品需求文档撰写', 'prd|需求文档|原型说明', '工学', '计算机科学与技术', 3, '撰写清晰可执行的产品需求文档', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '产品需求文档撰写');
UPDATE `zy_skill` SET `alias` = 'prd|需求文档|原型说明', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '撰写清晰可执行的产品需求文档' WHERE `name` = '产品需求文档撰写' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Axure 原型设计', 'axure|原型|交互', '工学', '计算机科学与技术', 3, '用 Axure 制作可交互原型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Axure 原型设计');
UPDATE `zy_skill` SET `alias` = 'axure|原型|交互', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Axure 制作可交互原型' WHERE `name` = 'Axure 原型设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '低代码平台搭建', '低代码|宜搭|简道云|表单', '工学', '计算机科学与技术', 3, '用低代码平台快速搭建业务系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '低代码平台搭建');
UPDATE `zy_skill` SET `alias` = '低代码|宜搭|简道云|表单', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用低代码平台快速搭建业务系统' WHERE `name` = '低代码平台搭建' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '公众号排版与运营', '公众号|排版|秀米|运营', '工学', '计算机科学与技术', 2, '完成公众号内容排版与发布', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '公众号排版与运营');
UPDATE `zy_skill` SET `alias` = '公众号|排版|秀米|运营', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '完成公众号内容排版与发布' WHERE `name` = '公众号排版与运营' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '视频号内容制作', '视频号|剪辑|封面|发布', '工学', '计算机科学与技术', 3, '制作并发布视频号内容', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '视频号内容制作');
UPDATE `zy_skill` SET `alias` = '视频号|剪辑|封面|发布', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '制作并发布视频号内容' WHERE `name` = '视频号内容制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '小红书内容运营', '小红书|笔记|种草|选题', '工学', '计算机科学与技术', 3, '策划并运营小红书内容', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '小红书内容运营');
UPDATE `zy_skill` SET `alias` = '小红书|笔记|种草|选题', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '策划并运营小红书内容' WHERE `name` = '小红书内容运营' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'B站视频制作与运营', 'b站|哔哩哔哩|封面|分区', '工学', '计算机科学与技术', 3, '制作并运营 B 站视频内容', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'B站视频制作与运营');
UPDATE `zy_skill` SET `alias` = 'b站|哔哩哔哩|封面|分区', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '制作并运营 B 站视频内容' WHERE `name` = 'B站视频制作与运营' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '搜索引擎优化 SEO', 'seo|关键词|收录|排名', '工学', '计算机科学与技术', 3, '优化内容在搜索引擎的可见度', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '搜索引擎优化 SEO');
UPDATE `zy_skill` SET `alias` = 'seo|关键词|收录|排名', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '优化内容在搜索引擎的可见度' WHERE `name` = '搜索引擎优化 SEO' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '在线问卷与数据回收', '问卷星|腾讯问卷|数据回收', '工学', '计算机科学与技术', 2, '设计在线问卷并回收整理数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '在线问卷与数据回收');
UPDATE `zy_skill` SET `alias` = '问卷星|腾讯问卷|数据回收', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '设计在线问卷并回收整理数据' WHERE `name` = '在线问卷与数据回收' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '思维导图与知识整理', '思维导图|xmind|幕布|知识整理', '工学', '计算机科学与技术', 2, '用思维导图梳理知识结构', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '思维导图与知识整理');
UPDATE `zy_skill` SET `alias` = '思维导图|xmind|幕布|知识整理', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '用思维导图梳理知识结构' WHERE `name` = '思维导图与知识整理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '笔记系统与知识管理', '笔记|obsidian|notion|第二大脑', '工学', '计算机科学与技术', 3, '建立个人知识管理体系', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '笔记系统与知识管理');
UPDATE `zy_skill` SET `alias` = '笔记|obsidian|notion|第二大脑', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '建立个人知识管理体系' WHERE `name` = '笔记系统与知识管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '网盘与文件协作管理', '网盘|共享|协作|版本', '工学', '计算机科学与技术', 2, '用网盘完成团队文件协作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '网盘与文件协作管理');
UPDATE `zy_skill` SET `alias` = '网盘|共享|协作|版本', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '用网盘完成团队文件协作' WHERE `name` = '网盘与文件协作管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '腾讯会议与线上协作', '腾讯会议|线上会议|屏幕共享', '工学', '计算机科学与技术', 2, '组织线上会议与远程协作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '腾讯会议与线上协作');
UPDATE `zy_skill` SET `alias` = '腾讯会议|线上会议|屏幕共享', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 2, `description` = '组织线上会议与远程协作' WHERE `name` = '腾讯会议与线上协作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Notion 团队协作搭建', 'notion|数据库|协作空间', '工学', '计算机科学与技术', 3, '用 Notion 搭建团队协作系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Notion 团队协作搭建');
UPDATE `zy_skill` SET `alias` = 'notion|数据库|协作空间', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用 Notion 搭建团队协作系统' WHERE `name` = 'Notion 团队协作搭建' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '飞书多维表格应用', '飞书|多维表格|自动化', '工学', '计算机科学与技术', 3, '用飞书多维表格做轻量项目管理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '飞书多维表格应用');
UPDATE `zy_skill` SET `alias` = '飞书|多维表格|自动化', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用飞书多维表格做轻量项目管理' WHERE `name` = '飞书多维表格应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '钉钉审批与流程配置', '钉钉|审批|流程|oa', '工学', '计算机科学与技术', 3, '配置钉钉审批流程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '钉钉审批与流程配置');
UPDATE `zy_skill` SET `alias` = '钉钉|审批|流程|oa', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '配置钉钉审批流程' WHERE `name` = '钉钉审批与流程配置' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '企业微信客户运营', '企业微信|客户群|运营', '工学', '计算机科学与技术', 3, '用企业微信做客户运营', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '企业微信客户运营');
UPDATE `zy_skill` SET `alias` = '企业微信|客户群|运营', `category_l1` = '工学', `category_l2` = '计算机科学与技术', `difficulty` = 3, `description` = '用企业微信做客户运营' WHERE `name` = '企业微信客户运营' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '敏捷开发与迭代管理', '敏捷|scrum|迭代|看板', '工学', '软件工程', 3, '组织迭代计划、站会与回顾', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '敏捷开发与迭代管理');
UPDATE `zy_skill` SET `alias` = '敏捷|scrum|迭代|看板', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 3, `description` = '组织迭代计划、站会与回顾' WHERE `name` = '敏捷开发与迭代管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '代码重构与整洁代码', '重构|整洁代码|代码质量', '工学', '软件工程', 4, '在保持行为不变的前提下改善代码结构', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '代码重构与整洁代码');
UPDATE `zy_skill` SET `alias` = '重构|整洁代码|代码质量', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 4, `description` = '在保持行为不变的前提下改善代码结构' WHERE `name` = '代码重构与整洁代码' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '持续集成与持续部署', 'ci/cd|jenkins|流水线|自动化部署', '工学', '软件工程', 4, '搭建自动化构建、测试与发布流水线', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '持续集成与持续部署');
UPDATE `zy_skill` SET `alias` = 'ci/cd|jenkins|流水线|自动化部署', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 4, `description` = '搭建自动化构建、测试与发布流水线' WHERE `name` = '持续集成与持续部署' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '软件测试与质量保障', '软件测试|测试用例|qa|缺陷管理', '工学', '软件工程', 3, '设计测试用例并管理缺陷生命周期', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '软件测试与质量保障');
UPDATE `zy_skill` SET `alias` = '软件测试|测试用例|qa|缺陷管理', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 3, `description` = '设计测试用例并管理缺陷生命周期' WHERE `name` = '软件测试与质量保障' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '需求评审与用例编写', '需求评审|用例|用户故事', '工学', '软件工程', 3, '把模糊需求拆成可验收的用例', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '需求评审与用例编写');
UPDATE `zy_skill` SET `alias` = '需求评审|用例|用户故事', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 3, `description` = '把模糊需求拆成可验收的用例' WHERE `name` = '需求评审与用例编写' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '项目管理与进度把控', '项目管理|进度|甘特图|风险', '工学', '软件工程', 3, '拆解任务、排期与风险跟踪', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '项目管理与进度把控');
UPDATE `zy_skill` SET `alias` = '项目管理|进度|甘特图|风险', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 3, `description` = '拆解任务、排期与风险跟踪' WHERE `name` = '项目管理与进度把控' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '技术文档写作', '技术文档|api文档|readme', '工学', '软件工程', 2, '写清接口、部署与使用说明', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '技术文档写作');
UPDATE `zy_skill` SET `alias` = '技术文档|api文档|readme', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 2, `description` = '写清接口、部署与使用说明' WHERE `name` = '技术文档写作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '领域驱动设计', 'ddd|领域模型|限界上下文', '工学', '软件工程', 5, '用领域模型组织复杂业务', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '领域驱动设计');
UPDATE `zy_skill` SET `alias` = 'ddd|领域模型|限界上下文', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 5, `description` = '用领域模型组织复杂业务' WHERE `name` = '领域驱动设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '代码评审与规范落地', 'code review|编码规范|静态检查', '工学', '软件工程', 3, '组织代码评审并落地规范', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '代码评审与规范落地');
UPDATE `zy_skill` SET `alias` = 'code review|编码规范|静态检查', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 3, `description` = '组织代码评审并落地规范' WHERE `name` = '代码评审与规范落地' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '故障复盘与事后分析', '复盘|postmortem|根因分析', '工学', '软件工程', 3, '组织故障复盘并产出改进项', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '故障复盘与事后分析');
UPDATE `zy_skill` SET `alias` = '复盘|postmortem|根因分析', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 3, `description` = '组织故障复盘并产出改进项' WHERE `name` = '故障复盘与事后分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '技术方案评审', '方案评审|技术选型|可行性', '工学', '软件工程', 4, '撰写并评审技术方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '技术方案评审');
UPDATE `zy_skill` SET `alias` = '方案评审|技术选型|可行性', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 4, `description` = '撰写并评审技术方案' WHERE `name` = '技术方案评审' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '接口文档与联调', '接口文档|swagger|联调', '工学', '软件工程', 2, '维护接口文档并组织联调', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '接口文档与联调');
UPDATE `zy_skill` SET `alias` = '接口文档|swagger|联调', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 2, `description` = '维护接口文档并组织联调' WHERE `name` = '接口文档与联调' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '敏捷估算与燃尽图', '故事点|估算|燃尽图', '工学', '软件工程', 3, '做迭代估算与进度可视化', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '敏捷估算与燃尽图');
UPDATE `zy_skill` SET `alias` = '故事点|估算|燃尽图', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 3, `description` = '做迭代估算与进度可视化' WHERE `name` = '敏捷估算与燃尽图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '软件配置管理', '配置管理|版本策略|发布分支', '工学', '软件工程', 3, '管理版本与分支策略', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '软件配置管理');
UPDATE `zy_skill` SET `alias` = '配置管理|版本策略|发布分支', `category_l1` = '工学', `category_l2` = '软件工程', `difficulty` = 3, `description` = '管理版本与分支策略' WHERE `name` = '软件配置管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '单片机与嵌入式开发', '单片机|stm32|嵌入式|arduino', '工学', '电子科学与技术', 4, '用单片机实现硬件控制程序', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '单片机与嵌入式开发');
UPDATE `zy_skill` SET `alias` = '单片机|stm32|嵌入式|arduino', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '用单片机实现硬件控制程序' WHERE `name` = '单片机与嵌入式开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '电路原理与仿真', '电路|multisim|仿真|模电', '工学', '电子科学与技术', 4, '设计并仿真模拟与数字电路', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '电路原理与仿真');
UPDATE `zy_skill` SET `alias` = '电路|multisim|仿真|模电', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '设计并仿真模拟与数字电路' WHERE `name` = '电路原理与仿真' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'PCB 设计与制板', 'pcb|ad|立创eda|画板', '工学', '电子科学与技术', 4, '绘制原理图与 PCB 并输出制板文件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'PCB 设计与制板');
UPDATE `zy_skill` SET `alias` = 'pcb|ad|立创eda|画板', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '绘制原理图与 PCB 并输出制板文件' WHERE `name` = 'PCB 设计与制板' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '传感器数据采集', '传感器|采集|i2c|spi', '工学', '电子科学与技术', 4, '接入传感器并读取处理数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '传感器数据采集');
UPDATE `zy_skill` SET `alias` = '传感器|采集|i2c|spi', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '接入传感器并读取处理数据' WHERE `name` = '传感器数据采集' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'FPGA 与数字逻辑', 'fpga|verilog|数字逻辑', '工学', '电子科学与技术', 5, '用硬件描述语言实现数字逻辑', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'FPGA 与数字逻辑');
UPDATE `zy_skill` SET `alias` = 'fpga|verilog|数字逻辑', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 5, `description` = '用硬件描述语言实现数字逻辑' WHERE `name` = 'FPGA 与数字逻辑' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '通信原理与信号处理', '通信原理|信号处理|调制解调', '工学', '电子科学与技术', 4, '理解调制解调、滤波与信号分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '通信原理与信号处理');
UPDATE `zy_skill` SET `alias` = '通信原理|信号处理|调制解调', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '理解调制解调、滤波与信号分析' WHERE `name` = '通信原理与信号处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '机器人控制与编程', '机器人|ros|运动控制|舵机', '工学', '电子科学与技术', 5, '实现机器人运动规划与控制逻辑', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '机器人控制与编程');
UPDATE `zy_skill` SET `alias` = '机器人|ros|运动控制|舵机', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 5, `description` = '实现机器人运动规划与控制逻辑' WHERE `name` = '机器人控制与编程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '无人机调试与飞控', '无人机|飞控|px4|航拍', '工学', '电子科学与技术', 4, '调试飞控参数与航线规划', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '无人机调试与飞控');
UPDATE `zy_skill` SET `alias` = '无人机|飞控|px4|航拍', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '调试飞控参数与航线规划' WHERE `name` = '无人机调试与飞控' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '模拟电路设计', '模电|运放|滤波|放大', '工学', '电子科学与技术', 5, '设计模拟放大与滤波电路', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '模拟电路设计');
UPDATE `zy_skill` SET `alias` = '模电|运放|滤波|放大', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 5, `description` = '设计模拟放大与滤波电路' WHERE `name` = '模拟电路设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数字电路设计', '数电|逻辑门|时序电路', '工学', '电子科学与技术', 4, '设计组合与时序逻辑电路', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数字电路设计');
UPDATE `zy_skill` SET `alias` = '数电|逻辑门|时序电路', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '设计组合与时序逻辑电路' WHERE `name` = '数字电路设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '嵌入式 C 编程', '嵌入式c|寄存器|中断|裸机', '工学', '电子科学与技术', 4, '编写裸机或 RTOS 下的嵌入式程序', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '嵌入式 C 编程');
UPDATE `zy_skill` SET `alias` = '嵌入式c|寄存器|中断|裸机', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '编写裸机或 RTOS 下的嵌入式程序' WHERE `name` = '嵌入式 C 编程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'RTOS 实时系统', 'rtos|freertos|实时调度', '工学', '电子科学与技术', 5, '在实时系统上开发任务调度', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'RTOS 实时系统');
UPDATE `zy_skill` SET `alias` = 'rtos|freertos|实时调度', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 5, `description` = '在实时系统上开发任务调度' WHERE `name` = 'RTOS 实时系统' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '无线通信模块调试', 'wifi|蓝牙|lora|nb-iot', '工学', '电子科学与技术', 4, '调试常见无线通信模块', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '无线通信模块调试');
UPDATE `zy_skill` SET `alias` = 'wifi|蓝牙|lora|nb-iot', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '调试常见无线通信模块' WHERE `name` = '无线通信模块调试' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '电源与电源管理', '电源设计|dc-dc|ldo|电池管理', '工学', '电子科学与技术', 5, '设计供电与电源管理方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '电源与电源管理');
UPDATE `zy_skill` SET `alias` = '电源设计|dc-dc|ldo|电池管理', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 5, `description` = '设计供电与电源管理方案' WHERE `name` = '电源与电源管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '信号采集与滤波', '信号采集|adc|滤波|去噪', '工学', '电子科学与技术', 4, '采集模拟信号并做滤波处理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '信号采集与滤波');
UPDATE `zy_skill` SET `alias` = '信号采集|adc|滤波|去噪', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '采集模拟信号并做滤波处理' WHERE `name` = '信号采集与滤波' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'PCB 信号完整性', '信号完整性|emc|阻抗', '工学', '电子科学与技术', 5, '处理高速信号完整性与 EMC 问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'PCB 信号完整性');
UPDATE `zy_skill` SET `alias` = '信号完整性|emc|阻抗', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 5, `description` = '处理高速信号完整性与 EMC 问题' WHERE `name` = 'PCB 信号完整性' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '嵌入式上位机开发', '上位机|串口|qt|labview', '工学', '电子科学与技术', 4, '开发与硬件通信的上位机软件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '嵌入式上位机开发');
UPDATE `zy_skill` SET `alias` = '上位机|串口|qt|labview', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 4, `description` = '开发与硬件通信的上位机软件' WHERE `name` = '嵌入式上位机开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '示波器与仪器使用', '示波器|万用表|信号源', '工学', '电子科学与技术', 3, '正确使用常用电子测量仪器', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '示波器与仪器使用');
UPDATE `zy_skill` SET `alias` = '示波器|万用表|信号源', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 3, `description` = '正确使用常用电子测量仪器' WHERE `name` = '示波器与仪器使用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '电子焊接与装配', '焊接|飞线|装配|调试', '工学', '电子科学与技术', 3, '完成电路焊接与装配调试', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '电子焊接与装配');
UPDATE `zy_skill` SET `alias` = '焊接|飞线|装配|调试', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 3, `description` = '完成电路焊接与装配调试' WHERE `name` = '电子焊接与装配' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '3D 打印建模与切片', '3d打印|建模|cura|切片', '工学', '电子科学与技术', 3, '建模并切片完成 3D 打印', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '3D 打印建模与切片');
UPDATE `zy_skill` SET `alias` = '3d打印|建模|cura|切片', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 3, `description` = '建模并切片完成 3D 打印' WHERE `name` = '3D 打印建模与切片' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '激光切割与结构制作', '激光切割|亚克力|结构件', '工学', '电子科学与技术', 3, '用激光切割制作结构件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '激光切割与结构制作');
UPDATE `zy_skill` SET `alias` = '激光切割|亚克力|结构件', `category_l1` = '工学', `category_l2` = '电子科学与技术', `difficulty` = 3, `description` = '用激光切割制作结构件' WHERE `name` = '激光切割与结构制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '建筑方案设计与表达', '建筑方案|设计表达|建筑制图', '工学', '建筑学', 4, '从概念到方案图纸的完整设计表达', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '建筑方案设计与表达');
UPDATE `zy_skill` SET `alias` = '建筑方案|设计表达|建筑制图', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 4, `description` = '从概念到方案图纸的完整设计表达' WHERE `name` = '建筑方案设计与表达' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'CAD 工程制图', 'cad|autocad|工程制图|施工图', '工学', '建筑学', 3, '用 CAD 绘制平立剖面与施工图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'CAD 工程制图');
UPDATE `zy_skill` SET `alias` = 'cad|autocad|工程制图|施工图', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 3, `description` = '用 CAD 绘制平立剖面与施工图' WHERE `name` = 'CAD 工程制图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'SketchUp 建筑建模', 'su|sketchup|建筑建模', '工学', '建筑学', 3, '用 SketchUp 建立建筑体量模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'SketchUp 建筑建模');
UPDATE `zy_skill` SET `alias` = 'su|sketchup|建筑建模', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 3, `description` = '用 SketchUp 建立建筑体量模型' WHERE `name` = 'SketchUp 建筑建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Revit BIM 建模', 'revit|bim|建筑信息模型', '工学', '建筑学', 4, '建立可用于协同的 BIM 模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Revit BIM 建模');
UPDATE `zy_skill` SET `alias` = 'revit|bim|建筑信息模型', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 4, `description` = '建立可用于协同的 BIM 模型' WHERE `name` = 'Revit BIM 建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '建筑手绘与快题', '手绘|快题|马克笔|建筑速写', '工学', '建筑学', 3, '用手绘快速表达设计意图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '建筑手绘与快题');
UPDATE `zy_skill` SET `alias` = '手绘|快题|马克笔|建筑速写', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 3, `description` = '用手绘快速表达设计意图' WHERE `name` = '建筑手绘与快题' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '城市规划与场地分析', '城市规划|场地分析|总图', '工学', '建筑学', 4, '分析场地条件并做规划布局', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '城市规划与场地分析');
UPDATE `zy_skill` SET `alias` = '城市规划|场地分析|总图', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 4, `description` = '分析场地条件并做规划布局' WHERE `name` = '城市规划与场地分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '建筑物理与环境模拟', '建筑物理|日照分析|能耗模拟', '工学', '建筑学', 4, '用软件模拟采光、通风与能耗', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '建筑物理与环境模拟');
UPDATE `zy_skill` SET `alias` = '建筑物理|日照分析|能耗模拟', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 4, `description` = '用软件模拟采光、通风与能耗' WHERE `name` = '建筑物理与环境模拟' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '建筑设计表现图', '效果图|渲染|lumion|vray', '工学', '建筑学', 3, '制作建筑效果图与表现图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '建筑设计表现图');
UPDATE `zy_skill` SET `alias` = '效果图|渲染|lumion|vray', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 3, `description` = '制作建筑效果图与表现图' WHERE `name` = '建筑设计表现图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '建筑模型制作', '建筑模型|实体模型|激光切割', '工学', '建筑学', 3, '制作实体或数字建筑模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '建筑模型制作');
UPDATE `zy_skill` SET `alias` = '建筑模型|实体模型|激光切割', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 3, `description` = '制作实体或数字建筑模型' WHERE `name` = '建筑模型制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '室内空间设计', '室内设计|软装|动线', '工学', '建筑学', 4, '完成室内空间与软装方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '室内空间设计');
UPDATE `zy_skill` SET `alias` = '室内设计|软装|动线', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 4, `description` = '完成室内空间与软装方案' WHERE `name` = '室内空间设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '绿色建筑与节能', '绿色建筑|节能|被动式', '工学', '建筑学', 4, '按绿色建筑标准做节能设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '绿色建筑与节能');
UPDATE `zy_skill` SET `alias` = '绿色建筑|节能|被动式', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 4, `description` = '按绿色建筑标准做节能设计' WHERE `name` = '绿色建筑与节能' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '建筑法规与规范', '建筑规范|防火|无障碍', '工学', '建筑学', 3, '掌握常用建筑规范要求', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '建筑法规与规范');
UPDATE `zy_skill` SET `alias` = '建筑规范|防火|无障碍', `category_l1` = '工学', `category_l2` = '建筑学', `difficulty` = 3, `description` = '掌握常用建筑规范要求' WHERE `name` = '建筑法规与规范' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '结构力学与受力分析', '结构力学|受力分析|内力图', '工学', '土木工程', 4, '计算结构的受力与变形', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '结构力学与受力分析');
UPDATE `zy_skill` SET `alias` = '结构力学|受力分析|内力图', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 4, `description` = '计算结构的受力与变形' WHERE `name` = '结构力学与受力分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'PKPM 结构设计', 'pkpm|结构设计|配筋', '工学', '土木工程', 4, '用 PKPM 完成结构建模与配筋计算', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'PKPM 结构设计');
UPDATE `zy_skill` SET `alias` = 'pkpm|结构设计|配筋', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 4, `description` = '用 PKPM 完成结构建模与配筋计算' WHERE `name` = 'PKPM 结构设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '工程测量与放线', '工程测量|水准仪|全站仪|放线', '工学', '土木工程', 3, '完成现场测量与放样', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '工程测量与放线');
UPDATE `zy_skill` SET `alias` = '工程测量|水准仪|全站仪|放线', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 3, `description` = '完成现场测量与放样' WHERE `name` = '工程测量与放线' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '施工组织设计', '施工组织|进度计划|施工方案', '工学', '土木工程', 3, '编制施工方案与进度计划', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '施工组织设计');
UPDATE `zy_skill` SET `alias` = '施工组织|进度计划|施工方案', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 3, `description` = '编制施工方案与进度计划' WHERE `name` = '施工组织设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '工程造价与预算', '工程造价|预算|清单计价|广联达', '工学', '土木工程', 4, '编制工程量清单与造价预算', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '工程造价与预算');
UPDATE `zy_skill` SET `alias` = '工程造价|预算|清单计价|广联达', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 4, `description` = '编制工程量清单与造价预算' WHERE `name` = '工程造价与预算' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '桥梁与道路设计', '桥梁设计|道路设计|线形', '工学', '土木工程', 5, '完成桥梁或道路的选型与计算', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '桥梁与道路设计');
UPDATE `zy_skill` SET `alias` = '桥梁设计|道路设计|线形', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 5, `description` = '完成桥梁或道路的选型与计算' WHERE `name` = '桥梁与道路设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '岩土与地基处理', '岩土|地基|基坑|勘察', '工学', '土木工程', 5, '分析地基承载力与基坑支护方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '岩土与地基处理');
UPDATE `zy_skill` SET `alias` = '岩土|地基|基坑|勘察', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 5, `description` = '分析地基承载力与基坑支护方案' WHERE `name` = '岩土与地基处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '混凝土结构设计', '混凝土|梁板柱|配筋', '工学', '土木工程', 4, '完成钢筋混凝土构件设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '混凝土结构设计');
UPDATE `zy_skill` SET `alias` = '混凝土|梁板柱|配筋', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 4, `description` = '完成钢筋混凝土构件设计' WHERE `name` = '混凝土结构设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '钢结构设计与节点', '钢结构|节点|焊缝|螺栓', '工学', '土木工程', 5, '设计钢结构构件与连接节点', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '钢结构设计与节点');
UPDATE `zy_skill` SET `alias` = '钢结构|节点|焊缝|螺栓', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 5, `description` = '设计钢结构构件与连接节点' WHERE `name` = '钢结构设计与节点' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '土力学与基础工程', '土力学|承载力|桩基', '工学', '土木工程', 5, '计算地基承载力与基础方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '土力学与基础工程');
UPDATE `zy_skill` SET `alias` = '土力学|承载力|桩基', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 5, `description` = '计算地基承载力与基础方案' WHERE `name` = '土力学与基础工程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '建筑给排水设计', '给排水|管道|消防水', '工学', '土木工程', 3, '设计建筑给排水与消防系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '建筑给排水设计');
UPDATE `zy_skill` SET `alias` = '给排水|管道|消防水', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 3, `description` = '设计建筑给排水与消防系统' WHERE `name` = '建筑给排水设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '暖通空调设计', '暖通|空调|负荷计算|通风', '工学', '土木工程', 4, '完成暖通负荷计算与系统设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '暖通空调设计');
UPDATE `zy_skill` SET `alias` = '暖通|空调|负荷计算|通风', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 4, `description` = '完成暖通负荷计算与系统设计' WHERE `name` = '暖通空调设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '建筑电气设计', '建筑电气|配电|照明|弱电', '工学', '土木工程', 4, '完成建筑配电与照明设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '建筑电气设计');
UPDATE `zy_skill` SET `alias` = '建筑电气|配电|照明|弱电', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 4, `description` = '完成建筑配电与照明设计' WHERE `name` = '建筑电气设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'BIM 施工模拟', 'bim|施工模拟|碰撞检查', '工学', '土木工程', 4, '用 BIM 做施工模拟与碰撞检测', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'BIM 施工模拟');
UPDATE `zy_skill` SET `alias` = 'bim|施工模拟|碰撞检查', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 4, `description` = '用 BIM 做施工模拟与碰撞检测' WHERE `name` = 'BIM 施工模拟' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '工程质量与验收', '质量验收|规范|检测', '工学', '土木工程', 3, '按规范执行质量验收', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '工程质量与验收');
UPDATE `zy_skill` SET `alias` = '质量验收|规范|检测', `category_l1` = '工学', `category_l2` = '土木工程', `difficulty` = 3, `description` = '按规范执行质量验收' WHERE `name` = '工程质量与验收' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化工流程模拟', 'aspen|流程模拟|化工设计', '工学', '化学工程与技术', 5, '用 Aspen 模拟化工流程与物料平衡', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化工流程模拟');
UPDATE `zy_skill` SET `alias` = 'aspen|流程模拟|化工设计', `category_l1` = '工学', `category_l2` = '化学工程与技术', `difficulty` = 5, `description` = '用 Aspen 模拟化工流程与物料平衡' WHERE `name` = '化工流程模拟' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化工实验操作', '化工实验|滴定|精馏|萃取', '工学', '化学工程与技术', 3, '完成基础化工单元操作实验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化工实验操作');
UPDATE `zy_skill` SET `alias` = '化工实验|滴定|精馏|萃取', `category_l1` = '工学', `category_l2` = '化学工程与技术', `difficulty` = 3, `description` = '完成基础化工单元操作实验' WHERE `name` = '化工实验操作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '仪器分析与检测', '仪器分析|色谱|光谱|检测', '工学', '化学工程与技术', 4, '用色谱光谱等仪器做成分分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '仪器分析与检测');
UPDATE `zy_skill` SET `alias` = '仪器分析|色谱|光谱|检测', `category_l1` = '工学', `category_l2` = '化学工程与技术', `difficulty` = 4, `description` = '用色谱光谱等仪器做成分分析' WHERE `name` = '仪器分析与检测' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '催化剂与反应工程', '催化剂|反应工程|动力学', '工学', '化学工程与技术', 5, '研究反应动力学与催化剂性能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '催化剂与反应工程');
UPDATE `zy_skill` SET `alias` = '催化剂|反应工程|动力学', `category_l1` = '工学', `category_l2` = '化学工程与技术', `difficulty` = 5, `description` = '研究反应动力学与催化剂性能' WHERE `name` = '催化剂与反应工程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化工安全与风险评估', '化工安全|hazop|风险评估', '工学', '化学工程与技术', 4, '识别工艺风险并做安全评估', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化工安全与风险评估');
UPDATE `zy_skill` SET `alias` = '化工安全|hazop|风险评估', `category_l1` = '工学', `category_l2` = '化学工程与技术', `difficulty` = 4, `description` = '识别工艺风险并做安全评估' WHERE `name` = '化工安全与风险评估' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化工设备与机械', '化工设备|换热器|反应釜', '工学', '化学工程与技术', 4, '选型与设计常用化工设备', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化工设备与机械');
UPDATE `zy_skill` SET `alias` = '化工设备|换热器|反应釜', `category_l1` = '工学', `category_l2` = '化学工程与技术', `difficulty` = 4, `description` = '选型与设计常用化工设备' WHERE `name` = '化工设备与机械' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化工设计与图纸', '化工设计|pid|工艺流程图', '工学', '化学工程与技术', 4, '绘制工艺流程图与设备布置', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化工设计与图纸');
UPDATE `zy_skill` SET `alias` = '化工设计|pid|工艺流程图', `category_l1` = '工学', `category_l2` = '化学工程与技术', `difficulty` = 4, `description` = '绘制工艺流程图与设备布置' WHERE `name` = '化工设计与图纸' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '传质与分离工程', '传质|分离|精馏|吸收', '工学', '化学工程与技术', 5, '设计传质分离单元', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '传质与分离工程');
UPDATE `zy_skill` SET `alias` = '传质|分离|精馏|吸收', `category_l1` = '工学', `category_l2` = '化学工程与技术', `difficulty` = 5, `description` = '设计传质分离单元' WHERE `name` = '传质与分离工程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化工仪表与自动化', '化工仪表|dcs|pid控制', '工学', '化学工程与技术', 4, '配置化工过程检测与控制', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化工仪表与自动化');
UPDATE `zy_skill` SET `alias` = '化工仪表|dcs|pid控制', `category_l1` = '工学', `category_l2` = '化学工程与技术', `difficulty` = 4, `description` = '配置化工过程检测与控制' WHERE `name` = '化工仪表与自动化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '材料制备与合成', '材料制备|合成|水热法|溶胶凝胶', '工学', '材料科学与工程', 4, '用不同方法合成目标材料', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '材料制备与合成');
UPDATE `zy_skill` SET `alias` = '材料制备|合成|水热法|溶胶凝胶', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 4, `description` = '用不同方法合成目标材料' WHERE `name` = '材料制备与合成' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '材料表征与测试', '材料表征|xrd|sem|tem', '工学', '材料科学与工程', 5, '用 XRD/SEM 等手段表征材料结构', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '材料表征与测试');
UPDATE `zy_skill` SET `alias` = '材料表征|xrd|sem|tem', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 5, `description` = '用 XRD/SEM 等手段表征材料结构' WHERE `name` = '材料表征与测试' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '力学性能测试', '力学性能|拉伸|硬度|疲劳', '工学', '材料科学与工程', 4, '测试材料的强度、硬度与疲劳性能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '力学性能测试');
UPDATE `zy_skill` SET `alias` = '力学性能|拉伸|硬度|疲劳', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 4, `description` = '测试材料的强度、硬度与疲劳性能' WHERE `name` = '力学性能测试' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '金属热处理工艺', '热处理|淬火|退火|金相', '工学', '材料科学与工程', 4, '通过热处理调控金属组织与性能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '金属热处理工艺');
UPDATE `zy_skill` SET `alias` = '热处理|淬火|退火|金相', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 4, `description` = '通过热处理调控金属组织与性能' WHERE `name` = '金属热处理工艺' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '高分子材料加工', '高分子|注塑|挤出|改性', '工学', '材料科学与工程', 4, '高分子材料的成型与改性工艺', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '高分子材料加工');
UPDATE `zy_skill` SET `alias` = '高分子|注塑|挤出|改性', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 4, `description` = '高分子材料的成型与改性工艺' WHERE `name` = '高分子材料加工' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '电池与储能材料', '电池|锂电|储能|电极材料', '工学', '材料科学与工程', 5, '研究电池电极材料与储能性能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '电池与储能材料');
UPDATE `zy_skill` SET `alias` = '电池|锂电|储能|电极材料', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 5, `description` = '研究电池电极材料与储能性能' WHERE `name` = '电池与储能材料' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '复合材料设计', '复合材料|纤维|层合板', '工学', '材料科学与工程', 5, '设计纤维增强复合材料的铺层与性能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '复合材料设计');
UPDATE `zy_skill` SET `alias` = '复合材料|纤维|层合板', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 5, `description` = '设计纤维增强复合材料的铺层与性能' WHERE `name` = '复合材料设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '材料失效分析', '失效分析|断口|腐蚀', '工学', '材料科学与工程', 5, '分析材料失效原因并提出改进', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '材料失效分析');
UPDATE `zy_skill` SET `alias` = '失效分析|断口|腐蚀', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 5, `description` = '分析材料失效原因并提出改进' WHERE `name` = '材料失效分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '薄膜与涂层制备', '薄膜|镀膜|溅射|cvd', '工学', '材料科学与工程', 5, '制备功能薄膜与防护涂层', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '薄膜与涂层制备');
UPDATE `zy_skill` SET `alias` = '薄膜|镀膜|溅射|cvd', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 5, `description` = '制备功能薄膜与防护涂层' WHERE `name` = '薄膜与涂层制备' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '陶瓷材料工艺', '陶瓷|烧结|成型', '工学', '材料科学与工程', 4, '完成陶瓷材料成型与烧结', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '陶瓷材料工艺');
UPDATE `zy_skill` SET `alias` = '陶瓷|烧结|成型', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 4, `description` = '完成陶瓷材料成型与烧结' WHERE `name` = '陶瓷材料工艺' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '材料计算与模拟', '材料计算|第一性原理|分子动力学', '工学', '材料科学与工程', 5, '用计算方法预测材料性质', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '材料计算与模拟');
UPDATE `zy_skill` SET `alias` = '材料计算|第一性原理|分子动力学', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 5, `description` = '用计算方法预测材料性质' WHERE `name` = '材料计算与模拟' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '无损检测技术', '无损检测|超声|射线|探伤', '工学', '材料科学与工程', 4, '用无损方法检测内部缺陷', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '无损检测技术');
UPDATE `zy_skill` SET `alias` = '无损检测|超声|射线|探伤', `category_l1` = '工学', `category_l2` = '材料科学与工程', `difficulty` = 4, `description` = '用无损方法检测内部缺陷' WHERE `name` = '无损检测技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '水质检测与分析', '水质检测|cod|氨氮|分光光度', '工学', '环境科学与工程', 3, '检测水体主要污染指标', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '水质检测与分析');
UPDATE `zy_skill` SET `alias` = '水质检测|cod|氨氮|分光光度', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 3, `description` = '检测水体主要污染指标' WHERE `name` = '水质检测与分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '大气污染监测', '大气监测|pm2.5|空气质量|采样', '工学', '环境科学与工程', 3, '布点采样并分析大气污染物', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '大气污染监测');
UPDATE `zy_skill` SET `alias` = '大气监测|pm2.5|空气质量|采样', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 3, `description` = '布点采样并分析大气污染物' WHERE `name` = '大气污染监测' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '污水处理工艺设计', '污水处理|活性污泥|a2o|工艺设计', '工学', '环境科学与工程', 4, '设计污水处理工艺流程与参数', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '污水处理工艺设计');
UPDATE `zy_skill` SET `alias` = '污水处理|活性污泥|a2o|工艺设计', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 4, `description` = '设计污水处理工艺流程与参数' WHERE `name` = '污水处理工艺设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '环境影响评价', '环评|环境影响评价|报告书', '工学', '环境科学与工程', 4, '编制环境影响评价报告', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '环境影响评价');
UPDATE `zy_skill` SET `alias` = '环评|环境影响评价|报告书', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 4, `description` = '编制环境影响评价报告' WHERE `name` = '环境影响评价' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '固废处理与资源化', '固废|垃圾处理|资源化|堆肥', '工学', '环境科学与工程', 4, '设计固废处理与资源化方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '固废处理与资源化');
UPDATE `zy_skill` SET `alias` = '固废|垃圾处理|资源化|堆肥', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 4, `description` = '设计固废处理与资源化方案' WHERE `name` = '固废处理与资源化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '环境监测数据分析', '环境数据|监测分析|趋势', '工学', '环境科学与工程', 3, '分析监测数据并识别污染趋势', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '环境监测数据分析');
UPDATE `zy_skill` SET `alias` = '环境数据|监测分析|趋势', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 3, `description` = '分析监测数据并识别污染趋势' WHERE `name` = '环境监测数据分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '噪声监测与控制', '噪声|监测|隔声|降噪', '工学', '环境科学与工程', 3, '监测噪声并设计降噪方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '噪声监测与控制');
UPDATE `zy_skill` SET `alias` = '噪声|监测|隔声|降噪', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 3, `description` = '监测噪声并设计降噪方案' WHERE `name` = '噪声监测与控制' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '土壤污染修复', '土壤修复|重金属|淋洗', '工学', '环境科学与工程', 5, '设计土壤污染修复方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '土壤污染修复');
UPDATE `zy_skill` SET `alias` = '土壤修复|重金属|淋洗', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 5, `description` = '设计土壤污染修复方案' WHERE `name` = '土壤污染修复' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '碳排放核算', '碳核算|碳足迹|碳交易', '工学', '环境科学与工程', 4, '核算碳排放并编制清单', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '碳排放核算');
UPDATE `zy_skill` SET `alias` = '碳核算|碳足迹|碳交易', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 4, `description` = '核算碳排放并编制清单' WHERE `name` = '碳排放核算' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '环境规划与管理', '环境规划|环境管理|总量控制', '工学', '环境科学与工程', 4, '编制环境规划与管理方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '环境规划与管理');
UPDATE `zy_skill` SET `alias` = '环境规划|环境管理|总量控制', `category_l1` = '工学', `category_l2` = '环境科学与工程', `difficulty` = 4, `description` = '编制环境规划与管理方案' WHERE `name` = '环境规划与管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '机械制图与公差配合', '机械制图|公差|形位公差', '工学', '机械工程', 3, '绘制机械图样并标注公差配合', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '机械制图与公差配合');
UPDATE `zy_skill` SET `alias` = '机械制图|公差|形位公差', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 3, `description` = '绘制机械图样并标注公差配合' WHERE `name` = '机械制图与公差配合' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'SolidWorks 三维建模', 'solidworks|sw|三维建模|装配', '工学', '机械工程', 3, '建立零件与装配体三维模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'SolidWorks 三维建模');
UPDATE `zy_skill` SET `alias` = 'solidworks|sw|三维建模|装配', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 3, `description` = '建立零件与装配体三维模型' WHERE `name` = 'SolidWorks 三维建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '有限元分析', 'ansys|有限元|仿真|应力分析', '工学', '机械工程', 5, '用有限元方法分析结构强度与模态', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '有限元分析');
UPDATE `zy_skill` SET `alias` = 'ansys|有限元|仿真|应力分析', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 5, `description` = '用有限元方法分析结构强度与模态' WHERE `name` = '有限元分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数控加工与编程', '数控|cnc|g代码|加工中心', '工学', '机械工程', 4, '编写数控程序并完成零件加工', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数控加工与编程');
UPDATE `zy_skill` SET `alias` = '数控|cnc|g代码|加工中心', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 4, `description` = '编写数控程序并完成零件加工' WHERE `name` = '数控加工与编程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '液压与气动系统', '液压|气动|回路设计', '工学', '机械工程', 4, '设计液压或气动控制回路', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '液压与气动系统');
UPDATE `zy_skill` SET `alias` = '液压|气动|回路设计', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 4, `description` = '设计液压或气动控制回路' WHERE `name` = '液压与气动系统' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '机械原理与机构设计', '机械原理|机构|连杆|凸轮', '工学', '机械工程', 4, '分析与设计常用机构', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '机械原理与机构设计');
UPDATE `zy_skill` SET `alias` = '机械原理|机构|连杆|凸轮', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 4, `description` = '分析与设计常用机构' WHERE `name` = '机械原理与机构设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '逆向工程与3D打印', '逆向工程|3d打印|扫描|增材制造', '工学', '机械工程', 3, '逆向建模并完成增材制造', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '逆向工程与3D打印');
UPDATE `zy_skill` SET `alias` = '逆向工程|3d打印|扫描|增材制造', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 3, `description` = '逆向建模并完成增材制造' WHERE `name` = '逆向工程与3D打印' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '机械制造工艺', '制造工艺|车削|铣削|工艺规程', '工学', '机械工程', 3, '编制零件制造工艺规程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '机械制造工艺');
UPDATE `zy_skill` SET `alias` = '制造工艺|车削|铣削|工艺规程', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 3, `description` = '编制零件制造工艺规程' WHERE `name` = '机械制造工艺' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '工程材料与选材', '工程材料|选材|热处理', '工学', '机械工程', 3, '按工况选择合适的工程材料', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '工程材料与选材');
UPDATE `zy_skill` SET `alias` = '工程材料|选材|热处理', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 3, `description` = '按工况选择合适的工程材料' WHERE `name` = '工程材料与选材' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '机械振动与噪声控制', '振动|噪声|模态|隔振', '工学', '机械工程', 5, '分析振动特性并提出减振方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '机械振动与噪声控制');
UPDATE `zy_skill` SET `alias` = '振动|噪声|模态|隔振', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 5, `description` = '分析振动特性并提出减振方案' WHERE `name` = '机械振动与噪声控制' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '热工与传热分析', '传热|热分析|散热|cfd', '工学', '机械工程', 4, '分析传热并进行散热设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '热工与传热分析');
UPDATE `zy_skill` SET `alias` = '传热|热分析|散热|cfd', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 4, `description` = '分析传热并进行散热设计' WHERE `name` = '热工与传热分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '机电一体化系统', '机电一体化|伺服|plc|控制', '工学', '机械工程', 4, '集成机械与电控实现自动化', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '机电一体化系统');
UPDATE `zy_skill` SET `alias` = '机电一体化|伺服|plc|控制', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 4, `description` = '集成机械与电控实现自动化' WHERE `name` = '机电一体化系统' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '工业机器人编程', '工业机器人|示教|离线编程', '工学', '机械工程', 4, '完成机器人示教与轨迹编程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '工业机器人编程');
UPDATE `zy_skill` SET `alias` = '工业机器人|示教|离线编程', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 4, `description` = '完成机器人示教与轨迹编程' WHERE `name` = '工业机器人编程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '精密测量与误差分析', '精密测量|三坐标|误差', '工学', '机械工程', 4, '完成精密测量与误差评估', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '精密测量与误差分析');
UPDATE `zy_skill` SET `alias` = '精密测量|三坐标|误差', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 4, `description` = '完成精密测量与误差评估' WHERE `name` = '精密测量与误差分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '机械产品结构设计', '结构设计|钣金|注塑件|装配', '工学', '机械工程', 4, '完成产品结构件设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '机械产品结构设计');
UPDATE `zy_skill` SET `alias` = '结构设计|钣金|注塑件|装配', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 4, `description` = '完成产品结构件设计' WHERE `name` = '机械产品结构设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '气压传动与夹具设计', '气动|夹具|工装', '工学', '机械工程', 4, '设计气动回路与工装夹具', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '气压传动与夹具设计');
UPDATE `zy_skill` SET `alias` = '气动|夹具|工装', `category_l1` = '工学', `category_l2` = '机械工程', `difficulty` = 4, `description` = '设计气动回路与工装夹具' WHERE `name` = '气压传动与夹具设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '气动分析与CFD', 'cfd|fluent|气动|流场仿真', '工学', '航空航天工程', 5, '用 CFD 分析流场与气动性能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '气动分析与CFD');
UPDATE `zy_skill` SET `alias` = 'cfd|fluent|气动|流场仿真', `category_l1` = '工学', `category_l2` = '航空航天工程', `difficulty` = 5, `description` = '用 CFD 分析流场与气动性能' WHERE `name` = '气动分析与CFD' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '飞行器总体设计', '飞行器设计|总体|气动布局', '工学', '航空航天工程', 5, '完成飞行器总体参数与布局设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '飞行器总体设计');
UPDATE `zy_skill` SET `alias` = '飞行器设计|总体|气动布局', `category_l1` = '工学', `category_l2` = '航空航天工程', `difficulty` = 5, `description` = '完成飞行器总体参数与布局设计' WHERE `name` = '飞行器总体设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '航模设计与制作', '航模|固定翼|穿越机|制作', '工学', '航空航天工程', 3, '设计并制作可用航模', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '航模设计与制作');
UPDATE `zy_skill` SET `alias` = '航模|固定翼|穿越机|制作', `category_l1` = '工学', `category_l2` = '航空航天工程', `difficulty` = 3, `description` = '设计并制作可用航模' WHERE `name` = '航模设计与制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '卫星轨道与姿态', '轨道力学|姿态控制|卫星', '工学', '航空航天工程', 5, '计算轨道与姿态控制方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '卫星轨道与姿态');
UPDATE `zy_skill` SET `alias` = '轨道力学|姿态控制|卫星', `category_l1` = '工学', `category_l2` = '航空航天工程', `difficulty` = 5, `description` = '计算轨道与姿态控制方案' WHERE `name` = '卫星轨道与姿态' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '锅炉与热力系统', '锅炉|热力系统|蒸汽', '工学', '动力工程及工程热物理', 4, '设计与运行热力系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '锅炉与热力系统');
UPDATE `zy_skill` SET `alias` = '锅炉|热力系统|蒸汽', `category_l1` = '工学', `category_l2` = '动力工程及工程热物理', `difficulty` = 4, `description` = '设计与运行热力系统' WHERE `name` = '锅炉与热力系统' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '内燃机原理与标定', '内燃机|发动机|标定', '工学', '动力工程及工程热物理', 5, '理解内燃机原理并做台架标定', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '内燃机原理与标定');
UPDATE `zy_skill` SET `alias` = '内燃机|发动机|标定', `category_l1` = '工学', `category_l2` = '动力工程及工程热物理', `difficulty` = 5, `description` = '理解内燃机原理并做台架标定' WHERE `name` = '内燃机原理与标定' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '制冷与低温技术', '制冷|空调|热泵|低温', '工学', '动力工程及工程热物理', 4, '设计制冷循环与低温系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '制冷与低温技术');
UPDATE `zy_skill` SET `alias` = '制冷|空调|热泵|低温', `category_l1` = '工学', `category_l2` = '动力工程及工程热物理', `difficulty` = 4, `description` = '设计制冷循环与低温系统' WHERE `name` = '制冷与低温技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '新能源发电技术', '光伏|风电|储能|新能源', '工学', '动力工程及工程热物理', 4, '设计新能源发电与储能方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '新能源发电技术');
UPDATE `zy_skill` SET `alias` = '光伏|风电|储能|新能源', `category_l1` = '工学', `category_l2` = '动力工程及工程热物理', `difficulty` = 4, `description` = '设计新能源发电与储能方案' WHERE `name` = '新能源发电技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '燃烧与节能技术', '燃烧|节能|余热回收', '工学', '动力工程及工程热物理', 4, '优化燃烧与余热利用', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '燃烧与节能技术');
UPDATE `zy_skill` SET `alias` = '燃烧|节能|余热回收', `category_l1` = '工学', `category_l2` = '动力工程及工程热物理', `difficulty` = 4, `description` = '优化燃烧与余热利用' WHERE `name` = '燃烧与节能技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '流体机械与泵阀', '泵|风机|阀门|流体机械', '工学', '动力工程及工程热物理', 4, '选型与调试流体机械', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '流体机械与泵阀');
UPDATE `zy_skill` SET `alias` = '泵|风机|阀门|流体机械', `category_l1` = '工学', `category_l2` = '动力工程及工程热物理', `difficulty` = 4, `description` = '选型与调试流体机械' WHERE `name` = '流体机械与泵阀' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '大地测量与GPS', 'gps|gnss|控制网|大地测量', '工学', '测绘科学与技术', 4, '布设控制网并处理 GNSS 数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '大地测量与GPS');
UPDATE `zy_skill` SET `alias` = 'gps|gnss|控制网|大地测量', `category_l1` = '工学', `category_l2` = '测绘科学与技术', `difficulty` = 4, `description` = '布设控制网并处理 GNSS 数据' WHERE `name` = '大地测量与GPS' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '摄影测量与三维重建', '摄影测量|三维重建|点云|倾斜摄影', '工学', '测绘科学与技术', 5, '用影像重建三维模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '摄影测量与三维重建');
UPDATE `zy_skill` SET `alias` = '摄影测量|三维重建|点云|倾斜摄影', `category_l1` = '工学', `category_l2` = '测绘科学与技术', `difficulty` = 5, `description` = '用影像重建三维模型' WHERE `name` = '摄影测量与三维重建' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '工程测量与变形监测', '变形监测|沉降|测量', '工学', '测绘科学与技术', 4, '实施变形监测与数据处理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '工程测量与变形监测');
UPDATE `zy_skill` SET `alias` = '变形监测|沉降|测量', `category_l1` = '工学', `category_l2` = '测绘科学与技术', `difficulty` = 4, `description` = '实施变形监测与数据处理' WHERE `name` = '工程测量与变形监测' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'GIS 二次开发', 'gis开发|arcgis engine|空间数据库', '工学', '测绘科学与技术', 5, '开发 GIS 应用与空间分析功能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'GIS 二次开发');
UPDATE `zy_skill` SET `alias` = 'gis开发|arcgis engine|空间数据库', `category_l1` = '工学', `category_l2` = '测绘科学与技术', `difficulty` = 5, `description` = '开发 GIS 应用与空间分析功能' WHERE `name` = 'GIS 二次开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '无人机航测', '航测|无人机|正射影像', '工学', '测绘科学与技术', 4, '规划航线并生成正射影像', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '无人机航测');
UPDATE `zy_skill` SET `alias` = '航测|无人机|正射影像', `category_l1` = '工学', `category_l2` = '测绘科学与技术', `difficulty` = 4, `description` = '规划航线并生成正射影像' WHERE `name` = '无人机航测' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '飞行动力学与仿真', '飞行动力学|simulink|仿真', '工学', '航空宇航科学与技术', 5, '建立飞行力学模型并仿真', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '飞行动力学与仿真');
UPDATE `zy_skill` SET `alias` = '飞行动力学|simulink|仿真', `category_l1` = '工学', `category_l2` = '航空宇航科学与技术', `difficulty` = 5, `description` = '建立飞行力学模型并仿真' WHERE `name` = '飞行动力学与仿真' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '航天器热控设计', '热控|热平衡|散热', '工学', '航空宇航科学与技术', 5, '设计航天器热控方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '航天器热控设计');
UPDATE `zy_skill` SET `alias` = '热控|热平衡|散热', `category_l1` = '工学', `category_l2` = '航空宇航科学与技术', `difficulty` = 5, `description` = '设计航天器热控方案' WHERE `name` = '航天器热控设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '复合材料结构分析', '复材结构|铺层|强度', '工学', '航空宇航科学与技术', 5, '分析复合材料结构强度', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '复合材料结构分析');
UPDATE `zy_skill` SET `alias` = '复材结构|铺层|强度', `category_l1` = '工学', `category_l2` = '航空宇航科学与技术', `difficulty` = 5, `description` = '分析复合材料结构强度' WHERE `name` = '复合材料结构分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '火箭推进原理', '推进|火箭发动机|比冲', '工学', '航空宇航科学与技术', 5, '理解推进原理与性能参数', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '火箭推进原理');
UPDATE `zy_skill` SET `alias` = '推进|火箭发动机|比冲', `category_l1` = '工学', `category_l2` = '航空宇航科学与技术', `difficulty` = 5, `description` = '理解推进原理与性能参数' WHERE `name` = '火箭推进原理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '医学图像处理', '医学图像|分割|配准|dicom', '工学', '生物医学工程', 5, '处理并分割医学影像', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '医学图像处理');
UPDATE `zy_skill` SET `alias` = '医学图像|分割|配准|dicom', `category_l1` = '工学', `category_l2` = '生物医学工程', `difficulty` = 5, `description` = '处理并分割医学影像' WHERE `name` = '医学图像处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生物信号采集与分析', '生物信号|心电|脑电|信号处理', '工学', '生物医学工程', 5, '采集并分析生理信号', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生物信号采集与分析');
UPDATE `zy_skill` SET `alias` = '生物信号|心电|脑电|信号处理', `category_l1` = '工学', `category_l2` = '生物医学工程', `difficulty` = 5, `description` = '采集并分析生理信号' WHERE `name` = '生物信号采集与分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '医疗仪器原理与维护', '医疗仪器|监护仪|维护', '工学', '生物医学工程', 4, '理解医疗仪器原理并维护', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '医疗仪器原理与维护');
UPDATE `zy_skill` SET `alias` = '医疗仪器|监护仪|维护', `category_l1` = '工学', `category_l2` = '生物医学工程', `difficulty` = 4, `description` = '理解医疗仪器原理并维护' WHERE `name` = '医疗仪器原理与维护' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生物材料与植入体', '生物材料|植入体|相容性', '工学', '生物医学工程', 5, '设计生物相容的植入材料', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生物材料与植入体');
UPDATE `zy_skill` SET `alias` = '生物材料|植入体|相容性', `category_l1` = '工学', `category_l2` = '生物医学工程', `difficulty` = 5, `description` = '设计生物相容的植入材料' WHERE `name` = '生物材料与植入体' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '康复辅具设计', '康复辅具|假肢|外骨骼', '工学', '生物医学工程', 5, '设计康复辅助器具', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '康复辅具设计');
UPDATE `zy_skill` SET `alias` = '康复辅具|假肢|外骨骼', `category_l1` = '工学', `category_l2` = '生物医学工程', `difficulty` = 5, `description` = '设计康复辅助器具' WHERE `name` = '康复辅具设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '渗透测试与漏洞挖掘', '渗透|漏洞|提权|exp', '工学', '网络空间安全', 5, '在授权范围内做渗透测试', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '渗透测试与漏洞挖掘');
UPDATE `zy_skill` SET `alias` = '渗透|漏洞|提权|exp', `category_l1` = '工学', `category_l2` = '网络空间安全', `difficulty` = 5, `description` = '在授权范围内做渗透测试' WHERE `name` = '渗透测试与漏洞挖掘' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Web 安全与防护', 'web安全|xss|sql注入|csrf', '工学', '网络空间安全', 4, '识别并修复常见 Web 漏洞', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Web 安全与防护');
UPDATE `zy_skill` SET `alias` = 'web安全|xss|sql注入|csrf', `category_l1` = '工学', `category_l2` = '网络空间安全', `difficulty` = 4, `description` = '识别并修复常见 Web 漏洞' WHERE `name` = 'Web 安全与防护' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '密码学应用', '密码学|对称加密|非对称|哈希', '工学', '网络空间安全', 4, '正确应用密码学原语', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '密码学应用');
UPDATE `zy_skill` SET `alias` = '密码学|对称加密|非对称|哈希', `category_l1` = '工学', `category_l2` = '网络空间安全', `difficulty` = 4, `description` = '正确应用密码学原语' WHERE `name` = '密码学应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '安全加固与基线', '安全加固|基线|等保', '工学', '网络空间安全', 4, '按基线加固主机与中间件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '安全加固与基线');
UPDATE `zy_skill` SET `alias` = '安全加固|基线|等保', `category_l1` = '工学', `category_l2` = '网络空间安全', `difficulty` = 4, `description` = '按基线加固主机与中间件' WHERE `name` = '安全加固与基线' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数字取证与应急响应', '取证|应急响应|溯源', '工学', '网络空间安全', 5, '处理安全事件并做取证溯源', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数字取证与应急响应');
UPDATE `zy_skill` SET `alias` = '取证|应急响应|溯源', `category_l1` = '工学', `category_l2` = '网络空间安全', `difficulty` = 5, `description` = '处理安全事件并做取证溯源' WHERE `name` = '数字取证与应急响应' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'CTF 竞赛训练', 'ctf|夺旗|逆向|pwn', '工学', '网络空间安全', 5, '参与 CTF 竞赛的专项训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'CTF 竞赛训练');
UPDATE `zy_skill` SET `alias` = 'ctf|夺旗|逆向|pwn', `category_l1` = '工学', `category_l2` = '网络空间安全', `difficulty` = 5, `description` = '参与 CTF 竞赛的专项训练' WHERE `name` = 'CTF 竞赛训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'AI 提示词工程', '提示词|prompt|提示工程|大模型', '工学', '人工智能', 3, '设计提示词让大模型稳定产出可用结果', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'AI 提示词工程');
UPDATE `zy_skill` SET `alias` = '提示词|prompt|提示工程|大模型', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 3, `description` = '设计提示词让大模型稳定产出可用结果' WHERE `name` = 'AI 提示词工程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '大模型 API 应用开发', 'llm api|openai|通义|接口调用', '工学', '人工智能', 4, '调用大模型接口构建应用', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '大模型 API 应用开发');
UPDATE `zy_skill` SET `alias` = 'llm api|openai|通义|接口调用', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 4, `description` = '调用大模型接口构建应用' WHERE `name` = '大模型 API 应用开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'RAG 检索增强生成', 'rag|向量检索|知识库问答', '工学', '人工智能', 5, '搭建检索增强的问答系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'RAG 检索增强生成');
UPDATE `zy_skill` SET `alias` = 'rag|向量检索|知识库问答', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '搭建检索增强的问答系统' WHERE `name` = 'RAG 检索增强生成' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '模型微调与训练', '微调|finetune|lora|训练', '工学', '人工智能', 5, '对模型做领域微调与效果评估', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '模型微调与训练');
UPDATE `zy_skill` SET `alias` = '微调|finetune|lora|训练', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '对模型做领域微调与效果评估' WHERE `name` = '模型微调与训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '机器学习建模', '机器学习|sklearn|特征工程|建模', '工学', '人工智能', 4, '用机器学习方法完成预测建模', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '机器学习建模');
UPDATE `zy_skill` SET `alias` = '机器学习|sklearn|特征工程|建模', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 4, `description` = '用机器学习方法完成预测建模' WHERE `name` = '机器学习建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '深度学习入门', '深度学习|pytorch|神经网络', '工学', '人工智能', 5, '搭建并训练神经网络模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '深度学习入门');
UPDATE `zy_skill` SET `alias` = '深度学习|pytorch|神经网络', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '搭建并训练神经网络模型' WHERE `name` = '深度学习入门' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '计算机视觉应用', 'cv|图像识别|目标检测|opencv', '工学', '人工智能', 5, '实现图像分类或目标检测', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '计算机视觉应用');
UPDATE `zy_skill` SET `alias` = 'cv|图像识别|目标检测|opencv', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '实现图像分类或目标检测' WHERE `name` = '计算机视觉应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '自然语言处理', 'nlp|文本分类|分词|情感分析', '工学', '人工智能', 5, '完成文本分类与信息抽取', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '自然语言处理');
UPDATE `zy_skill` SET `alias` = 'nlp|文本分类|分词|情感分析', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '完成文本分类与信息抽取' WHERE `name` = '自然语言处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据标注与质量校验', '数据标注|标注规范|质检', '工学', '人工智能', 2, '按规范完成数据标注与质量校验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据标注与质量校验');
UPDATE `zy_skill` SET `alias` = '数据标注|标注规范|质检', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 2, `description` = '按规范完成数据标注与质量校验' WHERE `name` = '数据标注与质量校验' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '模型评估与调参', '模型评估|交叉验证|调参|指标', '工学', '人工智能', 4, '评估模型表现并调优超参', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '模型评估与调参');
UPDATE `zy_skill` SET `alias` = '模型评估|交叉验证|调参|指标', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 4, `description` = '评估模型表现并调优超参' WHERE `name` = '模型评估与调参' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'AI 绘画与图像生成', 'ai绘画|stable diffusion|midjourney|文生图', '工学', '人工智能', 3, '用生成模型创作图像素材', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'AI 绘画与图像生成');
UPDATE `zy_skill` SET `alias` = 'ai绘画|stable diffusion|midjourney|文生图', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 3, `description` = '用生成模型创作图像素材' WHERE `name` = 'AI 绘画与图像生成' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'AI 辅助写作与润色', 'ai写作|润色|改写|摘要', '工学', '人工智能', 3, '用 AI 工具辅助写作与文本优化', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'AI 辅助写作与润色');
UPDATE `zy_skill` SET `alias` = 'ai写作|润色|改写|摘要', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 3, `description` = '用 AI 工具辅助写作与文本优化' WHERE `name` = 'AI 辅助写作与润色' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'AI 辅助编程', 'ai编程|copilot|代码补全', '工学', '人工智能', 3, '用 AI 工具提升编码效率', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'AI 辅助编程');
UPDATE `zy_skill` SET `alias` = 'ai编程|copilot|代码补全', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 3, `description` = '用 AI 工具提升编码效率' WHERE `name` = 'AI 辅助编程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '智能体与工作流编排', 'agent|智能体|工作流|自动化', '工学', '人工智能', 5, '编排多步骤智能体完成复杂任务', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '智能体与工作流编排');
UPDATE `zy_skill` SET `alias` = 'agent|智能体|工作流|自动化', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '编排多步骤智能体完成复杂任务' WHERE `name` = '智能体与工作流编排' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '推荐算法与排序', '推荐算法|协同过滤|排序模型', '工学', '人工智能', 5, '实现推荐排序算法', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '推荐算法与排序');
UPDATE `zy_skill` SET `alias` = '推荐算法|协同过滤|排序模型', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '实现推荐排序算法' WHERE `name` = '推荐算法与排序' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '知识图谱与图数据库', '知识图谱|neo4j|图数据库|本体', '工学', '人工智能', 5, '构建并查询知识图谱', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '知识图谱与图数据库');
UPDATE `zy_skill` SET `alias` = '知识图谱|neo4j|图数据库|本体', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '构建并查询知识图谱' WHERE `name` = '知识图谱与图数据库' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '向量数据库应用', '向量库|faiss|milvus|相似检索', '工学', '人工智能', 5, '用向量数据库做相似检索', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '向量数据库应用');
UPDATE `zy_skill` SET `alias` = '向量库|faiss|milvus|相似检索', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '用向量数据库做相似检索' WHERE `name` = '向量数据库应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '语音识别与合成', '语音识别|asr|tts|语音合成', '工学', '人工智能', 5, '实现语音转文字或文字转语音', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '语音识别与合成');
UPDATE `zy_skill` SET `alias` = '语音识别|asr|tts|语音合成', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '实现语音转文字或文字转语音' WHERE `name` = '语音识别与合成' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '多模态模型应用', '多模态|图文理解|视觉问答', '工学', '人工智能', 5, '用多模态模型处理图文混合任务', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '多模态模型应用');
UPDATE `zy_skill` SET `alias` = '多模态|图文理解|视觉问答', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 5, `description` = '用多模态模型处理图文混合任务' WHERE `name` = '多模态模型应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'AI 产品设计与评估', 'ai产品|效果评估|人机交互', '工学', '人工智能', 4, '设计 AI 产品并评估效果', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'AI 产品设计与评估');
UPDATE `zy_skill` SET `alias` = 'ai产品|效果评估|人机交互', `category_l1` = '工学', `category_l2` = '人工智能', `difficulty` = 4, `description` = '设计 AI 产品并评估效果' WHERE `name` = 'AI 产品设计与评估' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数学建模', '建模|数模|数学竞赛|美赛', '理学', '数学', 4, '把实际问题抽象为数学模型并求解与验证', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数学建模');
UPDATE `zy_skill` SET `alias` = '建模|数模|数学竞赛|美赛', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '把实际问题抽象为数学模型并求解与验证' WHERE `name` = '数学建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数学建模竞赛实战', '美赛|国赛|mcm|建模比赛', '理学', '数学', 5, '在限时条件下完成建模、求解与论文写作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数学建模竞赛实战');
UPDATE `zy_skill` SET `alias` = '美赛|国赛|mcm|建模比赛', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '在限时条件下完成建模、求解与论文写作' WHERE `name` = '数学建模竞赛实战' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '高等数学与微积分', '高数|微积分|极限|导数', '理学', '数学', 3, '掌握极限、微分、积分与级数', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '高等数学与微积分');
UPDATE `zy_skill` SET `alias` = '高数|微积分|极限|导数', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 3, `description` = '掌握极限、微分、积分与级数' WHERE `name` = '高等数学与微积分' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '线性代数与矩阵论', '线代|矩阵|特征值|线性空间', '理学', '数学', 3, '掌握矩阵运算、特征值与线性变换', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '线性代数与矩阵论');
UPDATE `zy_skill` SET `alias` = '线代|矩阵|特征值|线性空间', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 3, `description` = '掌握矩阵运算、特征值与线性变换' WHERE `name` = '线性代数与矩阵论' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '概率论与数理统计', '概率论|数理统计|假设检验|分布', '理学', '数学', 3, '掌握概率分布、估计与假设检验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '概率论与数理统计');
UPDATE `zy_skill` SET `alias` = '概率论|数理统计|假设检验|分布', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 3, `description` = '掌握概率分布、估计与假设检验' WHERE `name` = '概率论与数理统计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数值计算方法', '数值计算|数值分析|迭代|误差分析', '理学', '数学', 4, '用数值方法求解方程与优化问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数值计算方法');
UPDATE `zy_skill` SET `alias` = '数值计算|数值分析|迭代|误差分析', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '用数值方法求解方程与优化问题' WHERE `name` = '数值计算方法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '运筹学与最优化', '运筹学|最优化|线性规划|动态规划', '理学', '数学', 4, '建立优化模型并求解', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '运筹学与最优化');
UPDATE `zy_skill` SET `alias` = '运筹学|最优化|线性规划|动态规划', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '建立优化模型并求解' WHERE `name` = '运筹学与最优化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '常微分方程与建模', '微分方程|ode|动力学建模', '理学', '数学', 4, '建立并求解微分方程模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '常微分方程与建模');
UPDATE `zy_skill` SET `alias` = '微分方程|ode|动力学建模', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '建立并求解微分方程模型' WHERE `name` = '常微分方程与建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '随机过程与模拟', '随机过程|马尔可夫|蒙特卡洛', '理学', '数学', 5, '用随机过程与模拟方法分析问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '随机过程与模拟');
UPDATE `zy_skill` SET `alias` = '随机过程|马尔可夫|蒙特卡洛', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '用随机过程与模拟方法分析问题' WHERE `name` = '随机过程与模拟' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '统计分析软件应用', 'spss|sas|stata|统计分析', '理学', '数学', 3, '用统计软件完成数据处理与检验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '统计分析软件应用');
UPDATE `zy_skill` SET `alias` = 'spss|sas|stata|统计分析', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 3, `description` = '用统计软件完成数据处理与检验' WHERE `name` = '统计分析软件应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '时间序列分析', '时间序列|arima|预测', '理学', '数学', 5, '建立时间序列模型并做预测', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '时间序列分析');
UPDATE `zy_skill` SET `alias` = '时间序列|arima|预测', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '建立时间序列模型并做预测' WHERE `name` = '时间序列分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '复变函数与积分变换', '复变|积分变换|留数', '理学', '数学', 4, '掌握复变函数与变换方法', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '复变函数与积分变换');
UPDATE `zy_skill` SET `alias` = '复变|积分变换|留数', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '掌握复变函数与变换方法' WHERE `name` = '复变函数与积分变换' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '实变函数与泛函', '实变|泛函|测度', '理学', '数学', 5, '掌握测度与泛函基本理论', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '实变函数与泛函');
UPDATE `zy_skill` SET `alias` = '实变|泛函|测度', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '掌握测度与泛函基本理论' WHERE `name` = '实变函数与泛函' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '抽象代数与群论', '抽象代数|群论|环', '理学', '数学', 5, '掌握群环域的基本结构', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '抽象代数与群论');
UPDATE `zy_skill` SET `alias` = '抽象代数|群论|环', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '掌握群环域的基本结构' WHERE `name` = '抽象代数与群论' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '微分几何', '微分几何|流形|曲率', '理学', '数学', 5, '研究曲线曲面与流形几何', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '微分几何');
UPDATE `zy_skill` SET `alias` = '微分几何|流形|曲率', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '研究曲线曲面与流形几何' WHERE `name` = '微分几何' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '拓扑学基础', '拓扑|同胚|连通性', '理学', '数学', 5, '理解拓扑空间与连续映射', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '拓扑学基础');
UPDATE `zy_skill` SET `alias` = '拓扑|同胚|连通性', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '理解拓扑空间与连续映射' WHERE `name` = '拓扑学基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数论与密码数学', '数论|同余|素性', '理学', '数学', 5, '掌握初等数论与密码学基础', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数论与密码数学');
UPDATE `zy_skill` SET `alias` = '数论|同余|素性', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '掌握初等数论与密码学基础' WHERE `name` = '数论与密码数学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '图论与网络优化', '图论|网络流|最短路', '理学', '数学', 4, '用图论方法建模并求解', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '图论与网络优化');
UPDATE `zy_skill` SET `alias` = '图论|网络流|最短路', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '用图论方法建模并求解' WHERE `name` = '图论与网络优化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '组合数学与计数', '组合数学|排列组合|生成函数', '理学', '数学', 4, '解决计数与存在性问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '组合数学与计数');
UPDATE `zy_skill` SET `alias` = '组合数学|排列组合|生成函数', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '解决计数与存在性问题' WHERE `name` = '组合数学与计数' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数学分析证明训练', '数学分析|证明|ε-δ', '理学', '数学', 4, '训练严格的分析证明能力', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数学分析证明训练');
UPDATE `zy_skill` SET `alias` = '数学分析|证明|ε-δ', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '训练严格的分析证明能力' WHERE `name` = '数学分析证明训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '偏微分方程数值解', '偏微分方程|pde|有限差分', '理学', '数学', 5, '数值求解偏微分方程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '偏微分方程数值解');
UPDATE `zy_skill` SET `alias` = '偏微分方程|pde|有限差分', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '数值求解偏微分方程' WHERE `name` = '偏微分方程数值解' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '博弈论与决策', '博弈论|纳什均衡|策略', '理学', '数学', 4, '分析博弈结构与均衡', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '博弈论与决策');
UPDATE `zy_skill` SET `alias` = '博弈论|纳什均衡|策略', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '分析博弈结构与均衡' WHERE `name` = '博弈论与决策' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '模糊数学与综合评价', '模糊数学|隶属度|综合评价', '理学', '数学', 4, '用模糊方法做综合评价', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '模糊数学与综合评价');
UPDATE `zy_skill` SET `alias` = '模糊数学|隶属度|综合评价', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '用模糊方法做综合评价' WHERE `name` = '模糊数学与综合评价' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'MATLAB 数值计算与仿真', 'matlab|仿真|数值计算', '理学', '数学', 4, '用 MATLAB 建模、计算与仿真', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'MATLAB 数值计算与仿真');
UPDATE `zy_skill` SET `alias` = 'matlab|仿真|数值计算', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '用 MATLAB 建模、计算与仿真' WHERE `name` = 'MATLAB 数值计算与仿真' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'MATLAB 工具箱应用', 'matlab工具箱|simulink|优化工具箱', '理学', '数学', 5, '用专用工具箱解决领域问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'MATLAB 工具箱应用');
UPDATE `zy_skill` SET `alias` = 'matlab工具箱|simulink|优化工具箱', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 5, `description` = '用专用工具箱解决领域问题' WHERE `name` = 'MATLAB 工具箱应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Python 科学计算', 'scipy|sympy|科学计算', '理学', '数学', 4, '用 Python 做符号与数值计算', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Python 科学计算');
UPDATE `zy_skill` SET `alias` = 'scipy|sympy|科学计算', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '用 Python 做符号与数值计算' WHERE `name` = 'Python 科学计算' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数学公式编辑与排版', '公式编辑|mathtype|公式排版', '理学', '数学', 2, '规范编辑数学公式', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数学公式编辑与排版');
UPDATE `zy_skill` SET `alias` = '公式编辑|mathtype|公式排版', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 2, `description` = '规范编辑数学公式' WHERE `name` = '数学公式编辑与排版' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '几何画板与数学演示', '几何画板|动态演示|数学可视化', '理学', '数学', 3, '制作动态数学演示', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '几何画板与数学演示');
UPDATE `zy_skill` SET `alias` = '几何画板|动态演示|数学可视化', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 3, `description` = '制作动态数学演示' WHERE `name` = '几何画板与数学演示' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数学软件与计算器应用', 'maple|mathematica|计算器', '理学', '数学', 4, '用数学软件做符号运算', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数学软件与计算器应用');
UPDATE `zy_skill` SET `alias` = 'maple|mathematica|计算器', `category_l1` = '理学', `category_l2` = '数学', `difficulty` = 4, `description` = '用数学软件做符号运算' WHERE `name` = '数学软件与计算器应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '回归分析与建模', '回归|线性回归|多元回归', '理学', '统计学', 4, '建立回归模型并做诊断与解释', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '回归分析与建模');
UPDATE `zy_skill` SET `alias` = '回归|线性回归|多元回归', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 4, `description` = '建立回归模型并做诊断与解释' WHERE `name` = '回归分析与建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '方差分析与实验设计', '方差分析|anova|正交实验|doe', '理学', '统计学', 4, '设计实验并用方差分析检验差异', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '方差分析与实验设计');
UPDATE `zy_skill` SET `alias` = '方差分析|anova|正交实验|doe', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 4, `description` = '设计实验并用方差分析检验差异' WHERE `name` = '方差分析与实验设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '问卷调查与数据编码', '问卷|量表|信效度|编码', '理学', '统计学', 3, '设计问卷并完成信效度检验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '问卷调查与数据编码');
UPDATE `zy_skill` SET `alias` = '问卷|量表|信效度|编码', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 3, `description` = '设计问卷并完成信效度检验' WHERE `name` = '问卷调查与数据编码' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '贝叶斯统计方法', '贝叶斯|先验|后验|mcmc', '理学', '统计学', 5, '用贝叶斯方法做参数估计与推断', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '贝叶斯统计方法');
UPDATE `zy_skill` SET `alias` = '贝叶斯|先验|后验|mcmc', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 5, `description` = '用贝叶斯方法做参数估计与推断' WHERE `name` = '贝叶斯统计方法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据可视化统计图', '统计图|可视化|图表设计', '理学', '统计学', 2, '选择合适的图表表达数据结论', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据可视化统计图');
UPDATE `zy_skill` SET `alias` = '统计图|可视化|图表设计', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 2, `description` = '选择合适的图表表达数据结论' WHERE `name` = '数据可视化统计图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '非参数统计', '非参数|秩检验|bootstrap', '理学', '统计学', 5, '用非参数方法做统计推断', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '非参数统计');
UPDATE `zy_skill` SET `alias` = '非参数|秩检验|bootstrap', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 5, `description` = '用非参数方法做统计推断' WHERE `name` = '非参数统计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '多元统计分析', '多元统计|主成分|聚类|判别', '理学', '统计学', 5, '处理多变量数据关系', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '多元统计分析');
UPDATE `zy_skill` SET `alias` = '多元统计|主成分|聚类|判别', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 5, `description` = '处理多变量数据关系' WHERE `name` = '多元统计分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生存分析与可靠性', '生存分析|cox|可靠性', '理学', '统计学', 5, '分析生存数据与可靠性', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生存分析与可靠性');
UPDATE `zy_skill` SET `alias` = '生存分析|cox|可靠性', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 5, `description` = '分析生存数据与可靠性' WHERE `name` = '生存分析与可靠性' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '抽样调查设计', '抽样|分层|整群|加权', '理学', '统计学', 4, '设计抽样方案并估计误差', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '抽样调查设计');
UPDATE `zy_skill` SET `alias` = '抽样|分层|整群|加权', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 4, `description` = '设计抽样方案并估计误差' WHERE `name` = '抽样调查设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据挖掘与关联规则', '数据挖掘|关联规则|聚类', '理学', '统计学', 4, '从数据中发现模式与规则', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据挖掘与关联规则');
UPDATE `zy_skill` SET `alias` = '数据挖掘|关联规则|聚类', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 4, `description` = '从数据中发现模式与规则' WHERE `name` = '数据挖掘与关联规则' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '统计计算与模拟', '统计计算|r语言|模拟', '理学', '统计学', 4, '用 R 或 Python 实现统计计算', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '统计计算与模拟');
UPDATE `zy_skill` SET `alias` = '统计计算|r语言|模拟', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 4, `description` = '用 R 或 Python 实现统计计算' WHERE `name` = '统计计算与模拟' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'R 语言统计分析', 'r语言|rstudio|统计建模', '理学', '统计学', 4, '用 R 完成统计分析与绘图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'R 语言统计分析');
UPDATE `zy_skill` SET `alias` = 'r语言|rstudio|统计建模', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 4, `description` = '用 R 完成统计分析与绘图' WHERE `name` = 'R 语言统计分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Python 统计建模', 'statsmodels|统计建模|回归', '理学', '统计学', 4, '用 Python 库做统计建模', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Python 统计建模');
UPDATE `zy_skill` SET `alias` = 'statsmodels|统计建模|回归', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 4, `description` = '用 Python 库做统计建模' WHERE `name` = 'Python 统计建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据清洗与特征构造', '数据清洗|缺失值|特征工程', '理学', '统计学', 3, '清洗数据并构造有效特征', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据清洗与特征构造');
UPDATE `zy_skill` SET `alias` = '数据清洗|缺失值|特征工程', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 3, `description` = '清洗数据并构造有效特征' WHERE `name` = '数据清洗与特征构造' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '报表自动化与看板', '报表自动化|bi看板|定时导出', '理学', '统计学', 3, '自动生成报表与数据看板', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '报表自动化与看板');
UPDATE `zy_skill` SET `alias` = '报表自动化|bi看板|定时导出', `category_l1` = '理学', `category_l2` = '统计学', `difficulty` = 3, `description` = '自动生成报表与数据看板' WHERE `name` = '报表自动化与看板' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '大学物理实验', '物理实验|误差分析|实验报告', '理学', '物理学', 3, '完成力学电磁光学基础实验与误差分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '大学物理实验');
UPDATE `zy_skill` SET `alias` = '物理实验|误差分析|实验报告', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 3, `description` = '完成力学电磁光学基础实验与误差分析' WHERE `name` = '大学物理实验' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '理论力学与动力学', '理论力学|牛顿力学|拉格朗日', '理学', '物理学', 4, '分析质点与刚体系统的运动', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '理论力学与动力学');
UPDATE `zy_skill` SET `alias` = '理论力学|牛顿力学|拉格朗日', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 4, `description` = '分析质点与刚体系统的运动' WHERE `name` = '理论力学与动力学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '电磁场与电磁波', '电磁场|麦克斯韦|电磁波', '理学', '物理学', 4, '理解电磁场方程与波的传播', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '电磁场与电磁波');
UPDATE `zy_skill` SET `alias` = '电磁场|麦克斯韦|电磁波', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 4, `description` = '理解电磁场方程与波的传播' WHERE `name` = '电磁场与电磁波' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '量子力学基础', '量子力学|波函数|薛定谔', '理学', '物理学', 5, '掌握波函数、算符与基本量子现象', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '量子力学基础');
UPDATE `zy_skill` SET `alias` = '量子力学|波函数|薛定谔', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 5, `description` = '掌握波函数、算符与基本量子现象' WHERE `name` = '量子力学基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '光学与激光技术', '光学|激光|干涉|衍射', '理学', '物理学', 4, '理解干涉衍射与激光原理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '光学与激光技术');
UPDATE `zy_skill` SET `alias` = '光学|激光|干涉|衍射', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 4, `description` = '理解干涉衍射与激光原理' WHERE `name` = '光学与激光技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '计算物理与数值模拟', '计算物理|数值模拟|蒙特卡洛', '理学', '物理学', 5, '用数值方法模拟物理过程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '计算物理与数值模拟');
UPDATE `zy_skill` SET `alias` = '计算物理|数值模拟|蒙特卡洛', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 5, `description` = '用数值方法模拟物理过程' WHERE `name` = '计算物理与数值模拟' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '固体物理与材料性能', '固体物理|能带|晶格', '理学', '物理学', 5, '理解晶体结构与固体电学性质', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '固体物理与材料性能');
UPDATE `zy_skill` SET `alias` = '固体物理|能带|晶格', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 5, `description` = '理解晶体结构与固体电学性质' WHERE `name` = '固体物理与材料性能' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '热力学与统计物理', '热力学|统计物理|熵', '理学', '物理学', 5, '理解热现象与统计规律', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '热力学与统计物理');
UPDATE `zy_skill` SET `alias` = '热力学|统计物理|熵', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 5, `description` = '理解热现象与统计规律' WHERE `name` = '热力学与统计物理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '近代物理实验', '近代物理实验|光谱|核物理', '理学', '物理学', 4, '完成近代物理实验与分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '近代物理实验');
UPDATE `zy_skill` SET `alias` = '近代物理实验|光谱|核物理', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 4, `description` = '完成近代物理实验与分析' WHERE `name` = '近代物理实验' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '半导体物理', '半导体|pn结|载流子', '理学', '物理学', 5, '理解半导体器件物理基础', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '半导体物理');
UPDATE `zy_skill` SET `alias` = '半导体|pn结|载流子', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 5, `description` = '理解半导体器件物理基础' WHERE `name` = '半导体物理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '流体力学基础', '流体力学|伯努利|湍流', '理学', '物理学', 4, '分析流体运动与受力', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '流体力学基础');
UPDATE `zy_skill` SET `alias` = '流体力学|伯努利|湍流', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 4, `description` = '分析流体运动与受力' WHERE `name` = '流体力学基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '天体物理与观测', '天体物理|天文观测|星等', '理学', '物理学', 4, '开展天文观测与数据处理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '天体物理与观测');
UPDATE `zy_skill` SET `alias` = '天体物理|天文观测|星等', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 4, `description` = '开展天文观测与数据处理' WHERE `name` = '天体物理与观测' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '物理竞赛辅导', '物理竞赛|cpho|解题', '理学', '物理学', 4, '针对性物理竞赛训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '物理竞赛辅导');
UPDATE `zy_skill` SET `alias` = '物理竞赛|cpho|解题', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 4, `description` = '针对性物理竞赛训练' WHERE `name` = '物理竞赛辅导' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '物理仿真软件应用', 'comsol|仿真|有限元物理', '理学', '物理学', 5, '用仿真软件模拟物理场', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '物理仿真软件应用');
UPDATE `zy_skill` SET `alias` = 'comsol|仿真|有限元物理', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 5, `description` = '用仿真软件模拟物理场' WHERE `name` = '物理仿真软件应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Origin 数据作图', 'origin|作图|拟合', '理学', '物理学', 3, '用 Origin 处理数据并拟合作图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Origin 数据作图');
UPDATE `zy_skill` SET `alias` = 'origin|作图|拟合', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 3, `description` = '用 Origin 处理数据并拟合作图' WHERE `name` = 'Origin 数据作图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '示波与信号测量', '信号测量|示波|频谱', '理学', '物理学', 4, '测量并分析电信号', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '示波与信号测量');
UPDATE `zy_skill` SET `alias` = '信号测量|示波|频谱', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 4, `description` = '测量并分析电信号' WHERE `name` = '示波与信号测量' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '物理教学演示制作', '物理演示|教具|实验设计', '理学', '物理学', 3, '制作物理教学演示与教具', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '物理教学演示制作');
UPDATE `zy_skill` SET `alias` = '物理演示|教具|实验设计', `category_l1` = '理学', `category_l2` = '物理学', `difficulty` = 3, `description` = '制作物理教学演示与教具' WHERE `name` = '物理教学演示制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '有机化学合成', '有机化学|合成|反应机理', '理学', '化学', 4, '设计并完成有机合成路线', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '有机化学合成');
UPDATE `zy_skill` SET `alias` = '有机化学|合成|反应机理', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 4, `description` = '设计并完成有机合成路线' WHERE `name` = '有机化学合成' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '分析化学与滴定', '分析化学|滴定|定量分析', '理学', '化学', 3, '用滴定等方法完成定量分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '分析化学与滴定');
UPDATE `zy_skill` SET `alias` = '分析化学|滴定|定量分析', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 3, `description` = '用滴定等方法完成定量分析' WHERE `name` = '分析化学与滴定' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '无机化学与配位', '无机化学|配位|晶体', '理学', '化学', 4, '理解配位化合物与无机反应规律', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '无机化学与配位');
UPDATE `zy_skill` SET `alias` = '无机化学|配位|晶体', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 4, `description` = '理解配位化合物与无机反应规律' WHERE `name` = '无机化学与配位' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '物理化学与热力学', '物理化学|热力学|动力学|电化学', '理学', '化学', 5, '用热力学与动力学分析化学过程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '物理化学与热力学');
UPDATE `zy_skill` SET `alias` = '物理化学|热力学|动力学|电化学', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 5, `description` = '用热力学与动力学分析化学过程' WHERE `name` = '物理化学与热力学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化学信息与结构解析', 'chemdraw|核磁|质谱|结构解析', '理学', '化学', 4, '据谱图推断化合物结构', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化学信息与结构解析');
UPDATE `zy_skill` SET `alias` = 'chemdraw|核磁|质谱|结构解析', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 4, `description` = '据谱图推断化合物结构' WHERE `name` = '化学信息与结构解析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '高分子化学', '高分子化学|聚合|分子量', '理学', '化学', 4, '理解聚合反应与高分子结构', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '高分子化学');
UPDATE `zy_skill` SET `alias` = '高分子化学|聚合|分子量', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 4, `description` = '理解聚合反应与高分子结构' WHERE `name` = '高分子化学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化学反应工程', '反应工程|动力学|反应器', '理学', '化学', 5, '设计反应器与工艺条件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化学反应工程');
UPDATE `zy_skill` SET `alias` = '反应工程|动力学|反应器', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 5, `description` = '设计反应器与工艺条件' WHERE `name` = '化学反应工程' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '电化学与电池', '电化学|循环伏安|电池', '理学', '化学', 5, '用电化学方法研究电极过程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '电化学与电池');
UPDATE `zy_skill` SET `alias` = '电化学|循环伏安|电池', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 5, `description` = '用电化学方法研究电极过程' WHERE `name` = '电化学与电池' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '绿色化学与催化', '绿色化学|催化|原子经济', '理学', '化学', 4, '设计环境友好的合成路线', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '绿色化学与催化');
UPDATE `zy_skill` SET `alias` = '绿色化学|催化|原子经济', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 4, `description` = '设计环境友好的合成路线' WHERE `name` = '绿色化学与催化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化学实验室安全', '实验室安全|危化品|应急', '理学', '化学', 2, '掌握化学实验室安全规范', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化学实验室安全');
UPDATE `zy_skill` SET `alias` = '实验室安全|危化品|应急', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 2, `description` = '掌握化学实验室安全规范' WHERE `name` = '化学实验室安全' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '计算化学入门', '计算化学|gaussian|dft', '理学', '化学', 5, '用计算化学方法研究分子', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '计算化学入门');
UPDATE `zy_skill` SET `alias` = '计算化学|gaussian|dft', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 5, `description` = '用计算化学方法研究分子' WHERE `name` = '计算化学入门' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'ChemDraw 结构绘制', 'chemdraw|结构式|反应式', '理学', '化学', 3, '绘制化学结构与反应式', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'ChemDraw 结构绘制');
UPDATE `zy_skill` SET `alias` = 'chemdraw|结构式|反应式', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 3, `description` = '绘制化学结构与反应式' WHERE `name` = 'ChemDraw 结构绘制' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化学实验数据处理', '实验数据|origin|拟合|误差', '理学', '化学', 3, '处理化学实验数据并作图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化学实验数据处理');
UPDATE `zy_skill` SET `alias` = '实验数据|origin|拟合|误差', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 3, `description` = '处理化学实验数据并作图' WHERE `name` = '化学实验数据处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '实验室仪器操作', '旋蒸|离心|ph计|天平', '理学', '化学', 3, '规范操作常用化学仪器', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '实验室仪器操作');
UPDATE `zy_skill` SET `alias` = '旋蒸|离心|ph计|天平', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 3, `description` = '规范操作常用化学仪器' WHERE `name` = '实验室仪器操作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '化学品管理与安全', '化学品|危废|台账|安全', '理学', '化学', 2, '管理化学品台账与安全处置', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '化学品管理与安全');
UPDATE `zy_skill` SET `alias` = '化学品|危废|台账|安全', `category_l1` = '理学', `category_l2` = '化学', `difficulty` = 2, `description` = '管理化学品台账与安全处置' WHERE `name` = '化学品管理与安全' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '科研实验设计', '实验设计|科研方法|实验方案', '理学', '生物学', 4, '设计可复现的实验方案、对照组与统计方法', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '科研实验设计');
UPDATE `zy_skill` SET `alias` = '实验设计|科研方法|实验方案', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 4, `description` = '设计可复现的实验方案、对照组与统计方法' WHERE `name` = '科研实验设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '分子生物学实验', '分子生物学|pcr|电泳|克隆', '理学', '生物学', 4, '完成 PCR、电泳与克隆等基础操作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '分子生物学实验');
UPDATE `zy_skill` SET `alias` = '分子生物学|pcr|电泳|克隆', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 4, `description` = '完成 PCR、电泳与克隆等基础操作' WHERE `name` = '分子生物学实验' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '细胞培养技术', '细胞培养|传代|无菌操作|培养基', '理学', '生物学', 4, '无菌条件下培养与维护细胞', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '细胞培养技术');
UPDATE `zy_skill` SET `alias` = '细胞培养|传代|无菌操作|培养基', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 4, `description` = '无菌条件下培养与维护细胞' WHERE `name` = '细胞培养技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生物信息学分析', '生信|序列分析|blast|基因组', '理学', '生物学', 5, '分析基因序列与表达数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生物信息学分析');
UPDATE `zy_skill` SET `alias` = '生信|序列分析|blast|基因组', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 5, `description` = '分析基因序列与表达数据' WHERE `name` = '生物信息学分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '显微成像与观察', '显微镜|荧光|成像|切片', '理学', '生物学', 3, '制样、切片与显微观察记录', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '显微成像与观察');
UPDATE `zy_skill` SET `alias` = '显微镜|荧光|成像|切片', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 3, `description` = '制样、切片与显微观察记录' WHERE `name` = '显微成像与观察' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生态调查与采样', '生态调查|样方|生物多样性', '理学', '生物学', 3, '设计样方并完成生态数据采集', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生态调查与采样');
UPDATE `zy_skill` SET `alias` = '生态调查|样方|生物多样性', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 3, `description` = '设计样方并完成生态数据采集' WHERE `name` = '生态调查与采样' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '实验数据处理与作图', '实验数据|作图|origin|误差', '理学', '生物学', 3, '处理实验数据并绘制规范图表', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '实验数据处理与作图');
UPDATE `zy_skill` SET `alias` = '实验数据|作图|origin|误差', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 3, `description` = '处理实验数据并绘制规范图表' WHERE `name` = '实验数据处理与作图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '遗传学与基因编辑', '遗传学|基因编辑|crispr', '理学', '生物学', 5, '理解遗传规律并操作基因编辑', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '遗传学与基因编辑');
UPDATE `zy_skill` SET `alias` = '遗传学|基因编辑|crispr', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 5, `description` = '理解遗传规律并操作基因编辑' WHERE `name` = '遗传学与基因编辑' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '微生物培养与鉴定', '微生物|培养|鉴定|菌种', '理学', '生物学', 4, '培养并鉴定微生物', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '微生物培养与鉴定');
UPDATE `zy_skill` SET `alias` = '微生物|培养|鉴定|菌种', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 4, `description` = '培养并鉴定微生物' WHERE `name` = '微生物培养与鉴定' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '植物组织培养', '组培|无菌|继代', '理学', '生物学', 4, '完成植物组织培养操作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '植物组织培养');
UPDATE `zy_skill` SET `alias` = '组培|无菌|继代', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 4, `description` = '完成植物组织培养操作' WHERE `name` = '植物组织培养' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '动物实验与伦理', '动物实验|伦理|给药', '理学', '生物学', 4, '规范开展动物实验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '动物实验与伦理');
UPDATE `zy_skill` SET `alias` = '动物实验|伦理|给药', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 4, `description` = '规范开展动物实验' WHERE `name` = '动物实验与伦理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '蛋白质表达与纯化', '蛋白表达|纯化|western', '理学', '生物学', 5, '表达并纯化目标蛋白', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '蛋白质表达与纯化');
UPDATE `zy_skill` SET `alias` = '蛋白表达|纯化|western', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 5, `description` = '表达并纯化目标蛋白' WHERE `name` = '蛋白质表达与纯化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生态建模与simulation', '生态模型|种群动态|模拟', '理学', '生物学', 5, '建立生态动力学模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生态建模与simulation');
UPDATE `zy_skill` SET `alias` = '生态模型|种群动态|模拟', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 5, `description` = '建立生态动力学模型' WHERE `name` = '生态建模与simulation' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生物统计与R应用', '生物统计|r语言|差异分析', '理学', '生物学', 4, '用 R 做生物数据统计分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生物统计与R应用');
UPDATE `zy_skill` SET `alias` = '生物统计|r语言|差异分析', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 4, `description` = '用 R 做生物数据统计分析' WHERE `name` = '生物统计与R应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '显微镜操作与制片', '显微镜|制片|染色|观察', '理学', '生物学', 3, '制片并用显微镜观察记录', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '显微镜操作与制片');
UPDATE `zy_skill` SET `alias` = '显微镜|制片|染色|观察', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 3, `description` = '制片并用显微镜观察记录' WHERE `name` = '显微镜操作与制片' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生物统计与作图', '生物统计|graphpad|作图', '理学', '生物学', 4, '用 GraphPad 等做生物统计作图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生物统计与作图');
UPDATE `zy_skill` SET `alias` = '生物统计|graphpad|作图', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 4, `description` = '用 GraphPad 等做生物统计作图' WHERE `name` = '生物统计与作图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '实验记录与数据管理', '实验记录|原始数据|可复现', '理学', '生物学', 3, '规范记录实验过程与数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '实验记录与数据管理');
UPDATE `zy_skill` SET `alias` = '实验记录|原始数据|可复现', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 3, `description` = '规范记录实验过程与数据' WHERE `name` = '实验记录与数据管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生物绘图与示意图', '生物绘图|示意图|illustrator', '理学', '生物学', 3, '绘制生物结构与通路示意图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生物绘图与示意图');
UPDATE `zy_skill` SET `alias` = '生物绘图|示意图|illustrator', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 3, `description` = '绘制生物结构与通路示意图' WHERE `name` = '生物绘图与示意图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '野外调查与标本采集', '野外调查|标本|采集记录', '理学', '生物学', 3, '开展野外调查与标本采集', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '野外调查与标本采集');
UPDATE `zy_skill` SET `alias` = '野外调查|标本|采集记录', `category_l1` = '理学', `category_l2` = '生物学', `difficulty` = 3, `description` = '开展野外调查与标本采集' WHERE `name` = '野外调查与标本采集' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '遥感影像解译', '遥感|解译|影像分类|envi', '理学', '地理科学', 4, '解译遥感影像并提取地物信息', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '遥感影像解译');
UPDATE `zy_skill` SET `alias` = '遥感|解译|影像分类|envi', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 4, `description` = '解译遥感影像并提取地物信息' WHERE `name` = '遥感影像解译' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'GIS 空间分析', 'gis|arcgis|空间分析|矢量化', '理学', '地理科学', 4, '用 GIS 完成空间数据管理与分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'GIS 空间分析');
UPDATE `zy_skill` SET `alias` = 'gis|arcgis|空间分析|矢量化', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 4, `description` = '用 GIS 完成空间数据管理与分析' WHERE `name` = 'GIS 空间分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '地图制图与可视化', '地图制图|专题图|符号化', '理学', '地理科学', 3, '设计并制作规范专题地图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '地图制图与可视化');
UPDATE `zy_skill` SET `alias` = '地图制图|专题图|符号化', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 3, `description` = '设计并制作规范专题地图' WHERE `name` = '地图制图与可视化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '气象数据分析', '气象数据|气候分析|插值', '理学', '地理科学', 4, '分析气象要素的时空分布', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '气象数据分析');
UPDATE `zy_skill` SET `alias` = '气象数据|气候分析|插值', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 4, `description` = '分析气象要素的时空分布' WHERE `name` = '气象数据分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '野外地质与地貌考察', '地质考察|地貌|剖面|罗盘', '理学', '地理科学', 3, '野外识别岩性与地貌并记录', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '野外地质与地貌考察');
UPDATE `zy_skill` SET `alias` = '地质考察|地貌|剖面|罗盘', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 3, `description` = '野外识别岩性与地貌并记录' WHERE `name` = '野外地质与地貌考察' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '水文观测与计算', '水文|径流|水位|水文计算', '理学', '地理科学', 4, '观测并计算水文要素', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '水文观测与计算');
UPDATE `zy_skill` SET `alias` = '水文|径流|水位|水文计算', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 4, `description` = '观测并计算水文要素' WHERE `name` = '水文观测与计算' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '城市地理与空间结构', '城市地理|空间结构|职住', '理学', '地理科学', 4, '分析城市空间结构与演变', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '城市地理与空间结构');
UPDATE `zy_skill` SET `alias` = '城市地理|空间结构|职住', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 4, `description` = '分析城市空间结构与演变' WHERE `name` = '城市地理与空间结构' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '地理信息系统建库', 'gis建库|数据标准|图属一体', '理学', '地理科学', 4, '建立规范的空间数据库', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '地理信息系统建库');
UPDATE `zy_skill` SET `alias` = 'gis建库|数据标准|图属一体', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 4, `description` = '建立规范的空间数据库' WHERE `name` = '地理信息系统建库' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '自然灾害风险评估', '灾害评估|风险|脆弱性', '理学', '地理科学', 4, '评估自然灾害风险等级', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '自然灾害风险评估');
UPDATE `zy_skill` SET `alias` = '灾害评估|风险|脆弱性', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 4, `description` = '评估自然灾害风险等级' WHERE `name` = '自然灾害风险评估' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Google Earth 与地图应用', 'google earth|卫星图|地图', '理学', '地理科学', 2, '用卫星图与在线地图做地理分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Google Earth 与地图应用');
UPDATE `zy_skill` SET `alias` = 'google earth|卫星图|地图', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 2, `description` = '用卫星图与在线地图做地理分析' WHERE `name` = 'Google Earth 与地图应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '空间数据格式与转换', 'shp|geojson|坐标转换|投影', '理学', '地理科学', 4, '处理空间数据格式与坐标转换', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '空间数据格式与转换');
UPDATE `zy_skill` SET `alias` = 'shp|geojson|坐标转换|投影', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 4, `description` = '处理空间数据格式与坐标转换' WHERE `name` = '空间数据格式与转换' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '气候数据处理', '气候数据|nc文件|插值', '理学', '地理科学', 5, '处理再分析资料与气候数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '气候数据处理');
UPDATE `zy_skill` SET `alias` = '气候数据|nc文件|插值', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 5, `description` = '处理再分析资料与气候数据' WHERE `name` = '气候数据处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '地理调查与问卷', '地理调查|实地调研|问卷', '理学', '地理科学', 3, '开展地理实地调查与问卷', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '地理调查与问卷');
UPDATE `zy_skill` SET `alias` = '地理调查|实地调研|问卷', `category_l1` = '理学', `category_l2` = '地理科学', `difficulty` = 3, `description` = '开展地理实地调查与问卷' WHERE `name` = '地理调查与问卷' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '心理测量与量表分析', '心理测量|量表|信效度|因子分析', '理学', '心理学', 4, '编制与检验心理量表', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '心理测量与量表分析');
UPDATE `zy_skill` SET `alias` = '心理测量|量表|信效度|因子分析', `category_l1` = '理学', `category_l2` = '心理学', `difficulty` = 4, `description` = '编制与检验心理量表' WHERE `name` = '心理测量与量表分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '实验心理学设计', '实验心理学|实验设计|反应时', '理学', '心理学', 4, '设计行为实验并分析数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '实验心理学设计');
UPDATE `zy_skill` SET `alias` = '实验心理学|实验设计|反应时', `category_l1` = '理学', `category_l2` = '心理学', `difficulty` = 4, `description` = '设计行为实验并分析数据' WHERE `name` = '实验心理学设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '心理咨询基本技术', '心理咨询|倾听|共情|访谈', '理学', '心理学', 3, '掌握基本咨询技术与伦理边界', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '心理咨询基本技术');
UPDATE `zy_skill` SET `alias` = '心理咨询|倾听|共情|访谈', `category_l1` = '理学', `category_l2` = '心理学', `difficulty` = 3, `description` = '掌握基本咨询技术与伦理边界' WHERE `name` = '心理咨询基本技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '认知心理学范式', '认知心理学|注意|记忆|范式', '理学', '心理学', 4, '理解并实施经典认知实验范式', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '认知心理学范式');
UPDATE `zy_skill` SET `alias` = '认知心理学|注意|记忆|范式', `category_l1` = '理学', `category_l2` = '心理学', `difficulty` = 4, `description` = '理解并实施经典认知实验范式' WHERE `name` = '认知心理学范式' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '用户体验心理研究', '用户心理|可用性|用户访谈', '理学', '心理学', 3, '用心理学方法研究用户行为', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '用户体验心理研究');
UPDATE `zy_skill` SET `alias` = '用户心理|可用性|用户访谈', `category_l1` = '理学', `category_l2` = '心理学', `difficulty` = 3, `description` = '用心理学方法研究用户行为' WHERE `name` = '用户体验心理研究' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '海洋调查与观测', '海洋调查|水文观测|采样', '理学', '海洋科学', 4, '完成海洋水文与生物采样观测', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '海洋调查与观测');
UPDATE `zy_skill` SET `alias` = '海洋调查|水文观测|采样', `category_l1` = '理学', `category_l2` = '海洋科学', `difficulty` = 4, `description` = '完成海洋水文与生物采样观测' WHERE `name` = '海洋调查与观测' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '海洋数据分析', '海洋数据|温盐深|数据分析', '理学', '海洋科学', 4, '分析海洋观测数据并绘图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '海洋数据分析');
UPDATE `zy_skill` SET `alias` = '海洋数据|温盐深|数据分析', `category_l1` = '理学', `category_l2` = '海洋科学', `difficulty` = 4, `description` = '分析海洋观测数据并绘图' WHERE `name` = '海洋数据分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '物理海洋学基础', '物理海洋|环流|潮汐', '理学', '海洋科学', 5, '理解海洋环流与潮汐动力机制', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '物理海洋学基础');
UPDATE `zy_skill` SET `alias` = '物理海洋|环流|潮汐', `category_l1` = '理学', `category_l2` = '海洋科学', `difficulty` = 5, `description` = '理解海洋环流与潮汐动力机制' WHERE `name` = '物理海洋学基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '海洋生物采样与鉴定', '海洋生物|采样|鉴定', '理学', '海洋科学', 4, '采集并鉴定海洋生物', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '海洋生物采样与鉴定');
UPDATE `zy_skill` SET `alias` = '海洋生物|采样|鉴定', `category_l1` = '理学', `category_l2` = '海洋科学', `difficulty` = 4, `description` = '采集并鉴定海洋生物' WHERE `name` = '海洋生物采样与鉴定' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '海洋化学分析', '海洋化学|营养盐|分析', '理学', '海洋科学', 4, '分析海水化学要素', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '海洋化学分析');
UPDATE `zy_skill` SET `alias` = '海洋化学|营养盐|分析', `category_l1` = '理学', `category_l2` = '海洋科学', `difficulty` = 4, `description` = '分析海水化学要素' WHERE `name` = '海洋化学分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '海洋地质与沉积', '海洋地质|沉积物|柱样', '理学', '海洋科学', 5, '分析海底沉积物记录', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '海洋地质与沉积');
UPDATE `zy_skill` SET `alias` = '海洋地质|沉积物|柱样', `category_l1` = '理学', `category_l2` = '海洋科学', `difficulty` = 5, `description` = '分析海底沉积物记录' WHERE `name` = '海洋地质与沉积' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '矿物岩石鉴定', '矿物|岩石|镜下鉴定', '理学', '地质学', 4, '镜下鉴定矿物与岩石', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '矿物岩石鉴定');
UPDATE `zy_skill` SET `alias` = '矿物|岩石|镜下鉴定', `category_l1` = '理学', `category_l2` = '地质学', `difficulty` = 4, `description` = '镜下鉴定矿物与岩石' WHERE `name` = '矿物岩石鉴定' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '构造地质分析', '构造|褶皱|断层|剖面', '理学', '地质学', 5, '分析地质构造形态', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '构造地质分析');
UPDATE `zy_skill` SET `alias` = '构造|褶皱|断层|剖面', `category_l1` = '理学', `category_l2` = '地质学', `difficulty` = 5, `description` = '分析地质构造形态' WHERE `name` = '构造地质分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '地层与古生物', '地层|古生物|化石', '理学', '地质学', 4, '划分地层并识别化石', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '地层与古生物');
UPDATE `zy_skill` SET `alias` = '地层|古生物|化石', `category_l1` = '理学', `category_l2` = '地质学', `difficulty` = 4, `description` = '划分地层并识别化石' WHERE `name` = '地层与古生物' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '地球物理勘探', '物探|地震|电法|重力', '理学', '地质学', 5, '用物探方法探测地下结构', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '地球物理勘探');
UPDATE `zy_skill` SET `alias` = '物探|地震|电法|重力', `category_l1` = '理学', `category_l2` = '地质学', `difficulty` = 5, `description` = '用物探方法探测地下结构' WHERE `name` = '地球物理勘探' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '水文地质调查', '水文地质|地下水|勘察', '理学', '地质学', 4, '调查地下水资源与条件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '水文地质调查');
UPDATE `zy_skill` SET `alias` = '水文地质|地下水|勘察', `category_l1` = '理学', `category_l2` = '地质学', `difficulty` = 4, `description` = '调查地下水资源与条件' WHERE `name` = '水文地质调查' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '天气分析与预报', '天气分析|天气图|预报', '理学', '大气科学', 4, '分析天气图并做短期预报', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '天气分析与预报');
UPDATE `zy_skill` SET `alias` = '天气分析|天气图|预报', `category_l1` = '理学', `category_l2` = '大气科学', `difficulty` = 4, `description` = '分析天气图并做短期预报' WHERE `name` = '天气分析与预报' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数值天气预报', '数值预报|wrf|模式', '理学', '大气科学', 5, '运行与调试数值预报模式', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数值天气预报');
UPDATE `zy_skill` SET `alias` = '数值预报|wrf|模式', `category_l1` = '理学', `category_l2` = '大气科学', `difficulty` = 5, `description` = '运行与调试数值预报模式' WHERE `name` = '数值天气预报' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '气候统计与诊断', '气候统计|诊断|遥相关', '理学', '大气科学', 5, '分析气候变率与成因', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '气候统计与诊断');
UPDATE `zy_skill` SET `alias` = '气候统计|诊断|遥相关', `category_l1` = '理学', `category_l2` = '大气科学', `difficulty` = 5, `description` = '分析气候变率与成因' WHERE `name` = '气候统计与诊断' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '大气环境与污染扩散', '大气扩散|污染|模式', '理学', '大气科学', 4, '模拟污染物扩散过程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '大气环境与污染扩散');
UPDATE `zy_skill` SET `alias` = '大气扩散|污染|模式', `category_l1` = '理学', `category_l2` = '大气科学', `difficulty` = 4, `description` = '模拟污染物扩散过程' WHERE `name` = '大气环境与污染扩散' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'UI/UX 设计', '界面设计|交互设计|ui设计|用户体验', '艺术学', '设计学', 3, '界面视觉与用户体验设计，含原型与设计规范', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'UI/UX 设计');
UPDATE `zy_skill` SET `alias` = '界面设计|交互设计|ui设计|用户体验', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '界面视觉与用户体验设计，含原型与设计规范' WHERE `name` = 'UI/UX 设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Figma 界面设计与协作', 'figma|原型|组件库|设计交付', '艺术学', '设计学', 3, '用 Figma 完成界面设计与团队协作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Figma 界面设计与协作');
UPDATE `zy_skill` SET `alias` = 'figma|原型|组件库|设计交付', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '用 Figma 完成界面设计与团队协作' WHERE `name` = 'Figma 界面设计与协作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Sketch 与设计交付', 'sketch|标注|切图|设计规范', '艺术学', '设计学', 3, '完成设计稿标注与开发交付', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Sketch 与设计交付');
UPDATE `zy_skill` SET `alias` = 'sketch|标注|切图|设计规范', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '完成设计稿标注与开发交付' WHERE `name` = 'Sketch 与设计交付' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'PPT 与汇报表达', 'ppt|汇报|演示文稿|答辩', '艺术学', '设计学', 2, '演示文稿设计与口头汇报表达技巧', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'PPT 与汇报表达');
UPDATE `zy_skill` SET `alias` = 'ppt|汇报|演示文稿|答辩', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 2, `description` = '演示文稿设计与口头汇报表达技巧' WHERE `name` = 'PPT 与汇报表达' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '版式设计与排版', '版式|排版|网格|字体', '艺术学', '设计学', 3, '用网格与字体层级组织版面信息', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '版式设计与排版');
UPDATE `zy_skill` SET `alias` = '版式|排版|网格|字体', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '用网格与字体层级组织版面信息' WHERE `name` = '版式设计与排版' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '色彩理论与配色', '色彩|配色|色相|色彩心理', '艺术学', '设计学', 2, '运用色彩关系与心理完成配色方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '色彩理论与配色');
UPDATE `zy_skill` SET `alias` = '色彩|配色|色相|色彩心理', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 2, `description` = '运用色彩关系与心理完成配色方案' WHERE `name` = '色彩理论与配色' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '平面设计基础', '平面设计|海报|banner|视觉传达', '艺术学', '设计学', 3, '完成海报、主视觉等平面设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '平面设计基础');
UPDATE `zy_skill` SET `alias` = '平面设计|海报|banner|视觉传达', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '完成海报、主视觉等平面设计' WHERE `name` = '平面设计基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '品牌视觉与 VI 设计', '品牌|vi|logo|视觉识别', '艺术学', '设计学', 4, '构建品牌视觉识别系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '品牌视觉与 VI 设计');
UPDATE `zy_skill` SET `alias` = '品牌|vi|logo|视觉识别', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 4, `description` = '构建品牌视觉识别系统' WHERE `name` = '品牌视觉与 VI 设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '插画与手绘表达', '插画|手绘|数位板|procreate', '艺术学', '设计学', 3, '用手绘或数位板完成插画创作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '插画与手绘表达');
UPDATE `zy_skill` SET `alias` = '插画|手绘|数位板|procreate', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '用手绘或数位板完成插画创作' WHERE `name` = '插画与手绘表达' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '包装设计', '包装|结构|视觉|材质', '艺术学', '设计学', 4, '设计包装的视觉与结构方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '包装设计');
UPDATE `zy_skill` SET `alias` = '包装|结构|视觉|材质', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 4, `description` = '设计包装的视觉与结构方案' WHERE `name` = '包装设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '字体设计与选择', '字体设计|字形|字库', '艺术学', '设计学', 5, '设计或选用合适字体表达气质', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '字体设计与选择');
UPDATE `zy_skill` SET `alias` = '字体设计|字形|字库', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 5, `description` = '设计或选用合适字体表达气质' WHERE `name` = '字体设计与选择' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '信息图表设计', '信息图|infographic|数据可视化设计', '艺术学', '设计学', 3, '把复杂信息设计为易读图表', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '信息图表设计');
UPDATE `zy_skill` SET `alias` = '信息图|infographic|数据可视化设计', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '把复杂信息设计为易读图表' WHERE `name` = '信息图表设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '用户体验研究方法', '用户研究|访谈|可用性测试', '艺术学', '设计学', 4, '用访谈、问卷与可用性测试获取洞察', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '用户体验研究方法');
UPDATE `zy_skill` SET `alias` = '用户研究|访谈|可用性测试', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 4, `description` = '用访谈、问卷与可用性测试获取洞察' WHERE `name` = '用户体验研究方法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '动效设计规范', '动效|motion|转场|交互反馈', '艺术学', '设计学', 3, '为界面设计动效规范与节奏', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '动效设计规范');
UPDATE `zy_skill` SET `alias` = '动效|motion|转场|交互反馈', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '为界面设计动效规范与节奏' WHERE `name` = '动效设计规范' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '交互原型设计', '原型|低保真|高保真|axure', '艺术学', '设计学', 3, '设计可点击交互原型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '交互原型设计');
UPDATE `zy_skill` SET `alias` = '原型|低保真|高保真|axure', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '设计可点击交互原型' WHERE `name` = '交互原型设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '设计系统与组件库', '设计系统|组件库|design token', '艺术学', '设计学', 4, '建立可复用的设计系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '设计系统与组件库');
UPDATE `zy_skill` SET `alias` = '设计系统|组件库|design token', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 4, `description` = '建立可复用的设计系统' WHERE `name` = '设计系统与组件库' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '服务设计', '服务设计|旅程图|触点', '艺术学', '设计学', 5, '用服务设计方法优化完整体验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '服务设计');
UPDATE `zy_skill` SET `alias` = '服务设计|旅程图|触点', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 5, `description` = '用服务设计方法优化完整体验' WHERE `name` = '服务设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '无障碍与包容性设计', '无障碍|可访问性|wcag', '艺术学', '设计学', 4, '设计无障碍可用的界面', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '无障碍与包容性设计');
UPDATE `zy_skill` SET `alias` = '无障碍|可访问性|wcag', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 4, `description` = '设计无障碍可用的界面' WHERE `name` = '无障碍与包容性设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '设计调研与竞品分析', '设计调研|竞品|benchmark', '艺术学', '设计学', 3, '调研竞品并提炼设计机会', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '设计调研与竞品分析');
UPDATE `zy_skill` SET `alias` = '设计调研|竞品|benchmark', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '调研竞品并提炼设计机会' WHERE `name` = '设计调研与竞品分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '界面动效实现', 'lottie|动效实现|微交互', '艺术学', '设计学', 4, '把动效设计落地为可用实现', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '界面动效实现');
UPDATE `zy_skill` SET `alias` = 'lottie|动效实现|微交互', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 4, `description` = '把动效设计落地为可用实现' WHERE `name` = '界面动效实现' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '三维产品渲染', 'keyshot|产品渲染|c4d', '艺术学', '设计学', 4, '完成产品级三维渲染', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '三维产品渲染');
UPDATE `zy_skill` SET `alias` = 'keyshot|产品渲染|c4d', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 4, `description` = '完成产品级三维渲染' WHERE `name` = '三维产品渲染' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '虚拟展陈设计', '虚拟展陈|vr展厅|元宇宙展', '艺术学', '设计学', 5, '设计虚拟展览空间', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '虚拟展陈设计');
UPDATE `zy_skill` SET `alias` = '虚拟展陈|vr展厅|元宇宙展', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 5, `description` = '设计虚拟展览空间' WHERE `name` = '虚拟展陈设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '印刷工艺与落地', '印刷|工艺|出血|专色', '艺术学', '设计学', 3, '掌握印刷工艺与完稿规范', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '印刷工艺与落地');
UPDATE `zy_skill` SET `alias` = '印刷|工艺|出血|专色', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '掌握印刷工艺与完稿规范' WHERE `name` = '印刷工艺与落地' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '手绘草图与快速表达', '草图|快速表达|手绘', '艺术学', '设计学', 3, '用手绘快速表达设计构思', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '手绘草图与快速表达');
UPDATE `zy_skill` SET `alias` = '草图|快速表达|手绘', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '用手绘快速表达设计构思' WHERE `name` = '手绘草图与快速表达' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '设计管理与团队协作', '设计管理|协作|评审', '艺术学', '设计学', 3, '组织设计评审与团队协作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '设计管理与团队协作');
UPDATE `zy_skill` SET `alias` = '设计管理|协作|评审', `category_l1` = '艺术学', `category_l2` = '设计学', `difficulty` = 3, `description` = '组织设计评审与团队协作' WHERE `name` = '设计管理与团队协作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '视频剪辑', '剪辑|后期|premiere|pr|视频后期', '艺术学', '戏剧与影视学', 3, '视频素材剪辑、转场与调色等后期处理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '视频剪辑');
UPDATE `zy_skill` SET `alias` = '剪辑|后期|premiere|pr|视频后期', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 3, `description` = '视频素材剪辑、转场与调色等后期处理' WHERE `name` = '视频剪辑' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '视频调色与色彩管理', '调色|达芬奇|色轮|lut', '艺术学', '戏剧与影视学', 4, '用专业工具完成影视调色', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '视频调色与色彩管理');
UPDATE `zy_skill` SET `alias` = '调色|达芬奇|色轮|lut', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '用专业工具完成影视调色' WHERE `name` = '视频调色与色彩管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '短视频创作与运营', '短视频|抖音|b站|运营', '艺术学', '戏剧与影视学', 3, '策划、拍摄并运营短视频内容', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '短视频创作与运营');
UPDATE `zy_skill` SET `alias` = '短视频|抖音|b站|运营', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 3, `description` = '策划、拍摄并运营短视频内容' WHERE `name` = '短视频创作与运营' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '影视特效与合成', '特效|ae|after effects|合成', '艺术学', '戏剧与影视学', 4, '用合成软件制作特效与视觉合成', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '影视特效与合成');
UPDATE `zy_skill` SET `alias` = '特效|ae|after effects|合成', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '用合成软件制作特效与视觉合成' WHERE `name` = '影视特效与合成' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '三维动画与建模', '3d建模|maya|blender|动画', '艺术学', '戏剧与影视学', 5, '完成三维建模、材质与动画', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '三维动画与建模');
UPDATE `zy_skill` SET `alias` = '3d建模|maya|blender|动画', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 5, `description` = '完成三维建模、材质与动画' WHERE `name` = '三维动画与建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '剧本创作与分镜', '剧本|分镜|storyboard|叙事', '艺术学', '戏剧与影视学', 3, '编写剧本并绘制分镜脚本', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '剧本创作与分镜');
UPDATE `zy_skill` SET `alias` = '剧本|分镜|storyboard|叙事', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 3, `description` = '编写剧本并绘制分镜脚本' WHERE `name` = '剧本创作与分镜' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '摄影摄像基础', '摄影|摄像|构图|运镜', '艺术学', '戏剧与影视学', 2, '掌握构图、曝光与运镜基本技巧', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '摄影摄像基础');
UPDATE `zy_skill` SET `alias` = '摄影|摄像|构图|运镜', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 2, `description` = '掌握构图、曝光与运镜基本技巧' WHERE `name` = '摄影摄像基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '纪录片拍摄与采访', '纪录片|采访|纪实|拍摄', '艺术学', '戏剧与影视学', 4, '完成纪实拍摄与采访组织', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '纪录片拍摄与采访');
UPDATE `zy_skill` SET `alias` = '纪录片|采访|纪实|拍摄', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '完成纪实拍摄与采访组织' WHERE `name` = '纪录片拍摄与采访' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '音频后期与配乐', '音频后期|配乐|au|混音', '艺术学', '戏剧与影视学', 3, '完成音频降噪、混音与配乐', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '音频后期与配乐');
UPDATE `zy_skill` SET `alias` = '音频后期|配乐|au|混音', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 3, `description` = '完成音频降噪、混音与配乐' WHERE `name` = '音频后期与配乐' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '直播技术导播', '直播|导播|obs|推流', '艺术学', '戏剧与影视学', 3, '搭建直播推流与多机位导播', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '直播技术导播');
UPDATE `zy_skill` SET `alias` = '直播|导播|obs|推流', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 3, `description` = '搭建直播推流与多机位导播' WHERE `name` = '直播技术导播' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '影视录音与同期声', '同期声|录音|话筒', '艺术学', '戏剧与影视学', 4, '完成现场录音与声音采集', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '影视录音与同期声');
UPDATE `zy_skill` SET `alias` = '同期声|录音|话筒', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '完成现场录音与声音采集' WHERE `name` = '影视录音与同期声' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '栏目包装与片头设计', '片头|栏目包装|mg动画', '艺术学', '戏剧与影视学', 4, '设计节目片头与包装', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '栏目包装与片头设计');
UPDATE `zy_skill` SET `alias` = '片头|栏目包装|mg动画', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '设计节目片头与包装' WHERE `name` = '栏目包装与片头设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '舞台灯光设计', '舞台灯光|灯位|光比', '艺术学', '戏剧与影视学', 4, '设计舞台灯光方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '舞台灯光设计');
UPDATE `zy_skill` SET `alias` = '舞台灯光|灯位|光比', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '设计舞台灯光方案' WHERE `name` = '舞台灯光设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '影视制片与统筹', '制片|统筹|预算', '艺术学', '戏剧与影视学', 4, '统筹拍摄进度与资源', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '影视制片与统筹');
UPDATE `zy_skill` SET `alias` = '制片|统筹|预算', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '统筹拍摄进度与资源' WHERE `name` = '影视制片与统筹' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '短视频选题策划', '选题|策划|脚本', '艺术学', '戏剧与影视学', 3, '策划有传播力的选题与脚本', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '短视频选题策划');
UPDATE `zy_skill` SET `alias` = '选题|策划|脚本', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 3, `description` = '策划有传播力的选题与脚本' WHERE `name` = '短视频选题策划' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '影视剪辑节奏把控', '剪辑节奏|蒙太奇|叙事节奏', '艺术学', '戏剧与影视学', 4, '通过剪辑节奏控制叙事', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '影视剪辑节奏把控');
UPDATE `zy_skill` SET `alias` = '剪辑节奏|蒙太奇|叙事节奏', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '通过剪辑节奏控制叙事' WHERE `name` = '影视剪辑节奏把控' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '虚拟演播与绿幕抠像', '绿幕|抠像|虚拟演播', '艺术学', '戏剧与影视学', 4, '完成绿幕拍摄与合成', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '虚拟演播与绿幕抠像');
UPDATE `zy_skill` SET `alias` = '绿幕|抠像|虚拟演播', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '完成绿幕拍摄与合成' WHERE `name` = '虚拟演播与绿幕抠像' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '动画分镜与节奏', '动画分镜|layout|节奏', '艺术学', '戏剧与影视学', 4, '绘制动画分镜并控制节奏', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '动画分镜与节奏');
UPDATE `zy_skill` SET `alias` = '动画分镜|layout|节奏', `category_l1` = '艺术学', `category_l2` = '戏剧与影视学', `difficulty` = 4, `description` = '绘制动画分镜并控制节奏' WHERE `name` = '动画分镜与节奏' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '摄影构图与后期', '摄影|构图|修图|lightroom', '艺术学', '美术学', 3, '完成拍摄构图与照片后期修图', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '摄影构图与后期');
UPDATE `zy_skill` SET `alias` = '摄影|构图|修图|lightroom', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 3, `description` = '完成拍摄构图与照片后期修图' WHERE `name` = '摄影构图与后期' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '商业摄影布光', '商业摄影|布光|棚拍|产品摄影', '艺术学', '美术学', 4, '用灯位组合完成商业产品拍摄', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '商业摄影布光');
UPDATE `zy_skill` SET `alias` = '商业摄影|布光|棚拍|产品摄影', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 4, `description` = '用灯位组合完成商业产品拍摄' WHERE `name` = '商业摄影布光' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '油画与水彩创作', '油画|水彩|写生|创作', '艺术学', '美术学', 4, '完成架上绘画创作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '油画与水彩创作');
UPDATE `zy_skill` SET `alias` = '油画|水彩|写生|创作', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 4, `description` = '完成架上绘画创作' WHERE `name` = '油画与水彩创作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '书法与篆刻', '书法|篆刻|临帖|硬笔', '艺术学', '美术学', 3, '掌握书体临写与篆刻基本技法', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '书法与篆刻');
UPDATE `zy_skill` SET `alias` = '书法|篆刻|临帖|硬笔', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 3, `description` = '掌握书体临写与篆刻基本技法' WHERE `name` = '书法与篆刻' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '国画与水墨', '国画|水墨|工笔|写意', '艺术学', '美术学', 4, '完成国画工笔或写意创作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '国画与水墨');
UPDATE `zy_skill` SET `alias` = '国画|水墨|工笔|写意', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 4, `description` = '完成国画工笔或写意创作' WHERE `name` = '国画与水墨' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '雕塑与立体造型', '雕塑|立体|泥塑|造型', '艺术学', '美术学', 4, '完成立体造型与雕塑制作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '雕塑与立体造型');
UPDATE `zy_skill` SET `alias` = '雕塑|立体|泥塑|造型', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 4, `description` = '完成立体造型与雕塑制作' WHERE `name` = '雕塑与立体造型' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '美术史与作品鉴赏', '美术史|鉴赏|艺术流派', '艺术学', '美术学', 3, '梳理美术史脉络并鉴赏作品', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '美术史与作品鉴赏');
UPDATE `zy_skill` SET `alias` = '美术史|鉴赏|艺术流派', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 3, `description` = '梳理美术史脉络并鉴赏作品' WHERE `name` = '美术史与作品鉴赏' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '策展与展览布置', '策展|布展|展陈|空间', '艺术学', '美术学', 4, '策划展览并完成空间陈列', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '策展与展览布置');
UPDATE `zy_skill` SET `alias` = '策展|布展|展陈|空间', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 4, `description` = '策划展览并完成空间陈列' WHERE `name` = '策展与展览布置' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '水彩写生', '水彩|写生|湿画法', '艺术学', '美术学', 3, '完成水彩写生作品', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '水彩写生');
UPDATE `zy_skill` SET `alias` = '水彩|写生|湿画法', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 3, `description` = '完成水彩写生作品' WHERE `name` = '水彩写生' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '素描造型基础', '素描|造型|结构|明暗', '艺术学', '美术学', 2, '掌握素描造型与明暗表现', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '素描造型基础');
UPDATE `zy_skill` SET `alias` = '素描|造型|结构|明暗', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 2, `description` = '掌握素描造型与明暗表现' WHERE `name` = '素描造型基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '色彩写生与表现', '色彩写生|色彩表现|色调', '艺术学', '美术学', 3, '用色彩完成写生表现', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '色彩写生与表现');
UPDATE `zy_skill` SET `alias` = '色彩写生|色彩表现|色调', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 3, `description` = '用色彩完成写生表现' WHERE `name` = '色彩写生与表现' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '艺术策展文本撰写', '策展文本|前言|展签', '艺术学', '美术学', 4, '撰写展览前言与作品说明', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '艺术策展文本撰写');
UPDATE `zy_skill` SET `alias` = '策展文本|前言|展签', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 4, `description` = '撰写展览前言与作品说明' WHERE `name` = '艺术策展文本撰写' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '版画与丝网印刷', '版画|丝网|套色', '艺术学', '美术学', 4, '完成版画或丝网印刷作品', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '版画与丝网印刷');
UPDATE `zy_skill` SET `alias` = '版画|丝网|套色', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 4, `description` = '完成版画或丝网印刷作品' WHERE `name` = '版画与丝网印刷' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数字绘画与概念设计', '数字绘画|概念设计|角色设计', '艺术学', '美术学', 4, '完成概念设定与数字绘画', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数字绘画与概念设计');
UPDATE `zy_skill` SET `alias` = '数字绘画|概念设计|角色设计', `category_l1` = '艺术学', `category_l2` = '美术学', `difficulty` = 4, `description` = '完成概念设定与数字绘画' WHERE `name` = '数字绘画与概念设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '乐器演奏', '乐器|钢琴|吉他|演奏', '艺术学', '音乐与舞蹈学', 3, '演奏一门乐器并完成曲目排练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '乐器演奏');
UPDATE `zy_skill` SET `alias` = '乐器|钢琴|吉他|演奏', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 3, `description` = '演奏一门乐器并完成曲目排练' WHERE `name` = '乐器演奏' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '声乐与演唱技巧', '声乐|唱歌|发声|气息', '艺术学', '音乐与舞蹈学', 3, '掌握发声、气息与演唱处理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '声乐与演唱技巧');
UPDATE `zy_skill` SET `alias` = '声乐|唱歌|发声|气息', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 3, `description` = '掌握发声、气息与演唱处理' WHERE `name` = '声乐与演唱技巧' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '编曲与音乐制作', '编曲|logic|fl studio|音乐制作', '艺术学', '音乐与舞蹈学', 4, '完成编曲、音色设计与成品制作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '编曲与音乐制作');
UPDATE `zy_skill` SET `alias` = '编曲|logic|fl studio|音乐制作', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 4, `description` = '完成编曲、音色设计与成品制作' WHERE `name` = '编曲与音乐制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '乐理与视唱练耳', '乐理|视唱|练耳|和声', '艺术学', '音乐与舞蹈学', 3, '掌握音程和弦与视唱听辨', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '乐理与视唱练耳');
UPDATE `zy_skill` SET `alias` = '乐理|视唱|练耳|和声', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 3, `description` = '掌握音程和弦与视唱听辨' WHERE `name` = '乐理与视唱练耳' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '舞蹈编创与排练', '舞蹈|编创|排练|形体', '艺术学', '音乐与舞蹈学', 3, '编排舞蹈作品并组织排练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '舞蹈编创与排练');
UPDATE `zy_skill` SET `alias` = '舞蹈|编创|排练|形体', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 3, `description` = '编排舞蹈作品并组织排练' WHERE `name` = '舞蹈编创与排练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '舞台表演与形体', '表演|形体|台词|舞台', '艺术学', '音乐与舞蹈学', 3, '完成舞台表演与形体训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '舞台表演与形体');
UPDATE `zy_skill` SET `alias` = '表演|形体|台词|舞台', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 3, `description` = '完成舞台表演与形体训练' WHERE `name` = '舞台表演与形体' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '合唱指挥与排练', '合唱|指挥|排练', '艺术学', '音乐与舞蹈学', 4, '组织合唱排练与指挥', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '合唱指挥与排练');
UPDATE `zy_skill` SET `alias` = '合唱|指挥|排练', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 4, `description` = '组织合唱排练与指挥' WHERE `name` = '合唱指挥与排练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '流行音乐编配', '流行编配|和声|配器', '艺术学', '音乐与舞蹈学', 4, '为流行歌曲编配和声与配器', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '流行音乐编配');
UPDATE `zy_skill` SET `alias` = '流行编配|和声|配器', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 4, `description` = '为流行歌曲编配和声与配器' WHERE `name` = '流行音乐编配' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '音乐录音与混音', '录音|混音|声卡|插件', '艺术学', '音乐与舞蹈学', 4, '完成音乐录音与混音', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '音乐录音与混音');
UPDATE `zy_skill` SET `alias` = '录音|混音|声卡|插件', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 4, `description` = '完成音乐录音与混音' WHERE `name` = '音乐录音与混音' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '舞蹈基础训练', '舞蹈基础|基本功|形体', '艺术学', '音乐与舞蹈学', 2, '完成舞蹈基本功训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '舞蹈基础训练');
UPDATE `zy_skill` SET `alias` = '舞蹈基础|基本功|形体', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 2, `description` = '完成舞蹈基本功训练' WHERE `name` = '舞蹈基础训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '舞台化妆与造型', '舞台化妆|造型|特效妆', '艺术学', '音乐与舞蹈学', 3, '完成舞台化妆与造型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '舞台化妆与造型');
UPDATE `zy_skill` SET `alias` = '舞台化妆|造型|特效妆', `category_l1` = '艺术学', `category_l2` = '音乐与舞蹈学', `difficulty` = 3, `description` = '完成舞台化妆与造型' WHERE `name` = '舞台化妆与造型' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Photoshop 图像处理', 'ps|photoshop|抠图|修图', '艺术学', '数字创作工具', 3, '用 PS 完成图像处理与合成', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Photoshop 图像处理');
UPDATE `zy_skill` SET `alias` = 'ps|photoshop|抠图|修图', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 3, `description` = '用 PS 完成图像处理与合成' WHERE `name` = 'Photoshop 图像处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Illustrator 矢量绘图', 'ai|illustrator|矢量|logo', '艺术学', '数字创作工具', 3, '用 AI 绘制矢量图形与标志', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Illustrator 矢量绘图');
UPDATE `zy_skill` SET `alias` = 'ai|illustrator|矢量|logo', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 3, `description` = '用 AI 绘制矢量图形与标志' WHERE `name` = 'Illustrator 矢量绘图' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'InDesign 排版设计', 'indesign|id|排版|画册', '艺术学', '数字创作工具', 4, '用 InDesign 完成画册与排版', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'InDesign 排版设计');
UPDATE `zy_skill` SET `alias` = 'indesign|id|排版|画册', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 4, `description` = '用 InDesign 完成画册与排版' WHERE `name` = 'InDesign 排版设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Premiere 视频剪辑', 'pr|premiere|剪辑', '艺术学', '数字创作工具', 3, '用 Premiere 完成视频剪辑', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Premiere 视频剪辑');
UPDATE `zy_skill` SET `alias` = 'pr|premiere|剪辑', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 3, `description` = '用 Premiere 完成视频剪辑' WHERE `name` = 'Premiere 视频剪辑' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'After Effects 动效制作', 'ae|aftereffects|动效|特效', '艺术学', '数字创作工具', 4, '用 AE 制作动效与特效', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'After Effects 动效制作');
UPDATE `zy_skill` SET `alias` = 'ae|aftereffects|动效|特效', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 4, `description` = '用 AE 制作动效与特效' WHERE `name` = 'After Effects 动效制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '剪映快速剪辑', '剪映|手机剪辑|字幕', '艺术学', '数字创作工具', 2, '用剪映快速完成短视频剪辑', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '剪映快速剪辑');
UPDATE `zy_skill` SET `alias` = '剪映|手机剪辑|字幕', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 2, `description` = '用剪映快速完成短视频剪辑' WHERE `name` = '剪映快速剪辑' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '达芬奇调色', '达芬奇|davinci|调色', '艺术学', '数字创作工具', 4, '用达芬奇完成专业调色', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '达芬奇调色');
UPDATE `zy_skill` SET `alias` = '达芬奇|davinci|调色', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 4, `description` = '用达芬奇完成专业调色' WHERE `name` = '达芬奇调色' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Blender 三维创作', 'blender|三维|建模|渲染', '艺术学', '数字创作工具', 4, '用 Blender 完成建模渲染动画', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Blender 三维创作');
UPDATE `zy_skill` SET `alias` = 'blender|三维|建模|渲染', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 4, `description` = '用 Blender 完成建模渲染动画' WHERE `name` = 'Blender 三维创作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'C4D 三维动效', 'c4d|cinema4d|三维动效', '艺术学', '数字创作工具', 5, '用 C4D 制作三维动效', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'C4D 三维动效');
UPDATE `zy_skill` SET `alias` = 'c4d|cinema4d|三维动效', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 5, `description` = '用 C4D 制作三维动效' WHERE `name` = 'C4D 三维动效' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Figma 界面设计', 'figma|组件|原型|协作', '艺术学', '数字创作工具', 3, '用 Figma 完成界面设计与协作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Figma 界面设计');
UPDATE `zy_skill` SET `alias` = 'figma|组件|原型|协作', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 3, `description` = '用 Figma 完成界面设计与协作' WHERE `name` = 'Figma 界面设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Canva 快速设计', 'canva|模板|海报|社交媒体', '艺术学', '数字创作工具', 1, '用模板快速产出设计物料', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Canva 快速设计');
UPDATE `zy_skill` SET `alias` = 'canva|模板|海报|社交媒体', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 1, `description` = '用模板快速产出设计物料' WHERE `name` = 'Canva 快速设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Procreate 数字绘画', 'procreate|ipad绘画|笔刷', '艺术学', '数字创作工具', 3, '用 Procreate 完成数字绘画', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Procreate 数字绘画');
UPDATE `zy_skill` SET `alias` = 'procreate|ipad绘画|笔刷', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 3, `description` = '用 Procreate 完成数字绘画' WHERE `name` = 'Procreate 数字绘画' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'SketchUp 快速建模', 'sketchup|su|快速建模', '艺术学', '数字创作工具', 3, '用 SketchUp 快速建立空间模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'SketchUp 快速建模');
UPDATE `zy_skill` SET `alias` = 'sketchup|su|快速建模', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 3, `description` = '用 SketchUp 快速建立空间模型' WHERE `name` = 'SketchUp 快速建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Lumion 建筑渲染', 'lumion|建筑渲染|动画', '艺术学', '数字创作工具', 4, '用 Lumion 完成建筑渲染与漫游', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Lumion 建筑渲染');
UPDATE `zy_skill` SET `alias` = 'lumion|建筑渲染|动画', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 4, `description` = '用 Lumion 完成建筑渲染与漫游' WHERE `name` = 'Lumion 建筑渲染' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '音频处理 Audition', 'au|audition|降噪|音频剪辑', '艺术学', '数字创作工具', 3, '用 Audition 处理音频', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '音频处理 Audition');
UPDATE `zy_skill` SET `alias` = 'au|audition|降噪|音频剪辑', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 3, `description` = '用 Audition 处理音频' WHERE `name` = '音频处理 Audition' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'FL Studio 编曲', 'flstudio|编曲|beat', '艺术学', '数字创作工具', 4, '用 FL Studio 完成编曲', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'FL Studio 编曲');
UPDATE `zy_skill` SET `alias` = 'flstudio|编曲|beat', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 4, `description` = '用 FL Studio 完成编曲' WHERE `name` = 'FL Studio 编曲' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Logic Pro 音乐制作', 'logic|音乐制作|混音', '艺术学', '数字创作工具', 5, '用 Logic Pro 完成音乐制作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Logic Pro 音乐制作');
UPDATE `zy_skill` SET `alias` = 'logic|音乐制作|混音', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 5, `description` = '用 Logic Pro 完成音乐制作' WHERE `name` = 'Logic Pro 音乐制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'OBS 直播推流', 'obs|推流|直播|录屏', '艺术学', '数字创作工具', 3, '用 OBS 完成直播与录屏', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'OBS 直播推流');
UPDATE `zy_skill` SET `alias` = 'obs|推流|直播|录屏', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 3, `description` = '用 OBS 完成直播与录屏' WHERE `name` = 'OBS 直播推流' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '二维码与物料制作', '二维码|物料|印刷文件', '艺术学', '数字创作工具', 2, '制作可印刷的宣传物料', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '二维码与物料制作');
UPDATE `zy_skill` SET `alias` = '二维码|物料|印刷文件', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 2, `description` = '制作可印刷的宣传物料' WHERE `name` = '二维码与物料制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '色彩管理与屏幕校准', '色彩管理|icc|校准|印刷色差', '艺术学', '数字创作工具', 4, '处理跨设备的色彩一致性问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '色彩管理与屏幕校准');
UPDATE `zy_skill` SET `alias` = '色彩管理|icc|校准|印刷色差', `category_l1` = '艺术学', `category_l2` = '数字创作工具', `difficulty` = 4, `description` = '处理跨设备的色彩一致性问题' WHERE `name` = '色彩管理与屏幕校准' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '学术论文写作', '论文写作|论文|期刊投稿|文献综述', '文学', '中国语言文学', 3, '学术论文结构组织、文献综述与规范表达', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '学术论文写作');
UPDATE `zy_skill` SET `alias` = '论文写作|论文|期刊投稿|文献综述', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 3, `description` = '学术论文结构组织、文献综述与规范表达' WHERE `name` = '学术论文写作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '毕业论文选题与开题', '毕业论文|开题|选题|研究设计', '文学', '中国语言文学', 3, '完成选题论证与开题报告', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '毕业论文选题与开题');
UPDATE `zy_skill` SET `alias` = '毕业论文|开题|选题|研究设计', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 3, `description` = '完成选题论证与开题报告' WHERE `name` = '毕业论文选题与开题' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '公文与实用写作', '公文|应用文|通知|报告', '文学', '中国语言文学', 2, '撰写规范的通知、报告与总结', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '公文与实用写作');
UPDATE `zy_skill` SET `alias` = '公文|应用文|通知|报告', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 2, `description` = '撰写规范的通知、报告与总结' WHERE `name` = '公文与实用写作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '新媒体文案写作', '文案|新媒体|公众号|标题', '文学', '中国语言文学', 3, '为新媒体平台撰写有传播力的文案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '新媒体文案写作');
UPDATE `zy_skill` SET `alias` = '文案|新媒体|公众号|标题', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 3, `description` = '为新媒体平台撰写有传播力的文案' WHERE `name` = '新媒体文案写作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '创意写作与小说', '创意写作|小说|散文|叙事', '文学', '中国语言文学', 4, '完成短篇或长篇的文学创作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '创意写作与小说');
UPDATE `zy_skill` SET `alias` = '创意写作|小说|散文|叙事', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 4, `description` = '完成短篇或长篇的文学创作' WHERE `name` = '创意写作与小说' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '文学评论与文本细读', '文学评论|细读|批评|文本分析', '文学', '中国语言文学', 4, '对文本做细致的批评性解读', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '文学评论与文本细读');
UPDATE `zy_skill` SET `alias` = '文学评论|细读|批评|文本分析', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 4, `description` = '对文本做细致的批评性解读' WHERE `name` = '文学评论与文本细读' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '古汉语与文献阅读', '古汉语|文言文|文献|训诂', '文学', '中国语言文学', 4, '阅读并解读古代文献', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '古汉语与文献阅读');
UPDATE `zy_skill` SET `alias` = '古汉语|文言文|文献|训诂', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 4, `description` = '阅读并解读古代文献' WHERE `name` = '古汉语与文献阅读' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '编辑校对与出版规范', '编辑|校对|出版|标点规范', '文学', '中国语言文学', 3, '按出版规范完成编校工作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '编辑校对与出版规范');
UPDATE `zy_skill` SET `alias` = '编辑|校对|出版|标点规范', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 3, `description` = '按出版规范完成编校工作' WHERE `name` = '编辑校对与出版规范' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '诗词创作与鉴赏', '诗词|格律|鉴赏|古体诗', '文学', '中国语言文学', 4, '创作并鉴赏古典诗词', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '诗词创作与鉴赏');
UPDATE `zy_skill` SET `alias` = '诗词|格律|鉴赏|古体诗', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 4, `description` = '创作并鉴赏古典诗词' WHERE `name` = '诗词创作与鉴赏' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '影视文学改编', '影视改编|剧本|原著', '文学', '中国语言文学', 4, '把文学作品改编为影视剧本', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '影视文学改编');
UPDATE `zy_skill` SET `alias` = '影视改编|剧本|原著', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 4, `description` = '把文学作品改编为影视剧本' WHERE `name` = '影视文学改编' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '广告文案与创意', '广告文案|创意|slogan', '文学', '中国语言文学', 3, '撰写广告文案与创意概念', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '广告文案与创意');
UPDATE `zy_skill` SET `alias` = '广告文案|创意|slogan', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 3, `description` = '撰写广告文案与创意概念' WHERE `name` = '广告文案与创意' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '演讲稿撰写', '演讲稿|演讲|口才', '文学', '中国语言文学', 3, '撰写有感染力的演讲稿', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '演讲稿撰写');
UPDATE `zy_skill` SET `alias` = '演讲稿|演讲|口才', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 3, `description` = '撰写有感染力的演讲稿' WHERE `name` = '演讲稿撰写' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '汉语语法与修辞', '语法|修辞|病句|语言规范', '文学', '中国语言文学', 3, '掌握现代汉语语法与修辞', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '汉语语法与修辞');
UPDATE `zy_skill` SET `alias` = '语法|修辞|病句|语言规范', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 3, `description` = '掌握现代汉语语法与修辞' WHERE `name` = '汉语语法与修辞' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '方言与文化研究', '方言|语言调查|文化', '文学', '中国语言文学', 4, '调查方言并做语言文化分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '方言与文化研究');
UPDATE `zy_skill` SET `alias` = '方言|语言调查|文化', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 4, `description` = '调查方言并做语言文化分析' WHERE `name` = '方言与文化研究' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '绘本与儿童文学创作', '绘本|儿童文学|童话', '文学', '中国语言文学', 3, '创作绘本或儿童文学作品', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '绘本与儿童文学创作');
UPDATE `zy_skill` SET `alias` = '绘本|儿童文学|童话', `category_l1` = '文学', `category_l2` = '中国语言文学', `difficulty` = 3, `description` = '创作绘本或儿童文学作品' WHERE `name` = '绘本与儿童文学创作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '英语口语陪练', '口语|英语口语|speaking|英语对话', '文学', '外国语言文学', 2, '日常与学术场景的英语口语对话练习', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '英语口语陪练');
UPDATE `zy_skill` SET `alias` = '口语|英语口语|speaking|英语对话', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 2, `description` = '日常与学术场景的英语口语对话练习' WHERE `name` = '英语口语陪练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '英语写作与润色', '英语写作|writing|润色|学术英语', '文学', '外国语言文学', 3, '撰写并润色英文文章', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '英语写作与润色');
UPDATE `zy_skill` SET `alias` = '英语写作|writing|润色|学术英语', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '撰写并润色英文文章' WHERE `name` = '英语写作与润色' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '英汉互译', '翻译|笔译|英译汉|汉译英', '文学', '外国语言文学', 4, '完成准确的英汉互译', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '英汉互译');
UPDATE `zy_skill` SET `alias` = '翻译|笔译|英译汉|汉译英', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 4, `description` = '完成准确的英汉互译' WHERE `name` = '英汉互译' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '口译与交替传译', '口译|交传|同传|会议翻译', '文学', '外国语言文学', 5, '在会议场景完成交替传译', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '口译与交替传译');
UPDATE `zy_skill` SET `alias` = '口译|交传|同传|会议翻译', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 5, `description` = '在会议场景完成交替传译' WHERE `name` = '口译与交替传译' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '雅思托福备考', '雅思|托福|ielts|toefl', '文学', '外国语言文学', 3, '系统备考并提升语言考试成绩', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '雅思托福备考');
UPDATE `zy_skill` SET `alias` = '雅思|托福|ielts|toefl', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '系统备考并提升语言考试成绩' WHERE `name` = '雅思托福备考' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '日语基础与会话', '日语|jlpt|五十音|会话', '文学', '外国语言文学', 3, '掌握日语基础语法与日常会话', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '日语基础与会话');
UPDATE `zy_skill` SET `alias` = '日语|jlpt|五十音|会话', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '掌握日语基础语法与日常会话' WHERE `name` = '日语基础与会话' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '德语基础与会话', '德语|daf|德语会话', '文学', '外国语言文学', 3, '掌握德语基础语法与日常会话', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '德语基础与会话');
UPDATE `zy_skill` SET `alias` = '德语|daf|德语会话', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '掌握德语基础语法与日常会话' WHERE `name` = '德语基础与会话' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '法语基础与会话', '法语|tcf|法语会话', '文学', '外国语言文学', 3, '掌握法语基础语法与日常会话', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '法语基础与会话');
UPDATE `zy_skill` SET `alias` = '法语|tcf|法语会话', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '掌握法语基础语法与日常会话' WHERE `name` = '法语基础与会话' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '英文文献阅读', '文献阅读|paper|英文文献', '文学', '外国语言文学', 3, '快速阅读并提炼英文文献要点', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '英文文献阅读');
UPDATE `zy_skill` SET `alias` = '文献阅读|paper|英文文献', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '快速阅读并提炼英文文献要点' WHERE `name` = '英文文献阅读' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '韩语基础与会话', '韩语|topik|韩语会话', '文学', '外国语言文学', 3, '掌握韩语基础语法与日常会话', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '韩语基础与会话');
UPDATE `zy_skill` SET `alias` = '韩语|topik|韩语会话', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '掌握韩语基础语法与日常会话' WHERE `name` = '韩语基础与会话' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '俄语基础与会话', '俄语|俄语会话', '文学', '外国语言文学', 3, '掌握俄语基础语法与日常会话', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '俄语基础与会话');
UPDATE `zy_skill` SET `alias` = '俄语|俄语会话', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '掌握俄语基础语法与日常会话' WHERE `name` = '俄语基础与会话' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '西班牙语基础', '西语|西班牙语|dele', '文学', '外国语言文学', 3, '掌握西语基础语法与会话', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '西班牙语基础');
UPDATE `zy_skill` SET `alias` = '西语|西班牙语|dele', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '掌握西语基础语法与会话' WHERE `name` = '西班牙语基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '学术英语写作', '学术英语|论文英语|abstract', '文学', '外国语言文学', 4, '用规范学术英语撰写论文', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '学术英语写作');
UPDATE `zy_skill` SET `alias` = '学术英语|论文英语|abstract', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 4, `description` = '用规范学术英语撰写论文' WHERE `name` = '学术英语写作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '跨文化交际', '跨文化|文化差异|交际', '文学', '外国语言文学', 3, '理解并处理跨文化交际差异', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '跨文化交际');
UPDATE `zy_skill` SET `alias` = '跨文化|文化差异|交际', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '理解并处理跨文化交际差异' WHERE `name` = '跨文化交际' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '字幕翻译与本地化', '字幕翻译|本地化|时间轴', '文学', '外国语言文学', 4, '完成影视字幕翻译与压制', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '字幕翻译与本地化');
UPDATE `zy_skill` SET `alias` = '字幕翻译|本地化|时间轴', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 4, `description` = '完成影视字幕翻译与压制' WHERE `name` = '字幕翻译与本地化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '商务英语函电', '商务英语|函电|外贸英语', '文学', '外国语言文学', 3, '撰写商务英语邮件与函电', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '商务英语函电');
UPDATE `zy_skill` SET `alias` = '商务英语|函电|外贸英语', `category_l1` = '文学', `category_l2` = '外国语言文学', `difficulty` = 3, `description` = '撰写商务英语邮件与函电' WHERE `name` = '商务英语函电' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '新闻采访与写作', '采访|新闻写作|消息|通讯', '文学', '新闻传播学', 3, '完成采访组织与新闻稿写作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '新闻采访与写作');
UPDATE `zy_skill` SET `alias` = '采访|新闻写作|消息|通讯', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 3, `description` = '完成采访组织与新闻稿写作' WHERE `name` = '新闻采访与写作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '视频号与新媒体运营', '新媒体运营|涨粉|选题|社群', '文学', '新闻传播学', 3, '策划内容并运营账号增长', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '视频号与新媒体运营');
UPDATE `zy_skill` SET `alias` = '新媒体运营|涨粉|选题|社群', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 3, `description` = '策划内容并运营账号增长' WHERE `name` = '视频号与新媒体运营' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '舆情分析与监测', '舆情|监测|分析报告', '文学', '新闻传播学', 4, '监测舆情并撰写分析报告', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '舆情分析与监测');
UPDATE `zy_skill` SET `alias` = '舆情|监测|分析报告', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 4, `description` = '监测舆情并撰写分析报告' WHERE `name` = '舆情分析与监测' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '广告创意与策划', '广告|创意|策划案|slogan', '文学', '新闻传播学', 3, '产出广告创意与整合传播方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '广告创意与策划');
UPDATE `zy_skill` SET `alias` = '广告|创意|策划案|slogan', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 3, `description` = '产出广告创意与整合传播方案' WHERE `name` = '广告创意与策划' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '公共关系与危机应对', '公关|危机公关|声明|沟通', '文学', '新闻传播学', 4, '处理公关事件与对外沟通', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '公共关系与危机应对');
UPDATE `zy_skill` SET `alias` = '公关|危机公关|声明|沟通', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 4, `description` = '处理公关事件与对外沟通' WHERE `name` = '公共关系与危机应对' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据新闻与可视化', '数据新闻|可视化|图表叙事', '文学', '新闻传播学', 4, '用数据与图表完成新闻叙事', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据新闻与可视化');
UPDATE `zy_skill` SET `alias` = '数据新闻|可视化|图表叙事', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 4, `description` = '用数据与图表完成新闻叙事' WHERE `name` = '数据新闻与可视化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '播音主持与配音', '播音|主持|配音|普通话', '文学', '新闻传播学', 3, '完成播音主持与配音工作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '播音主持与配音');
UPDATE `zy_skill` SET `alias` = '播音|主持|配音|普通话', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 3, `description` = '完成播音主持与配音工作' WHERE `name` = '播音主持与配音' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '新闻摄影与图片编辑', '新闻摄影|图片编辑|图说', '文学', '新闻传播学', 3, '完成新闻摄影与图片编辑', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '新闻摄影与图片编辑');
UPDATE `zy_skill` SET `alias` = '新闻摄影|图片编辑|图说', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 3, `description` = '完成新闻摄影与图片编辑' WHERE `name` = '新闻摄影与图片编辑' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '媒体融合与全媒体运营', '媒体融合|全媒体|矩阵运营', '文学', '新闻传播学', 4, '运营全媒体内容矩阵', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '媒体融合与全媒体运营');
UPDATE `zy_skill` SET `alias` = '媒体融合|全媒体|矩阵运营', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 4, `description` = '运营全媒体内容矩阵' WHERE `name` = '媒体融合与全媒体运营' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '深度报道与调查', '深度报道|调查报道|暗访', '文学', '新闻传播学', 5, '完成深度调查报道', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '深度报道与调查');
UPDATE `zy_skill` SET `alias` = '深度报道|调查报道|暗访', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 5, `description` = '完成深度调查报道' WHERE `name` = '深度报道与调查' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '传播学理论与研究方法', '传播学|内容分析|框架理论', '文学', '新闻传播学', 4, '用传播学方法研究问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '传播学理论与研究方法');
UPDATE `zy_skill` SET `alias` = '传播学|内容分析|框架理论', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 4, `description` = '用传播学方法研究问题' WHERE `name` = '传播学理论与研究方法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '视觉传达与版式编辑', '版式编辑|报纸排版|indesign', '文学', '新闻传播学', 3, '完成版面编辑与排版', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '视觉传达与版式编辑');
UPDATE `zy_skill` SET `alias` = '版式编辑|报纸排版|indesign', `category_l1` = '文学', `category_l2` = '新闻传播学', `difficulty` = 3, `description` = '完成版面编辑与排版' WHERE `name` = '视觉传达与版式编辑' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Grammarly 英文校对', 'grammarly|英文校对|语法检查', '文学', '语言与写作工具', 2, '用工具检查英文语法与表达', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Grammarly 英文校对');
UPDATE `zy_skill` SET `alias` = 'grammarly|英文校对|语法检查', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 2, `description` = '用工具检查英文语法与表达' WHERE `name` = 'Grammarly 英文校对' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '中英互译工具应用', '翻译工具|deepl|术语库', '文学', '语言与写作工具', 3, '用工具辅助翻译并校对术语', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '中英互译工具应用');
UPDATE `zy_skill` SET `alias` = '翻译工具|deepl|术语库', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 3, `description` = '用工具辅助翻译并校对术语' WHERE `name` = '中英互译工具应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '字幕制作与打轴', '字幕|打轴|srt|压制', '文学', '语言与写作工具', 3, '制作并压制字幕文件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '字幕制作与打轴');
UPDATE `zy_skill` SET `alias` = '字幕|打轴|srt|压制', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 3, `description` = '制作并压制字幕文件' WHERE `name` = '字幕制作与打轴' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '播客录制与剪辑', '播客|录音|剪辑|shownotes', '文学', '语言与写作工具', 3, '策划并制作播客节目', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '播客录制与剪辑');
UPDATE `zy_skill` SET `alias` = '播客|录音|剪辑|shownotes', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 3, `description` = '策划并制作播客节目' WHERE `name` = '播客录制与剪辑' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '公文格式与排版规范', '公文格式|红头|版式规范', '文学', '语言与写作工具', 2, '按规范排版公文', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '公文格式与排版规范');
UPDATE `zy_skill` SET `alias` = '公文格式|红头|版式规范', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 2, `description` = '按规范排版公文' WHERE `name` = '公文格式与排版规范' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '学术引用格式规范', '引用格式|apa|gb/t|参考文献', '文学', '语言与写作工具', 2, '按规范著录参考文献', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '学术引用格式规范');
UPDATE `zy_skill` SET `alias` = '引用格式|apa|gb/t|参考文献', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 2, `description` = '按规范著录参考文献' WHERE `name` = '学术引用格式规范' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '查重与降重处理', '查重|降重|改写|学术规范', '文学', '语言与写作工具', 3, '在保持原意前提下规范改写', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '查重与降重处理');
UPDATE `zy_skill` SET `alias` = '查重|降重|改写|学术规范', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 3, `description` = '在保持原意前提下规范改写' WHERE `name` = '查重与降重处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '外语听力训练方法', '听力|精听|泛听|dictation', '文学', '语言与写作工具', 3, '用科学方法提升外语听力', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '外语听力训练方法');
UPDATE `zy_skill` SET `alias` = '听力|精听|泛听|dictation', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 3, `description` = '用科学方法提升外语听力' WHERE `name` = '外语听力训练方法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '外语单词记忆方法', '背单词|词根|间隔重复|anki', '文学', '语言与写作工具', 2, '用记忆方法高效积累词汇', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '外语单词记忆方法');
UPDATE `zy_skill` SET `alias` = '背单词|词根|间隔重复|anki', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 2, `description` = '用记忆方法高效积累词汇' WHERE `name` = '外语单词记忆方法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '口语发音纠正', '发音|音标|连读|语调', '文学', '语言与写作工具', 3, '纠正发音并改善语调', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '口语发音纠正');
UPDATE `zy_skill` SET `alias` = '发音|音标|连读|语调', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 3, `description` = '纠正发音并改善语调' WHERE `name` = '口语发音纠正' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '语言交换与陪练组织', '语言交换|语伴|陪练', '文学', '语言与写作工具', 2, '组织语言交换与口语陪练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '语言交换与陪练组织');
UPDATE `zy_skill` SET `alias` = '语言交换|语伴|陪练', `category_l1` = '文学', `category_l2` = '语言与写作工具', `difficulty` = 2, `description` = '组织语言交换与口语陪练' WHERE `name` = '语言交换与陪练组织' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '计量经济学分析', '计量|计量经济|stata|回归', '经济学', '应用经济学', 4, '用计量方法检验经济假设', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '计量经济学分析');
UPDATE `zy_skill` SET `alias` = '计量|计量经济|stata|回归', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 4, `description` = '用计量方法检验经济假设' WHERE `name` = '计量经济学分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '微观与宏观经济学', '微观经济|宏观经济|供需|均衡', '经济学', '应用经济学', 3, '掌握基本经济模型与分析框架', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '微观与宏观经济学');
UPDATE `zy_skill` SET `alias` = '微观经济|宏观经济|供需|均衡', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 3, `description` = '掌握基本经济模型与分析框架' WHERE `name` = '微观与宏观经济学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '金融数据分析', '金融数据|wind|行情分析', '经济学', '应用经济学', 4, '获取并分析金融市场数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '金融数据分析');
UPDATE `zy_skill` SET `alias` = '金融数据|wind|行情分析', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 4, `description` = '获取并分析金融市场数据' WHERE `name` = '金融数据分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '投资理财与资产配置', '投资|理财|资产配置|基金', '经济学', '应用经济学', 3, '构建并评估投资组合', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '投资理财与资产配置');
UPDATE `zy_skill` SET `alias` = '投资|理财|资产配置|基金', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 3, `description` = '构建并评估投资组合' WHERE `name` = '投资理财与资产配置' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '国际贸易实务', '国际贸易|进出口|报关|信用证', '经济学', '应用经济学', 3, '处理进出口流程与单据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '国际贸易实务');
UPDATE `zy_skill` SET `alias` = '国际贸易|进出口|报关|信用证', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 3, `description` = '处理进出口流程与单据' WHERE `name` = '国际贸易实务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '产业分析与行业研究', '行业研究|产业分析|研报', '经济学', '应用经济学', 4, '撰写行业研究报告', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '产业分析与行业研究');
UPDATE `zy_skill` SET `alias` = '行业研究|产业分析|研报', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 4, `description` = '撰写行业研究报告' WHERE `name` = '产业分析与行业研究' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '经济学论文与建模', '经济论文|经济建模|实证', '经济学', '应用经济学', 4, '完成经济学实证论文', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '经济学论文与建模');
UPDATE `zy_skill` SET `alias` = '经济论文|经济建模|实证', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 4, `description` = '完成经济学实证论文' WHERE `name` = '经济学论文与建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '证券投资分析', '证券|股票|技术分析|基本面', '经济学', '应用经济学', 4, '分析证券投资价值与风险', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '证券投资分析');
UPDATE `zy_skill` SET `alias` = '证券|股票|技术分析|基本面', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 4, `description` = '分析证券投资价值与风险' WHERE `name` = '证券投资分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '量化投资策略', '量化|因子|回测|策略', '经济学', '应用经济学', 5, '构建并回测量化策略', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '量化投资策略');
UPDATE `zy_skill` SET `alias` = '量化|因子|回测|策略', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 5, `description` = '构建并回测量化策略' WHERE `name` = '量化投资策略' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '保险精算基础', '精算|保险|费率|准备金', '经济学', '应用经济学', 5, '计算保险费率与准备金', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '保险精算基础');
UPDATE `zy_skill` SET `alias` = '精算|保险|费率|准备金', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 5, `description` = '计算保险费率与准备金' WHERE `name` = '保险精算基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '国际贸易理论与实务', '国际贸易|比较优势|贸易壁垒', '经济学', '应用经济学', 4, '分析贸易结构与政策', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '国际贸易理论与实务');
UPDATE `zy_skill` SET `alias` = '国际贸易|比较优势|贸易壁垒', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 4, `description` = '分析贸易结构与政策' WHERE `name` = '国际贸易理论与实务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数字经济与平台经济', '数字经济|平台经济|双边市场', '经济学', '应用经济学', 4, '分析平台经济特征与监管', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数字经济与平台经济');
UPDATE `zy_skill` SET `alias` = '数字经济|平台经济|双边市场', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 4, `description` = '分析平台经济特征与监管' WHERE `name` = '数字经济与平台经济' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '财政与税收分析', '财政|税收|税负|预算', '经济学', '应用经济学', 4, '分析财政收支与税收政策', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '财政与税收分析');
UPDATE `zy_skill` SET `alias` = '财政|税收|税负|预算', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 4, `description` = '分析财政收支与税收政策' WHERE `name` = '财政与税收分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '金融风险管理', '风险|var|信用风险|压力测试', '经济学', '应用经济学', 5, '识别并计量金融风险', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '金融风险管理');
UPDATE `zy_skill` SET `alias` = '风险|var|信用风险|压力测试', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 5, `description` = '识别并计量金融风险' WHERE `name` = '金融风险管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '经济数据获取与清洗', '经济数据|数据源|清洗', '经济学', '应用经济学', 3, '从公开渠道获取并整理经济数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '经济数据获取与清洗');
UPDATE `zy_skill` SET `alias` = '经济数据|数据源|清洗', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 3, `description` = '从公开渠道获取并整理经济数据' WHERE `name` = '经济数据获取与清洗' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '实验经济学与行为经济', '实验经济|行为经济|前景理论', '经济学', '应用经济学', 5, '用实验方法研究经济行为', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '实验经济学与行为经济');
UPDATE `zy_skill` SET `alias` = '实验经济|行为经济|前景理论', `category_l1` = '经济学', `category_l2` = '应用经济学', `difficulty` = 5, `description` = '用实验方法研究经济行为' WHERE `name` = '实验经济学与行为经济' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '市场调研与用户洞察', '市场调研|问卷|竞品分析', '经济学', '工商管理', 3, '设计调研并提炼用户洞察', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '市场调研与用户洞察');
UPDATE `zy_skill` SET `alias` = '市场调研|问卷|竞品分析', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 3, `description` = '设计调研并提炼用户洞察' WHERE `name` = '市场调研与用户洞察' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '营销策划与推广', '营销|推广|活动策划|投放', '经济学', '工商管理', 3, '制定并执行营销推广方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '营销策划与推广');
UPDATE `zy_skill` SET `alias` = '营销|推广|活动策划|投放', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 3, `description` = '制定并执行营销推广方案' WHERE `name` = '营销策划与推广' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '财务报表分析', '财报|财务报表|财务分析', '经济学', '工商管理', 4, '读财报并判断经营状况', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '财务报表分析');
UPDATE `zy_skill` SET `alias` = '财报|财务报表|财务分析', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '读财报并判断经营状况' WHERE `name` = '财务报表分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '会计实务与记账', '会计|记账|凭证|报表', '经济学', '工商管理', 3, '完成日常账务处理与报表编制', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '会计实务与记账');
UPDATE `zy_skill` SET `alias` = '会计|记账|凭证|报表', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 3, `description` = '完成日常账务处理与报表编制' WHERE `name` = '会计实务与记账' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '审计与内控', '审计|内部控制|合规', '经济学', '工商管理', 4, '执行审计程序并识别内控缺陷', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '审计与内控');
UPDATE `zy_skill` SET `alias` = '审计|内部控制|合规', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '执行审计程序并识别内控缺陷' WHERE `name` = '审计与内控' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '人力资源管理', '人力资源|hr|招聘|绩效', '经济学', '工商管理', 3, '完成招聘、绩效与员工关系管理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '人力资源管理');
UPDATE `zy_skill` SET `alias` = '人力资源|hr|招聘|绩效', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 3, `description` = '完成招聘、绩效与员工关系管理' WHERE `name` = '人力资源管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '商业计划书撰写', '商业计划书|bp|创业计划', '经济学', '工商管理', 3, '撰写可落地的商业计划书', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '商业计划书撰写');
UPDATE `zy_skill` SET `alias` = '商业计划书|bp|创业计划', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 3, `description` = '撰写可落地的商业计划书' WHERE `name` = '商业计划书撰写' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '供应链与物流管理', '供应链|物流|库存|采购', '经济学', '工商管理', 4, '优化库存与物流调度方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '供应链与物流管理');
UPDATE `zy_skill` SET `alias` = '供应链|物流|库存|采购', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '优化库存与物流调度方案' WHERE `name` = '供应链与物流管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '商业数据分析', '商业分析|bi|指标体系|看板', '经济学', '工商管理', 4, '搭建指标体系与经营看板', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '商业数据分析');
UPDATE `zy_skill` SET `alias` = '商业分析|bi|指标体系|看板', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '搭建指标体系与经营看板' WHERE `name` = '商业数据分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '项目管理 PMP', 'pmp|项目管理|里程碑', '经济学', '工商管理', 4, '按项目管理体系推进复杂项目', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '项目管理 PMP');
UPDATE `zy_skill` SET `alias` = 'pmp|项目管理|里程碑', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '按项目管理体系推进复杂项目' WHERE `name` = '项目管理 PMP' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '创业与商业模式设计', '创业|商业模式|canvas', '经济学', '工商管理', 4, '设计并验证商业模式', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '创业与商业模式设计');
UPDATE `zy_skill` SET `alias` = '创业|商业模式|canvas', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '设计并验证商业模式' WHERE `name` = '创业与商业模式设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '电子商务运营', '电商|店铺运营|转化率', '经济学', '工商管理', 3, '运营电商店铺与提升转化', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '电子商务运营');
UPDATE `zy_skill` SET `alias` = '电商|店铺运营|转化率', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 3, `description` = '运营电商店铺与提升转化' WHERE `name` = '电子商务运营' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '客户关系管理', 'crm|客户运营|生命周期', '经济学', '工商管理', 3, '管理客户关系与生命周期', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '客户关系管理');
UPDATE `zy_skill` SET `alias` = 'crm|客户运营|生命周期', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 3, `description` = '管理客户关系与生命周期' WHERE `name` = '客户关系管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '战略管理与竞争分析', '战略|五力|swot|竞争', '经济学', '工商管理', 4, '制定企业竞争战略', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '战略管理与竞争分析');
UPDATE `zy_skill` SET `alias` = '战略|五力|swot|竞争', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '制定企业竞争战略' WHERE `name` = '战略管理与竞争分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '组织行为与团队建设', '组织行为|团队|激励', '经济学', '工商管理', 3, '理解组织行为并建设团队', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '组织行为与团队建设');
UPDATE `zy_skill` SET `alias` = '组织行为|团队|激励', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 3, `description` = '理解组织行为并建设团队' WHERE `name` = '组织行为与团队建设' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '业务流程优化', '流程优化|bpr|sop', '经济学', '工商管理', 4, '梳理并优化业务流程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '业务流程优化');
UPDATE `zy_skill` SET `alias` = '流程优化|bpr|sop', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '梳理并优化业务流程' WHERE `name` = '业务流程优化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '质量管理与六西格玛', '质量管理|六西格玛|spc', '经济学', '工商管理', 4, '用统计方法改进质量', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '质量管理与六西格玛');
UPDATE `zy_skill` SET `alias` = '质量管理|六西格玛|spc', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '用统计方法改进质量' WHERE `name` = '质量管理与六西格玛' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '定价与收益管理', '定价|收益管理|弹性', '经济学', '工商管理', 4, '制定定价与收益策略', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '定价与收益管理');
UPDATE `zy_skill` SET `alias` = '定价|收益管理|弹性', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '制定定价与收益策略' WHERE `name` = '定价与收益管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '消费者行为分析', '消费者行为|决策路径|洞察', '经济学', '工商管理', 4, '分析消费者决策过程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '消费者行为分析');
UPDATE `zy_skill` SET `alias` = '消费者行为|决策路径|洞察', `category_l1` = '经济学', `category_l2` = '工商管理', `difficulty` = 4, `description` = '分析消费者决策过程' WHERE `name` = '消费者行为分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Wind 与金融数据终端', 'wind|choice|金融终端', '经济学', '金融与实务工具', 4, '用金融终端获取与分析数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Wind 与金融数据终端');
UPDATE `zy_skill` SET `alias` = 'wind|choice|金融终端', `category_l1` = '经济学', `category_l2` = '金融与实务工具', `difficulty` = 4, `description` = '用金融终端获取与分析数据' WHERE `name` = 'Wind 与金融数据终端' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Excel 财务建模', '财务模型|估值模型|dcf', '经济学', '金融与实务工具', 5, '搭建财务预测与估值模型', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Excel 财务建模');
UPDATE `zy_skill` SET `alias` = '财务模型|估值模型|dcf', `category_l1` = '经济学', `category_l2` = '金融与实务工具', `difficulty` = 5, `description` = '搭建财务预测与估值模型' WHERE `name` = 'Excel 财务建模' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT 'Python 金融数据分析', '金融数据|pandas|行情分析', '经济学', '金融与实务工具', 4, '用 Python 分析金融时间序列', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = 'Python 金融数据分析');
UPDATE `zy_skill` SET `alias` = '金融数据|pandas|行情分析', `category_l1` = '经济学', `category_l2` = '金融与实务工具', `difficulty` = 4, `description` = '用 Python 分析金融时间序列' WHERE `name` = 'Python 金融数据分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '区块链与数字货币基础', '数字货币|区块链|defi', '经济学', '金融与实务工具', 4, '理解数字货币与链上金融', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '区块链与数字货币基础');
UPDATE `zy_skill` SET `alias` = '数字货币|区块链|defi', `category_l1` = '经济学', `category_l2` = '金融与实务工具', `difficulty` = 4, `description` = '理解数字货币与链上金融' WHERE `name` = '区块链与数字货币基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '税务申报实务', '报税|纳税申报|发票', '经济学', '金融与实务工具', 3, '完成纳税申报与发票管理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '税务申报实务');
UPDATE `zy_skill` SET `alias` = '报税|纳税申报|发票', `category_l1` = '经济学', `category_l2` = '金融与实务工具', `difficulty` = 3, `description` = '完成纳税申报与发票管理' WHERE `name` = '税务申报实务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '银行信贷与风控实务', '信贷|风控|授信', '经济学', '金融与实务工具', 4, '了解信贷流程与风控要点', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '银行信贷与风控实务');
UPDATE `zy_skill` SET `alias` = '信贷|风控|授信', `category_l1` = '经济学', `category_l2` = '金融与实务工具', `difficulty` = 4, `description` = '了解信贷流程与风控要点' WHERE `name` = '银行信贷与风控实务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '保险产品与理赔实务', '保险|理赔|条款', '经济学', '金融与实务工具', 3, '理解保险条款与理赔流程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '保险产品与理赔实务');
UPDATE `zy_skill` SET `alias` = '保险|理赔|条款', `category_l1` = '经济学', `category_l2` = '金融与实务工具', `difficulty` = 3, `description` = '理解保险条款与理赔流程' WHERE `name` = '保险产品与理赔实务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '社会调查与统计分析', '社会调查|抽样|统计分析', '管理学', '公共管理', 3, '设计抽样方案并完成统计分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '社会调查与统计分析');
UPDATE `zy_skill` SET `alias` = '社会调查|抽样|统计分析', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 3, `description` = '设计抽样方案并完成统计分析' WHERE `name` = '社会调查与统计分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '公共政策分析', '政策分析|公共政策|评估', '管理学', '公共管理', 4, '分析政策效果并提出建议', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '公共政策分析');
UPDATE `zy_skill` SET `alias` = '政策分析|公共政策|评估', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 4, `description` = '分析政策效果并提出建议' WHERE `name` = '公共政策分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '公文写作与行政事务', '公文写作|行政|会务', '管理学', '公共管理', 2, '处理行政公文与会务组织', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '公文写作与行政事务');
UPDATE `zy_skill` SET `alias` = '公文写作|行政|会务', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 2, `description` = '处理行政公文与会务组织' WHERE `name` = '公文写作与行政事务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '社区治理与志愿服务', '社区治理|志愿|社会组织', '管理学', '公共管理', 3, '组织社区项目与志愿活动', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '社区治理与志愿服务');
UPDATE `zy_skill` SET `alias` = '社区治理|志愿|社会组织', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 3, `description` = '组织社区项目与志愿活动' WHERE `name` = '社区治理与志愿服务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '应急管理与预案编制', '应急管理|预案|演练', '管理学', '公共管理', 4, '编制应急预案并组织演练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '应急管理与预案编制');
UPDATE `zy_skill` SET `alias` = '应急管理|预案|演练', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 4, `description` = '编制应急预案并组织演练' WHERE `name` = '应急管理与预案编制' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '社会保障政策分析', '社保|养老|医保|政策', '管理学', '公共管理', 4, '分析社会保障制度设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '社会保障政策分析');
UPDATE `zy_skill` SET `alias` = '社保|养老|医保|政策', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 4, `description` = '分析社会保障制度设计' WHERE `name` = '社会保障政策分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '非营利组织管理', 'ngo|社会组织|公益项目', '管理学', '公共管理', 3, '管理非营利组织与公益项目', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '非营利组织管理');
UPDATE `zy_skill` SET `alias` = 'ngo|社会组织|公益项目', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 3, `description` = '管理非营利组织与公益项目' WHERE `name` = '非营利组织管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '城市规划与公共政策', '城市规划|公共政策|治理', '管理学', '公共管理', 4, '参与城市规划与政策制定', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '城市规划与公共政策');
UPDATE `zy_skill` SET `alias` = '城市规划|公共政策|治理', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 4, `description` = '参与城市规划与政策制定' WHERE `name` = '城市规划与公共政策' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '政府绩效评估', '绩效评估|指标体系|考核', '管理学', '公共管理', 4, '设计政府绩效评估指标', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '政府绩效评估');
UPDATE `zy_skill` SET `alias` = '绩效评估|指标体系|考核', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 4, `description` = '设计政府绩效评估指标' WHERE `name` = '政府绩效评估' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '舆情应对与信息公开', '舆情|信息公开|回应', '管理学', '公共管理', 3, '处理舆情并做好信息公开', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '舆情应对与信息公开');
UPDATE `zy_skill` SET `alias` = '舆情|信息公开|回应', `category_l1` = '管理学', `category_l2` = '公共管理', `difficulty` = 3, `description` = '处理舆情并做好信息公开' WHERE `name` = '舆情应对与信息公开' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '运筹优化与决策分析', '运筹|优化|决策|排队论', '管理学', '管理科学与工程', 4, '建立优化模型支持决策', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '运筹优化与决策分析');
UPDATE `zy_skill` SET `alias` = '运筹|优化|决策|排队论', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 4, `description` = '建立优化模型支持决策' WHERE `name` = '运筹优化与决策分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '信息系统分析与设计', '信息系统|需求分析|er图', '管理学', '管理科学与工程', 4, '分析业务流程并设计信息系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '信息系统分析与设计');
UPDATE `zy_skill` SET `alias` = '信息系统|需求分析|er图', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 4, `description` = '分析业务流程并设计信息系统' WHERE `name` = '信息系统分析与设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '项目管理与风险控制', '项目风险|wbs|进度控制', '管理学', '管理科学与工程', 4, '识别风险并制定应对措施', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '项目管理与风险控制');
UPDATE `zy_skill` SET `alias` = '项目风险|wbs|进度控制', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 4, `description` = '识别风险并制定应对措施' WHERE `name` = '项目管理与风险控制' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据驱动的运营优化', '运营优化|数据驱动|a/b测试', '管理学', '管理科学与工程', 4, '用数据实验改进运营指标', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据驱动的运营优化');
UPDATE `zy_skill` SET `alias` = '运营优化|数据驱动|a/b测试', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 4, `description` = '用数据实验改进运营指标' WHERE `name` = '数据驱动的运营优化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '供应链建模与仿真', '供应链建模|仿真|anylogic', '管理学', '管理科学与工程', 5, '建模并仿真供应链系统', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '供应链建模与仿真');
UPDATE `zy_skill` SET `alias` = '供应链建模|仿真|anylogic', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 5, `description` = '建模并仿真供应链系统' WHERE `name` = '供应链建模与仿真' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '业务流程建模 BPMN', 'bpmn|流程建模|流程引擎', '管理学', '管理科学与工程', 4, '用 BPMN 建模业务流程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '业务流程建模 BPMN');
UPDATE `zy_skill` SET `alias` = 'bpmn|流程建模|流程引擎', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 4, `description` = '用 BPMN 建模业务流程' WHERE `name` = '业务流程建模 BPMN' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据治理与主数据管理', '数据治理|主数据|元数据', '管理学', '管理科学与工程', 5, '建立数据治理体系', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据治理与主数据管理');
UPDATE `zy_skill` SET `alias` = '数据治理|主数据|元数据', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 5, `description` = '建立数据治理体系' WHERE `name` = '数据治理与主数据管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '商业智能与报表开发', 'bi|tableau|powerbi|报表', '管理学', '管理科学与工程', 4, '开发经营分析报表与看板', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '商业智能与报表开发');
UPDATE `zy_skill` SET `alias` = 'bi|tableau|powerbi|报表', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 4, `description` = '开发经营分析报表与看板' WHERE `name` = '商业智能与报表开发' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '精益生产与现场改善', '精益|5s|看板|现场改善', '管理学', '管理科学与工程', 4, '推行精益改善活动', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '精益生产与现场改善');
UPDATE `zy_skill` SET `alias` = '精益|5s|看板|现场改善', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 4, `description` = '推行精益改善活动' WHERE `name` = '精益生产与现场改善' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '项目管理工具应用', 'jira|project|teambition', '管理学', '管理科学与工程', 3, '用工具管理项目任务与进度', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '项目管理工具应用');
UPDATE `zy_skill` SET `alias` = 'jira|project|teambition', `category_l1` = '管理学', `category_l2` = '管理科学与工程', `difficulty` = 3, `description` = '用工具管理项目任务与进度' WHERE `name` = '项目管理工具应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '文献检索与信息素养', '文献检索|知网|web of science', '管理学', '图书情报与档案管理', 2, '高效检索并筛选学术文献', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '文献检索与信息素养');
UPDATE `zy_skill` SET `alias` = '文献检索|知网|web of science', `category_l1` = '管理学', `category_l2` = '图书情报与档案管理', `difficulty` = 2, `description` = '高效检索并筛选学术文献' WHERE `name` = '文献检索与信息素养' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '参考文献管理与规范', '参考文献|endnote|zotero|引用规范', '管理学', '图书情报与档案管理', 2, '规范管理引用与参考文献格式', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '参考文献管理与规范');
UPDATE `zy_skill` SET `alias` = '参考文献|endnote|zotero|引用规范', `category_l1` = '管理学', `category_l2` = '图书情报与档案管理', `difficulty` = 2, `description` = '规范管理引用与参考文献格式' WHERE `name` = '参考文献管理与规范' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '知识图谱构建', '知识图谱|本体|关系抽取', '管理学', '图书情报与档案管理', 5, '构建领域知识图谱与本体', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '知识图谱构建');
UPDATE `zy_skill` SET `alias` = '知识图谱|本体|关系抽取', `category_l1` = '管理学', `category_l2` = '图书情报与档案管理', `difficulty` = 5, `description` = '构建领域知识图谱与本体' WHERE `name` = '知识图谱构建' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '档案整理与数字化', '档案|数字化|编目', '管理学', '图书情报与档案管理', 3, '完成档案整理编目与数字化', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '档案整理与数字化');
UPDATE `zy_skill` SET `alias` = '档案|数字化|编目', `category_l1` = '管理学', `category_l2` = '图书情报与档案管理', `difficulty` = 3, `description` = '完成档案整理编目与数字化' WHERE `name` = '档案整理与数字化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数字人文与文本挖掘', '数字人文|文本挖掘|语料', '管理学', '图书情报与档案管理', 5, '用计算方法研究人文语料', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数字人文与文本挖掘');
UPDATE `zy_skill` SET `alias` = '数字人文|文本挖掘|语料', `category_l1` = '管理学', `category_l2` = '图书情报与档案管理', `difficulty` = 5, `description` = '用计算方法研究人文语料' WHERE `name` = '数字人文与文本挖掘' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '情报分析与竞争情报', '情报分析|竞争情报|报告', '管理学', '图书情报与档案管理', 4, '撰写情报分析报告', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '情报分析与竞争情报');
UPDATE `zy_skill` SET `alias` = '情报分析|竞争情报|报告', `category_l1` = '管理学', `category_l2` = '图书情报与档案管理', `difficulty` = 4, `description` = '撰写情报分析报告' WHERE `name` = '情报分析与竞争情报' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '信息组织与元数据', '元数据|编目|分类法', '管理学', '图书情报与档案管理', 4, '设计信息组织与元数据方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '信息组织与元数据');
UPDATE `zy_skill` SET `alias` = '元数据|编目|分类法', `category_l1` = '管理学', `category_l2` = '图书情报与档案管理', `difficulty` = 4, `description` = '设计信息组织与元数据方案' WHERE `name` = '信息组织与元数据' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '学术出版与开放获取', '开放获取|预印本|投稿', '管理学', '图书情报与档案管理', 3, '了解学术出版流程与规范', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '学术出版与开放获取');
UPDATE `zy_skill` SET `alias` = '开放获取|预印本|投稿', `category_l1` = '管理学', `category_l2` = '图书情报与档案管理', `difficulty` = 3, `description` = '了解学术出版流程与规范' WHERE `name` = '学术出版与开放获取' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '演讲与公开表达', '演讲|presentation|表达|台风', '管理学', '通用职业能力', 3, '克服紧张，结构清晰地做公开表达', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '演讲与公开表达');
UPDATE `zy_skill` SET `alias` = '演讲|presentation|表达|台风', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '克服紧张，结构清晰地做公开表达' WHERE `name` = '演讲与公开表达' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '答辩与面试技巧', '答辩|面试|自我介绍|问答', '管理学', '通用职业能力', 3, '准备并完成答辩或面试', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '答辩与面试技巧');
UPDATE `zy_skill` SET `alias` = '答辩|面试|自我介绍|问答', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '准备并完成答辩或面试' WHERE `name` = '答辩与面试技巧' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '时间管理与任务规划', '时间管理|番茄钟|待办|优先级', '管理学', '通用职业能力', 2, '规划任务优先级并保持执行', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '时间管理与任务规划');
UPDATE `zy_skill` SET `alias` = '时间管理|番茄钟|待办|优先级', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 2, `description` = '规划任务优先级并保持执行' WHERE `name` = '时间管理与任务规划' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '团队协作与冲突处理', '团队协作|沟通|冲突|分工', '管理学', '通用职业能力', 3, '在团队中协作并处理分歧', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '团队协作与冲突处理');
UPDATE `zy_skill` SET `alias` = '团队协作|沟通|冲突|分工', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '在团队中协作并处理分歧' WHERE `name` = '团队协作与冲突处理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '跨专业沟通与转译', '跨专业|沟通|术语转译|共识', '管理学', '通用职业能力', 4, '把本专业内容讲给外专业的人听懂', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '跨专业沟通与转译');
UPDATE `zy_skill` SET `alias` = '跨专业|沟通|术语转译|共识', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 4, `description` = '把本专业内容讲给外专业的人听懂' WHERE `name` = '跨专业沟通与转译' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '会议组织与纪要', '会议|纪要|议程|跟进', '管理学', '通用职业能力', 2, '组织会议并撰写可执行纪要', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '会议组织与纪要');
UPDATE `zy_skill` SET `alias` = '会议|纪要|议程|跟进', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 2, `description` = '组织会议并撰写可执行纪要' WHERE `name` = '会议组织与纪要' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '目标拆解与复盘', 'okr|目标拆解|复盘|改进', '管理学', '通用职业能力', 3, '把大目标拆成可执行任务并复盘', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '目标拆解与复盘');
UPDATE `zy_skill` SET `alias` = 'okr|目标拆解|复盘|改进', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '把大目标拆成可执行任务并复盘' WHERE `name` = '目标拆解与复盘' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '简历撰写与优化', '简历|求职|经历描述|star', '管理学', '通用职业能力', 3, '撰写突出能力的简历', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '简历撰写与优化');
UPDATE `zy_skill` SET `alias` = '简历|求职|经历描述|star', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '撰写突出能力的简历' WHERE `name` = '简历撰写与优化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '职业规划与行业调研', '职业规划|行业调研|岗位分析', '管理学', '通用职业能力', 3, '调研行业并规划职业路径', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '职业规划与行业调研');
UPDATE `zy_skill` SET `alias` = '职业规划|行业调研|岗位分析', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '调研行业并规划职业路径' WHERE `name` = '职业规划与行业调研' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '商业谈判与沟通', '谈判|沟通|让步|双赢', '管理学', '通用职业能力', 4, '在合作中达成双方可接受的方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '商业谈判与沟通');
UPDATE `zy_skill` SET `alias` = '谈判|沟通|让步|双赢', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 4, `description` = '在合作中达成双方可接受的方案' WHERE `name` = '商业谈判与沟通' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '文档写作与结构化表达', '文档写作|结构化|金字塔原理', '管理学', '通用职业能力', 3, '用结构化方式表达复杂内容', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '文档写作与结构化表达');
UPDATE `zy_skill` SET `alias` = '文档写作|结构化|金字塔原理', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '用结构化方式表达复杂内容' WHERE `name` = '文档写作与结构化表达' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据素养与指标解读', '数据素养|指标|口径|解读', '管理学', '通用职业能力', 3, '读懂数据指标并识别口径问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据素养与指标解读');
UPDATE `zy_skill` SET `alias` = '数据素养|指标|口径|解读', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '读懂数据指标并识别口径问题' WHERE `name` = '数据素养与指标解读' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '学习效率与刻意练习', '学习方法|刻意练习|费曼', '管理学', '通用职业能力', 2, '用科学方法提升学习效率', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '学习效率与刻意练习');
UPDATE `zy_skill` SET `alias` = '学习方法|刻意练习|费曼', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 2, `description` = '用科学方法提升学习效率' WHERE `name` = '学习效率与刻意练习' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '英文邮件与商务沟通', '英文邮件|商务沟通|邮件礼仪', '管理学', '通用职业能力', 3, '撰写得体的英文商务邮件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '英文邮件与商务沟通');
UPDATE `zy_skill` SET `alias` = '英文邮件|商务沟通|邮件礼仪', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '撰写得体的英文商务邮件' WHERE `name` = '英文邮件与商务沟通' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '知识产权与成果保护', '专利|软著|成果|申报', '管理学', '通用职业能力', 4, '申请专利软著并保护成果', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '知识产权与成果保护');
UPDATE `zy_skill` SET `alias` = '专利|软著|成果|申报', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 4, `description` = '申请专利软著并保护成果' WHERE `name` = '知识产权与成果保护' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '竞赛备赛与团队组织', '竞赛|备赛|组队|分工', '管理学', '通用职业能力', 3, '组织竞赛团队并推进备赛', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '竞赛备赛与团队组织');
UPDATE `zy_skill` SET `alias` = '竞赛|备赛|组队|分工', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '组织竞赛团队并推进备赛' WHERE `name` = '竞赛备赛与团队组织' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '科研项目管理', '科研项目|申报书|结项|进度', '管理学', '通用职业能力', 4, '管理科研项目全流程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '科研项目管理');
UPDATE `zy_skill` SET `alias` = '科研项目|申报书|结项|进度', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 4, `description` = '管理科研项目全流程' WHERE `name` = '科研项目管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '开题与文献综述撰写', '开题|文献综述|研究设计', '管理学', '通用职业能力', 3, '完成开题报告与文献综述', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '开题与文献综述撰写');
UPDATE `zy_skill` SET `alias` = '开题|文献综述|研究设计', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '完成开题报告与文献综述' WHERE `name` = '开题与文献综述撰写' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据备份与信息安全习惯', '备份|信息安全|密码管理', '管理学', '通用职业能力', 2, '建立数据备份与信息安全习惯', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据备份与信息安全习惯');
UPDATE `zy_skill` SET `alias` = '备份|信息安全|密码管理', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 2, `description` = '建立数据备份与信息安全习惯' WHERE `name` = '数据备份与信息安全习惯' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '信息安全与隐私保护意识', '隐私保护|合规|数据安全', '管理学', '通用职业能力', 3, '理解并遵守数据合规要求', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '信息安全与隐私保护意识');
UPDATE `zy_skill` SET `alias` = '隐私保护|合规|数据安全', `category_l1` = '管理学', `category_l2` = '通用职业能力', `difficulty` = 3, `description` = '理解并遵守数据合规要求' WHERE `name` = '信息安全与隐私保护意识' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '法律文书写作', '法律文书|起诉状|合同', '法学', '法学', 4, '撰写起诉状、答辩状与合同', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '法律文书写作');
UPDATE `zy_skill` SET `alias` = '法律文书|起诉状|合同', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 4, `description` = '撰写起诉状、答辩状与合同' WHERE `name` = '法律文书写作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '合同法与合同审查', '合同法|合同审查|条款', '法学', '法学', 4, '审查合同条款并识别风险', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '合同法与合同审查');
UPDATE `zy_skill` SET `alias` = '合同法|合同审查|条款', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 4, `description` = '审查合同条款并识别风险' WHERE `name` = '合同法与合同审查' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '模拟法庭与辩论', '模拟法庭|辩论|庭辩', '法学', '法学', 4, '参与模拟法庭并完成庭辩', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '模拟法庭与辩论');
UPDATE `zy_skill` SET `alias` = '模拟法庭|辩论|庭辩', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 4, `description` = '参与模拟法庭并完成庭辩' WHERE `name` = '模拟法庭与辩论' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '法律检索与案例研究', '法律检索|案例|裁判文书', '法学', '法学', 3, '检索法条与案例并做类案分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '法律检索与案例研究');
UPDATE `zy_skill` SET `alias` = '法律检索|案例|裁判文书', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 3, `description` = '检索法条与案例并做类案分析' WHERE `name` = '法律检索与案例研究' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '知识产权法实务', '知识产权|专利|商标|著作权', '法学', '法学', 4, '处理专利商标著作权相关事务', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '知识产权法实务');
UPDATE `zy_skill` SET `alias` = '知识产权|专利|商标|著作权', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 4, `description` = '处理专利商标著作权相关事务' WHERE `name` = '知识产权法实务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '宪法与行政法', '宪法|行政法|行政救济', '法学', '法学', 4, '理解宪法与行政法基本制度', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '宪法与行政法');
UPDATE `zy_skill` SET `alias` = '宪法|行政法|行政救济', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 4, `description` = '理解宪法与行政法基本制度' WHERE `name` = '宪法与行政法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '刑法与刑事辩护', '刑法|犯罪构成|辩护', '法学', '法学', 4, '掌握犯罪构成与辩护要点', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '刑法与刑事辩护');
UPDATE `zy_skill` SET `alias` = '刑法|犯罪构成|辩护', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 4, `description` = '掌握犯罪构成与辩护要点' WHERE `name` = '刑法与刑事辩护' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '民法与物权债权', '民法|物权|债权|侵权', '法学', '法学', 4, '掌握民事权利与责任规则', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '民法与物权债权');
UPDATE `zy_skill` SET `alias` = '民法|物权|债权|侵权', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 4, `description` = '掌握民事权利与责任规则' WHERE `name` = '民法与物权债权' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '民事诉讼法实务', '民诉|诉讼程序|证据', '法学', '法学', 4, '处理民事诉讼程序与证据规则', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '民事诉讼法实务');
UPDATE `zy_skill` SET `alias` = '民诉|诉讼程序|证据', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 4, `description` = '处理民事诉讼程序与证据规则' WHERE `name` = '民事诉讼法实务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '国际法与国际贸易法', '国际法|wto|贸易争端', '法学', '法学', 5, '理解国际法与贸易争端解决', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '国际法与国际贸易法');
UPDATE `zy_skill` SET `alias` = '国际法|wto|贸易争端', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 5, `description` = '理解国际法与贸易争端解决' WHERE `name` = '国际法与国际贸易法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '公司法与证券法', '公司法|证券法|合规', '法学', '法学', 4, '处理公司治理与证券合规', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '公司法与证券法');
UPDATE `zy_skill` SET `alias` = '公司法|证券法|合规', `category_l1` = '法学', `category_l2` = '法学', `difficulty` = 4, `description` = '处理公司治理与证券合规' WHERE `name` = '公司法与证券法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '合同起草与风险条款', '合同起草|风险条款|违约责任', '法学', '法律实务与合规', 4, '起草合同并设计风险条款', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '合同起草与风险条款');
UPDATE `zy_skill` SET `alias` = '合同起草|风险条款|违约责任', `category_l1` = '法学', `category_l2` = '法律实务与合规', `difficulty` = 4, `description` = '起草合同并设计风险条款' WHERE `name` = '合同起草与风险条款' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '劳动法与劳动争议', '劳动法|劳动合同|争议', '法学', '法律实务与合规', 3, '处理劳动合同与争议问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '劳动法与劳动争议');
UPDATE `zy_skill` SET `alias` = '劳动法|劳动合同|争议', `category_l1` = '法学', `category_l2` = '法律实务与合规', `difficulty` = 3, `description` = '处理劳动合同与争议问题' WHERE `name` = '劳动法与劳动争议' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '数据合规与个人信息保护', '数据合规|个人信息保护法|隐私', '法学', '法律实务与合规', 4, '按法规要求处理个人信息', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '数据合规与个人信息保护');
UPDATE `zy_skill` SET `alias` = '数据合规|个人信息保护法|隐私', `category_l1` = '法学', `category_l2` = '法律实务与合规', `difficulty` = 4, `description` = '按法规要求处理个人信息' WHERE `name` = '数据合规与个人信息保护' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '知识产权申请实务', '专利撰写|软著申请|商标注册', '法学', '法律实务与合规', 4, '完成专利软著商标的申请', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '知识产权申请实务');
UPDATE `zy_skill` SET `alias` = '专利撰写|软著申请|商标注册', `category_l1` = '法学', `category_l2` = '法律实务与合规', `difficulty` = 4, `description` = '完成专利软著商标的申请' WHERE `name` = '知识产权申请实务' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '法律文书与证据整理', '证据|举证|文书', '法学', '法律实务与合规', 4, '整理证据并撰写法律文书', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '法律文书与证据整理');
UPDATE `zy_skill` SET `alias` = '证据|举证|文书', `category_l1` = '法学', `category_l2` = '法律实务与合规', `difficulty` = 4, `description` = '整理证据并撰写法律文书' WHERE `name` = '法律文书与证据整理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '模拟仲裁与调解', '仲裁|调解|和解', '法学', '法律实务与合规', 4, '参与仲裁或调解程序', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '模拟仲裁与调解');
UPDATE `zy_skill` SET `alias` = '仲裁|调解|和解', `category_l1` = '法学', `category_l2` = '法律实务与合规', `difficulty` = 4, `description` = '参与仲裁或调解程序' WHERE `name` = '模拟仲裁与调解' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '教学设计', '教学设计|教案|课程设计', '教育学', '教育学', 3, '设计教学目标、活动与评价', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '教学设计');
UPDATE `zy_skill` SET `alias` = '教学设计|教案|课程设计', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 3, `description` = '设计教学目标、活动与评价' WHERE `name` = '教学设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '说课与试讲', '说课|试讲|教师资格|面试', '教育学', '教育学', 3, '完成说课与课堂试讲', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '说课与试讲');
UPDATE `zy_skill` SET `alias` = '说课|试讲|教师资格|面试', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 3, `description` = '完成说课与课堂试讲' WHERE `name` = '说课与试讲' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '教育心理学应用', '教育心理|学习动机|个别差异', '教育学', '教育学', 3, '运用心理学原理改进教学', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '教育心理学应用');
UPDATE `zy_skill` SET `alias` = '教育心理|学习动机|个别差异', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 3, `description` = '运用心理学原理改进教学' WHERE `name` = '教育心理学应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '教学课件制作', '课件|ppt教学|交互课件|希沃', '教育学', '教育学', 3, '制作清晰易用的教学课件', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '教学课件制作');
UPDATE `zy_skill` SET `alias` = '课件|ppt教学|交互课件|希沃', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 3, `description` = '制作清晰易用的教学课件' WHERE `name` = '教学课件制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '教育测量与评价', '教育测量|试卷分析|评价', '教育学', '教育学', 4, '编制试卷并做质量分析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '教育测量与评价');
UPDATE `zy_skill` SET `alias` = '教育测量|试卷分析|评价', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 4, `description` = '编制试卷并做质量分析' WHERE `name` = '教育测量与评价' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '班主任与班级管理', '班主任|班级管理|家校沟通', '教育学', '教育学', 3, '组织班级活动与家校沟通', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '班主任与班级管理');
UPDATE `zy_skill` SET `alias` = '班主任|班级管理|家校沟通', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 3, `description` = '组织班级活动与家校沟通' WHERE `name` = '班主任与班级管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '微课与在线课程制作', '微课|慕课|录屏|在线课程', '教育学', '教育学', 3, '设计并制作微课视频', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '微课与在线课程制作');
UPDATE `zy_skill` SET `alias` = '微课|慕课|录屏|在线课程', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 3, `description` = '设计并制作微课视频' WHERE `name` = '微课与在线课程制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '翻转课堂设计', '翻转课堂|课前任务|课堂活动', '教育学', '教育学', 3, '设计翻转课堂的教学流程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '翻转课堂设计');
UPDATE `zy_skill` SET `alias` = '翻转课堂|课前任务|课堂活动', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 3, `description` = '设计翻转课堂的教学流程' WHERE `name` = '翻转课堂设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '项目式学习设计', 'pbl|项目式学习|驱动问题', '教育学', '教育学', 4, '设计项目式学习方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '项目式学习设计');
UPDATE `zy_skill` SET `alias` = 'pbl|项目式学习|驱动问题', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 4, `description` = '设计项目式学习方案' WHERE `name` = '项目式学习设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '教育技术工具应用', '教育技术|雨课堂|学习通', '教育学', '教育学', 2, '用工具支撑线上线下混合教学', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '教育技术工具应用');
UPDATE `zy_skill` SET `alias` = '教育技术|雨课堂|学习通', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 2, `description` = '用工具支撑线上线下混合教学' WHERE `name` = '教育技术工具应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '特殊教育基础', '特殊教育|融合教育|个别化', '教育学', '教育学', 4, '理解特殊教育需求与支持策略', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '特殊教育基础');
UPDATE `zy_skill` SET `alias` = '特殊教育|融合教育|个别化', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 4, `description` = '理解特殊教育需求与支持策略' WHERE `name` = '特殊教育基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '教育政策与法规', '教育政策|教师法|法规', '教育学', '教育学', 3, '掌握教育相关法规要求', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '教育政策与法规');
UPDATE `zy_skill` SET `alias` = '教育政策|教师法|法规', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 3, `description` = '掌握教育相关法规要求' WHERE `name` = '教育政策与法规' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '学业辅导与答疑', '辅导|答疑|一对一', '教育学', '教育学', 2, '为学生提供学业辅导', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '学业辅导与答疑');
UPDATE `zy_skill` SET `alias` = '辅导|答疑|一对一', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 2, `description` = '为学生提供学业辅导' WHERE `name` = '学业辅导与答疑' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '课程思政设计', '课程思政|价值引领|融入', '教育学', '教育学', 3, '在专业课中设计思政元素', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '课程思政设计');
UPDATE `zy_skill` SET `alias` = '课程思政|价值引领|融入', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 3, `description` = '在专业课中设计思政元素' WHERE `name` = '课程思政设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '教育行动研究', '行动研究|教学反思|改进', '教育学', '教育学', 4, '用行动研究改进教学实践', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '教育行动研究');
UPDATE `zy_skill` SET `alias` = '行动研究|教学反思|改进', `category_l1` = '教育学', `category_l2` = '教育学', `difficulty` = 4, `description` = '用行动研究改进教学实践' WHERE `name` = '教育行动研究' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '篮球技战术训练', '篮球|技战术|训练', '教育学', '体育学', 3, '组织篮球技战术训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '篮球技战术训练');
UPDATE `zy_skill` SET `alias` = '篮球|技战术|训练', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '组织篮球技战术训练' WHERE `name` = '篮球技战术训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '足球技战术训练', '足球|技战术|训练', '教育学', '体育学', 3, '组织足球技战术训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '足球技战术训练');
UPDATE `zy_skill` SET `alias` = '足球|技战术|训练', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '组织足球技战术训练' WHERE `name` = '足球技战术训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '羽毛球技术指导', '羽毛球|技术|陪练', '教育学', '体育学', 2, '指导羽毛球基本技术与对练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '羽毛球技术指导');
UPDATE `zy_skill` SET `alias` = '羽毛球|技术|陪练', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 2, `description` = '指导羽毛球基本技术与对练' WHERE `name` = '羽毛球技术指导' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '游泳技能训练', '游泳|蛙泳|自由泳|救生', '教育学', '体育学', 3, '教授泳姿与水上安全', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '游泳技能训练');
UPDATE `zy_skill` SET `alias` = '游泳|蛙泳|自由泳|救生', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '教授泳姿与水上安全' WHERE `name` = '游泳技能训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '健身与体能训练', '健身|体能|力量训练|减脂', '教育学', '体育学', 3, '制定并执行体能训练计划', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '健身与体能训练');
UPDATE `zy_skill` SET `alias` = '健身|体能|力量训练|减脂', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '制定并执行体能训练计划' WHERE `name` = '健身与体能训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '运动损伤防护', '运动损伤|拉伸|康复|防护', '教育学', '体育学', 4, '预防与处理常见运动损伤', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '运动损伤防护');
UPDATE `zy_skill` SET `alias` = '运动损伤|拉伸|康复|防护', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 4, `description` = '预防与处理常见运动损伤' WHERE `name` = '运动损伤防护' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '体育赛事组织与裁判', '赛事组织|裁判|规则', '教育学', '体育学', 3, '组织赛事并担任裁判', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '体育赛事组织与裁判');
UPDATE `zy_skill` SET `alias` = '赛事组织|裁判|规则', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '组织赛事并担任裁判' WHERE `name` = '体育赛事组织与裁判' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '乒乓球技术训练', '乒乓球|技术|对练', '教育学', '体育学', 2, '指导乒乓球技术训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '乒乓球技术训练');
UPDATE `zy_skill` SET `alias` = '乒乓球|技术|对练', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 2, `description` = '指导乒乓球技术训练' WHERE `name` = '乒乓球技术训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '排球技战术训练', '排球|技战术|训练', '教育学', '体育学', 3, '组织排球技战术训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '排球技战术训练');
UPDATE `zy_skill` SET `alias` = '排球|技战术|训练', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '组织排球技战术训练' WHERE `name` = '排球技战术训练' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '田径训练与指导', '田径|短跑|跳远|训练', '教育学', '体育学', 3, '指导田径项目训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '田径训练与指导');
UPDATE `zy_skill` SET `alias` = '田径|短跑|跳远|训练', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '指导田径项目训练' WHERE `name` = '田径训练与指导' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '太极拳与传统武术', '太极|武术|套路', '教育学', '体育学', 3, '教授太极拳或传统武术套路', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '太极拳与传统武术');
UPDATE `zy_skill` SET `alias` = '太极|武术|套路', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '教授太极拳或传统武术套路' WHERE `name` = '太极拳与传统武术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '轮滑与滑板教学', '轮滑|滑板|极限运动', '教育学', '体育学', 3, '教授轮滑或滑板基础', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '轮滑与滑板教学');
UPDATE `zy_skill` SET `alias` = '轮滑|滑板|极限运动', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '教授轮滑或滑板基础' WHERE `name` = '轮滑与滑板教学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '体能测试与评估', '体测|体能评估|标准', '教育学', '体育学', 2, '组织体测并评估体能水平', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '体能测试与评估');
UPDATE `zy_skill` SET `alias` = '体测|体能评估|标准', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 2, `description` = '组织体测并评估体能水平' WHERE `name` = '体能测试与评估' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '运动营养指导', '运动营养|补剂|膳食', '教育学', '体育学', 3, '提供运动营养与膳食建议', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '运动营养指导');
UPDATE `zy_skill` SET `alias` = '运动营养|补剂|膳食', `category_l1` = '教育学', `category_l2` = '体育学', `difficulty` = 3, `description` = '提供运动营养与膳食建议' WHERE `name` = '运动营养指导' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '一对一辅导技巧', '一对一|辅导|讲解|提问', '教育学', '教学与培训', 3, '针对个体差异做有效辅导', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '一对一辅导技巧');
UPDATE `zy_skill` SET `alias` = '一对一|辅导|讲解|提问', `category_l1` = '教育学', `category_l2` = '教学与培训', `difficulty` = 3, `description` = '针对个体差异做有效辅导' WHERE `name` = '一对一辅导技巧' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '知识点讲解与拆解', '讲解|拆解|类比|举例', '教育学', '教学与培训', 3, '把复杂知识点讲清楚', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '知识点讲解与拆解');
UPDATE `zy_skill` SET `alias` = '讲解|拆解|类比|举例', `category_l1` = '教育学', `category_l2` = '教学与培训', `difficulty` = 3, `description` = '把复杂知识点讲清楚' WHERE `name` = '知识点讲解与拆解' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '习题设计与讲评', '习题|讲评|错因分析', '教育学', '教学与培训', 3, '设计习题并做讲评', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '习题设计与讲评');
UPDATE `zy_skill` SET `alias` = '习题|讲评|错因分析', `category_l1` = '教育学', `category_l2` = '教学与培训', `difficulty` = 3, `description` = '设计习题并做讲评' WHERE `name` = '习题设计与讲评' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '学习计划制定与监督', '学习计划|监督|打卡', '教育学', '教学与培训', 2, '制定学习计划并跟踪执行', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '学习计划制定与监督');
UPDATE `zy_skill` SET `alias` = '学习计划|监督|打卡', `category_l1` = '教育学', `category_l2` = '教学与培训', `difficulty` = 2, `description` = '制定学习计划并跟踪执行' WHERE `name` = '学习计划制定与监督' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '教学反思与改进', '教学反思|改进|听课', '教育学', '教学与培训', 3, '通过反思持续改进教学', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '教学反思与改进');
UPDATE `zy_skill` SET `alias` = '教学反思|改进|听课', `category_l1` = '教育学', `category_l2` = '教学与培训', `difficulty` = 3, `description` = '通过反思持续改进教学' WHERE `name` = '教学反思与改进' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '培训课件与讲义制作', '培训|讲义|课件', '教育学', '教学与培训', 3, '制作培训课件与讲义', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '培训课件与讲义制作');
UPDATE `zy_skill` SET `alias` = '培训|讲义|课件', `category_l1` = '教育学', `category_l2` = '教学与培训', `difficulty` = 3, `description` = '制作培训课件与讲义' WHERE `name` = '培训课件与讲义制作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '在线教学平台使用', '在线教学|直播课|录播课', '教育学', '教学与培训', 2, '用平台开展线上教学', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '在线教学平台使用');
UPDATE `zy_skill` SET `alias` = '在线教学|直播课|录播课', `category_l1` = '教育学', `category_l2` = '教学与培训', `difficulty` = 2, `description` = '用平台开展线上教学' WHERE `name` = '在线教学平台使用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '解剖学与标本辨识', '解剖|标本|图谱', '医学', '基础医学', 4, '辨识人体结构与标本', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '解剖学与标本辨识');
UPDATE `zy_skill` SET `alias` = '解剖|标本|图谱', `category_l1` = '医学', `category_l2` = '基础医学', `difficulty` = 4, `description` = '辨识人体结构与标本' WHERE `name` = '解剖学与标本辨识' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生理学实验', '生理学|实验|机能', '医学', '基础医学', 4, '完成生理学机能实验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生理学实验');
UPDATE `zy_skill` SET `alias` = '生理学|实验|机能', `category_l1` = '医学', `category_l2` = '基础医学', `difficulty` = 4, `description` = '完成生理学机能实验' WHERE `name` = '生理学实验' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '病理学读片', '病理|读片|切片', '医学', '基础医学', 5, '识别常见病理切片特征', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '病理学读片');
UPDATE `zy_skill` SET `alias` = '病理|读片|切片', `category_l1` = '医学', `category_l2` = '基础医学', `difficulty` = 5, `description` = '识别常见病理切片特征' WHERE `name` = '病理学读片' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '医学统计学', '医学统计|spss|临床统计', '医学', '基础医学', 4, '用统计方法分析临床数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '医学统计学');
UPDATE `zy_skill` SET `alias` = '医学统计|spss|临床统计', `category_l1` = '医学', `category_l2` = '基础医学', `difficulty` = 4, `description` = '用统计方法分析临床数据' WHERE `name` = '医学统计学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '医学文献阅读与循证', '循证医学|文献阅读|meta分析', '医学', '基础医学', 4, '循证方法评价文献', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '医学文献阅读与循证');
UPDATE `zy_skill` SET `alias` = '循证医学|文献阅读|meta分析', `category_l1` = '医学', `category_l2` = '基础医学', `difficulty` = 4, `description` = '循证方法评价文献' WHERE `name` = '医学文献阅读与循证' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '组织胚胎学实验', '组胚|切片|观察', '医学', '基础医学', 4, '完成组织切片制备与观察', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '组织胚胎学实验');
UPDATE `zy_skill` SET `alias` = '组胚|切片|观察', `category_l1` = '医学', `category_l2` = '基础医学', `difficulty` = 4, `description` = '完成组织切片制备与观察' WHERE `name` = '组织胚胎学实验' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '免疫学实验技术', '免疫|elisa|流式', '医学', '基础医学', 5, '完成免疫学检测实验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '免疫学实验技术');
UPDATE `zy_skill` SET `alias` = '免疫|elisa|流式', `category_l1` = '医学', `category_l2` = '基础医学', `difficulty` = 5, `description` = '完成免疫学检测实验' WHERE `name` = '免疫学实验技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生物化学实验', '生化实验|电泳|酶活', '医学', '基础医学', 4, '完成生化指标检测实验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生物化学实验');
UPDATE `zy_skill` SET `alias` = '生化实验|电泳|酶活', `category_l1` = '医学', `category_l2` = '基础医学', `difficulty` = 4, `description` = '完成生化指标检测实验' WHERE `name` = '生物化学实验' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '医学分子生物学', '医学分子|pcr|基因检测', '医学', '基础医学', 5, '完成医学分子检测实验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '医学分子生物学');
UPDATE `zy_skill` SET `alias` = '医学分子|pcr|基因检测', `category_l1` = '医学', `category_l2` = '基础医学', `difficulty` = 5, `description` = '完成医学分子检测实验' WHERE `name` = '医学分子生物学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '病史采集与体格检查', '问诊|查体|病史', '医学', '临床医学', 4, '规范完成病史采集与查体', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '病史采集与体格检查');
UPDATE `zy_skill` SET `alias` = '问诊|查体|病史', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 4, `description` = '规范完成病史采集与查体' WHERE `name` = '病史采集与体格检查' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '临床技能操作', '临床技能|穿刺|缝合|无菌', '医学', '临床医学', 4, '完成常见临床操作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '临床技能操作');
UPDATE `zy_skill` SET `alias` = '临床技能|穿刺|缝合|无菌', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 4, `description` = '完成常见临床操作' WHERE `name` = '临床技能操作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '心电图判读', '心电图|ecg|判读', '医学', '临床医学', 5, '识别常见心电图异常', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '心电图判读');
UPDATE `zy_skill` SET `alias` = '心电图|ecg|判读', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 5, `description` = '识别常见心电图异常' WHERE `name` = '心电图判读' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '病例汇报与讨论', '病例汇报|病例讨论|查房', '医学', '临床医学', 4, '规范汇报病例并参与讨论', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '病例汇报与讨论');
UPDATE `zy_skill` SET `alias` = '病例汇报|病例讨论|查房', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 4, `description` = '规范汇报病例并参与讨论' WHERE `name` = '病例汇报与讨论' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '急救与心肺复苏', '急救|cpr|心肺复苏|aed', '医学', '临床医学', 3, '实施急救与心肺复苏', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '急救与心肺复苏');
UPDATE `zy_skill` SET `alias` = '急救|cpr|心肺复苏|aed', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 3, `description` = '实施急救与心肺复苏' WHERE `name` = '急救与心肺复苏' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '外科基本操作', '外科|缝合|打结|消毒', '医学', '临床医学', 4, '完成外科基本操作训练', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '外科基本操作');
UPDATE `zy_skill` SET `alias` = '外科|缝合|打结|消毒', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 4, `description` = '完成外科基本操作训练' WHERE `name` = '外科基本操作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '内科病例分析', '内科|病例|鉴别诊断', '医学', '临床医学', 4, '分析内科病例并做鉴别诊断', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '内科病例分析');
UPDATE `zy_skill` SET `alias` = '内科|病例|鉴别诊断', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 4, `description` = '分析内科病例并做鉴别诊断' WHERE `name` = '内科病例分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '儿科常见病诊疗', '儿科|常见病|生长发育', '医学', '临床医学', 4, '处理儿科常见疾病', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '儿科常见病诊疗');
UPDATE `zy_skill` SET `alias` = '儿科|常见病|生长发育', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 4, `description` = '处理儿科常见疾病' WHERE `name` = '儿科常见病诊疗' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '妇产科基础技能', '妇产科|产科检查|技能', '医学', '临床医学', 4, '掌握妇产科基本技能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '妇产科基础技能');
UPDATE `zy_skill` SET `alias` = '妇产科|产科检查|技能', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 4, `description` = '掌握妇产科基本技能' WHERE `name` = '妇产科基础技能' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '影像诊断读片', '影像|ct|mri|读片', '医学', '临床医学', 5, '判读 X 线、CT 与 MRI', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '影像诊断读片');
UPDATE `zy_skill` SET `alias` = '影像|ct|mri|读片', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 5, `description` = '判读 X 线、CT 与 MRI' WHERE `name` = '影像诊断读片' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '临床路径与病历书写', '病历|临床路径|规范', '医学', '临床医学', 3, '规范书写病历与临床路径', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '临床路径与病历书写');
UPDATE `zy_skill` SET `alias` = '病历|临床路径|规范', `category_l1` = '医学', `category_l2` = '临床医学', `difficulty` = 3, `description` = '规范书写病历与临床路径' WHERE `name` = '临床路径与病历书写' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '药物分析与检测', '药物分析|hplc|检测', '医学', '药学', 5, '用仪器方法检测药物成分', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '药物分析与检测');
UPDATE `zy_skill` SET `alias` = '药物分析|hplc|检测', `category_l1` = '医学', `category_l2` = '药学', `difficulty` = 5, `description` = '用仪器方法检测药物成分' WHERE `name` = '药物分析与检测' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '药剂学与制剂制备', '药剂|制剂|片剂|缓释', '医学', '药学', 4, '制备常见药物制剂', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '药剂学与制剂制备');
UPDATE `zy_skill` SET `alias` = '药剂|制剂|片剂|缓释', `category_l1` = '医学', `category_l2` = '药学', `difficulty` = 4, `description` = '制备常见药物制剂' WHERE `name` = '药剂学与制剂制备' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '药理学与用药指导', '药理|用药|相互作用', '医学', '药学', 4, '理解药理作用与用药注意事项', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '药理学与用药指导');
UPDATE `zy_skill` SET `alias` = '药理|用药|相互作用', `category_l1` = '医学', `category_l2` = '药学', `difficulty` = 4, `description` = '理解药理作用与用药注意事项' WHERE `name` = '药理学与用药指导' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '临床用药监护', '临床药学|用药监护|处方审核', '医学', '药学', 4, '审核处方并做用药监护', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '临床用药监护');
UPDATE `zy_skill` SET `alias` = '临床药学|用药监护|处方审核', `category_l1` = '医学', `category_l2` = '药学', `difficulty` = 4, `description` = '审核处方并做用药监护' WHERE `name` = '临床用药监护' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '中药鉴定与炮制', '中药|鉴定|炮制', '医学', '药学', 4, '鉴定中药材并完成炮制', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '中药鉴定与炮制');
UPDATE `zy_skill` SET `alias` = '中药|鉴定|炮制', `category_l1` = '医学', `category_l2` = '药学', `difficulty` = 4, `description` = '鉴定中药材并完成炮制' WHERE `name` = '中药鉴定与炮制' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '药物合成与工艺', '药物合成|工艺|中间体', '医学', '药学', 5, '设计药物合成路线', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '药物合成与工艺');
UPDATE `zy_skill` SET `alias` = '药物合成|工艺|中间体', `category_l1` = '医学', `category_l2` = '药学', `difficulty` = 5, `description` = '设计药物合成路线' WHERE `name` = '药物合成与工艺' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '药事管理与法规', '药事管理|gmp|法规', '医学', '药学', 3, '掌握药品管理法规要求', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '药事管理与法规');
UPDATE `zy_skill` SET `alias` = '药事管理|gmp|法规', `category_l1` = '医学', `category_l2` = '药学', `difficulty` = 3, `description` = '掌握药品管理法规要求' WHERE `name` = '药事管理与法规' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生物药剂学与药动学', '药动学|pk|生物利用度', '医学', '药学', 5, '分析药物体内过程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生物药剂学与药动学');
UPDATE `zy_skill` SET `alias` = '药动学|pk|生物利用度', `category_l1` = '医学', `category_l2` = '药学', `difficulty` = 5, `description` = '分析药物体内过程' WHERE `name` = '生物药剂学与药动学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '流行病学调查', '流行病|流调|队列研究', '医学', '公共卫生与预防医学', 4, '设计并实施流行病学调查', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '流行病学调查');
UPDATE `zy_skill` SET `alias` = '流行病|流调|队列研究', `category_l1` = '医学', `category_l2` = '公共卫生与预防医学', `difficulty` = 4, `description` = '设计并实施流行病学调查' WHERE `name` = '流行病学调查' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '健康教育与促进', '健康教育|科普|健康促进', '医学', '公共卫生与预防医学', 3, '设计并实施健康教育活动', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '健康教育与促进');
UPDATE `zy_skill` SET `alias` = '健康教育|科普|健康促进', `category_l1` = '医学', `category_l2` = '公共卫生与预防医学', `difficulty` = 3, `description` = '设计并实施健康教育活动' WHERE `name` = '健康教育与促进' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '卫生统计与spss', '卫生统计|数据分析|spss', '医学', '公共卫生与预防医学', 4, '分析卫生统计数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '卫生统计与spss');
UPDATE `zy_skill` SET `alias` = '卫生统计|数据分析|spss', `category_l1` = '医学', `category_l2` = '公共卫生与预防医学', `difficulty` = 4, `description` = '分析卫生统计数据' WHERE `name` = '卫生统计与spss' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '食品安全与检测', '食品安全|检测|卫生标准', '医学', '公共卫生与预防医学', 3, '开展食品安全检测与评价', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '食品安全与检测');
UPDATE `zy_skill` SET `alias` = '食品安全|检测|卫生标准', `category_l1` = '医学', `category_l2` = '公共卫生与预防医学', `difficulty` = 3, `description` = '开展食品安全检测与评价' WHERE `name` = '食品安全与检测' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '卫生检验与检疫', '卫生检验|检疫|理化检验', '医学', '公共卫生与预防医学', 4, '完成卫生理化与微生物检验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '卫生检验与检疫');
UPDATE `zy_skill` SET `alias` = '卫生检验|检疫|理化检验', `category_l1` = '医学', `category_l2` = '公共卫生与预防医学', `difficulty` = 4, `description` = '完成卫生理化与微生物检验' WHERE `name` = '卫生检验与检疫' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '职业卫生与评价', '职业卫生|职业病|检测', '医学', '公共卫生与预防医学', 4, '评估职业危害因素', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '职业卫生与评价');
UPDATE `zy_skill` SET `alias` = '职业卫生|职业病|检测', `category_l1` = '医学', `category_l2` = '公共卫生与预防医学', `difficulty` = 4, `description` = '评估职业危害因素' WHERE `name` = '职业卫生与评价' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '营养与食品卫生', '营养|膳食调查|食品卫生', '医学', '公共卫生与预防医学', 3, '开展营养调查与指导', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '营养与食品卫生');
UPDATE `zy_skill` SET `alias` = '营养|膳食调查|食品卫生', `category_l1` = '医学', `category_l2` = '公共卫生与预防医学', `difficulty` = 3, `description` = '开展营养调查与指导' WHERE `name` = '营养与食品卫生' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '突发公共卫生事件处置', '突发公卫|应急|处置', '医学', '公共卫生与预防医学', 4, '参与突发公共卫生事件处置', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '突发公共卫生事件处置');
UPDATE `zy_skill` SET `alias` = '突发公卫|应急|处置', `category_l1` = '医学', `category_l2` = '公共卫生与预防医学', `difficulty` = 4, `description` = '参与突发公共卫生事件处置' WHERE `name` = '突发公共卫生事件处置' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '基础护理操作', '护理|无菌|输液|操作', '医学', '护理学', 3, '完成基础护理操作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '基础护理操作');
UPDATE `zy_skill` SET `alias` = '护理|无菌|输液|操作', `category_l1` = '医学', `category_l2` = '护理学', `difficulty` = 3, `description` = '完成基础护理操作' WHERE `name` = '基础护理操作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '急救护理', '急救护理|cpr|除颤', '医学', '护理学', 4, '实施急救护理措施', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '急救护理');
UPDATE `zy_skill` SET `alias` = '急救护理|cpr|除颤', `category_l1` = '医学', `category_l2` = '护理学', `difficulty` = 4, `description` = '实施急救护理措施' WHERE `name` = '急救护理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '老年护理', '老年护理|照护|评估', '医学', '护理学', 3, '提供老年照护与评估', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '老年护理');
UPDATE `zy_skill` SET `alias` = '老年护理|照护|评估', `category_l1` = '医学', `category_l2` = '护理学', `difficulty` = 3, `description` = '提供老年照护与评估' WHERE `name` = '老年护理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '心理护理与沟通', '心理护理|沟通|共情', '医学', '护理学', 3, '实施心理护理与护患沟通', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '心理护理与沟通');
UPDATE `zy_skill` SET `alias` = '心理护理|沟通|共情', `category_l1` = '医学', `category_l2` = '护理学', `difficulty` = 3, `description` = '实施心理护理与护患沟通' WHERE `name` = '心理护理与沟通' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '护理文书书写', '护理文书|记录|规范', '医学', '护理学', 2, '规范书写护理文书', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '护理文书书写');
UPDATE `zy_skill` SET `alias` = '护理文书|记录|规范', `category_l1` = '医学', `category_l2` = '护理学', `difficulty` = 2, `description` = '规范书写护理文书' WHERE `name` = '护理文书书写' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '医患沟通技巧', '医患沟通|告知|共情', '医学', '临床与应用', 3, '与患者及家属有效沟通', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '医患沟通技巧');
UPDATE `zy_skill` SET `alias` = '医患沟通|告知|共情', `category_l1` = '医学', `category_l2` = '临床与应用', `difficulty` = 3, `description` = '与患者及家属有效沟通' WHERE `name` = '医患沟通技巧' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '医学文献检索与综述', '医学检索|pubmed|综述', '医学', '临床与应用', 4, '检索医学文献并撰写综述', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '医学文献检索与综述');
UPDATE `zy_skill` SET `alias` = '医学检索|pubmed|综述', `category_l1` = '医学', `category_l2` = '临床与应用', `difficulty` = 4, `description` = '检索医学文献并撰写综述' WHERE `name` = '医学文献检索与综述' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '临床数据分析', '临床数据|spss|统计', '医学', '临床与应用', 4, '分析临床研究数据', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '临床数据分析');
UPDATE `zy_skill` SET `alias` = '临床数据|spss|统计', `category_l1` = '医学', `category_l2` = '临床与应用', `difficulty` = 4, `description` = '分析临床研究数据' WHERE `name` = '临床数据分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '医学术语与英文文献', '医学术语|医学英语|文献', '医学', '临床与应用', 4, '掌握医学术语并读英文文献', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '医学术语与英文文献');
UPDATE `zy_skill` SET `alias` = '医学术语|医学英语|文献', `category_l1` = '医学', `category_l2` = '临床与应用', `difficulty` = 4, `description` = '掌握医学术语并读英文文献' WHERE `name` = '医学术语与英文文献' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '健康科普内容创作', '健康科普|科普写作|短视频', '医学', '临床与应用', 3, '创作面向大众的健康科普内容', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '健康科普内容创作');
UPDATE `zy_skill` SET `alias` = '健康科普|科普写作|短视频', `category_l1` = '医学', `category_l2` = '临床与应用', `difficulty` = 3, `description` = '创作面向大众的健康科普内容' WHERE `name` = '健康科普内容创作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '急救技能普及培训', '急救培训|普及|cpr教学', '医学', '临床与应用', 3, '面向非专业人员开展急救培训', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '急救技能普及培训');
UPDATE `zy_skill` SET `alias` = '急救培训|普及|cpr教学', `category_l1` = '医学', `category_l2` = '临床与应用', `difficulty` = 3, `description` = '面向非专业人员开展急救培训' WHERE `name` = '急救技能普及培训' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '作物栽培与田间管理', '作物栽培|田间管理|农艺', '农学', '农学', 3, '完成作物栽培与田间管理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '作物栽培与田间管理');
UPDATE `zy_skill` SET `alias` = '作物栽培|田间管理|农艺', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 3, `description` = '完成作物栽培与田间管理' WHERE `name` = '作物栽培与田间管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '土壤分析与改良', '土壤|土壤分析|改良|施肥', '农学', '农学', 4, '分析土壤性质并制定改良方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '土壤分析与改良');
UPDATE `zy_skill` SET `alias` = '土壤|土壤分析|改良|施肥', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 4, `description` = '分析土壤性质并制定改良方案' WHERE `name` = '土壤分析与改良' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '植物病虫害识别与防治', '病虫害|防治|植保', '农学', '农学', 4, '识别病虫害并制定防治方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '植物病虫害识别与防治');
UPDATE `zy_skill` SET `alias` = '病虫害|防治|植保', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 4, `description` = '识别病虫害并制定防治方案' WHERE `name` = '植物病虫害识别与防治' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '育种与分子标记', '育种|分子标记|杂交', '农学', '农学', 5, '开展品种选育与分子标记辅助选择', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '育种与分子标记');
UPDATE `zy_skill` SET `alias` = '育种|分子标记|杂交', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 5, `description` = '开展品种选育与分子标记辅助选择' WHERE `name` = '育种与分子标记' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农业遥感与估产', '农业遥感|估产|长势监测', '农学', '农学', 4, '用遥感监测作物长势并估产', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农业遥感与估产');
UPDATE `zy_skill` SET `alias` = '农业遥感|估产|长势监测', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 4, `description` = '用遥感监测作物长势并估产' WHERE `name` = '农业遥感与估产' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '作物育种与良种繁育', '育种|良种|繁育', '农学', '农学', 4, '开展作物育种与良种繁育', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '作物育种与良种繁育');
UPDATE `zy_skill` SET `alias` = '育种|良种|繁育', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 4, `description` = '开展作物育种与良种繁育' WHERE `name` = '作物育种与良种繁育' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农业气象与灾害防御', '农业气象|灾害|防御', '农学', '农学', 4, '分析农业气象条件与防灾', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农业气象与灾害防御');
UPDATE `zy_skill` SET `alias` = '农业气象|灾害|防御', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 4, `description` = '分析农业气象条件与防灾' WHERE `name` = '农业气象与灾害防御' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '节水灌溉技术', '节水灌溉|滴灌|喷灌', '农学', '农学', 3, '设计节水灌溉方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '节水灌溉技术');
UPDATE `zy_skill` SET `alias` = '节水灌溉|滴灌|喷灌', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 3, `description` = '设计节水灌溉方案' WHERE `name` = '节水灌溉技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农产品贮藏与加工', '贮藏|保鲜|加工', '农学', '农学', 3, '完成农产品贮藏与初加工', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农产品贮藏与加工');
UPDATE `zy_skill` SET `alias` = '贮藏|保鲜|加工', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 3, `description` = '完成农产品贮藏与初加工' WHERE `name` = '农产品贮藏与加工' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农业机械化作业', '农机|作业|维护', '农学', '农学', 3, '操作与维护农业机械', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农业机械化作业');
UPDATE `zy_skill` SET `alias` = '农机|作业|维护', `category_l1` = '农学', `category_l2` = '农学', `difficulty` = 3, `description` = '操作与维护农业机械' WHERE `name` = '农业机械化作业' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '森林资源调查', '森林调查|样地|蓄积量', '农学', '林学', 4, '开展森林资源抽样调查', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '森林资源调查');
UPDATE `zy_skill` SET `alias` = '森林调查|样地|蓄积量', `category_l1` = '农学', `category_l2` = '林学', `difficulty` = 4, `description` = '开展森林资源抽样调查' WHERE `name` = '森林资源调查' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '园林景观设计', '园林|景观设计|植物配置', '农学', '林学', 4, '完成园林景观方案设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '园林景观设计');
UPDATE `zy_skill` SET `alias` = '园林|景观设计|植物配置', `category_l1` = '农学', `category_l2` = '林学', `difficulty` = 4, `description` = '完成园林景观方案设计' WHERE `name` = '园林景观设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '苗木繁育与养护', '苗木|繁育|嫁接|养护', '农学', '林学', 3, '完成苗木繁育与日常养护', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '苗木繁育与养护');
UPDATE `zy_skill` SET `alias` = '苗木|繁育|嫁接|养护', `category_l1` = '农学', `category_l2` = '林学', `difficulty` = 3, `description` = '完成苗木繁育与日常养护' WHERE `name` = '苗木繁育与养护' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '森林生态与碳汇', '森林生态|碳汇|碳储量', '农学', '林学', 5, '评估森林碳汇与生态功能', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '森林生态与碳汇');
UPDATE `zy_skill` SET `alias` = '森林生态|碳汇|碳储量', `category_l1` = '农学', `category_l2` = '林学', `difficulty` = 5, `description` = '评估森林碳汇与生态功能' WHERE `name` = '森林生态与碳汇' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '森林病虫害防治', '森林病虫害|防治|检疫', '农学', '林学', 4, '防治森林病虫害', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '森林病虫害防治');
UPDATE `zy_skill` SET `alias` = '森林病虫害|防治|检疫', `category_l1` = '农学', `category_l2` = '林学', `difficulty` = 4, `description` = '防治森林病虫害' WHERE `name` = '森林病虫害防治' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '经济林栽培', '经济林|果树|栽培', '农学', '林学', 3, '开展经济林栽培管理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '经济林栽培');
UPDATE `zy_skill` SET `alias` = '经济林|果树|栽培', `category_l1` = '农学', `category_l2` = '林学', `difficulty` = 3, `description` = '开展经济林栽培管理' WHERE `name` = '经济林栽培' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '园林植物造景', '植物造景|配置|季相', '农学', '林学', 4, '用植物营造景观效果', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '园林植物造景');
UPDATE `zy_skill` SET `alias` = '植物造景|配置|季相', `category_l1` = '农学', `category_l2` = '林学', `difficulty` = 4, `description` = '用植物营造景观效果' WHERE `name` = '园林植物造景' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '自然保护区管理', '自然保护|生态监测|管理', '农学', '林学', 4, '参与自然保护地管理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '自然保护区管理');
UPDATE `zy_skill` SET `alias` = '自然保护|生态监测|管理', `category_l1` = '农学', `category_l2` = '林学', `difficulty` = 4, `description` = '参与自然保护地管理' WHERE `name` = '自然保护区管理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '食品加工工艺', '食品加工|工艺|烘焙|发酵', '农学', '食品科学与工程', 3, '设计并执行食品加工工艺', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '食品加工工艺');
UPDATE `zy_skill` SET `alias` = '食品加工|工艺|烘焙|发酵', `category_l1` = '农学', `category_l2` = '食品科学与工程', `difficulty` = 3, `description` = '设计并执行食品加工工艺' WHERE `name` = '食品加工工艺' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '食品微生物检验', '微生物检验|菌落总数|大肠菌群', '农学', '食品科学与工程', 4, '完成食品微生物指标检验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '食品微生物检验');
UPDATE `zy_skill` SET `alias` = '微生物检验|菌落总数|大肠菌群', `category_l1` = '农学', `category_l2` = '食品科学与工程', `difficulty` = 4, `description` = '完成食品微生物指标检验' WHERE `name` = '食品微生物检验' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '感官评价与品评', '感官评价|品评|风味', '农学', '食品科学与工程', 3, '组织食品感官评价实验', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '感官评价与品评');
UPDATE `zy_skill` SET `alias` = '感官评价|品评|风味', `category_l1` = '农学', `category_l2` = '食品科学与工程', `difficulty` = 3, `description` = '组织食品感官评价实验' WHERE `name` = '感官评价与品评' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '食品营养与配方设计', '营养|配方|功能性食品', '农学', '食品科学与工程', 4, '设计符合营养要求的配方', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '食品营养与配方设计');
UPDATE `zy_skill` SET `alias` = '营养|配方|功能性食品', `category_l1` = '农学', `category_l2` = '食品科学与工程', `difficulty` = 4, `description` = '设计符合营养要求的配方' WHERE `name` = '食品营养与配方设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '食品工程原理', '食品工程|传热|干燥', '农学', '食品科学与工程', 4, '分析食品加工单元操作', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '食品工程原理');
UPDATE `zy_skill` SET `alias` = '食品工程|传热|干燥', `category_l1` = '农学', `category_l2` = '食品科学与工程', `difficulty` = 4, `description` = '分析食品加工单元操作' WHERE `name` = '食品工程原理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '食品添加剂应用', '食品添加剂|配方|标准', '农学', '食品科学与工程', 3, '按标准使用食品添加剂', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '食品添加剂应用');
UPDATE `zy_skill` SET `alias` = '食品添加剂|配方|标准', `category_l1` = '农学', `category_l2` = '食品科学与工程', `difficulty` = 3, `description` = '按标准使用食品添加剂' WHERE `name` = '食品添加剂应用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '粮油加工技术', '粮油|制粉|榨油', '农学', '食品科学与工程', 4, '完成粮油加工工艺设计', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '粮油加工技术');
UPDATE `zy_skill` SET `alias` = '粮油|制粉|榨油', `category_l1` = '农学', `category_l2` = '食品科学与工程', `difficulty` = 4, `description` = '完成粮油加工工艺设计' WHERE `name` = '粮油加工技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '乳品与饮料工艺', '乳品|饮料|工艺', '农学', '食品科学与工程', 4, '设计乳品或饮料工艺', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '乳品与饮料工艺');
UPDATE `zy_skill` SET `alias` = '乳品|饮料|工艺', `category_l1` = '农学', `category_l2` = '食品科学与工程', `difficulty` = 4, `description` = '设计乳品或饮料工艺' WHERE `name` = '乳品与饮料工艺' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '食品法规与标准', '食品法规|国标|标签', '农学', '食品科学与工程', 3, '掌握食品标签与法规要求', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '食品法规与标准');
UPDATE `zy_skill` SET `alias` = '食品法规|国标|标签', `category_l1` = '农学', `category_l2` = '食品科学与工程', `difficulty` = 3, `description` = '掌握食品标签与法规要求' WHERE `name` = '食品法规与标准' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农业昆虫与防治', '农业昆虫|害虫|防治', '农学', '植物保护', 4, '识别害虫并制定防治方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农业昆虫与防治');
UPDATE `zy_skill` SET `alias` = '农业昆虫|害虫|防治', `category_l1` = '农学', `category_l2` = '植物保护', `difficulty` = 4, `description` = '识别害虫并制定防治方案' WHERE `name` = '农业昆虫与防治' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '植物病理与诊断', '植物病理|病害|诊断', '农学', '植物保护', 4, '诊断植物病害并提出方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '植物病理与诊断');
UPDATE `zy_skill` SET `alias` = '植物病理|病害|诊断', `category_l1` = '农学', `category_l2` = '植物保护', `difficulty` = 4, `description` = '诊断植物病害并提出方案' WHERE `name` = '植物病理与诊断' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农药使用与安全', '农药|配比|安全间隔', '农学', '植物保护', 3, '安全使用农药并控制残留', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农药使用与安全');
UPDATE `zy_skill` SET `alias` = '农药|配比|安全间隔', `category_l1` = '农学', `category_l2` = '植物保护', `difficulty` = 3, `description` = '安全使用农药并控制残留' WHERE `name` = '农药使用与安全' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '生物防治技术', '生物防治|天敌|微生物农药', '农学', '植物保护', 4, '应用生物防治手段', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '生物防治技术');
UPDATE `zy_skill` SET `alias` = '生物防治|天敌|微生物农药', `category_l1` = '农学', `category_l2` = '植物保护', `difficulty` = 4, `description` = '应用生物防治手段' WHERE `name` = '生物防治技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农业技术推广', '农技推广|培训|示范', '农学', '农业实践与乡村振兴', 3, '向农户推广农业技术', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农业技术推广');
UPDATE `zy_skill` SET `alias` = '农技推广|培训|示范', `category_l1` = '农学', `category_l2` = '农业实践与乡村振兴', `difficulty` = 3, `description` = '向农户推广农业技术' WHERE `name` = '农业技术推广' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农产品品牌与电商', '农产品|品牌|直播带货', '农学', '农业实践与乡村振兴', 3, '打造农产品品牌并做电商', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农产品品牌与电商');
UPDATE `zy_skill` SET `alias` = '农产品|品牌|直播带货', `category_l1` = '农学', `category_l2` = '农业实践与乡村振兴', `difficulty` = 3, `description` = '打造农产品品牌并做电商' WHERE `name` = '农产品品牌与电商' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '休闲农业与乡村旅游', '休闲农业|乡村旅游|规划', '农学', '农业实践与乡村振兴', 4, '规划休闲农业与乡村旅游项目', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '休闲农业与乡村旅游');
UPDATE `zy_skill` SET `alias` = '休闲农业|乡村旅游|规划', `category_l1` = '农学', `category_l2` = '农业实践与乡村振兴', `difficulty` = 4, `description` = '规划休闲农业与乡村旅游项目' WHERE `name` = '休闲农业与乡村旅游' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农村调研与社会实践', '农村调研|社会实践|入户', '农学', '农业实践与乡村振兴', 3, '开展农村入户调研', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农村调研与社会实践');
UPDATE `zy_skill` SET `alias` = '农村调研|社会实践|入户', `category_l1` = '农学', `category_l2` = '农业实践与乡村振兴', `difficulty` = 3, `description` = '开展农村入户调研' WHERE `name` = '农村调研与社会实践' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '农业政策与补贴申报', '农业政策|补贴|项目申报', '农学', '农业实践与乡村振兴', 3, '了解农业政策并申报项目', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '农业政策与补贴申报');
UPDATE `zy_skill` SET `alias` = '农业政策|补贴|项目申报', `category_l1` = '农学', `category_l2` = '农业实践与乡村振兴', `difficulty` = 3, `description` = '了解农业政策并申报项目' WHERE `name` = '农业政策与补贴申报' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '史料整理与考据', '史料|考据|文献整理', '历史学', '历史学', 4, '整理史料并做考证辨析', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '史料整理与考据');
UPDATE `zy_skill` SET `alias` = '史料|考据|文献整理', `category_l1` = '历史学', `category_l2` = '历史学', `difficulty` = 4, `description` = '整理史料并做考证辨析' WHERE `name` = '史料整理与考据' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '口述史采访与整理', '口述史|采访|录音整理', '历史学', '历史学', 3, '开展口述访谈并整理成文', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '口述史采访与整理');
UPDATE `zy_skill` SET `alias` = '口述史|采访|录音整理', `category_l1` = '历史学', `category_l2` = '历史学', `difficulty` = 3, `description` = '开展口述访谈并整理成文' WHERE `name` = '口述史采访与整理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '地方志与族谱研究', '地方志|族谱|方志', '历史学', '历史学', 4, '利用地方文献开展区域研究', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '地方志与族谱研究');
UPDATE `zy_skill` SET `alias` = '地方志|族谱|方志', `category_l1` = '历史学', `category_l2` = '历史学', `difficulty` = 4, `description` = '利用地方文献开展区域研究' WHERE `name` = '地方志与族谱研究' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '历史地理与地图解读', '历史地理|古地图|沿革', '历史学', '历史学', 4, '解读历史地图与地理沿革', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '历史地理与地图解读');
UPDATE `zy_skill` SET `alias` = '历史地理|古地图|沿革', `category_l1` = '历史学', `category_l2` = '历史学', `difficulty` = 4, `description` = '解读历史地图与地理沿革' WHERE `name` = '历史地理与地图解读' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '中国近代史研究', '近代史|晚清|民国', '历史学', '历史学', 4, '研究中国近代历史进程', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '中国近代史研究');
UPDATE `zy_skill` SET `alias` = '近代史|晚清|民国', `category_l1` = '历史学', `category_l2` = '历史学', `difficulty` = 4, `description` = '研究中国近代历史进程' WHERE `name` = '中国近代史研究' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '世界史与全球史', '世界史|全球史|文明', '历史学', '历史学', 4, '研究世界历史与文明交往', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '世界史与全球史');
UPDATE `zy_skill` SET `alias` = '世界史|全球史|文明', `category_l1` = '历史学', `category_l2` = '历史学', `difficulty` = 4, `description` = '研究世界历史与文明交往' WHERE `name` = '世界史与全球史' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '史学理论与方法', '史学理论|史料学|方法论', '历史学', '历史学', 5, '掌握史学研究方法', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '史学理论与方法');
UPDATE `zy_skill` SET `alias` = '史学理论|史料学|方法论', `category_l1` = '历史学', `category_l2` = '历史学', `difficulty` = 5, `description` = '掌握史学研究方法' WHERE `name` = '史学理论与方法' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '历史文献数字化', '文献数字化|数据库|检索', '历史学', '历史学', 3, '建设历史文献数据库', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '历史文献数字化');
UPDATE `zy_skill` SET `alias` = '文献数字化|数据库|检索', `category_l1` = '历史学', `category_l2` = '历史学', `difficulty` = 3, `description` = '建设历史文献数据库' WHERE `name` = '历史文献数字化' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '文物鉴赏与断代', '文物|鉴赏|断代', '历史学', '历史学', 5, '鉴赏文物并判断年代', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '文物鉴赏与断代');
UPDATE `zy_skill` SET `alias` = '文物|鉴赏|断代', `category_l1` = '历史学', `category_l2` = '历史学', `difficulty` = 5, `description` = '鉴赏文物并判断年代' WHERE `name` = '文物鉴赏与断代' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '田野考古发掘', '田野考古|发掘|探方|地层', '历史学', '考古学', 5, '按规范开展田野发掘与记录', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '田野考古发掘');
UPDATE `zy_skill` SET `alias` = '田野考古|发掘|探方|地层', `category_l1` = '历史学', `category_l2` = '考古学', `difficulty` = 5, `description` = '按规范开展田野发掘与记录' WHERE `name` = '田野考古发掘' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '文物修复与保护', '文物修复|保护|脱盐', '历史学', '考古学', 5, '对文物进行修复与预防性保护', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '文物修复与保护');
UPDATE `zy_skill` SET `alias` = '文物修复|保护|脱盐', `category_l1` = '历史学', `category_l2` = '考古学', `difficulty` = 5, `description` = '对文物进行修复与预防性保护' WHERE `name` = '文物修复与保护' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '器物描述与类型学', '器物|类型学|断代', '历史学', '考古学', 4, '对器物做类型学分析与断代', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '器物描述与类型学');
UPDATE `zy_skill` SET `alias` = '器物|类型学|断代', `category_l1` = '历史学', `category_l2` = '考古学', `difficulty` = 4, `description` = '对器物做类型学分析与断代' WHERE `name` = '器物描述与类型学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '考古绘图与摄影', '考古绘图|器物图|摄影', '历史学', '考古学', 4, '完成考古绘图与记录摄影', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '考古绘图与摄影');
UPDATE `zy_skill` SET `alias` = '考古绘图|器物图|摄影', `category_l1` = '历史学', `category_l2` = '考古学', `difficulty` = 4, `description` = '完成考古绘图与记录摄影' WHERE `name` = '考古绘图与摄影' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '遗址调查与勘探', '遗址调查|勘探|钻探', '历史学', '考古学', 5, '开展遗址调查与勘探', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '遗址调查与勘探');
UPDATE `zy_skill` SET `alias` = '遗址调查|勘探|钻探', `category_l1` = '历史学', `category_l2` = '考古学', `difficulty` = 5, `description` = '开展遗址调查与勘探' WHERE `name` = '遗址调查与勘探' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '博物馆展陈设计', '博物馆|展陈|陈列', '历史学', '考古学', 4, '设计博物馆陈列方案', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '博物馆展陈设计');
UPDATE `zy_skill` SET `alias` = '博物馆|展陈|陈列', `category_l1` = '历史学', `category_l2` = '考古学', `difficulty` = 4, `description` = '设计博物馆陈列方案' WHERE `name` = '博物馆展陈设计' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '文物保护技术', '文物保护|加固|环境控制', '历史学', '考古学', 5, '实施文物保护技术措施', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '文物保护技术');
UPDATE `zy_skill` SET `alias` = '文物保护|加固|环境控制', `category_l1` = '历史学', `category_l2` = '考古学', `difficulty` = 5, `description` = '实施文物保护技术措施' WHERE `name` = '文物保护技术' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '文化遗产保护与利用', '文化遗产|保护|活化', '历史学', '文化遗产与传播', 4, '参与文化遗产保护与活化利用', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '文化遗产保护与利用');
UPDATE `zy_skill` SET `alias` = '文化遗产|保护|活化', `category_l1` = '历史学', `category_l2` = '文化遗产与传播', `difficulty` = 4, `description` = '参与文化遗产保护与活化利用' WHERE `name` = '文化遗产保护与利用' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '历史科普内容创作', '历史科普|短视频|公众号', '历史学', '文化遗产与传播', 3, '创作面向大众的历史科普内容', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '历史科普内容创作');
UPDATE `zy_skill` SET `alias` = '历史科普|短视频|公众号', `category_l1` = '历史学', `category_l2` = '文化遗产与传播', `difficulty` = 3, `description` = '创作面向大众的历史科普内容' WHERE `name` = '历史科普内容创作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '红色文化资源整理', '红色文化|史料整理|宣讲', '历史学', '文化遗产与传播', 3, '整理红色文化资源并宣讲', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '红色文化资源整理');
UPDATE `zy_skill` SET `alias` = '红色文化|史料整理|宣讲', `category_l1` = '历史学', `category_l2` = '文化遗产与传播', `difficulty` = 3, `description` = '整理红色文化资源并宣讲' WHERE `name` = '红色文化资源整理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '口述历史与纪录片', '口述史|纪录片|采访', '历史学', '文化遗产与传播', 4, '用影像记录口述历史', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '口述历史与纪录片');
UPDATE `zy_skill` SET `alias` = '口述史|纪录片|采访', `category_l1` = '历史学', `category_l2` = '文化遗产与传播', `difficulty` = 4, `description` = '用影像记录口述历史' WHERE `name` = '口述历史与纪录片' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '哲学论文写作', '哲学论文|论证|思辨', '哲学', '哲学', 4, '撰写结构严谨的哲学论证文章', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '哲学论文写作');
UPDATE `zy_skill` SET `alias` = '哲学论文|论证|思辨', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 4, `description` = '撰写结构严谨的哲学论证文章' WHERE `name` = '哲学论文写作' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '逻辑学与论证分析', '逻辑|论证|谬误|推理', '哲学', '哲学', 3, '识别论证结构并分析逻辑谬误', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '逻辑学与论证分析');
UPDATE `zy_skill` SET `alias` = '逻辑|论证|谬误|推理', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 3, `description` = '识别论证结构并分析逻辑谬误' WHERE `name` = '逻辑学与论证分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '伦理学与案例分析', '伦理学|道德|案例', '哲学', '哲学', 3, '用伦理学框架分析现实案例', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '伦理学与案例分析');
UPDATE `zy_skill` SET `alias` = '伦理学|道德|案例', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 3, `description` = '用伦理学框架分析现实案例' WHERE `name` = '伦理学与案例分析' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '科技哲学与伦理', '科技哲学|技术伦理|ai伦理', '哲学', '哲学', 4, '分析科技发展带来的伦理问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '科技哲学与伦理');
UPDATE `zy_skill` SET `alias` = '科技哲学|技术伦理|ai伦理', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 4, `description` = '分析科技发展带来的伦理问题' WHERE `name` = '科技哲学与伦理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '中西哲学史', '哲学史|西方哲学|中国哲学', '哲学', '哲学', 4, '梳理中西哲学发展脉络', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '中西哲学史');
UPDATE `zy_skill` SET `alias` = '哲学史|西方哲学|中国哲学', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 4, `description` = '梳理中西哲学发展脉络' WHERE `name` = '中西哲学史' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '马克思主义哲学原理', '马哲|唯物|辩证法', '哲学', '哲学', 3, '掌握马克思主义哲学基本原理', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '马克思主义哲学原理');
UPDATE `zy_skill` SET `alias` = '马哲|唯物|辩证法', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 3, `description` = '掌握马克思主义哲学基本原理' WHERE `name` = '马克思主义哲学原理' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '中国哲学与儒家思想', '中国哲学|儒家|道家', '哲学', '哲学', 4, '理解中国传统哲学思想', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '中国哲学与儒家思想');
UPDATE `zy_skill` SET `alias` = '中国哲学|儒家|道家', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 4, `description` = '理解中国传统哲学思想' WHERE `name` = '中国哲学与儒家思想' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '西方哲学与德国古典', '西方哲学|康德|黑格尔', '哲学', '哲学', 5, '研读西方哲学经典', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '西方哲学与德国古典');
UPDATE `zy_skill` SET `alias` = '西方哲学|康德|黑格尔', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 5, `description` = '研读西方哲学经典' WHERE `name` = '西方哲学与德国古典' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '美学与艺术哲学', '美学|艺术哲学|审美', '哲学', '哲学', 4, '从哲学角度分析审美问题', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '美学与艺术哲学');
UPDATE `zy_skill` SET `alias` = '美学|艺术哲学|审美', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 4, `description` = '从哲学角度分析审美问题' WHERE `name` = '美学与艺术哲学' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '宗教学基础', '宗教|宗教史|比较宗教', '哲学', '哲学', 4, '理解宗教现象与比较研究', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '宗教学基础');
UPDATE `zy_skill` SET `alias` = '宗教|宗教史|比较宗教', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 4, `description` = '理解宗教现象与比较研究' WHERE `name` = '宗教学基础' AND `status` = 1;
INSERT INTO `zy_skill` (`name`, `alias`, `category_l1`, `category_l2`, `difficulty`, `description`, `hot_score`, `status`)
SELECT '批判性思维训练', '批判性思维|论证|质疑', '哲学', '哲学', 3, '训练批判性思维与论证能力', 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `zy_skill` WHERE `name` = '批判性思维训练');
UPDATE `zy_skill` SET `alias` = '批判性思维|论证|质疑', `category_l1` = '哲学', `category_l2` = '哲学', `difficulty` = 3, `description` = '训练批判性思维与论证能力' WHERE `name` = '批判性思维训练' AND `status` = 1;

-- -----------------------------------------------------------------------------
-- 统计：技能 784 条 / 二级学科 62 个 / 门类 12 个
-- -----------------------------------------------------------------------------
SELECT COUNT(*) AS 技能总数, COUNT(DISTINCT category_l2) AS 二级学科数,
       COUNT(DISTINCT category_l1) AS 门类数 FROM `zy_skill` WHERE `status` = 1;
