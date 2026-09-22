# scripts/ 运维脚本说明

> 本目录存放**运行期运维脚本**，与产品代码分开，避免和 `backend/` `frontend/` 的构建流程混淆。
> 最后更新：2026-09-22

---

## 零、`start-all.ps1` —— 一键启动（推荐入口）

### 为什么要它

三个服务（NLP、后端、前端）原先必须手工开三个终端分别启动，而**漏掉一个的后果是静默且误导的**：
NLP 没起时，解析接口照样返回 HTTP 200，但命中 0 条，还提示「未匹配到标准化标签，可尝试补充更具体的技能描述」——
把服务没开的问题说成用户的描述不够具体。网站看起来一切正常。

这个脚本按依赖顺序启动、逐个验证健康、并且**只有整条链路真的通了才报成功**。

### 用法

```powershell
cd G:\DEV\zhiyi-manyou-repo

# 启动（会在独立窗口里起三个服务，最小化）
powershell -ExecutionPolicy Bypass -File .\scripts\start-all.ps1

# 看状态（不动任何进程）
powershell -ExecutionPolicy Bypass -File .\scripts\start-all.ps1 -Status

# 全部停止
powershell -ExecutionPolicy Bypass -File .\scripts\start-all.ps1 -Stop
```

启动成功后直接打印室友要用的地址：

```
  室友访问地址 : http://192.168.x.x:5173/
  测试账号 : 2024117420 / 123456    (admin / 123456)
```

### 它做了哪些事

| 步骤 | 内容 |
|---|---|
| 0 | 检查密码 / JWT 密钥 / jar 是否已构建 / dist 是否存在 / Python 是否可用 |
| 1 | 检查 8901 / 8080 / 5173 是否被占用，占用时**询问**是否接管 |
| 2 | 启动 NLP，轮询 `/health` 直到真的 ready（不是只看端口） |
| 3 | 启动后端，轮询 `/api/health` |
| 4 | 启动前端，轮询首页 |
| 验证 | 用**局域网地址**再走一遍首页与 `/api/health`，确认室友那条路真的通 |

### JWT 密钥的处理

`application.yml` 里的 JWT 密钥有个**公开的兜底默认值**，而这行代码已经推到公开仓库了：

```yaml
secret: ${ZHIYI_JWT_SECRET:zhiyi-manyou-dev-secret-key-please-change-in-production-2026}
```

谁都知道这个值，就能**伪造任意用户的令牌，包括 admin**。

脚本的处理：
- 没设 `ZHIYI_JWT_SECRET` → 打印警告，然后**随机生成一个**（局域网够用，代价是重启后旧令牌失效）
- 设了但等于那个公开默认值 → **拒绝启动**（防止你以为设了其实没设）
- 设了真实值 → 直接用

### 参数

| 参数 | 默认 | 说明 |
|---|---|---|
| `-Action` | `start` | `start` / `stop` / `status`（也可用 `-Stop` / `-Status`） |
| `-FrontPort` / `-BackendPort` / `-NlpPort` | 5173 / 8080 / 8901 | 端口 |
| `-DbName` / `-DbUser` / `-DbHost` / `-DbPort` | `zhiyi_manyou` / `root` / `localhost` / 3306 | 数据库 |
| `-NoNlp` | 关 | 跳过语义服务（匹配退化为纯关键词） |
| `-WindowStyle` | `Minimized` | 服务窗口样式 |

### 停止逻辑为什么这么绕（踩过三次）

`-Stop` 要可靠地杀掉整棵进程树，且**绝不能误杀你在别的终端手工起的服务**。

试过三种做法，前两种都在真实运行中失败了：

1. **只按窗口标题杀**（`taskkill /FI "WINDOWTITLE eq ..."`）
   杀掉的是拥有窗口的 `cmd.exe`，而真正监听端口的 node/python/java 是**孙进程**，
   会作为孤儿存活并继续占用端口 → 下次启动报「端口被占用」，而那个服务是脚本刚刚声称已经停掉的。

2. **「父进程还活着就说明不是我们的」**
   这个判据本身就是错的：npm 通过一个中间 `cmd.exe` 启动 vite 二进制，
   所以残留的 node 进程**父进程活着，却毫无疑问是我们的** —— 结果 5173 没被释放。

