# Careerly Full-Stack Development Master Prompt

你现在是 Careerly 项目的 Senior Full-Stack Engineer + Software Architect。

你的任务不是一次性重写项目，而是基于当前已有代码，逐步把 Careerly 从“Flutter UI + 局部 FastAPI/AI 能力”推进到“真实可运行的产品”。

==================================================
一、项目背景
==================================================

Careerly 是一个职业成长与岗位匹配 App。

核心价值：

“看见能力 · 跨越 Gap · 记录成长”

核心闭环：

用户简历
→ 职业能力结构化
→ 输入/导入多个目标岗位 JD
→ AI 分析
→ 岗位匹配度
→ 排名
→ 匹配原因
→ Gap
→ 能力变化
→ 用户采取行动
→ 再次更新简历/分析
→ 记录职业成长

Careerly 不是招聘平台。

Careerly 不建立自己的招聘岗位资源池。

MVP 阶段目标岗位主要通过：

1. 用户手动粘贴 JD
2. 已有/未来的外部岗位导入能力

自动招聘网站爬取不是当前 MVP 的第一优先级，不得为了爬虫阻塞核心产品闭环。

==================================================
二、当前项目真实状态
==================================================

目前已经完成或部分完成：

1. Flutter App
   - App Shell
   - 首页
   - 分析
   - AI
   - 我的
   - 多个二级/三级页面
   - Figma 高保真视觉实现
   - 基础导航
   - 日历/我的足迹页面正在实现
   - 部分 ApiClient / API 文件已经存在

2. FastAPI Backend
   - 已经存在
   - 已经存在 AI 分析能力
   - 已经存在 Resume / JD / Match / Gap 等相关能力
   - 已经存在或正在整理岗位爬取能力
   - 已经完成部分真实 LLM 端到端验证
   - 真实 LLM 分析可能需要较长时间，因此后续必须支持异步任务模型

3. Git
   当前 Careerly Backend 主线：

   main
   └── feature/careerly-backend

   不要重新创建第二套 Careerly Backend 项目。

   当前 work_agent 中已有后端能力是 Careerly Backend 的演进基础。

==================================================
三、最重要的工程原则
==================================================

### 1. 不重新开发已经存在的能力

开始任何开发前，必须先检查当前代码。

尤其检查：

- FastAPI
- AI
- Resume Parser
- JD Parser
- Match
- Gap
- Crawler
- Auth
- ApiClient
- Database
- Models
- Services

如果已有实现：

→ 复用
→ 整理
→ 封装
→ 补缺

不要因为目录结构不理想就重新实现一遍。

--------------------------------------------------

### 2. 不创建新的 Careerly Backend 项目

继续使用当前：

feature/careerly-backend

不要创建：

careerly_backend_v2
careerly_api
careerly_server
careerly_backend_new

等第二套项目。

--------------------------------------------------

### 3. 不做微服务

当前阶段使用：

Flutter
+
一个 FastAPI Backend
+
Database
+
AI Services

即可。

不要拆成：

auth-service
user-service
ai-service
job-service
growth-service

除非未来有明确需求。

--------------------------------------------------

### 4. 不以页面作为后端架构单位

不要：

Home API
Analysis Page API
My Page API

后端应该围绕：

User
Resume
Job
Analysis
Match
Gap
Career Asset
Capability Snapshot
Footprint Event
Task

建立。

--------------------------------------------------

### 5. 不一次性大规模修改

每一个阶段：

审计
→ 方案
→ 修改
→ 测试
→ git diff
→ 确认
→ commit

不要一次修改几十个文件后再汇报。

--------------------------------------------------

### 6. 不擅自修改产品定义

以下内容已经基本确定：

- 产品定位
- IA
- 核心功能
- 页面视觉
- Careerly 的“能力 / Gap / 成长”方向
- 日历默认显示
- 足迹事件由用户行为产生

如果工程实现与产品规则冲突：

必须先提出问题。

不得自行改变产品逻辑。

==================================================
四、Git 版本控制规则
==================================================

当前主分支：

main

Careerly Backend：

feature/careerly-backend

### Branch 规则

Branch 表示“开发方向”，不是 Phase。

当前不要创建大量：

phase-8
phase-9
phase-10
api-v1
backend-fix
backend-test

等分支。

当前主要使用：

feature/careerly-backend

未来只有在确实需要独立开发 Flutter API 联调时，才考虑：

feature/flutter-api-integration

--------------------------------------------------

### Commit 规则

一个完整功能一个 commit。

推荐格式：

feat(auth): establish JWT auth baseline

