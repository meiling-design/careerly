# Careerly — TODO

> **「接下来做什么」+「什么在挡路」+「什么等人拍板」**
>
> 现状 → `CURRENT_STATUS.md` ｜ 为什么这么决定 → `CHANGELOG.md` ｜ 怎么做 → `DEVELOPMENT_WORKFLOW.md`
>
> 最后更新：**2026-10-02**（Session 020 —— ③ 岗位 URL 接线：后端 + Flutter 双端）
>
> 📌 本文件 §3.1 新增 **D112–D116**，**D107 已裁决**（移入 §3.2）；
> 交付经过见 `CHANGELOG.md` **Session 019 / 020**。
> 下方的 **2026-09-30 全量审查（§1.0d）** 是关于「文档欠账」的另一条线，仍然有效。
>
> ⚠️ 本文件此前停在 2026-09-28。**09-23 之后有 4 批代码进了仓库但没有任何记录**，
> §1.0d ③ 逐条列出。**在补上这些账之前，本文件任何「已交付」的说法都不完整。**
>
> ⚠️ **2026-09-30 补充**：本节内容曾于 13:53 写入，13:58 被一次外部保存整体覆盖，
> 现已重写并提交。**若你仍开着该文件的旧缓冲区，请先关闭或重新加载，否则再次保存会二次覆盖。**
>
> 📌 同日追加 **§四「未实现功能台账」**（对 §1.0d 的补充：§1.0d 讲「账怎么欠的」，
> §四讲「还差哪些功能」）。

---

## 一、接下来做什么

### 1.0d ▶ **2026-09-30 全量审查 —— 现状 / 偏差 / 下一步开发流程**

> **本轮是一次只读审查**：未改任何业务代码、未改任何产品规则、未新增页面。
> 产出 = 本节 + §2.1 的两条新卡点（K17 / K18）+ §3.1 的四条新待裁决（D102–D105）。
>
> **一句话结论**：功能面已经铺到 Phase 8A，**但文档链条断在 09-23**。
> 下一步的主要工作不是写新功能，而是**先把账补齐，再验收，最后才谈新单元**。

#### ① 实测证据（当次，**含未提交的工作区**）

```bash
cd /g/ai_agent/careerly
flutter analyze  →  No issues found!                 (2026-09-30 · 37.7s)
flutter test     →  All tests passed!（180 / 180）   (2026-09-30)
```

| 项 | 值 | 复算命令 |
|---|---|---|
| `lib/` | **133** 个 Dart 文件 / **33286** 行 | `git ls-files lib \| wc -l` · `cat $(git ls-files lib) \| wc -l` |
| `test/` | **17** 个文件 / 5125 行 / **180** 用例 | `wc -l test/*.dart` · `grep -c "testWidgets(\|test(" test/*.dart` |
| 分支 | `feature/phase6-analysis` @ `7de0d5b` | — |
| 工作区 | ~~4 个文件未提交（+192 / −35）~~ → **已于 09-30 提交为 `267fd64`**（内容见 ③ · D） | `git log --oneline -1` |

> ⚠️ `CURRENT_STATUS.md` §3.3 记的 `119 文件 / 24682 行 / 158 用例` 已过期 ——
> 那份数字停在 2026-09-22，**不覆盖 09-23 之后的工作**。

#### ② 交付台账（**除 Phase 0 / 1 外，全部「已交付 · ⚠️ 未验收」**）

| Phase | 名称 | 代码 | 文档记录 | 验收 |
|---|---|---|---|---|
| 0 | 基准锁定 | ✅ | ✅ | ✅ COMPLETE |
| 1 | 工程骨架 | ✅ | ✅ | ✅ PASS WITH NOTES |
| 2 | 批 1 / 批 2 / Token 审计 / `CareerlyInput` | ✅ | ✅ | ⚠️ 未验收（4 笔欠账） |
| 3 | App Shell 视觉定稿 | ✅ | ✅ | ⚠️ 未验收 |
| 4 | Onboarding 批 1 + 批 2 | ✅ | ✅ | ⚠️ 未验收 |
| 5 | 首页三态（D64） | ✅ | ✅ | ⚠️ 未验收 |
| 6 | 分析 | ✅ | ✅ | ⚠️ 未验收（缺口见 ⑤） |
| 7 | AI Chat UI（Mock） | ✅ | ✅ | ⚠️ 未验收（**仅 2 用例**） |
| 8 | 我的 批 1 + 批 2 | ✅ | ✅ | ⚠️ 未验收 |
| 8A | 成长足迹「日历与事件解耦」 | ✅ | ✅ | ⚠️ 未验收 |
| 9 | Global States | ⛔ 无生产代码 | ❌ 无 Session / 无 D | 未授权 |
| 10 | Android QA | APK 构建 / 安装 / 启动已完成 | ⚠️ 授权状态自相矛盾（见 ③ · ⑤） | T1–T14 待执行 |
| **A–D** | **09-23 → 09-30 的四批（见 ③）** | ✅ | ❌ **零记录** | ⚠️ 未验收 |

#### ③ 🔴 本次审查的核心发现：**代码已经走到文档之前**

以下是**已进仓库、但 CHANGELOG / CURRENT_STATUS / 本文件都没有记录**的四批：

| # | 日期 | 内容 | 现有记录 |
|---|---|---|---|
| **A** | 09-23–09-24 | **Android Back 统一** —— `careerlyBack()` / `CareerlyBackScope` / `CareerlyBackGuard` / 预测性返回（`lib/app/router/back_navigation.dart`，329 行）+ `test/back_navigation_test.dart`（5 用例） | 规则只进了 **`CLAUDE.md` §5.6**（标注「2026-09-23 产品确认」）· ❌ 无 CHANGELOG Session · ❌ 无 D 编号 · ❌ `CURRENT_STATUS.md` 无分节 |
| **B** | 09-24 | **分析的三条二级页**（岗位详情 / Gap / 目标岗位）+ `analysis_loader.dart` + `analysis_page.dart` 重写（1956 行） | ❌ 无任何记录 |
| **C** | 09-29 | **真实后端 API 层** —— `ApiClient`（289 行）+ `api_auth` / `api_resume` / `api_analysis` 三个实现 + `demo_analysis_fixture` + 职业资产页 / 能力页改写 | ❌ 无任何记录 · 且 `CURRENT_STATUS.md` §3.5 **仍写着「❌ `ApiClient`（无真实后端调用）」** |
| **D** | 09-30 | **「选择文件」接线**（`ResumeFilePicker` 平台网关 + `CareerlyApp.overrides` 测试注入缝 + 测试改断言）—— 即 **D67 已被代码关闭** | ✅ 已提交 `267fd64` · ❌ §3.1 · D67 至今仍记作「待裁决」（授权问题见 D103） |

**连带的三笔账**：

```text
❌ 依赖未登记    pubspec.yaml 新增 file_picker ^13.1.0 / http ^1.2.2，
                 未见 CLAUDE.md §6.5 要求的「Package / Purpose / Why Needed」登记
❌ 幽灵引用      CHANGELOG.md Session 017 列出的 docs/phase8a_footprint_report.md **不存在**
                 （与 Session 010 修过的「6 处幽灵引用」是同一类问题，属复发）
❌ 文件自相矛盾  CURRENT_STATUS.md §1 前 15 行内同时写着
                 「四个一级页面现已全部接上真实页面」（L50）与
                 「四个一级页面仍然是 route placeholder」（L66）—— 后者是 09-22 前的旧文
```

> 📌 **这与 D82 / D83 是同一种情形**（授权与文档双双缺失，代码先落地）。
> 上一次的处置是**产品侧追认授权 + AI 侧补登文档**，本次建议同型处理 ——
> 见 **§3.1 · D102**。

#### ④ ▶ 下一步开发流程（建议顺序）

```text
第 0 步  文档收口            —— 不需要授权，可直接做（本轮审查的建议起点）
第 1 步  Phase 3–8A 合并验收  —— 产品侧动作，**阻塞一切后续开发**
第 2 步  授权后的 4 个候选单元 —— 一次只做一个，每个结束即停止等验收
```

**第 0 步 · 文档收口**（`DEVELOPMENT_WORKFLOW.md` §0：文档漂移不会报错，只会让人安静地做错事）

```text
0.1  提交当前工作区（已实测 green：analyze 干净 + 180/180），它关闭了 D67
0.2  CHANGELOG 追加 Session 018+：A / B / C / D 四批各一条
     —— 写法照 DEVELOPMENT_WORKFLOW.md §4 的模板：交付内容 / 实测 / 待裁决 / 明确未做
0.3  为 A–D 补 D 编号与授权说明（或按 §3.1 · D102 的裁决结果写「越界」）
0.4  修正 CURRENT_STATUS 三处与代码相反的结论：
     §3.3 数字 · §3.5「无真实后端调用」· §1「仍是 route placeholder」
0.5  补回或删除 Session 017 引用的 docs/phase8a_footprint_report.md（幽灵引用）
0.6  关闭 D67（或按裁决回退），并把 file_picker / http 按 §6.5 登记
```

**第 1 步 · Phase 3–8A 合并验收**（为什么必须排在所有新开发之前）

```text
8 批「已交付」至今**全部是未验证假设**（DEVELOPMENT_WORKFLOW.md §3.2：
未验收的假设会被当成已确认的基础，越往后堆积越贵）。
验收时请重点看这四条**测试断言不到**的地方：
  ⚠️ Phase 8 §5.4 核心不变量 —— Tab 点击 → 对应 Card 前移第一位、其他 Card 保持相对顺序
  ⚠️ Phase 7 只有 2 个 Provider 单元用例，**无页面 widget 测试**
  ⚠️ Phase 6 剩余缺口（见 ⑤）
  ⚠️ 全部视觉结论都建立在**字体缺失**（K1）的前提下，排版一栏不能盖章
```

**第 2 步 · 授权后的候选单元（建议优先级，**需产品侧具名授权**）**

| 序 | 候选单元 | 为什么建议排这个位置 |
|---|---|---|
| 2.1 | **Phase 10 · Android 真机 QA T1–T14** | 设备已就绪（K3 已解除），它是**唯一**能暴露 SafeArea / 返回键 / 中文字体回退的手段；而 09-23 的 Back 重构（③ · A 批）**从未在真机上跑过** |
| 2.2 | **Phase 6 补口**：分析「历史版本」+「更新分析」Sheet | IA §7.2 明文要求，属**交付缺口**（不是「Figma 表达不了」那类，不能挂起等设计侧） |
| 2.3 | **真实后端联调**（`CAREERLY_USE_API=true` 跑通一条端到端链路） | C 批的 API 层已写好但**从未在真实后端上验证**；前置是会话口径（§3.1 · D104）与契约文档归属（K18） |
| 2.4 | **Phase 2 批 3**（`ScoreIndicator` / `AIMessageBubble` / 导航栏 Glass 统一 K10·K12） | 前置未变：**批 1 + 批 2 合并验收通过** |

> ⚠️ 上表是**建议**，不是授权。**每完成一个单元 → 停止 → 报告 → 等验收**（`CLAUDE.md` §0 第三禁令）。

#### ⑤ 本次审查附带更正的两处旧结论

```text
① §1.0b 记的「Phase 6 有三处规格要求未落实」 → 现为**两处**
   ✅ CareerlyAnalysisProgress **已实现**（09-24 那批）：
      lib/features/analysis/presentation/widgets/careerly_analysis_progress.dart（1118 行）
      + test/phase6_analysis_progress_test.dart（7 用例）—— D28 的移交已闭环
   ❌ 「更新分析」Sheet 仍未做（按钮存在，直接落新建分析）
   ❌ 分析「历史版本」仍未做（IA §7.2，形态应为历史分析内的 Bottom Sheet）

② `CURRENT_STATUS.md` §2 把 Phase 9 记为「⛔ 未获授权」，
   同表却把 Phase 10 记为「▶ 真机已连接 / T1–T14 待执行」；
   而**本文件 §1.4** 又称 Phase 3–10 全部未授权 —— **三处互相冲突，需产品侧澄清一次**
   （登记为 §3.1 · D102 的附属项）
```

#### ⑥ 本轮明确不做

```text
❌ 不新增任何一级页面 / 一级导航 / 第 5 个 Tab
❌ 不修改任何产品规则（含 D67、D102–D105 的裁决 —— 一律等产品侧）
❌ 不进入 Phase 9 / 11
❌ 不「顺手」收敛暂定 Token、不「顺手」修视觉
```

---

### 1.0 ▶ 开发中 —— **Phase 3 + 4 + 5**（验收推迟至 Phase 5 结束）

> ⚠️ **本小节的「开发中」字样已过时（2026-09-30）。**
> 最新状态见 **§1.0d**；下面保留原文以追溯 D59 / D60 那一轮的交付与授权。

> **2026-09-18 最新状态。** 产品侧已具名授权 **Phase 3 + 4 + 5 整体开发**（**D60**），
> 并**首次给出欠账清偿方式**：三批**全部完成后合并验收**。
> 本条与下方 §1.1（Phase 2 合并验收）**并存** —— 验收时点合并，**欠账并不消失**。

**本轮（**D59**：修红 + 补文档）交付了什么**：

```text
✅ 修复 test/phase4_onboarding_test.dart 的红灯用例
   —— 经诊断为测试夹具的时序缺陷（转场动画未获推进），**非产品缺陷**
✅ 补登 D53 · 新增 D54–D58
   —— Phase 4 批 1 有 6 处争议「只活在源码注释里」，§3.1 一条都没有
✅ CURRENT_STATUS.md / CHANGELOG.md 与代码同步
   —— 此前 CHANGELOG 无 Session 010，CURRENT_STATUS 误写「Phase 4 ⛔ 未启动」
```

**Phase 4 批 1 的实际状态**：

| 项 | 状态 |
|---|---|
| 代码 | ✅ 已存在（1150 行：开屏 / 注册 / 进度头 / Provider / AuthRepository + Mock / 289 行测试） |
| 交付记录 | ✅ **本轮补齐** —— 此前**零记录**，属 §0 禁止的文档漂移 |
| 实测 | ✅ `flutter analyze` 零 issue · `flutter test` **72/72**（2026-09-18 当次实测） |
| 验收 | ⚠️ **未验收** |

**▶ 2026-09-21 / 09-22 更新 —— 已越过本节的 Phase 3 / 4 / 5，停在更远处。**

```text
✅ Phase 6 分析        已交付（D82）· ⚠️ 未验收
✅ Phase 7 AI          已交付（D82）· ⚠️ 未验收
✅ Phase 8 批 1 我的   已交付（D83）· ⚠️ 未验收
✅ Phase 8 批 2 我的   已交付（技能 / 奖项 / 能力 三页，2026-09-22）· ⚠️ 未验收
✅ Phase 8A 成长足迹   已交付（日历与事件解耦，D99，2026-09-28）· ⚠️ 未验收
⛔ Phase 9 Global States / Phase 10 Android QA  **未获授权**
```
claude
**▶ 当前停止点：Phase 6 + 7 + 8（批 1 + 批 2）+ 8A 已交付，等待验收。**
实测 `flutter analyze` 零 issue · `flutter test` **178/178**（2026-09-28 当次实测）。
详见 `CHANGELOG.md` Session 017 与下方 §1.0c。

> ⚠️ 下面这一段（Phase 3 / 4 / 5，D60）**仍然有效且未验收** ——
> 它没有被 Phase 6/7/8 的交付「顶掉」，只是不再是**最新**的一条。
> ⚠️ **Phase 6 / 7 / 8 的验收时点未定**，见 §1.0b。

> ✅ **已过时：下面这条关于入口的说明已由 D84 取代（2026-09-21）。**
> 现在默认入口 = `/onboarding/splash`，开发期用 `CAREERLY_ENTRY=home` 覆盖。
> 原文（保留以追溯）：批 1 的「接线」尚未闭环 —— App 入口仍是 `/home` 而非开屏，
> 原因与候选方案见 **§3.1 · D54**。**裁决前不得改动入口。**

---

### 1.0c ▶ 最新交付 —— **Phase 8A 成长足迹「日历与事件解耦」**（2026-09-28）

> **授权**：产品侧本轮具名给出的规则（→ §3.2 · **D99**）：日历是**默认存在**的容器，
> 事件是动态数据。**不得**用 Event 存在与否决定 Calendar 是否渲染。

| # | 交付物 | 实测 | 验收 |
|---|---|---|---|
| **8A** | 成长足迹页：拆掉顶层 Empty 门禁（日历无条件渲染）+ 全部日期可点选 + 当天事件区恒渲染（含当天空状态）+ 默认选中今天 + 「今天」快捷定位 + 切月选中跟随 + 时间线区块标题「全部记录」 | ✅ 8/8（本文件）· 178/178（全量） | ⚠️ 未验收 |

```bash
cd /g/ai_agent/careerly
flutter analyze  →  No issues found!                (2026-09-28)
flutter test     →  All tests passed!（178 / 178）  (2026-09-28)
```

> ⚠️ **续跑本项目的测试必须先去掉代理环境变量**（否则 `flutter_tester`
> 连接失败、表现为「测试无输出」）—— 命令见 `CHANGELOG.md` Session 017 · 新发现 ②。

**本批新增待裁决项**：**D100**（非今天日期的空态文案）· **D101**（切月选中跟随 / 「今天」胶囊）。
**另有一处必须收敛**：**D96 的文档与代码配色不一致**（TODO 写青色系、代码是粉色系）。

---

### 1.0b ⏹ 上一停止点 —— **Phase 6 + 7 + 8 已交付**（2026-09-21 / 09-22，D82 / D83）

> **授权**：**D82**（Phase 6 分析 + Phase 7 AI）、**D83**（Phase 8 我的 + 本轮收口）。
> 四批**均未验收**。

| Phase | 交付物 | 实测 | 验收 |
|---|---|---|---|
| **6** 分析 | `新建分析`（当前简历 / 添加岗位 / 岗位列表 / 开始分析）+ `历史分析`（列表 / 结果 / 四态 / 额度门禁） | ✅ | ⚠️ 未验收 |
| **7** AI | Chat UI（空会话 + 建议问题 + 输入区）+ `AIProvider` + `MockAIRepository` | ✅ | ⚠️ 未验收 |
| **8 批 1** 我的 | Tab → Card 前移 → Detail（`AnimatedList` + `AppMotion.cardReorder` = 300ms）+ 8 张二级页（工作经历 / 项目 / 成长足迹 / 简历历史 / 会员 / 设置 …） | ✅ | ⚠️ 未验收 |
| **8 批 2** 我的 | **技能 / 奖项 / 能力**三张职业资产二级页 + 三处降级落点回接（2026-09-22） | ✅ | ⚠️ 未验收 |

```bash
cd /g/ai_agent/careerly
flutter analyze  →  No issues found!                (2026-09-22 批 2 收口)
flutter test     →  All tests passed!（158 / 158）  (2026-09-22 批 2 收口)
```

> ⚠️ **批 1 与本批在文档上的待遇不同**：批 1 交付时**没有** CHANGELOG Session、
> **没有** D 编号记录（D86–D91 / K16 全部只活在源码注释里）。
> 批 2 交付时连同这两笔一起补登 —— 见 §3.1 顶部的「集中补登」说明。

#### 🔴 Phase 6 有**两处**规格要求未落实（~~三处~~ → **2026-09-30 更正**）

> 📌 更正依据：§1.0d · ③ 的审查（09-24 那批代码把第一条补上了）。
> 本节的「三处」结论写于 09-22，**当时确实成立，现在已不成立**。

```text
✅ CareerlyAnalysisProgress —— **已实现**（2026-09-30 更正）
   —— lib/features/analysis/presentation/widgets/careerly_analysis_progress.dart（1118 行）
      + test/phase6_analysis_progress_test.dart（7 用例）
   —— D28「移出批 2 → 改归 Phase 6」的移交**已闭环**；
      本节此前记的「`lib/` 全库 0 处引用」已过时
❌ 「更新分析」未实现（IA §7.2）
   —— 按钮存在（analysis_page.dart:1154），但**直接落新建分析**，不是 IA 要求的 Sheet 形态
❌ 「历史版本」未实现（IA §7.2；形态为历史分析内的 Bottom Sheet —— 见 CLAUDE.md §2.2）
   —— ⚠️ 本节此前给的证据「分析页对 CareerlyBottomSheet 的 0 处使用」**已失效**
      （`careerly_analysis_progress.dart` 现在用了它）；改用本条证据：
      分析结果页只渲染**简历版本**（`ResumeVersion`），没有分析结果自己的历史版本
```

> ⚠️ 这两条**不是**「Figma 无法表达」那一类，**不能**挂起等设计侧 ——
> IA 已明确规定，属**交付缺口**。

#### ⚠️ 验收时请注意：Phase 7 / 8 的**验证强度低于 Phase 5**

```text
Phase 5 首页      16 个用例，含**结构不变量**断言（钉死 D64 ①bis 铁律）
Phase 6 分析      18 个用例
Phase 7 AI         2 个用例，**仅 Provider 单元测试，无页面 widget 测试**
Phase 8 我的      19 个用例（批 1 = 9 / 批 2 = 10）—— 覆盖四态、二级页导航、
                  演示数据渲染、以及批 2 的三处落点回接
```

> 🔴 **Phase 8 仍未断言 §5.4 的核心不变量** ——
> 「点击 Tab → 对应 Card 前移到第一位，**其他 Card 保持相对顺序**」。
> 批 2 加的是**三张二级页**，**没有**补这条：它属 `profile_page.dart`（批 1 的页面），
> 本轮未改动该页的结构。
> **这是验收时最该人工核对的一条** —— 动画本身（300ms / 250–350ms 区间）也是
> 只有真机/模拟器上才看得出来（`flutter test` 不验证观感）。
>
> 「测试全绿」只覆盖被断言到的部分。**不要**按 Phase 5 的标准推断 Phase 7 / 8。

#### ⚠️ 本轮是两个会话并发写同一工作区（详见 `CHANGELOG.md` Session 012 第四节）

无改动丢失（双方恰好未触碰同一文件），但**没有任何机制能防下次冲突**。

---

---

### 1.1 ⏹ 已停在停止点 —— Phase 2 批 2 已交付，等待**合并验收**

> **2026-09-18 当前状态：批 2 开发完成；欠账仍未清偿。**
>
> ⛔ **不得自动进入批 3**（`CLAUDE.md` §0 / D24）。
> 停止点的豁免只能由产品侧**逐次、具名**给出（`DEVELOPMENT_WORKFLOW.md` §8.1）。
> 批 1→批 2 那次豁免（D20）**已用掉**，不覆盖批 2→批 3。
>
> 📌 **2026-09-18 更新**：产品侧已具名授权 **Phase 3 开工**（**D51**，见 §3.2）。
> ⚠️ **该授权没有清偿任何欠账** —— 批 1 / 批 2 / Token 审计 / `CareerlyInput`
> **四者的验收状态仍是「未验收」**，且 §8.1 要求的**欠账清偿方式本次未给出**，继续挂账。
> Phase 3 的开工**不是**批 3 的开工 —— 批 3 前置未变。

#### 验收欠账台账

| 批次 | 内容 | 验收状态 |
|---|---|---|
| **批 1** | `GlassSurface` / `CareerlyButton` / `CareerlyCard` / `CareerlyChip` | ⚠️ **未验收（已授权跳过，D20）** |
| **批 2** | `CareerlyProgress` / `CareerlyBottomSheet` / `CareerlyToast` | ⏳ **已交付，未验收** |
| **Token 审计** | 逐文件核查依据 / 暂定值集中登记（`CURRENT_STATUS.md` §3.6） | ⏳ **已完成，未验收** |
| **Input** | `CareerlyInput`（产品侧点名要求的第 5 个组件） | ⏳ **已交付，未验收** |

> 📌 **后两项不在原分批计划内** —— Token 审计来自产品侧对 Phase 2 执行方式的调整，
> `CareerlyInput` 来自产品侧点名的五组件清单（Button / Card / Input / Chip / Navigation）。
> 两者都不构成「进入批 3」的授权。

```text
约定：批 2 交付时，批 1 + 批 2 合并验收。
```

> ⚠️ **批 1 至今没有验收过。**
> 不得因为批 2 交付了，就反推「批 1 已确认无误」（D20 的明文警告）。
> 合并验收时必须**两批都重新过一遍**，不能只验批 2。

**批 2 相对原计划的变更**（详见 §3.2）：

```text
CareerlyAnalysisProgress  → 移出批 2，改归 Phase 6（D28）
```

**为什么合并验收、而不是永久跳过**（依据 `DEVELOPMENT_WORKFLOW.md` §3.2）：

未验收的假设会被当成已确认的基础。批 2 的组件本就**建在批 1 之上**
（`CareerlyBottomSheet` 预期复用 `GlassSurface`），
两者无法真正分开验收。合并验收能在欠账滚大之前结清。

#### 批 2 开发期间禁止

```text
❌ 不修改任何产品规则
❌ 不新增任何页面 / 一级导航
❌ 不「顺手」收敛批 1 的既有实现（重叠项见 §3.1 的 D21 / D22）
❌ 不因为看到了不完美就顺手改视觉 —— 先记录，等裁决
```

**已知会影响验收结论的一项**（对批 1 与批 2 同时生效）：