3. **最终方案：启动时把自己的 PID 写进 `run.pid`，停止时 `taskkill /F /T /PID`**
   `/T` 递归杀整棵树。而且 `.pid` 文件本身就是所有权证明，所以依然不会碰别人的进程。
   由于 `-Stop` 通常是**另一个进程**（内存里的记录是空的），PID 记录需要从磁盘恢复 ——
   临时目录名是随机 GUID，但每个目录里的 `run.cmd` 第一行是 `title <名字>`，
   名字因此可以反查出来，不需要额外的隐藏状态文件。

实测：连续 start→stop 两轮，每次三个端口都干净释放。

---

## 一、`backup.ps1` —— 数据库备份与恢复（FR-M9-06）

### 为什么需要它

在此之前仓库里**没有任何备份脚本**，`docs/需求文档.md` 里 FR-M9-06 只有需求条目、没有实现。
而 MySQL 里的数据是这个项目的全部业务资产 —— 788 个技能标签、7 个账号、13 条交换记录、
8 份互评、78 条通知、以及支撑语义检索的技能本体。一次误 `DROP`、一次
`UPDATE` 忘了 `WHERE`，这些都会不可逆地消失。

### 四个动作

| 动作 | 用途 |
|---|---|
| `backup` | 导出整库（结构 + 数据），压缩、算校验和、写元信息、按保留策略清理旧档 |
| `list` | 列出所有备份，逐个复核校验和，一眼看出哪个文件已经损坏 |
| `verify` | 校验单个备份：**先比 SHA256，再解压进去确认真的含 `CREATE TABLE`** |
| `restore` | 恢复指定备份到指定库，恢复前强制校验、越权覆盖需显式 `-Force` |

### 快速开始

```powershell
# 0) 密码只走环境变量，不写进命令行、不落盘
$env:ZHIYI_DB_PASSWORD = '你的密码'
# 若 mysql 不在 PATH 中（本项目开发机在 G:\DEV\mysql）
$env:ZHIYI_MYSQL_HOME   = 'G:\DEV\mysql'

cd G:\DEV\zhiyi-manyou-repo

# 1) 备份（默认压缩，保留最近 14 份）
powershell -ExecutionPolicy Bypass -File .\scripts\backup.ps1 backup

# 2) 看看有哪些备份、有没有坏的
powershell -ExecutionPolicy Bypass -File .\scripts\backup.ps1 list

# 3) 校验某一个
powershell -ExecutionPolicy Bypass -File .\scripts\backup.ps1 verify `
    -File .\backups\zhiyi_manyou-20260922-220356.sql.zip

# 4) 恢复（覆盖已有数据必须加 -Force，这是防手滑的硬闸）
powershell -ExecutionPolicy Bypass -File .\scripts\backup.ps1 restore `
    -File .\backups\zhiyi_manyou-20260922-220356.sql.zip `
    -Database zhiyi_manyou -Force
```

### 恢复演练（强烈建议先做一次）

**"能备份"和"能恢复"是两件事。** 只做备份、从不恢复，等于把风险从"删库"换成了"以为有备份"。
建议在真正出事之前，先按下面步骤走一遍：

```powershell
# 把当前备份恢复到一个临时库，随便折腾，绝不动生产库
powershell -ExecutionPolicy Bypass -File .\scripts\backup.ps1 restore `
    -File .\backups\<最新的>.sql.zip -Database zhiyi_restore_test

# 对比两张表，确认数据一致
mysql -uroot -e "SELECT (SELECT COUNT(*) FROM zhiyi_manyou.zy_skill) a,
                        (SELECT COUNT(*) FROM zhiyi_restore_test.zy_skill) b;"

# 演练完删掉
mysql -uroot -e "DROP DATABASE zhiyi_restore_test;"
```

本项目 2026-09-22 的实测结果：恢复后 **27 张表全部行数一致**，
`zy_skill` / `zy_skill_ontology` / `zy_user_skill_profile` 三张表的
**内容 MD5 完全相同**，中文技能名无乱码。

### 参数一览

| 参数 | 默认值 | 说明 |
|---|---|---|
| `-Database` | `zhiyi_manyou` | backup 时是**导出源**，restore 时是**恢复目标** |
| `-DbHost` | `localhost` | 数据库主机 |
| `-Port` | `3306` | 端口 |
| `-User` | `root` | 用户名 |
| `-OutDir` | `<仓库>/backups` | 备份输出目录（已在 `.gitignore` 中） |
| `-Keep` | `14` | 保留最近 N 份；`0` = 全部保留 |
| `-NoCompress` | 关 | 不压缩，直接留 `.sql` |
| `-File` | — | `verify` / `restore` 的输入文件 |
| `-Force` | 关 | 允许覆盖已有表的库，**不加则直接拒绝** |

