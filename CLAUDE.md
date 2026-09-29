# CLAUDE.md — Careerly 长期开发规则

> 本文件是 Careerly 项目的**长期开发规则**，每次会话自动加载。
> 它定义「什么能做、什么不能做、遇到歧义听谁的」。
>
> **本文件只写规则，不写进度。**
>
> | 想知道 | 去哪里 |
> |---|---|
> | 现在做到哪里 | `docs/05_progress/CURRENT_STATUS.md` |
> | 接下来做什么 / 什么挡路 | `docs/05_progress/TODO.md` |
> | 为什么这么决定 | `docs/05_progress/CHANGELOG.md` |
> | 每次开发怎么做 | `DEVELOPMENT_WORKFLOW.md` |

---

## 0. 三条最高优先级禁令

```text
❌ 禁止自行修改产品规则
❌ 禁止自行增加一级页面 / 一级导航
❌ 禁止自动进入下一个 Phase
```

具体含义：

| 禁令 | 说明 |
|---|---|
| **禁止自行修改产品规则** | 不得「简化」「优化」「顺手统一」任何已锁定的产品规则。发现规则有冲突或疑问 → **停下来报告**，标明类别，等产品侧裁决，**不要用写代码的方式解决** |
| **禁止自行增加一级页面** | 不得因为 Figma Make 里出现了某个页面/卡片/模块，就自行建立对应页面或一级导航。尤其：Growth Calendar、History Version、Membership、Career Context |
| **禁止自动进入下一 Phase** | 每个 Phase 结束后**停止**，输出报告，等待验收。不得因为「下一步很明显」就继续 |

发现新问题时的正确动作：

```text
发现冲突 / 疑问
  → 分类：【产品冲突】【IA 冲突】【视觉/交互差异】【技术实现差异】
  → 报告 + 标记「待确认」
  → 等裁决
  → ❌ 不要直接改代码
```

---

## 1. 产品定位

**Careerly** —— AI 原生的职业成长 App，**Android 优先**。

```text
产品命题：看见能力 · 跨越 Gap · 记录成长
用户旅程：看见自己  →  看见距离  →  看见变化
```

Careerly 不是招聘 App，不是简历工具。
它要回答三个问题：**我现在在哪 → 我离目标有多远 → 我积累了什么。**

---

## 2. 四个一级导航与职责

**恰好四个，永远不加第 5 个。**

| 导航 | 回答的问题 | 职责边界 |
|---|---|---|
| **首页** | 我现在在哪？ | **只展示**「现在」：当前职业状态 / 最近变化 / 岗位匹配变化 / 行动建议 / 最近成长 / 今日内容。**不是完整数据仓库** |
| **分析** | 我离目标有多远？ | 结构 = **新建分析**（当前简历 / 添加岗位 / 岗位列表 / 开始分析）+ **历史分析**（分析项目 / 分析结果 / 更新分析 / 历史版本） |
| **AI** | 为什么？下一步做什么？ | **正式一级 Tab**（不是辅助入口、不是浮动按钮的附属品）。可以特殊视觉表现 |
| **我的** | 我积累了什么？ | **长期职业资产**。结构 = **Tab → Card → Detail**，**不是**再次展示完整分析历史 |

### 2.1 AI Tab 的定位

```text
AI = 正式一级 Tab          ✅ 已确认
AI 允许特殊视觉表现         ✅ 已确认（品牌渐变圆形等）
```

AI 与首页 / 分析 / 我的**平级**。它的特殊视觉是**表现层差异**，不是**层级差异**。

> ⚠️ AI 入口的具体视觉形态（是否浮起、尺寸、是否带文字标签）
> 属**视觉定稿问题**，在 Phase 3 按 Figma 确定。
> 在定稿前**不得**把它写成产品规则。

### 2.2 信息归属（已锁死）

```text
历史分析       → 只属于「分析」。「我的」不再提供历史分析入口
设置           → 唯一入口 =「我的」右上角齿轮。无设置 Tab、无设置卡片
成长日历        → 属于「我的 → 成长足迹 → Detail」内部，不是独立页面
成长时间线      → 同上
历史版本        → 属于「历史分析」内部的 Bottom Sheet / 局部状态，不是独立页面
```

