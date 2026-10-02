# Careerly — Current Status

> **「我们现在做到哪里」**
>
> 本文件只写**现状**。
> 接下来做什么 → `TODO.md` ｜ 为什么这么决定 → `CHANGELOG.md` ｜ 怎么做 → `DEVELOPMENT_WORKFLOW.md`
>
> 最后更新：**2026-10-02**（Session 020）
> 当前状态：**⏸ 暂停 · 「接通 work_agent 已有能力」四项全部走完 · 等待合并验收**
>
> ```text
> ▶ 当前工作流：把 work_agent 里**已经存在**的能力接出来（接线，不是造能力）
>   ① 退出登录        ✅ 已交付 · 已提交（9d879c0）
>   ② 简历资产入口    ✅ 后端（S018）+ Flutter 侧（S019）均已交付 · ⚠️ 未验收
>   ④ 截图 OCR        ✅ 同 ② 一条链路（图片 → OCR → 同一个 ResumeAgent）
>   ③ 岗位 URL        ✅ 后端 + Flutter 侧（S020）均已交付 · ⚠️ 未验收
> ```
>
> ⚠️ **「已交付」不等于「已验收」** —— 本轮证明的是**契约层**
> （端点 / 传输形态 / 字段映射 / 错误归一化，全部在 Fake backend / 桩上钉死），
> **真实端到端（真机 + 真实后端 + 真实爬虫）本轮未跑**（无设备）。
> 恢复时从 `CHANGELOG.md` **Session 020** §8 / §9 的停止点接着做
> （待裁决 D114 / D115）。
>
> 另：**Phase 8A（成长足迹「日历与事件解耦」）已交付 · ⚠️ 未验收**
> · Phase 10 Android QA 仍在「APK 已构建/安装/启动，T1–T14 待执行」
> · 四笔旧欠账（批 1 / 批 2 / Token 审计 / `CareerlyInput`）均 ⚠️ 未验收，
>   Phase 3/4/5/6/7/8 也都仍待合并验收
>
> ```text
> ✅ Phase 3  App Shell 视觉定稿 + AI 入口 + 页面转场
> ✅ Phase 4  Onboarding 六步（批 1 + 批 2）
> ✅ Phase 5  首页三态（D64）
> ✅ Phase 8 已交付：三卡重排 + Card Detail + 设置二级入口 + 成长足迹二级页（日历 + 时间线）
> ✅ Phase 9 第一单元：Loading / Empty / Error / Retry / Disabled 契约测试
> ▶ Phase 10 当前完成设备发现、APK 构建、安装与启动
> ```

---

## 1. 一句话现状

```text
Phase 0 基准锁定  →  Phase 1 工程骨架  →  Phase 2 批 1 + 批 2（⚠️ 均未验收）
                                        +  Token 审计 + CareerlyInput
                                        →  Phase 4 批 1 + 批 2（⚠️ 未验收）
                                        →  Phase 3 视觉定稿（⚠️ 未验收）
                                        →  Phase 5 首页三态（⚠️ 未验收）
                                        →  Phase 6 分析 + Phase 7 AI（⚠️ 未验收）
                                        →  Phase 8 批 1 + 批 2 + 批 3 我的（⚠️ 未验收）
                                        →  ⏹ 停止点：一次合并验收
```

Careerly 的**产品规则、IA、视觉基准、工程约束已经四者对齐并冻结**；
Flutter 侧的**基础设施已全部就位**，且 Phase 2 的组件已落地
（批 1 地基 4 项 + 批 2 反馈层 3 项 + Input 1 项，共 **8 个组件**）；
**Onboarding 六步已全部建成**（开屏 / 注册 / 提交简历 / 建立职业基线 /
确认，加 `on-welcome` 的裁决性缺席），**首页已按 D64 的三态模型建成**。

> ✅ **2026-09-22 更正**：本节此前写着「**首页 / 分析 / 我的** 三个一级页面中，
> 首页已不再是 placeholder；分析 / AI / 我的仍待 Phase 6/7/8」与
> 「四个一级页面仍然是 route placeholder」—— **两句都已过时**
> （Phase 6/7/8 已交付，四个一级页均已接真实页面）。
> 原句保留在 `CHANGELOG.md` Session 015 的核对记录里，此处不再复述。

**四个一级页面现已全部接上真实页面（⚠️ 全部未验收）**：

```text
首页   Phase 5 三态（D64）
分析   Phase 6 新建分析 / 历史分析
AI     Phase 7 Chat UI + Mock Response
我的   Phase 8 批 1（首页三卡 + 二级页）+ 批 2（技能 / 奖项 / 能力）
       + 批 3（成长足迹：周日历条 + 月网格 + 成长时间线，2026-09-23）
```

> 📌 **Phase 2 的执行方式已于 2026-09-18 调整** ——
> 不再「一次性确定所有 Token」，改为
> **「先实现 → 实际视觉验证 → 再裁决 → Token 收敛」**。
> 已有依据的 Token 与暂定 Token 已分开登记，见 **§3.6**。
> **暂定值只写在 Token 层**，后续调整改一处即全系统统一变化。

**但四个一级页面仍然是 route placeholder** —— 业务功能只在
**Onboarding 那 2 页**（开屏 / 注册）上开了口子，首页 / 分析 / AI / 我的仍是空的。

> 📌 **2026-09-18 更新 —— Phase 4 批 1 已交付（**未验收**）**：
>
> ```text
> ✅ 已交付：Onboarding 开屏 + 注册/登录，两页，纯 Mock（D52 授权）
> ⚠️ 交付记录：本轮（D59）才补齐 ——
>    此前 CHANGELOG 无 Session 010，本文件误写「Phase 4 ⛔ 未启动」，
>    属 DEVELOPMENT_WORKFLOW.md §0 明令禁止的文档漂移
> ✅ 后续：批 2 以外的 Phase 3 / 4 批 2 / 5 已由 D60 一并授权并交付
> ```

> 📌 **2026-09-18 更新 —— Phase 3 / 4 批 2 / 5 已全部交付（**均未验收**）**：
>
> ```text
> D60 授权：Phase 3 + 4 + 5 整体开发，验收推迟至 Phase 5 结束
> D64 ⑥ ：第三条红线（禁止自动进入下一 Phase）**仅对 Phase 3/4/5 豁免**
>
> ✅ Phase 3  App Shell 视觉定稿 + AI 入口 + 页面转场 + K4 裁决
> ✅ Phase 4 批 2  提交简历 / 建立职业基线 / 确认（含 6 步收敛 D65）
> ✅ Phase 5  首页三态（State 01 / 02 / 03，按 D64）
> ⏹ 停在这里 —— **Phase 6（分析）及以后未获授权**，不得自动进入
> ```
>
> ⚠️ **这不能反推「Phase 3 / 4 / 5 已确认无误」** ——
> 「已交付」与「已验收」在本项目里是两件不同的事（本文件通篇的记号约定）。
>
> ⚠️ **批 1 的「接线」尚未闭环** —— App 入口仍是 `/home` 而非开屏。
> 原因：D52 限定「不引入本地存储依赖」，而入口判断依赖会话持久化。
> 详见 `TODO.md` §3.1 · **D54**。**裁决前不得改动入口。**