> ⚠️ **K1 字体缺失** —— 在字体到位前，视觉验收只能记
> **「几何通过，排版待复核」**。Noto Sans SC 不在项目内，中文字形是系统回退的结果。

---

### 1.2 ▶ Phase 2 后续批次

| 批 | 内容 | 前置 | 状态 |
|---|---|---|---|
| 批 2 | `CareerlyProgress` · `CareerlyBottomSheet` · `CareerlyToast` | 批 1 验收 → **已由 D20 豁免** | ✅ **已交付（未验收）** |
| 批 3 | `ScoreIndicator` · `AIMessageBubble` · 用 `GlassSurface` 重做导航栏 Glass（合并 K10 / K12） | **批 1 + 批 2 合并验收通过** | ⛔ 未启动 |

> ⛔ **批 3 的前置这次没有豁免。** 不要再以「批 2 都交付了，下一步很明显」为由开工。

#### 批 2 交付结果（2026-09-18）

| 组件 | 结果 | 交付时的处置 |
|---|---|---|
| `CareerlyProgress` | ✅ 已实现 + 5 项测试 | 确定型；不确定型无视觉定义，**有意不做** |
| `CareerlyBottomSheet` | ✅ 已实现 + 7 项测试 | 参数化 shell + 3 档 tone 预设（属**分析归纳**，D27） |
| `CareerlyToast` | ✅ 已实现 + 5 项测试 | 视觉由 Flutter 用**已有 Token** 补齐（D26），**非设计值** |
| `CareerlyAnalysisProgress` | ⛔ **移出批 2** | 改归 Phase 6（D28） |

**批 2 新增的待裁决项**：D29–D34（见 §3.1）。
**批 2 未做的事**：下滑关闭、Toast 变体、不确定型进度 —— 均因**设计侧未定义**，见对应 D 条目。

#### Token 审计 + `CareerlyInput` 交付结果（2026-09-18）

| 项 | 结果 |
|---|---|
| Token 依据审计 | ✅ 6 个 Token 文件逐个核查完毕；**22 行**暂定值集中登记到 `CURRENT_STATUS.md` §3.6 |
| 审计的处置原则 | **只标注、未改值** —— 改值属视觉决策，按 `CLAUDE.md` §0 第一禁令不得自决 |
| `CareerlyInput` | ✅ 4 档 variant × 2 档 tone + Error / Disabled 两态 · 16 项测试 |
| 输入框未做的事 | 聚焦态 / 占位符 / 错误态边框（Figma **完全没有定义**，D46）；4 档变体**有意不收敛**（D45） |
| 验证 | `flutter analyze` 零 issue · `flutter test` **58/58** |

**新增的待裁决项**：**D35–D49**（见 §3.1）。
**新增的卡点**：无 —— 本轮**没有**产生新的阻塞项。

> ⚠️ **Token 审计有一项结论会影响验收** ——
> `AppSpacing.pageHorizontal` 取的是 **16**，而 Figma 最主流的是 **20**
> （`px-5` 47 次 vs `px-4` 12 次）。**这是最可能需要在真实页面上调整的一项**
> （D37）。若验收时觉得左右留白偏窄，改这一处即可全局生效。

#### 批 2 开工前的两项前置（已完成状态）

- [x] **K6** —— `flutter_localizations` 写入 `pubspec.yaml`
      ✅ **2026-09-18 已落地**（含 `MaterialApp.router` 的 delegates 接线）
- [ ] **K1** —— 字体文件到位后注册 `pubspec.yaml` 并实测（不阻塞开工，**阻塞定稿**）
      ⚠️ 仍未落地 —— 所以批 2 与批 1 一样，**排版一栏不能盖章**。

---

### 1.3 ⏸ Android 真机测试 T1–T14（等设备）

> ⚠️ 当前**没有任何业务页面**，所以真机测试的对象是 **App Shell 的平台适配行为**，
> 不是产品功能。这是 Phase 1 的收尾验证，**不是 Phase 2 的开始**。

#### 为什么必须做

Phase 1 的验收证据只有：

```text
flutter analyze 干净  +  Widget 测试通过  +  APK 能构建
```

这三项**都不能证明**真机行为正确。
**「APK 能构建」≠「真机行为正确」** —— 平台差异只有真机能暴露。

#### 核心目标

```text
1. App 能在真实 Android 设备上正常启动，不崩溃、不白屏
2. 四态基础设施在真机上渲染正常
3. SafeArea / 状态栏 / 手势导航条 处理正确
4. 自绘底部导航在真机上的触摸与布局正确
5. Android 返回键行为符合预期
6. 中文字体回退在真机上的实际表现（K1 的直接暴露点）
7. 背景渐变在真机屏幕上的实际视觉效果
8. 小屏 / 大屏 / 高刷 适配
```

#### 建议设备矩阵

| 维度 | 建议覆盖 |
|---|---|
| Android 版本 | 最低支持版本 + 一个较新版本（如 Android 10 / 14） |
| 屏幕形态 | 挖孔屏 / 刘海屏（**SafeArea 关键**） |
| 导航方式 | 手势导航（**底部手势条**）+ 三键导航 |
| 屏幕尺寸 | 小屏（≤6.0"）+ 常规 |
| 刷新率 | 60Hz + 90/120Hz（**动画观感**） |

#### 清单

| # | 验证项 | 期望 | 对应 |
|---|---|---|---|
| T1 | **App 启动** | 冷启动进入 App Shell，无崩溃 / 无白屏 | Phase 1 §二十五 |
| T2 | **四态渲染** | Loading（600ms 可见）→ Empty 正常展示 | `CareerlyAsyncStateView` |
| T3 | **底部导航渲染** | 3 Tab 玻璃条（首页 / 分析 / 我的）+ **条外 AI 浮球**（62×62，`✦` + `AI` 标签） | 决策 9 |
| T4 | **Tab 切换** | 点击切换正常，**分支状态保留** | `StatefulShellRoute` |
| T5 | **SafeArea — 顶部** | 内容不被状态栏 / 挖孔遮挡 | Phase 1 §十四 |
| T6 | **SafeArea — 底部** | 底部导航不被手势条遮挡 | Phase 1 §十四 |
| T7 | **Android 返回键** | 分支根页面 → 退出 App；有二级页 → 先 pop | K4 |
| T8 | **中文渲染** | 中文正常显示（⚠️ 预期会**回退到系统字体**，因 K1） | K1 |
| T9 | **背景渐变** | 全屏渐变连续，**无颜色断层 / 无 banding** | 决策 8 / D1 |
| T10 | **自绘导航触摸** | 点击热区正常，按压反馈（`AnimatedScale`）可见 | Phase 1 §十五 |
| T11 | **小屏适配** | 小屏不溢出、不截断 | Phase 1 §二十五 |
| T12 | **高刷屏动画** | Tab 切换 / 页面转场在 90/120Hz 下流畅 | `AppMotion` |
| T13 | **旋转 / 分屏** | 行为可预期（当前仅要求不崩溃） | — |
| T14 | **深色模式** | 当前**只提供 Light Theme**，不应出现异常渲染 | `CareerlyTheme.light()` |

> ⚠️ **T8 是预期会「失败」的一项，且不是 bug**：
> 字体文件缺失（K1），系统会回退渲染。
> 测试目的是**确认回退行为可接受**并**量化缺口**，而不是修复它。

**测试期间允许的改动**：仅限**修复真机上暴露的、属于 Phase 1 范围的平台适配问题**
（SafeArea / 布局溢出）。

**测试期间禁止的改动**：

```text
❌ 不修改任何产品规则
❌ 不新增任何页面
❌ 不因为真机上看到了不完美就顺手改视觉
```

---

### 1.4 ⛔ ~~更远~~（Phase 3–10）

> ⚠️ **本节的「更远」已过时（2026-09-30）** —— Phase 3 / 4 / 5 / 6 / 7 / 8 / 8A
> **全部已交付**（均未验收），Phase 10 的 APK 也已构建 / 安装 / 启动。
> 当前真正「更远」的只有 **Phase 9** 与**尚未授权的候选单元**，
> 见 **§1.0d ④ · 第 2 步**。下面保留原文以追溯当初的分期设想。

```text
Phase 3   App Shell 视觉定型（含 AI 入口视觉定稿、Android back 分支级处理 K4）
          ▶ 2026-09-18 已获授权开工（D51）—— 交付物为「桌面 / Chrome 视觉定稿」
Phase 4   Onboarding
          ▶ 批 1（开屏 + 注册/登录，纯 Mock）已交付（D52 授权）—— ⚠️ 未验收
          ⛔ 批 2+（价值介绍 / 提交简历 / 解析 / 确认）未获授权
Phase 5   首页（Mock）
Phase 6   分析
Phase 7   AI
Phase 8   我的（Tab → Card reorder）
Phase 9   Global States
Phase 10  Android QA
```

每个 Phase **结束即停止**，输出报告，等待验收。

---

### 1.5 ❌ 明确不做（当前阶段）

> ⚠️ **本节写于 Phase 1 / 2 时期，其中四项已被后续交付越过**（2026-09-30 审查）：
> 「任何业务页面」→ Phase 4–8A 已落地 ·「Growth Calendar 业务逻辑」→ Phase 8 批 3 + 8A
> ·「真实 Backend API」→ 09-29 的 C 批 API 层（**默认仍关闭**，`CAREERLY_USE_API=false`）。
> **这些是否仍属禁用范围，取决于 §3.1 · D102 的澄清** —— 在此之前，
> 本节按「**仍然有效**」对待，即**不得在此基础上继续扩大**。

```text
❌ 任何业务页面
❌ Resume Parser / JD Parser / Match Engine / Gap Engine / LLM
❌ Growth Calendar 业务逻辑
❌ History Version（应为 Bottom Sheet 局部状态，不是独立页面）
❌ Membership / Payment
❌ 真实 Backend API
❌ 第 5 个一级导航
```

---

## 二、卡住的事（Known Issues）

### 2.1 🔴 真正阻塞当前工作的

| # | 问题 | 阻塞什么 | 谁来解 |
|---|---|---|---|
| **K11** | 🟠 **`CareerlyToast` 在设计侧没有视觉实体** —— `App.tsx` 中**不存在** Toast 组件或使用点；仅有 `.toast-in` / `.toast-out` 两个 CSS 关键帧，且**无任何元素引用**。容器 / 图标 / 文字 / 变体 / 停留时长**全部缺失** | **批 2 验收时 `CareerlyToast` 的视觉结论**（组件已按 D26 用已有 Token 补齐，可运行；但那是 **Flutter 侧取值**，不能被当成设计值盖章） | **设计侧补充视觉**；Flutter 侧**不得凭空补全** |
| **K1** | **Noto Sans SC 字体文件缺失** —— 项目内 `.ttf` / `.otf` 文件数：**0** | **所有视觉验收的排版盖章** | **用户**放入 `assets/fonts/`；Flutter 侧注册 `pubspec.yaml` 并实测 |
| **K3** | ~~无 Android 设备~~ —— 已连接 `V2359A`（Android 16 / API 36） | **T1–T14 全部平台验证** | ✅ 已解除；继续执行真机清单 |
| **K17** | 🔴 **文档与代码脱节** —— 09-23 起的四批交付（Back 统一 / 分析二级页 / 真实 API 层 / D67 接线）**全部无 CHANGELOG Session、无 D 编号、无交付报告**；连带 1 处幽灵引用、1 处文件内自相矛盾、2 个依赖未按 §6.5 登记（清单见 **§1.0d ③**） | **Phase 3–8A 合并验收的证据链** —— 验收要核「这份交付当初承诺了什么、明确没做什么」，而这些记录不存在；也阻塞 D67 的裁决状态 | AI 侧（补登）· 产品侧（§3.1 · **D102** 的授权追认） |
| **K18** | 🔴 **后端契约文档不在本仓库** —— `ApiClient` 的类注释把 `docs/careerly/BACKEND_API_CONTRACT.md`（**后端仓库**）当作端点与 envelope 的真值源，本仓库既无副本也无版本锚点 | **真实后端联调**（§1.0d ④ · 2.3）—— 后端改端点 / 改字段时，本仓库**无法察觉**，会在运行期才暴露 | 产品侧定文档归属（并入 K17 一起收口） |

> **K11 的现状变更（2026-09-18）**：批 2 曾因它被判为「🔴 阻塞」。
> 产品侧裁决走 **D26**（用**已有 Token** 补齐、不新造视觉语言）后，
> 阻塞解除、组件已交付 —— **但设计缺口本身没有消失**，
> 只是从「阻塞交付」降级为「阻塞视觉盖章」。

> **K1 的现状**：代码层面**已 100% 遵守**硬规则 —— `AppTypography` 与 `CareerlyTheme`
> 都声明了 `'Noto Sans SC'`，全项目**零处**出现其他中文字体族名。
> 但**字体资产不在项目内**，运行时由 Android 平台**回退渲染**。
> ⚠️ **禁止自行从网络下载**，也**禁止用其他中文字体偷偷替代**。
> 补齐方式见 `assets/fonts/README.md`（含可直接复制的 pubspec 片段）。

> **K17 详述（2026-09-30 新增）**：本项目已有一次同型前科 ——
> Session 010 曾修掉 **6 处幽灵引用**，并为此在 §3.1 顶部立下
> 「代码注释里的争议必须同时登记」的规则。本轮再度复发，且规模更大：
> **不是注释没登记，而是整批交付没有记录**。
>
> 处理方式**不要用「回补一份看起来很完整的报告」蒙过去** ——
> 那些记录的价值在于「当时承诺了什么、明确没做什么」，
> 补写时必须**只写能从代码与测试里复算出来的事实**，
> 不确定的部分标「待确认」，不确定的裁决**一律走 §3.1**。

> **K18 详述（2026-09-30 新增）**：`CLAUDE.md` §3 的来源优先级里，
> 「Flutter 实际代码」排最后一位 —— 前提是**上游文档都在本仓库可查**。
> API 契约目前打破了这个前提：它是**跨仓库的运行时约定**，
> 既不在 `docs/` 里，也没有被 `AppError` 之外的任何测试钉住。
> 在它落进本仓库之前，**任何「API 层已完成」的说法都只能算「已写完，未验证」**。

---

### 2.2 🟡 已排期，到点处理

| # | 问题 | 什么时候处理 |
|---|---|---|
| **K13** | 🟠 **Figma 有 `StatusBar` 组件，Flutter 侧零实现** —— `App.tsx` L5231 渲染 `StatusBar light={lightStatusBar}`（`on-splash` 全屏时隐藏，Onboarding / 分析中等屏用浅色图标）。`lib/` 内 `SystemChrome` / `AnnotatedRegion` / `SystemUiOverlayStyle` **零匹配** | **Phase 3 App Shell 视觉定稿**（属 Shell 层职责）。⚠️ 图标深浅是否生效**只能在真机上看**（K3） | Flutter 侧实现；**「哪些屏幕用浅色状态栏」的逐屏映射需产品侧确认**（见 §3.1 · D50） |
| **K16** | 🟠 **「我的」头部 Logo 在 Figma 里是位图资源，仓库没有该资源** —— 图上只有一个图片节点、无文字节点。`assets/` 下无对应文件，且 `CLAUDE.md` §8.3 明令**不得自行下载/替代**美术资源 | **「我的」页头部一栏的视觉盖章**（现以已有品牌字标近似顶上） | **设计侧补齐位图**（放入 `assets/`）后替换；在此之前该栏**不得盖章** |
| **K7** | `applicationId` 仍是 `com.example.careerly`，release 仍用 debug 签名 | **发版前必须处理**（属发布决策） |
| **K9** | `CareerlyPlaceholderNote` 是 Phase 1 临时产物 —— 必须随各页面真实 UI 落地而**逐页删除** | 随 Phase 4–8 各页面落地 |
| **K10** | **导航栏与 `GlassSurface` 存在重复的 Glass 实现**（两份功能重叠的代码） | **Phase 2 批 3** 合并，届时删除导航栏内的私有副本 |
| **K12** | **`CareerlyBottomSheet` 成为第三处 Glass 组合** —— 因 `GlassSurface` 的圆角参数是单个 `double`，**表达不了非均匀圆角**，而 Figma 的 BottomSheet 正是 `S.glass` + 仅顶部圆角 | **Phase 2 批 3**，与 K10 一并处理；是否扩展 `GlassSurface` 见 **D30** |

> **K10 详述**：批 1 把导航栏里的私有 `_GlassEdgePainter` / `_GlassFilters`
> **泛化**成了公开的 `GlassEdgePainter` / `GlassFilters`
> （`lib/design_system/components/glass/`），供 `GlassSurface` 使用。
> 但**导航栏本身尚未切过去**，仍保留自己的私有副本。
>
> **这是有意为之**：批 1 的交付边界是「4 个组件 + 必要 Token」，
> 不把改动扩散到品牌识别度最高、最复杂的 `careerly_navigation_bar.dart`（856 行）。
>
> **未处理的风险**：两份实现若各自演化会产生**视觉漂移**。
> 在批 3 完成前，导航栏的 Glass 改动必须**同步检查** `GlassSurface`（反之亦然）。

> **K12 详述**：批 2 的 `CareerlyBottomSheet` 需要「**仅顶部圆角**的 Glass 面板」
> （Figma `S.glass` + `rounded-t-3xl`），而 `GlassSurface` / `GlassEdgePainter`
> 的圆角参数是单个 `double`，其文档要求**四角一致**。
>
> **该「四角一致」前提是错的** —— BottomSheet 就是一个反例。
>
> 批 2 的处置：**旁路** `GlassSurface`，直接组合其底层基元
> （`GlassFilters.blur()` + `AppColors.glassFill` / `glassBorder`）。
> 代价是项目里出现了**第三处** Glass 组合。
>
> ✅ 侥幸之处：`S.glass` **本身没有 inset 高光**，
> 所以不需要 `GlassEdgePainter` —— 只需填充 + 1px 描边 + blur，
> 这三样对非均匀圆角都成立。
>
> ⚠️ **批 2 没有改 `GlassSurface` / `GlassEdgePainter` 的既有代码**
> （那属批 1，未验收），因此 `GlassEdgePainter` 里那句错误的前提**仍在源码中**。
> 处理方式待 **D30** 裁决。

---

### 2.3 🟢 已处理，仅需知悉

| # | 问题 | 处置 |
|---|---|---|
| **K14** | **`docs/phase_1_report.md` §18 的 P3 / P4 / R3 已过时** —— 仍写「AI 入口是**嵌在导航栏内**的 46×46」「需确认 4 位置还是 3 Tab + 浮起球」。实际代码早已重写为 **62×62 / 条外**（见 §3.2 · Q1/Q3 复核）。**R3 至今仍在要求产品侧确认一件已经落定的事** | ✅ **不回改该文件** —— 它与 `Careerly_Vibe_Coding_开发启动_Prompt_V1.0.md` 同属**历史产物**，按只追加原则保留（与 §3.1 对 `docs/06_` 的处置同一先例）。**本条即为其失效标记**；`TODO.md` §3.2 · Q1/Q3 为现行真值 |
| **K2** | go_router 18.x 会导致 kernel 编译失败（→ `Error: Undefined name 'awaitNotRequired'`） | `pubspec.yaml` 已约束 `go_router: ^17.0.0`，原因写在注释里。⚠️ **`flutter analyze` 抓不到这个错**，只有 `flutter test` / `flutter build` 才暴露 |

---

### 2.4 ✅ 已关闭

| # | 问题 | 结论 | 记录 |
|---|---|---|---|
| **K4** | Android Back 的「**非首个 Tab 按返回先回首页**」不在任何锁定的产品规则源中（`01_PRD` / `04_IA` / `07_Baseline` / `06_Spec` 均无；`06_Spec` §39 只有一句「必须遵循页面层级」） | ✅ **2026-09-18 产品侧裁决：保持现状**。go_router 默认行为（**分支内有二级页 → 先 pop；分支根 → 退出 App**）即满足「遵循页面层级」。**未改任何代码** | `CHANGELOG.md` Session 009 |
| **K5** | Figma Glass 的多层 `inset box-shadow`，Flutter `BoxShadow` 不支持 inset | ✅ 方案**早已在 Phase 1 落地**（`_GlassEdgePainter` 用「裁剪到圆角矩形 + 沿边画内缩色带」还原，`_GlassFilters` 把 `backdrop-filter` 链翻译为 `ui.ImageFilter.compose`），只是当时未登记。批 1 已泛化为公共基元 —— 从「阻塞项」降级为「低风险重构」 | `CHANGELOG.md` Session 004 · D13 |
| **K6** | 未引入 `flutter_localizations`，Material 内建组件标签为英文 | ✅ **2026-09-18 已落地**：写入 `pubspec.yaml` + `MaterialApp.router` 接线（delegates + `supportedLocales: [zh_CN]`）。⚠️ `supportedLocales` 的登记范围**未经产品侧裁决**，见 §3.1 | `CHANGELOG.md` Session 006 |
| **K8** | 仓库未初始化 git | ✅ `fa4d290 chore: establish Careerly Phase 1 baseline`，Phase 1 基线已提交 | `CHANGELOG.md` Session 004 |

---

## 三、等产品侧裁决

> ⚠️ 以下**不是已锁定的产品规则**，是执行过程中浮现、**需要产品侧确认**的问题。
> 在确认前，Flutter 侧按「兼容实现 + 明确记录」处理，**未擅自定案**。

### 3.1 ⏳ 待裁决

> 📌 **登记规则（2026-09-18 新增，见 `DEVELOPMENT_WORKFLOW.md` §5.4）**
>
> 代码注释里出现 `待裁决` / `待确认` / `偏差` 等争议标记时，
> **必须同时在下方登记一条带编号的条目**；反之亦然。
>
> **为什么**：本文件是查争议的**唯一入口**。若争议只写在组件源码注释里，
> 验收时没人会去翻源码 —— 它会静默沉淀成「已确认」。
> 本规则建立时即发现一笔此类欠账（D19）。
>
> ⚠️ **2026-09-18 复查再次发现同类违规** —— Phase 4 批 1 的代码里
> 有 **6 处**「已登记待裁决」的引用，而 §3.1 **一条都没有**。
> 已补齐为 **D54–D58**（另有一条被代码引用却从未建立的裁决 **D53** → §3.2）。
> 与 D19 一样，它们此前**只活在源码注释里**。

---

> 📌 **以下是最新一批待裁决（D106–D111，2026-10-02「接通 work_agent 已有能力」新增）**，
> 放在最前只为便于阅读 —— **编号大 ≠ 优先级高**。
> 经过与理由见 `CHANGELOG.md` **Session 018**。

---

## D106–D111 — 2026-10-02 · 接通 work_agent 已有能力（① 退出登录 · ② 简历资产入口 · ④ 截图 OCR）

> **D106–D111 来自 Session 018**（② / ④ 的**后端**已交付并自测通过）；
> **D112–D113 来自 Session 019**（② / ④ 的 **Flutter 侧**已交付，见下）。
>
> 📌 **Session 019 之后，② / ④ 的 Flutter 侧已落地**（`ApiClient.postMultipart`、
> 提交改走 `POST /api/v1/resume`、`fetchProfile` 字段映射修复、白名单对齐、文案）。
> 本条块内 D107 因此**已裁决**（移入 §3.2），D108–D111 仍然有效。
> **D114–D116 来自 Session 020**（③ 岗位 URL 接线，见下方独立条块）。

#### D106 — 退出登录的**确认弹层**是 Flutter 侧补的（Figma 只有按钮）

**分类：【视觉/交互差异】**

Figma 的「设置」页只画了「退出登录」按钮，**没有**确认层规格。
Flutter 侧补了一层（理由：退出丢弃本机身份，属不可逆操作，
与既有 `CareerlyBackGuard` 的「未保存修改先确认」同型）。

**待确认**：文案（「要退出登录吗？」/「退出后需要重新登录才能查看你的职业资产与成长记录。」）
与「是否保留确认层」本身。

**现状**：已实现，注释中标注「未经产品侧确认」。

---

#### D107 — 图片 OCR 与 `on-resume` 上传卡文案冲突 → ✅ **已裁决**（2026-10-02）

**分类：【视觉/交互差异】**

产品侧 2026-10-02 采用 AI 侧草稿，两处文案含图片。
**详见 §3.2 已裁决留档。**

---

#### D108 — 「OCR 依赖缺失」由静默返回空改为显式报错，**影响既有端点**

**分类：【技术实现差异】**

改造前 `ResumeAgent._ocr_extract` 在缺依赖时 `return ""` ——
用户拿到空基线却看不到任何错误（典型「失败无痕」）。
现在统一抛 `ResumeExtractionError`。

**副作用**：`POST /api/v1/resume/upload`（`router_app.py`）在
「扫描件 PDF + OCR 不可用」时，行为从 `200 + 空 profile` 变为
`500 PARSE_ERROR`。

**待确认**：接受该变更，还是要求 `/resume/upload` 保持旧的宽容语义。

---

#### D109 — `BACKEND_API_CONTRACT.md` §0.5.2 记「文件上传 Flutter **明确不接**」

**分类：【产品冲突】**

`work_agent/docs/careerly/BACKEND_API_CONTRACT.md` §0.5.2 原文：

> `POST /api/v1/resume/upload` … **Flutter 明确不接**：单版本基线用文本即可，文件上传排 P3

**而本轮产品侧指令是「建立统一简历资产入口，文件上传是三种输入方式之一」。**

