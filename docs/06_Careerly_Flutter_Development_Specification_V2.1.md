# 06_Careerly_Flutter_Development_Specification_V2.1

> 项目：Careerly  
> 文档：Flutter 开发规范  
> 版本：V2.1  
> 状态：开发前基准版本  
> 平台：Flutter / Android First  
> 开发方式：Vibe Coding  
> 前置基准：Careerly PRD V2.1、IA V2.1、最新 Figma Design / Figma Make

---

## 01. 文档定位

本文件用于指导 Careerly 从产品设计进入 Flutter 实际开发。

**本版本明确：Careerly 不在旧 JobInsight AI Flutter 项目上继续迭代，而是从一个全新的 Flutter 默认项目开始开发。**

因此：

- 不继承旧项目的页面代码
- 不继承旧项目的状态管理代码
- 不继承旧项目的路由结构
- 不继承旧项目的 UI 组件实现
- 不直接复制旧项目的目录结构
- 旧项目仅作为历史技术参考，不作为 V2.1 前端代码基线

开发基准关系：

```text
PRD V2.1
    ↓
IA V2.1
    ↓
Figma / Figma Make
    ↓
Flutter Development Specification V2.1
    ↓
Vibe Coding
    ↓
Flutter App
```

其中：

- PRD：定义为什么做、做什么
- IA：定义页面和信息如何组织
- Figma：定义视觉、布局和已确定的交互细节
- Flutter Spec：定义如何工程化实现
- Vibe Coding：负责具体代码实现与迭代

---

# 02. V2.1 开发基线

## 2.1 全新 Flutter 项目

开发第一步：

```bash
flutter create careerly
```

之后在新项目中逐步建立 Careerly 工程结构。

禁止直接将旧 JobInsight Flutter 项目复制为新项目基础。

## 2.2 旧 JobInsight AI 项目的定位

旧项目仅保留为：

- 后端 API 参考
- LangGraph 分析流程参考
- 部分业务字段参考
- 历史实现经验参考

旧项目中的以下内容不直接迁移：

```text
Screen
Router
Provider
Theme
Widgets
AppState
UI
```

如果旧实现存在可复用逻辑，应重新判断其是否符合 Careerly V2.1 后再实现。

---

# 03. 技术栈

| 层级 | 技术 |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Platform | Android First |
| Navigation | go_router |
| State | Provider / ChangeNotifier |
| Network | HTTP Client |
| Local Storage | 根据实际需要选择轻量本地存储 |
| Backend | FastAPI |
| AI Workflow | LangGraph |
| Design | Figma / Figma Make |

版本原则：

> 以开发环境当前稳定且与项目兼容的 Flutter / Dart 版本为准，不为了复刻旧项目而锁定旧版本。

---

# 04. 最终产品 IA

Careerly 一级导航固定为：

```text
首页
分析
AI
我的
```

整体结构：

```text
首页
├── 当前状态
├── 行动建议
├── 最近成长
└── 最近岗位变化

分析
├── 新建分析
│   ├── 选择简历
│   ├── 添加 JD
│   ├── 分析中
│   └── 分析结果
└── 历史分析
    └── 分析详情
        └── 更新分析

AI
└── AI Chat

我的
├── 职业资产
├── 成长足迹
├── 我的简历
└── 设置
```

以下不作为一级导航：

```text
Agent
Result
History
Resume
Profile
Settings
```

---

# 05. Router 架构

推荐：

```text
GoRouter
│
├── Onboarding
│   ├── Welcome
│   ├── Auth
│   ├── Career Profile
│   ├── Resume
│   └── Career Baseline
│
└── App Shell
    ├── Home
    ├── Analysis
    ├── AI
    └── Me
```

建议路由：

```text
/
├── onboarding
│   ├── welcome
│   ├── auth
│   ├── profile
│   ├── resume
│   └── baseline
│
└── app
    ├── home
    ├── analysis
    │   ├── new
    │   ├── running
    │   ├── result
    │   └── history
    │       └── :analysisId
    │
    ├── ai
    │
    └── me
        ├── career-assets
        ├── growth
        ├── resume
        └── settings
```

路由只表达页面层级，不承载复杂业务状态。

---

# 06. Flutter 工程目录

从默认 Flutter 项目开始，逐步建立：

