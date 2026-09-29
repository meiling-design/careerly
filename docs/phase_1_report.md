# Careerly Phase 1 Report — Flutter Project Scaffold

> 项目：Careerly
> 阶段：Phase 1 — Flutter 工程基础架构
> 日期：2026-09-17
> 上游依据：`docs/07_Careerly_Development_Baseline_V1.0.md`（Phase 0 交付物，已锁定）
> 状态：**见文末 §22**

---

## 1. Environment

| 项 | 值 |
|---|---|
| Flutter | **3.44.0** · channel stable |
| Flutter revision | `559ffa3f75` |
| Dart | **3.12.0** |
| DevTools | 2.57.0 |
| Dart SDK 平台 | windows_x64 |
| 开发平台 | Windows 11 Home China 10.0.22631 |
| 目标平台 | Android（Android-first，依 CLAUDE.md / Baseline） |

### 设备情况（影响验收方式）

```text
flutter devices
├── Windows (desktop)  windows-x64
├── Chrome (web)       web-javascript
└── Edge (web)         web-javascript

❌ 无 Android 真机 / 模拟器在线
```

因此 Phase 1 的启动验收采用：

1. **`flutter analyze`** —— 0 issue
2. **`flutter test`** —— 10/10 通过（含 App Shell 启动 + 四个一级导航切换）
3. **`flutter build apk --debug`** —— 验证 Android 目标可编译

**未做**：Android 真机上的 SafeArea / 状态栏 / 导航栏 / 键盘 / 返回键实机校验。
这部分需要在有 Android 设备时补做，见 §21。

---

## 2. Project State

### 修改前

```text
lib/
└── main.dart            ← Flutter 默认 counter demo（MyApp / 'Flutter Demo'）

test/
└── widget_test.dart     ← 默认 counter 测试

pubspec.yaml
├── dependencies:  flutter, cupertino_icons ^1.0.8
├── dev_dependencies: flutter_test, flutter_lints ^6.0.0
└── 无 assets / fonts 段启用
```

### 修改后

```text
lib/                     56 个 Dart 文件
├── main.dart            仅启动，无产品逻辑
├── app/                 装配层（App / Router / Shell / Providers / AppState）
├── core/                常量 / 错误 / 扩展 / 状态基类 / 工具
├── design_system/       tokens / theme / components
├── data/                models / repositories / mock
└── features/            home / analysis / ai / profile

assets/
└── fonts/README.md      字体资源缺口说明（见 §6）

test/
└── widget_test.dart     Careerly 冒烟测试（10 个用例）
```

### 与 Phase 0 基准的一致性

- ✅ 目录结构与 Baseline §7.1 / Phase 1 §十 完全一致
- ✅ 分层 `UI → State → Repository → Data Source`（Baseline §7.2）
- ✅ 一级导航 4 个，无第 5 个（PRD §6 / IA §3.1）
- ✅ **未新增任何产品页面**（Phase 1 §二十三 / §二十四）

---

## 3. Final Project Structure

```text
lib/
├── main.dart                              仅 WidgetsFlutterBinding + runApp
│
├── app/
│   ├── app.dart                           CareerlyApp：MultiProvider → MaterialApp.router
│   ├── providers.dart                     依赖装配（唯一决定用哪个实现的地方）
│   ├── router/
│   │   ├── app_routes.dart                路由常量（/home /analysis /ai /profile）
│   │   ├── app_router.dart                GoRouter + StatefulShellRoute.indexedStack
│   │   └── page_transitions.dart          Careerly 自定义转场架构
│   ├── shell/
│   │   └── careerly_shell.dart            App Shell + 自绘导航接线
│   └── state/
│       └── app_provider.dart              App 级状态（刻意保持极小）
│
├── core/
│   ├── constants/app_constants.dart       全局常量（App 名 / 分值区间 / 免费额度 / 导航高度）
│   ├── errors/
│   │   ├── app_error.dart                 AppError + 6 个 sealed 子类
│   │   └── error_handler.dart             异常归一化 + guard()
│   ├── extensions/context_extensions.dart BuildContext 便捷读取
│   ├── state/
│   │   ├── async_state.dart               AsyncState<T>：Initial/Loading/Success/Failure
│   │   ├── async_state_notifier.dart      所有 Provider 的基类
│   │   └── state.dart                     barrel
│   └── utils/debouncer.dart               防抖（Phase 6 JD 输入用）
│
├── design_system/
│   ├── tokens/
│   │   ├── app_colors.dart                颜色 + Glass 材质 + 背景渐变
│   │   ├── app_typography.dart            Type Scale + Noto Sans SC 声明
│   │   ├── app_spacing.dart               间距 + 语义别名
│   │   ├── app_radius.dart                圆角
│   │   ├── app_shadows.dart               阴影
│   │   ├── app_motion.dart                六档时长 + 曲线 + 位移量
│   │   └── tokens.dart                    barrel
│   ├── theme/careerly_theme.dart          CareerlyTheme + 自定义 PageTransitionsBuilder
│   └── components/
│       ├── careerly_scaffold.dart         页面容器 + 轻量标题栏
│       ├── careerly_navigation_bar.dart   自绘底部导航（非 M3 NavigationBar）
│       ├── careerly_async_state_view.dart Loading/Empty/Error/Success 四态渲染
│       ├── careerly_placeholder_note.dart Phase 1 专用占位说明（Phase 2 起删除）
│       └── components.dart                barrel
│
├── data/
│   ├── models/
│   │   ├── quota_state.dart               QuotaState {total, used, remaining, canAnalyze}
│   │   ├── job.dart                       Job（独立可复用实体）
│   │   ├── analysis_result.dart           JobMatch + AnalysisResult（versioned）
│   │   ├── analysis_project.dart          AnalysisProject = Jobs + Results[]
│   │   ├── resume_profile.dart            ResumeVersion + ResumeProfile（职业基线）
│   │   ├── growth_event.dart              GrowthEvent + GrowthEventType
│   │   ├── home_summary.dart              HomeSummary + MatchChange（首页摘要）
│   │   └── models.dart                    barrel
│   ├── repositories/                      接口（abstract interface class）
│   │   ├── home_repository.dart
│   │   ├── analysis_repository.dart
│   │   ├── resume_repository.dart
│   │   ├── growth_repository.dart
│   │   └── repositories.dart              barrel
│   └── mock/                              Phase 1 全部绑定到这一层
│       ├── mock_config.dart               延迟 / 失败开关（用于验证四态）
│       ├── mock_home_repository.dart
│       ├── mock_analysis_repository.dart
│       ├── mock_resume_repository.dart
│       ├── mock_growth_repository.dart
│       └── mock.dart                      barrel
│
└── features/
    ├── home/
    │   ├── presentation/home_page.dart
    │   └── state/home_provider.dart
    ├── analysis/
    │   ├── presentation/analysis_page.dart
    │   └── state/analysis_provider.dart
    ├── ai/
    │   └── presentation/ai_page.dart      刻意没有 Provider（见 §11）
    └── profile/
        ├── presentation/profile_page.dart
        └── state/
            ├── resume_provider.dart
            └── growth_provider.dart
```