> ⚠️ **批 1 与批 2 的验收状态都是「未验收」，不是「已通过」。**
> 2026-09-18 产品侧授权**跳过批 1 的独立验收**，直接开工批 2
> （`TODO.md` §3.2 · **D20**）。
> 欠账约定：**批 1 + 批 2 合并验收**。
> 在此之前，任何针对这两批组件的判断都仍是**未验证假设**。
>
> 📌 **2026-09-18 更新 —— 停止点已由产品侧具名豁免，但仅限 Phase 3**（**D51**）：
>
> ```text
> ✅ 已授权：Phase 3 开工（App Shell 视觉定稿 / AI 入口定稿 / K4）
>           且视觉定稿改在 桌面 / Chrome 上进行（非 Android 真机）
> ❌ 未授权：Phase 2 批 3（ScoreIndicator / AIMessageBubble / 导航栏 Glass 统一）
> ```
>
> ⚠️ **该豁免没有清偿任何欠账。** 批 1 / 批 2 / Token 审计 / `CareerlyInput`
> 四者的验收状态**仍是「未验收」**；`DEVELOPMENT_WORKFLOW.md` §8.1 要求的
> **欠账清偿方式本次未给出**，故欠账**继续挂账**，不自动并入 Phase 3。
> **不得据本次授权反推「批 1 / 批 2 已确认无误」。**

> ⏸ **Android 真机测试仍未执行**（无设备，K3 未消除）。
> 它被**推迟**而不是**取消** —— 平台相关行为（SafeArea / 返回键 / 中文字体回退）
> 至今**全部未验证**。真机到位后仍需按 `TODO.md` §1.3 的 T1–T14 走一遍。

---

## 2. Phase 状态

| Phase | 名称 | 状态 |
|---|---|---|
| Phase 0 | 基准锁定 | ✅ **COMPLETE** |
| Phase 1 | Flutter 空项目 / 工程基础架构 | ✅ **PASS WITH NOTES** |
| **—** | **Android 真机测试** | ⏸ **推迟**（无设备，未取消） |
| Phase 2 | Design System（组件） | ⏹ **批 1 + 批 2 + Token 审计 + `CareerlyInput` 已交付，均 ⚠️ 未验收** |
| Phase 3 | App Shell 视觉定型 | ✅ **已交付**（2026-09-18，D51/D60）· ⚠️ **未验收** —— 仅桌面 / Chrome 视觉；Android 侧仍被 K3/K1 挡住 |
| Phase 4 | Onboarding | ✅ **批 1 + 批 2 已交付** · ⚠️ **均未验收**（D60） |
| Phase 5 | 首页（Mock） | ✅ **已交付**（2026-09-18，D60）· ⚠️ **未验收** |
| Phase 6 | 分析 | ✅ 单岗位 Mock 闭环已交付 · ⚠️ **未验收**（2026-09-21 的 3 个点击命中失败**已修**，见 §3.2）<br>＋ **③ 岗位 URL「抓取回填 JD 文本框」已接真实后端**（2026-10-02，Session 020 · ⚠️ 未验收 · Mock 下此路径必然报错，见 D114） |
| Phase 7 | AI | ✅ Chat UI + Mock Response 已交付 · ⚠️ **未验收** · Career Context / Real API 未开始 |
| Phase 8 | 我的（Tab → Card reorder） | ✅ **批 1 + 批 2 + 批 3 已交付**（批 2 = 技能 / 奖项 / 能力 三页，2026-09-22；批 3 = 成长足迹二级页：周日历条 + 月网格 + 成长时间线，2026-09-23，D91 已裁决）· ⚠️ **未验收** |
| Phase 9 | Global States | ⛔ **未获授权**（`test/phase9_global_state_test.dart` 只覆盖 Phase 1 的 `CareerlyAsyncStateView` 四态契约，**不是**新功能 —— 见 §4 尾部的文档欠账说明） |
| Phase 10 | Android QA | ▶ Android 16 真机已连接 · APK 构建/安装/启动完成 · T1–T14 待执行 |

### 2.1 Phase 2 分批

> 2026-09-17 产品侧决定：**分批交付，每批暂停验收**。

| 批 | 内容 | 状态 |
|---|---|---|
| **批 1** | **地基**：`GlassSurface` · `CareerlyButton` · `CareerlyCard` · `CareerlyChip` | ✅ 已交付 · ⚠️ **未验收**（已授权跳过） |
| **批 2** | 反馈层：`CareerlyProgress` · `CareerlyBottomSheet` · `CareerlyToast` | ✅ 已交付 · ⚠️ **未验收** |
| 批 3 | 领域组件：`ScoreIndicator` · `AIMessageBubble` · 用 `GlassSurface` 重做导航栏 Glass（合并 K10 / K12） | ⛔ 未启动 |

> ⚠️ **批 1 与批 2 都未经过验收。** 批 1 由 2026-09-18 产品侧授权跳过
> （`TODO.md` §3.2 · D20）。
> **欠账：批 1 + 批 2 合并验收。**
>
> 批 2 的前置 **K6（`flutter_localizations`）已落地**；
> **K1（字体）仍未落地**，故两批的**排版一栏都不能盖章**。

**批 2 相对原计划的变更**：`CareerlyAnalysisProgress` **移出批 2 → Phase 6**
（`TODO.md` §3.2 · D28）。它是 Figma 里的**页面级复合体**，不是 design-system 原子组件。

---

## 3. 工程现状

### 3.1 技术栈

| 项 | 值 |
|---|---|
| Flutter | 3.44.0 stable（revision `559ffa3f75`） |
| Dart | 3.12.0 |
| 路由 | `go_router ^17.0.0` ⚠️ **上限必须 <18.0.0**（见 K2） |
| 状态 | `provider ^6.1.5+1`（Provider + ChangeNotifier） |
| Lint | `flutter_lints ^6.0.0` |
| 目标平台 | Android-first |

### 3.2 可运行性（**2026-10-02 实测**）

```bash
cd /g/ai_agent/careerly
flutter analyze   →  No issues found!                  (8.0s／复核 119.1s)
flutter test      →  All tests passed!（215 / 215 + 1 skipped）  (2026-10-02 Session 019 当次)
```

> ⚠️ **上一版此处记的是 `158/158`（2026-09-22）** —— 已过期三批交付。
> 本轮数字**独立复算**过：`grep -c "testWidgets(\|test(" test/*.dart test/*/*.dart`
> = **216**，减 1 条默认 skip 的 `real_backend_integration_test` → **215 passed**。
> `flutter analyze` 耗时 8.0s → 复核时 119.1s，同一结论。