```text
lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── bootstrap.dart
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   ├── app_shadows.dart
│   │   ├── app_motion.dart
│   │   └── app_theme.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   └── api_exception.dart
│   │
│   ├── storage/
│   │   └── local_storage.dart
│   │
│   └── utils/
│
├── data/
│   ├── api/
│   ├── local/
│   └── repositories/
│
├── models/
│
├── state/
│   ├── auth_state.dart
│   ├── resume_state.dart
│   ├── career_state.dart
│   ├── analysis_state.dart
│   └── ai_state.dart
│
├── shared/
│   ├── widgets/
│   ├── components/
│   ├── layouts/
│   └── animations/
│
└── features/
    ├── onboarding/
    ├── home/
    ├── analysis/
    ├── ai/
    └── me/
```

目录允许随着开发调整，但不得为了快速 Vibe Coding 把所有代码集中到单一文件。

---

# 07. Architecture

统一采用：

```text
UI
↓
State / Controller
↓
Repository
↓
Data Source
├── API
└── Local
```

页面不得直接：

```text
Screen
↓
HttpClient
```

页面不得直接处理复杂 API 请求。

---

# 08. State Management

使用：

> Provider + ChangeNotifier

推荐：

```text
AuthProvider
ResumeProvider
CareerProvider
AnalysisProvider
AIProvider
AppProvider
```

避免建立一个包含全部业务状态的巨大 `AppState`。

State 负责：

- 页面状态
- 加载状态
- 数据状态
- 错误状态
- 用户操作状态

Repository 负责数据访问。

---

# 09. Repository

建立：

```text
AuthRepository
ResumeRepository
CareerRepository
AnalysisRepository
AIRepository
```

开发早期允许使用 Mock：

```text
UI
↓
Repository
↓
Mock
```

之后切换：

```text
UI
↓
Repository
↓
Real API
```

---

# 10. Design System

最新 Figma 是视觉实现基准。

Flutter 不允许把所有视觉参数散落在页面代码中。

统一使用：

```text
AppColors
AppTypography
AppSpacing
AppRadius
AppShadows
AppMotion
```

所有新增页面优先调用 Design Token。

---

# 11. Careerly Visual Direction

当前方向：

> **Soft Brand + Neutral Structure**

关键词：

```text
现代
克制
温暖
轻盈
Android First
精致
内容优先
```

主要视觉：

```text
浅色背景
柔和渐变
半透明卡片
轻玻璃效果
柔和阴影
蓝紫品牌色
黑白中性结构
```

Flutter 开发阶段不重新设计视觉系统，以当前 Figma Design / Figma Make 为准实现。

---

# 12. 图标规则

### AI / 核心能力

AI Chat、分析：

```text
蓝 / 紫 / 粉
渐变
```

### 功能图标

```text
单色
线性
黑 / 白
```

### 系统图标

```text
黑白
简约
线性
```

---

# 13. Shared Components

优先建立：

```text
CareerlyScaffold
CareerlyNavigationBar

GlassCard

PrimaryButton
SecondaryButton
IconButton

SectionHeader
Tag
Chip

ScoreIndicator
ProgressIndicator

ResumeCard
CareerAssetCard
GrowthCard
JobMatchCard

AnalysisProgress

AIMessageBubble

EmptyState
LoadingState
ErrorState
```

原则：

> Screen 负责组合，Component 负责表现。

---

# 14. Onboarding

首次注册流程：

```text
Splash
↓
产品价值介绍
↓
注册 / 登录
↓
Career Profile
↓
提交简历
↓
AI 解析
↓
建立职业基线
↓
进入首页
```

重要规则：

> **首次注册后不要求用户提交岗位 JD。**

Onboarding 不包含：

```text
JD 输入
岗位分析
岗位排名
匹配结果
```

岗位分析进入 App 后，从「分析」开始。

---

# 15. Login / Auth

需要区分：

```text
首次注册
登录
```

首次注册用于建立 Career Baseline。

登录用于返回已有 Careerly 用户状态。

Auth UI 可以独立实现，但不得改变一级 IA。

---

# 16. Resume

简历是 Careerly 建立职业基线的重要输入。

流程：

```text
选择 / 上传简历
↓
上传
↓
解析
↓
结构化
↓
建立 Career Baseline
```

状态：

```text
idle
uploading
parsing
success
error
```

---

# 17. Career Baseline

Career Baseline 来源：

```text
当前简历
+
Career Profile
```

用于：

```text
首页当前状态
职业资产
AI Context
岗位匹配
```

首次进入 App 时完成初始化。

---

# 18. 首页

首页解决：

> **我现在怎么样？**

结构：