也可用环境变量代替：`ZHIYI_DB_NAME` / `ZHIYI_DB_HOST` / `ZHIYI_DB_PORT` / `ZHIYI_DB_USER` / `ZHIYI_DB_PASSWORD` / `ZHIYI_MYSQL_HOME`。

### 产出文件长什么样

```
backups/
├── zhiyi_manyou-20260922-220356.sql.zip         # 备份本体（约 58 KB）
├── zhiyi_manyou-20260922-220356.sql.zip.sha256  # 校验和，list 会用它复核
└── zhiyi_manyou-20260922-220356.sql.zip.meta.json  # 元信息
```

`.meta.json` 记录的是"这份备份里有什么"，让恢复行为可审计：

```json
{
  "database": "zhiyi_manyou",
  "takenAt": "2026-09-22 22:03:57",
  "schemaStamp": "2026-09-21 23:11:57",
  "mysqldump": "mysqldump  Ver 8.0.46 for Win64 on x86_64",
  "tableCount": 27,
  "topTables": { "zy_skill": 788, "zy_notification": 78, ... },
  "sha256": "ca6f5d0ac...",
  "file": "zhiyi_manyou-20260922-220356.sql"
}
```

---

## 二、实现上的几个坑（改脚本前必读）

这几条都是**实测踩出来的**，不是推测：

### 1. `mysqldump --databases` 会把库名写死在文件里

导出文件里含 `CREATE DATABASE zhiyi_manyou;` 和 `USE zhiyi_manyou;`，
所以直接把这份备份恢复到 `zhiyi_restore_test` **会静默写回原库**（或者直接报
`Unknown database`）。`restore` 因此会把这两行剥掉，改成目标库名后再导入，
并打印 `retargeted dump to 'xxx' (3 statement(s) rewritten)` ——
看到这行才说明重定向真的生效了。

### 2. `Get-Content | mysql` 会毁中文

用 `Get-Content file.sql | mysql` 让 PowerShell 逐行管道传输，会按控制台编码重新编码，
788 个中文技能名会全部变乱码。脚本改用 `cmd /c "... < file.sql"` 让 mysql 直接读文件。

### 3. `Set-StrictMode` 下单个结果 `.Count` 会抛异常

`Get-ChildItem` 只匹配到一个文件时返回的是对象而非数组，`.Count` 报
`PropertyNotFoundStrict`。所有可能为单个对象的地方都用 `@(...)` 强制成数组。

### 4. PowerShell 参数名 `-Db` / `-Host` 会被拒

`-Db` 与 `[CmdletBinding()]` 自动注入的 `-Debug` 别名冲突，直接
`ParameterNameConflictsWithAlias`；`-Host` 与只读自动变量 `$Host` 冲突。
参数因此叫 `-Database` 和 `-DbHost`。

### 5. 本文件是**纯 ASCII**

Windows PowerShell 5.1 在 zh-CN 环境下按 GBK 解析 `.ps1`，写中文注释极易出
解析错误；带 UTF-8 BOM 又会干扰别的工具。所以脚本内**一律英文注释**，
中文说明放在本文件里。这不是偷懒，是踩过坑后的约定。

### 6. `mysqldump` 的 `-h` 参数也必须带

最初 pre-check 查询漏了 `@connArgs`，mysql 客户端就退化成用默认用户
`ODBC` 连接，报 `Access denied for user 'ODBC'@'localhost'` ——
所有 `mysql.exe` 调用现在都统一带 `@connArgs`。

---

## 三、建议的备份节奏

| 场景 | 做法 |
|---|---|
| 日常开发 | 动手改数据**之前**先跑一次 `backup` |
| 演示 / 答辩前 | 跑一次 `backup`，并把 `.zip` 复制一份到 U 盘 |
| 提交重要功能后 | 跑一次 `backup`，`-Keep 30` 多留一段历史 |
| 定期 | 用「任务计划程序」每天定时跑，命令见下 |

```powershell
# 任务计划程序里可用的无交互命令
powershell -NoProfile -ExecutionPolicy Bypass -File G:\DEV\zhiyi-manyou-repo\scripts\backup.ps1 backup
```

> 密码通过**系统环境变量**（不是用户变量）配好，任务计划程序才读得到。