> ✅ **2026-09-18 的那 1 个红灯已消失** ——
> 它曾指向 `test/widget_test.dart` 的「可以切换到『分析』，并保留分支状态」
> （断言 Phase 1 的分析页 placeholder 文案）。该断言已按 §1 的同型做法
> 改为**断言页面类型**，随 Phase 6 交付一并收口。
> 原文（保留以追溯）：**处置：只报告，不修改** —— 分析页属 Phase 6，未获授权。
> 见 `CHANGELOG.md` Session 011。
>
> ℹ️ 更早的一轮还**修好**了首页的两处同类红灯（`首页 · 看见现在` /
> `find.text('首页')`）—— 它们是被 Phase 5 改动直接打破的，故在范围内，
> 已改为断言**页面类型**而不是会随三态变化的页内文案。

`flutter build apk --debug` / `flutter devices` **本轮未跑**：

```text
flutter build apk --debug  →  ⏸ 本轮未执行（无 Android 设备）
flutter devices            →  Windows / Chrome / Edge —— ⚠️ 无 Android 设备（K3）
```

> 📌 **数字演进**：`10/10` → `24/24`（实为 25）→ `42/42` → `58/58`
> → `72/72` → `96/97`（1 失败）→ `128/128`（Phase 6/7/8 批 1）
> → `158/158`（2026-09-22，Phase 8 批 2）→ `180/180`（2026-09-30 全量审查）
> → **`215/215 + 1 skipped`（2026-10-02，Session 019）**。
> 差异与更正说明见 `CHANGELOG.md` Session 006 · 第七节、Session 007、008、010、011、015、019。

> ⚠️ **`cd` 到仓库根再跑。** Bash 工具的工作目录会在调用之间保持 ——
> 曾因此导致 `flutter analyze` 分析了错误的目录、`flutter test` 找不到 `test/`。
> 本项目的命令一律写明 `cd /g/ai_agent/careerly`。

> ⚠️ **测试结论有保质期。**
>
> 这份结论**曾两次失真**：
>
> ```text
> ① Session 003–004   文档写 10/10，实测 6 通过 / 4 失败   —— 结论过期
> ② Session 004–005   文档写 24/24，实测 25/25            —— 数字记错
> ```
>
> **教训**：光「重跑」不足以保证数字正确 —— 必须让数字**可被独立复算**。
> 引用测试数字时请**连同产出它的命令一起写**，并注明实测日期。

**产物路径**：

```text
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-debug.apk.sha1
```

### 3.3 代码规模

```text
lib/          119 个 Dart 文件 / 24682 行
test/          14 个测试文件 / 4080 行（**158** 用例）
assets/fonts/    1 个 README（⚠️ 字体文件仍缺失，见 K1）
```

**复算命令**（数字必须可被独立复算 —— 见 §3.2 的教训）：

```bash
cd /g/ai_agent/careerly
ls -R lib | grep -c "\.dart$"                              # → 119
cat $(ls lib/*/*.dart lib/*/*/*.dart lib/*/*/*/*.dart lib/*.dart) | wc -l
#                                                          # → 24682（含未跟踪文件）
wc -l test/*.dart | tail -1                                # → 4080
grep -c "testWidgets(\|test(" test/*.dart
# → 9 (app_debug_entry) / 15 (design_system) / 17 (phase2_batch2)
#   / 16 (phase2_input) / 9 (phase4_batch2) / 23 (phase4_onboarding)
#   / 16 (phase5_home) / 18 (phase6_analysis) / 2 (phase7_ai)
#   / 3 (phase8_profile) / 6 (phase8b_profile) / 10 (phase8c_profile)
#   / 4 (phase9_global_state) / 10 (widget)                = 158
```

> ⚠️ `lib/` 的数字含**未跟踪文件**（`git status` 里成片的 `??`），
> 因此它比一次干净 checkout 后的数字大。复算请用上面这条命令原样跑。
>
> 📌 用例数演进：`10` → `24`（**实为 25，误记**）→ `42` → `58` → `72` → `97`
> → `128`（Phase 6/7/8 批 1）→ **`158`（2026-09-22，Phase 8 批 2）**。
> 25 → 24 那次误记见 `CHANGELOG.md` Session 006 · 第七节。
>
> ⚠️ **两次大跃进的原因不同**：
> `97 → 128` 是 Phase 6 / 7 / 8 批 1 在同一授权下连续交付（+31）；
> `128 → 158` 是 Phase 8 批 2 补测（+10，`test/phase8c_profile_test.dart`）。

### 3.4 已建成的基础设施

| 层 | 产物 |
|---|---|
| Design Token | `AppColors` / `AppTypography` / `AppSpacing` / `AppRadius` / `AppShadows` / `AppMotion` |
| Theme | `CareerlyTheme`（未被 Material 3 默认样式主导） |
| Router | `createAppRouter()` — 4 条一级 route，`StatefulShellRoute.indexedStack` |
| App Shell | `CareerlyShell`（SafeArea / 内容区 / Tab 状态 / Tab 切换 / 转场架构） |
| 自绘导航 | `CareerlyNavigationBar`（**非 M3 `NavigationBar`**） |
| State | `AsyncState<T>` + `AsyncStateNotifier<T>` + 5 个 Provider |
| Repository | 4 个 `abstract interface class` |
| Mock | 4 个 Mock 实现 + `MockConfig`（延迟 / 失败开关） |
| Error | `AppError` + 6 个 sealed 子类 + `ErrorHandler` |
| Motion | `AppMotion` 六档时长 + 6 条曲线 + 位移量 |
| 四态渲染 | `CareerlyAsyncStateView<T>`（Loading / Empty / Error / Success） |
| Glass 基元 | `GlassEdgePainter` / `GlassFilters` / `GlassSurface`（Phase 2 批 1） |
| 组件 · 批 1 | `CareerlyButton` / `CareerlyCard` / `CareerlyChip` / `CareerlyPressFeedback` |
| 组件 · 批 2 | `CareerlyProgress`（线性确定型）/ `CareerlyBottomSheet`（3 档 tone）/ `CareerlyToast` |
| 组件 · Input | `CareerlyInput`（4 档 variant × 2 档 tone，含 Error / Disabled 两态） |
| 本地化 | `flutter_localizations` + `supportedLocales: [zh_CN]`（2026-09-18 落地 K6） |
| 页面 · Phase 4 批 1 | `OnboardingSplashPage`（开屏）/ `OnboardingRegisterPage`（注册·登录落点）/ `OnboardingProgressHeader`（步骤进度头） |
| State · Phase 4 批 1 | `OnboardingProvider` —— `idle / submitting / success / failure` 四态；**刻意不复用 `AsyncStateNotifier<T>`**（注册返回 `void`，为塞泛型而编造 `Account` 会违反 §7「不编造产品数据」） |
| Repository · Phase 4 批 1 | `AuthRepository`（仅 `register`）+ `MockAuthRepository` —— **纯 Mock，不接鉴权、不写本地存储、不保存会话**（D52） |
| 页面 · Phase 4 批 2 | `OnboardingResumePage`（提交简历 + 粘贴弹层）/ `OnboardingParsingPage`（建立职业基线）/ `OnboardingConfirmPage`（确认） |
| 页面 · Phase 5 | `HomePage`（三态）+ `HomeHeader` / `HomeHeroCard` / `HomeStilCards` / `HomeAnalysisSection` |
| 内容装配 · Phase 5 | `HomeContent.forStage()` —— 三态**全部文案差异**的唯一落点；视觉组件不认识 `HomeStage`，使 D64 ①bis「只换文字」在结构上成立 |
| 首页三态 · Phase 5 | `HomeStage.firstUse / baselineOnly / analyzed` —— **只读 `HomeSummary`** 判定，不跨读 `ResumeProvider`（§6.1） |
| Motion · Phase 3 | `lib/design_system/motion/` —— 页面转场与 Tab 切换曲线收口（Baseline §6.6，不用 M3 默认转场） |