按 `CLAUDE.md` §3 的来源优先级（PRD > IA > Baseline > Dev Spec > Figma > 代码），
这条记在**契约文档**里的既往前议定，与本轮产品侧指令直接冲突 → **待裁决**。

⚠️ 该文档在工作区里**有未提交改动**，**不要覆盖**。

---

#### D110 — 「获奖经历」用什么数据源？

**分类：【产品冲突】**

`onboarding_confirm_page.dart` 的汇总卡第 4 行是「获奖经历」，
由 `ResumeProfile.awards` 驱动。

但后端**没有**这个数据：`app/careerly/assets.py` 明确写着

> `| ``awards`` | **not parsed** | ``[]`` |`

而 `ResumeProfile`（pydantic）里**只有** `certifications`
（Professional certifications）—— 它**不等于**「获奖」。

⚠️ 而且产品自己的提取清单（`on-resume` 的「AI 将自动提取」）把
**「技能与证书」与「获奖与荣誉」列为两项** —— 说明产品是区分二者的。
因此把 `certifications` 映射成 `awards` 会**违背产品自己的口径**。

**AI 侧不自行 invent**。**待确认**：
① 后端补奖项解析；② 该行长期为空（并在 UI 上表达）；
③ 或明确 `certifications → awards` 的映射。

---

#### D111 — 简历的**双轨存储**如何处理

**分类：【技术实现差异】**

```text
POST /api/v1/resume/upload  (router_app.py) → data/resumes/{id}.json   （通用能力）
POST /api/v1/resume         (careerly)      → careerly_resumes        （Careerly 资产）  ← 新增
```

Session 018 的**建议**（尚未获确认）：前者**保留不动**（它是 work_agent 的
通用能力，另有消费者），Careerly **只走后者**。

**待确认**：是否接受双轨并存；或需要前者向后者收口。

---

#### D112 — 文件白名单**去掉 `.doc`**（Flutter 侧的能力收窄）

**分类：【技术实现差异】** —— Session 019 新增

为与后端 `POST /api/v1/resume` 的 `_ALLOWED_RESUME_SUFFIXES` **逐项一致**，
`ResumeFileData.allowedExtensions` 从 `{pdf, doc, docx}` 改为
`{pdf, docx, txt, png, jpg, jpeg, webp, bmp}`。

**这是一处用户可见的能力变化**，不只是内部对齐：

```text
➖ 去掉 .doc   用户此前能在选择器里选中 .doc —— 但它**必然**被后端拒
              （python-docx 读不了旧二进制格式）。放行等于「可选但必然失败」。
➕ 加 txt      后端本就支持，Flutter 此前漏了。
➕ 加图片      产品侧指令（Session 018 §0「截图 OCR 属于本轮」）。
```

**待确认**：接受收窄（`.doc` 从「必然失败」变为「不可选」），
还是要求保留 `.doc` 并在 UI 上给出「请转存为 .docx」的指引。

---

#### D113 — 确认页 Empty 文案仍写着「**Mock 数据源**」

**分类：【视觉/交互差异】** —— Session 019 新增

`onboarding_confirm_page.dart` 的空态文案：

```text
'Mock 数据源默认返回空档案，接入真实接口后这里会显示解析结果。'
```

它是 D52（纯 Mock 阶段）留下的措辞。**Session 019 之后真实 API 已接通**
（`CAREERLY_USE_API=true`），该措辞不再成立：用户看到的将是一句
「解释我们内部数据源」的话，而不是一句面向用户的话。

**触发条件**：后端返回空 / 降级为无结构画像时（`ResumeProfile.isEmpty`）。
**正常解析成功时不显示**，故不影响主路径。

**待确认**：面向真实用户的空态文案。AI 侧**不自行起稿**（D66 的教训）。

---

## D114–D116 — 2026-10-02 · ③ 岗位 URL 接线（`CHANGELOG.md` Session 020）

> ③ 是「接通 work_agent 已有能力」的第 4 项。落点由产品侧 2026-10-02 裁决：
> **抓取回填 JD 文本框**（不是让 `/analysis` 直接收 URL），范围 **后端 + Flutter 一并做完**。
> 三条都不是「做没做」的问题 —— 都已落地 —— 而是**要不要接受这个口径**。

#### D114 — Mock 模式下「岗位链接抓取」**显式报错**，而不是返回假 JD

**分类：【技术实现差异】** —— Session 020 新增

`MockAnalysisRepository.parseJobUrl` **必然抛错**：

```text
UnknownError('岗位链接抓取尚未接入')
```

与 `MockResumeRepository.setCurrentVersion` 同款处置。理由：Mock 里没有爬虫，
两条「看起来更友好」的路都不可接受 ——

```text
返回空 ParsedJob  →  表单像是成功了，但 JD 框是空的；用户点「开始分析」
                    撞上「JD 不能为空」—— 失败点被挪到两步之后（D108 同类）
返回一段假 JD    →  违反 CLAUDE.md §7（不得编造产品数据），
                    且假 JD 与真抓到的 JD 在 UI 上无从分辨
```

**用户可见后果**：`CAREERLY_USE_API=false`（Mock 默认）时，
「粘贴岗位 URL → 添加岗位」**一定失败**并显示「岗位链接抓取尚未接入」。
**演示模式（`CAREERLY_DEMO_DATA=true`）也不例外** —— 这条路径的产出会被当成
真实岗位送进分析，不是展示位。

**待确认**：接受「Mock 下此路径必然报错」，还是要求 Mock 也给一份样例 JD
（若选后者，需产品侧明确「这是演示数据、与真实抓取不可分辨」可接受）。

---

#### D115 — 抓取端点**未写进 `BACKEND_API_CONTRACT.md`**

**分类：【技术实现差异】** —— Session 020 新增

`POST /api/v1/analysis/jobs/parse-url`（请求 `{url}` / 响应
`{url, title, company, description}`）目前**只存在于代码里**：

```text
✅ app/careerly/router.py + job_import.py + schemas.py + tests/test_p4_job_url.py
❌ docs/careerly/BACKEND_API_CONTRACT.md   ← 没有这一条
```

**为什么没写**：该契约文档**工作区里有未提交改动**（P3-5a 回写，D109），
本轮的规矩是**不覆盖它**；且 `schemas.py` 自身注明「契约文档由另一侧维护」。

**待确认**：由谁把这一条回写进契约（后端侧自行回写 / 与 D109 那批改动一起提交），
以及回写时要放在 §0.5.x「已落地」栏还是 §1「目标态」。

---

#### D116 — 抓取失败被归成 `AIError`（类型名与语义不符，用户文案正确）

**分类：【技术实现差异】** —— Session 020 新增

后端对「抓不到」返回 **502 `JOB_FETCH_FAILED`**（刻意不是静默空，见 D108 的反面）。
`ApiClient._mapError` 现有规则是 `statusCode >= 500 → AIError`，于是：

```text
用户看到的文案   ✅ 后端原文（「请确认链接可公开访问，或直接粘贴 JD 文本」）——
                    用户可执行，这一条没问题
错误类型 / 日志  ⚠️ 记为 AIError —— 但这是**爬虫**失败，不是 AI 失败
```

**本轮未改**：`_mapError` 是**全端点共用**的归一化入口，在其中为爬虫单开分支
会牵动所有 5xx 的归类（分析 502 就是 AIError，那条是对的）。

**待确认**：是否新增一个通用 `ServerError`（或按 `code` 而非仅按状态码分流）。
属技术侧可自行收口的项，登记在此只为**不静默**。

---

> 📌 **以下是前一批待裁决（D102–D105，2026-09-30 全量审查新增）**。其后仍接原本的 D54 起正文。

---

#### D102 — 09-23 之后的四批交付**授权记录与文档记录双双缺失**（2026-09-30 审查发现）

**分类：【产品冲突】/【技术实现差异】**（授权层面 —— 与 **D82 / D83** 同一类型）

**事实**（可在仓库内复算）：

```text
A  Android Back 统一        09-23–09-24   规则只进 CLAUDE.md §5.6，无 Session / D 编号
B  分析三条二级页 + 页面重写  09-24         无任何记录
C  真实后端 API 层           09-29         无任何记录；CURRENT_STATUS §3.5 仍写「无真实后端调用」
D 「选择文件」接线（D67）      09-30         未提交；§3.1 · D67 至今记作「待裁决」
```

**为什么按条文这算冲突**：`CLAUDE.md` §0 第三禁令（禁止自动进入下一 Phase）
与 §1.5「❌ 真实 Backend API / ❌ 任何业务页面」在文档层面**仍然有效**，
而代码已经越过它们。**但这不是「AI 违规」的结论** ——
D82 / D83 的先例说明这几种可能都存在：产品侧另开的会话、口头授权、或确实越界。
**在文档里无法区分，所以必须由产品侧澄清。**

**候选方案**（待裁决）：

```text
方案 A：追认授权（同 D82 / D83），AI 侧补登 Session 018+ 与 D 编号
方案 B：部分追认 —— 例如接受 A / B / D，要求 C（真实 API 层）先回退或
        用 CAREERLY_USE_API=false 保持 Mock 为唯一默认（当前默认确实为 false）
方案 C：不追认，要求回退相应范围后重新走授权流程
```

**附属项（同一次澄清里一起定）**：

```text
⚠️ Phase 9 / Phase 10 的授权状态在 CURRENT_STATUS.md 内自相矛盾
   （§2 表记 Phase 9「⛔ 未获授权」、同表记 Phase 10「▶ 正在进行」、
     本文件 §1.4 又称 Phase 3–10 全部未授权）—— 需产品侧给一次明确的当前授权边界
⚠️ 是否接受 CareerlyApp.overrides 这类「生产代码里的测试注入缝」
   （D 批引入：CareerlyApp 多一个 overrides 参数，供测试替换平台网关；
     已在源码注释里写明「生产代码不要传」）—— 属工程取舍，非产品规则
```

> ⚠️ **本条不阻塞补登文档**（§1.0d ④ · 第 0 步可先做）——
> 补登时把「授权来源未知」如实写成「待确认」即可，**不要写成「已授权」**。

---

#### D103 — D67 已被代码**事实上定案为方案 A**，而三种方案从未裁决（2026-09-30 审查发现）

**分类：【产品冲突】**（产品能力范围）

`§3.1 · D67` 原文明确写着：

```text
❌ 项目当前没有文件选择依赖
❌ D52 定的是「纯 Mock、不引入平台依赖」
⚠️ 三种方案的差别是**产品能力范围**，不是实现细节，故不自行定案
```

而 2026-09-30 的工作区把**方案 A**（接入 `file_picker`）完整实现了：
`ResumeFilePicker` 平台网关 + `pubspec.yaml` 的 `file_picker ^13.1.0`
+ 页面接线 + 测试（`CareerlyApp.overrides` 注入 Fake）。

**这正是 `CLAUDE.md` §0 第一禁令禁止的形态** ——
「不要用写代码的方式解决产品问题」。它是否被授权，**文档里查不到**。

**需要产品侧回答的**：

```text
① 方案 A 是授权过的吗（若是 → 追认 + 补 D67 的裁决记录；若否 → 要求回退到方案 B）
② 10MB 上限 / PDF·Word 白名单来自 Figma 文案（`App.tsx` L761 / L768），
   —— 实现侧**未擅自扩展**，此处只需确认它可作为**产品规则**生效
③ 「选择文件」在**无后端可上传**时的语义：当前会走 Mock 提交并进入解析页，
   是否需要提示「本次未真实上传」
```

**引用**：`lib/core/services/resume_file_picker.dart` ·
`lib/data/models/resume_file.dart` · `lib/features/onboarding/presentation/onboarding_resume_page.dart`

---

#### D104 — MVP 的**会话口径**：API 层只把 JWT 放在内存，重启即登出（2026-09-30 审查发现）

**分类：【产品冲突】/【技术实现差异】**（D52 / D54 的延伸）

C 批的 `ApiClient` 已按 **D52** 的约束实现会话 —— JWT **只存在内存里**，
未引入 `shared_preferences` / `secure_storage`；App 重启后需要重新登录。
同时 **D84** 已把默认入口定为 `/onboarding/splash`。

两条合起来会产生一个**尚未定义的用户可见行为**：

```text
真实后端 + 重启 App  →  又回到开屏，要求重新注册/登录
```

**候选方案**（待裁决）：

```text
方案 A：MVP 就是「每次启动都重新登录」—— 明确写进产品规则，验收时不再当缺陷
方案 B：解除 D52 限制，引入本地存储做会话保持 —— 需产品侧先给期望行为（即 D54 的方案 C）
方案 C：仅对「真实后端模式」引入存储，Mock 模式保持无存储
        —— ⚠️ 两种模式行为不同，会制造「演示通过、真机不通过」的假象，需慎重
```

> ⚠️ 本条**不阻塞** Mock 模式下的任何验收 —— 只有真实后端联调（§1.0d ④ · 2.3）才必须先用它定案。

---

#### D105 — Mock 模式下**免费额度不持久化**，「3 次」形同虚设（2026-09-30 审查发现）

**分类：【技术实现差异】**（Mock First 的副作用）

`MockAnalysisRepository.fetchQuota()` **恒返回 `QuotaState.free`**（3 次，写死），
且 Mock **不保存 `used`**；而分析页 / 「我的」页 / 会员页每次进入都会
`loadQuota()`。因此：

```text
扣减 → 退出页面 → 重进页面 → 额度复位为 3 / 3
```

**扣减与回滚的状态机本身是正确的**（`analysis_provider.dart` 的
`consume()` / `rollback()` / `_runId` 代际号防僵尸结果），
问题只在**数据源不持久化**；全项目无本地存储依赖，重启即失。

**这不是「Mock 允许」的那类空实现** —— `CLAUDE.md` §5.2 的 3 次额度是
**不可协商的产品规则**，而当前 Mock 下它在行为上不成立，会造成
「验收时看起来有额度门禁、实际可以无限分析」的假象。

**候选方案**（待裁决）：

```text
方案 A：Mock 侧加一个**会话级**内存计数（不引依赖），使 3 次在单次运行内真实生效
        —— 不改产品规则、不引存储，只是让 Mock 不再自相矛盾
方案 B：明确「额度只在真实后端模式下有意义」，Mock 下不演示该能力
        —— 需产品侧确认这不是验收项
方案 C：引入本地存储（与 D54 / D104 一并解决）
```

**引用**：`lib/data/mock/mock_analysis_repository.dart:50-54` ·
`lib/features/analysis/presentation/analysis_page.dart:68` ·
`lib/features/analysis/state/analysis_provider.dart:96,111,134`

---

#### D54 — 「App 启动进入 Onboarding 还是首页」依赖会话持久化，当前无法表达

**分类：【产品冲突】/【技术实现差异】**（Phase 4 批 1 新发现）

Figma 原型的入口是 `on-splash`，而 Flutter 侧 `createAppRouter()` 的
`initialLocation` 默认**仍是 `/home`**，Onboarding 处于
**「可达但未接线」**状态（直接访问 `/onboarding/splash` 可进入）。

**这不是遗漏，是有意保留。** D52 把批 1 明确限定为
「纯 Mock、**不引入本地存储依赖**」，而「已注册用户不该再看一遍引导」
这个判断**只能由会话持久化提供**。在该前提下硬把入口改成开屏，
会得到「每次启动都要求重新注册」的错误行为 —— **比暂时不接线更糟**。

**同源引用（三处，均指向本条）**：
`lib/app/app.dart:31` · `lib/app/router/app_router.dart:55` ·
`lib/data/repositories/auth_repository.dart:16`

**候选方案**（待裁决）：

```text
方案 A：引入本地存储（shared_preferences / secure_storage），
        以「是否已注册」决定入口 —— 需先解除 D52 的「不引入存储依赖」限制
方案 B：MVP 阶段不做会话保持，每次启动都进 Onboarding
方案 C：由产品侧先给出「已注册用户重新打开 App」的期望行为，再定实现
```

> ⚠️ 本条**阻塞 Phase 4 的「接线」收口**。批 1 的两页视觉与交互不受影响，
> 但「用户首次注册后能否回到 Onboarding」这件事在裁决前无法闭环。

---

#### D55 — Figma 里「登录」没有独立页面，两个按钮都跳注册页

**分类：【产品冲突】/【IA 冲突】**

`App.tsx` L409 / L416 —— 开屏的「点击登录」与「点击注册」
`onClick` **都是** `go('on-register')`，且 `ONBOARDING_SCREENS`（L5162）
里**没有**独立的登录屏。**设计稿中「登录」不拥有自己的页面。**

Flutter 侧**原样实现**了这个行为，并在测试里**显式钉住**
（`phase4_onboarding_test.dart`「『点击登录』**也**进入注册页」），
防止后人把它当成 bug「顺手修好」。**未自行发明登录页** ——
新增页面属 `CLAUDE.md` §0 第二禁令范围。

**同源引用（两处）**：`onboarding_splash_page.dart:27` ·
`onboarding_register_page.dart:27`

**候选方案**（待裁决）：

```text
方案 A：维持现状 —— 登录复用注册页（当前实现）
方案 B：登录作为注册页的「切换模式」（同一页两种形态）
方案 C：设计侧补一张独立登录屏；AuthRepository 相应补 login 方法
方案 D：登录不进 MVP，入口暂不提供
```

---

#### D56 — 注册页三个表单标签用了两种灰（`#727272` / `#6B7280`）

**分类：【视觉/交互差异】**

Figma 中「姓名」标签走 `LABEL` 常量（`#727272`），
而「手机号」「邮箱（选填）」被**内联覆盖**成 `#6B7280`。
三个同层级字段却用两种灰。

Flutter 侧判断这更像原型里的手写残留而非规则，
故统一走 `AppTypography.inputLabel`（`#727272`），**未复刻该差异**。

**引用**：`onboarding_register_page.dart:273`

**候选方案**（待裁决）：

```text
方案 A：维持统一（现状）—— 标签灰收敛为 inputLabel 的 #727272
方案 B：照 Figma 原样，两个字段单独覆盖为 #6B7280
```

---

#### D57 — 注册页「继续」的可用性校验规则为 Flutter 侧补齐

**分类：【视觉/交互差异】**

Figma **未定义任何表单校验**。Flutter 侧取**最小**规则：

```text
「继续」可用  ⟺  姓名非空 且 手机号非空
```

手机号格式 / 验证码 / 邮箱格式校验 **均未自行发明**。

**引用**：`onboarding_register_page.dart:39-41`（同页 `_canSubmit`）

**候选方案**（待裁决）：

```text
方案 A：接受「非空即可」（现状）
方案 B：由产品侧给出注册所需的真实校验规则（含手机号格式 / 验证码）
```

---

#### D58 — 注册页头像用 Material 图标近似 Figma 的自绘 SVG

**分类：【视觉/交互差异】**

Figma 的头像人像是**自绘 SVG**（圆形头部 + 肩部弧线），
右下角徽标内的铅笔同样是自绘 SVG。
Flutter 侧用 `Icons.person` / `Icons.edit_outlined` 近似，
**未新建图标资源**。

**引用**：`onboarding_register_page.dart:205-209`

**候选方案**（待裁决）：

```text
方案 A：接受 Material 图标近似（现状）—— 待真实页面视觉验证后定
方案 B：补自绘 SVG 资产，与 Figma 逐位一致
```

---

#### D62 — 页面转场：被覆盖页的位移与 Figma 有一处刻意偏差

**分类：【视觉/交互差异】**（Phase 3 · P3-3 实现时新增）

Figma `index.css` L137-162 的四条关键帧里，
`.page-pop`（`translateX(-20px) → 0`）作用在**被揭开的页**上；
而 push 时下层页**不动**（React 里它直接被卸载）。

Flutter 的 `secondaryAnimation` 是**对称**的
（被覆盖 `0→1`、被揭开 `1→0`），**无法只响应其中一个方向**。

当前实现（`lib/design_system/motion/careerly_page_transition.dart`）选择
**保留对称位移**：push 时下层页轻微左移 20px，pop 时滑回。

**理由**：Baseline §6.6 明令「返回：与进入形成**相反关系**，
不允许瞬移或重新淡入整页」—— 只做单侧会让 pop 失去反向关系。

**引用**：`lib/design_system/motion/careerly_page_transition.dart`
`CareerlyTransitionKind.coveredOffset` 的文档注释

**候选方案**（待裁决）：

```text
方案 A：保留对称位移（现状）—— 满足 Baseline §6.6，但与 Figma push 行为不同
方案 B：push 时下层页不动 —— 与 Figma 逐位一致，但 pop 无反向关系
方案 C：用自定义 Animatable 只响应单调下降的 secondaryAnimation
        —— 两者兼得，但实现复杂度明显上升
```

> 需**真机视觉验证**后再定：桌面定稿看不出这 20px 的差别。

---

#### D66 — `on-parsing` / `on-confirm` 的**文案**由 AI 侧起草，待产品侧确认

**分类：【视觉/交互差异】**（D63 裁决「保留视觉、只换文案」后产生）

D63 定的方向是「只换文案」，但**产品侧未给出具体文案**。
AI 侧依据 PRD §7.2 的 Career Baseline 定义起草了一套，
**必须由产品侧逐条确认后才算定稿**。

**引用**：
- `lib/features/onboarding/presentation/onboarding_parsing_page.dart`
- `lib/features/onboarding/presentation/onboarding_confirm_page.dart`

**两处需特别注意的文案**：

| 位置 | Figma 原文 | 本轮实现 | 问题 |
|---|---|---|---|
| `on-parsing` 副行 | `正在认识` | **照抄原文 `正在认识`** | **源码就只有这四个字**（已逐字核实），像是一句被截断的话。按 D63 的基线语义，本应补全，但补全即属创作 → **待确认** |
| `on-parsing` 底部按钮 | `退出分析` | **`退出解析`** | 该屏已不是「分析」，按钮文案随之失去依据 → 待确认。本轮**只把「分析」换成「解析」**（该屏的真实动作是解析简历），不做其它改写 |
| `on-parsing` 5 步 label / sub | 岗位需求解析 … | **AI 起草的 5 步**（见下） | D63 已裁决「只换文案」，但产品侧未给文案 |
| `on-parsing` 药丸 / 大标题 | `解析完成` / `解析完成！` | **照抄原文** | 「解析」二字本身不违反 D63（被禁的是岗位需求解析 / 匹配度 / 排名 / Gap），故**不改**，减少创作面 |
| `on-confirm` 标题 / 说明 / 横幅 | `你的职业档案已建立！` … | **照抄原文** | ⚠️ 「档案」与 D63 定的「职业基线」**措辞并存**，待一并确认 |

**AI 起草的 5 步文案**（依据 PRD §7.2 对 Career Baseline 的定义）：

```text
1 读取简历       —— AI 通读你提交的简历内容
2 整理工作经历   —— 归纳职位、职责与任职时间
3 提取项目经验   —— 整理项目成果与其中的证据
4 汇总技能与获奖 —— 汇总技能、证书与获奖经历
5 形成职业基线   —— 生成你的初始能力画像
```

**候选方案**（待裁决）：

```text
方案 A：确认 AI 起草的文案（5 步 + 「退出解析」）
方案 B：产品侧给出正式文案，AI 侧替换
        —— 改动集中在 onboarding_parsing_page.dart 的 _steps 常量表
           与 _ExitButton 的一行，成本低
```

---

#### D67 — 「选择文件」需要文件选择能力，本轮（纯 Mock）无法实现

> 🔴 **状态变更（2026-09-30 审查）**：**代码已把方案 A 实现完毕**
> （`file_picker ^13.1.0` + `ResumeFilePicker` 网关 + 页面接线，见 §1.0d ③ · D 批），
> **而本条的三种方案从未裁决**。这属 `CLAUDE.md` §0 第一禁令禁止的
> 「用写代码的方式解决产品问题」形态 —— 已另立 **D103** 追踪，
> **本条的裁决状态在 D103 结案前仍然有效。**

**分类：【技术实现差异】**（Phase 4 批 2 落地时发现）

`on-resume` 有两种提交简历的路径：

```text
① 选择文件      ← Figma 的 file input
② 粘贴简历文本  ← 纯文本，Flutter 侧可完整实现
```

路径 ② 不需要任何新能力，本轮**已完整实现**。
路径 ① 需要调起系统文件选择器，而：

```text
❌ 项目当前**没有**文件选择依赖（flutter pubspec 里无 file_picker / file_selector）
❌ D52 定的是「纯 Mock、不引入平台依赖」
❌ CLAUDE.md §6.5：新增依赖必须「明确必要 + 当前阶段实际使用」
   —— 当前无后端可上传，选了文件也无处可去，不满足第二条
```

**当前处置**：`选择文件` 走 [ResumeRepository] 之外的一条明确失败路径，
向用户展示「文件选择尚未接入」的可见提示（不是静默无反应的死按钮）。

**引用**：`lib/features/onboarding/presentation/onboarding_resume_page.dart`

**候选方案**（待裁决）：

```text
方案 A：接入 `file_picker`，本轮只做「选中文件名」的展示，不上传
        —— 好处：主按钮真的能用；代价：新增平台依赖，与 D52 的「纯 Mock」相抵
方案 B：维持现状（明确提示未接入），待后端可上传时一并接入
方案 C：把「选择文件」也收敛为文本文案粘贴（等于删掉一条设计稿给出的路径）
        —— ⚠️ 属修改产品规则，AI 侧不自行采用
```