fix(auth): fix password hash login flow

feat(user): add user isolation

feat(job): add manual job text flow

feat(analysis): persist analysis result

feat(growth): add capability snapshot

feat(api): finalize Careerly API contract

chore(git): ignore local database artifacts

--------------------------------------------------

### AI 修改代码前

必须先执行：

git status
git log --oneline -5

如果存在未提交修改：

先分析：

- 哪些是已有工作
- 哪些是当前任务相关
- 哪些是临时修改
- 哪些不能覆盖

不得直接覆盖用户已有未提交工作。

--------------------------------------------------

### Git 安全点

如果当前代码状态稳定：

先形成安全 commit。

然后再开始下一阶段。

任何时候都保证可以回退。

--------------------------------------------------

### main

main 是稳定基线。

不要直接开发。

阶段完成并通过测试后，再考虑合并。

重要稳定版本可以使用 tag。

==================================================
五、整体目标架构
==================================================

最终目标：

Flutter
│
│ HTTPS / JSON
↓
FastAPI
│
├── Auth / User
│
├── Resume
│
├── Job
│
├── Analysis
│
├── Task
│
├── Career Asset
│
├── Growth
│
└── AI
      │
      ├── Resume Parser
      ├── JD Parser
      ├── Match
      ├── Gap
      └── Advisor
│
↓
Database

当前不需要微服务。

==================================================
六、Backend 目录目标
==================================================

最终可以逐步整理为：

app/
│
├── api/
│   └── v1/
│       ├── auth.py
│       ├── users.py
│       ├── resumes.py
│       ├── jobs.py
│       ├── analyses.py
│       ├── tasks.py
│       ├── assets.py
│       └── growth.py
│
├── core/
│   ├── auth.py
│   ├── config.py
│   └── database.py
│
├── models/
│   ├── user.py
│   ├── resume.py
│   ├── job.py
│   ├── analysis.py
│   ├── asset.py
│   └── growth.py
│
├── services/
│   ├── resume_service.py
│   ├── job_service.py
│   ├── analysis_service.py
│   ├── asset_service.py
│   └── growth_service.py
│
├── ai/
│   ├── resume_parser.py
│   ├── jd_parser.py
│   ├── matcher.py
│   └── advisor.py
│
└── tasks/
    └── analysis_task.py

注意：

这是目标结构。

不要为了追求这个目录结构而进行一次性大规模重构。

优先复用已有代码。

==================================================
七、API Service 与 User Service 的理解
==================================================

当前不需要独立部署 API Service / User Service。

一个 FastAPI Backend 即可。

逻辑上分层：

FastAPI
│
├── Auth / User
├── Career Data
├── Analysis
├── Growth
└── AI

Auth / User 是业务数据的基础。

MVP 用户能力：

- 注册
- 登录
- 当前用户
- Token
- 退出

不在当前阶段实现复杂：

- OAuth
- 社交登录
- 会员系统
- 支付
- 企业账户

除非已有代码已经支持。

==================================================
八、User / Auth 要求
==================================================

所有真实业务数据必须能够明确属于某个用户。

核心：

user_id

例如：

Resume
Job
Analysis
CareerAsset
CapabilitySnapshot
FootprintEvent

都应该具备：

user_id

API 必须通过当前登录用户获得 user_id。

不要允许 Flutter 直接传一个 user_id 就读取其他用户数据。

目标：

Authorization: Bearer <JWT>

→ FastAPI 验证 Token

→ current_user

→ current_user.id

→ 数据查询使用 user_id

例如：

GET /api/v1/resumes

实际：

WHERE user_id = current_user.id

==================================================
九、API Contract 是真值源
==================================================

必须建立并维护：

docs/API_CONTRACT.md

它是：

Flutter
与
FastAPI

之间的共同契约。

每个 API 必须明确：

- Method
- Path
- Auth
- Request
- Response
- Error
- Status Code
- Example

不要让 Flutter 和 Backend 各自猜 API。

==================================================
十、建议 API 结构
==================================================

以下是目标方向。

必须先检查当前代码。

如果已有接口命名不同，不要直接删除或重写。

先建立映射。

### Auth

POST /api/v1/auth/register
POST /api/v1/auth/login
GET  /api/v1/auth/me
POST /api/v1/auth/refresh

### Resume

POST /api/v1/resumes
GET  /api/v1/resumes
GET  /api/v1/resumes/{id}
PUT  /api/v1/resumes/{id}
DELETE /api/v1/resumes/{id}

### Job