---

## 3. 来源优先级与冲突裁决

遇到歧义时，**按顺序**找答案：

```text
1. PRD V2.1                  → 产品行为最高依据       docs/01_...
2. IA V2.1                   → 页面归属 / 导航最高依据  docs/04_...
3. Development Baseline      → 已裁决的历史决策        docs/07_...
4. Flutter Dev Spec          → 工程架构与实现规则       docs/06_...
5. Figma Make                → 视觉 / 交互参考          docs/Careerly App Interface Design (Copy)/
6. Flutter 实际代码           → 最终可运行产品           lib/
```

> **`docs/07_Careerly_Development_Baseline_V1.0.md` 是歧义仲裁的第一入口。**
> 遇到任何「这个到底怎么做」的问题，**先查 Baseline**，多半已经裁决过了。

### 3.1 冲突裁决硬规则

```text
Figma ≠ PRD                      → PRD 胜
Figma ≠ IA                       → IA 胜
Figma 有视觉，但 Flutter 没有对应实现方式  → 重新实现，而不是放弃视觉
Figma 有页面，但 PRD / IA 已确认取消     → 不实现
Figma 已明确设计交互细节，但 PRD 描述较粗  → 采纳 Figma
```

### 3.2 一条必须记住的原则

**设计稿负责视觉，Flutter 负责真实交互逻辑。**

Figma Make 是 React 静态原型，**天生无法表达**：

- Card reorder 动画
- Bottom Sheet 的局部状态
- 额度扣减与失败回滚
- 加载 / 空 / 错误 / 重试

遇到这类「Figma 没画」的差异，正确动作是 **在 Flutter 里实现**，
**不是**判定设计稿错了、要求重新出稿。

> 这条原则来自一次真实的结论修正（见 `docs/05_progress/CHANGELOG.md` Session 001）。

---

## 4. Phase 0 已锁定的决策

以下 9 条**已由产品侧裁决并锁定，不得重新讨论**：

| # | 问题 | **最终决定** |
|---|---|---|
| 1 | 「我的」Tab / Card 交互 | **Tab → 对应 Card 自动移到第一位 → 点击 Card → Detail** |
| 2 | 是否重新导出 Figma | **不需要** |
| 3 | 历史分析归属 | **只归「分析」** |
| 4 | 分析额度扣减时机 | **点击「开始分析」时**扣减 |
| 5 | 首页岗位变化点击 | 直接进入对应匹配结果 |
| 6 | Membership | MVP = 静态页面 + 额度门禁，**不做真实支付** |
| 7 | AI 会话历史 | **暂不进入 MVP** |
| 8 | Visual Token | 以 **Figma Make 实际视觉**为准，Flutter 重新归纳 Token |
| 9 | 底部导航 | **自绘 Careerly Navigation**，不使用 M3 `NavigationBar`；自定义页面转场 |

---

## 5. 不可协商的产品规则

违反其中任何一条都算**严重错误**：

### 5.1 Onboarding

```text
开屏 → 注册/登录 → 职业画像 → 提交简历 → 简历解析 → 确认职业信息 → 进入首页
```

- ✅ 目的是**建立职业基线（Career Baseline）**
- ❌ 首次注册**不要求 JD**
- ❌ 不做首次匹配
- ❌ 不做首次分析
- ❌ 不做目标岗位输入

> 首次 Onboarding 的目的不是完成一次分析，而是**建立用户的职业基线**。
> 分析发生在进入 App 之后：首页 → 分析 → 添加 JD → 开始分析。

### 5.2 分析额度

```text
免费用户：3 次完整分析
```

| 动作 | 是否扣额度 |
|---|---|
| 上传简历 | ❌ **不扣** |
| 粘贴 JD | ❌ **不扣** |
| 进入分析页面 | ❌ **不扣** |
| **点击「开始分析」** | ✅ **扣** |

- 成功 → 保留结果
- 失败 → **回滚额度**
- 额度耗尽 → 展示剩余额度 + 升级入口，`canAnalyze == false` 时禁用「开始分析」

### 5.3 匹配度

```text
匹配度 = 0–100
只由「能力匹配」计算
❌ 薪资 / 通勤 / 城市 不得进入核心分数
```