> ⚠️ 三种方案的差别是**产品能力范围**，不是实现细节，故不自行定案。

---

#### D50 — 状态栏图标深浅的「逐屏映射」Figma 有实现、但未形成规则

**分类：【技术实现差异】/【视觉/交互差异】**（本轮新增，见 K13）

Figma 的 Shell 把状态栏图标颜色**逐屏硬编码**（`App.tsx` L5224-5225）：

```text
hideStatusBar  = screen === 'on-splash'          // 开屏全屏，不画状态栏
lightStatusBar = ['growth-record', 'analysis-history', 'a-processing',
                  'on-register', 'on-career', 'on-welcome',
                  'on-resume', 'on-parsing', 'on-confirm']
```

即：**Onboarding 全流程 + 分析中 + 成长记录 + 历史分析** 用浅色（白）图标，
其余屏用深色图标。

**问题**：这是一份**屏幕名清单**，不是一条可以推导的规则。
Flutter 侧实现它有两个选择：

```text
方案 A：照抄这份清单 —— 但屏幕名是 Figma 原型的内部命名，
        与 Flutter 的 route / 分支结构不一一对应
方案 B：提炼出规则（如「深色背景页 → 浅色图标」）—— 需产品侧/设计侧确认规则本意
```

**本轮未实现**（K13 未消除）。实现前需先裁决映射方式。

**候选方案**（待裁决）：

```text
方案 A：按「背景是否为深色」推导，由页面自己声明（AnnotatedRegion 就近声明）
方案 B：由 Shell 层按 route 统一映射，规则写成显式表
方案 C：设计侧给出可推导的规则，而非屏幕清单
```

---

#### D19 — `CareerlyButton` 按压反馈时长与 Figma 偏差 20ms

**分类：【视觉/交互差异】**

| | 值 |
|---|---|
| Figma `PrimaryBtn` / `SecondaryBtn` | `transition 120ms` |
| 代码实际 | `AppMotion.micro`（100ms） |

**偏差 20ms。** 原因：`AppMotion` 没有 120ms 档，
而 100ms 落在 `micro` 自述区间（80–120ms）内，故**未自行新增 Token**。

**待裁决**：是否为按钮补一档 `120ms` 时长 Token。

> ⚠️ **本项此前只写在代码注释里**（`lib/design_system/components/careerly_button.dart:198-205`），
> **未登记到本文件**。2026-09-18 补登 —— 这正是「争议只活在注释里」的典型漏洞。

---

#### D21 — `CareerlyAsyncStateView._Loading` 与 `CareerlyProgress` 职责重叠

**分类：【技术实现差异】**

`CareerlyAsyncStateView` 的私有 `_Loading` 已内建一个
`CircularProgressIndicator`，且已接 `AsyncLoading.progress`（即已支持确定进度）。
`CareerlyProgress` 落地后，两者在「展示进度」上出现职责重叠。

**候选方案**（待裁决）：

```text
方案 A：_Loading 内部改用 CareerlyProgress，Material 组件退位
方案 B：保持现状，两者各服务不同场景（页面级 vs 组件级）
```

**本轮处理：不动。** 属跨组件重构，**不在批 2 边界内**（与 K10 同类）。
批 2 **只新增、不改既有实现**。

---

#### D22 — Material `SnackBar` / `bottomSheet` 主题与自绘组件的重叠

**分类：【技术实现差异】**

`CareerlyTheme` 已定义 `snackBarTheme` 与 `bottomSheetTheme`。
`CareerlyToast` / `CareerlyBottomSheet` 落地后，这两个主题将**退化为兜底**
（只服务第三方组件与 Material 内建弹窗），不再服务业务页面。

**本轮处理：不动主题定义**，仅登记归属关系。是否清理待后续裁决。

---

#### D23 — K6 落地的实现选择：`supportedLocales` 只登记 `zh_CN`

**分类：【技术实现差异】**

K6 只裁决了「引入 `flutter_localizations`」，**未裁决语言登记范围**。
落地时做了如下选择，**未经产品侧裁决**：

```dart
supportedLocales: const <Locale>[Locale('zh', 'CN')],
```

**理由**：Careerly 目前只提供中文 UI。只登记 `zh_CN` 时，
无论设备语言是什么，Flutter 都会解析到唯一候选，
Material 内建组件（日期选择器 / 长按菜单 / Tooltip）保持中文。

**影响**：若未来要支持多语言，此处必须改为多语言列表 + 语言切换入口。

---

#### D29 — `AppRadius.sheet` 只覆盖了 Figma 两种圆角中的一种

**分类：【技术实现差异】**

`AppRadius.sheet` 定义于批 1，注释写「Bottom Sheet 顶部圆角」：

```dart
static const BorderRadius sheet = BorderRadius.vertical(
  top: Radius.circular(xxl),   // 28
);
```

但 Figma 的 6 处内联变体里，**只有 C / D 用 28**，
A / B / E / F 用的是 **24**。该 Token 因而**把两种取值收敛成了一档**，
名字却声称是通用的 Bottom Sheet 圆角。

**批 2 的处理**：`CareerlyBottomSheet` **不改动该 Token**（属批 1 既有实现），
改为按 tone 分别取 `AppRadius.xxl`（28）/ `AppRadius.xl`（24）。

**候选方案**（待裁决）：

```text
方案 A：保留 AppRadius.sheet = 28，明确其语义为「大号 Sheet 圆角」，
        并新增一个「标准 Sheet 圆角 = 24」
方案 B：让 AppRadius.sheet 指向出现次数更多的 24，
        28 改由 AppRadius.xxl 直接表达
方案 C：承认「Sheet 圆角不是一个 Token」，删除该语义别名
```

**倾向 A** —— 不删除既有 Token，且两种取值都有明确归属。

---

#### D30 — `GlassSurface` 不支持非均匀圆角，BottomSheet 因此旁路

**分类：【技术实现差异】**

`GlassSurface` / `GlassEdgePainter` 的圆角参数是单个 `double`，
`glass_edge_painter.dart` 的注释写：

> 「圆角半径。要求**四角一致**——Figma 的所有 Glass 面都是均匀圆角。」

⚠️ **该前提是错的。** Figma 的 BottomSheet 变体 E / F 用的正是
`S.glass` + `rounded-t-3xl`（**仅顶部圆角**）。

**批 2 的处理**：`CareerlyBottomSheet` 旁路 `GlassSurface`，
直接组合 `GlassFilters.blur()` + `AppColors.glassFill` / `glassBorder`。

**为什么不直接扩展 `GlassSurface`**：那会修改**批 1 的既有实现**，
而批 1 **尚未验收** —— 违反批 2 的开发边界（见 §1.1）。
因此选择「新增而不改动」，代价是产生第三处 Glass 组合（**K12**）。

**遗留问题**：`GlassEdgePainter` 里那句错误的前提**至今仍在源码中**，
会误导后续开发者。

**候选方案**（待裁决）：

```text
方案 A：把 GlassSurface / GlassEdgePainter 的 radius 参数
        从 double 放宽为 BorderRadius；同步修正注释
        → 需要改动批 1 代码，建议放在合并验收通过之后
方案 B：保持现状，BottomSheet 永久旁路
        → Glass 组合长期存在三份，漂移风险持续
```

**倾向 A，但排在合并验收之后** —— 与 K10 一并在批 3 处理最省事。

---

#### D31 — `CareerlyProgress` 时长偏差（统一取 550ms）

**分类：【视觉/交互差异】**

Figma `OnboardingProgress` 给了**两个**时长：

```text
值变化（transition: all 500ms）
入场（.bar-grow，600ms）
```

`CareerlyProgress` 统一使用 `AppMotion.reveal`（**550ms**），
即两者之间值，且落在同档「重大结果揭示 400–700ms」内。

**偏差**：值变化 **+50ms** / 入场 **−50ms**。**未自行新增 Token**。

**候选方案**（待裁决）：

```text
方案 A：接受 550ms 统一值（现状）—— 视觉差异不可感知
方案 B：新增两个 Token 分别表达 500 / 600
        → 与「不新增依赖 / 不新增 Token」的克制原则冲突
```

**倾向 A。**

---

#### D32 — `CareerlyToast` 的停留时长（2500ms）设计侧未定义

**分类：【视觉/交互差异】**

Figma 只给了 Toast 的进出动画（160 / 180ms），**没有给停留时长**。
`_ToastMetrics.displayDuration` 取 **2500ms**，属 **Flutter 侧补齐**。

**候选方案**（待裁决）：

```text
方案 A：接受 2500ms（现状）
方案 B：由设计侧补一个明确值
```

**这是 D26「用已有 Token 补齐」无法覆盖的一项** ——
Token 里没有「停留时长」这类值，因此它是**新造的数字**，
必须单独裁决。

---

#### D33 — `CareerlyToast` 进出动画偏差，以及是否新增「轻提示」时长档

**分类：【视觉/交互差异】**

Figma 真值：进入 `160ms ease-out`、退出 `180ms ease-in`。
`_ToastPresenter` 两者统一取 `AppMotion.button`（**160ms**）。

**偏差**：退出比真值**少 20ms**。未自行新增 Token ——
`AppMotion.button` 自述区间为 `120–200ms`，160 与 180 均落在区间内。

**遗留的语义问题**：`button` 显然不是「轻提示」档，
用它表达 Toast 动画是**语义错配**。

**候选方案**（待裁决）：

```text
方案 A：接受现状，靠「区间内」兜住
方案 B：为「轻提示 / 瞬时反馈」新增一档时长 Token
```

---

#### D34 — `CareerlyBottomSheet` 的面板高度上限（0.9）为工程兜底

**分类：【技术实现差异】**

Figma **未定义**任何高度档位（half / full 之类）。
`_BottomSheetMetrics.maxHeightRatio = 0.9` 是**防止内容溢出**的工程兜底，
**不是设计值**。

同理，拖拽关闭（drag-to-dismiss）**有意未实现** ——
Figma 无法表达拖拽手势，位移 / 速度阈值属 Flutter 侧需自定的交互参数，
在无产品侧输入的情况下不应自行发明。

**候选方案**（待裁决）：

```text
方案 A：接受 0.9 兜底 + 暂不做下滑关闭
方案 B：设计侧给出高度档位与拖拽规格
```

---

#### D35 — `AppShadows.sheet` 语义别名很可能取错了源

**分类：【技术实现差异】**

`AppShadows.sheet` 定义为 `= md`，注释写「模态 / Bottom Sheet 投影」。
但 `md` 的真值是 `App.tsx` L3166 的**一张 Glass 信息卡**
（`0 12px 24px rgba(155,177,201,0.25)`），**不是 Bottom Sheet**。

Figma 里 Bottom Sheet 的阴影是**向下反方向**的：
L4603 `0px -2px 48px rgba(0,0,0,0.18)`。

**即：该别名指向的阴影，方向与用途都不对。**

**批 2 的处置**：不改动（属批 1 既有实现），仅标注。
`CareerlyBottomSheet` **未引用本值**（用自己的内联投影），改动无风险。

**候选方案**（待裁决）：

```text
方案 A：修正 AppShadows.sheet，改为底部面板的真实投影（向上 / 更深）
方案 B：删除该语义别名 —— 目前引用点极少
```

---

#### D36 — `AppMotion.stagger` 落在 motion-spec 规定区间之外

**分类：【视觉/交互差异】**

`motion-spec` §27 明写列表项错峰延迟为 **`50–80ms`**，
而 `AppMotion.stagger` 取 **40ms** —— **落在区间之外**。

**批 2 的处置**：**未自行改值**（改它属于视觉决策），登记待裁决。
该 Token 当前**引用点为 0 处**，改动无风险。

**候选方案**（待裁决）：

```text
方案 A：改为 60ms（区间中点）
方案 B：由设计侧给出确值
```

---

#### D37 — `AppSpacing.pageHorizontal` 取 16，而 Figma 最主流的是 20

**分类：【视觉/交互差异】**

Figma 的页面横向留白实际分布：

| Tailwind | 值 | 出现次数 |
|---|---|---|
| `px-5` | **20** | **47** ← 最主流 |
| `px-6` | 24 | 22 |
| `px-4` | 16 | 12 |

`AppSpacing.pageHorizontal = md`（**16**）取的是**第三名**。
**20 更可能是真值。**

**影响面：全局** —— 所有业务页面的左右留白都来自这一项。

**批 2 的处置**：未改值。这是**最需要在真实页面上验证**的一项，
必须在有真实页面后才能判断，不是现在能拍板的。

**候选方案**（待裁决）：

```text
方案 A：改为 mdLg（20），与 Figma 主流一致
方案 B：维持 16，待真实页面视觉验证后再定
```

> ⚠️ **本项属「暂定 Token」的典型样本** —— 有 Figma 依据（值真实存在），
> 但**选错了档**。集中登记见 `CURRENT_STATUS.md` §3.6。

---

#### D38 — `AppTypography.numeric.fontSize = 32` 不在 Figma 的字号集合内

**分类：【视觉/交互差异】**

Figma 实际使用的字号共 **22 个**
（9/10/11/12/13/14/15/16/17/18/20/21/22/24/26/28/30/36/40/48/50/56）。
`32` **不在其中**（最接近的是 30 与 36，各出现 1 次）。

匹配度分数是 Careerly 的**核心视觉锚点**，
这个字号**尤其需要真实页面验证**。

**候选方案**（待裁决）：

```text
方案 A：改为 36（Figma 中真实存在，且量级接近）
方案 B：维持 32，待真实页面视觉验证
```

---

#### D39 — `AppRadius.input` 与 Figma 的输入框圆角不统一

**分类：【视觉/交互差异】**

Figma 的输入框**圆角不唯一**：

| 场景 | 圆角 |
|---|---|
| 工作台内联表单（JD / 链接） | `rounded-2xl` = **16** |
| a-jd-step 展开区 | `rounded-xl` = **12** |

`AppRadius.input = borderMd`（16）取的是前者 —— 因为那是更完整的一版表单。

**候选方案**（待裁决）：

```text
方案 A：维持 16（现状）
方案 B：由设计侧统一输入框圆角后回改
```

---

#### D40 — `AppTypography` 的 Type Scale 整节（含行高 / 字距）为归纳值

**分类：【视觉/交互差异】**

**Figma 里没有 Type Scale。** 它是 22 个零散字号，
且 `text-[Npx]` 与内联 `fontSize` 两套写法混用，**无阶梯、无层级命名**。

`AppTypography` 的 11 个角色是 Flutter 侧**重新归纳**的结果：

```text
fontSize      未必等于任何一处 Figma 原值
height        没有来源（Figma 未定义行高）
letterSpacing 没有来源（Figma 未定义字距）
```

**影响面：全局排版。** 若实际页面上字号层级观感不对，改这一节即可。

**批 2 的处置**：未改值 —— 归纳 Type Scale 本身是 Baseline §6.2 的既定原则
（「原型数值需要重新归纳，不 1:1 抄」），**不是错误**。
但「归纳出的这套值是否成立」**必须在真实页面上验证**。

> ✅ **组件级角色不在本项范围内** ——
> `buttonPrimary` / `buttonSecondary` / `chipSmall` / `chipMedium` /
> `navAiGlyph` / `navAiLabel` 都是 **Figma 原值**，有明确依据。

---

#### D41 — `AppSpacing` / `AppRadius` 的语义别名整节为归纳值

**分类：【技术实现差异】**

Figma **不使用语义名** —— 它直接写 Tailwind 类（`px-5` / `p-4` / `gap-3` …）
或内联数值。因此这些别名都是 Flutter 侧「挑一档最常见的当语义值」。

**`AppSpacing` 语义别名**（全部无 Figma 语义名）：

| Token | 值 | Figma 依据状况 |
|---|---|---|
| `pageHorizontal` | 16 | ⚠️ 选错档，见 **D37** |
| `pageTop` | 24 | 无对应语义名 |
| `pageBottom` | 32 | 无对应语义名 |
| `cardPadding` | 16 | `p-5`(20) 21 次 / `p-4`(16) 20 次 —— **几乎持平，难以判定** |
| `cardGap` | 12 | `gap-3`(12) 37 次 ✅ 与主流一致 |
| `listGap` | 12 | 无对应语义名 |

**`AppRadius` 语义别名**：

| Token | 值 | 依据状况 |
|---|---|---|
| `card` | 24 | `rounded-3xl` 8 次 + `rounded-t-3xl` 5 次 |
| `cardSmall` | 16 | `rounded-2xl` 25 次 ✅ 最主流 |
| `button` | pill | `rounded-full` 81 次 ✅ 压倒性主流 |
| `input` | 16 | ⚠️ 不统一，见 **D39** |
| `sheet` | 28 | ⚠️ 只覆盖一半，见 **D29** |

> ✅ **刻度值本身全部有依据** —— 12/14/16/20/24/28 均能在 `App.tsx` 的
> 内联 `borderRadius` 中找到。归纳的是**「分成六档」这件事**，
> 不是档位取值。

**批 2 的处置**：未改值。同 D40，归纳本身是既定原则，
但归纳结果需真实页面验证。

---

#### D42 — `AppShadows.sm` / `brand` 无逐位一致的 Figma 来源

**分类：【视觉/交互差异】**

`AppShadows` 的多数值是 Figma 逐位还原（`glass` / `glassLight` / `md` /
`button` / `primaryButton` / 全部 `nav*`），但有两项例外：

| Token | 代码值 | Figma 状况 |
|---|---|---|
| `sm` | `rgba(155,177,201,0.06) / 0 2px 8px` | **无对应原值**。以 `155,177,201` 为色的阴影只有 L1113（`0 8px 20px 0.25`）与 L3166（`0 12px 24px 0.25`），**都不匹配** |
| `brand` | `rgba(79,126,245,0.20) / 0 10px 24px` | **无逐位一致值**。最接近 L589 `0 10px 14px 0.28`（偏移同，模糊与透明度不同）。Figma 的品牌卡片阴影本身就有 4 套近似值 |

**批 2 的处置**：未改值（不属批 2 边界），仅标注。

**候选方案**（待裁决）：

```text
方案 A：由设计侧为「轻量分层」与「品牌卡片」各定一个标准值
方案 B：接受现状（Figma 本身就不统一，替代值是合理的归纳）
```

---

#### D43 — `AppColors` 中 3 个色值在 Figma 中出现 0 次

**分类：【视觉/交互差异】**

`AppColors` 的绝大多数值都能在 Figma 中找到（多为 10 次以上），
但以下 3 项**出现 0 次**：

| Token | 代码值 | 情况 | 影响面 |
|---|---|---|---|
| `backgroundFallback` | `#EDE9FA` | Flutter 侧从背景渐变取的近似中间值 | 渐变不可用时的兜底 |
| `disabled` | `rgba(17,24,39,0.38)` | Figma 的不可用按钮**只把文字调灰**，未定义背景 / 边框（见 D16） | **7 处引用** |
| `info` | `#4F7EF5` | Figma 的 `S` 对象里**只有 `green` / `orange`**，无「信息」语义色 | 1 处引用 |

**批 2 的处置**：未改值。三者都是**为凑齐四态 / 语义而推导**的
（与 D16 同类：补齐而不是发明，但取值未经裁决）。

---

#### D44 — `careerly_theme` 的 `_inputDecorationTheme` 没有 Figma 依据

**分类：【技术实现差异】**

`lib/design_system/theme/careerly_theme.dart` 的 `_inputDecorationTheme`
是 **Phase 1 的 Material 3 兜底**，不是 Careerly 组件：

```text
filled: true + fillColor: AppColors.glassFillLight
OutlineInputBorder(borderRadius: AppRadius.borderMd)
contentPadding: md / sm
```

**Figma 中没有任何输入框使用这套样式** ——
真实输入框是「透明底 + 仅下边框」（Onboarding）
或「半透明底 + 细边框」（工作台），**与 M3 的 filled + outline 无关**。

**批 2 的处置**：未改。它**当前没有业务引用点**（尚无业务页面）。

**候选方案**（待裁决）：

```text
方案 A：实现 Careerly 自有 Input 组件后，把该 Theme 降级为纯兜底并注明
方案 B：按 Figma 的真实输入框样式重写该 Theme
```

> ⚠️ **输入框是 `CLAUDE.md` §8.4 未列入、Baseline §7.5 也未规划的一项。**
> 实现前需先确认命名（按 D18 规则，大概率应加 `Careerly` 前缀）。见 §3.1 的 Input 条目。

---

#### D45 — `CareerlyInput` 的 4 个变体是否应收敛（含命名待确认）

**分类：【产品冲突】/【技术实现差异】**

产品侧明确要求 **Button / Card / Input / Chip / Navigation 五者先完成可运行实现**，
其中 **Input 是唯一尚不存在的**，本轮已实现为 `CareerlyInput`。

**命名（待确认）**：

```text
按 D18 的判定标准 —— 「有没有 Careerly 业务语义」——
输入框承载的是 Careerly 的表单交互语义，因此应加 Careerly 前缀。
拟定 `CareerlyInput`，**未经产品侧确认**。
⚠️ 它**不在 Baseline §7.5 的 8 项规划内**，属项目自有规划，故命名未预先复核。
```

**范围（待裁决 —— 这是本项的核心）**：

Figma **不存在统一的 Input 组件**，实际有 **4 套互不相同的写法**：

| 变体 | Figma 位置 | 形态 | 圆角 | 字号 |
|---|---|---|---|---|
| `underline` | L510-541（Onboarding 表单） | 透明底 + **仅下边框** `1.217px` | 无 | 16px |
| `boxed` | L1344-1390（工作台内联表单） | 半透明底 + 细边框 `1.5px` | `rounded-2xl`(16) | 13px |
| `filled` | L1673-1722（a-jd-step 展开区） | 灰底 + **无边框** | `rounded-xl`(12) | 13px |
| `plain` | L2631-2644（AI 对话输入） | 完全无底色无边框 | 无 | — |

**本轮的处置：原样保留 4 档，透过 variant 参数暴露。**

理由：**「4 套输入样式是否应该统一成 1 套」是视觉方向的重大决策**，
按 `CLAUDE.md` §0 第一禁令**不得由 Flutter 侧自行拍板**。
保留 4 档 = **不代替设计侧做这个决定**，
同时让页面能先跑起来 → 在真实页面上看到实际效果 → 再裁决是否收敛。
这正是 Phase 2 新的执行方式（`CURRENT_STATUS.md` §3.6）本身。

**候选方案**（待裁决）：

```text
方案 A：保留 4 档变体（现状）—— 认为 4 种场景本就该有不同形态
方案 B：收敛成 1 套 —— 由设计侧定出唯一的输入框样式，删除其余 3 档
方案 C：收敛成 2 套 —— 「表单输入」（underline）+「内容输入」（boxed/filled 合一）
```

> ⚠️ 若裁决为 B 或 C，**只改 `careerly_input.dart` 一个文件**，
> 不影响任何页面 —— 因为没有页面直接依赖变体枚举以外的细节。

**同日登记的相关项**：D46（未定义状态的补齐）/ D47（uppercase 取舍）/ D48（补齐的几何值）。

---

#### D46 — `CareerlyInput` 的聚焦 / 占位 / 错误态取值均为 Flutter 侧补齐

**分类：【视觉/交互差异】**

`App.tsx` 中**完全不存在**以下规则（已逐项 grep 确认）：

```text
❌ :focus / focus: / focus-visible   —— Figma 未定义任何聚焦样式
❌ ::placeholder                     —— 占位符用的是浏览器默认色
❌ disabled:                         —— 未定义禁用态（输入框层面）
❌ ::selection                       —— 未定义选中态
✅ caretColor                        —— 唯一有定义的一项（品牌色）
```

因此 `CareerlyInput` 的以下取值**全部是补齐，不是设计值**：

| 项 | 取值 | 依据 |
|---|---|---|
| 占位符色 | `AppColors.textTertiary` | 沿用 Type Token 的辅助文字色 |
| 错误色 | `AppColors.danger` | Figma 无语义色以外的输入错误定义 |
| 错误态边框 | 与常态同色（**不改成红色**） | Figma 无依据，**有意不发明** |
| 禁用填充（`boxed`） | `AppColors.inputSurfaceDisabled` | 取自 L1682 一颗不可用按钮的灰底 —— **有 Figma 出处** |
| 禁用文字 | `AppColors.textDisabled` | Figma 的空输入按钮文字色，逐位一致 |
| 光标宽度 | `1.5` | Figma 未定义 |

**明确未做**：把错误态边框改成红色。
Figma 没有任何输入框错误态，改成红色会让「错误态」看起来像设计定稿，
而它其实是 Flutter 推导的。**未知的两项保持中性**，
只有**有出处**的禁用态才真的换色。

依据 D26 的先例：**补齐结果不得盖章为「视觉已定稿」**。

**候选方案**（待裁决）：

```text
方案 A：接受补齐（现状），设计侧补视觉后回改
方案 B：设计侧补全 :focus / ::placeholder / 错误态 / 禁用态的正式定义
```

---

#### D47 — `inputLabel` 未施加 Figma 声明的 `text-transform: uppercase`

**分类：【视觉/交互差异】**

Figma 的 `LABEL`（`App.tsx` L466-469）声明了：