---

## 4. Dependencies Added / Removed

### 新增（Phase 1 §二十一：明确必要 + 当前阶段实际使用）

| Package | 版本 | Purpose | 为什么现在就需要 |
|---|---|---|---|
| `go_router` | `^17.0.0` | 路由 | Phase 1 §十三 / §十四要求建立 Router 与 App Shell。Shell 使用 `StatefulShellRoute.indexedStack`，这是 go_router 独有的能力，Provider 无法替代。工程规范 §05 已指定 |
| `provider` | `^6.1.5+1` | 状态管理 | Phase 1 §十六要求建立 State Management Foundation。工程规范 §08 已指定 Provider + ChangeNotifier |

### 未新增（明确决定不装）

| Package | 为什么没装 |
|---|---|
| `http` / `dio` | Phase 1 §八禁止真实 Backend API。`ApiClient` 留到接入后端时再建 |
| `shared_preferences` / `hive` | Phase 1 无本地持久化需求 |
| `flutter_localizations` | 无 Material 内建组件的中文标签需求。见 §18 |
| `meta` | 已改用 `package:flutter/foundation.dart` 的 re-export，避免为 `@immutable` 单独加依赖 |
| `freezed` / `json_serializable` | 模型手写 `fromJson/toJson`，避免引入 build_runner 工具链 |

### 移除

无。仅 `pubspec.yaml` 的 `description` 从 `"A new Flutter project."` 改为 Careerly 描述。

### ⚠️ 依赖降级说明（重要）

初次执行 `flutter pub add go_router` 解析到 **18.0.1**，它连带引入了
`material_ui 1.3.0` 与 `cupertino_ui 1.1.0`。

这两个包使用 `@awaitNotRequired` 注解，该注解需要 **meta ≥ 1.19**，
而当前 Flutter SDK 把 `meta` 锁死在 **1.18.0**，导致：

```text
Error: Undefined name 'awaitNotRequired'.
  .../material_ui-1.3.0/lib/src/date_picker.dart:224:2
```

`flutter test` 与 `flutter build apk` 均编译失败（`flutter analyze` 不报，因为它不编译包源码）。

**处理**：将 `go_router` 约束为 `^17.0.0`（解析到 17.0.0），
`material_ui` / `cupertino_ui` / `intl` / `flutter_localizations` 全部退出依赖树。
已在 `pubspec.yaml` 中写明原因，待 Flutter SDK 放开 meta 约束后再评估升级。

---

## 5. Design System

### Tokens（`lib/design_system/tokens/`）

真值来源：**`docs/Careerly App Interface Design (Copy)/src/App.tsx` 的 `S` 对象**
（Baseline §6.1：不取自 V1.0 的 `careerly-design-system.md`）。

| Token | 内容 |
|---|---|
| `AppColors` | 品牌蓝 `#4F7EF5` / 品牌紫 `#A77BE6` / 背景渐变三段 `#DCE9FB → #E5DCFA → #FBE9F1` / 中性结构色 / 语义色 / Glass 材质 |
| `AppTypography` | 10 个角色 + `asTextTheme()` 映射 |
| `AppSpacing` | 4→48 八档 + 语义别名 + `pageInsets` / `cardInsets` |
| `AppRadius` | 12→28 六档 + `pill`，含 `card` / `button` / `sheet` 别名 |
| `AppShadows` | 8 组，取自 Figma 的 `glass` / `glassLight` / 按钮 / 导航栏投影 |
| `AppMotion` | 六档时长 + fast/normal/slow 别名 + 6 条曲线 + 4 个位移量 |

### 背景渐变的 CSS → Flutter 换算

```text
CSS: linear-gradient(128.67deg, rgb(220,233,251) 7.74%,
                     rgb(229,220,250) 45.77%, rgb(251,233,241) 92.27%)

CSS 角度 → 屏幕坐标方向向量 (sin θ, -cos θ) = (0.781, 0.625)   // 向右下
Flutter: begin = Alignment(-0.78, -0.63), end = Alignment(0.78, 0.63)
         stops = [0.0774, 0.4577, 0.9227]
```

### Type Scale 重新归纳（Baseline §6.2）

Figma Make 使用了 15 个非标字号（9/10/11/12/13/14/15/17/18/22/24/28/30/40）。
Flutter 侧**未 1:1 抄原型**，收敛为：

| 角色 | 字号 / 字重 | 用途 |
|---|---|---|
| `display` | 40 / w700 | Onboarding 主标题、重大结果页 |
| `headline` | 28 / w700 | 页面主标题 |
| `title` | 22 / w700 | 区块 / 卡片主标题 |
| `subtitle` | 18 / w600 | 次级标题 |
| `body` | 15 / w400 | 正文 |
| `bodyStrong` | 15 / w600 | 正文加强 |
| `bodySmall` | 13 / w400 | 辅助正文 |
| `label` | 13 / w600 | 按钮 / Chip / 导航文字 |
| `caption` | 11 / w400 | 时间戳 / 脚注 |
| `numeric` | 32 / w700 + tabular | 匹配度分数 |
| `numericSmall` | 20 / w700 + tabular | 列表行内分数 |

`numeric` / `numericSmall` 启用 `FontFeature.tabularFigures()`，
保证数字在列表与动画中不跳动。

### 组件（Phase 1 只建 App Shell 必需的 3 个）

| 组件 | 职责 |
|---|---|
| `CareerlyScaffold` | 页面容器：内边距 / SafeArea / 轻量标题栏（透明背景，渐变由根节点绘制） |
| `CareerlyNavigationBar` | 自绘底部导航。**不使用 M3 `NavigationBar`**（Baseline §6.5 / 决策 9） |
| `CareerlyAsyncStateView<T>` | 把 `AsyncState` 渲染成 Loading / Empty / Error / Success |
| `CareerlyPlaceholderNote` | ⚠️ Phase 1 专用占位说明，Phase 2 起逐页删除 |

`GlassSurface` / `CareerlyButton` / `CareerlyCard` / `CareerlyChip` /
`CareerlyProgress` / `CareerlyBottomSheet` / `CareerlyToast`
按 Baseline §7.5 属于 **Phase 2**，本阶段未建。

---

## 6. Typography