### 5.4 「我的」交互

```text
Tab（职业资产 / 成长足迹 / 我的简历）
  → 点击 Tab：对应 Card 动画移动到第一位（250–350ms，平滑，不得突跳/回弹），其他 Card 保持相对顺序
  → 点击 Card：打开 Detail
```

### 5.5 四态

每个业务页面**必须**处理：

```text
Loading / Empty / Error / Retry / Disabled
```

尤其：简历上传、简历解析、分析、AI 对话。

### 5.6 Android Back 导航规则（2026-09-23 产品确认）

一句话：**一级页面负责切换，二级/三级页面负责返回。**

```text
一级页面（首页 / 分析 / AI / 我的）：Bottom Navigation 管理，
  ❌ 无页面级 Back      ❌ 不返回上一一级页面
  Back = 退出 / 系统默认处理
二级 / 三级页面：统一支持 Back
```

- **三个入口同一个 Back Action**：顶部返回按钮、Android 系统 Back、
  左边缘向右的 Edge Swipe Back，必须落在同一条代码路径上。
  执行层是 `lib/app/router/back_navigation.dart` 的 `careerlyBack()`
  （`Navigator.maybePop`）；**禁止**在页面里直接写 `context.pop()`
  —— go_router 18 的 `pop()` 绕过 `PopScope`，守卫会失效。
- **Back = 当前导航栈的 pop**（回到上一个操作上下文），
  ❌ 不跳转固定页面。返回目标由 `app_router.dart` 的路由层级表达，
  页面不自己决定「回到哪」。
- **Edge Swipe 只认左屏幕边缘**：页面中间的横向滑动（卡片横滑、
  列表横滑）不触发 Back；一级页面之间禁止左滑切换；
  ❌ 不要自绘 `GestureDetector` 横滑返回（会与横滑组件抢手势）。
  预测性返回已在 `AndroidManifest.xml` 开启
  （`android:enableOnBackInvokedCallback="true"`）。
- **未保存修改先确认**：有未保存内容时 Back 必须先弹离开确认
  （`CareerlyBackScope(guard: CareerlyBackGuard.unsavedChanges())`），
  用户选「放弃」才真正 pop。
- **分析进行中 Back 不取消任务**：先弹「是否离开分析？」，
  确认离开后任务状态保留（`CareerlyBackGuard.analysisInProgress()`），
  重新进入分析页可以看到「分析中……」或已完成的结果。
  取消分析是另一件事，走显式入口（「退出分析」→ `exitAnalysis`）。
- Back 行为必须在 Android 真机 / 模拟器上完整验证。

---

## 6. 工程架构与分层

### 6.1 分层规则（硬规则）

```text
UI  →  State/Controller  →  Repository  →  Data Source (API | Local | Mock)
```

- ✅ 页面**只能**通过 State 拿数据
- ❌ 页面**禁止**直接访问 API / HTTP
- ✅ Repository 是**唯一**数据访问层
- ✅ API base URL 只属于 `ApiClient`，**不得**出现在页面代码里

### 6.2 目录结构

```text
lib/
├── app/            # app.dart, providers.dart, router/, shell/
├── core/           # constants/, errors/, state/, extensions/, utils/
├── design_system/  # tokens/, theme/, components/, motion/
├── data/           # models/, repositories/, mock/, api/
├── features/       # home/, analysis/, ai/, profile/
└── main.dart
```

### 6.3 State 规则

- 按领域拆分为**各自独立的 ChangeNotifier**
  （`AuthProvider` / `ResumeProvider` / `CareerProvider` / `AnalysisProvider` / `AIProvider` / `AppProvider`）
- ❌ **禁止**做成一个巨大的 `AppState`
- 只注册**当前真实被使用**的 Provider。**不预建空 Provider 占位**（那是死代码）

### 6.4 命名

命名规则见 **§8.4**：按层级分两类 ——
**Design Primitive 不加前缀**（`GlassSurface` / `GlassEdgePainter`），
**产品级共享组件加 `Careerly` 前缀**（`CareerlyCard` / `CareerlyButton` / `CareerlyChip` …）。

Widget 保持 **Small / Composable / Reusable**。

### 6.5 依赖原则

❌ **不要为了「以后可能用到」而安装 Package。**