### 3.5 尚未建立

- ❌ **另三个一级页面的业务功能**（分析 / AI / 我的 —— **首页已不再是 placeholder**）
- ❌ Phase 6+（分析 / AI / 我的 / Global States / Android QA）—— **未获授权**
- ❌ **App 入口接线** —— 仍是 `/home` 而非开屏；依赖会话持久化，**裁决前不得改动**（D54）
- ❌ 独立登录页 —— Figma 中「登录」不拥有页面，两个按钮都跳注册（D55）
- ❌ Phase 2 批 3 组件（`ScoreIndicator` / `AIMessageBubble`）
- ❌ Phase 6 才做的 `CareerlyAnalysisProgress`（页面级复合体，D28）
- ❌ `ApiClient`（无真实后端调用）
- ❌ 本地存储、鉴权、会员、支付
- ❌ 导航栏与 `GlassSurface` 的统一（**存在临时重复实现**，见 K10）
- ❌ Glass 的统一收口 —— 批 2 又添了**第三处**组合（**K12**）
- ❌ 字体的实际落地（**K1** 未消除 → 两批的排版都不能盖章）
- ❌ BottomSheet 的下滑关闭 / Toast 变体 / 不确定型进度（**设计侧未定义**，D34 / D26）
- ❌ 输入框的聚焦态 / 占位符样式 / 错误态边框（**Figma 完全没有定义**，D46）
- ❌ 4 套输入形态是否收敛（**属设计决策**，Flutter 侧原样保留，D45）
- ❌ 首页 State 02 / 03 的**界面走查路径** —— 当前 Mock 只返回空摘要，
      故点击走查只能到 State 01（**D75**）
- ❌ 首页「上传简历」的**应用内落点** —— 现复用 Onboarding 页（**D80**）
- ❌ 「最近成长」卡的**成长页落点** —— 现落「我的」Tab（**D81**）

---

### 3.6 暂定 Token 集中登记表（2026-09-18 建立）

> **为什么有这张表** —— Phase 2 的执行方式已调整为
> 「**先实现 → 实际视觉验证 → 再裁决 → Token 收敛**」。
> 因此现在**不追求一次性确定全部 Token**，而是明确区分
> 「**已有依据的**」与「**暂定的**」，让后续调整只改 Token、不改业务代码。
>
> **本表是查暂定值的唯一入口。** 争议的裁决记录在 `TODO.md` §3.1。
>
> ---
>
> #### 集中管理规则（硬规则）
>
> ```text
> ✅ 暂定值只允许出现在 lib/design_system/tokens/ 里
> ❌ 不得在组件 / 页面里内联任何一个暂定数值
> ✅ 要调整视觉 → 只改 Token → 全系统统一变化
> ```
>
> 这是「Token 收敛」能成立的前提：
> **只要暂定值不散落，后续调整就永远是改一处。**
> `flutter analyze` 抓不到硬编码数值，因此靠**代码评审**与**本表**保证。

#### ⚠️ 暂定值清单

| Token | 当前值 | 为什么是暂定的 | D |
|---|---|---|---|
| `AppSpacing.pageHorizontal` | `16` | **Figma 最主流是 20**（`px-5` 47 次 vs `px-4` 12 次）—— **选错了档** | D37 |
| `AppSpacing.pageTop` / `pageBottom` | `24` / `32` | Figma 无对应语义名 | D41 |
| `AppSpacing.cardPadding` | `16` | `p-5`(20) 21 次 / `p-4`(16) 20 次 —— **几乎持平，难以判定** | D41 |
| `AppSpacing.listGap` | `12` | Figma 无对应语义名 | D41 |
| `AppTypography` Type Scale **整节** | 11 个角色 | **Figma 没有 Type Scale**（22 个零散字号）；**行高与字距完全没有来源** | D40 |
| `AppTypography.numeric.fontSize` | `32` | **不在 Figma 的 22 个字号里**（最接近 30 / 36） | D38 |
| `AppRadius.input` | `16` | Figma 输入框**不统一**：工作台 16 / a-jd-step 12 | D39 |
| `AppRadius.sheet` | `28` | 只覆盖 Figma 两种圆角中的一种（另一半是 24） | D29 |
| `AppRadius.card` / `cardSmall` / `button` | `24` / `16` / pill | Figma 无语义名，是按出现次数挑的 | D41 |
| `AppShadows.sm` | `0.06 / 0 2px 8px` | **Figma 中无对应原值** | D42 |
| `AppShadows.brand` | `0.20 / 0 10px 24px` | **无逐位一致值**（Figma 本身有 4 套近似值） | D42 |
| `AppShadows.sheet` | `= md` | **很可能取错了源**（`md` 是一张 Glass 信息卡，不是 Sheet） | D35 |
| `AppColors.backgroundFallback` | `#EDE9FA` | **Figma 中出现 0 次** | D43 |
| `AppColors.disabled` | `rgba(17,24,39,0.38)` | **Figma 中出现 0 次**（**7 处引用**，影响面最大的一项） | D43 / D16 |
| `AppColors.info` | `#4F7EF5` | Figma **没有「信息」语义色**（只有 green / orange） | D43 |
| `AppMotion.stagger` | `40ms` | **落在 motion-spec 规定的 50–80ms 之外**（当前 0 处引用） | D36 |
| `AppMotion.enter` / `exit` / `pageCurve` / `cardCurve` | Material 内建曲线 | spec 只给了文字描述（「ease-out」），**没给 `cubic-bezier`** | D49 |
| `CareerlyTheme._inputDecorationTheme` | M3 `filled + outline` | **Figma 中没有任何输入框使用这套样式**（当前无业务引用） | D44 |
| `CareerlyInput` 占位符色 | `textTertiary` | Figma **没有 `::placeholder` 规则**，占位符用的是浏览器默认色 | D46 |
| `CareerlyInput` 错误色 | `danger` | Figma **没有任何输入框错误态**；错误态边框**有意保持中性**，未发明红色 | D46 |
| `_InputMetrics.underlineLabelGap` | `4` | Figma 标签与输入框之间**无显式间距**（被 Tailwind preflight 清零） | D48 |
| `_InputMetrics.cursorWidth` | `1.5` | Figma 未定义光标宽度（⚠️ 光标**颜色**有定义，取品牌色） | D48 |
| `CareerlyInput` 的 4 档 variant 是否收敛 | 原样保留 4 档 | **属视觉方向的重大决策**，Flutter 侧不代替设计侧拍板 | D45 |
| `AppTypography.homeEmptyBody` | `12 / w400 / lh1.5` | **Figma 没有首页空态** —— 该角色是为 State 01 / 02 的引导语新造的 | D79 |
| `AppTypography.homeEmptyAction` | `14 / w700 / primaryBlue` | 同上（行动行「分析第一个岗位 →」） | D79 |