### 决策落实（Phase 0 O1 / Phase 1 §二）

| 要求 | 落实位置 |
|---|---|
| 中文 UI 统一使用 Noto Sans SC | `AppTypography.fontFamilyChinese = 'Noto Sans SC'` |
| 进入 Flutter Typography Token | `AppTypography.fontFamily` + 全部角色 |
| Theme 中明确声明 | `CareerlyTheme.light()` → `fontFamily: AppTypography.fontFamily` |
| 不使用其他中文字体替代 | **代码中零处出现其他中文字体族名** |
| 不自行下载字体 | **未下载任何字体文件** |
| 英文 / 数字字体 Phase 2 再定 | `AppTypography.fontFamilyNumeric = null`（当前沿用中文字体族） |
| Logo 独立 Brand Asset | 未纳入 Typography Token |

### ⚠️ 字体资源缺口（§11.2 的处理结果）

```text
项目内 .ttf / .otf 文件数量：0
assets/ 目录：Phase 1 之前不存在
```

按 Phase 1 §11.2 的五步处理：

1. ✅ 建立 Typography Token（`app_typography.dart`）
2. ✅ 在 Token / Theme 中明确声明 Noto Sans SC
3. ✅ 记录字体资源缺口 —— `assets/fonts/README.md` + 本节
4. ✅ 未用其他中文字体偷偷替代产品决策
5. ✅ 在 Phase 1 Report 中明确说明（即本节）

**Phase 1 没有把 `fonts:` 段写入 `pubspec.yaml`**，因为声明一个没有 asset 的字体族会让 `pub get` 直接失败。
补齐方式（含可直接复制的 pubspec 片段）见 `assets/fonts/README.md`，
补齐后**不需要改任何 Dart 代码**。

### 当前运行时的实际情况

Theme 中 `fontFamily` 已是 `'Noto Sans SC'`。由于系统通常未注册该字体族，
Android 会**由平台回退**渲染中文。

> 这是**运行时的回退行为**，不是本项目的字体选择。
> 代码层面 100% 遵守了「中文 UI 走 Noto Sans SC」这条硬规则，
> 缺口只在**字体文件**，不在代码。

**因此 §26「Typography 验收」当前无法在视觉上完全确认**，见 §21。

---

## 7. Theme

`lib/design_system/theme/careerly_theme.dart`

### 设计立场（Phase 1 §十二）

> Material 3 可以作为 Flutter 的基础能力使用，
> **但 Careerly 的视觉系统不能被 Material 3 默认样式主导。**

因此：

- ✅ `useMaterial3: true` —— 保留 M3 的能力
- ❌ **不使用 `ColorScheme.fromSeed`** —— 种子算法会派生出一整套与 Figma 不符的色阶。
  改为显式构造以 Careerly 品牌色为准的 `ColorScheme`
- ✅ 显式覆盖所有 Careerly 会实际用到的组件主题

### 覆盖的组件主题

```text
AppBarTheme              transparent / elevation 0 / 用 AppTypography.title
CardThemeData            glassFill / 圆角用 AppRadius.card / elevation 0
ChipThemeData            pill 形状 / 选中态 surfaceDark
ElevatedButtonThemeData  品牌蓝 / pill / 无 elevation
OutlinedButtonThemeData  glassBorder 描边
TextButtonThemeData      品牌蓝文字
InputDecorationTheme     glassFillLight 填充 / 聚焦态品牌蓝描边
BottomSheetThemeData     顶部 AppRadius.sheet 圆角 / 显示 drag handle
DialogThemeData          AppRadius.xl
ProgressIndicatorTheme   品牌蓝
SnackBarThemeData        surfaceDark / floating
DividerTheme             AppColors.divider
IconTheme                textPrimary / 22
```

另外：

- `scaffoldBackgroundColor: Colors.transparent` —— 让根节点的背景渐变透出来
- `splashFactory: NoSplash.splashFactory` —— 不要 Material 水波纹，反馈由 `AppMotion` 控制
- `pageTransitionsTheme` —— 使用 Careerly 自定义转场，**不用 M3 默认转场**（Baseline §6.6）

---

## 8. Router

`lib/app/router/app_router.dart` / `app_routes.dart` / `page_transitions.dart`

### 结构（Phase 1 §十三）

```text
GoRouter(initialLocation: '/home')
└── StatefulShellRoute.indexedStack
    ├── /home       首页      name: home
    ├── /analysis   分析      name: analysis
    ├── /ai         AI        name: ai
    └── /profile    我的      name: profile
```

- 一级导航**只有 4 个**，路由层不做任何产品页面的扩展
- 使用 `StatefulShellRoute.indexedStack`：
  每个一级导航是独立的 `StatefulShellBranch`，用 `IndexedStack` 保持页面状态
  （用户在「分析」粘贴了一半的 JD，切到「我的」再切回来不会丢）
- 有 `errorBuilder` 兜底（开发期输错路径不会白屏）

### 刻意**没有**建立的 route（及依据）

| 未建立的 route | 依据 |
|---|---|
| `/onboarding/*` | Phase 4 建立。Onboarding 流程已锁定（Baseline §4.1） |
| 分析准备页 / 分析确认页 | `careerly-analysis-structure.md` §38 明确禁止 |
| 分析中 / 分析结果 | IA §18：**页面状态**，不是独立页面 |
| 更新分析 | IA §18：不作为独立页面 |
| 版本对比 / 历史版本页 | IA §18 + Phase 1 §四（O3）：**Bottom Sheet / 局部状态** |
| 成长日历 / 成长时间线 | Phase 1 §三（O2）：属于成长足迹 Detail 内部 |
| `/settings` | Phase 8 建立，且只有「我的」右上角 ⚙ 一个入口 |

### 转场架构（Baseline §6.6）

`CareerlyPageTransitions` 提供：

| 方法 | 用途 | 时长 |
|---|---|---|
| `slide` | 二级页面进入：右侧轻微进入 + 淡入 | `AppMotion.pageTransition`（280ms，在 240–320 区间内） |
| `fadeUp` | 一级导航切换 / Progressive Flow：淡入 + 轻微上移 | `AppMotion.pageTransition` |

反向自动镜像（`Curve.flipped`），不会出现「瞬移」或整页重新淡入。

---

## 9. App Shell

`lib/app/app.dart` + `lib/app/shell/careerly_shell.dart`

### 装配链

```text
main()
└── CareerlyApp
    └── MultiProvider                       依赖注入（Repository / Router / State）
        └── MaterialApp.router
            ├── theme: CareerlyTheme.light()
            ├── builder → DecoratedBox(背景渐变)   ← 渐变只在这里绘制一次
            └── GoRouter → CareerlyShell
                ├── body: navigationShell        内容区
                └── bottomNavigationBar: SafeArea(CareerlyNavigationBar)
```