新增依赖必须同时满足：

1. 明确必要
2. 当前阶段**实际使用**

每个新增依赖都要在对应 Phase 报告中说明：Package / Purpose / Why Needed。

---

## 7. Mock First

```text
先做 UI → State → 交互，再接 Repository → API
```

目的是让**前端、后端、设计三方互不阻塞**。

早期所有 Repository 用 Mock 实现，后续替换为真实 API，**页面代码不需要改**。

Mock 规则：

- ❌ **不编造产品数据**（如「匹配度 86%」「Alex Chen」）——假数据会被误当成需求
- ✅ 默认返回**空数据**，让 **Empty 态真实可见**
- ✅ 保留可配置的**延迟 / 失败**开关，让 **Loading / Error 态真实可达**

---

## 8. 设计系统

### 8.1 视觉方向

**"Soft Brand + Neutral Structure"**
浅色背景 · 柔和渐变 · 半透明玻璃卡片 · 蓝紫品牌色 · 黑白中性结构。
AI / 核心图标用蓝紫粉渐变；功能图标用单色线性图标。

### 8.2 Token

```text
AppColors · AppTypography · AppSpacing · AppRadius · AppShadows · AppMotion
```

❌ 业务页面**不得硬编码**：颜色 / 字号 / 字体族 / 圆角 / 动画时长。
✅ 一律通过 Token 获取。

#### 暂定值规则（2026-09-18）

Phase 2 的执行方式是 **「先实现 → 实际视觉验证 → 再裁决 → Token 收敛」**，
因此 Token 分两类：**已有 Figma 依据的** 与 **暂定值**。

```text
✅ 暂定值只允许写在 lib/design_system/tokens/ 里
❌ 不得在组件 / 页面里内联任何一个暂定数值
✅ 要调整视觉 → 只改 Token 一处 → 全系统统一变化
✅ 暂定值必须标注 `⚠️ 暂定值 · 待视觉验证` + 登记到待裁决清单
❌ 不得在文档里把暂定值描述成「已最终确定的设计规则」
```

> **这是「Token 收敛」能成立的前提**：只要暂定值不散落，
> 后续调整就永远是改一处。
> `flutter analyze` **抓不到硬编码数值** —— 靠代码评审与登记表保证。
>
> 📌 **暂定值的集中登记表** → `docs/05_progress/CURRENT_STATUS.md` §3.6
> （裁决记录仍在 待裁决清单 §3.1，两处职责不重叠：一个查「哪些是暂定的」，
> 一个查「谁拍板」）。

### 8.3 中文字体 —— 统一 Noto Sans SC

```text
✅ 所有中文 UI 文案统一使用 Noto Sans SC
❌ 不使用系统中文字体作为 Careerly UI 的默认字体
❌ 不允许不同页面自行指定其他中文字体
✅ Noto Sans SC 必须进入 Typography Token
❌ 业务页面不得绕过 Typography Token 自行设置中文字体
```

- **英文 / 数字**：统一方案，**Phase 2 再确认最终 Font Family**，Phase 1 仅预留 Token
- **Logo**：独立 Brand Asset，**不属于**普通 UI Typography Token
- ⚠️ **字体缺口**：项目当前**没有** Noto Sans SC 字体文件。
  **不得自行从网络下载**，也**不得用其他中文字体偷偷替代**。
  处理方式见 `assets/fonts/README.md`

### 8.4 组件与命名规范

#### 命名规则（2026-09-18 产品侧裁决）

按**层级**分两类 —— 判定标准是「**有没有 Careerly 业务语义**」，不是「好不好看」：

| 层 | `Careerly` 前缀 | 判定标准 | 例 |
|---|---|---|---|
| **Design Primitive** | ❌ **不加** | 纯视觉 / 基础设施，**不含 Careerly 业务语义**，可被任何项目复用 | `GlassSurface` · `GlassEdgePainter` · `GlassFilters` |
| **产品级共享组件** | ✅ **必须加** | 承载 Careerly 的产品交互语义（额度、四态、分析…） | `CareerlyCard` · `CareerlyButton` · `CareerlyChip` · `CareerlyPressFeedback` · `CareerlyAsyncStateView` · `CareerlyScaffold` · `CareerlyNavigationBar` |