```text
首页
├── 核心状态
├── 行动建议
├── 最近成长
├── 职业资产摘要
└── 最近岗位匹配变化
```

首页展示摘要与变化，不重复展示完整分析报告。

---

# 19. 分析

分析是核心业务模块。

内部：

```text
新建分析 | 历史分析
```

默认：

```text
新建分析
```

---

# 20. 新建分析

流程：

```text
选择简历
↓
添加 JD
↓
确认岗位
↓
开始分析
↓
分析中
↓
分析结果
```

支持一次分析多个岗位。

数据结构：

```text
AnalysisSession
├── ResumeVersion
└── Jobs[]
```

---

# 21. Analysis Progress

后端可能包含：

```text
Crawl
Parse
Embed
Match
Rank
Report
```

前端不直接展示技术节点名称，而是转化为用户能理解的过程：

```text
准备数据
↓
理解简历
↓
理解岗位
↓
建立能力模型
↓
匹配计算
↓
生成报告
```

UI 必须明确：

- 当前步骤
- 已完成步骤
- 处理中步骤
- 总体进度
- 失败状态

---

# 22. Analysis Result

结果包括：

```text
Match Score
Ranking
Match Reasons
Strengths
Gaps
Distance
Improvement
Action Suggestions
```

评分：

```text
0–100
```

多岗位按照匹配度形成排名。

核心只聚焦：

> **能力匹配。**

不把城市、薪资、通勤等非能力因素混入核心能力评分。

---

# 23. History Analysis

历史分析归属：

```text
分析
└── 历史分析
```

不要在「我的」再次建立完整历史分析入口。

产品原则：

> 分析负责“使用分析结果”，我的负责“管理职业资产”。

历史分析支持：

```text
查看
↓
详情
↓
更新分析
```

---

# 24. Update Analysis

当用户简历变化：

```text
新简历
↓
旧岗位
↓
重新分析
↓
新结果
```

展示：

```text
Old Score
New Score
Score Change

Old Rank
New Rank

Capability Change
```

这是 Careerly 第二个“看见”：

> **看见能力变化。**

---

# 25. AI

AI 是职业成长陪伴入口。

支持：

```text
为什么这个岗位匹配度低？
我缺什么能力？
我的优势是什么？
我应该提升什么？
为什么排名发生变化？
```

AI 不负责承诺：

```text
一定获得 Offer
一定提升薪资
一定进入某公司
```

---

# 26. Career Context

AI 使用统一 Career Context：

```text
CareerContext
├── Resume
├── CareerAssets
├── CapabilityProfile
├── TargetJobs
├── MatchResults
└── GrowthRecords
```

AI Repository 根据 Context 构建请求。

页面不直接拼接复杂 Prompt。

---

# 27. 我的

「我的」定位：

> **职业资产中心。**

结构：

```text
我的
├── 用户信息
├── 设置
└── Tab
    ├── 职业资产
    ├── 成长足迹
    └── 我的简历
```

---

# 28. Tab → Card → Detail

这是 V2.1 已确定的重要交互。

默认：

```text
职业资产
成长足迹
我的简历
```

点击某个 Tab 后：

```text
对应 Card 自动排序到第一张
```

例如：

```text
点击「成长足迹」

成长足迹
职业资产
我的简历
```

然后：

```text
点击 Card
↓
进入对应详细内容
```

---

# 29. Card 动画

建议动画时长：

```text
250–350ms
```

要求：

- 平滑
- 克制
- 不瞬移
- 不夸张弹跳

可使用：

```text
AnimatedSwitcher
AnimatedSize
AnimatedPositioned
AnimationController
```

---

# 30. 我的简历 Card

**保留 Card。**

因为当前设计中 Card 本身具有信息价值。

展示摘要，例如：

```text
当前简历
更新时间
工作经历
项目经历
技能
```

点击：

> 查看完整职业简历资产。

---

# 31. 职业资产

展示：

```text
工作经历
项目经历
技能
奖项
能力
```

目标：

> 让用户看见自己已经拥有的职业资产。

---

# 32. 成长足迹

展示：

```text
能力变化
匹配度变化
岗位排名变化
新增经历
```

目标：

> 让用户看见职业成长过程。

---

# 33. 设置

设置只保留一个明确入口：

```text
我的
↓
设置
```

不建立重复的：

```text
设置 Tab
设置 Card
设置快捷按钮
```

如果 Figma 当前存在入口角标 / Card / 快捷按钮等视觉表现，应在实现时保证它们不会造成多个“设置入口”的认知重复。

