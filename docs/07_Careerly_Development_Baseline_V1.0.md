# Careerly Development Baseline V1.0

> 项目：Careerly
> 文档：开发基准锁定（Phase 0 交付物）
> 状态：**已锁定**
> 锁定日期：2026-09-17
> 上游：PRD V2.1 / IA V2.1 / Flutter Development Specification V2.1 / Figma Make
> 下游：Phase 1 起的所有开发任务

---

## 0. 本文件的作用

本文件是 Phase 0 的唯一交付物，用于把四份基准来源的冲突**一次性裁决完毕**。

从 Phase 1 开始，任何开发任务遇到歧义，**先查本文件**；本文件未覆盖的，再回到 PRD / IA 原文。

本文件不重复 PRD / IA 的内容，只记录：

```text
1. 来源优先级与冲突裁决规则
2. 已锁定的决策（避免反复讨论）
3. 信息归属表（防止页面之间重复）
4. 尚未锁定的开放项（明确标注阻塞哪个 Phase）
```

---

## 1. 来源优先级与冲突裁决规则

### 1.1 各来源的职责边界

| 来源 | 职责 |
|---|---|
| PRD V2.1 | **产品行为的最高依据** |
| IA V2.1 | **页面归属和导航的最高依据** |
| Figma Make | 视觉、布局、组件、内容层级、**交互表现的参考依据** |
| Flutter Development Specification V2.1 | **工程架构和实现规则** |
| Flutter 实际代码 | 最终可运行产品 |

### 1.2 裁决规则（硬规则）

```text
Figma ≠ PRD
    → PRD 胜

Figma ≠ IA
    → IA 胜

Figma 有视觉效果，但 Flutter 没有对应实现方式
    → 重新实现，而不是放弃视觉

Figma 有一个页面，但 PRD / IA 已确认取消
    → 不实现

Figma 已明确设计出交互细节，但 PRD 描述较粗
    → 采纳 Figma（PRD 的"粗"不等于"否定"）
```

### 1.3 重要说明：三者不要求代码层面一致

```text
Figma Make 是视觉与交互参考稿
PRD + IA 是产品规则
Flutter Development Specification 是工程实现规则
```

三者**不要求代码层面完全一致**。

最终 Flutter 应该**按照已确认的 V2.1 产品规则去实现 Figma 中尚未完善的交互**。

典型例子：

> 「我的」页面的 Tab → Card → Detail 交互，
> Figma 中未实现卡片重排，
> 这是正常的——**Figma 负责卡片视觉，Flutter 负责真实交互逻辑**。
>
> 因此：**不需要为了这个交互重新导出一版 Figma。**

---

## 2. 已锁定的决策

| # | 决策项 | 最终决定 |
|---|---|---|
| 1 | 「我的」Tab / Card 交互 | **Tab → 对应 Card 自动移动到第一位 → 点击 Card → Detail** |
| 2 | 是否重新导出 Figma | **不需要**。Flutter 直接实现交互逻辑 |
| 3 | 历史分析归属 | **只归「分析」**；「我的」不再提供历史分析入口 |
| 4 | 分析额度扣减时机 | **点击「开始分析」时扣减** |
| 5 | 首页岗位变化点击 | **直接进入对应匹配结果**（不是新建分析） |
| 6 | Membership | MVP 做**静态页面 + 额度门禁**，不做真实支付 |
| 7 | AI 会话历史 | **暂不进入 MVP** |
| 8 | Visual Token | **以当前 Figma Make 实际视觉为准**，Flutter 重新归纳 Token |
| 9 | 底部导航 | **自绘 Careerly Navigation**，不使用 M3 `NavigationBar`；**自定义页面转场** |

---

## 3. 信息归属表

> 这一节是开发前最重要的一件事：**锁死每个信息的归属页面，防止同一信息在多处重复。**

### 3.1 首页｜看见现在

只展示：

```text
当前职业状态
最近变化
岗位匹配变化
行动建议
最近成长
今日内容
```

**不要变成完整数据仓库。**

首页只提供**摘要和入口**，不完整复制分析结果。

### 3.2 分析｜看见距离

结构：

```text
分析
│
├── 新建分析
│   ├── 当前简历
│   ├── 添加岗位
│   ├── 岗位列表
│   └── 开始分析
│
└── 历史分析
    ├── 分析项目
    ├── 分析结果
    ├── 更新分析
    └── 历史版本
```

核心逻辑：

```text
简历
 +
多个 JD
 ↓
Analysis
 ↓
匹配度
 ↓
排序
 ↓
优势
 ↓
Gap
 ↓
建议
```

### 3.3 「我的」｜沉积积累