```text
fontSize 14 / w700 / #727272 / letterSpacing 0.3px / uppercase / lineHeight 16.5px
```

`AppTypography.inputLabel` 固化了**除 uppercase 之外**的全部取值。

**为什么未施加**：

```text
Figma 自己的标签文案是中文（「姓名」「手机号」「邮箱（选填）」），
uppercase 对中文无任何视觉效果。
若强行 toUpperCase()，中文结果不变，但拉丁字母场景会变成
与设计稿字面不符的全大写。
```

**候选方案**（待裁决）：

```text
方案 A：不施加（现状）—— 保留原始文案
方案 B：施加 toUpperCase()，严格照 Figma 声明
方案 C：设计侧明确「uppercase 是否只针对英文标签」
```

---

#### D48 — `CareerlyInput` 中两处无 Figma 出处的几何值

**分类：【技术实现差异】**

`_InputMetrics` 里的数值分两类。有出处的一类无需讨论：

| 值 | 出处 |
|---|---|
| `underlineWidth = 1.217` | Figma `INPUT_BASE` 的 `borderBottom` |
| `boxedBorderWidth = 1.5` | Figma 工作台内联表单容器 |
| `multilineMinHeight = 120` | Figma `minHeight: 120` |
| `underline` 上下留白 `4 / 10` | Figma `paddingTop: 4` / `paddingBottom: 10` |

**无出处的一类（待视觉验证）**：

| 值 | 现状 | 问题 |
|---|---|---|
| `underlineLabelGap = 4` | 标签与输入框之间的间距 | Figma 的 `LABEL` 与输入框之间**没有显式间距**（靠 `p` 的默认边距，而 Tailwind preflight 会把它清零），**无设计原值可取** |
| `cursorWidth = 1.5` | 光标宽度 | Figma 未定义光标宽度 |

**候选方案**（待裁决）：

```text
方案 A：接受现值，在真实页面上验证
方案 B：设计侧补出标签与输入框的明确间距
```

> ⚠️ `underlineLabelGap` 是**在真实页面上最可能看出问题**的一项 ——
> 它影响所有 Onboarding 表单的纵向节奏。

---

#### D49 — `AppMotion` 的四条曲线是归纳值，spec 只给了文字描述

**分类：【视觉/交互差异】**

`AppMotion` 里有**六条**曲线，但只有**两条**有 Figma 原值：

| 曲线 | 状态 |
|---|---|
| `standard` | ✅ Figma 原值 `cubic-bezier(0.25, 0.46, 0.45, 0.94)` |
| `emphasized` | ✅ Figma 原值 `cubic-bezier(0.34, 1.2, 0.64, 1)` |
| `enter` | ⚠️ **归纳值** —— 取 `Curves.easeOutCubic` |
| `exit` | ⚠️ **归纳值** —— 取 `Curves.easeInCubic` |
| `pageCurve` | ⚠️ **归纳值** —— spec 只说「ease-out」，未给数值 |
| `cardCurve` | ⚠️ **归纳值** —— 当前 **0 处引用** |

motion-spec §27 对其余场景**只写文字描述**（「ease-out / smooth easing」），
**没有给 `cubic-bezier`**。上表四条是 Flutter 侧按文字描述挑的
**Material 内建曲线**，不是 Figma 原值。

**影响面**：`pageCurve` **6 处** · `enter` / `exit` 各 **2 处**。

**候选方案**（待裁决）：

```text
方案 A：接受归纳值（现状）
方案 B：设计侧补出这四条的 cubic-bezier
```

> ⚠️ 若实际页面上转场 / 显隐的手感需要调整，**改这一节即可**，
> 不需要改任何页面代码 —— 这正是「暂定值集中在 Token 层」的目的。

---

#### D16 — Disabled 态的具体取值

**分类：【视觉/交互差异】**

Figma 的 `PrimaryBtn` 在不可用时**只是把文字调灰**，没有定义背景 / 边框。

**Flutter 的处理**：用**已有 Token**（`disabledSurface` / `textDisabled`）补齐，
保证四态齐备（`CLAUDE.md` §5.5 的硬要求）。

这是**补齐**而不是**发明**，但**具体取值未经产品侧裁决**。

---

#### `docs/06_` §13 的组件清单与命名规范不一致

**分类：【技术实现差异】**

2026-09-18 的组件命名规范（D18）已落地到 `CLAUDE.md` §8.4。
但 **`docs/06_Careerly_Flutter_Development_Specification_V2.1.md` §13
「Shared Components」的清单未同步**：

```text
第 470 行  GlassCard          ← 实际是 CareerlyCard
第 472 行  PrimaryButton      ← 实际是 CareerlyButton（variant）
第 473 行  SecondaryButton    ← 同上
第 474 行  IconButton         ← 未实现，命名未复核
第 476 行  SectionHeader      ← 未实现，命名未复核
第 477 行  Tag                ← 未实现，命名未复核
第 480 行  ScoreIndicator     ← 未实现，命名未复核
第 481 行  ProgressIndicator  ← 未实现，命名未复核
```

**为什么没有自行修改**：`docs/06_` 是**来源优先级 4 的源文档**
（`CLAUDE.md` §3），修改源文档不属于「同步 CLAUDE.md §8.4」的范围。
且清单里多数组件**尚未实现**，D18 只裁决了**已实现组件**。

**建议**（待裁决）：

```text
方案 A：在 docs/06_ §13 顶部加一行注记
        「命名以 CLAUDE.md §8.4 为准」，不改动清单本体

方案 B：待批 2 / 批 3 组件实现后，一次性回填实际名称
```

**倾向 A** —— 源文档保留原始规划意图，命名规则由 `CLAUDE.md` 统一收口。

> 📌 `docs/07_...Baseline`（优先级 3，歧义仲裁第一入口）**已核查，无此问题**。
> `docs/phase_1_report.md` 与 `Careerly_Vibe_Coding_开发启动_Prompt_V1.0.md`
> 是**历史产物**，按只追加原则**不回改**。

---

#### O4–O7 —— Phase 0 遗留开放项

来自 `docs/07_...Baseline` §9，**均不阻塞当前阶段**：

| # | 开放项 | 阻塞 |
|---|---|---|
| O4 | Careerly Pro 入口是否保留在「我的」首页 | Phase 8 |
| O5 | Pro 的额度语义（无限 / 每月 N 次）—— 影响 `QuotaState` 模型 | Phase 9 |
| O6 | Settings 是否含「关联职业上下文」开关 | Phase 8（低风险） |
| O7 | IA Level 3 缺口（Membership 未登记 / 历史岗位详情无对应页） | Phase 8 |

> O1（字体）、O2（成长日历归属）、O3（历史版本形态）**已在 Phase 1 裁决并落实**。

---

#### D68 — Onboarding 的「页面主标题」在 Figma 里有**两个不同取值**

**分类：【视觉/交互差异】**（Phase 4 批 2 落地时发现）

```text
`OnRegister`   标题：26px / w900 / line-height 32px
`OnResume`     标题：24px / w900 / line-height 36px   ← 字号与行高都不同
```

两者都是**页面主标题**（同一层级、同一位置），但设计稿给的字号与行高都不同。
本轮**不合并**（依 §3.1「Figma 已明确设计细节 → 采纳 Figma」），
在 Typography 里固化成两个角色：

```text
AppTypography.onboardingTitle        26 / w900 / lh32   → 注册页
AppTypography.onboardingPageHeading  24 / w900 / lh36   → 提交简历页
```

**引用**：`lib/design_system/tokens/app_typography.dart`

**候选方案**：

```text
方案 A：确认两个取值并存（即现状 —— 两屏标题本就该不同大小）
方案 B：统一为一个值（等于认定其中一个写错了），产品侧指定取哪个
```

> ⚠️ 影响面很小（2 处），但**若统一不了，后续每一屏都要单独查一遍标题值**。

---

#### D69 — `OnParsing` 顶栏与 `OnboardingProgressHeader` 两处不一致

**分类：【视觉/交互差异】**（Phase 4 批 2 落地时发现）

`OnParsing` 的顶栏是 Figma 的**内联写法**，不是 `OnboardingProgress` 组件
（该屏没有进度条），两处取值与组件不同：

| 项 | `OnboardingProgressHeader`（注册页用） | `OnParsing` 内联顶栏 |
|---|---|---|
| 步骤阶梯 | `step: 1 / total: 4` | `step: 3 / total: 3`（**没有进度条，但写了 3/3**） |
| 返回箭头色 | `#0088FF` | `#4F7EF5`（品牌蓝） |
| 返回目标 | 上一屏 | `on-welcome`（该屏未实现，见 D61） |

**两屏的实际观感**：注册页进度条 25%，解析页**没有进度条**。
`3 / 3` 这个值在一屏没有进度条的页面上**不产生任何视觉输出**，
但它说明 Figma 的 Onboarding 步骤阶梯与注册页的 `1 / 4` 对不上。

**当前处置**：**逐位照抄 Figma**（本页渲染 `3 / 3`，但无进度条故无观感差异；
箭头用 `#4F7EF5`）。**未自行统一**。

**引用**：`lib/features/onboarding/presentation/onboarding_parsing_page.dart`

**另一项（实现说明，不另行编号）**：Figma 的 Glass 圆钮含
`0 0 0 0.5px #e8e8e8` 描边环，本轮**未复刻**（沿用
`OnboardingProgressHeader` 的既有处理，只落外阴影 + 半透明白底）。

**候选方案**：

```text
方案 A：确认各屏独立取值（现状）
方案 B：把 OnParsing 顶栏也换成 `OnboardingProgressHeader`（需要产品侧定 step/total）
方案 C：统一返回箭头色为一个值
```

---

#### D70 — `on-resume` 上 Flutter 侧补齐的三项（Figma 未定义 / 未接线）

**分类：【技术实现差异】**（Phase 4 批 2 落地时发现）

| # | 项 | Figma 的情况 | 本轮处理 |
|---|---|---|---|
| 1 | 「粘贴简历文本」的 **Bottom Sheet** | 与「选择文件」**一样直接跳 `on-parsing`**，没有取文本的界面 | 补一个弹层收文本（`CareerlyBottomSheet` + `CareerlyInput`），文本经 `ResumeProvider.submitText` 落到 Repository |
| 2 | 提交中的 **Loading** | 未定义 | 沿用**注册页既有处理**：提交期间按钮置灰，防重复提交。**未发明新视觉** |
| 3 | 上传卡**整卡可点** | 文案是「点击或拖拽上传简历」，但原型没接线 | 整卡可点，点击行为同「选择文件」（见 D67） |

**为什么要补 ①**：本页的职责就是「提交一份简历」。
不给输入界面 → 点「粘贴简历文本」等于**什么都没提交**，
而 Figma 的这条路径**只画了按钮、没画取文本的地方**。

**引用**：`lib/features/onboarding/presentation/onboarding_resume_page.dart`

**候选方案**：

```text
方案 A：确认现状（弹层收文本，视觉用既有组件，不新增设计）
方案 B：产品侧给出「粘贴简历」这一步的设计稿，AI 侧按稿重做
    —— ⚠️ 需要新设计稿，不是实现调整
```

---

#### D71 — 同一 Onboarding 流程内**并存两种按钮实现**（渐变与投影都不同）

**分类：【视觉/交互差异】**（Phase 4 批 2 落地时发现）

Figma 的按钮有**两套写法**：

| 来源 | 渐变 | 投影 | 本轮实现 |
|---|---|---|---|
| `PrimaryBtn`（可复用组件） | `135deg`（[`brandGradient`]） | `0 8px 24px`（[`primaryButton`]） | `CareerlyButton` primary |
| `OnRegister` 内联 | `172deg` | `0 8px 12px`（[`button`]） | 注册页**仍用** `CareerlyButton`（Phase 4 批 1 已交付） |
| `OnResume` 内联 | `172deg` | `0 8px 12px` | `OnboardingPrimaryButton` |
| `OnConfirm` 内联 | `135deg` **且首色 `#5B7CF6`** | `0 8px 12px` | `OnboardingPrimaryButton(gradient: confirmGradient)` |

即：**注册页（135deg / 0 8px 24px）与后续两屏（172deg 或 confirmGradient / 0 8px 12px）
在同一流程里视觉不一致**。

**当前处置**：各屏**逐位照抄各自 Figma 的写法**，不自行统一；
新增 `OnboardingPrimaryButton` / `OnboardingOutlineButton`（feature-local，
不进 design-system），并给它开了 `gradient` 参数以承载 `OnConfirm` 的第三种渐变。

**引用**：
- `lib/features/onboarding/presentation/widgets/onboarding_action_buttons.dart`
- `lib/features/onboarding/presentation/onboarding_register_page.dart`

**候选方案**：

```text
方案 A：确认不一刀切 —— Figma 就是两套按钮，各自照抄
方案 B：统一为一套（产品侧指定取哪一套），注册页按钮随之改写
        —— 影响面：注册页视觉会变（Phase 4 批 1 已交付内容）
```

---

#### D72 — Flutter **无法逐位表达**的视觉细节（4 项，均为近似或省略）

**分类：【技术实现差异】**（Phase 4 批 2 落地时发现）

| # | 项 | Figma | 本轮处理 | 影响面 |
|---|---|---|---|---|
| 1 | 上传图标 / 勾选图形 | 自绘 SVG 路径 | Material 字形近似（同 **D58** 的先例，**不新建图标资源**） | `on-resume`、`on-parsing`、`on-confirm` |
| 2 | 虚线边框 | CSS `1.5px dashed` | 自绘 `_DashedRoundedBorderPainter`，节奏 `6 / 4` 为**近似值** | `on-resume` |
| 3 | 磨砂层的 `backdrop-filter: blur(16px)` | 有 | **未加** —— 背景是静态渐变，模糊无可模糊之物；加 `BackdropFilter` 只有开销 | `on-parsing` 步骤卡、`on-confirm` 汇总卡 |
| 4 | 光晕球的 `filter: blur(0.5px)` | 有 | **未复刻**（0.5px 亚像素，肉眼不可辨）；同一条 filter 里的 `brightness()` **已复刻**（颜色矩阵） | `on-parsing` |

**引用**：
- `lib/features/onboarding/presentation/onboarding_resume_page.dart`
- `lib/features/onboarding/presentation/onboarding_parsing_page.dart`
- `lib/features/onboarding/presentation/onboarding_confirm_page.dart`

**候选方案**：

```text
方案 A：确认现状（全部为「近似或省略」，且已逐条说明）
方案 B：产品侧出具 SVG 资产（图标与虚线节奏），AI 侧按资产替换
    —— ⚠️ 需要设计资源，不是实现调整
```

---

#### D73 — `on-parsing` 的**两条时钟**：Figma 的动画 vs 真实的数据调用

**分类：【技术实现差异】**（Phase 4 批 2 落地时发现）

Figma `OnParsing` **只有动画**：一条约 8.9s 的时间线，到点即 `go('on-confirm')`，
全程没有任何数据调用。而真实流程里这一屏要做的事是
**建立职业基线**（`ResumeProvider.buildBaseline()` → Repository）。

**本轮处理**：

```text
① 保留 Figma 的完整时间线（视觉逐位一致）
② 同时真实调用 buildBaseline()（⚠️ 不扣分析额度 —— CLAUDE.md §5.2）
③ 两条时钟**都完成**才跳下一页
④ 数据侧失败 → 停下时间线，展示 Error + Retry（Figma 未定义该态，
   复用既有 CareerlyAsyncStateView）
```

**为什么不能只留一条**：

```text
只留动画   → 数据好坏无人过问，「建立基线」变成纯动画
只留数据   → 丢掉 Figma 的整套进度视觉（Mock 下几乎是瞬间完成，什么都看不到）
```

**引用**：`lib/features/onboarding/presentation/onboarding_parsing_page.dart`

**候选方案**：

```text
方案 A：确认现状（两条时钟 + 都完成才推进）
方案 B：只保留动画，数据调用挪到未知的其它时机
        —— 需产品侧说明「基线到底什么时候建立」
方案 C：只留数据、去掉时间线 —— 等于放弃整屏视觉（D63 已裁决要保留）
```

---

#### D74 — `CareerlyBottomSheet` 内**无法直接使用** `CareerlyInput`（缺 `Material` 祖先）

**分类：【技术实现差异】**（Phase 4 批 2 落地时发现，**属 Phase 2 批 2 组件缺陷**）

`CareerlyBottomSheet` 走 `showGeneralDialog`，面板本身**不提供** `Material` 祖先；
而 `CareerlyInput` 内部是原生 `TextField` —— 后者**硬性要求** `Material` 祖先。

**后果**：把 `CareerlyInput` 放进 `CareerlyBottomSheet` 会**直接抛异常**
（构建期 `No Material widget found … TextField widgets require a Material
widget ancestor`），**不是**渲染异常，而是**崩溃**。

两个 Phase 2 批 2 组件**单独都能用，组合起来不能用** ——
当时两批都未验收，这个交叉组合也没被任何测试覆盖过。

**本轮处理（最小改动）**：

```text
在「粘贴简历文本」弹层的内容外**局部**包一层
`Material(type: MaterialType.transparency)`
```

- ✅ 透明 Material，**零视觉影响**（不加颜色、不加 elevation）
- ✅ **未改动** `CareerlyBottomSheet` / `CareerlyInput` 任何一个组件
  —— 两者均已交付、正在等待 Phase 2 批 1 + 批 2 合并验收，
  此时改它们会让「验收的对象」与「已交付的东西」不一致
- ⚠️ **代价**：缺陷仍在组件里。**下一个**在弹层里放输入框的人会再次踩到。

**引用**：`lib/features/onboarding/presentation/onboarding_resume_page.dart`
（`_PasteResumeSheetState.build`）

**候选方案**：

```text
方案 A（推荐）：在 `CareerlyBottomSheet` 的面板里常驻一层透明 Material
        —— 一处修好，全组件生效；验收时需**重新过一遍**批 2 已有视觉
方案 B：维持现状（调用方各自包 Material）
        —— 需在 `CareerlyBottomSheet` 的文档里写明这条**使用约束**
方案 C：让 `CareerlyInput` 自带 Material 祖先
        —— 但「文本框需要 Material」是 Flutter 的平台约束，
           不该由每个业务组件各自兜底
```

> ⚠️ 这**不是**产品规则问题，是组件组合缺陷；但按 `CLAUDE.md` §5.4，
> 代码里对它的引用必须有编号条目，故登记在此。

---

#### D75 — 首页 State 02 / 03 在**当前 Mock 下不可达**（只能靠注入测试覆盖）

**分类：【技术实现差异】**（Phase 5 首页落地时发现）

D64 的三态由**数据是否存在**判定：

```text
State 01  hasBaseline == false
State 02  hasBaseline == true 且 matchChanges 为空
State 03  hasBaseline == true 且 matchChanges 非空
```

但当前 `MockHomeRepository` 是**无状态**的，只返回 `HomeSummary.empty`
（`hasBaseline == false`）—— 因此**点击走查只能走到 State 01**。
State 02 / 03 目前靠 `test/phase5_home_test.dart` 注入桩实现来验证。

**候选方案**：

```text
方案 A：给 Mock 加一层可控的会话状态（如「已建立基线」开关），
        让三态都能通过界面走查
方案 B：维持现状 —— 三态由测试覆盖，界面走查只验 State 01
方案 C：等 Onboarding 真实落库（会话持久化，**D54**）后自然可达
```

> ⚠️ 本条**不影响**三态实现本身的正确性，只影响**人工走查的可达性**。
> 与 **D54**（登录态持久化）有依赖关系。

---

#### D76 — 首页 State 02 的**文案**为 AI 起草 / Header 区块 D64 未给 / 无用户姓名字段

**分类：【产品冲突】**（需产品侧增删）

三处缺口，**均已在代码里标注**：

```text
1. State 02 文案   D64 ② 只给了 State 01 与 State 03 的文案，
                   **State 02 从未给出**。现值为 AI 起草，原则是
                   「最小改写 + 只用 D64 已出现过的词」：

   Hero 小标签      你的职业主页
   Hero 主标题      还没有岗位分析
   Hero 说明行      用一份目标岗位 JD，看见你与它的距离
   Hero 按钮        添加目标岗位
   卡片 2 标题      职业基线已建立（D63 已裁决的措辞）
   卡片 2 描述      添加一个目标岗位并开始分析 / 看见你的能力匹配度
   其余三张卡与区块 与 State 01 完全相同

2. Header 区块     D64 ② 只列了 Hero / 四卡 / 岗位匹配变化三项，
                   **没有**给顶部身份区（「主页」+「<名字> 的职业主页」）
                   的文案。现取 D64 自己写过的「你的职业主页」填槽，
                   **不另造新词**。

3. 用户姓名        Figma 首页写的是 `Alex 的职业主页`，头像里是字母 `A`。
                   `HomeSummary` **没有**用户姓名字段，取不到真名 ——
                   现用「你的职业主页」+ 人像字形（**D58** 的既有处置），
                   **不回落**到假名。
                   → 若要真的显示名字，需要先有「用户档案」数据
                     （属 Phase 6「我的」）。
```

**引用**：`lib/features/home/presentation/home_content.dart`
（`_baselineOnly` / `_firstUse` / `_analyzed`）、
`lib/features/home/presentation/widgets/home_header.dart`

---

#### D77 — 首页 Hero 卡的**五处** Flutter 侧取值（Figma 未定义 / 无数据）

**分类：【视觉/交互差异】**（需产品侧确认）

```text
1. 读数区在 State 01 / 02 **整体不渲染**
   State 01 / 02 没有匹配度可言。依 CLAUDE.md §7「不编造产品数据」，
   现处理为**整块不画**，而不是用 `0` / `--` / `暂无` 占位。
   ⚠️ 装饰弧线**照常保留** —— 它与读数本就不成比例（252° vs 86），
      是纯装饰（见下条）。

2. 弧线角度与读数**不成比例**
   Figma 的弧是固定的 252°（`arcFill` 路径），与 `86%` 无换算关系。
   现值：**照抄 252°**，不按分数反推 —— 若产品侧本意是「弧长=匹配度」，
   这是一处必须改的实现。

3. 说明行的**语义**随状态漂移，且字段缺失
   Figma 该槽位是「🕐 2026/9/12」（更新时间），而 State 01 / 02 的
   同一槽位放的是说明句（无时钟图标、无日期）。
   且 `HomeSummary` **没有**更新时间字段 → State 03 该行现为**空**，
   不搬 Figma 的假日期。
   → 若要恢复「更新时间」，需要先有该字段。

4. 读数区由 `left: 238` 改锚 `right: 15`（**有意偏差**）
   设计稿 390 宽下两者**逐位相同**（350 − 15 − 97 = 238）；
   但窄机型（360dp → 卡片 320）按 `left` 定位会溢出 15px 被
   `overflow: hidden` 裁掉读数。改为锚右边界后窄屏自动内收。

5. 小标签的 `text-transform: uppercase` **未实现**
   Figma 该行写了 `uppercase` + `letter-spacing: 1.1`，
   现值只取字距、不取大写转换。
   ⚠️ 对**当前两处文案**（「你的职业主页」/「最匹配岗位」）**零影响**
   —— 中文没有大小写。若将来该槽位出现英文，需补 `toUpperCase()`。
```

**引用**：`lib/features/home/presentation/widgets/home_hero_card.dart`

---

#### D78 — 「今日一句」卡：**三态通用** vs 「State 03 = Figma 现有 Dashboard」

**分类：【产品冲突】**（一句话的归属有歧义）

D64 ② 的原话把该卡标为「**三态通用**」（它不看岗位数据）；
但同一份裁决又说 **State 03 = Figma 现有的那版首页** —— 而 Figma 的
该卡是「今日一句 / 每一段经历，都在悄悄改变你与目标之间的距离。」，
与 D64 给 State 01 写的「今天也可以向前一步 / 先看见自己，再决定下一步。」
**不是同一句**。

现处理：**三态都用 D64 给的那一句**（即按「三态通用」执行），
标题与描述在三态里完全相同。

**待确认**：State 03 是否应换回 Figma 的那一句？

**引用**：`lib/features/home/presentation/home_content.dart`
（`HomeStilCardData.isQuote` 与三处 `title: '今天也可以向前一步'`）

---

#### D79 — 首页空态的两个**文字角色**为暂定值（Figma 无此态）

**分类：【视觉/交互差异】**（需产品侧确认 → 同时登记在 `CURRENT_STATUS.md` §3.6）

State 01 / 02 的「岗位匹配变化」区块用的是 **Figma 没有的形态**：
Figma 那张卡里只有岗位列表，没有「还没有数据 → 去分析第一个岗位」的引导。

为填这个缺口新增了两个 Typography 角色，**两个都是暂定值**：

```text
homeEmptyBody     12 / w400 / lh1.5 / textSecondary   引导语
homeEmptyAction   14 / w700 / primaryBlue             「分析第一个岗位 →」

⚠️ 暂定值 · 待视觉验证
```

两者**只写在** `lib/design_system/tokens/app_typography.dart`，
未在组件里内联。

**待确认**：取值是否合适？行动行是否应该做成按钮/链接样式？
（Figma 里「查看变化 →」那类行动行是 12px w600 的纯文字，
故现在按「纯文字 + 主色」处理。）

**引用**：`lib/design_system/tokens/app_typography.dart`（`首页 · 空态` 小节）

---