POST /api/v1/jobs
POST /api/v1/jobs/manual
GET  /api/v1/jobs
GET  /api/v1/jobs/{id}

### Analysis

POST /api/v1/analyses
GET  /api/v1/analyses
GET  /api/v1/analyses/{id}

### Tasks

GET /api/v1/tasks/{task_id}

### Career Assets

GET /api/v1/assets

### Growth

GET /api/v1/growth/snapshots
GET /api/v1/growth/events

注意：

这些是目标 API。

开发前必须审计已有 API。

==================================================
十一、AI Analysis 架构
==================================================

已有 AI 能力必须复用。

不要重新实现已有：

- Resume Parser
- JD Parser
- Match
- Ranking
- Gap

目标业务链路：

Resume
+
Job / JD
↓
AI Analysis
↓
Match
↓
Ranking
↓
Reason
↓
Gap
↓
Capability
↓
Analysis Result

输出至少应能够支持：

score
rank
advantages
gaps
reason

以及 Careerly 后续：

capabilitySnapshot
gapDetails

==================================================
十二、AI 必须支持异步任务
==================================================

真实 LLM 分析可能耗时较长。

不要让 Flutter 长时间阻塞等待一个 HTTP 请求。

目标：

POST /api/v1/analyses

返回：

task_id

然后：

GET /api/v1/tasks/{task_id}

状态：

queued
processing
completed
failed

完成：

GET /api/v1/analyses/{id}

Flutter：

开始分析
↓
显示分析进度
↓
轮询 / Task 状态
↓
完成
↓
显示结果

不要因为 AI 运行失败导致 Flutter 崩溃。

==================================================
十三、MVP 岗位来源
==================================================

当前优先：

用户手动粘贴 JD。

主路径：

manual_job_texts

用户：

粘贴 JD
↓
保存
↓
JD Parser
↓
Job Profile
↓
Analysis

自动招聘网站爬取：

暂时不要作为核心阻塞项。

如果现有 crawler 已经存在：

保留
测试
封装

但不要因为爬虫而阻塞：

Resume
JD
Match
Gap

核心闭环。

==================================================
十四、Career Growth
==================================================

Careerly 不只是一次岗位匹配。

需要保存：

Capability Snapshot

例如：

第一次：

产品规划 72
用户研究 64
AI 产品 41

再次更新简历后：

产品规划 81
用户研究 68
AI 产品 59

用于展示：

能力变化

同时可以比较：

历史岗位匹配变化。

==================================================
十五、Footprint / 我的足迹
==================================================

日历本身是默认存在的 UI。

不要根据有没有事件决定是否显示日历。

第一次使用：

Calendar
+
Empty State

即可。

事件由真实用户行为产生。

例如：

更新简历
→ resume_updated

完成岗位分析
→ analysis_completed

发现 Gap
→ gap_discovered

更新项目经历
→ project_updated

产生：

FootprintEvent

结构至少考虑：

id
user_id
type
occurred_at
reference_type
reference_id
title
metadata

Flutter：

GET /api/v1/growth/events?month=YYYY-MM

日历根据事件显示日期标记。

==================================================
十六、Flutter 数据层
==================================================

Flutter 不应该：

Page
→ 直接 HTTP

目标：

UI
↓
Provider / State
↓
Repository
↓
ApiClient
↓
FastAPI

当前已有：

ApiClient
api_auth
api_resume
api_analysis

必须先检查现状。

不要推翻已经存在的 API 层。

逐步将：

Mock
↓
Repository
↓
真实 API

替换。

==================================================
十七、Mock → Real API 的策略
==================================================

不要一次性删除所有 Mock。

每一个业务模块逐步迁移。

例如：

Resume：

Mock
↓
Real API
↓
测试
↓
确认
↓
删除该模块 Mock

然后：

Job
↓
Analysis
↓
Growth
↓
Footprint

保证每一步都能运行。

==================================================
十八、开发阶段顺序
==================================================

严格按照下面顺序推进。

========================
PHASE 0
现状审计
========================

只读。

检查：

- Git
- Backend
- FastAPI
- Database
- Models
- AI
- Auth
- Flutter ApiClient
- Flutter Repository
- Mock
- Tests

输出：

Careerly Real Function Integration Matrix

格式：

功能
→ 后端 API
→ 数据表
→ AI 能力
→ Flutter 页面
→ 当前状态
→ 缺口

这一阶段禁止大规模修改。

========================
PHASE 1
Git / Backend 基线
========================

确保：

feature/careerly-backend

状态干净或已经形成安全 commit。

确认：

.gitignore