### 背景渐变为什么画在根节点

`CareerlyScaffold` 同时用于 Shell 内（上方状态栏、下方导航栏）与 Shell 外（全屏页）。
若两边各画一次，同一个渐变会被按不同尺寸拉伸两次，
**在导航栏上沿出现可见色带**。

因此：根节点画一次，所有页面 `Scaffold` 保持透明，渐变从最底层透上来。

### 已支持的能力（Phase 1 §十四）

| 要求 | 实现 |
|---|---|
| SafeArea | 内容区 `SafeArea`（`CareerlyScaffold`）+ 导航栏独立 `SafeArea(top: false)` |
| Content area | `navigationShell` 作为 `Scaffold.body` |
| Custom Bottom Navigation | `CareerlyNavigationBar`（自绘） |
| 当前 Tab 状态 | `navigationShell.currentIndex` |
| Tab 切换 | `navigationShell.goBranch()` —— 保留分支导航栈 |
| Android Back 基础行为 | go_router 默认：分支内先 pop 二级页 → 分支根 pop → 退出 App。见 §18 |
| 页面 Transition Architecture | `CareerlyPageTransitions`（§8） |

---

## 10. Careerly Navigation

`lib/design_system/components/careerly_navigation_bar.dart`

### 为什么不使用 Material 3 `NavigationBar`

Baseline §6.5 / 决策 9：

> 自绘 Careerly Navigation，**不使用 M3 `NavigationBar`**。

原因是 M3 `NavigationBar` 无法满足 Careerly 的视觉要求：
Liquid Glass 材质、选中态流动 morph、自定义图标、AI 特殊入口。

### Phase 1 结构

```text
CareerlyNavigationBar
├── 首页   标准 Tab（图标 + 文字，选中态品牌蓝）
├── 分析   标准 Tab
├── AI     特殊入口 isSpecial = true → 品牌渐变圆形，无文字标签
└── 我的   标准 Tab
```

已实现：

- ✅ 4 个位置，AI 走 `CareerlyNavDestination.isSpecial` 特殊渲染
- ✅ 选中态（图标 / 文字颜色切换，走 `AppMotion.micro`）
- ✅ 按压缩放 `scale(0.96)`（`AppMotion.pressScale` + `AppMotion.button`）
- ✅ 所有尺寸 / 颜色 / 动效来自 Token，**零硬编码**
- ✅ `Semantics(button, selected, label)` 可访问性

Phase 2 / Phase 3 补：

- ❌ Glass 模糊（`BackdropFilter`）—— Phase 2 `GlassSurface`
- ❌ 选中态流动 morph —— 曲线已备好（`AppMotion.emphasized`），Phase 3 实现
- ❌ 自定义图标 —— 当前用 Material 图标占位（Figma 是自绘图标）
- ❌ AI 浮起球超出导航栏上沿的最终形态

### ⚠️ 与 Baseline 的一处描述差异（已按兼容方式实现）

| 来源 | 描述 |
|---|---|
| Baseline §6.5 / 决策 9 | 「3 Tab + AI 浮起球」 |
| Phase 1 §十四 / §十五 | 结构上 4 个位置，且「AI 特殊入口」 |
| Phase 1 §十五 | 「Phase 1 只完成基础结构」 |

**处理**：按 **4 个位置 + AI 特殊渲染** 实现。
两种描述都被满足，Phase 3 只需替换视觉，**不需要改结构**。
已在此记录，未擅自改动产品决策。

---

## 11. State Management

### 分层（Phase 1 §十六）

```text
UI (Page)
 ↓ context.watch / read
State (ChangeNotifier)      ← AsyncStateNotifier<T> 基类
 ↓
Repository (抽象接口)
 ↓
Data Source (当前 = Mock)
```

**页面不得直接访问 API，也不得直接 new Repository。**

### 基础设施

| 类 | 位置 | 职责 |
|---|---|---|
| `AsyncState<T>` | `core/state/async_state.dart` | sealed：`AsyncInitial` / `AsyncLoading(progress, message)` / `AsyncSuccess(data)` / `AsyncFailure(error)` |
| `AsyncStateNotifier<T>` | `core/state/async_state_notifier.dart` | 所有 Provider 的基类：`execute()` / `setLoading()` / `setSuccess()` / `setFailure()`，自动 try-catch + `notifyListeners` |
| `ErrorHandler.guard()` | `core/errors/error_handler.dart` | 把任意异常归一化为 `AppError` |

**Empty 被建模为 Success 的子情况**（`data` 为空集合），而不是独立状态——
因为「空」永远是某个成功请求的结果。UI 通过
`CareerlyAsyncStateView(isEmpty: ...)` 决定是否渲染 Empty State。

### 已建立的 Provider

| Provider | 数据源 | 职责 |
|---|---|---|
| `AppProvider` | — | App 级状态（bootstrap 就绪）。**刻意保持极小** |
| `HomeProvider` | `HomeRepository` | 首页摘要 |
| `AnalysisProvider` | `AnalysisRepository` | 历史分析项目 + 额度门禁 `canAnalyze` |
| `ResumeProvider` | `ResumeRepository` | 简历 / 职业基线 |
| `GrowthProvider` | `GrowthRepository` | 成长足迹 |

### 刻意**没有**建立的 Provider

| Provider | 为什么没建 |
|---|---|
| `AuthProvider` | Phase 1 无鉴权数据源。随 Phase 4（Onboarding）建立 |
| `CareerProvider` | Phase 1 无职业资产数据源。随 Phase 8（我的）建立 |
| `AIProvider` | **Phase 1 不建立空 Provider——那只会是死代码**。随 Phase 7 建立 |

Baseline §7.3 的六 Provider 命名会在对应阶段逐一落地，
但 Phase 1 不为了「凑齐名单」而写空壳。

---

## 12. Repository Layer

`lib/data/repositories/` —— 全部是 `abstract interface class`。

| 接口 | 方法 | 归属依据 |
|---|---|---|
| `HomeRepository` | `fetchSummary()` | Baseline §3.1：首页只拿摘要 |
| `AnalysisRepository` | `fetchProjects()` / `fetchProject(id)` / `fetchJobLibrary()` / `fetchQuota()` | Baseline §3.2：分析项目只属于「分析」 |
| `ResumeRepository` | `fetchProfile()` / `fetchVersions()` / `setCurrentVersion(id)` | PRD §14：简历属于职业资产 |
| `GrowthRepository` | `fetchEvents({type})` / `fetchTimeline({from, to})` | Phase 1 §三（O2）：成长足迹 Detail 内部 |