---

# 34. Quota

免费用户：

> 3 次完整 AI 分析体验。

状态：

```text
QuotaState
├── total
├── used
├── remaining
└── canAnalyze
```

开始分析前：

```text
canAnalyze == true
```

如果额度不足：

```text
禁止开始分析
↓
显示剩余额度 / 状态
↓
提供升级入口
```

---

# 35. API

后端基准：

```text
FastAPI + LangGraph
```

现有 API：

```text
GET  /api/v1/health

POST /api/v1/resume/upload

POST /api/v1/match

GET  /api/v1/tasks/{id}

GET  /api/v1/tasks/{id}/result
```

API Base URL 不允许散落在页面代码中。

统一由：

```text
ApiClient
```

管理。

---

# 36. Mock First

Vibe Coding 阶段允许：

```text
Mock Data
```

优先完成：

```text
UI
↓
State
↓
Interaction
```

再接：

```text
Repository
↓
API
```

原因：

> 避免前端页面、后端 API、设计调整互相阻塞。

---

# 37. Loading / Empty / Error

主要业务必须完整处理：

```text
Loading
Success
Empty
Error
Retry
Disabled
```

重点：

```text
简历上传
简历解析
岗位分析
AI Chat
历史分析
职业资产
```

---

# 38. Android First

必须重点测试：

```text
SafeArea
StatusBar
NavigationBar
Keyboard
Back Button
BottomSheet
Dialog
Scroll
Long Text
Small Screen
```

尤其：

> Android 系统返回键必须遵循页面层级。

---

# 39. Figma → Flutter

Figma 是 UI / interaction reference。

转换关系：

```text
Figma
↓
Page
↓
Component
↓
Data
↓
State
↓
Interaction
↓
Flutter
```

不要简单：

```text
Figma Frame
↓
一个巨大的 Screen Widget
```

相似 UI 应抽象为可复用 Component。

---

# 40. Figma 未确定细节

允许在 Flutter 阶段确定：

```text
按钮点击区域
Card 点击区域
Scroll
Keyboard
BottomSheet
返回行为
动画
Loading
Error
```

但是：

> 不允许因为实现方便而改变 IA。

如果发现必须新增页面 / 一级导航才能实现功能，则暂停代码实现，回到产品层确认。

---

# 41. Vibe Coding 工作原则

禁止：

> 一次 Prompt 生成整个 App。

采用：

```text
拆分任务
↓
AI 编码
↓
运行
↓
flutter analyze
↓
人工检查
↓
提出具体问题
↓
AI 修复
↓
测试
↓
Commit
```

---

# 42. 每次 AI 开发任务

每个任务尽量限制为：

```text
1 个页面
```

或：

```text
1 个组件
```

或：

```text
1 个交互
```

或：

```text
1 个数据链路
```

避免一次修改大量无关文件。

---

# 43. Vibe Coding Prompt 基础模板

```text
你正在开发 Careerly Flutter App。

项目基准：
- Careerly PRD V2.1
- Careerly IA V2.1
- Careerly Flutter Development Specification V2.1
- 最新 Figma Design / Figma Make

当前任务：
[填写任务]

目标页面：
[填写页面]

目标：
[填写目标]

必须遵守：
1. 不改变 IA
2. 不新增未经确认的产品功能
3. 遵循最新 Figma
4. 使用已有 Design Tokens
5. 优先复用 Shared Components
6. 页面不得直接访问 API
7. Android First
8. 只修改当前任务相关代码

数据：
[Mock / API]

需要处理的状态：
- Loading
- Empty
- Success
- Error

交互：
[填写交互]

验收标准：
[填写标准]

修改范围：
[填写文件或目录]

禁止：
[填写禁止修改内容]

完成后：
1. flutter analyze
2. 修复分析错误
3. 运行项目
4. 列出修改文件
5. 说明实现结果
6. 不修改任务范围之外代码
```

---

# 44. 开发顺序

## Phase 0 — 项目初始化

```text
flutter create
↓
Git 初始化
↓
依赖配置
↓
基础目录
↓
App Bootstrap
```

## Phase 1 — Architecture

```text
Router
State
Repository
ApiClient
LocalStorage
```

验收：

> 空项目能够正常启动。

## Phase 2 — Design System

```text
Colors
Typography
Spacing
Radius
Shadow
Motion
```

然后建立：

```text
Button
Card
Chip
Navigation
```

## Phase 3 — App Shell