#### ✅ 已有明确依据（**不是**暂定值）

> 这些**不需要视觉验证**就能确定，改动它们等于改设计真值。

| Token | 依据 |
|---|---|
| `AppColors` 的**绝大多数**值 | `App.tsx` 的 `S` 对象 + 逐处内联色值（多为 10 次以上命中） |
| `AppColors` 的 `progress*` / `sheet*` / `nav*` 全套 | Figma 逐层还原，逐位一致 |
| `AppShadows.glass` / `glassLight` / `md` / `button` / `primaryButton` | `App.tsx` L27-28 / L3166 / L411 / L147 逐位一致 |
| `AppShadows.nav*` 全套 | Figma `BottomNav` 逐层还原 |
| `AppMotion` 六档时长 | motion-spec §27 的区间定义 |
| `AppMotion.standard` / `emphasized` | Figma 给出的两个真实 `cubic-bezier` |
| `AppRadius` **六个刻度值** + pill | 12/14/16/20/24/28/999 均能在 `App.tsx` 内联 `borderRadius` 中找到 |
| `AppTypography` **组件级角色**（6 个） | `buttonPrimary` / `buttonSecondary` / `chipSmall` / `chipMedium` / `navAiGlyph` / `navAiLabel` 全是 Figma 原值 |
| `AppSpacing` **九个刻度值** | 4/8/12/16/20/24/32/40/48 均有 Tailwind 对应 |
| `AppColors` 的 **8 个 `input*` 值** | 全部来自 Figma 4 处输入控件的内联色值（含 `#727272` 标签色） |
| `AppTypography` 的 **5 个 `input*` 角色** | `inputLabel`(14/w700) / `inputLabelInline`(12/w600) / `inputFieldUnderline`(16) / `inputFieldCompact`(13) / `inputHelper`(11) 全是 Figma 原值 |

> ⚠️ **区分「刻度值」与「语义别名」** ——
> 刻度值有依据，**语义别名（挑哪一档）是归纳的**。
> 上表「已有依据」只覆盖刻度值本身。

#### 收敛方式

```text
现在   ：暂定值 → 只写在 Token 里，标注「待视觉验证」
后续   ：真实页面出来 → 看整体视觉关系 → 裁决
调整时 ：只改 Token 一处 → 全系统统一变化
       ❌ 不需要改任何组件 / 页面代码
```

---

## 4. 已完成内容

### ✅ Phase 0 — COMPLETE

- [x] 四来源一致性分析（A–E）
- [x] 9 个开放问题全部裁决（Baseline §2）
- [x] 信息归属表锁定（首页 / 分析 / 我的）
- [x] 冲突裁决规则写入 Vibe Coding Prompt
- [x] `docs/07_Careerly_Development_Baseline_V1.0.md` ✅

### ✅ Phase 1 — PASS WITH NOTES

- [x] 环境与项目状态检查（报告 §1–§2）
- [x] 目录结构（`app/` `core/` `design_system/` `data/` `features/`）
- [x] 6 个 Design Token
- [x] `CareerlyTheme`
- [x] Router + 4 条一级 route
- [x] App Shell + 自绘 `CareerlyNavigationBar`
- [x] State 基类 + 5 个 Provider
- [x] 4 个 Repository 接口 + 4 个 Mock
- [x] Error 基础设施（6 类错误）
- [x] Motion 基础设施（六档）
- [x] 四态渲染组件 `CareerlyAsyncStateView`
- [x] `flutter analyze` 零 issue
- [x] 10 个冒烟测试全过
- [x] `flutter build apk --debug` 成功
- [x] `docs/phase_1_report.md`（22 节）✅

### ⚠️ Phase 2 — 批 1 已交付（**未验收**）

> 📌 **验收状态：⚠️ 未验收。**
> 2026-09-18 产品侧授权跳过批 1 的独立验收（`TODO.md` §3.2 · D20）。
> **欠账：批 2 交付时，批 1 + 批 2 合并验收。**
> 下列勾选项表示**已完成交付**，**不表示已通过验收**。

- [x] `GlassSurface` + 玻璃基元（`GlassEdgePainter` / `GlassFilters`）
- [x] `CareerlyButton`（primary / secondary，含 Disabled 态）
- [x] `CareerlyCard`（glass / glassLight / brand / surface）
- [x] `CareerlyChip`（8 种语义色调 × 2 种尺寸）
- [x] `CareerlyPressFeedback`（按压反馈，卡片与后续组件复用）
- [x] Token 补齐：语义色底衬 · 组件级 Typography · 主按钮投影 · 禁用文字色
- [x] **15** 个新测试用例（`test/design_system_test.dart`）
- [x] `flutter analyze` 零 issue · `flutter test` **25/25**（2026-09-18 复核更正，原记 14 / 24）

**批 1 明确未做**（属批 2 / 批 3）：`CareerlyProgress` · `CareerlyBottomSheet` ·
`CareerlyToast` · `ScoreIndicator` · `AIMessageBubble` · 导航栏 Glass 统一。

### ⚠️ Phase 2 — 批 2 已交付（**未验收**）

> 📌 **验收状态：⚠️ 未验收。**
> **欠账：批 1 + 批 2 合并验收**（`TODO.md` §1.1）。
> 下列勾选项表示**已完成交付**，**不表示已通过验收**。

- [x] `CareerlyProgress` —— 线性**确定型**进度条（Figma `OnboardingProgress`）
      · 还原 `left:-4px` / `calc(pct% + 4px)` 的固有细节 · 入场 0 → value
- [x] `CareerlyBottomSheet` —— **参数化 shell + 3 档 tone 预设**（D27）
      · scrim 自绘 backdrop blur · 仅顶部圆角 · 三档分别为白 / 半透明 / Glass 面板