```text
我的
│
├── Tab
│   ├── 职业资产
│   ├── 成长足迹
│   └── 我的简历
│
├── Card Stack
│   ├── 职业资产 Card
│   ├── 成长足迹 Card
│   └── 我的简历 Card
│
└── Settings
    └── 右上角 ⚙（唯一入口）
```

「我的」= **职业资产 + 成长记录**，**不是第二个 History 页面**。

### 3.4 核心职责划分

```text
分析 = 用（查看、比较、更新分析项目）
我的 = 存（管理、沉淀职业资产）
```

---

## 4. 三大模块结构锁定

### 4.1 Onboarding

```text
开屏
 ↓
注册 / 登录
 ↓
职业画像
 ↓
提交简历
 ↓
简历解析
 ↓
确认职业信息
 ↓
进入首页
```

**硬规则：首次注册不输入 JD。**

不包含：

```text
❌ 目标岗位
❌ 岗位分析
❌ 首次匹配
❌ 分析结果
```

原因：

> 首次 Onboarding 的目的不是完成一次分析，而是**建立用户的职业基线**。

之后进入 App：

```text
首页 → 分析 → 添加 JD → 开始分析
```

> ⚠️ Figma Make 中的 `careerly-app-motion-spec.md` §五 把「目标岗位 / 分析 / 分析报告」写进了首次 onboarding 流程，
> 这是 **V2.1 之前的过时残留**，**已作废**，不得作为实现依据。

### 4.2 分析

```text
AnalysisHome
 ↓
New Analysis
 ↓
JD Input
 ↓
Start Analysis
 ↓
Progress
 ↓
Result
 ↓
Job Detail
 ↓
Gap
```

> 「分析中 / Progress」是**页面状态**，不是独立路由，也不是独立页面。

### 4.3 AI

```text
AI Chat
 ↓
当前职业上下文
 ↓
分析结果上下文
 ↓
Gap
 ↓
行动建议
```

**不做 AI 会话历史。**

---

## 5. 额度规则

```text
用户点击「开始分析」
        ↓
    canAnalyze?
   ├── No → 额度不足
   │          ↓
   │       Membership
   │
   └── Yes
        ↓
    扣除 1 次
        ↓
      开始分析
        ↓
    JD 解析 / AI
        ↓
   ┌──────────────┐
   │ 成功         │
   │ 保留分析结果 │
   └──────────────┘

   如果失败
        ↓
   回滚额度
```

### 不扣额度的操作

```text
上传简历        → 不扣
粘贴 JD         → 不扣
进入分析页面    → 不扣
```

> **只有真正开始 AI 分析才扣额度。**
> 避免用户产生「我只是试着粘贴一下，怎么就扣次数了」的问题。

### QuotaState

```text
QuotaState
├── total
├── used
├── remaining
└── canAnalyze
```

免费用户：**3 次**完整分析。

---

## 6. 视觉与 Token 规则

### 6.1 视觉真值来源

> **以当前 Figma Make 的实际视觉为准。**

具体来说：

- 背景渐变、Glass 参数、阴影、圆角 → 取自 `Figma Make / src/App.tsx` 的 `S` 对象
- **不取自** `pasted_text/careerly-design-system.md`（该文档为 V1.0，数值已过期）

### 6.2 Flutter 重新归纳 Token

Figma Make 的字号使用了 15 个非标值（9/10/11/12/13/14/15/17/18/22/24/28/30/40），

> **Flutter 必须重新归纳成一套 Type Scale，不能 1:1 抄原型。**

### 6.3 Token 清单

```text
AppColors
AppTypography
AppSpacing
AppRadius
AppShadows
AppMotion
```

### 6.4 AppMotion 六档（来自 motion-spec §27）

```text
Micro Interaction        80–120ms
Button Feedback         120–200ms
Small Component         180–240ms
Page Transition         240–320ms
Modal / Sheet           300–400ms
Major Result Reveal     400–700ms
```

**不要每个页面随意设置动画时间。**

### 6.5 底部导航

```text
自绘 Careerly Navigation
不使用 Material 3 NavigationBar
```

原因：

> `careerly-design-system.md` §11.4 建议使用 M3 `NavigationBar`，
> 但 `careerly-app-motion-spec.md` §20 与 Figma Make 实现要求 **Liquid Glass 自绘导航**（3 Tab + AI 浮起球，选中态流动 morph）。
> 两者不能同时满足，**采纳后者**。

### 6.6 页面转场

```text
一级导航切换   →  淡入 + 内容轻微上移，180–260ms
二级页面进入   →  右侧轻微进入 (translationX 16–24px)，240–300ms
返回           →  与进入形成相反关系，不允许瞬移或重新淡入整页
Onboarding     →  Progressive Flow，280–320ms
```