**Provider 依赖抽象接口，不依赖 Mock 实现**——
接入真实后端时只改 `lib/app/providers.dart` 一个文件。

### 数据模型（Baseline §7.4 的扩展要求）

Baseline §7.4 指出 Flutter Spec §20 的
`AnalysisSession { ResumeVersion, Jobs[] }` **不足以表达已确认的产品规则**
（「更新分析不是覆盖，旧结果保留」），要求扩展为：

| 模型 | 是否已建 | 说明 |
|---|---|---|
| `Job` | ✅ | 独立可复用实体。删除不删历史记录（PRD §9.7） |
| `AnalysisProject` | ✅ | `Jobs[]` + `Results[]`，一对多容器 |
| `AnalysisResult` | ✅ | **versioned**，记录 `resumeVersionId` + `capabilitySnapshot` |

另外补齐：`JobMatch`（含 `score` 0–100 / `rank` / `strengths` / `gaps` / `reasons` / `suggestion`）、
`QuotaState`、`ResumeVersion`、`ResumeProfile`、`GrowthEvent`、`HomeSummary`。

全部手写 `fromJson` / `toJson` / `copyWith`，未引入 codegen 工具链。

---

## 13. Mock Data Layer

`lib/data/mock/` —— Phase 1 §十八「Mock First」。

| Mock | 默认返回 | 理由 |
|---|---|---|
| `MockHomeRepository` | `HomeSummary.empty` | 首页走 Empty State |
| `MockAnalysisRepository` | `[]` 项目 / `[]` 岗位；`QuotaState.free` | 额度返回 **3 次** —— 这是 Baseline §5 已锁定的产品规则，不是编造的数据 |
| `MockResumeRepository` | `ResumeProfile.empty` / `[]` | 相当于「尚未上传简历」的新用户 |
| `MockGrowthRepository` | `[]` | 成长足迹走 Empty State |

### 刻意不编造产品数据

Mock **没有**编造「匹配度 86%」「Alex Chen」「某公司高级工程师」这类
看起来像真实产品的数据。Phase 1 不产生业务数据，也不预设产品文案。
真实 Mock 数据在 Phase 5（首页）随 UI 一起补齐。

### `MockConfig` —— 让四态可被真实验证

```dart
MockConfig { latency: 600ms, failNext: false, throwError: null }
```

默认 600ms 延迟的意义是：**否则 Mock 立即返回，
UI 的 Loading 分支永远不会被走到**。
`failNext: true` 可人工验证 Error State。

---

## 14. Error Infrastructure

`lib/core/errors/app_error.dart`

```dart
sealed class AppError implements Exception
├── NetworkError   网络失败 / 超时      → 可重试
├── ParseError     简历 / JD 解析失败    → 可重试（PRD §15：不计入分析次数）
├── AIError        LLM 调用失败          → 可重试
├── QuotaError     额度耗尽              → 不可重试，引导升级会员（PRD §16）
├── AuthError      登录态失效            → 不可重试，引导重新登录
└── UnknownError   未归类                → 可重试
```

`AppError` 带 `message`（面向用户，中文）、`detail`（面向日志）、
`cause` / `stackTrace`（原始异常）、`isRetryable`（UI 据此决定是否显示重试按钮）。

`ErrorHandler.normalize()` 会把 `SocketException` / `TimeoutException` /
`FormatException` 等自动归类；`ErrorHandler.guard()` 让业务层不必写 try/catch。

### 四态支持

| 状态 | 承载 |
|---|---|
| Loading | `AsyncLoading`（含 `progress` / `message`，支持分析流程的确定性进度） |
| Success | `AsyncSuccess` |
| Empty | `AsyncSuccess` + `isEmpty` 判定 |
| Error | `AsyncFailure(AppError)` |

`CareerlyAsyncStateView` 把这四态收敛成一次渲染调用。

---

## 15. Motion Infrastructure

`lib/design_system/tokens/app_motion.dart`

### 六档时长（motion-spec §27，Baseline §6.4）

| 档位 | Token | 值 | 规格区间 |
|---|---|---|---|
| Micro Interaction | `AppMotion.micro` | 100ms | 80–120 ✅ |
| Button Feedback | `AppMotion.button` | 160ms | 120–200 ✅ |
| Small Component | `AppMotion.smallComponent` | 210ms | 180–240 ✅ |
| Page Transition | `AppMotion.pageTransition` | 280ms | 240–320 ✅ |
| Modal / Sheet | `AppMotion.sheet` | 350ms | 300–400 ✅ |
| Major Result Reveal | `AppMotion.reveal` | 550ms | 400–700 ✅ |

（测试 `Design Tokens AppMotion 六档时长满足 motion-spec §27 区间` 断言了这 6 条区间）

### 语义别名（Phase 1 §二十要求预留 fast / normal / slow）

```text
fast   = micro   (100ms)
normal = smallComponent (210ms)
slow   = reveal  (550ms)
```

另外预留：`cardReorder`（300ms，IA §12 的 250–350ms）、`stagger`（40ms）。

### 曲线

| Token | 原值 | 用途 |
|---|---|---|
| `standard` | `cubic-bezier(0.25, 0.46, 0.45, 0.94)` | 通用状态变化 |
| `emphasized` | `cubic-bezier(0.34, 1.2, 0.64, 1)` | 底部导航选中态流动 |
| `enter` / `exit` | `easeOutCubic` / `easeInCubic` | 元素进出 |
| `pageCurve` | `easeOutCubic` | 页面转场 |
| `cardCurve` | `easeInOutCubic` | 卡片重排 |

### 位移量

```text
pageSlideOffset    20.0   // 二级页面进入，规格 16–24px
tabContentOffset   10.0   // 一级导航切换上移
pressScale          0.96  // 按压缩放
stateContentOffset 12.0   // 空 / 错误状态出现
```

---

## 16. Files Created

**56 个文件**（55 个新文件 + `lib/main.dart` 重写）

