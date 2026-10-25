# yueyong 个人改进清单

> 记录人：yueyong
> 起始日期：2026-10-25
> 分支：`yueyong`
> 说明：本文件只记录「发现的问题 + 修复建议 + 验收标准」，不直接改代码。
> 实施时遵循：**以队友最新基线为准 → 改 → 编译/测试 → 提交到 `yueyong`（不直接推 `main`）**。

---

## 总览

| # | 问题 | 优先级 | 影响 | 状态 |
|---|---|---|---|---|
| 1 | 逻辑删除的学号重新注册 → 撞唯一索引 → 500 | **P0** | 用户看到"系统内部错误" + 产生 500 告警噪音 | ✅ 已完成（912a4cd） |
| 2 | 并发注册 → 唯一键冲突 → 500（TOCTOU） | **P0** | 同上；查重不是并发安全的 | ✅ 已完成（510847a） |
| 3 | `authStatus` 未落地 → 未核验用户拥有完整权限 | **P1** | "请等待学号核验"只是文案，业务规则失效 | ✅ 已完成（510847a） |
| 4 | 跨标签页并发刷新：每个标签页各发一次 refresh | **P1** | 当前无害（旧 refresh 仍有效）；但引入「一次性使用」后会互相踢出 | ✅ 已完成（2be3449） |
| 5 | 旧 refresh token 未作废（轮换但未失效） | **P1** | 被窃取的旧 refresh 在 7 天内仍可换新令牌 | ✅ 已完成（764cd93） |
| 6 | 登出接口要求 access token 有效（access 过期时 refresh 不会被撤销） | **P2** | 前端以为登出，服务端 refresh 仍有效 | ✅ 已完成（510847a） |

**实施状态**：#1 ✅（912a4cd）、#2/#3/#6 ✅（510847a）、#5 ✅（764cd93）、#4 ✅（2be3449）。**编号任务已全部完成**；附录 A~F 为观察项/低优先清理，不阻塞主线。

---

## 1. 逻辑删除的学号重新注册会返回 500

### 现象

一个学号被逻辑删除（`deleted = 1`）后，用同一个学号重新注册：

1. 查重通过（因为 MyBatis-Plus 的 `@TableLogic` 自动给查询加了 `deleted = 0`）
2. `insert` 时撞上 `zy_student` 的全表唯一索引 `uk_student_sno (sno)`
3. 抛出数据库异常 → `GlobalExceptionHandler` 的兜底 `@ExceptionHandler(Exception.class)`
4. 最终返回 **HTTP 500 + code 5000「系统内部错误」**，而不是 **3002「该学号已注册」**

### 证据

| 位置 | 内容 |
|---|---|
| `AuthService.java:89-94` | `selectCount(...eq(Student::getSno, ...))`，>0 时抛 `SNO_ALREADY_EXISTS` |
| `Student.java:91-93` | `deleted` 字段标注了 `@TableLogic` → MP 自动加 `deleted = 0` |
| `sql/01-schema.sql`（`zy_student` 表） | `UNIQUE KEY uk_student_sno (sno)` —— **全表唯一，包含 `deleted=1` 的行** |

### 影响

- 用户看到"系统内部错误"，无法理解原因
- 运维收到 500 告警，但这其实是**可预期的业务情况**
- 概率低（需要"逻辑删除 + 同学号重注册"），但一旦发生很难排查

### 修复建议

查重时**显式绕过逻辑删除**（不要依赖 MP 的自动过滤）：

```java
// StudentMapper 新增一个手写方法（注意：不带 deleted = 0）
@Select("SELECT COUNT(*) FROM zy_student WHERE sno = #{sno}")
long countBySnoIncludingDeleted(@Param("sno") String sno);
```

> 不要把唯一索引改成 `(sno, deleted)`：当前 `deleted` 只有 0/1，多个已删除的同名记录会在 `(sno,1)` 上冲突。

### 验收标准

- [ ] 逻辑删除一个用户后，用同一学号注册 → 返回 **3002**（HTTP 200 + code）
- [ ] 正常新学号注册 → 不受影响
- [ ] `mvn -B test` 全绿

---

## 2. 并发注册：查重通过但插入失败（TOCTOU）

### 现象

两个请求几乎同时用同一个学号注册：

```
请求 A: selectCount = 0  ✅
请求 B: selectCount = 0  ✅     ← 两个都通过
请求 A: insert → 成功
请求 B: insert → 撞唯一索引 → 500
```

### 影响

- 用户 B 看到 **500 / 5000**，而不是 **3002**
- 这是典型的 **TOCTOU**（Time-of-check to time-of-use）
- 查重只能提供"友好提示"，**唯一索引才是最终防线**

### 修复建议

在 `studentMapper.insert(student)` 外层捕获唯一键冲突，转成业务异常：