**不使用 M3 默认转场。**

---

## 7. 工程规则

### 7.1 目录结构

```text
lib/
├── app/
├── core/
├── design_system/
├── features/
├── data/
└── main.dart
```

### 7.2 分层

```text
UI → State / Controller → Repository → Data Source (API | Local | Mock)
```

**页面不得直接访问 API。**

### 7.3 状态

```text
AuthProvider
ResumeProvider
CareerProvider
AnalysisProvider
AIProvider
AppProvider
```

避免无限膨胀的 Global AppState。

### 7.4 数据模型（需扩展，Flutter Spec §20 不足）

Flutter Spec 定义的 `AnalysisSession { ResumeVersion, Jobs[] }` **不足以表达已确认的产品规则**：

> 「更新分析不是覆盖，旧结果保留，新结果建立新的结果记录。」

Phase 1 需扩展为：

```text
Job               独立实体（可复用、可沉淀进「我的 → 历史岗位」）
AnalysisProject   岗位集合 + 多次 Result
AnalysisResult    versioned（score / rank / gap / capability snapshot）
```

### 7.5 组件优先

```text
Screen 负责组合，Component 负责表现。
不要把整个 Figma Frame 写成一个巨大 Widget。
```

Phase 2 需先建立：

```text
GlassSurface
CareerlyButton
CareerlyCard
CareerlyChip
CareerlyNavigationBar
CareerlyProgress
CareerlyBottomSheet
CareerlyToast
```

---

## 8. 开发阶段顺序

```text
Phase 0  基准锁定            ← 本文件
Phase 1  Flutter 空项目
Phase 2  Design System
Phase 3  App Shell
Phase 4  Onboarding
Phase 5  首页（Mock）
Phase 6  分析
Phase 7  AI
Phase 8  我的
Phase 9  Global States
Phase 10 Android QA
```

### Phase 1 — Flutter 空项目

只建立目录结构，**不写业务页面**。

### Phase 2 — Design System

先 Token，后组件。

### Phase 3 — App Shell

重点验证：

```text
自绘 Bottom Navigation
AI Floating Button
Tab transition
Push / Pop
SafeArea
Android back
Liquid Glass
```

### Phase 8 — 我的

重点处理 **Tab → Card reorder animation**。

> 这是整个 Figma → Flutter 转换过程中**一个真正需要自研的交互**，
> 需要单独验证，不能期望从 Figma 得到参考实现。

---

## 9. 尚未锁定的开放项

以下事项**尚未裁决**，标注了各自阻塞的阶段。

| # | 开放项 | 说明 | 阻塞 |
|---|---|---|---|
| O1 | **字体方案** | Figma Make 混用 Inter / Roboto / Noto Sans SC / Plus Jakarta Sans（原型拼装痕迹）。建议：英文 Inter + 中文 Noto Sans SC | Phase 2 |
| O2 | **成长日历的归属位置** | PRD / IA 完全未提及"成长日历"，但 `my-module-redesign-prompt.md` 与 Figma Make 都实现了它。本次锁定的「我的」首页只有 3 张 Card。→ 日历是放在「我的」首页，还是收进「成长足迹 Card → Detail」？ | Phase 8 |
| O3 | **「历史分析 → 历史版本」是页面还是状态** | 本次锁定的分析结构里列了"历史版本"，但 IA §18 明确"版本对比不作为独立页面"，`careerly-analysis-structure.md` §38 明确"不要增加历史版本页"。→ 应是状态 / Bottom Sheet | Phase 6 |
| O4 | **Careerly Pro 入口是否保留在「我的」首页** | `my-module-redesign-prompt.md` §25 要求保留；本次锁定的「我的」结构未提及 | Phase 8 |
| O5 | **Careerly Pro 的额度语义** | 免费 3 次已锁；Pro 是"无限"还是"每月 N 次"？影响 `QuotaState` 模型 | Phase 9 |
| O6 | **Settings 是否含「关联职业上下文」开关** | IA §16 只列 3 个通知开关；Figma Make 实现了 4 个 | Phase 8（低风险） |
| O7 | **IA Level 3 缺口** | IA §18 列出了 `Membership` 未登记；同时 IA 有「我的 / 历史岗位详情」但 Figma Make 无对应页面 | Phase 8 |

---

## 10. 一句话总结

> **PRD 定行为，IA 定归属，Figma 定视觉，Flutter Spec 定工程，Flutter 代码定最终产品。**
>
> 四者不要求代码层面一致；冲突时按 §1.2 裁决。
>
> Figma 未完善的交互（如 Tab → Card 重排），由 Flutter 按 V2.1 产品规则实现，
> **不需要回头改 Figma。**

---

## End

**Careerly Development Baseline V1.0**