---

## 四、`verify-graph.ps1` —— 技能图谱验收

### 为什么需要它

图谱边从 3 条扩到近 600 条之后，"有数据"和"数据对"是两件事。
这个脚本不检查"表里有没有行"，而是检查**图谱能不能支撑它该支撑的功能**：

| 检查组 | 内容 |
|---|---|
| 体量 | 总边数、三种关系类型齐全、COMPLEMENT 数量（隐性需求挖掘只读这类边） |
| 语义正确性 | PREREQUISITE 必须是有向、COMPLEMENT 必须是无向 |
| 跨学科主张 | 跨门类边占比、被连接技能是否过半 |
| 数据完整性 | 无悬空边（指向已删除技能）、无自环 |
| **可达性** | 5 组"产品自己主张过的"技能对之间确实存在互补边 |
| 枢纽度 | 图谱里存在度数 ≥5 的中心节点（否则游走无处可去） |

用法：

```powershell
$env:ZHIYI_DB_PASSWORD = '你的密码'
powershell -ExecutionPolicy Bypass -File .\scripts\verify-graph.ps1
```

退出码 0 = 全部通过。当前实测 **16/16 通过**。

### 两个设计决定

**为什么是纯 ASCII + 独立数据文件**：脚本要校验**中文技能名**，
但 PowerShell 5.1 在中文 Windows 上按 GBK 解析无 BOM 的 `.ps1`，
中文字符串会让解析器报出**指向无关行**的错误。这个脚本因此先后坏了两次
（每次重新编辑都丢 BOM）。最终方案：脚本保持 ASCII，
中文技能对放 `graph-seed-pairs.txt`（UTF-8），运行时用 `-Encoding UTF8` 读。

**为什么可达性检查用固定技能对而不是随机抽样**：随机抽样会漏掉"恰好断掉的那条边"。
写死的这 5 对都是产品主张（前端↔设计、数据↔医学、储能↔新能源发电），
断任何一条都说明图谱退化或生成器出错，应当立刻失败。

### 一个自己踩过的坑

第一版的"枢纽度"检查只统计 `src_skill_id`，报出"最大度 = 4"并失败。
原因是 `COMPLEMENT` 是无向边，生成器按技能名排序后**只存一次**，
方向不固定 —— 只数一个方向等于只数了半个邻域。真实中心节点度数是 13。
统计无向图度数必须 `src UNION ALL dst`。

---

## 五、`lib/lan.ps1` —— 共用的局域网探测

`check-lan.ps1` 和 `start-all.ps1` 都点源这个模块，保证两边对"局域网地址是什么"
"端口是否对外"的判断**永远一致**。它们原先各有一套实现，结果不一致 —— 见下面第六节。

提供：

| 函数 | 用途 |
|---|---|
| `Get-LanIPv4` | 选局域网 IPv4，首选"已 Up 且带默认网关"的网卡；附 `Others`/`Source` 便于排查 |
| `Test-PortListening` | 端口是否有监听 |
| `Get-PortBindAddresses` | 端口绑定在哪些地址，按"对外可见度"排序 |
| `Test-PortBoundAll` | 是否绑到全网卡（即室友能否访问） |
| `Get-ListeningPid` | 占用端口的进程 PID |
| `Test-HttpOk` | URL 是否返回 2xx/3xx（真正的健康检查） |

---

## 六、`../check-lan.ps1` 的两处修复（2026-09-22）

局域网部署自检，8→9 项。

### 修复 1：选错网卡，把好端端的部署报成故障

原逻辑：过滤掉 `127.*` 和 `169.254.*` 后**取第一个**。

本机实测的网卡列表：

| 网卡 | 状态 | IPv4 |
|---|---|---|
| WLAN | **Up** | **192.168.152.222** ← 真实地址 |
| 本地连接* 12（WiFi Direct 虚拟网卡） | **Down** | **192.168.0.1** ← 被选中的那个 |
| 以太网 ×3、本地连接* 3 | Down | 169.254.x.x |

那张**已断开**的虚拟网卡带着静态 IP，枚举顺序又排在 WLAN 前面，
于是脚本拿 `192.168.0.1` 这个**不通的地址**去测，报了 3 个失败：

```
[通过] 本机IP: 192.168.0.1
[失败] 前端首页  http://192.168.0.1:5173/     HTTP 0
[失败] 接口代理  http://192.168.0.1:5173/api/health
[失败] 登录接口 (经代理)  请求未发出
```