```text
lib/main.dart                                        ← 重写（原为 counter demo）
lib/app/app.dart
lib/app/providers.dart
lib/app/router/app_routes.dart
lib/app/router/app_router.dart
lib/app/router/page_transitions.dart
lib/app/shell/careerly_shell.dart
lib/app/state/app_provider.dart
lib/core/constants/app_constants.dart
lib/core/errors/app_error.dart
lib/core/errors/error_handler.dart
lib/core/extensions/context_extensions.dart
lib/core/state/async_state.dart
lib/core/state/async_state_notifier.dart
lib/core/state/state.dart
lib/core/utils/debouncer.dart
lib/data/models/analysis_project.dart
lib/data/models/analysis_result.dart
lib/data/models/growth_event.dart
lib/data/models/home_summary.dart
lib/data/models/job.dart
lib/data/models/models.dart
lib/data/models/quota_state.dart
lib/data/models/resume_profile.dart
lib/data/repositories/analysis_repository.dart
lib/data/repositories/growth_repository.dart
lib/data/repositories/home_repository.dart
lib/data/repositories/repositories.dart
lib/data/repositories/resume_repository.dart
lib/data/mock/mock.dart
lib/data/mock/mock_config.dart
lib/data/mock/mock_analysis_repository.dart
lib/data/mock/mock_growth_repository.dart
lib/data/mock/mock_home_repository.dart
lib/data/mock/mock_resume_repository.dart
lib/design_system/tokens/app_colors.dart
lib/design_system/tokens/app_typography.dart
lib/design_system/tokens/app_spacing.dart
lib/design_system/tokens/app_radius.dart
lib/design_system/tokens/app_shadows.dart
lib/design_system/tokens/app_motion.dart
lib/design_system/tokens/tokens.dart
lib/design_system/theme/careerly_theme.dart
lib/design_system/components/careerly_scaffold.dart
lib/design_system/components/careerly_navigation_bar.dart
lib/design_system/components/careerly_async_state_view.dart
lib/design_system/components/careerly_placeholder_note.dart
lib/design_system/components/components.dart
lib/features/home/presentation/home_page.dart
lib/features/home/state/home_provider.dart
lib/features/analysis/presentation/analysis_page.dart
lib/features/analysis/state/analysis_provider.dart
lib/features/ai/presentation/ai_page.dart
lib/features/profile/presentation/profile_page.dart
lib/features/profile/state/resume_provider.dart
lib/features/profile/state/growth_provider.dart
```

另有 **1 个非 Dart 文件**：

```text
assets/fonts/README.md      ← 字体资源缺口说明 + 补齐方式
```

---

## 17. Files Modified

| 文件 | 改动 |
|---|---|
| `lib/main.dart` | 从 Flutter 默认 counter demo 改为 Careerly 启动入口（`CareerlyApp`） |
| `pubspec.yaml` | `description` 改为 Careerly 描述；新增 `go_router: ^17.0.0`、`provider: ^6.1.5+1`（含降级原因注释） |
| `test/widget_test.dart` | 从默认 counter 测试改为 Careerly 冒烟测试（10 个用例） |
| `pubspec.lock` | 依赖解析结果 |

**未改动**：`analysis_options.yaml`、`android/**`、`ios/**`、`web/**`、
`windows/**`、`linux/**`、`macos/**`、所有 `docs/**`。

---

## 18. Potential Issues

### P1 —【字体资源缺口】Noto Sans SC 字体文件缺失 · 阻塞视觉验收

见 §6。代码层面已 100% 遵守硬规则，缺口只在资产文件。
在字体补齐前，**中文渲染由 Android 平台回退决定**，
因此「中文 UI 是否真的走了 Noto Sans SC」**无法在当前状态下视觉确认**。

> 按 Phase 1 §11.2，**未自行下载、未用其他中文字体替代**。

### P2 —【依赖约束】go_router 被锁在 17.x

见 §4。18.x 会引入 `material_ui` / `cupertino_ui`，
在 meta 被 SDK 锁死在 1.18.0 的环境下**直接编译失败**。
已在 `pubspec.yaml` 写明原因。

### P3 —【视觉差异】底部导航与 Baseline 的描述不同源

见 §10。Baseline 写「3 Tab + AI 浮起球」，Phase 1 §十四 画的是 4 个位置。
**已按兼容方式实现（4 位置 + AI 特殊渲染）**，未擅自改动产品决策，**提请确认**。

### P4 —【Phase 1 缺口】AI 浮起球的最终形态未做

当前 AI 入口是**嵌在导航栏内**的 46×46 渐变圆形。
Figma `BottomNav` 里是 62×62、**浮在导航栏之上**的球体。
Phase 1 §十五 明确「只完成基础结构，暂时不需要制作最终视觉效果」，
故留到 Phase 2 / Phase 3。

### P5 —【技术差异】Figma 的 inset 阴影在 Flutter 无法直接实现

Figma `BottomNav` 的 Glass 使用了 **6 层 `inset box-shadow`**。
Flutter 的 `BoxShadow` **不支持 inset**。

按 Baseline §1.2「Figma 有视觉效果但 Flutter 没有对应实现方式 → **重新实现，而不是放弃视觉**」，
该高光需在 Phase 2 的 `GlassSurface` 中用
`BackdropFilter` + 渐变描边重新实现。已在 `app_shadows.dart` 中注释说明。

### P6 —【技术差异】未引入 `flutter_localizations`

`MaterialApp` 未配置 `supportedLocales` / 本地化 delegate。
Careerly 自己的中文文案不受影响，但 **Material 内建组件**
（日期选择器、长按文本菜单等）的标签仍是英文。

当前无内建组件，不影响 Phase 1。**Phase 2 引入 `CareerlyBottomSheet` /
日期类组件前需要补上。**

### P7 —【Android 配置】applicationId 仍是 `com.example.careerly`

`android/app/build.gradle.kts`：`namespace` 与 `applicationId` 均为 `com.example.careerly`，
release 仍使用 debug 签名。

**Phase 1 未修改**——这属于发布决策，不在 Phase 1 范围内。**发版前必须处理。**

### P8 —【Android Back】采用 go_router 默认行为

```text
分支内有二级页面  →  先 pop 二级页面
分支根页面        →  退出 App
```

「在非首个 Tab 按返回先回到首页」是更常见的 Android 体验，
但实现它需要在 Shell 层加 `PopScope`，而这会**连带阻断分支内二级页面的 pop**，
需要更仔细的处理（Baseline §8 把「Android back」明确列在 **Phase 3** 的验证项里）。

Phase 1 **不引入这个有风险的改动**，保持 go_router 默认行为并记录在此。

### P9 —【验证方式】无 Android 设备，未做实机校验

见 §1。SafeArea / 状态栏 / 导航栏 / 键盘 / 返回键 / 小屏
**均未在真机上验证**。

### P10 —【临时产物】`CareerlyPlaceholderNote`

Phase 1 专用的占位说明组件。
**Phase 2 起必须随各页面的真实 UI 落地而逐页删除**，不应留在最终代码里。

### P11 —【非阻塞】仓库尚未纳入 Git

`git status` → `fatal: not a git repository`。
Baseline / 工程规范建议 `feat/*` 分支 + 小步提交，
Phase 1 的 brief 未要求建仓，故未执行。

### P12 —【未决】Phase 0 开放项 O4 / O5 / O6 / O7 仍未裁决

均**不阻塞 Phase 1**，但会在后续阶段变成阻塞：

