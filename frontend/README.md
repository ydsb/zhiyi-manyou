# 知驿·漫游 · 前端

Vue 3 + Vite + TypeScript 单页应用。仓库总览见 [根目录 README](../README.md)。

## 运行

```bash
npm install
npm run dev      # 开发服务器 http://localhost:5173，已配置代理到后端 8080
npm run build    # 生产构建
npx vue-tsc --noEmit   # 类型检查
```

## 页面

| 路由 | 页面 | 对应需求 |
|---|---|---|
| `/login` | 登录 | 认证 |
| `/onboarding` | 新手引导（技能画像录入） | FR-M2-* |
| `/dashboard` | **数字档案**：能力雷达图、数字勋章、成长轨迹、成长周报、报告导出 | FR-M7-01 ~ 08 |
| `/market` | 供需集市：需求卡片、匹配度因子、邀约 | FR-M4-* |
| `/skills` | 技能图谱：标签树、关系网络 | FR-M2-* |
| `/exchanges` | 我的交换：状态机操作、邀约响应 | FR-M4-* |
| `/workspace/:recordId` | **协作工作台**：任务打卡、文件版本、留言、时间轴、过程指标 | FR-M5-* |
| `/profile` | 个人中心 | — |

## 约定

- **响应拦截**：后端业务错误返回 HTTP 200 + `code`，由 `api/request.ts` 统一判定并提示，
  页面里只需 `try/catch` 兜住"已提示过"的情况。
- **时间字段**：接口返回 `LocalDateTime` 序列化为 `yyyy-MM-dd HH:mm:ss`，
  统一用工具函数解析，不要直接 `new Date(str)`。
- **栅格**：`el-col` 必须显式给 `:span`，只写 `:xs` 会同时生成 `el-col-24` 覆盖响应式类。
- **图表**：ECharts 按需引入，容器需要有确定高度，且在 DOM 渲染后再 `init`。

---

> 大学生创新训练计划项目 · 西北大学计算机学院
> Vue 3 + Vite + TypeScript + Pinia + Element Plus + ECharts

---

## 一、环境要求

| 组件 | 版本 | 说明 |
|---|---|---|
| Node.js | ≥ 20.19（本项目用 v24.19.0 验证） | Vite 8 要求 |
| npm | 11.x | — |
| 后端 | Spring Boot 3.3.5 / JDK 17，端口 **8080** | 见 `../zhiyi-manyou/README.md` |

---

## 二、快速开始

```powershell
cd frontend
npm install                 # 若已装过可跳过
npm run dev                 # 启动开发服务器
```

打开 **http://127.0.0.1:5173** ，使用测试账号登录：

| 学号 | 密码 | 角色 |
|---|---|---|
| `admin` | `123456` | 管理员 |
| `2024117420` | `123456` | 学生（李泽宬） |
| `2024117421` | `123456` | 学生（吴禹晗） |
| `2024117422` | `123456` | 学生（杨渡） |

> **首次登录会强制进入「新手漫游导引」**，这是 FR-M1-03 的设计行为
> （后端 `firstLogin=true`，即该用户尚未建立技能画像）。
> 走完三步或点"跳过"即可进入数字档案。

其他命令：

```powershell
npm run build        # 生产构建，产物在 dist/
npm run preview      # 预览生产构建
npm run typecheck    # vue-tsc 类型检查
```

---

## 三、目录结构

```
zhiyi-manyou-web/
├── .npmrc                      npm 配置（本地缓存 + 国内镜像）
├── index.html
├── vite.config.ts              构建配置 + /api 开发代理
├── tsconfig.json
├── public/favicon.svg          像素风驿站图标
└── src/
    ├── main.ts                 应用入口
    ├── App.vue                 根组件
    ├── env.d.ts                类型声明（含 *.vue 模块声明）
    ├── api/
    │   ├── request.ts          axios 封装：令牌注入、统一响应解包、401 跳转
    │   ├── types.ts            与后端对应的类型定义
    │   └── auth.ts             认证与健康检查接口
    ├── stores/
    │   └── auth.ts             认证状态（Pinia）
    ├── router/
    │   └── index.ts            路由表 + 登录守卫 + 首次登录引导
    ├── layouts/
    │   └── DefaultLayout.vue   主布局（侧栏 + 顶栏）
    ├── styles/
    │   └── main.scss           全局样式与设计令牌
    └── views/
        ├── LoginView.vue       登录 / 注册（FR-M1-01、FR-M1-02）
        ├── OnboardingView.vue  新手导引 + 技能星图（FR-M1-03、FR-M1-04）
        ├── DashboardView.vue   数字档案：能力雷达图 + 勋章（FR-M7-01~03）
        ├── MarketView.vue      供需集市：Issue 式卡片（FR-M4-01~03）
        ├── SkillsView.vue      技能图谱：分类 + 跨学科关系（FR-M2）
        ├── ExchangesView.vue   我的交换：状态机 + 任务进度 + 互评（FR-M4/M5/M6）
        ├── ProfileView.vue     个人中心：资料 / 信用 / 档案导出（FR-M1-05）
        └── NotFoundView.vue    404
```