**这个缺陷很恶劣**：它让完全正常的部署看起来是坏的，而且没有任何线索指向"是检查脚本选错了网卡"。
使用者无法区分"网站挂了"和"检查器坏了"。

现在改为优先选**正在 Up 且带默认网关**的网卡（有网关才说明这张卡真的承载局域网流量），
并把其他候选地址一并打印出来 —— 万一以后又选错，一眼就能看出来：

```
[通过] 本机IP: 192.168.152.222
       other adapters: 169.254.26.220, ..., 192.168.0.1, ...
```

### 修复 2：把 `0.0.0.0:5173` 当成 `127.0.0.1`，反过来误报"仅本机可见"

`netstat` 的本地地址列是 `IP:PORT`（`0.0.0.0:5173`），**不是裸 IP**。
第一版直接拿这一列和 `0.0.0.0` 比较，永远不相等，于是所有监听都被判成"仅本机可见"：

```
[通过] 监听 5173
      仅本机可见，请将 vite.config.ts 的 host 改为 0.0.0.0   ← 错的，实际已对全网卡开放
```

这和第二处是同一类错误：**把健康的部署报成坏的**。现在会剥掉端口再比较，
并按"对外可见度"排序（`0.0.0.0` > `[::]` > 其他 > `127.*`）。

### 顺带修好的一处

NLP 检查原先只做 `netstat` 端口匹配 —— 端口上有**任何东西**监听就算通过。
服务还在启动中、或者别的程序占了 8901，都能骗过它。现在改成真的打 `/health`。

---

## 七、一键启动脚本的验收记录（2026-09-22）

| 项 | 结果 |
|---|---|
| 冷启动 | NLP → 后端 → 前端依次健康，局域网首页与 `/api/health` 均 200 |
| 可重复性 | 连续 start→stop 两轮，每轮三端口全部干净释放 |
| 端口占用处理 | 检测到占用时**询问**；回答 y 才接管，否则中止 |
| 不误杀外来进程 | 另起进程占住 9099，`-Stop` 完全不碰它 |
| 孤儿进程清理 | 三次真实观察到"窗口已杀但服务作为孙进程存活"，`taskkill /T` 解决 |
| JWT 密钥 | 未设时随机生成并警告；等于公开默认值时**拒绝启动** |
| 输出 | 直接打印室友访问地址与测试账号 |

---

## 八、验收记录

### 数据库备份（2026-09-22）

| 项 | 结果 |
|---|---|
| 备份产出 | 27 张表 / 254,774 字节原始 SQL / 压缩后 58 KB / 354 ms |
| 校验和 | `list` 与 `verify` 均报 `OK`（含 zip 解压内检 `CREATE TABLE`） |
| 篡改检测 | 改动 zip 一个字节 → `verify` 退出码 1，`restore` **拒绝执行**且不触碰数据库 |
| 恢复到临时库 | 27 张表，`zy_skill` 788 行，三张核心表内容 MD5 与源库一致 |
| 恢复到原库名 | 成功，恢复后 `788 技能 / 7 学生 / 33 画像 / 3 图谱边` 全部完好 |
| 防误覆盖 | 目标库已有 27 张表且未加 `-Force` → 拒绝，退出码 2 |
| 中文 | 恢复后技能名无乱码（`Vue 前端开发`、`UI/UX 设计`、`Logic Pro 音乐制作` 均正常） |

### 技能图谱（2026-09-22）

| 项 | 结果 |
|---|---|
| 入库边数 | 3 → **593**（COMPLEMENT 424 / PREREQUISITE 151 / SYNONYM 18） |
| 幂等性 | 连续应用 3 次，边数稳定 593，不增不减 |
| 跨门类边 | 215 / 593 = 36.3% |
| 技能覆盖 | 556 / 788 = 70.6% 的技能至少有一条边 |
| 生成器校验 | 技能名逐字校验，拦下 **189** 个凭印象写错的技能名 |
| 验收脚本 | `verify-graph.ps1` 16/16 通过 |
| 端到端 | `/api/skills/parse` 实测：输入"我要做一个前端页面" → 图谱补出 `交互原型设计`、`UI/UX 设计`、`Figma 界面设计与协作` |
| 前端 | 面板显示「556 节点 / 593 边」，分页渲染 60 条/屏；`/skills` DOM 节点 8,133（分页前全量渲染会是约 9,900） |