| # | 开放项 | 阻塞 |
|---|---|---|
| O4 | Careerly Pro 入口是否保留在「我的」首页 | Phase 8 |
| O5 | Pro 的额度语义（无限 / 每月 N 次）—— 影响 `QuotaState` 模型 | Phase 9 |
| O6 | Settings 是否含「关联职业上下文」开关 | Phase 8（低风险） |
| O7 | IA Level 3 缺口（Membership 未登记 / 历史岗位详情无对应页） | Phase 8 |

---

## 19. Phase 0 Decisions Applied

### O1 — Typography：中文使用 Noto Sans SC ✅

| 落实项 | 位置 |
|---|---|
| Token 声明 | `AppTypography.fontFamilyChinese = 'Noto Sans SC'` |
| 全部角色继承 | `display` / `headline` / `title` / `subtitle` / `body` / `bodyStrong` / `bodySmall` / `label` / `caption` / `numeric` |
| Theme 声明 | `CareerlyTheme.light()` → `fontFamily` |
| 英文 / 数字延后 | `fontFamilyNumeric = null`（Phase 2 定） |
| Logo 不入 Token | 未纳入 |
| 未下载字体 / 未替换字体 | ✅ |
| 缺口已记录 | `assets/fonts/README.md` + §6 + §18 P1 |

### O2 — Growth Calendar：属于成长足迹 Detail ✅

| 禁止项 | 是否遵守 |
|---|---|
| ❌ 不增加第四张 Card | ✅「我的」占位页只列 职业资产 / 成长足迹 / 我的简历 三项 |
| ❌ 不增加一级导航 | ✅ Router 只有 4 条一级 route |
| ❌ 不创建独立 Growth Calendar Page | ✅ `features/` 下无 growth 页面目录；`GrowthProvider` 注释明确说明它服务于 Detail 内部 |

### O3 — History Version：Bottom Sheet / 局部状态 ✅

| 禁止项 | 是否遵守 |
|---|---|
| ❌ 不创建 `HistoryVersionPage` | ✅ `features/analysis/` 下只有 `analysis_page.dart` |
| ❌ 不创建 `VersionComparePage` | ✅ 同上 |

分析页占位说明中明确写出：「历史版本：Bottom Sheet 局部状态，不是独立页面」。

### 其他 Phase 0 决策

| 决策 | 落实情况 |
|---|---|
| 决策 3：历史分析只归「分析」 | ✅「我的」占位页明确标注「❌ 无历史分析入口」；`AnalysisRepository` 注释写明归属 |
| 决策 4：点击「开始分析」时扣减额度 | ✅ `QuotaState.consume()` 文档写明「仅在真正开始 AI 分析时调用」；`AnalysisProvider` 注释写明 |
| 决策 8：Visual Token 以 Figma Make 实际视觉为准 | ✅ 全部颜色 / 阴影 / 圆角取自 `App.tsx` 的 `S` 对象 |
| 决策 9：自绘导航 + 自定义转场 | ✅ `CareerlyNavigationBar` + `CareerlyPageTransitions` |
| Baseline §5：上传简历 / 粘贴 JD / 进入分析页不扣额度 | ✅ 写在 `QuotaState` / `AnalysisProvider` / `MockAnalysisRepository` 三处文档 |
| Baseline §5：失败回滚额度 | ✅ `QuotaState.rollback()` |
| PRD §12 / IA §16：设置只有齿轮一个入口 | ✅「我的」占位页只有右上角 ⚙，无设置 Tab、无设置卡片 |
| PRD §9.4：匹配度只由能力匹配计算 | ✅ `JobMatch.score` 文档写明「薪资 / 通勤 / 城市不得进入该分值」 |

---

## 20. Phase 1 Acceptance Checklist

### 验收标准（Phase 1 §二十五）

| # | 验收项 | 结果 | 证据 |
|---|---|---|---|
| 1 | `flutter run` 能够正常启动 | ⚠️ **部分** | 无 Android 设备在线。已用 `flutter build apk --debug` 构建成功 + 10 个 Widget 测试替代，见下方「验证方式」 |
| 2 | 启动后可以看到 Careerly App Shell | ✅ | 测试 `启动后展示 Careerly Shell 与四个一级导航` |
| 3 | 能够切换 首页 / 分析 / AI / 我的 | ✅ | 4 个切换测试全部通过 |
| 4 | SafeArea | ⚠️ 代码就位，**未实机验证** | `CareerlyScaffold` + 导航栏独立 `SafeArea` |
| 5 | Tab State（切换不丢状态） | ✅ | `StatefulShellRoute.indexedStack`；测试 `可以切换到「分析」，并保留分支状态` |
| 6 | Android Back | ⚠️ go_router 默认行为，**未实机验证** | 见 §18 P8 |
| 7 | Theme | ✅ | `CareerlyTheme.light()` 接入 `MaterialApp.router` |
| 8 | Typography | ⚠️ 代码就位，**视觉未验证** | 见 §6 / §18 P1 |

### 基础设施存在性

| # | 要求 | 结果 |
|---|---|---|
| 9 | Design Token | ✅ 6 个 Token 类 + barrel |
| 10 | Theme | ✅ `CareerlyTheme` |
| 11 | Router | ✅ `createAppRouter()`，4 条一级 route |
| 12 | App Shell | ✅ `CareerlyShell` |
| 13 | Careerly Navigation | ✅ `CareerlyNavigationBar`（非 M3） |
| 14 | State Management Foundation | ✅ `AsyncState` + `AsyncStateNotifier` + 5 个 Provider |
| 15 | Repository Interface | ✅ 4 个 `abstract interface class` |
| 16 | Mock Data Layer | ✅ 4 个 Mock + `MockConfig` |
| 17 | Error Infrastructure | ✅ `AppError` 6 子类 + `ErrorHandler` |
| 18 | Motion Infrastructure | ✅ `AppMotion` 六档 + 曲线 + 位移量 |

### Typography 专项验收（Phase 1 §二十六）

| 检查项 | 结果 |
|---|---|
| 中文 UI 走 Noto Sans SC | ✅ 代码层面：Token + Theme 均已声明 |
| 不出现系统默认中文字体 | ⚠️ 运行时由平台回退（字体文件缺失，**已明确报告**） |
| 不出现其他中文字体 | ✅ 全项目零处出现其他中文字体族名 |
| 不出现页面私有中文字体 | ✅ 全项目零处 `fontFamily` 硬编码（除 `AppTypography` 内部） |

### 验证方式

```bash
flutter analyze            →  No issues found!  (ran in 5.2s)
flutter test               →  10/10 All tests passed!
flutter build apk --debug  →  ✅ 构建成功
```