---

## 四、与后端的对接

开发环境通过 Vite 代理转发，避免跨域：

```
浏览器 → http://127.0.0.1:5173/api/...  →（代理）→ http://localhost:8080/api/...
```

配置见 `vite.config.ts` 的 `server.proxy`。前端请求统一加 `/api` 前缀
（`import.meta.env.VITE_API_BASE_URL` 默认 `/api`）。

### 统一响应处理

后端约定 `{ code, message, data, traceId, timestamp }`：

- `code === 0` → 成功，`request<T>()` 自动解包 `data`
- `code !== 0` → 失败，抛 `ApiError` 并弹出 `ElMessage` 提示
- HTTP 401 → 清除本地令牌并跳转登录页（带 `redirect` 参数）

因此业务代码里无需重复判断错误码，示例：

```ts
import { authApi } from '@/api/auth'

const user = await authApi.me()   // 失败会抛 ApiError
```

---

## 五、当前进度

### 已完成
- 工程脚手架：Vite 8 + Vue 3.5 + TS 5.7 + Pinia + Element Plus + ECharts，构建通过
- 路由与守卫：登录校验、首次登录强制导引、页面标题自动设置
- 请求层：令牌注入、响应解包、401/403 统一处理
- 认证状态管理：登录 / 注册 / 刷新 / 退出 / 恢复会话
- 8 个页面骨架，全部渲染验证通过（含 ECharts 雷达图与像素风勋章）
- 视觉规范：地窖蓝主色 + 暖橙强调色、像素/体素风格"基础方块"

### 仍为演示数据（等后端接口）
| 页面 | 待接入接口 |
|---|---|
| 数字档案 | `GET /api/profile/radar`（FR-M7-03） |
| 技能图谱 | `GET /api/skills/tree`、`GET /api/ontology/graph`（FR-M2-04/05） |
| 供需集市 | `GET/POST /api/demands`（FR-M4-01/02） |
| 我的交换 | `GET /api/exchanges`、协作工作台、互评提交（FR-M4~M6） |
| 个人中心 | `PUT /api/profile`、`GET /api/profile/report/export`（FR-M7-06） |
| 新手导引 | `POST /api/skills/parse`、画像保存（FR-M1-03/04、FR-M2-02） |

---

## 六、已知问题与注意事项

**1. 受限沙箱下 Vite 会报 `spawn EPERM`**
Vite 在 Windows 上通过 `exec`（`stdio:'pipe'`）子进程解析真实路径；受限沙箱
禁止这种子进程创建，报错堆栈指向
`optimizeSafeRealPathSync → windowsSafeRealPathSync`。
**在普通终端（你自己的 PowerShell / IDEA 终端）里不会有这个问题。**
`vite.config.ts` 里的 `resolve.preserveSymlinks: true` 是为减少该调用而加的，
本项目无符号链接依赖，保留无副作用。

**2. `manualChunks` 必须是函数**
Vite 8 底层换成 rolldown，`manualChunks` 的对象写法已不支持，必须是函数。

**3. 依赖版本较新**
本项目使用 Vite 8 / vue-router 5 / Pinia 4 / Element Plus 2.14。若遇到
兼容问题，可回退到 Vite 7 / vue-router 4 / Pinia 3 这一代组合。

**4. 生产构建体积**
Element Plus（~982 KB）与 ECharts（~1.1 MB）已拆为独立 chunk，
gzip 后分别约 315 KB / 370 KB。后续可改为按需引入进一步优化。