完成：

```text
四个一级导航
Bottom Navigation
页面 Scaffold
基础页面切换
```

验收：

> 四个一级页面可以正常切换。

## Phase 4 — Onboarding

完整实现：

```text
Welcome
↓
Register / Login
↓
Career Profile
↓
Resume
↓
Parsing
↓
Career Baseline
↓
Home
```

验收：

> 新用户无需 JD 即可完成首次进入 App。

## Phase 5 — Home

完成首页 UI + Career State。

## Phase 6 — Analysis

顺序：

```text
Analysis Input
↓
Analysis Progress
↓
Analysis Result
↓
Multi Job
↓
History
↓
Update Analysis
```

优先完成一个岗位完整闭环，再扩展多岗位。

## Phase 7 — AI

先：

```text
Chat UI
↓
Mock Response
↓
Career Context
↓
Real API
```

## Phase 8 — Me

顺序：

```text
我的
↓
职业资产
↓
成长足迹
↓
我的简历
↓
Tab → Card Reorder
↓
Card → Detail
↓
设置
```

## Phase 9 — Global States

统一补齐：

```text
Loading
Empty
Error
Retry
Quota
Offline
Auth
Cache
```

## Phase 10 — Android QA

重点：

```text
真机
键盘
返回
滚动
屏幕尺寸
SafeArea
性能
动画
```

---

# 45. Git / Commit

推荐：

```text
feat/project-init
feat/app-architecture
feat/design-system
feat/app-shell
feat/onboarding
feat/auth
feat/resume
feat/career-baseline
feat/home
feat/analysis-input
feat/analysis-progress
feat/analysis-result
feat/analysis-history
feat/analysis-update
feat/ai
feat/me
feat/settings
```

不要将整个 App 开发完成后再提交第一次 Commit。

---

# 46. 开发验收标准

## 产品结构

- [ ] 四个一级导航
- [ ] Onboarding 不要求 JD
- [ ] 历史分析只归属分析
- [ ] 设置只有明确入口
- [ ] 我的 Tab / Card / Detail 结构正确

## Onboarding

- [ ] 产品介绍
- [ ] 注册
- [ ] 登录
- [ ] Career Profile
- [ ] 简历上传
- [ ] 简历解析
- [ ] Career Baseline

## 分析

- [ ] 新建分析
- [ ] JD 输入
- [ ] 多岗位
- [ ] 分析进度
- [ ] 匹配结果
- [ ] 排名
- [ ] Gap
- [ ] 历史分析
- [ ] 更新分析
- [ ] 变化对比

## AI

- [ ] Chat
- [ ] Career Context
- [ ] 快捷问题
- [ ] Loading
- [ ] Error
- [ ] Retry

## 我的

- [ ] 职业资产
- [ ] 成长足迹
- [ ] 我的简历
- [ ] Tab → Card 自动排序
- [ ] Card → Detail
- [ ] 设置

## 工程

- [ ] flutter analyze 无错误
- [ ] 页面无明显 Overflow
- [ ] Android 返回逻辑正常
- [ ] Keyboard 行为正常
- [ ] Loading / Error 完整
- [ ] Mock / API 可以切换
- [ ] 核心组件可复用

---

# 47. Careerly 最终技术闭环

```text
                    用户
                     ↓
                 Onboarding
                     ↓
              Career Baseline
                     ↓
                    首页
              「看见现在」
                     ↓
                    分析
              「看见距离」
                     ↓
            Match / Gap / Rank
                     ↓
                     AI
              「理解并行动」
                     ↓
             简历 / 能力变化
                     ↓
                    我的
              「看见积累」
                     ↓
                再次分析
                     ↓
       Match / Rank / Capability Change
                     ↓
                    首页
```

Careerly Flutter 开发最终服务于产品核心：

> **看见自己 → 看见距离 → 看见变化。**

---

# 48. 开发启动原则

正式开始 Vibe Coding 前，必须确认：

```text
PRD V2.1
✓

IA V2.1
✓

Figma Design
✓

Figma Make
✓

Flutter Development Specification V2.1
✓

新 Flutter 项目
✓
```

第一条实际开发任务：

> **基于 Careerly PRD V2.1、IA V2.1 和 Flutter Development Specification V2.1，在当前全新 Flutter 默认项目中建立项目基础架构，不开发业务页面。**

完成后：

```text
Design System
↓
App Shell
↓
Onboarding
↓
Home
↓
Analysis
↓
AI
↓
Me
```