**后续新增共享组件原则上遵循 `Careerly` 前缀。**
若判断某物确属 primitive，**在交付报告中说明理由**，不自行归类。

#### 已裁决的「不拆分」决策

```text
CareerlyButton          用 variant 区分 primary / secondary
                        ❌ 不创建 PrimaryButton / SecondaryButton 两个组件

CareerlyAsyncStateView  统一承载 loading / empty / error 等异步状态
                        ❌ 不拆成 EmptyState / LoadingState / ErrorState
                          —— 除非后续出现**明确的独立复用需求**

GlassSurface            保持基础视觉 primitive 定位
                        ❌ 不改名为 CareerlyGlassSurface
```

> **原则：变体用参数，不用新组件。**
> 只有当两个形态的**行为**真的不同（而不只是样式不同）时，才拆成两个组件。

#### 组件清单

##### ① Baseline §7.5 已规划的组件（**共 8 项，全部**）

`docs/07_Careerly_Development_Baseline_V1.0.md` §7.5「组件优先」列出的完整清单：

| 组件 | 状态 |
|---|---|
| `GlassSurface` | ✅ 已实现 |
| `CareerlyButton` | ✅ 已实现 |
| `CareerlyCard` | ✅ 已实现 |
| `CareerlyChip` | ✅ 已实现 |
| `CareerlyNavigationBar` | ✅ 已实现（Phase 1） |
| `CareerlyProgress` | ✅ 已实现（Phase 2 批 2） |
| `CareerlyBottomSheet` | ✅ 已实现（Phase 2 批 2） |
| `CareerlyToast` | ✅ 已实现（Phase 2 批 2） |

##### ② 已实现、但**不在** Baseline §7.5 的组件

Baseline §7.5 是**规划清单而非穷举**。以下组件已实现且已按本节规则归类：

| 组件 | 归类 | 来源 |
|---|---|---|
| `CareerlyPressFeedback` | 产品级共享组件 | Phase 2 批 1 |
| `CareerlyAsyncStateView` | 产品级共享组件 | Phase 1 |
| `CareerlyInput` | 产品级共享组件 | 2026-09-18（产品侧点名要求，⚠️ **命名待确认**，见待裁决清单 D45） |
| `GlassEdgePainter` | Design Primitive | Phase 2 批 1（自导航栏泛化） |
| `GlassFilters` | Design Primitive | Phase 2 批 1（自导航栏泛化） |

##### ③ 后续规划（**不在** Baseline §7.5，尚未实现）

```text
CareerlyAnalysisProgress      ← 已排期 Phase 6（2026-09-18 移出批 2）
ScoreIndicator                ← 批 3 规划，⚠️ 命名待确认，见下
AIMessageBubble               ← 批 3 规划，⚠️ 命名待确认，见下
```

> ⚠️ **上表仅表示「未来可能需要」，不代表已创建或已批准。**
> 实现前**必须先报告**，不得径行创建。
>
> ⚠️ `ScoreIndicator` / `AIMessageBubble` 的**命名尚未按本节规则复核**
> —— 两者都承载 Careerly 业务语义（匹配度 0–100 / AI 对话），
> 按规则**大概率应加 `Careerly` 前缀**。
> 但本轮裁决只覆盖已实现组件，故**保留原名待实现时确认，不预先改名**。
>
> ⚠️ `CareerlyAnalysisProgress` 是 **Figma 里的页面级复合体**
> （圆环 + 大百分比 + 步骤时间线），不是 design-system 原子组件 ——
> 这正是它被移出批 2 的原因。

#### 与 Material 3 的边界

❌ **禁止**把 Material 3 `NavigationBar` 作为 Careerly 的最终底部导航
❌ **禁止**使用 M3 默认页面转场
✅ Material 3 可作为 Flutter 基础能力使用，但**Careerly 的视觉系统不得被 M3 默认样式主导**

---

## 9. 命令

```bash
flutter pub get                          # 安装依赖
flutter analyze                          # 静态分析 —— 提交前必须干净
flutter test                             # 跑全部测试
flutter test test/widget_test.dart       # 跑单个测试文件
flutter run                              # 在设备/模拟器上运行
flutter build apk --debug                # 构建 debug APK
flutter devices                          # 查看可用设备
```