#### Android 构建结果（替代「真机 flutter run」的最强可用证据）

```text
build/app/outputs/flutter-apk/app-debug.apk        75,419,271 bytes
build/app/outputs/flutter-apk/app-debug.apk.sha1   ✅ 已生成
```

`.sha1` 文件由 Gradle 在构建**成功完成后**写出。
APK 产出说明 **Android 目标（Gradle / Kotlin / Java 17 / 资源 / Dart 内核）编译链路完整可用**。

**但它不能替代真机验收** —— APK 能构建 ≠ SafeArea / 返回键 / 键盘行为正确。见 §21 R2。

#### 测试用例清单

```text
App Shell
  ✅ 启动后展示 Careerly Shell 与四个一级导航
  ✅ 默认落在首页
  ✅ 可以切换到「分析」，并保留分支状态
  ✅ 可以切换到「我的」
  ✅ 可以切换到 AI
Design Tokens
  ✅ AppMotion 六档时长满足 motion-spec §27 区间
  ✅ Typography 声明了 Noto Sans SC
  ✅ 背景渐变有三个停靠点（Figma S.bg）
QuotaState
  ✅ 免费用户初始为 3 次且可分析
  ✅ 扣减与回滚（分析失败回滚额度）
```

---

## 21. Remaining Issues

### 阻塞 Phase 1 完整验收（需处理）

| # | 问题 | 需要谁做什么 |
|---|---|---|
| R1 | **Noto Sans SC 字体文件缺失** | 提供字体文件（放入 `assets/fonts/`）或授权下载。补齐方式见 `assets/fonts/README.md` |
| R2 | **无 Android 设备，未实机验证** | 连接 Android 真机 / 启动模拟器后，补验 SafeArea / 状态栏 / 导航栏 / 返回键 / 小屏 |
| R3 | **P3：底部导航形态需确认** | 确认「4 位置 + AI 特殊入口」还是「3 Tab + AI 浮起球」，Phase 3 按结论定型 |

### 不阻塞 Phase 1，但需在后续阶段解决

| # | 问题 | 阻塞阶段 |
|---|---|---|
| R4 | P2：go_router 锁 17.x（meta 约束） | 持续观察 Flutter SDK |
| R5 | P6：未引入 `flutter_localizations` | Phase 2（引入内建组件前） |
| R6 | P7：`applicationId` 仍为 `com.example.careerly`，release 用 debug 签名 | 发布前 |
| R7 | P11：仓库未纳入 Git | 建议尽早（Baseline 建议 `feat/*` + 小步提交） |
| R8 | P12：Phase 0 开放项 O4 / O5 / O6 / O7 | Phase 8 / Phase 9 |

---

## 22. Recommendation for Phase 2

Phase 2 的目标（Baseline §8）是 **Design System：先 Token，后组件**。
Token 已在 Phase 1 完成，因此 Phase 2 的实质工作是**组件**。

### 建议的 Phase 2 顺序

```text
1. GlassSurface                      ← 最底层，其他组件都依赖它
2. CareerlyButton / SecondaryButton
3. CareerlyCard
4. CareerlyChip
5. CareerlyProgress / AnalysisProgress
6. CareerlyBottomSheet
7. CareerlyToast
8. ScoreIndicator
9. AIMessageBubble
10. 用 GlassSurface 重新实现 CareerlyNavigationBar 的 Glass 视觉
```

### Phase 2 需要先解决的问题

| # | 问题 | 为什么在 Phase 2 之前必须解决 |
|---|---|---|
| 1 | **字体文件**（R1） | 组件的视觉验收依赖真实字体。字体不到位，所有组件的排版都无法盖章 |
| 2 | **P5：inset 阴影的 Flutter 实现方案** | `GlassSurface` 是整个视觉体系的地基，方案定错会影响所有卡片 |
| 3 | **P6：`flutter_localizations`** | `CareerlyBottomSheet` 一旦引入日期类内容就需要 |
| 4 | **R3：底部导航最终形态** | 决定 `GlassSurface` 的第一个真实用例怎么设计 |

### Phase 2 建议**不要**做的事

- ❌ 不要开始任何业务页面（Phase 4 起）
- ❌ 不要引入真实 API
- ❌ 不要因为 Figma Make 里出现了 Growth Calendar / History Version /
  Membership / Career Context 就建立对应页面（Phase 1 §二十三 / §二十四，
  Baseline §9 的 O2 / O3 已裁决）

---

## PHASE 1 STATUS

```text
PHASE 1 STATUS

PASS WITH NOTES
```

### 判定依据

**PASS 的部分：**

- ✅ 工程目录结构完整，与 Baseline §7.1 / Phase 1 §十 一致
- ✅ 6 个 Design Token 全部建立，数值取自 Figma Make 真值来源
- ✅ `CareerlyTheme` 建立，且**未被 Material 3 默认样式主导**
- ✅ Router 建立，一级导航恰好 4 个，无多余页面
- ✅ App Shell 建立，SafeArea / 内容区 / 自绘导航 / Tab 状态 / Tab 切换 / 转场架构全部就位
- ✅ `CareerlyNavigationBar` 自绘，**未使用 M3 `NavigationBar`**
- ✅ State / Repository / Mock / Error / Motion 五层基础设施全部建立
- ✅ `flutter analyze` **零 issue**
- ✅ `flutter test` **10/10 通过**
- ✅ **未新增任何产品页面**，未实现任何被禁止的业务逻辑
- ✅ Phase 0 的 O1 / O2 / O3 三项决策全部落实

**NOTES 的部分（3 条）：**

- ⚠️ **字体文件缺失** —— 代码层面 100% 遵守「中文走 Noto Sans SC」，
  但字体资产不在项目内，且 Phase 1 明确禁止自行下载。
  **视觉上的 Typography 验收无法在当前状态下完成。**
  这是**已知的、按指令处理的、已上报的**缺口，不是执行偏差。

- ⚠️ **无 Android 设备，未做实机验证** ——
  SafeArea / 状态栏 / 导航栏 / 键盘 / 返回键 / 小屏适配
  均只做到「代码就位 + 单测通过」，未在真机上确认。

- ⚠️ **底部导航形态与 Baseline 表述不完全同源**（P3）——
  已按兼容方式实现并明确记录，**未擅自改动产品决策**，提请确认。

**BLOCKED 的不成立：** 上述三项均不阻碍 Phase 2 启动；
Phase 2 的组件工作可以先做与字体无关的部分（布局 / 形状 / 阴影 / 动效）。

---

## Phase 1 完成。停止，等待验收。

**不进入 Phase 2。不开始 Resume Parser / JD Parser / AI / Match。**

---

## End

**Careerly Phase 1 Report**