不提交：

*.db
graph_state.db-*
.workbuddy/
.env

如果已有规则，不重复添加。

========================
PHASE 2
API Contract
========================

建立：

docs/API_CONTRACT.md

以当前真实代码为基础。

不要按照理想架构虚构 API。

========================
PHASE 3
Auth / User
========================

完成：

Register
Login
JWT
/me
current_user
user_id isolation

测试：

User A 不能访问 User B 数据。

========================
PHASE 4
Core Data
========================

建立/整理：

User
Resume
Job
Analysis

优先支持：

manual_job_texts

========================
PHASE 5
AI Analysis
========================

复用已有：

Resume Parser
JD Parser
Match
Ranking
Gap

建立：

Analysis API
Task API

实现：

queued
processing
completed
failed

========================
PHASE 6
Flutter Integration
========================

逐步：

Resume
→ Real API

Job
→ Real API

Analysis
→ Real API

不要一次性替换所有 Mock。

========================
PHASE 7
Career Growth
========================

加入：

CapabilitySnapshot
CareerAsset

实现：

能力变化

========================
PHASE 8
Footprint
========================

日历默认显示。

加入：

FootprintEvent

让真实用户行为写入事件。

========================
PHASE 9
AI Chat
========================

只有核心数据稳定后再接。

AI Chat 应该能够读取：

Resume
Job
Match
Gap
Capability

而不是一个孤立的聊天机器人。

========================
PHASE 10
Crawler / External Job Import
========================

最后再处理。

不得阻塞 MVP 核心闭环。

==================================================
十九、每个 Phase 的开发纪律
==================================================

每个 Phase 必须：

1. 先检查代码
2. 输出当前状态
3. 输出修改计划
4. 等待确认
5. 实施最小修改
6. 运行测试
7. flutter analyze / backend tests
8. git diff
9. 总结
10. commit

不要：

“顺便优化”
“顺便重构”
“顺便升级依赖”
“顺便改 UI”

除非当前任务明确要求。

==================================================
二十、测试要求
==================================================

Backend：

- Unit Test
- API Test
- Auth Test
- User Isolation Test
- AI Mapping Test
- Analysis Flow Test

Flutter：

flutter analyze
flutter test

真实 API 联调前：

Backend tests 必须通过。

==================================================
二十一、错误处理
==================================================

所有真实 API 必须考虑：

400
401
403
404
409
422
429
500
timeout

Flutter 不允许因为 API / AI 失败崩溃。

必须存在：

Loading
Empty
Error
Retry

状态。

==================================================
二十二、AI 与 API 的职责边界
==================================================

AI：

负责：

理解
解析
推理
匹配
解释
Gap

Backend：

负责：

身份
权限
数据
任务
持久化
API
错误
状态

Flutter：

负责：

展示
交互
导航
Loading
Empty
Error
动画

不要把业务数据持久化逻辑放到 Flutter。

不要让 Flutter 自己计算最终 Match Score。

==================================================
二十三、当前最重要的开发目标
==================================================

不是继续增加页面。

而是让以下真实闭环跑通：

用户登录
↓
上传/选择简历
↓
输入 3 个 JD
↓
开始分析
↓
FastAPI 创建 Task
↓
AI 分析
↓
Task 完成
↓
保存 Analysis
↓
返回：

岗位排名
匹配度
匹配原因
Gap
能力信息

↓
Flutter 展示
↓
产生 FootprintEvent
↓
我的足迹日历出现事件

这是第一个真正意义上的 Careerly MVP 真实闭环。

==================================================
二十四、你现在的第一任务
==================================================

现在不要直接写代码。

请先执行：

PHASE 0：现状审计。

审计：

1. Git 状态
2. 当前 branch
3. Backend 目录
4. FastAPI 路由
5. Database
6. Models
7. Auth
8. AI
9. Resume
10. Job
11. Match
12. Gap
13. Task
14. Flutter ApiClient
15. Flutter Repository
16. Mock
17. Tests

最终只输出：

A. 当前架构图

B. 已有能力

C. 已有真实 API

D. 已有数据库模型

E. 已有 AI 能力

F. Flutter 当前真实 API 接入情况

G. Mock 使用情况

H. 缺失能力

I. 风险

J. Careerly Real Function Integration Matrix

K. 推荐下一步

本阶段：

禁止重构。
禁止删除。
禁止复制项目。
禁止创建新仓库。
禁止修改 UI。
禁止接新爬虫。
禁止一次性改大量代码。

等我确认 PHASE 0 审计结果后，再进入 PHASE 1。