```java
try {
    studentMapper.insert(student);
} catch (DuplicateKeyException e) {
    // org.springframework.dao.DuplicateKeyException
    throw new BusinessException(ErrorCode.SNO_ALREADY_EXISTS);
}
```

> #1 和 #2 是同一个问题的两面：
> **#1 解决"逻辑删除导致的误判"，#2 解决"并发导致的兜底缺失"。**
> 两者都要做，缺一不可。

### 验收标准

- [ ] 并发 10 个请求注册同一学号 → **1 个成功、9 个返回 3002**，**没有 500**
- [ ] 正常注册不受影响
- [ ] `mvn -B test` 全绿

---

## 3. `authStatus` 应按操作校验，而不是做成"登录门槛"

### 现象

- `AuthService.register` 把新用户设为 `authStatus = UNVERIFIED`（`AuthService.java:106-107`）
- `AuthController.register` 的返回文案是 **"注册成功，请等待学号核验"**（`AuthController.java:76`）
- 但 `AuthService.login` 只检查：用户存在、`isActive()`、密码 —— **不检查 `authStatus`**
- `ErrorCode.AUTH_NOT_VERIFIED(2006)` **全项目 0 处使用**

### 影响

- **未核验的用户拥有完整权限**：可以发布需求、发起交换、提交互评、导出报告……
- "请等待学号核验"没有任何强制力，属于**文案与行为不一致**
- 答辩时若被问"未核验用户有什么限制"，当前答案是：**没有任何限制**

### 为什么不建议做成"登录门槛"

如果把 `authStatus` 加进登录校验，会出现自相矛盾：

| 用户类型 | 能看公开内容吗？ |
|---|---|
| 匿名访客 | ✅ 能（技能图谱、集市浏览、验真、治理公示） |
| 已注册但未核验 | ❌ 不能登录 → **连访客都不如** |

**正确做法**：把 `authStatus` 做成**按操作的权限门**。

### 建议的权限矩阵（待产品确认）

| 操作 | 需要核验？ | 理由 |
|---|---|---|
| 浏览技能图谱 / 集市 / 验真 / 治理公示 | ❌ 不需要 | 公开内容 |
| 发布需求、发起交换 | ✅ 需要 | 涉及真实身份与责任 |
| 提交互评、参与仲裁 | ✅ 需要 | 评价具有公信力要求 |
| 导出能力鉴定报告 | ✅ 需要 | 凭证具有对外效力 |

### 实现方式（二选一）

| 方式 | 做法 |
|---|---|
| **服务层校验**（推荐，与现有风格一致） | 在相关 Service 入口校验 `authStatus == VERIFIED`，否则抛 `BusinessException(ErrorCode.AUTH_NOT_VERIFIED)` |
| 方法级注解 | `@PreAuthorize` + 自定义表达式（注意：项目当前 `@PreAuthorize` 使用数为 0，需要先补齐基础） |

### 验收标准

- [ ] 未核验用户：能浏览公开内容
- [ ] 未核验用户：发布需求 / 发起交换 → 返回 **2006**
- [ ] 核验通过后：上述操作恢复正常
- [ ] 登录本身**不**因 `authStatus` 被拒绝
- [ ] `mvn -B test` 全绿

---

## 4. 跨标签页并发刷新（每个标签页各发一次）

### 现象

前端的 `refreshing` 是**模块级变量**，每个标签页有独立的 JS 上下文 → **single-flight 只在「同一页面内」生效**。

```
标签页 A：401 → POST /auth/refresh（用 R1）
标签页 B：401 → POST /auth/refresh（用 R1）   ← 各自独立
```

### 当前影响

**暂时无害**：

- 旧的 refresh token 没有被作废（见 #5），所以两次刷新都会成功
- 两个标签页各自把新令牌写入 localStorage，后写的覆盖先写的，功能正常

### 潜在风险

一旦实现 #5 的「refresh token 一次性使用」，多标签页就会变成：

- A 成功 → R1 被作废
- B 用 R1 刷新 → 被拒 → **B 被踢回登录页**

### 修复建议（二选一）

| 方案 | 做法 |
|---|---|
| **跨标签页 single-flight** | `BroadcastChannel` / `navigator.locks`（Web Locks API）/ localStorage + 事件 |
| **明确接受限制** | 保持现状，但在做 #5 时必须先解决跨标签页协调，否则不能上线「一次性使用」 |

### 验收标准

- [ ] 多标签页同时触发 401 → `/auth/refresh` 只出现 1 次（采用方案 A 时）
- [ ] 或：在 #5 的 PR 描述里明确记录「多标签页是已知限制，已评估」

> 备注：本项目以单页面操作为主，跨标签页并发的实际概率低；但**做「一次性使用」前必须先处理**。

---

## 5. 旧 refresh token 未作废（轮换但未失效）

### 现象

`AuthService.refresh` 每次都会签发**新的** access + refresh，但**没有把旧的 refresh token 加入撤销名单**。