工作流：完成一个任务后 → `flutter analyze` → 修复 → 跑起来 → 列出改动文件。

> 完整流程（开工读什么 / 收工写什么 / 交付报告模板 / 停止点清单）见
> **`DEVELOPMENT_WORKFLOW.md`**。

---

## 10. 环境陷阱（踩过的坑，别再踩）

### 10.1 ⚠️ `go_router` 必须锁在 `^17.0.0`

```text
go_router 18.x → 依赖 material_ui / cupertino_ui
               → 它们要求 meta >= 1.19（@awaitNotRequired）
               → 但 Flutter SDK 把 meta 锁死在 1.18.0
               → Error: Undefined name 'awaitNotRequired'
```

**`flutter analyze` 抓不到这个错**（它不编译包源码）。
只有 `flutter test` / `flutter build` 才暴露。

升级 go_router 前**必须先确认 Flutter SDK 是否放开了 meta 约束**。

### 10.2 Git Bash 下 `find` 不可用

```bash
find lib -name "*.dart"     # ❌ 找不到文件 - *.dart（编码问题）
```

✅ 改用 **Glob / Grep 工具**。

### 10.3 控制台编码

Windows 中文环境控制台为 GBK，向控制台输出非 GBK 字符会抛
`UnicodeEncodeError`。脚本中避免输出 emoji / 特殊符号。

### 10.4 渐变只画一次

背景渐变由 `CareerlyApp` 的 `MaterialApp.router.builder` **统一绘制一次**。
`CareerlyScaffold` 是**透明** Scaffold。

> 曾经每个页面各画一次，导致底部导航栏上沿出现**肉眼可见的颜色断层**。

---

## 11. 协作方式（Vibe Coding）

> 本节只写**原则**。操作流程见 **`DEVELOPMENT_WORKFLOW.md`**
> （开工必读 / 收工必做 / 报告模板 / 停止点清单）。
> **两处不重复正文 —— 规则归本文件，流程归 WORKFLOW。**

```text
✅ 一个任务 = 一个可独立验收的单元（不要一次性生成整个 App）
❌ 不要修改范围外的代码
✅ 需要新增页面或一级导航 → 先停下来，在产品层面确认
✅ 每个 Phase / 批次结束 → 输出报告 → 停止 → 等待验收
```

**去别处的指针**（不在本节重复）：

```text
Mock First 顺序 + Mock 数据规则  →  §7
任务粒度判断标准                  →  DEVELOPMENT_WORKFLOW.md §2
收工检查 / 报告模板 / 停止点      →  DEVELOPMENT_WORKFLOW.md §1.3 / §4 / §8
```

**每个文件只写它该写的东西** —— 职责划分见 `DEVELOPMENT_WORKFLOW.md` §0。

> ❌ 不要让两个文件描述同一件事 —— 那是文档漂移的起点。
> 曾经导航栏被重写而无人记录，下一个 Session 读到过时描述并据此继续工作。

---

## 12. 当前状态

```text
Phase 0  →  COMPLETE
Phase 1  →  PASS WITH NOTES
Phase 2  →  批 1 + 批 2 + Token 审计 + CareerlyInput 已交付，均未验收
Phase 3  →  已交付（App Shell 视觉定稿 + AI 入口 + 转场），未验收
Phase 4  →  批 1 + 批 2 已交付（Onboarding 六步），均未验收
Phase 5  →  已交付（首页三态 D64），未验收
Current  →  停止点：Phase 3 + 4 + 5 合并验收（含上列四笔旧欠账）
```

**详细状态见 `docs/05_progress/CURRENT_STATUS.md`。**
**当前已停止开发，不进入 Phase 6（分析）。**

> ⚠️ **批 1 从未单独验收过**（产品侧授权跳过，见 `TODO.md` §3.2 · D20）。
> 不得反推「批 1 已确认无误」。
>
> ⚠️ **「已交付」不等于「已验收」** —— Phase 3 / 4 / 5 三批同样是
> **未验收**状态，不得据「已开发完」反推「已确认无误」。

---

**Careerly CLAUDE.md** · 长期开发规则 · 最后更新 2026-09-18