#### D80 — State 01 的「上传简历」按钮**复用 Onboarding 的提交简历页**

**分类：【IA 冲突】**（入口归属，需产品侧裁决）

D64 规定首登路径为「上传简历 → 输入/粘贴 JD → 分析」，
State 01 的 Hero 按钮就是这条路径的第一步。

但应用内**只有一处**简历上传入口 —— Phase 4 的
`/onboarding/resume`（它是 Onboarding 流程的一环：返回键回注册页、
提交后走解析 → 确认 → 首页）。

```text
现状：点「上传简历」→ context.go('/onboarding/resume')
```

**问题**：用户从**首页**点进去，却落在一个带 Onboarding 流程上下文
（返回 → 注册）的页面里。

**候选方案**：

```text
方案 A：把「提交简历」抽成一个**流程无关**的页面，两处复用
方案 B：新建应用内的「我的简历」上传入口（属 Phase 6「我的」，须先裁决）
方案 C：维持现状（复用 Onboarding 页）
```

> ⚠️ **未新建页面、未新建一级导航** —— 依 `CLAUDE.md` §0，
> 那是必须先经裁决的事。

**引用**：`lib/features/home/presentation/home_page.dart`（`_onHeroAction`）

---

#### D81 — 「最近成长」卡的目标：Figma 是 `cap-change`，而它属于「我的 → 成长足迹」

**分类：【IA 冲突】**（入口归属，需产品侧裁决）

Figma 首页四张卡的 `onClick` 逐张为：

```text
问问AI    → setTabNav('ai')        → AI Tab          ✅ 已照做
当前状态  → go('analysis')         → 分析 Tab        ✅ 已照做
最近成长  → go('cap-change')       → **能力变化页**  ⚠️ 见下
今日一句  → undefined              → 不可点          ✅ 已照做
```

`cap-change`（`CapabilityChangePage`）按 **IA §2.2** 属于
「**我的 → 成长足迹 → Detail**」内部 —— 那一层尚未实现（Phase 6）。

**现处理**：落到「我的」**Tab**，不新建页面、也不改判到「分析」
（成长不属于分析）。Phase 6 建成后应改为直达成长足迹。

**引用**：`lib/features/home/presentation/home_content.dart`
（`HomeCardTarget.growth`）、
`lib/features/home/presentation/home_page.dart`（`onOpenGrowth`）

---

> ## ⚠️ 2026-09-22 集中补登 —— Phase 8 批 1 / 批 2 的 **D86–D95**
>
> 下面 **10 条**在写入源码时被引作「已登记 §3.1」，**而 §3.1 一条都没有**。
> 与 D19、D54–D58 同一类违规，是**第三次**出现：
>
> ```text
> Phase 8 批 1（8 张二级页）      2026-09-22 01:00–01:30 交付，无 Session、无 D 编号记录
> Phase 8 批 2（技能 / 奖项 / 能力）本会话交付，同时补齐上述欠账
> ```
>
> ⚠️ 另发现一处**编号撞号**：`D86` 被**两个不同的缺口**同时引用
> （「我的」页三处 IA 偏离 / 注册页登录形态）。两者由同一天的不同写入者各自分配 ——
> 与 `CHANGELOG.md` Session 012 §4 记录的并发写入同源。
> 处置：保留 **D86 = 注册页登录形态**，三处 IA 偏离改记 **D95**，
> 源码引用（`profile_page.dart`）已同步改正。

---

#### D86 — 注册页的**登录形态**整列由 Flutter 侧补齐（Figma 无登录屏）

**分类：【产品冲突】/【视觉/交互差异】**（D85 裁决「登录 = 注册页的模式切换」后浮现）

Figma 里没有登录屏，因此[登录形态]的**每一格都没有出处**：

```text
标题          「登录你的账号」        —— 按注册标题的句式改写
说明句        原样复用注册形态的隐私说明（复用既有文案优于新造一句）
头像占位      登录形态**不渲染** —— 它是「换头像」的暗示，登录场景无意义
次按钮        「跳过，稍后完善」**不渲染** —— 登录没有可跳过的下一步
切换控件      复用 CareerlyChip（dark = 选中 / neutral = 未选中），**未新造分段控件**
切换控件间距  16（AppSpacing.md），为补齐值
```

**现处理**：全部按上表实现。**验收时不得盖章为「视觉已定稿」** ——
文案、头像去留、次按钮去留、切换控件形态与间距，四类都待产品侧确认。

**引用**：`lib/features/onboarding/presentation/onboarding_register_page.dart`

---

#### D87 — 会员页 / 「我的」页三处**口径未定义**，本轮不猜

**分类：【产品冲突】**

| # | 位置 | 事实 | 本轮处置 |
|---|---|---|---|
| 1 | 「我的」头部 `V1会员` 徽章（Figma L3173-3178） | **等级语义未定义**（V1 之后是什么？按期？按功能？） | 只渲染 Mock 给的字符串，**不解析、不推导等级** |
| 2 | 会员页额度用尽后的「能力变化 `+12`」（L4874-4878） | **口径未定义**：Σ增量？最高项？快照差？`+12` 与任何算法都对不上 | **不渲染该行**（另两行可派生，已还原） |
| 3 | 会员页「开通 Careerly Pro」的点击反馈文案 | 原型无此文案；MVP 无支付（§4 决策 6） | Flutter 侧自拟一句（`purchaseHint`），**不是设计值** |

> 第 2 条**不是遗漏**：口径没定义时，写死或猜一个都是
> 「用代码解决产品问题」（`CLAUDE.md` §0）。

**引用**：`lib/features/profile/presentation/membership_page.dart`、`profile_page.dart`

---

#### D88 — `CareerAssets` 与 `ResumeProfile` 并存（同一条数据的两层建模）

**分类：【技术实现差异】/【产品冲突】**（数据模型归属）

```text
ResumeProfile.workExperiences : List<String>          ← Phase 4 / Onboarding 时期的基线摘要
CareerAssets.workExperiences  : List<WorkExperience>  ← Phase 8 / 长期资产层的富结构
```

两者**并存**，不是替代关系。本轮**未**改 `ResumeProfile` 的字段类型 ——
它被 `OnboardingConfirmPage` 依赖，改类型会波及已交付的 Onboarding。

**待裁决**：长期是否收敛为一层、由谁承担迁移。

**引用**：`lib/data/models/career_assets.dart`、`lib/data/models/work_experience.dart`

---

#### D89 — Figma 多处**硬编码派生值**与它自己的数据对不上，本轮一律「派生」

**分类：【产品冲突】**（原型**自身的**矛盾，非 Flutter 侧偏差）

| # | Figma | 同一份原型的数据 | 本轮 |
|---|---|---|---|
| 1 | 技能页顶栏 `12 项`（L3820）· 资产卡 `12项目技能`（L3436） | `SKILL_CATS` 展平 = **13** | 派生 → 演示态显示 `13 项` |
| 2 | 能力画像条宽 `91% / 76% / 78%`（L3618-3620） | `score` = `85 / 76 / 78` | 派生自 `score` |
| 3 | 能力总览条 `62%`（L3606） | 5 项均值 = **74.6** | 派生 = 均值 |

写死会让显示值与数据脱钩（空数据时仍画出一条 `62%` 的条）。
⚠️ 第 1 条附带**文案微调**（`12项目技能` → `N 项技能`，原句不通），
需产品侧在验收时一并确认。

**引用**：`skills_page.dart`、`career_assets_page.dart`

---

#### D90 — 五处 Empty 态**文案由 Flutter 侧起草**（原型没有空态）

**分类：【视觉/交互差异】**（文案）

原型**永远有数据**，不存在空态；而 `CLAUDE.md` §7 要求 Mock 默认返回空、
让 Empty 态真实可见 —— 于是必须有话可说。已起草：

```text
职业资产页     「还没有职业资产」+「完成职业简历后，这里会显示你的经历、项目、技能与荣誉」
「我的」页      资产卡摘要空态 + 各分组卡的空态说明
技能页         「还没有技能」+「提交简历并完成职业基线后，这里会显示你掌握的技能」
奖项页         「还没有荣誉成果」+「提交简历并完成职业基线后，这里会显示你获得的奖项与荣誉」
能力页         「还没有能力数据」+ 同句式
```

**现处理**：按四态契约渲染，**文案为暂定**；产品侧给出正式文案后逐条替换。

**引用**：`career_assets_page.dart`、`profile_page.dart`、`skills_page.dart`、
`awards_page.dart`、`capability_page.dart`

---

#### D91 — 成长事件的**类型映射**：两套枚举对不上（属产品定义）

**✅ 已裁决（2026-09-23 产品侧）→ 留档见 §3.2 · D91。**

结论：4 套 Figma 配色按映射沿用，**排名变化新增第 5 套配色**
（暂定值见 §3.1 · **D96**，待产品侧确认）。

---

#### D92 — 能力页的「查看变化 →」**不渲染**（`cap-change` 无路由）

**分类：【IA 冲突】**（与 D81 同源）

Figma `CapabilityPage` 的能力详情卡右上角有「查看变化 →」，跳 `cap-change`
（`CapabilityChangePage`）。该页**无路由** —— 依 **D81** 它属于
「我的 → 成长足迹 → Detail」内部，且其口径仍**待裁决**（本文件 · D81）。

**现处理**：与职业资产页两张分组卡同一处置 ——
**落点不存在的入口不渲染**，不留死链、也**不新建页面**
（`CLAUDE.md` §0 第二条禁令）。

**引用**：`lib/features/profile/presentation/capability_page.dart`

---

#### D93 — 能力页条目**未做错峰展开**（Figma 的 `animationDelay`）

**分类：【视觉/交互差异】**（动画）

Figma 的能力条目按 `100 + i×80ms` / `200 + i×80ms` **错峰**展开；本页**同时**展开。

**理由**：错峰依赖 `AppMotion.stagger`，而它是**待裁决值**
（**D36**：40ms 落在 motion-spec 的 50–80ms 之外）且**全库 0 处引用**。
本轮不把它引入新页面 —— 已交付的项目 / 工作经历列表同样未做错峰进入。

> 若产品侧要求错峰：**先裁决 D36**，再决定是否**统一引入**（会波及全部列表）。

**引用**：`capability_page.dart`

---

#### D94 — 能力条生长动画取 `AppMotion.reveal`（550ms），Figma 为 600ms

**分类：【视觉/交互差异】**（动画时长，**归纳**而非偏离）

Figma 的 `bar-grow` 是 **600ms**（`src/index.css` L193）；本页用
`AppMotion.reveal`（**550ms**，其声明区间 400–700ms）——
与 `AppRadius` / `AppMotion` 的既定做法一致：
**原型数值重新归纳进阶梯，不 1:1 抄**。差值 50ms。

> 若要逐位一致 → **只改 Token 一处**。

**引用**：`capability_page.dart`

---

#### D95 — 「我的」页相对 Figma 的**三处 IA 偏离**（已按锁定规则处置，仅备案）

**分类：【IA 冲突】**（**已处置**，非阻塞项）

| # | Figma | 本页 | 依据 |
|---|---|---|---|
| 1 | Tab 有 **5 个**（多「历史分析」「设置」） | **只 3 个** | `CLAUDE.md` §5.4 / §2.2 / IA §16 |
| 2 | 底部另有**历史分析卡**与**设置卡** | **不渲染** | §2.2（历史分析只属「分析」）；IA §16（设置唯一入口 = 右上齿轮） |
| 3 | 「我的职业成长」内嵌**成长日历本体** | 只留标题 + 入口卡，日历移入详情 | §2.2 / Baseline O2 |

**处置**：三条**都不是待裁决项** —— 依据是已锁定的最高优先级规则
（`Figma ≠ IA → IA 胜`）。登记在此只为满足 §5.4 的标记登记要求，
**验收时按「已处置」核对，无需重新裁决**。

> ⚠️ **编号说明**：这三处在源码里曾被引作 `D86`，与注册页登录形态缺口**撞号**。
> 本文件按「先到先得」保留 **D86 = 注册页登录形态**，
> 本条改记 **D95**，源码引用已同步改正（见本节顶部的补登说明）。

**引用**：`lib/features/profile/presentation/profile_page.dart`

---

#### D96 — 成长时间线「排名变化」第 5 套配色的**暂定值**待确认

**分类：【产品冲突】**（D91 裁决的连带项）

D91 裁决「排名变化新增第 5 套配色」，但 Figma 只有 4 套色板，
第 5 套**无设计依据**。Flutter 侧暂定一套**青色系**
（与既有 4 套蓝紫/紫/橙/绿可区分）：

| Token | 暂定值 | 用途 |
|---|---|---|
| `growthRankStart` | `#06B6D4` | 圆点 / 徽章渐变起点 |
| `growthRankEnd` | `#0891B2` | 渐变终点 |
| `growthRankBg` | `#CFFAFE` | 类型卡底色 |
| `growthRankText` | `#0E7490` | 类型卡文字 |

⚠️ **这是暂定值，不是正式产品规则** —— 产品侧确认或改定后更新 Token 即可，
页面与测试均按 Token 取值，无需改结构。

**引用**：`lib/design_system/tokens/app_colors.dart` ·
`lib/features/profile/presentation/growth_record_page.dart`

---

#### D97 — 成长日历月网格的**月份切换箭头**为 Flutter 侧补充交互

**分类：【视觉/交互差异】**（**已拍板**，备案）

Figma 的月网格（「我的职业成长」卡内）写死「2026年8月」，
**没有**月份切换；但详情页月网格承载「看任意月份事件」的职责，
静态单月在真实数据下不可用。

**拍板**：月网格标题左右补 `‹ ›` 箭头切换月份（实现层补充交互，
属 `CLAUDE.md` 允许自行合理处理的「点击区域 / 滚动」同类细节）。
周日历条按 Figma `growth-record` 页规格为**动态真实日期**，
「今天」= 蓝紫渐变圆。

**引用**：`lib/features/profile/presentation/growth_record_page.dart`

---

#### D100 — 成长足迹「非今天」日期的空态文案由 Flutter 侧起草（2026-09-28）

**分类：【视觉/交互差异】**（文案）

产品侧只给了**今天**那一句（逐字）：

```text
今天还没有足迹
完成一次职业分析，这里会留下你的成长记录。
```

但当天事件区对**任意**选中的日期都要给空态（这正是 Phase 8A 的要求），
因此非今天那句没有出处：

| 选中日 | 标题 | 说明 |
|---|---|---|
| 今天 | `今天还没有足迹` | **逐字＝产品侧原话** |
| 非今天 | `这一天还没有足迹` | **Flutter 侧按同句式起草** |

说明句两者共用（`完成一次职业分析，这里会留下你的成长记录。`）。

> 与 **D90** 同类：原型不存在空态，而 §7 要求 Mock 默认返回空，
> 于是必须有人起草文案。**现为暂定**，产品侧确认后逐条替换。

**引用**：`lib/features/profile/presentation/growth_record_page.dart`（`_DayEmptyNote`）

---

#### D101 — 成长足迹：切月时**选中日跟随** + 「今天」快捷定位（**已拍板**，备案）

**分类：【视觉/交互差异】**（**已拍板**，与 D97 同源）

Figma 是静态原型：**没有**月份导航，也**没有**「回到今天」。
但详情页的日历要承载「看任意月份 / 任意日期的事件」，静态单月不可用。

**拍板**（属 `CLAUDE.md` §3.2 允许 Flutter 自行合理处理的交互细节）：

```text
① 切月时选中日跟随 —— 切到该月同日（越界夹到月末）；切到当前月则回今天
   理由：否则切月后「当天事件区」会指向网格里看不见的日期
② 视图离开今天时，月份标题行出现「今天」胶囊（复用 CareerlyChip，不新造控件）
   理由：跨月浏览后无法一键回到今天
```

⚠️ 两条**都不是** Figma 原值，**不得**在视觉验收时当作设计值盖章。
⚠️ **未新增一级导航 / 一级页面**（仍挂在 profile 分支内）。

**引用**：`lib/features/profile/presentation/growth_record_page.dart`

---

### 3.2 ✅ 已裁决留档

<details>
<summary>展开查看已裁决项（不再讨论，仅供追溯）</summary>

#### D107 — `on-resume` 上传卡文案含图片（2026-10-02 产品侧）

**裁决内容**：选择器放行图片（走 OCR）后，两处文案必须含图片，
否则「说一套做一套」。产品侧采用 AI 侧草稿：

```text
标题（App.tsx L761）
  支持 PDF、Word 格式，AI 将自动解析你的职业经历
→ 支持 PDF、Word、图片格式，AI 将自动解析你的职业经历

卡内（App.tsx L768）
  PDF / Word · 最大 10MB
→ PDF / Word / 图片截图 · 最大 10MB

「AI 将自动提取」清单 ⛔ 不动 —— 它本就列了「技能与证书 / 获奖与荣誉」两项。
```

**背景**：Figma 只写了 PDF / Word，而 `D67` 的实现把白名单注释为
「不擅自扩展」；Session 018 产品侧裁决「扩既有上传支持图片」后，
两者冲突。**改法归属产品侧**（D66 的教训：文案不自行起稿），
故本项挂了一轮，Session 019 交付时当场拍板。

**实现落点**：`onboarding_resume_page.dart`（`_ResumeTitle` / `_UploadCard`）·
`test/phase4_batch2_test.dart`（断言跟随）· `resume_file.dart`（注释）

**引用**：`docs/05_progress/CHANGELOG.md` Session 019 §5

---

#### D99 — 成长足迹：**日历与事件解耦**，日历默认存在（2026-09-28 产品侧）

**裁决内容**（产品侧原话要点）：

```text
✅ 日历是默认存在的核心页面结构 —— 永远渲染
✅ 即使没有任何事件，也必须显示完整日历 + 对应的当天空状态
❌ 不得根据 Event 是否存在来决定是否渲染 Calendar
```

**结构**：

```text
我的 → 成长足迹
        ├── 日历（月份切换 / 今天定位 / 日期选择 / 有事件日期标记）
        ├── 当天事件区（selectedDate 查询 → 事件 / 空状态）
        └── 全部记录（时间线）
```

**为什么**：事件由**各业务操作**逐步写入
（更新简历 → ResumeUpdated / 完成岗位分析 → AnalysisCompleted /
新增项目经历 → ProjectAdded），**不由本页产生**。
本页是**容器**，因此空数据下也必须是完整、正确的页面。

**连带**（与 D98 同源、互为补充）：
D98 说「日历默认加载，事件由用户操作后记录」，本条件把它**结构化为页面不变量** ——
批 3 的实现（整页包在 `isEmpty` 门禁里）**违反了它**，本轮已改正。

**实现落点**：`growth_record_page.dart`（类文档 + 顶层门禁拆除）·
`test/phase8d_growth_record_test.dart`（「空数据：日历照常渲染」为核心不变量断言）。

**引用**：`lib/features/profile/presentation/growth_record_page.dart` ·
`docs/05_progress/CHANGELOG.md` Session 017

---

#### D98 — 成长日历**默认加载**，事件由用户操作后记录（2026-09-23 产品侧）

**裁决内容**（产品侧原话：「日历默认加载，只是事件更新需要用户操作后记录」）：

```text
① 日历本体（周日历条 + 月网格）默认加载 —— 不依赖任何数据、不设门控
② 事件不做预填 —— 默认路径事件列表为空，用户产生行为后才记录出现
```

**现状核对**（无需改代码）：

- 日历框架 = 真实日期动态计算，无数据依赖 ✅
- 默认路径 `MockGrowthRepository` 返回空列表；Figma 样例事件仅在
  `CAREERLY_DEMO_DATA` 演示开关下出现（视觉走查专用，非产品行为）✅

**连带（后续阶段）**：真实事件的**写入路径**（用户操作 → 记录成长事件）
属于数据层职责，当前 Mock 仓库只读，待对应功能阶段落地。

**引用**：`lib/data/mock/mock_growth_repository.dart` ·
`lib/features/profile/presentation/growth_record_page.dart`

---

#### D91 — 成长事件类型映射：沿用 Figma 4 色 + 排名变化新增第 5 套（2026-09-23 产品侧）

**冲突**：Figma 时间线按 4 类事件配色（analysis / resume / project / capability），
本项目模型按 PRD §11.3 为 5 类（experience / skill / capability / matchScore / rank）。

**裁决内容**：

```text
新增经历 experience   → 项目 project     蓝紫系
技能变化 skill        → 简历 resume      紫色系
能力变化 capability   → 能力 capability  橙色系
匹配度变化 matchScore  → 分析 analysis    绿色系
排名变化 rank         → 新增第 5 套配色（青色系，暂定值见 §3.1 · D96）
```

即：**不改模型枚举、不改 PRD §11.3**，4 套 Figma 配色按映射沿用，
排名变化独立成色。月网格事件圆点与图例同按 5 类渲染。

**连带裁决**：成长足迹二级页日历范围 = **周日历条 + 月网格都进详情页**
（依 Baseline O2，不回「我的」主页）。

**落地**：`growth_record_page.dart` 重建（顶栏 + 周条 + 月网格 + 时间线）；
测试 `test/phase8d_growth_record_test.dart` 8/8。

---

#### D85 — 登录补成「账号页的模式切换」，不新建登录页（2026-09-21 产品侧，**2026-09-22 补登**）

**补登说明**：本条裁决在 `lib/` 内被引用 **15 处**，
但 `TODO.md` / `CURRENT_STATUS.md` **此前均无记录**（D84 同样缺 §3.2 条目，
仅 `CHANGELOG.md` Session 014 有一行）。属 §3.1 顶部「登记规则」要防的
「只活在源码注释里」——**第四次**同类欠账。

**裁决内容**（转录自源码引用处，未改动）：

```text
① 登录**不是**独立页面 —— 它是注册页的 `?mode=login` 形态
② 两种形态共用同一个页面类（OnboardingRegisterPage）
③ 身份 = **手机号**（最小规则，不设密码 / 验证码）
```

**连带**：登录形态的整列视觉**无设计依据**（Figma 无登录屏）→ 见 §3.1 · **D86**。

**来源引用**：`lib/app/router/app_routes.dart` · `lib/data/repositories/auth_repository.dart` ·
`lib/features/onboarding/presentation/onboarding_register_page.dart`

---

#### D84 — 未接入会话持久化前，启动默认进 Onboarding 开屏（2026-09-21 产品侧）

**补登说明**：本条原只记在 `CHANGELOG.md` Session 014，§3.2 无条目。

**裁决内容**：默认入口 = `/onboarding/splash`；开发期可用环境变量
`CAREERLY_ENTRY=home` 覆盖为首页。待 Auth / 本地缓存阶段再补
「已注册用户跳过 Onboarding」的判断（与 §3.1 · **D54** 同一件事）。

**验证**：`test/app_debug_entry_test.dart` 9/9。

---

#### D82 — Phase 6 + Phase 7 开工授权追认（2026-09-21 产品侧）

**背景**：2026-09-21 工作区出现 Phase 6（分析）/ Phase 7（AI）的实现，
但 `D60` 明确写着「❌ 未授权：Phase 6+」，三份进度文档也仍停在 09-18 ——
即这批代码当时处于**「无授权记录 + 无文档记录」**状态。

**处置**：AI 侧按 `CLAUDE.md` §0 停下来报告（分类：【产品冲突】· 授权层面），
未直接改代码。产品侧裁决：**该批工作系上一轮口头授权后所写，授权成立。**

**授权内容**：

```text
✅ 授权：Phase 6 分析（新建分析 / 历史分析 / 额度门禁 / 四态）
✅ 授权：Phase 7 AI（Chat UI + Mock Response）
✅ 授权：《CLAUDE.md》§0「禁止自动进入下一个 Phase」由本授权**具名豁免**，
         仅限 Phase 6 / 7
❌ 未授权：Phase 2 批 3（ScoreIndicator / AIMessageBubble / 导航栏 Glass 统一）
❌ 未授权：修改任何产品规则 / 新增一级页面或一级导航 / 新增第 5 个 Tab
```

> ⚠️ **本次追认不清偿任何旧欠账。** 批 1 / 批 2 / Token 审计 / `CareerlyInput`
> 四笔欠账 + Phase 3 / 4 / 5 三批新交付，**仍是「未验收」**。
> **不得据本次授权反推「Phase 6 / 7 已确认无误」。**

---

#### D83 — Phase 8（我的）追认授权 + 本轮收口（2026-09-21 产品侧）

**背景**：Session 012 进行中，发现**有第二个写入者并发修改同一工作区**
（`ListAgents` 无对等会话、无 hook；详情见 `CHANGELOG.md` Session 012 第四节）。
其中 `lib/features/profile/presentation/profile_page.dart`（Phase 8「我的」）
与 `test/phase8_profile_test.dart` 于 14:59–15:00 被写入，
而 `D60` 同样写着「❌ 未授权 Phase 8」。**同时**它使
`test/widget_test.dart` 的「我的」断言（钉 Phase 1 占位文案）变红。

**产品侧裁决**：

```text
① 该写入者 = 产品侧另开的会话/后台任务
② Phase 8 **一并授权**
③ 要求本轮**收口到全绿**：修掉那条过期断言，并补记 D 编号与 Session 012
```

**据此完成的收口**：

```text
✅ test/widget_test.dart 「我的」断言改为**断言页面类型**（与首页/分析同型）
✅ flutter analyze 零 issue · flutter test 128/128
✅ CHANGELOG Session 012 / TODO D82–D83 / CURRENT_STATUS 同步
```