`TokenRevocationService` 目前只在**登出**时使用（`AuthController.logout` → `tokenProvider.revoke(...)`）。

### 影响

- 旧 refresh token 在 **7 天有效期**内仍然可用
- 如果它被窃取（XSS、日志泄露、设备丢失），即使合法用户已经刷新过，攻击者仍能继续用它换新令牌
- 这是「只有轮换的形，没有轮换的实」

### 修复建议

| 方案 | 做法 | 代价 |
|---|---|---|
| **A. 最小改动** | 刷新成功后 `tokenProvider.revoke(旧 refreshToken)`，并给旧 token 一个**短暂宽限期**（如 60 秒） | 实现简单；宽限期需要额外状态 |
| **B. Redis 当前 jti** | Redis 存 `sno -> 当前 refresh jti`，用 Lua 原子比较并替换；不匹配返回 2003 | 严格一次性；需要 Redis |
| **C. Token Family** | 每次轮换生成 family id；检测到旧 token 被复用 → 撤销整个 family | 最安全；实现复杂 |

**推荐 A 或 B**（本科生团队可落地）。

### 必须联动 #4

> 一旦旧 refresh 被作废，多标签页并发刷新就会互相踢出。
> **所以 #5 不能单独上线，必须先处理 #4（跨标签页协调）或加宽限期。**

### 验收标准

- [ ] 用同一个 refresh token 连续刷新两次：第二次返回 **2003**（宽限期内除外）
- [ ] 正常刷新流程不受影响
- [ ] 多标签页同时刷新不会误踢（与 #4 一起验收）
- [ ] `mvn -B test` 全绿

---

## 6. 登出接口要求 access token 有效，access 过期时 refresh 不会被撤销

### 现象

`/api/auth/logout` **不在** `PUBLIC_ENDPOINTS` 里，因此要求 **access token 有效** 才能进入 Controller。

### 影响

如果用户点登出时 access token 已经过期：

- 请求在 `RestAuthenticationEntryPoint` 就被 401 拦下，Controller 不执行
- refresh token 的 jti 没有被删除 → 它在 7 天内仍然有效
- 前端 401 处理器会清空本地令牌（`logout` 属于 auth 端点，不会触发静默刷新）
- 结果：**前端以为登出了，但服务端的 refresh token 仍然有效**

### 修复建议

把 `/api/auth/logout` 加入白名单：它只需要请求体里的 refresh token 就能完成撤销，不依赖 access token。

### 验收标准

- [ ] access token 过期时调用登出 → refresh token 从白名单删除
- [ ] 用旧 refresh token 刷新 → 2003

---

## 附：其他已发现、暂不处理的点

| # | 发现 | 说明 |
|---|---|---|
| A | `@PreAuthorize` / `@Secured` / `@RolesAllowed` **0 处使用** | 方法级鉴权"开了没用"，实际是两层（路径级 + 服务层） |
| B | `/api/arbitration/**` **无对应 Controller** | SecurityConfig 里的死规则；仲裁资格实际靠服务层 3078 |
| C | `UserPrincipal.enabled` **0 处读取** | 死字段；账号状态实际由过滤器每请求查库保证 |
| D | **交换配额三处不一致** | ✅ 已处理（510847a）：注册改为由 `CreditLevel.of(100).getExchangeQuota()` 推导（= **5**，与 DDL / 需求 FR-M4-09 一致）；删除未被读取的 `zhiyi.exchange.default-quota`。DDL 默认 5 现在只影响绕过应用的手工插入。⚠️ 行为变化：新注册用户的初始配额由 3 变为 5。 |
| E | **traceId 未接入日志 pattern** | MDC 里塞了 traceId，但 `application.yml` 的 pattern 没有 `%X{traceId}` → 拿到追踪号也搜不到日志 |
| F | **文档数字过期** | README 写"24 张表"，实际已 27+；测试数量等也需要同步更新 |

---

## 变更记录

| 日期 | 内容 |
|---|---|
| 2026-10-25 | 创建 #1~#3 与附录 A~F；同日补充 #4（跨标签页刷新）与 #5（旧 refresh 未作废） |
| 2026-10-25 | ✅ 完成 #1（注册查重包含逻辑删除），commit `912a4cd`；`mvn -B test` 226 项全绿 |
| 2026-10-25 | ✅ 完成 #5（refresh 白名单 + 一次性刷新），commit `764cd93`；232 项测试全绿。⚠️ #4 升级为 P1；新增 #6 |
| 2026-10-25 | ✅ 完成 #2/#3/#6（510847a）与 #4（2be3449）；后端 236 项、前端 17 项测试全绿 |
| 2026-10-25 | ✅ 完成 #2/#3/#4/#6；附录 B/D 同步处理；README 测试数 224 -> 236；DDL 配额默认仍为 5 |