- [x] `CareerlyToast` —— 视觉按 **D26** 用**已有 Token** 补齐（**非设计值**）
      · `liveRegion` 无障碍播报 · 不拦截下方点击 · 自动消失
- [x] Token 补齐：进度轨道 / 172deg 进度渐变 · 3 档 scrim · 2 档面板填充 · 2 档把手色
- [x] **17** 个新测试用例（`test/phase2_batch2_test.dart`）
- [x] `flutter analyze` 零 issue · `flutter test` **42/42**（2026-09-18）

**批 2 明确未做**（因**设计侧未定义**，见对应条目）：

```text
下滑关闭 / 高度档位        → D34（Figma 无法表达拖拽手势）
Toast 变体 / 撤销型         → D26（Figma 无任何视觉区分）
不确定型进度条              → 无视觉定义
CareerlyAnalysisProgress   → 移出批 2，改归 Phase 6（D28）
```

**批 2 新增待裁决项**：D29–D34（`TODO.md` §3.1）。

### ⚠️ Phase 2 — Token 审计 + `CareerlyInput`（**不在原分批计划内**）

> 📌 **执行方式已于 2026-09-18 调整** ——
> 不再「一次性确定所有 Token 的最终值」，改为
> **「先实现 → 实际视觉验证 → 再裁决 → Token 收敛」**。
> 集中登记表见 **§3.6**。

这一项包含三个动作，都**不属于原定的批 1 / 批 2 / 批 3 任何一批**：

#### ① Token 依据审计

逐个 Token 文件核查「哪些有 Figma 明确依据、哪些属暂定」：

| 文件 | 结论 |
|---|---|
| `app_colors.dart` | ✅ 绝大多数有依据（多为 10 次以上命中）· ⚠️ 3 项出现 **0 次** |
| `app_typography.dart` | ✅ 组件级角色有依据 · ⚠️ **整节 Type Scale 是归纳值**（Figma 无 Type Scale） |
| `app_spacing.dart` | ✅ 九个刻度值有依据 · ⚠️ **全部语义别名是归纳的**，其中 `pageHorizontal` **选错了档** |
| `app_radius.dart` | ✅ 六个刻度值有依据 · ⚠️ 语义别名是归纳的 |
| `app_shadows.dart` | ✅ 多数逐位还原 · ⚠️ `sm` / `brand` 无逐位来源，`sheet` **取错源** |
| `app_motion.dart` | ✅ 六档时长 + 两条曲线有依据 · ⚠️ `stagger` **落在 spec 区间之外** |

**结果**：**22 行**暂定值集中登记到 §3.6（部分行合并了同类 Token），
全部**只标注、未改值**
（改值属视觉决策，按 `CLAUDE.md` §0 第一禁令不得自决）。

#### ② `CareerlyInput`（产品侧点名要求）

产品侧明确要求 **Button / Card / Input / Chip / Navigation 五者先完成可运行实现**，
Input 是其中唯一尚不存在的。

- [x] 4 档 variant（`underline` / `boxed` / `filled` / `plain`）+ 2 档 tone（蓝 / 紫）
      —— 全部对应 Figma 真实存在的写法，**原样保留、不做收敛**（D45）
- [x] Error / Disabled 两态；Loading / Retry **显式声明不适用**（不硬塞）
- [x] 用 `InputDecoration.collapsed` 绕开无 Figma 依据的 M3 输入主题（D44）
- [x] 字数计数器放在**标题行**（Figma 位置），不用 Material 的右下角计数器
- [x] Token 补齐：8 个 `input*` 色值 + 5 个 `input*` 排版角色
- [x] **16** 个新测试用例（`test/phase2_input_test.dart`）
- [x] `flutter analyze` 零 issue · `flutter test` **58/58**（2026-09-18）

**新增待裁决项**：D35–D49（`TODO.md` §3.1）。

**明确未做**：

```text
输入框的聚焦态样式        → Figma 完全没有 :focus 规则（D46）
占位符样式 / 错误态边框    → Figma 没有 ::placeholder / 错误态（D46）
4 档 variant 的收敛       → 属视觉方向决策，Flutter 侧不拍板（D45）
```

> ⚠️ **停止点仍然有效。** 本轮是**审计 + 一个具名组件的实现**，
> 不构成进入批 3 的授权 —— 批 3（`ScoreIndicator` / `AIMessageBubble` /
> 导航栏 Glass 统一）的前置仍是「**批 1 + 批 2 合并验收通过**」。

### ⚠️ Phase 4 — 批 1 已交付（**未验收**）

> 📌 **验收状态：⚠️ 未验收。**
> 授权依据：**D52**（产品侧具名，仅批 1：开屏 + 注册/登录，纯 Mock）。
> **交付记录于 2026-09-18（D59）补齐** —— 此前 CHANGELOG 无 Session 010，
> 本文件误写「Phase 4 ⛔ 未启动」。下列勾选项表示**已完成交付**，
> **不表示已通过验收**。

- [x] `OnboardingSplashPage` —— 开屏：品牌名 / 标语 / 「点击登录」「点击注册」
      · 顶部**未做** Figma 的自绘 iOS 状态栏（归 **K13**，非本批范围）
- [x] `OnboardingRegisterPage` —— 注册（**也是登录的落点**，见 D55）
      · 姓名 / 手机号 / 邮箱（选填）三字段 · 「继续」+「跳过，稍后完善」
- [x] `OnboardingProgressHeader` —— 步骤进度头（复用 `CareerlyProgress`）
- [x] `OnboardingProvider` —— `idle / submitting / success / failure` 四态
- [x] `AuthRepository` + `MockAuthRepository` —— 纯 Mock 链路
      `UI → State → Repository → Mock`
- [x] **14** 个新测试用例（`test/phase4_onboarding_test.dart`）
- [x] `flutter analyze` 零 issue · `flutter test` **72/72**（2026-09-18 当次实测）

**批 1 新增待裁决项**：**D54–D58**（`TODO.md` §3.1）——
它们此前**只活在源码注释里**，本轮才建档。另补登 **D53**（§3.2）。

**批 1 明确未做**：

```text
价值介绍 / 提交简历 / 解析 / 确认 / 职业基线   → 批 2+，未获授权
独立登录页                                  → Figma 中不存在，属产品决策（D55）
App 入口接线（启动即进开屏）                  → 依赖会话持久化（D54）
表单校验规则（手机号格式 / 验证码）            → Figma 未定义，未自行发明（D57）
状态栏（SystemChrome / AnnotatedRegion）      → 归 K13，需先裁决 D50
```

---

### ⚠️ Phase 3 — App Shell 视觉定稿（2026-09-18，D51/D60）（**未验收**）