> ⚠️ **并发写入本身是本轮的实质风险**，虽未造成改动丢失：
> 双方恰好未触碰同一文件（本会话只动 `test/`）。**下一次不保证。**
> 已记入 Session 012 —— 同一工作区不应有两个写入者。
>
> ⚠️ **Phase 8 的实现细节本会话未审阅**，本记录的「已交付」仅指
> **文件存在 + 测试通过**，**不构成设计正确性背书**。

---

#### D60 — Phase 3 + 4 + 5 整体开发授权，验收推迟至 Phase 5 结束（2026-09-18 产品侧）

**背景**：AI 侧在 Session 010 完整报告了仓库状态 —— 包括
「Phase 4 批 2+ / Phase 5 / Phase 3 收口均未获授权」、
「四笔欠账继续挂账」、「§8.1 要求豁免时必须同时给出清偿方式」。
产品侧据此在**知情前提下**给出本轮授权（符合 `DEVELOPMENT_WORKFLOW.md` §8.1 ①）。

**授权内容**（具名）：

```text
✅ 授权：Phase 3 收口（AI 入口视觉定稿 / 页面转场 / Liquid Glass / K13 状态栏）
✅ 授权：Phase 4 全部剩余步骤
         （价值介绍 → 提交简历 → 解析 → 确认 → 职业基线）
✅ 授权：Phase 5 首页（Mock）
✅ 授权：验收时点推迟 —— Phase 3 + 4 + 5 **全部开发完成后一次性验收**
❌ 未授权：Phase 6+（分析 / AI / 我的 / Global States / Android QA）
❌ 未授权：Phase 2 批 3（`ScoreIndicator` / `AIMessageBubble` / 导航栏 Glass 统一）
          —— 其前置仍是「批 1 + 批 2 合并验收通过」
❌ 未授权：修改任何产品规则 / 新增一级页面或一级导航 / 新增第 5 个 Tab
```

**欠账清偿方式 —— 本次给出了（§8.1 的硬要求首次被满足）**：

```text
清偿方式：合并验收
验收时点：Phase 3 + 4 + 5 全部开发完成之后
验收范围：批 1 / 批 2 / Token 审计 / CareerlyInput（四笔旧欠账）
        + Phase 3 / Phase 4 / Phase 5（本轮三批新交付）
```

> ⚠️ **风险已明确告知并照实记录**（`DEVELOPMENT_WORKFLOW.md` §3.2「为什么要停」）：
> 把 3 个 Phase 的验收合并成一次，**未验收的假设会连续叠加**。
> 若验收时发现早期假设有误，返工范围将远大于逐批验收。
> 产品侧在知情前提下选择了这个节奏，本条不予粉饰。

---

#### D61 — Figma 的 `on-welcome` 实为「用户身份选择」，本轮不单做价值介绍页（2026-09-18 产品侧）

**背景**：AI 侧报告了 Phase 4 的冲突清单，其中一条是
「价值介绍」在 PRD §7.1 / IA §5.2 里排在**注册之前**，
而 Figma 的 `on-welcome` 排在**注册之后**。产品侧就此给出裁决。

**产品侧原话**：

```text
figma的价值介绍页面其实是用户身份选择（暂时不单做价值介绍页面）
```

**据此确定的处置**：

```text
✅ on-welcome 这个屏的**真实产品语义**是「用户身份选择」，
   不是「产品价值介绍」—— Figma 里那三张卡（看见能力 / 找到 Gap / 持续成长）
   与该屏的真实用途不符，不得据此实现
❌ 本轮**不新建**任何「价值介绍」页面
⚠️ 「用户身份选择」页的具体规格 **尚未给出**，
   因此在规格落地前 `on-welcome` **不进入实现队列**
```

**这条裁决连带解决的争议**：

| 原争议 | 处置 |
|---|---|
| PRD/IA「价值介绍在前」 vs Figma「在后」 | **消解** —— 本轮不做价值介绍页，先后问题不存在 |
| 【产品冲突】差异 10：三张卡的内容无任何文档依据 | **消解** —— 不实现该屏 |
| `app_routes.dart:43` 与 D53 的步骤表 | 需**更正**：六步链路里 `on-welcome` 一步的性质不是「价值介绍」 |

**该屏缺位造成的接线缺口**（Phase 4 批 2 落地时的**已知事实**，非新决策）：

```text
六步链路：开屏 → 注册/登录 → on-welcome → 提交简历 → 解析 → 确认
                              ↑ 本轮未建

因此注册完成后**没有 on-welcome 可去**，接线直接指向「提交简历」。
这是「该屏规格未给出」的直接结果，**不是**对链路顺序的修改。

待 on-welcome 规格落地后，只需把注册页的跳转目标改回该屏
—— 改动为一行，登记在案，避免日后被误读成「链路就是五步」。
```

**原待裁决项（已由 D63 / D65 收口）**：

```text
D63 → ✅ 已裁决：on-parsing 改用「建立职业基线」语义（保留 Figma 视觉）
D65 → ✅ 已裁决：职业画像一步确认删除，维持六步
```

---

#### D63 — `on-parsing` 改为「建立职业基线」语义（2026-09-18 产品侧裁决）

**分类：【产品冲突】**（本轮调研发现，**未自行处理**）

Figma `OnParsing`（`App.tsx` L806-920）的五个步骤是：

```text
1 岗位需求解析  —— AI 提取核心职责与技能要求
2 简历信息解析  —— AI 提取经历、项目与能力证据
3 能力匹配分析  —— 将简历能力与岗位要求深度匹配
4 识别能力 Gap  —— 分析与岗位要求之间的成长空间
5 生成分析报告  —— 整理匹配度、排名与改进建议
```

而三份文档逐条禁止 Onboarding 包含这些：

| 源 | 原文 |
|---|---|
| PRD §7.1 | 「不包含：**JD 输入**、**岗位选择**、**岗位匹配**、**第一次岗位分析**、**Gap 分析**」 |
| IA §5.2 | 「明确不包含：JD 输入 / 目标岗位 / 多岗位分析 / **匹配排序** / Gap 分析 / 第一次岗位分析」 |
| Baseline §4.1 | 「❌ 目标岗位 ❌ 岗位分析 ❌ 首次匹配 ❌ 分析结果」 |

**两难**：

```text
按 Figma 实现  → 实现三份文档明令禁止的功能，且直接触碰 PRD §5.3「匹配度只由能力匹配计算」
按 PRD 实现    → 该屏**没有任何视觉依据**（Figma 未画别的样子）
```

**影响范围**：`on-parsing` + `on-confirm` 两屏**无法开工**。

**✅ 产品侧裁决（2026-09-18）**：

```text
采用方案 A —— 保留 Figma 的进度视觉（光晕球 / 百分比 / 步骤清单），
只把 5 步文案换成「建立职业基线」语义。
```

**据此确定的处置**：

```text
✅ Figma 的**视觉**逐位保留：光晕三层结构 / 百分比 / 步骤清单卡 / 时序与缓动
✅ 5 步文案改为「建立职业基线」语义 —— 依据 PRD §7.2 对 Career Baseline 的定义
   （工作经历 / 项目经历 / 技能 / 奖项 / 初始能力画像 / 当前简历版本）
❌ 不出现：岗位需求解析 / 岗位匹配 / 匹配度 / 排名 / Gap
⚠️ 具体文案由 AI 侧起草，**登记为待产品侧确认** → §3.1 · **D66**
```

> ⚠️ 这是本轮发现的**最严重冲突** —— 它不是措辞差异，
> 而是「这个屏到底是什么」的根本分歧。裁决后按方案 A 实现。

---

#### D65 — 「职业画像（Career Profile）」确认删除，维持六步（2026-09-18 产品侧裁决）

**分类：【产品冲突】/【IA 冲突】**（Phase 4 调研时发现）

**✅ 产品侧裁决（2026-09-18）**：

```text
采用方案 A —— 确认删除该步，维持六步。
```

**据此确定的处置**：

```text
✅ Onboarding 链路固定为六步：
   开屏 → 注册/登录 → on-welcome → 提交简历 → 解析 → 确认
❌ 不恢复「职业画像」一步
❌ 不把 Figma 中不可达的 `OnCareer` 组件接回流程
   —— 它保持死代码状态，不进入实现队列
⚠️ D61 的「用户身份选择」与「职业画像」**不是**同一页
   —— 方案 C 被本裁决间接排除
```

**原始调研记录（保留，供追溯）**：

三份文档都有「职业画像」独立一步，Figma 里没有：

| 源 | 原文 |
|---|---|
| PRD §7.1 | 流程含独立一步 `Career Profile` |
| IA §5.2 / §20.1 | 同上，独立一步 `Career Profile` |
| Baseline §4.1 | `开屏 → 注册 / 登录 → **职业画像** → 提交简历 → …` |
| Figma | 有组件 `OnCareer`（`App.tsx` L640-746），**但不可达** —— 不在 `ONBOARDING_SCREENS`（L5162），全文件**无** `go('on-career')` 调用 |

**当前实现**：D53 回填的六步链路**不含**职业画像，即事实上删掉了这一步。

**引用**：`docs/05_progress/TODO.md` §3.2 · D53 的更正说明

**原候选方案**（已被上述裁决收口）：

```text
方案 A：确认删除该步（维持现状）—— Figma 的实际链路就是六步  ← ✅ 采纳
方案 B：恢复该步，并把不可达的 `OnCareer` 接回流程
        —— 需产品侧给规格（现有组件是死代码，内容未经确认）
方案 C：该步的职责由 D61 的「用户身份选择」承担
        —— 若成立，需产品侧明确它与 D61 是同一页还是两页
```

---

#### D64 — 首页三态模型 + 首登 Empty State 规格（2026-09-18 产品侧）

**背景**：AI 侧报告了首页调研的 6 项待裁决，其中「Figma 首页永远是满数据状态、
新用户 Empty State 未实现」是核心一条。产品侧据此给出完整规格。

**① 首页必须是三态，不是一态**

```text
State 01  首次使用：无简历 / 无岗位   →  引导上传简历
State 02  已有简历：无岗位分析        →  引导添加 JD
State 03  已有简历 + 岗位分析         →  Figma 现有的完整 Dashboard
```

> ✅ **现有 Figma 首页不废掉，直接成为 State 03。**
> 本轮新增的是 State 01 / 02 两个 Empty State，**首页视觉结构保留**。

**①bis 实施铁律（产品侧追加，原话）**

```text
注意只替换文字内容，不要修改 figma 视觉设计
```

→ 即：三个状态**共用同一套 Figma 视觉**（5 区块结构 / 几何 / 渐变 / 阴影 / 圆角），
**只替换文案**。不得为了 Empty State 改版式、改配色、改间距、增删区块。

**② State 01（首登）的逐块规格**

| 区块 | 内容 |
|---|---|
| **Hero** | 小标签 `你的职业主页` · 标题 `还没有职业分析` · 说明 `从一份简历开始，看见你的职业能力` · 按钮 **`上传简历`** |
| **问问 AI 卡** | `问问 AI` / `不知道下一步该提升什么？` / `和 AI 聊聊你的职业方向` |
| **当前状态卡** | `还没有职业分析` / `上传简历并分析一个目标岗位` / `看见你的能力匹配度` |
| **最近成长卡** | `还没有成长记录` / `每一次简历更新、技能增加` / `都会成为你的职业资产` |
| **今日一句卡** | `今天也可以向前一步` / `先看见自己，再决定下一步。`（**不依赖岗位数据，三态通用**） |
| **原「岗位匹配变化」区** | 改为 **`开始你的第一次分析`** / `找到一个你感兴趣的岗位，把 JD 粘贴进 Careerly。` / `分析第一个岗位 →` |

**③ 要传达的核心价值链（必须体现在首登页上）**

```text
简历  +  目标岗位 JD   →   Careerly   →   看见能力匹配   →   发现 Gap
```

**④ 一条明确的产品红线**

```text
❌ 首次登录**不得**要求用户先填大量职业信息
   （选择职业方向 / 行业 / 城市 / 目标薪资 / 工作年限 …）
✅ 首登路径必须收敛为三步：上传简历 → 输入/粘贴 JD → 分析
```

> 理由（产品侧原话）：「这些东西会让 Careerly 从
> 『帮助我看见自己』变成『让我先填一张表』。」

**⑤ 本条对既有争议的处置**

| 原争议（详见本次报告） | 处置 |
|---|---|
| 【产品冲突】PRD §8 六项 vs Baseline §3.1 六项不一致 | **本轮不阻塞** —— State 01 用产品侧新给的文案，State 03 按 Figma 现有结构保留 |
| 【产品冲突】Figma 首页有 Header / Filter Tabs，IA §6 未列 | **保留**（产品侧明确「Figma 首页结构保留、不重新设计」） |
| 【产品冲突】首页渲染全部 4 行岗位 = 越过「不做数据仓库」红线？ | **State 03 维持现状**；State 01 不含岗位列表，问题自然收敛 |
| 【技术实现差异】「最近成长」卡跳 `cap-change` 无路由 | **仍待裁决** —— 属 Phase 8 的「能力变化」页 |
| `AppSpacing.pageHorizontal` 16 vs Figma `px-5` 20 | **仍待裁决**（D37 已挂账） |

**⑥ Figma 假数据的处置（与 `CLAUDE.md` §7 一致）**

```text
❌ Figma 首页硬编码的 `Alex` / `86%` / `AI 产品经理` / `4/6/12/5` 等
   **不得**搬进 Mock
✅ 三态由**真实数据是否存在**驱动（`ResumeProfile.hasBaseline` + 是否有岗位分析）
✅ 因此 State 01 / 02 在 Mock 下**天然可见**，无需编造数据
```

> 这条同时消解了 Phase 5 报告里的「`Alex` 硬编码违反 §7」问题 ——
> 首登态根本不显示姓名。

---

> 📌 **与 D51 / D52 的关键区别**：**D51 / D52 未给清偿方式，D60 给了。**
> 因此四笔旧欠账从「无限期挂账」转为「**已排期清偿**」。
> ⚠️ 但**在真正验收之前，其真实状态仍是「未验收」** ——
> 不得据本次授权反推「已确认无误」（与 D20 / D51 / D52 的警告同款）。

**本轮仍受约束的禁令**（`CLAUDE.md` §0 三条最高禁令**未被豁免**）：

```text
❌ 禁止自行修改产品规则
❌ 禁止自行增加一级页面 / 一级导航
✅ 第三条（禁止自动进入下一 Phase）由本授权**具名豁免，仅限 Phase 3 / 4 / 5**
```

---

#### D59 — 本轮「修红 + 补文档」的授权范围与欠账处置（2026-09-18 产品侧）

**背景**：AI 侧在开工核对时实测发现仓库**处于红灯 + 文档漂移状态**
（`flutter test` 72 用例中 1 失败；Phase 4 批 1 的 1150 行代码**完全没有交付记录**，
而 `CURRENT_STATUS.md` 仍写「Phase 4 ⛔ 未启动」），遂停下报告。
产品侧在**知情前提下**给出本轮范围（符合 §8.1 ①）。

**授权内容**（具名）：

```text
✅ 授权：修复 test/phase4_onboarding_test.dart 的红灯用例
✅ 授权：补齐 Phase 4 批 1 缺失的文档
         （D53 补登 · §3.1 新增 D54–D58 · CURRENT_STATUS / CHANGELOG 同步）
✅ 授权：本轮结束后停在 Phase 4 批 1 交付点
❌ 未授权：Phase 4 批 2（价值介绍 / 提交简历）
❌ 未授权：Phase 4 其余步骤（解析 / 确认 / 基线）
❌ 未授权：Phase 5（首页）
❌ 未授权：Phase 3 的未定稿项收口 / Phase 2 批 3
```

**欠账处置 —— 产品侧明确选择「继续挂账」**：

```text
批 1 / 批 2 / Token 审计 / CareerlyInput
        —— 四者本轮不处理，验收状态仍是「未验收」
```

> ⚠️ **与 §8.1 的张力，如实记录（不代为圆场）**：
> `DEVELOPMENT_WORKFLOW.md` §8.1 要求豁免停止点时**必须同时给出欠账的清偿方式**。
> 本次产品侧在知情前提下明确选择**不给** —— 这是产品侧的处置权，
> 故本条**照实记录**，**未替产品侧补一个清偿方式**。
>
> 但**欠账不会因为被选择不处理而消失**：
>
> ```text
> 批 1 / 批 2 / Token 审计 / CareerlyInput 的真实状态 = ⚠️ 未验收
> 不得反推「已确认无误」（与 D20 / D51 / D52 的警告同款）
> ```
>
> 📌 这是**第三次**向产品侧暴露该欠账（前两次见 D51 / D52）。
> 按 §3.2 规则，未给清偿方式即视为**继续挂账**，而非自动并入任何后续批次。

---

#### D53 — Onboarding 步骤顺序取 Figma（**补登**，2026-09-18）

**分类：【产品冲突】/【IA 冲突】**

**⚠️ 本条目为补登，不是本次新裁决。**

该裁决被 `lib/app/router/app_routes.dart:43` 引用
（「步骤顺序取 **Figma**（产品侧裁决，见 `TODO.md` §3.2 D53）」），
**但 `TODO.md` 中从未建立过这一条** —— 属 `DEVELOPMENT_WORKFLOW.md` §5.4
「代码引用 ↔ 登记条目必须一一对应」的一次违规。本次补齐。

**裁决内容**（按代码实现回填）：

```text
开屏 → 注册 / 登录 → 价值介绍 → 提交简历 → 解析 → 确认
```

**⚠️ 一致性核查表已于 2026-09-18 更正（原表有错，见下）**

原表只比对了第 3 步的**措辞**，**没有比对它的位置**，因此得出「PRD / IA 一致」
的结论 —— 该结论**是错的**。补做位置比对后的真实情况：

| 源 | 完整顺序 | 与本节裁决的关系 |
|---|---|---|
| **PRD V2.1 §7.1** | `Splash → **产品价值介绍** → 注册/登录 → Career Profile → 提交简历 → AI 解析 → 建立基线 → 完成 → 首页` | ❌ **顺序相反**：PRD 把价值介绍放在注册**之前** |
| **IA V2.1 §5.2 / §20.1** | 同 PRD（含 `Career Profile` 独立一步） | ❌ 同上 |
| **Baseline §4.1** | `开屏 → 注册/登录 → **职业画像** → 提交简历 → 简历解析 → 确认职业信息 → 首页` | ⚠️ **也有「职业画像」一步** |
| **Figma** | `on-splash → on-register → on-welcome → on-resume → on-parsing → on-confirm` | ✅ 与本裁决一致（注册在前） |
| `Careerly_Vibe_Coding_开发启动_Prompt_V1.0.md` §三十五 | 「Career Profile（职业画像）」 | ⚠️ 历史产物，不回改 |

**两处实质分歧**：

```text
分歧 1：价值介绍的**位置** —— PRD/IA 在注册前，Figma 与本节裁决在注册后
分歧 2：`Career Profile`（职业画像）这一步 —— PRD/IA/Baseline 三份都有，
        Figma 里 `OnCareer` 是**不可达死代码**（不在 ONBOARDING_SCREENS，
        全文件无 `go('on-career')`），本节裁决把它删掉了
```

> ⚠️ **本节裁决的效力说明**：它是从代码实现**回填**的，**没有产品侧原话可引**。
> 按 `CLAUDE.md` §3.1「`Figma ≠ PRD → PRD 胜`」，分歧 1 本应按 PRD 处理
> —— 但当时未识别出这是冲突。
>
> **2026-09-18 产品侧已就分歧 1 给出裁决（见 §3.2 · D61）**：
> `on-welcome` 的真实语义是「用户身份选择」，本轮不单做价值介绍页。
> 因此分歧 1 **消解**，本节的六步链路仍成立，
> 但 `on-welcome` 一步的**性质需重新理解**（不是价值介绍）。
>
> **分歧 2（职业画像的存废）仍未获产品侧明确裁决** —— 见 §3.1 待裁决清单。

---

#### D52 — Phase 4 第 1 批开工授权（2026-09-18 产品侧，**仍未解除任何欠账**）

**授权内容**（具名）：

```text
✅ 授权：Phase 4 Onboarding 第 1 批 —— 开屏 + 注册 / 登录，两页
✅ 授权：注册 / 登录 走「纯 Mock」—— 不接真实鉴权、不引入本地存储依赖
❌ 未授权：Onboarding 其余步骤（职业画像 / 提交简历 / 解析 / 确认 / 基线）
❌ 未授权：Phase 2 批 3（前置仍是「批 1 + 批 2 合并验收通过」）
```

**依据**：`CLAUDE.md` §7 Mock First + `DEVELOPMENT_WORKFLOW.md` §2
（「一个任务 = 一个页面 / 一个组件 / 一个交互 / 一条数据链路」，须可独立验收）。

**⚠️ 欠账状态（与 D51 相同，未被清偿）**：批 1 / 批 2 / Token 审计 /
`CareerlyInput` **四者仍是「未验收」**。

> ⚠️ `DEVELOPMENT_WORKFLOW.md` §8.1 要求豁免时**同时给出欠账清偿方式**，
> **D51 与 D52 均未给出**。欠账继续挂账，已第二次向产品侧报告。

---

#### D51 — Phase 3 开工授权（2026-09-18 产品侧，**未解除批 1 / 批 2 欠账**）

**背景**：`CLAUDE.md` §0 第三条禁令 + `DEVELOPMENT_WORKFLOW.md` §8.1 规定，
Phase / 批次结束后必须停在停止点等验收，豁免须由产品侧**逐次、具名**给出。
当时的停止点是 **Phase 2 批 1 + 批 2 合并验收**（§1.1）。

**授权内容**（具名）：

```text
✅ 授权：按 CURRENT_STATUS.md 的 Phase 3 定义开工
         （App Shell 视觉定稿 / AI 入口视觉定稿 / Android back 分支级处理）
✅ 授权：Phase 3 的视觉定稿改在 桌面 / Chrome 上进行（非 Android 真机）
❌ 未授权：Phase 2 批 3（ScoreIndicator / AIMessageBubble / 导航栏 Glass 统一）
          —— 其前置仍是「批 1 + 批 2 合并验收通过」，本次豁免不覆盖
❌ 未授权：roadmap 与 CURRENT_STATUS 的历史差异 → 不重划 Phase、不新增 Phase、不重写 roadmap
```

**AI 侧动作**：本次由产品侧在**知情前提下**主动选择（停止点与欠账台账已先行完整报告），
故符合 §8.1 的 ①「不得由 AI 提议并自行采纳」。

**⚠️ 欠账状态（重要）—— 本次授权没有清偿任何欠账**：

| 批次 | 验收状态 |
|---|---|
| 批 1 | ⚠️ **仍未验收** |
| 批 2 | ⚠️ **仍未验收** |
| Token 审计 | ⚠️ **仍未验收** |
| `CareerlyInput` | ⚠️ **仍未验收** |

> ⚠️ **§8.1 要求豁免时必须同时给出欠账的清偿方式 —— 本次未给出。**
> 已向产品侧报告，**清偿方式待定**，不得据本次授权反推「批 1 / 批 2 已确认无误」。
> 未给清偿方式即视为欠账**继续挂账**，而非自动并入 Phase 3。

**已知会带入 Phase 3 的两项缺陷**（授权时已明确标记影响范围）：

```text
K1  无 Noto Sans SC 字体  → Phase 3「视觉定稿」的排版一栏不能盖章
K3  无 Android 设备       → SafeArea / Android back 的验证不可执行（桌面定稿不覆盖）
```

---

#### D20 — 跳过 Phase 2 批 1 独立验收（2026-09-18 产品侧授权）

**背景**：`CLAUDE.md` §0 三条最高禁令之一为「禁止自动进入下一个 Phase / 批次」，
`DEVELOPMENT_WORKFLOW.md` §3.1 亦规定「每个 Phase（或批次）结束 → 输出报告 → 停止 → 等待验收」。

**授权内容**：产品侧明确选择「**跳过验收，直接开工批 2**」，并确认
**批 1 视为通过**。

**执行方式**：AI 侧不得自行作出此判断 —— 本轮是由产品侧在知情前提下明确选择，
故此记录**不是**对禁令的推翻，而是**一次具名授权**。

**配套的欠账处理**（重要）：

```text
批 1 的真实验收状态 = ⚠️ 未验收（不是「已通过」）
欠账约定           = 批 2 交付时，批 1 + 批 2 合并验收
```

> ⚠️ **后续 Session 注意**：批 1 **没有**验收过。
> 不得据本授权反推「批 1 已确认无误」。
> 任何针对批 1 组件的假设都仍是**未验证假设**。

---

#### D26 — `CareerlyToast` 的视觉由 Flutter 用**已有 Token** 补齐（2026-09-18 产品侧裁决）

**原问题**（【视觉/交互差异】）：K11 —— Figma 中不存在 Toast 的视觉实体。

**产品侧裁决**：**用已有 Token 补齐**（而非从网络找参考、或自行发明新的视觉语言）。

**这意味着什么**：

```text
✅ 组件可运行、可交付、四态齐备
❌ 补齐出来的取值**不是设计值**，验收时不得盖章为「视觉已定稿」
```