> 📌 **验收状态：⚠️ 未验收。** 视觉定稿在**桌面 / Chrome** 上进行
> （D51），**Android 真机仍未跑**（K3）—— 因此本节的视觉结论
> **不覆盖平台相关行为**（SafeArea / 中文字体回退 / 返回键）。

- [x] 页面转场收口 —— `CareerlyPageTransitions`（`slide` / `onboarding`）
      · 一级 Tab 切换用 Figma 的 `.page-tab`（200ms / `translateY(8px)`）
- [x] Onboarding 转场改为**水平** `translateX(24px)`（300ms）——
      早先误用垂直 `fadeUp`，Phase 3 已更正
- [x] AI 入口的视觉定位（一级 Tab，允许特殊视觉表现）
- [x] K4 裁决（见 `TODO.md` §3.2）

**Phase 3 收口仍挂着的项**（未闭合，**不得**当作已完成）：

```text
P3-2  AI 入口视觉定稿          A-1 重复描边 / A-2、A-3 时序 / A-4 字体族
P3-7  Liquid Glass / K10 / K12
K13   状态栏 —— 需先裁决 D50
```

**Phase 3 新增待裁决项**：D62（转场位移与 Figma 的刻意偏差）

---

### ⚠️ Phase 4 批 2 — 提交简历 / 建立职业基线 / 确认（2026-09-18）（**未验收**）

> 📌 **验收状态：⚠️ 未验收。** 与批 1 一并挂在 D60 的合并验收里。

- [x] `OnboardingResumePage` —— 提交简历（选择文件 / 粘贴文本两条路径）
      · ⚠️ 「选择文件」**未接线**（纯 Mock 阶段无文件选择能力，**D67**）
- [x] `OnboardingParsingPage` —— 建立职业基线（**D63**：保留 Figma 视觉，
      5 条步骤文案换成「职业基线」语义；**不得**出现岗位 / 匹配度 / Gap）
      · 两条时钟：时间线 + 数据调用（**D73**）
      · 文案由 AI 起草（**D66**）
- [x] `OnboardingConfirmPage` —— 确认职业信息 + 「进入 Careerly」
      · Mock 空档案下汇总卡走 Empty 态，**不编造** 4 / 6 / 12 / 5（D64 ⑥）
- [x] **9** 个新测试用例（`test/phase4_batch2_test.dart`）
- [x] 链路由 D65 收敛为**六步**：开屏 → 注册/登录 → `on-welcome` →
      提交简历 → 解析 → 确认（`on-welcome` 的裁决性缺席见 D61）

**Phase 4 批 2 新增待裁决项**：**D66–D74**（`TODO.md` §3.1）

---

### ⚠️ Phase 5 — 首页三态（2026-09-18，D64）（**未验收**）

> 📌 **验收状态：⚠️ 未验收。**
> **授权依据**：**D60**（Phase 3 + 4 + 5 整体授权）。
> **规格依据**：**D64**（首页三态模型 + 首登 Empty State 规格），
> 其 ①bis 铁律为「**只替换文字内容，不要修改 figma 视觉设计**」。

**三态模型（D64）**：

```text
State 01  首次使用（没有职业基线）        → 文案 = D64 ② 逐字
State 02  已有简历（有基线、无岗位分析）  → ⚠️ 文案为 AI 起草（D76）
State 03  已有简历 + 岗位分析             → Figma 现有那版首页 + 真实数据
```

- [x] `HomeProvider.stage` —— 三态判定**只读 `HomeSummary`**
      （`hasBaseline` / `matchChanges.isEmpty`），不跨读其他 Provider（§6.1）
- [x] `HomeContent.forStage()` —— 三态**全部文案**的唯一落点
      · 视觉组件（`HomeHeader` / `HomeHeroCard` / `HomeStilCards` /
        `HomeAnalysisSection`）**不认识 `HomeStage`**
      · → 「只换文字」因此**在结构上成立**，不靠自觉
- [x] `HomeHeader` —— 身份区（`主页` + 主标题 + 头像 + 在线点）
      · 头像用**人像字形**而非 Figma 的字母 `A`（无用户姓名字段，D76）
- [x] `HomeHeroCard` —— 190 高 / r36 / 151.5deg / 装饰圆 ×2 / 装饰弧线 /
      左侧文案 + 深色小按钮 / 右侧读数区（无数据时**整块不渲染**）
- [x] `HomeStilCards` —— 2×2 四张卡（Figma 几何逐位：r28 / padding 18 /
      48×48 渐变底板 / 1.5px 描边 / 0 8px 20px 投影）
      · 四张卡的**渐变 / 图标 / 高亮色 / 点击目标**在**三态完全一致**
      · 「今日一句」不可点（Figma `onClick: undefined`）
- [x] `HomeAnalysisSection` —— 三颗筛选胶囊 + 岗位匹配变化卡
      · State 03：排名（🥇🥈🥉）/ 渐变文字匹配度 / 变化 Chip / 比例条 /
        分隔线，整组几何取自 Figma
      · State 01 / 02：换成「开始你的第一次分析」引导（**Figma 无此态**，
        两个文字角色为暂定值 → **D79**）
- [x] **16** 个新测试用例（`test/phase5_home_test.dart`）
      · 含**三态结构不变量**断言 —— 直接钉住 D64 ①bis
      · 含**反假数据**断言（`Alex` / `86%` / `排名 #1` … 共 9 条）
- [x] 首页脱离 Phase 1 的 route placeholder
      （`首页 · 看见现在` 占位卡与 `CareerlyScaffold(title: '首页')` 均已移除
      —— Figma 首页**没有标题栏**）

**Phase 5 新增待裁决项**：**D75–D81**（`TODO.md` §3.1）

**Phase 5 明确未做**：

```text
下拉刷新                    → Figma 未定义，未自行发明
首页→分析 的跳转落点细化     → 现统一落「分析」Tab 根（分析页属 Phase 6）
用户姓名展示                → 需先有用户档案数据（D76）
```

---

### ⚠️ Phase 8 批 2 — 技能 / 奖项 / 能力（2026-09-22）（**未验收**）

**交付物**：三张职业资产二级页 + 三处降级落点回接。

```text
/profile/skills       SkillsPage      按分类分组的技能 Chip（Figma L3817）
/profile/awards       AwardsPage      荣誉列表：奖杯底板 / 年份胶囊 / 机构 / 说明（L3838）
/profile/capability   CapabilityPage  能力雷达图（CustomPainter）+ 能力详情双层条（L3865）

回接的落点（此前是「点了没反应」或落到职业资产页根）：
  profile_page.dart      技能子卡 → profileSkills    奖项子卡 → profileAwards
  career_assets_page.dart 专业技能分组「查看全部」→ profileSkills
                          能力画像卡「查看全部」  → profileCapability
```

⚠️ **三条路由都是「我的」分支内的二级页**（`StatefulShellBranch` 子路由），
**不是一级导航** —— 底部导航保留、返回 = 分支内 pop。
四个一级导航的数量**未变**（`CLAUDE.md` §2）。

**本批的模型改动**：`Award` 补回 `description` 字段（原型本来就有 `desc`，
此前因「无人消费」而略去；奖项页落地后该理由不再成立，三条说明逐字照抄原型）。

**本批新增待裁决项**：**D92–D94**（`TODO.md` §3.1）——
能力页「查看变化 →」不渲染 / 条目未做错峰展开 / 条目动画 550ms（Figma 600ms）。

**本批明确未做**（**不是遗漏**，逐条有依据）：

```text
「查看变化 →」入口        → cap-change 无路由（D81/D92），落点不存在的入口不渲染
成长日历网格              → 两套事件枚举对不上（D91），映射属产品定义
「能力变化 +12」          → 口径未定义（D87）
历史岗位页                → IA 有、Figma 无规格（TODO §3.1 · O7）
```

**本批判为「未验收」**：视觉（雷达图比例、卡片间距、渐变）**只能人工核对**；
`flutter test` 只保证结构与数据链路。

> 🔴 **文档欠账（本批未能清偿，必须点名）**：
>
> ```text
> ① CURRENT_STATUS 缺 Phase 6 / Phase 7 / Phase 8 批 1 / Phase 9 的 §4 分节
>    —— 本文件 §4 从 Phase 5 直接跳到「## 6. 文档地图」，且「## 5.」整节标题缺失
> ② Phase 8 批 1 交付时无 CHANGELOG Session、无 D 编号
>    —— D86–D91 / K16 只活在源码注释里，本批已补登（TODO §3.1）
> ③ CHANGELOG 缺 Session 013（012 与 014 之间有断号）
> ④ test/phase9_global_state_test.dart 存在（4 用例），而 Phase 9 未获授权、
>    无 Session、无 D 编号 —— 它只覆盖 Phase 1 的 CareerlyAsyncStateView 四态契约，
>    **没有**新增生产代码
> ```
>
> 以上四条**不影响本批的代码结论**，但意味着**本文件的 §4 不完整** ——
> 查 Phase 6 / 7 / 8 批 1 的交付细节请去 `CHANGELOG.md` Session 012。

---

> ⚠️ **本节的标题行已缺失** —— 编号直接跳过了 5（§4 之后就是 `## 6. 文档地图`），
> 现有材料无法确定原标题。**已记入 §4 尾部的文档欠账清单**；
> 未擅自补标题（补什么属文档口径，不是代码问题）。

完整优先级与冲突裁决规则见 `CLAUDE.md` §3。

```text
1. PRD V2.1                  docs/01_...
2. IA V2.1                   docs/04_...
3. Development Baseline      docs/07_...   ← 歧义仲裁第一入口
4. Flutter Dev Spec          docs/06_...
5. Figma Make                docs/Careerly App Interface Design (Copy)/
6. Flutter 实际代码           lib/
```

---

### ✅ Phase 8A — 成长足迹「日历与事件解耦」（2026-09-28）（**未验收**）

**产品侧规则**（→ `TODO.md` §3.2 · **D99**）：

```text
✅ 日历是默认存在的核心页面结构 —— 永远渲染
✅ 即使没有任何事件，也必须显示完整日历 + 对应的当天空状态
❌ 不得根据 Event 是否存在来决定是否渲染 Calendar
```

**为什么需要这一轮**：批 3 把本页实现成了**数据消费页** —— 整页包在
`CareerlyAsyncStateView` 的 `isEmpty` 门禁里，而 Mock 默认返回空，
于是**日历整块消失**。这正好违反上述规则。

**交付物**：`lib/features/profile/presentation/growth_record_page.dart`

| # | 改动 |
|---|---|
| 1 | 拆掉顶层 Empty 门禁 —— 日历（周条 + 月网格）无条件渲染 |
| 2 | 全部日期可点选（旧：空日期 `onTap: null`） |
| 3 | 当天事件区**恒渲染** + 当天空状态（`_DayEmptyNote`） |
| 4 | 默认选中**今天**（旧：预选「最近有事件的日期」，无事件时无选中） |
| 5 | 「今天」快捷定位（复用 `CareerlyChip`，视图离开今天时出现） |
| 6 | 切月时选中日**跟随**（越界夹到月末；切到当前月回今天） |
| 7 | 时间线加区块标题「全部记录」，与当天事件区区分（两者都保留） |

```text
✅ 新增待裁决：D100（非今天日期的空态文案）· D101（切月跟随 /「今天」胶囊）
⚠️ 必收敛   ：D96 的文档与代码配色不一致（TODO 写青色系、代码是粉色系）
```

**实测（2026-09-28 当次）**：

```bash
cd /g/ai_agent/careerly
flutter analyze  →  No issues found!
flutter test     →  All tests passed!（178 / 178）
flutter test test/phase8d_growth_record_test.dart  →  8 / 8（含 Phase 8A 核心不变量）
```

> ⚠️ **本批同时清掉了三处与它无关的阻塞**（09-24 另一条工作线遗留）：
> `resume_file_picker.dart` 的 file_picker v13 API 未迁移 ·
> `mock_resume_repository.dart` 缺 import · 两个 phase6 测试桩缺接口实现。
> **仓库在其中修复前处于「编译不过」状态**，任何整 App 测试都无法编译。
> 详见 `CHANGELOG.md` Session 017 · 新发现 ①。
>
> ⚠️ **「选择文件」在页面上的实际接线（D67）仍未做** —— 只修到**可编译**。

> ⚠️ **测试命令必须先去掉代理环境变量**（`http_proxy` 等），
> 否则 `flutter_tester` 连接失败、表现为「测试无输出」。
> 命令见 `CHANGELOG.md` Session 017 · 新发现 ②。

**本批明确未做**（**不是遗漏**，逐条有依据）：

```text
事件的写入路径（各业务操作 → GrowthEvent）  → 属后续阶段的**数据层**职责
                                           本页只做容器（D99 已明确）
真机/模拟器视觉走查                        → 本轮未跑 APK，日历观感未验
D100 文案 · D96 配色收敛                   → 等产品侧裁决
```

---

## 6. 文档地图

```text
CLAUDE.md                          规则：什么能做 / 不能做 / 听谁的   （每次会话自动加载）
DEVELOPMENT_WORKFLOW.md            流程：每次开发怎么做
docs/05_progress/CURRENT_STATUS.md 状态：现在在哪                      ← 本文件
docs/05_progress/TODO.md           计划：接下来做什么
docs/05_progress/CHANGELOG.md      决策：为什么这么做（只追加）

docs/01_ PRD V2.1                  产品行为最高依据
docs/04_ IA V2.1                   页面归属 / 导航最高依据
docs/06_ Flutter Dev Spec          工程架构与实现规则
docs/07_ Development Baseline      歧义仲裁第一入口
docs/phase_1_report.md             Phase 1 交付报告（历史）
```