**补齐依据的既有 Token**（全部来自 `CareerlyTheme.snackBarTheme`，未新造）：

| 项 | 取值来源 |
|---|---|
| 底色 | `AppColors.surfaceDark` |
| 文字色 | `AppColors.textInverse` |
| 圆角 | `AppRadius.borderMd` |
| 投影 | 无（`snackBarTheme.elevation = 0`） |
| 字号 | `AppTypography.body` |

**同一处置方式的先例**：`CareerlyButton` 的 Disabled 态（D16）——
「补齐而不是发明，但具体取值未经裁决」。

**明确的后续动作**：设计侧补视觉后，**必须回改** `CareerlyToast` 并按真实视觉复核。

**未覆盖的部分**（Token 里没有对应值，故仍需单独裁决）：

```text
D32  停留时长 2500ms      ← 新造的数字
D33  进出动画 160ms       ← 与 Figma 真值 180ms 有偏差
```

**变体未实现**：设计侧没有成功 / 错误 / 警告的任何视觉区分，
`motion-spec` 提及的「已删除 · 撤销」需要带操作按钮的 Toast，视觉同样未定义。

---

#### D27 — `CareerlyBottomSheet` 采用「参数化 shell + 变体预设」（2026-09-18 产品侧裁决）

**背景**：Figma **不存在统一的 BottomSheet 组件**，
而是 6 处**内联变体**（`App.tsx` L2082 / L2298 / L4431 / L4595 / L5056 / L5098）。

**产品侧裁决**：**参数化 shell + 变体预设**。

```text
壳（shell）   ：scrim + 贴底面板 + 顶部圆角 + 拖拽把手   ← 6 处变体的共性
预设（preset） ：按 scrim 取值 + 使用场景归纳出 3 档 tone
```

**⚠️ 三档 tone 是「分析归纳」，不是设计侧定义的枚举。**
`CareerlyBottomSheetTone` 的 `confirm` / `action` / `overlay`
由 Flutter 侧归纳，**待产品侧确认这个归纳方式本身**。

| tone | Figma 变体 | 场景 |
|---|---|---|
| `confirm` | A · B | 分析中退出确认、结果页更新分析 |
| `action` | C · D | 简历分享 / 导出、导入新简历 |
| `overlay` | E · F | 退出登录、额度用尽 / 最后 1 次 |

**变体差异通过参数暴露**（`radius` / `fill` / `handleWidth` / `handleColor`），
未拆成多个组件 —— 遵循 D18「变体用参数，不用新组件」。

**有意未做**：下滑关闭、高度档位（见 D34）。

---

#### D28 — `CareerlyAnalysisProgress` 移出批 2，改归 Phase 6（2026-09-18 产品侧裁决）

**原问题**（【技术实现差异】）：Figma 里的「分析中」是一个**页面级复合体**
（圆环进度 + 大百分比 + 步骤时间线），
而 `CareerlyProgress`（批 2 的另一个交付物）是**线性**进度条。
两者不是同一个东西。

**产品侧裁决**：**移出批 2 → Phase 6**。

**理由**：它是页面级复合体，不是 design-system 层的原子组件；
在没有真实分析页面的情况下无法验收。

**后果**：

```text
批 2 的组件数 4 → 3（CareerlyProgress / CareerlyBottomSheet / CareerlyToast）
CareerlyAnalysisProgress 的命名尚未按 D18 复核（大概率应加 Careerly 前缀）
```

---

#### D18 — 组件命名规范（2026-09-18 裁决）

**原问题**（【技术实现差异】）：`CLAUDE.md` §8.4 的组件清单与 Phase 2 批 1 实际建成的组件对不上，
且 §8.4 自身与 §6.4「统一前缀 `Careerly`」矛盾。

**裁决：以实际代码为准，不修改已实现的组件命名。** 命名规则按**层级**分两类：

| 层 | 前缀 | 判定标准 | 例 |
|---|---|---|---|
| Design Primitive | ❌ 不加 | 不含 Careerly 业务语义，可被任何项目复用 | `GlassSurface` · `GlassEdgePainter` · `GlassFilters` |
| 产品级共享组件 | ✅ 加 `Careerly` | 承载 Careerly 的产品交互语义 | `CareerlyCard` · `CareerlyButton` · `CareerlyChip` · `CareerlyPressFeedback` · `CareerlyAsyncStateView` |

**三条「不拆分」决策**：

```text
CareerlyButton            用 variant 区分 primary / secondary（不建 PrimaryButton / SecondaryButton）
CareerlyAsyncStateView    统一承载 loading / empty / error（不拆成 EmptyState / LoadingState / ErrorState）
GlassSurface              保持 primitive 定位（不改名 CareerlyGlassSurface）
```

**原则**：变体用参数，不用新组件 —— 只有当**行为**真的不同（而非只是样式不同）时才拆。

**已同步**：`CLAUDE.md` §8.4（重写）+ §6.4（去掉「统一前缀」的矛盾表述）。
**未改动任何组件代码。**

> ⚠️ **遗留**：**Baseline §7.5 只规划了 8 项**（`CareerlyProgress` / `CareerlyBottomSheet` /
> `CareerlyToast` 在列）。`CareerlyAnalysisProgress` / `ScoreIndicator` / `AIMessageBubble`
> **不在 Baseline**，属项目自有规划，**命名尚未按 D18 复核**。
> 批 2 / 批 3 实现时确认，**不预先改名**，**也不代表已创建或已排期**。

---

#### AI Tab 的定位（2026-09-17 确认）

```text
AI 是正式一级 Tab          —— 已确认
AI 允许特殊视觉表现         —— 已确认
```

AI 与首页 / 分析 / 我的**平级**，其特殊性属**表现层**，不属**层级**。

---

#### Q1 / Q3 / Q4 — 复核更正（2026-09-17）

> 原记录与 `careerly_navigation_bar.dart` 的**实际实现**矛盾。
> 该文件已在 Phase 1 期间被**重写为 Figma-faithful 版本**，
> 但当时没有留下任何记录 —— 文档链在此断了一环（已在 Session 004 补记）。

**结构：3 Tab 玻璃条 + 条外 AI 浮球**（不是「4 个位置」）

```text
        ┌──────────────┐
        │ ▢   ▢   ▢    │        ╭───╮
        └──────────────┘        │ ✦ │
                                │ AI│
                                ╰───╯
         玻璃条 232×60            AI 62×62
                    ←── gap 10 ──→
```

与 **Baseline §6.5 / 决策 9** 一致。Phase 1 brief 的「4 个位置」描述**未被采纳** ——
AI 不是玻璃条内的第 4 格。

**视觉取值全部按 Figma 真值**：

| 项 | Figma 真值 | 代码实际 | 原文档错记为 |
|---|---|---|---|
| AI 球直径 | `62 × 62` | ✅ `_NavMetrics.aiSize = 62` | ~~`46 × 46`~~ |
| 玻璃条高度 | `60`（`padding 5×2 + tab 50`） | ✅ `_NavMetrics.barHeight = 60` | ~~导航栏高 64~~ |
| 玻璃条宽度 | `232`（3 × 72 + 2 × 2 + 6 × 2） | ✅ 由 slots 推导 | — |
| 玻璃条圆角 | `30` | ✅ `barRadius = 30` | — |
| AI 球文字标签 | **有**（`✦` + `AI`） | ✅ `AppTypography.navAiLabel` | ~~「无文字标签」~~ |

**Q3 的结论**：AI 入口**有**文字标签，且已带 `Semantics(label: ...)` 可访问性标注。
**原记录「无标签」是错的。**

**仍然成立的部分**：AI 入口的最终视觉定稿（是否浮起 / 尺寸微调 / 标签排版）
仍属 **Phase 3 视觉定稿**范围。但**结构已按 Figma 落定，不需要改结构**。

</details>

---

## 四、未实现功能台账（2026-09-30 盘点）

> **这一节回答**：「还差哪些功能」。
> §1.0d 回答的是「这些账是**怎么欠下的**」；本节的兄弟节是 `CURRENT_STATUS.md`（现状总表）。
>
> ❌ **它不是授权、不是排期、不是产品裁决。**
> 台账里列出一条缺口**不等于**可以开工 —— 开工仍需按 `CLAUDE.md` §0 第三禁令逐单元具名授权。
> ❌ 台账也**不判断**哪条该做。凡需要判断的，都指向 §3.1 的 D 编号。
>
> **盘点方式**：只读扫描 `lib/features/**` · `lib/data/**` · `lib/app/**` · `test/**`，
> 逐条带 `文件:行号`，**未修改任何代码**。
> 基线：分支 `feature/phase6-analysis` @ `267fd64`。
>
> ⚠️ **一个会骗人的事实**：全仓**没有** literal `// TODO` / `// FIXME` ——
> 未做项一律用中文注释 + §3.1 的 D 编号表达。
> 所以「grep TODO 查不到东西」**不代表没有欠账**，只代表欠账写法不同。

### 4.0 总览

| 组 | 含义 | 条数 |
|---|---|---|
| **4.1** 🔴 交付缺口 | 需求明文要求、且**没有**站得住的豁免依据 | **8** |
| **4.2** ✅ 有意未做 | **有**依据（产品规则 / 裁决 / 「不编造数据」）—— **不必再问一遍** | 12 |
| **4.3** ⚠️ 待产品侧裁决 | 到底是缺口还是设计，文档内无法判定 | 5 |
| **4.4** ⬜ 未开工 | 排过期、但一行生产代码都没写 | 5 |
| **4.5** ⚙️ Mock 层空实现 | Mock First 的**正常形态**，不是缺陷 —— 但决定「验收时看不见什么」 | 14 |
| **4.6** 🟡 测试覆盖缺口 | 功能在，但没有能验它的测试 | 7 |
| **4.7** 📝 过期注释 | 注释说的与代码做的不一致（**本次新发现的债种**） | 2 |

---

### 4.1 🔴 交付缺口 —— 需求有明文，豁免依据不足

> 判定口径：`IA` / `PRD` 里**写明了**，而代码里没有；并且代码给出的「未做」
> 理由是**数据缺失 / 落点不存在**这类**可随 Phase 推进消除**的原因，
> 而不是产品规则层面的豁免。

| # | 缺口 | 需求来源 | 现状证据 |
|---|---|---|---|
| **G1** | 分析「**更新分析**」Sheet | IA §8 整节（更新分析 IA：历史分析 → 选项目 → 更新 → 变化反馈） | `analysis_page.dart:1110-1115` 自述「有意未做…**直接落新建分析**」 |
| **G2** | 分析「**历史版本**」 | IA §7.5（查看过去分析项目 / 重新打开 / 继续使用岗位 / 更新 / 查看变化） | 未实现。IA 已定形态为**历史分析内部的 Bottom Sheet**（不是独立页面） |
| **G3** | 简历详情 / 管理页（`resume-detail`） | IA §15（查看当前简历 / 查看历史版本 / 上传新简历 / **删除** / **设置当前**） | 页面**不存在**；`resume_history_page.dart:16-24` 自述「批 1 只交付当前简历横幅，其余属批 3」 |
| **G4** | 简历历史版本列表 + 左滑操作 + 新建 FAB + 导入 Sheet | IA §15 | `resume_history_page.dart:20-23` 的 `⬜ 批 3` 清单；`:95` 留了回改 96 的注释 |
| **G5** | 设置页 5 个入口 | IA §16（账户 / AI 与通知×3 / AI 回答风格×3 / 隐私与数据 / 帮助中心 / 关于 Careerly / 退出登录） | `settings_page.dart:36,73,74,75` 全为 `onTap: () {}`；`:82`「退出登录」`onPressed: () {}` |
| **G6** | 设置项持久化 | IA §16 | 开关与回答风格只在本地 `setState`，**离开页面即失**（无 Provider、无存储、无后端） |
| **G7** | 历史岗位详情页 | IA §13（职业资产含「历史岗位」）/ IA §18 Level 3「我的 / 历史岗位详情」 | 无页面、无路由。⚠️ **Baseline O7 早已登记此缺口并排给 Phase 8**，而 Phase 8 已交付 |
| **G8** | 「从历史岗位添加」（新建分析） | PRD §9.3 / IA §7.2 | Mock 恒空（见 M4）；真实 API 已实现（`GET /api/v1/analysis/jobs`）—— 即**后端有了、前端这条路在 Mock 下不可见** |

> ⚠️ **G1 / G2 的「有意未做」是否成立，需要产品侧认定。**
> 代码把这两条按 **D92「落点不存在的入口不渲染」** 处置，
> 但 §1.0d ⑤ 已指出：IA §8 是**明文要求**，不是「Figma 表达不了」那类。
> **口径不一致，故此处登记为缺口而非豁免** —— 最终归属等产品侧（并入 D102 一并澄清）。

> 📌 **G3–G6 不要与 G1/G2 混为一谈。**
> G3/G4 的切分理由写在代码里，而且**站得住**（`ResumeVersion` 没有匹配度字段，
> 硬造「当前简历的最高匹配」等于编产品数据 → 违反 §7）。
> 但这只解释「**为什么这批没做**」，不改变「**还没做**」这个事实 ——
> 所以它仍在 4.1，不在 4.2：**理由成立 ≠ 已豁免**。

---

### 4.2 ✅ 有意未做 —— **有依据，不必再问**

> 列在这里是为了**避免重复提问**，也是为了让验收时不必逐条追问
> 「这个按钮为什么点了没反应」。每一条都有出处。

| 未做项 | 依据 | 证据 |
|---|---|---|
| 自有招聘岗位池 / 保证求职结果 / 自动投递 / 自动完成求职 / 替用户提升能力 / 替用户做人生级职业决策 | **PRD §18「非目标」** | — |
| Onboarding 不做 JD 输入 / 岗位选择 / 首次匹配 / 首次分析 / Gap 分析 | **PRD §8「不包含」** + `CLAUDE.md` §5.1 | — |
| 真实支付（Pro 只弹提示） | **Phase 0 决策 6**（MVP = 静态页 + 额度门禁） | `membership_page.dart:130` → `_showTrialNotice` |
| AI 会话历史 | **Phase 0 决策 7**（暂不进 MVP） | `ai_repository.dart:7` 只有 `sendMessage` |
| Figma 的「历史分析」「设置」两个 Tab 不做成卡片 | **`CLAUDE.md` §2.2 / IA §16** | `profile_page.dart:163` 明确只有 3 个 Tab |
| `on-welcome` 价值介绍页不单做 | **D61** | `app_routes.dart:172` 记「未进入实现队列」 |
| 「点击下载」（导出分析结果） | 无导出能力 —— 不编造不存在的落点 | `analysis_page.dart:1112` |
| 「查看最匹配岗位」 | `a-job` 页未建 | `analysis_page.dart:1112` |
| 成长空间**数值**双条 | Mock 只有 Gap 文案，没有 `yours` / `target` 数值 | `analysis_page.dart:1113-1114` |
| 能力页「查看变化 →」整块不渲染 | `cap-change` **无路由**（D92 / D81 处置） | `capability_page.dart:43` |
| 分析页简历「更换」徽标不接线 | 挂起项 **D82**，且无简历时不渲染 | `analysis_page.dart:503-506` |
| 「+ 添加目标岗位 JD」按钮纯视觉 | Figma 原型本身就**没有 onClick** | `targets_page.dart:304-309` |

---

### 4.3 ⚠️ 待产品侧裁决 —— 无法在文档内判定是缺口还是设计

| # | 事项 | 为什么文档里判不出来 |
|---|---|---|
| **A1** | **`/analysis/targets` 是死路由** —— 页面已实现、路由已注册（`app_routes.dart:53`），但**全仓没有任何入口跳它**（`targets_page.dart:30` 自述「已注册、未接线」） | 是「等接线」还是「不该建、应删」？C 批把它建了出来，但 §3.1 里**没有**对应的 D 编号，也没有授权记录 |
| **A2** | **Onboarding 整条流程无入口** —— 六步页面全部实现，但 `initialLocation` 默认 `/home`，无任何 `go(/onboarding/splash)` | 已被 **D54 / D84** 覆盖（默认进开屏 vs 跳过取决于会话持久化）—— 此处只登记「代码已就绪、入口待裁决」 |
| **A3** | **Mock 下 3 次额度不成立** | 已立 **D105**（`fetchQuota` 恒 3/3 且不落盘 → 退出重进即复位） |
| **A4** | **`CareerlyApp.overrides` 生产代码里的测试注入缝** 是否接受 | 已登记为 **D102 附属项**（工程取舍，非产品规则） |
| **A5** | **D67 方案 A 是否授权** + 10MB / PDF·Word 白名单能否作为产品规则生效 | 已立 **D103** |

> 🔴 **A1 的一个连带事实（本次新发现）**：`ApiResumeRepository.submitResumeFile`
> **直接抛错**（`api_resume_repository.dart:34-41`：「简历文件上传暂未接入，请改用粘贴简历文本」，后端 P3 未建）。
> 因此刚提交的 `267fd64`（D67 方案 A）**只在 Mock 模式走得通**：
>
> ```text
> Mock 模式      选文件 → Mock 空实现 → 成功 → 进解析页（其实什么都没上传）
> 真实后端模式   选文件 → 立即失败 → Toast「简历文件上传暂未接入」
> ```
>
> 这不是缺陷（Mock First 是既定做法），但**必须写进 D103 的裁决材料** ——
> 「方案 A 已实现」这句话在真实后端下**不成立**。

---

### 4.4 ⬜ 未开工 —— 排过期，但一行生产代码都没有

| # | 项 | 现状 |
|---|---|---|
| **N1** | **Phase 9 · Global States** | 无生产代码。`test/phase9_global_state_test.dart` 存在，测的是**跨页面通用反馈**，不代表 Phase 9 已开工 |
| **N2** | **Phase 10 · Android 真机 QA（T1–T14）** | 未执行。它是**唯一**能暴露 SafeArea / 返回键 / 中文字体回退的手段；09-23 的 Back 重构**从未在真机上跑过** |
| **N3** | **Phase 2 批 3**（`ScoreIndicator` / `AIMessageBubble` / 导航栏 Glass 统一 K10·K12） | 未开工。前置：批 1 + 批 2 合并验收通过 |
| **N4** | **K1 字体缺口** —— Noto Sans SC 未入仓 | `assets/fonts/README.md` 已说明；`CLAUDE.md` §8.3 禁止自行下载或替代。**所有排版结论因此不能盖章** |
| **N5** | **AI 真实上下文** —— `sendMessage` 恒返回同一条写死文案，不读简历 / 岗位 | `mock_ai_repository.dart:15-24`。⚠️ 属 Mock，但 Phase 7 标称「AI Chat UI（Mock）」已交付 —— 即**UI 在、智能不在**，验收时勿误判 |

---

### 4.5 ⚙️ Mock 层空实现 —— **不是缺陷**，但决定了「验收时看不见什么」

> `CLAUDE.md` §7 明确要求 Mock **默认返回空数据**（让 Empty 态真实可见），
> 所以下表**大部分是合规的**。它的用途是：验收时对着它看，
> **知道哪些现象是「功能没做」，哪些只是「Mock 没数据」**。

| # | 位置 | 行为 | 后果 |
|---|---|---|---|
| **M1** | `mock_home_repository.dart:21` | `fetchSummary` 恒 `HomeSummary.empty` | 首页**永远停在 State 01**（D75：State 02/03 只能靠注入测试覆盖） |
| **M2** | `onboarding_confirm_page.dart:104-115` | 简历画像恒空 | 「确认职业信息」屏**恒为 Empty 态**，走不到真实内容分支 |
| **M3** | `mock_analysis_repository.dart:53` | `fetchQuota` 恒 `QuotaState.free` | 🔴 **与其余各行不同 —— 见 D105**：额度**行为上不成立**，违反 `CLAUDE.md` §5.2 |
| **M4** | `mock_analysis_repository.dart:46` | `fetchJobLibrary` 恒 `const []` | 「从历史岗位添加」不可用（见 G8） |
| **M5** | `mock_analysis_repository.dart:84` | `analyze` 写死 `score: 0` | 匹配度恒 0 —— ⚠️ **不是编造数据，是「没算」**，勿误当需求 |
| **M6** | `mock_analysis_repository.dart:31` | `fetchProjects` 无写入方法 | 分析历史**在 Mock 下永远为空** |
| **M7** | `mock_resume_repository.dart:23,29,80` | 画像 / 版本 / 基线恒空 | 简历三块在 Mock 下全空 |
| **M8** | `mock_resume_repository.dart:37-40` | `setCurrentVersion` **抛错** | 「设置当前简历」不是没做，是**报错** |
| **M9** | `mock_resume_repository.dart:53,62` | 两个提交方法空实现、不持久化 | 提交「成功」但什么都没存 |
| **M10** | `mock_career_assets_repository.dart:26` / `mock_profile_repository.dart:26` / `mock_growth_repository.dart:26,37` | 职业资产 / 身份 / 成长 恒空 | 「我的」各二级页在 Mock 下全为 Empty |
| **M11** | `mock_auth_repository.dart:35,45` | `register` / `login` 只延迟，不校验、不存会话 | 「登录成功」不产生任何状态 |
| **M12** | `home_repository.dart:14` · `profile_repository.dart:18` · `career_assets_repository.dart:28` · `growth_repository.dart:19,25` · `ai_repository.dart:7` | **全部只有读方法，没有写** | 结论：MVP 里**所有「编辑职业资产」类能力都没有数据层落点** —— 这是设计（职业资产来自简历解析），但验收时不要期待「能改」 |
| **M13** | `api_resume_repository.dart:34-41` | 真实后端下 `submitResumeFile` 抛错 | 见 4.3 的连带事实 |
| **M14** | `quota_state.dart:44-45` · `career_assets.dart:42` · `user_profile.dart:23-25` | 若干字段是**占位语义**（`isMember` 未裁决 / D89 口径未定 / D90 空态文案） | 对应 §3.1 的 D 编号，勿当已定 |

---

### 4.6 🟡 测试覆盖缺口

> 现状：`test/` **17 个文件 / 180 用例 / 全绿**（`flutter analyze` 亦干净）。
> 下表只列**功能在、但没有能验它的测试**的地方。

| # | 位置 | 缺口 |
|---|---|---|
| **C1** | `ai_page.dart`（383 行） | **无 widget 测试**。`phase7_ai_test.dart` 只有 **2 个 Provider 单元用例**，聊天 UI（发送 / 禁用 / 重试气泡 / 建议卡）**零覆盖** |
| **C2** | `gap_page.dart` | 无专门测试 |
| **C3** | `job_detail_page.dart` | 无专门测试 |
| **C4** | `targets_page.dart` | 无专门测试（且是死路由，见 A1） |
| **C5** | `settings_page.dart` | 仅测「能进入」（`phase8_profile_test.dart:79`）—— 5 个空回调**没有任何测试会发现它们没接线** |
| **C6** | `membership_page.dart` | 仅测静态提示（`phase8b_profile_test.dart:217`）；额度卡四态 / 派生统计未测 |
| **C7** | `core/services/resume_file_picker.dart:39` | `DefaultResumeFilePicker`（**走平台通道**）无测试 —— 测试一律用 `_FakeResumeFilePicker` 替换 |

> ⚠️ C1 / C5 / C6 / C7 有一个共同点：**测试断言的是「页面在」，不是「功能在」**。
> 这类缺口不会让 `flutter test` 变红，只会让验收看起来比实际更绿。

---

### 4.7 📝 过期注释 —— **注释说的与代码做的不一致**

> 本次盘点**新发现的一类债**。`flutter analyze` 抓不到，只有人读才看得见。

| # | 位置 | 问题 |
|---|---|---|
| **P1** | `analysis_provider.dart:15` 仍写「分析引擎、JD 解析、匹配计算、**扣减额度**全部**未实现** —— Phase 6 才做」 | ❌ **已过时**。同一文件 `:96` 已实现 `consume()`、`:112` 已实现失败回滚、`:134` 已在退出分析时回滚。**注释落后于代码**，且落后的方向是「说得比实际少」 |
| **P2** | `api_client.dart:13` 把 `docs/careerly/BACKEND_API_CONTRACT.md`（**后端仓库**）当作端点与 envelope 的真值源 | 本仓库无副本、无版本锚点 → 即 **K18** |

> 📌 P1 与本文件 §3.1 多条目（只活在源码注释里的争议）是**同一种病的另一面**：
> 那边是「代码里有争议、文档里没有」；P1 是「文档（注释）里有结论、代码里已过期」。

---

### 4.8 维护规则

```text
✅ 台账条目必须带 file:行号 —— 没有证据的条目不进表
✅ 每次 Phase 交付后，只在对应组内增删，**不改别组的结论**
✅ 某条缺口开工前：先把它从 4.1 移到 §3.1（登记 D 编号）或 §1（排期）
✅ 某条被产品侧裁决为「不做」：移到 4.2，并写上依据的 D 编号
❌ 不在这里写排期、不写优先级、不写「建议做」—— 那是 §1 和产品侧的事
❌ 不把 Mock 空实现当缺陷修：Mock First 是既定做法，改它要么等真后端，要么另立 D（如 D105）
```

> ⚠️ **本节与 `CURRENT_STATUS.md` §3.6（暂定值登记表）不重叠**：
> 那张表查「哪些**数值**是暂定的」，本节查「哪些**功能**还没做」。

