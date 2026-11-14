import 'package:flutter/material.dart';

/// Careerly 颜色 Token。
///
/// 真值来源：`docs/Careerly App Interface Design (Copy)/src/App.tsx` 的 `S` 对象。
/// 依据 `docs/07_Careerly_Development_Baseline_V1.0.md` §6.1：
/// **不取自** `pasted_text/careerly-design-system.md`（该文档为 V1.0，数值已过期）。
///
/// 硬规则（Baseline §7.5 / Phase 1 §11）：
/// 业务页面不得直接写死颜色值，一律通过 `AppColors` 获取。
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // 品牌色
  // ---------------------------------------------------------------------------

  /// 品牌蓝。
  static const Color primaryBlue = Color(0xFF4F7EF5);

  /// 品牌紫。
  static const Color primaryPurple = Color(0xFFA77BE6);

  /// 品牌渐变（135deg / #4F7EF5 → #A77BE6）。
  /// 用于主按钮、AI 入口、核心强调元素。
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[primaryBlue, primaryPurple],
  );

  /// AI 浮起球使用的柔和品牌渐变。
  static const LinearGradient aiOrbGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xB84F7EF5), Color(0xB8A77BE6)],
  );

  // ---------------------------------------------------------------------------
  // 页面背景
  // ---------------------------------------------------------------------------

  /// Careerly 全局背景渐变。
  ///
  /// CSS 原值：`linear-gradient(128.67deg, rgb(220,233,251) 7.74%,
  /// rgb(229,220,250) 45.77%, rgb(251,233,241) 92.27%)`
  ///
  /// Flutter 换算：CSS 角度 128.67deg → 屏幕坐标方向向量
  /// `(sin θ, -cos θ) = (0.781, 0.625)`，即向右下推进。
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment(-0.78, -0.63),
    end: Alignment(0.78, 0.63),
    colors: <Color>[Color(0xFFDCE9FB), Color(0xFFE5DCFA), Color(0xFFFBE9F1)],
    stops: <double>[0.0774, 0.4577, 0.9227],
  );

  /// 渐变不可用时的纯色兜底（浅色背景）。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D43）** —— 该色值在 Figma 中**出现 0 次**
  /// （`App.tsx` 与 `index.css` 均无），是 Flutter 侧从背景渐变里取的近似中间值。
  /// 若实际页面上兜底背景与渐变观感不一致，改这里即可。
  static const Color backgroundFallback = Color(0xFFEDE9FA);

  // ---------------------------------------------------------------------------
  // 中性结构色
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  /// 更弱的辅助文字（时间戳、说明）。
  static const Color textTertiary = Color(0xFF9CA3AF);

  /// 深色反白文字（用于深色 chip / 深色按钮之上）。
  static const Color textInverse = Color(0xFFFFFFFF);

  /// 选中态深色底（Figma 中的深色 chip）。
  static const Color surfaceDark = Color(0xFF373B4D);

  /// 分割线。
  static const Color divider = Color(0xB3E5E7EB);

  /// 卡片浅底（非 Glass 场景）。
  static const Color surface = Color(0xFFFFFFFF);

  /// 页面次级底色（列表区块、输入框底）。
  static const Color surfaceSubtle = Color(0x66FFFFFF);

  // ---------------------------------------------------------------------------
  // 语义色
  // ---------------------------------------------------------------------------

  /// 成功 / 正向变化。
  static const Color success = Color(0xFF34C759);

  /// 警示 / 需要关注。
  static const Color warning = Color(0xFFFF9500);

  /// 错误 / 失败 / 破坏性操作。
  static const Color danger = Color(0xFFFF3B30);

  /// 会员 / Pro 标识。
  static const Color pro = Color(0xFFF2C94C);

  /// 信息提示。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D43）** —— Figma 的 `S` 对象里**只有 `green` / `orange`**，
  /// **没有「信息」语义色**。此处取 [primaryBlue] 等同值（仅 1 处引用）。
  /// 若实际页面上「信息」需要与品牌蓝区分，改这里。
  static const Color info = Color(0xFF4F7EF5);

  // ---------------------------------------------------------------------------
  // 语义色 · 半透明底（Chip / 次级按钮 / 浅底色块）
  //
  // Figma 的 Chip 与次级按钮一律是「语义色 + 低透明度填充」，
  // 而不是实心色块。这里把每个语义色的标准底衬固化下来，
  // 避免业务侧各写各的 `withOpacity(...)`。
  //
  // 真值来源：`src/App.tsx` 各 Chip / `SecondaryBtn` 的 background 原值。
  // ---------------------------------------------------------------------------

  /// `rgba(79,126,245,0.08)` —— 品牌蓝底衬。
  static const Color primaryBlueSurface = Color(0x144F7EF5);

  /// `rgba(167,123,230,0.10)` —— 品牌紫底衬。
  static const Color primaryPurpleSurface = Color(0x1AA77BE6);

  /// `rgba(52,199,89,0.12)` —— 成功 / 正向变化底衬。
  static const Color successSurface = Color(0x1F34C759);

  /// `rgba(255,149,0,0.12)` —— 警示 / Gap 底衬。
  static const Color warningSurface = Color(0x1FFF9500);

  /// `rgba(255,59,48,0.10)` —— 错误 / 负向变化底衬。
  static const Color dangerSurface = Color(0x1AFF3B30);

  /// `rgba(107,114,128,0.10)` —— 中性底衬（无变化、归档）。
  static const Color neutralSurface = Color(0x1A6B7280);

  /// `rgba(255,255,255,0.20)` —— **渐变/深色底之上**的白色底衬
  /// （如渐变卡片里的「查看结果 →」）。
  static const Color onBrandSurface = Color(0x33FFFFFF);

  // ---------------------------------------------------------------------------
  // 半透明底 · 更浅一档（Phase 6 分析页新增，真值来源 `src/App.tsx`）
  //
  // Figma 在分析页用了比标准底衬更浅的 0.06 / 0.15 档，
  // 现有 `*Surface`（0.08–0.12）与 `*Border`（0.25+）都覆盖不到。
  // ---------------------------------------------------------------------------

  /// `rgba(79,126,245,0.06)` —— 品牌蓝**浅**底衬
  /// （新建分析：简历读数三格底、额度条底；`App.tsx` L1306 / L1408）。
  static const Color primaryBlueSurfaceSubtle = Color(0x0F4F7EF5);

  /// `rgba(79,126,245,0.15)` —— 品牌蓝**浅**描边
  /// （额度条描边、JD 表单 footer 分隔线；`App.tsx` L1408 / L1356）。
  static const Color primaryBlueBorderFaint = Color(0x264F7EF5);

  /// `rgba(167,123,230,0.15)` —— 品牌紫**浅**描边
  /// （岗位链接表单 footer 分隔线；`App.tsx` L1389）。
  static const Color primaryPurpleBorderFaint = Color(0x26A77BE6);

  /// `rgba(79,126,245,0.12)` —— JD 表单 footer 分隔线
  /// （`App.tsx` L1356；比表单描边 0.25 更浅一档）。
  static const Color primaryBlueDividerHairline = Color(0x1F4F7EF5);

  /// `rgba(255,59,48,0.06)` —— 错误**浅**底衬
  /// （额度条耗尽态底；`App.tsx` L1408）。
  static const Color dangerSurfaceSubtle = Color(0x0FFF3B30);

  /// `rgba(255,59,48,0.15)` —— 错误**浅**描边
  /// （额度条耗尽态描边；`App.tsx` L1408）。
  static const Color dangerBorderFaint = Color(0x26FF3B30);

  /// `rgba(156,163,175,0.8)` —— 弱化辅助文案
  /// （岗位链接表单的平台说明行；`App.tsx` L1387）。
  static const Color helperTextFaint = Color(0xCC9CA3AF);

  /// `rgba(79,126,245,0.10)` —— 品牌蓝中底衬
  /// （「更换」徽标底；`App.tsx` L1302）。
  static const Color primaryBlueSurfaceSoft = Color(0x1A4F7EF5);

  // ---------------------------------------------------------------------------
  // 分析结果页（a-result，真值来源 `src/App.tsx` L2120-2295）
  // ---------------------------------------------------------------------------

  /// `rgba(255,255,255,0.08)` —— 渐变 Hero 卡上的装饰圆
  /// （`App.tsx` L2140）。
  static const Color resultHeroDecoration = Color(0x14FFFFFF);

  /// `rgba(255,255,255,0.05)` —— Hero 卡磨砂清单面板底（L2156）。
  static const Color resultPanelFill = Color(0x0DFFFFFF);

  /// `rgba(255,255,255,0.29)` —— Hero 卡磨砂清单面板描边（L2156）。
  static const Color resultPanelBorder = Color(0x4AFFFFFF);

  /// `#b7f1ba` —— Hero「较上次 ↑」涨幅文字（L2148）。
  /// ⚠️ 不是 [success]（`#34C759`）—— Figma 在深色渐变上单独给了浅绿。
  static const Color resultDeltaGreen = Color(0xFFB7F1BA);

  /// `linear-gradient(153deg, #4F7EF5 0%, #A77BE6 100%)` ——
  /// 结果页 Hero 卡渐变（L2138）。
  ///
  /// Flutter 换算：CSS `153deg` → `(sin θ, -cos θ) = (0.454, 0.891)`。
  static const LinearGradient resultHeroGradient = LinearGradient(
    begin: Alignment(-0.454, -0.891),
    end: Alignment(0.454, 0.891),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  // ---------------------------------------------------------------------------
  // Glass 材质
  // ---------------------------------------------------------------------------

  /// 标准 Glass 卡片底。
  static const Color glassFill = Color(0xADFFFFFF); // rgba(255,255,255,0.68)

  /// 轻量 Glass 底。
  static const Color glassFillLight = Color(0x73FFFFFF); // rgba(255,255,255,0.45)

  /// Glass 描边。
  static const Color glassBorder = Color(0x8CFFFFFF); // rgba(255,255,255,0.55)

  /// 轻量 Glass 描边。
  static const Color glassBorderLight = Color(0x66FFFFFF); // rgba(255,255,255,0.40)

  // ---------------------------------------------------------------------------
  // 底部导航 Glass（真值来源：Figma `src/App.tsx` 的 `BottomNav`，行 235–334）
  //
  // ⚠️ 这里的数值**不是**归纳收敛的结果，而是 Figma 的**逐层还原**。
  // 底部导航是品牌识别度最高的组件，Baseline §1.2 要求
  // 「Figma 有视觉但 Flutter 没有实现方式 → 重新实现，而不是放弃视觉」。
  // ---------------------------------------------------------------------------

  /// 玻璃条填充。Figma `rgba(255,255,255,0.04)`。
  static const Color navGlassFill = Color(0x0AFFFFFF);

  /// 玻璃条描边。Figma `0.5px rgba(255,255,255,0.30)`。
  static const Color navGlassBorder = Color(0x4DFFFFFF);

  /// 玻璃条**外圈高光**填充（`inset:-1px`，比玻璃条大 1px 的环）。
  /// Figma `rgba(255,255,255,0.18)`。
  static const Color navGlassEdgeFill = Color(0x2EFFFFFF);

  /// 玻璃条外圈高光描边。Figma `0.5px rgba(255,255,255,0.35)`。
  static const Color navGlassEdgeBorder = Color(0x59FFFFFF);

  /// 选中态滑动药丸填充。Figma `rgba(255,255,255,0.50)`。
  static const Color navPillFill = Color(0x80FFFFFF);

  /// 选中态滑动药丸描边。Figma `1.163px rgba(255,255,255,0.40)`。
  static const Color navPillBorder = Color(0x66FFFFFF);

  // --- Glass 内阴影高光 ---------------------------------------------------
  //
  // Flutter 的 `BoxShadow` **不支持 inset**（见 `AppShadows` 顶部说明与 K5）。
  // 这 6 层内阴影由 `_GlassEdgePainter` 以「裁剪到圆角矩形 + 内缩色带」重绘。

  /// `inset 0 1.5px 0 rgba(255,255,255,0.62)` —— 顶部内高光（视觉主导项）。
  static const Color navInsetTop = Color(0x9EFFFFFF);

  /// `inset 0 -1px 0 rgba(255,255,255,0.12)` —— 底部内高光。
  static const Color navInsetBottom = Color(0x1FFFFFFF);

  /// `inset 1px 0 0 rgba(255,255,255,0.18)` —— 左侧内高光。
  static const Color navInsetLeft = Color(0x2EFFFFFF);

  /// `inset -1px 0 0 rgba(255,255,255,0.10)` —— 右侧内高光。
  static const Color navInsetRight = Color(0x1AFFFFFF);

  /// 药丸 `inset 0 1px 0 rgba(255,255,255,0.55)`。
  static const Color navPillInsetTop = Color(0x8CFFFFFF);

  /// AI 球 `inset 0 1.5px 0 rgba(255,255,255,0.50)`。
  static const Color navOrbInsetTop = Color(0x80FFFFFF);

  /// AI 球 `inset 0 -1px 0 rgba(79,126,245,0.20)`。
  static const Color navOrbInsetBottom = Color(0x334F7EF5);

  /// AI 球描边。Figma `0.5px rgba(255,255,255,0.42)`。
  static const Color navOrbBorder = Color(0x6BFFFFFF);

  /// 导航图标**未选中**描边。Figma `#7B7979`（非 `textSecondary`）。
  static const Color navIconInactive = Color(0xFF7B7979);

  /// AI 入口文字标签。Figma `rgba(255,255,255,0.92)`。
  static const Color navAiLabel = Color(0xEBFFFFFF);

  // ---------------------------------------------------------------------------
  // Progress（Phase 2 批 2）
  //
  // 真值来源：Figma `OnboardingProgress`（`src/App.tsx` L448-452）。
  // ⚠️ 进度条的渐变**不是** `brandGradient`（135deg），而是 **172deg** ——
  // 几乎垂直向下，仅带轻微右偏。两者不可互换。
  // ---------------------------------------------------------------------------

  /// 进度轨道。Figma `rgba(79,126,245,0.12)`。
  static const Color progressTrack = Color(0x1F4F7EF5);

  /// 进度填充渐变。Figma `linear-gradient(172deg, #4F7EF5 0%, #A77BE6 100%)`。
  ///
  /// Flutter 换算：CSS `172deg` → 方向向量 `(sin θ, -cos θ)`
  /// `= (0.139, 0.990)`，即基本朝下。
  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment(-0.139, -0.990),
    end: Alignment(0.139, 0.990),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  // ---------------------------------------------------------------------------
  // Onboarding（Phase 4 批 1）
  //
  // 真值来源：Figma `OnSplash`（`src/App.tsx` L366-425）
  // 与 `OnRegister` / `OnWelcome`（L460-560 / L562-634）。
  //
  // ⚠️ **Onboarding 的页面背景与全局 [backgroundGradient] 不是同一个渐变**：
  // 全局是 `128.67deg`（7.74% / 45.77% / 92.27%），开屏是 `111deg`，
  // 表单页是 `143deg`，**三者的角度与色标都不同**，不可互相替代。
  // ---------------------------------------------------------------------------

  /// 开屏页背景。
  /// Figma `linear-gradient(111.07deg, #DCE9FB 11.49%,
  /// #E5DCFA 46.15%, #FBE9F1 88.52%)`（2026-10-04 重新导出）。
  ///
  /// Flutter 换算：CSS 角度 111.07deg → `(sin θ, -cos θ) = (0.933, 0.359)`。
  ///
  /// ⚠️ 2026-10-04 重新导出版把角度从 `111deg` 精化成 `111.07deg`，
  /// 方向向量相应从 `(0.934, 0.358)` 微调到 `(0.933, 0.359)` —— 视觉无差别，
  /// 改的是与设计稿逐位对齐的可追溯性。
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment(-0.933, -0.359),
    end: Alignment(0.933, 0.359),
    colors: <Color>[Color(0xFFDCE9FB), Color(0xFFE5DCFA), Color(0xFFFBE9F1)],
    stops: <double>[0.1149, 0.4615, 0.8852],
  );

  /// Onboarding 表单页背景（注册 / 价值介绍 / 提交简历 / 解析 / 确认）。
  /// Figma `linear-gradient(142.84deg, #EEF2FF 8.49%, #F5F3FF 50%, #FDF4FF 91.51%)`。
  ///
  /// Flutter 换算：CSS 角度 142.84deg → `(sin θ, -cos θ) = (0.605, 0.797)`。
  ///
  /// ⚠️ 2026-10-04 的微调同 [splashGradient]：`143deg` → `142.84deg`。
  ///
  /// ⚠️ **登录页不用本渐变** —— 它是一块从 `top: 185` 起的独立面板，
  /// 走 [authLoginPanelGradient]（终点是纯白）。
  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment(-0.605, -0.797),
    end: Alignment(0.605, 0.797),
    colors: <Color>[Color(0xFFEEF2FF), Color(0xFFF5F3FF), Color(0xFFFDF4FF)],
    stops: <double>[0.0849, 0.5, 0.9151],
  );

  /// 开屏 Logo 文字的渐变填充。
  /// Figma `linear-gradient(157deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)`。
  ///
  /// ⚠️ **不是 [brandGradient]** —— 品牌渐变是 135deg，本渐变是 157deg
  /// （更接近垂直）。用在文字上时角度差会体现在字形上下的色偏里。
  ///
  /// Flutter 换算：CSS 角度 157deg → `(sin θ, -cos θ) = (0.391, 0.921)`。
  static const LinearGradient splashTitleGradient = LinearGradient(
    begin: Alignment(-0.391, -0.921),
    end: Alignment(0.391, 0.921),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  /// Onboarding 顶部返回键的 Glass 底色。
  /// Figma `OnboardingProgress`：`rgba(255,255,255,0.55)`。
  static const Color onboardingGlassFill = Color(0x8CFFFFFF);

  /// Onboarding 顶部返回箭头的描边色。
  /// Figma `OnboardingProgress`：`#0088FF`。
  ///
  /// ⚠️ **不是** [primaryBlue]（`#4F7EF5`）—— 更亮、更接近纯青蓝。
  static const Color onboardingBackIcon = Color(0xFF0088FF);

  /// 品牌渐变圆上的人像字形色。
  /// Figma `OnRegister`：`fill="white" fillOpacity="0.9"` → `rgba(255,255,255,0.9)`。
  ///
  /// ⚠️ 比 [textInverse]（纯白）低一档透明度 —— 在渐变底上不要直接用纯白。
  static const Color onAvatarGlyph = Color(0xE6FFFFFF);

  // ---------------------------------------------------------------------------
  // Onboarding（Phase 4 批 2）
  //
  // 真值来源：Figma `OnResume`（`App.tsx` L747-800）/
  // `OnParsing`（L806-920）/ `OnConfirm`（L926-981）。
  //
  // 三屏共用 [onboardingGradient] 作背景，本节只登记它们**新增**的色值。
  // ---------------------------------------------------------------------------

  /// 中等强度的品牌描边（`0.35`）。Figma `OnResume` 中两处同值：
  /// - 上传区虚线框：`1.5px dashed`
  /// - 「粘贴简历文本」按钮描边：`1.5px solid`
  ///
  /// ⚠️ 比 [inputBorderBrand]（`0.25`）与 [brandBorderFaint]（`0.20`）都更实
  /// —— 三者是**三个不同的透明度档**，不可互换。
  static const Color brandBorderSoft = Color(0x594F7EF5);

  /// 品牌色 `12%` 淡底。Figma `OnResume` 清单勾选圆底：
  /// `rgba(79,126,245,0.12)`。
  ///
  /// ⚠️ 与 [progressTrack] **色值完全相同但语义不同**
  /// （一个是进度轨道，一个是勾选圆底）。此处并存一个具名别名而不是复用，
  /// 是为了让「改进度条配色」不会意外改到清单圆底 ——
  /// 它们只是**恰好同值**，不是同一个设计意图。
  static const Color brandTint = Color(0x1F4F7EF5);

  /// 品牌渐变（`172deg`，接近垂直向下）。
  ///
  /// Figma 中 `172deg` 的品牌渐变出现在**三处不同用途**上：
  /// `OnboardingProgress` 的进度填充、`OnResume` 主按钮、
  /// `OnParsing` 的光晕球与步骤条。
  ///
  /// ⚠️ 与 [progressGradient] **色值与角度完全相同**，同样并存具名别名
  /// 而非复用 —— 理由与 [brandTint] 相同。
  static const LinearGradient brandGradientDown = LinearGradient(
    begin: Alignment(-0.139, -0.990),
    end: Alignment(0.139, 0.990),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  /// 中等正文色（清单条目）。Figma `OnResume`：`#374151`。
  ///
  /// ⚠️ 比 [textPrimary]（`#111827`）浅、比 [textSecondary]（`#6B7280`）深
  /// —— 是第三个中性层级，不可用两者替代。
  static const Color textBody = Color(0xFF374151);

  /// 步骤徽标**未到达**时的底色。Figma `OnParsing`：`rgba(0,0,0,0.08)`。
  static const Color stepBadgeInactive = Color(0x14000000);

  /// 清单行分隔线。Figma `OnParsing` 步骤卡 / `OnConfirm` 汇总卡：
  /// `1px solid rgba(0,0,0,0.05)`。
  ///
  /// ⚠️ 与 [divider]（`rgba(229,231,235,0.7)`）不是同一个值。
  static const Color rowDivider = Color(0x0D000000);

  /// 磨砂卡片底。Figma `OnParsing` 步骤卡 / `OnConfirm` 汇总卡：
  /// `rgba(255,255,255,0.65)` 配 `blur(16px)`。
  ///
  /// ⚠️ 这是 Glass 的**第三个透明度档** —— 低于 [glassFill]（0.68）、
  /// 高于 [glassFillLight]（0.45），不可互相替代。
  static const Color frostedFill = Color(0xA6FFFFFF);

  /// 状态药丸底。Figma `OnParsing` 顶部药丸：`rgba(79,126,245,0.10)`。
  ///
  /// ⚠️ 与 [primaryBlueSurface]（`0.08`）不是同一个值。
  static const Color brandPillFill = Color(0x1A4F7EF5);

  /// 「退出解析」按钮底。Figma `OnParsing`：`rgba(255,255,255,0.60)`。
  static const Color ghostButtonFill = Color(0x99FFFFFF);

  /// 细品牌描边（环形 / 按钮外圈）。
  ///
  /// Figma 中两处同值、用途不同：
  /// - `OnParsing` 退出按钮的 `box-shadow: 0 0 0 1px`
  /// - `OnConfirm` 外圈的 `border: 2px solid`
  ///
  /// 都是 `rgba(79,126,245,0.20)`。
  static const Color brandBorderFaint = Color(0x334F7EF5);

  /// 「确认」页的装饰渐变。
  ///
  /// Figma `OnConfirm`：
  /// `linear-gradient(135deg, rgb(91,124,246) 0%, rgb(167,123,230) 100%)`。
  ///
  /// ⚠️ **不是 [brandGradient]** —— 品牌渐变首色是 `#4F7EF5`，
  /// 而本渐变首色是 `rgb(91,124,246)` = `#5B7CF6`。两者并排能看出色差，
  /// 依 `CLAUDE.md` §3.1「Figma 已明确设计细节 → 采纳 Figma」逐位还原。
  static const LinearGradient confirmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF5B7CF6), primaryPurple],
  );

  // ---------------------------------------------------------------------------
  // BottomSheet（Phase 2 批 2）
  //
  // ⚠️ 真值来源是 Figma 里 **6 处内联变体**（`App.tsx` L2082-5156），
  // **不存在统一组件**。下面的归类（确认 / 操作 / 浮层）是**分析归纳**，
  // 不是设计侧给出的正式枚举。详见 `CareerlyBottomSheet` 的类文档。
  // ---------------------------------------------------------------------------

  /// 确认类 scrim。Figma `rgba(0,0,0,0.28)` + `blur(3px)`。
  static const Color sheetScrimConfirm = Color(0x47000000);

  /// 操作类 scrim。Figma `rgba(0,0,0,0.40)` + `blur(6px)`。
  static const Color sheetScrimAction = Color(0x66000000);

  /// 浮层 / Dialog 型 scrim。Figma `rgba(0,0,0,0.45)` + `blur(4px)`。
  static const Color sheetScrimOverlay = Color(0x73000000);

  /// 半透明面板 —— 高。Figma `rgba(255,255,255,0.95)`（分享 / 导出）。
  static const Color sheetFillHigh = Color(0xF2FFFFFF);

  /// 半透明面板 —— 中。Figma `rgba(255,255,255,0.88)`（导入简历）。
  static const Color sheetFillMid = Color(0xE0FFFFFF);

  /// 把手 —— 浅。Figma `rgba(229,231,235,0.9)`（确认类）。
  static const Color sheetHandleLight = Color(0xE6E5E7EB);

  /// 把手 —— 深。Figma `rgba(209,213,219,0.8)`（操作 / 浮层类）。
  static const Color sheetHandleDark = Color(0xCCD1D5DB);

  // ---------------------------------------------------------------------------
  // Input（Phase 2 · 输入组件）
  //
  // 真值来源：`src/App.tsx` 中 4 处输入控件的内联色值。
  // ⚠️ 与 Progress / BottomSheet 不同 —— Figma **不存在统一的 Input 组件**，
  // 这 4 处是各自独立的写法，因此下面的 Token 按**变体**分组，
  // 不做「统一输入框样式」的收敛（那属设计决策 → **待裁决 · D45**）。
  //
  // 变体对照：
  //   ① Onboarding 表单  → [inputBorderBrand]（仅下边框）
  //   ② 工作台内联表单    → [inputBorderBrand] / [inputBorderPurple] + 对应 Surface
  //   ③ a-jd-step 展开区  → [inputSurfaceFilled]
  //   ④ AI 对话输入       → 无底色无边框，直接用透明
  // ---------------------------------------------------------------------------

  /// 输入框细描边。Figma `rgba(79,126,245,0.25)`
  /// —— 工作台内联表单的 `1.5px` 边框，**也是** Onboarding 表单
  /// `1.217px` 下边框的同一色值。
  static const Color inputBorderBrand = Color(0x404F7EF5);

  /// 输入框细描边（紫）。Figma `rgba(167,123,230,0.28)`（粘贴岗位链接）。
  static const Color inputBorderPurple = Color(0x47A77BE6);

  /// 输入框半透明底（蓝）。Figma `rgba(79,126,245,0.03)`。
  static const Color inputSurfaceBrand = Color(0x084F7EF5);

  /// 输入框半透明底（紫）。Figma `rgba(167,123,230,0.04)`。
  static const Color inputSurfacePurple = Color(0x0AA77BE6);

  /// 输入框实心灰底。Figma `rgba(229,231,235,0.40)`（a-jd-step 展开区）。
  static const Color inputSurfaceFilled = Color(0x66E5E7EB);

  /// 输入框**不可用**底。Figma `rgba(229,231,235,0.6)`
  /// —— 取自 a-jd-step 那颗不可用按钮的底色，是 Figma 中唯一
  /// 「灰底 + 不可用」的组合。
  static const Color inputSurfaceDisabled = Color(0x99E5E7EB);

  /// 输入框上方的大写标签色。Figma `#727272`（Onboarding 的 `LABEL`）。
  ///
  /// ⚠️ 与 [textSecondary]（`#6B7280`）**不是同一个值**。
  /// Figma 的必填字段用 `#727272`，选填字段用 `#6B7280`。
  static const Color inputLabel = Color(0xFF727272);

  /// 输入框下方的辅助说明色。Figma `rgba(156,163,175,0.8)`。
  ///
  /// 即 [textTertiary] 降到 80%，与 Figma 原值逐位一致。
  static const Color inputHelper = Color(0xCC9CA3AF);

  // ---------------------------------------------------------------------------
  // 分析 · 添加岗位 ——「从历史岗位添加」入口（2026-10-05）
  //
  // ⚠️ **暂定值 · 待视觉验证（待裁决 · D117）** —— 两值在 Figma 中
  // **都没有依据**：Figma 的添加岗位是「＋ 添加岗位」**单按钮 + 三项选择菜单**
  // （见 `careerly-analysis-structure.md` §六「添加岗位」），
  // **不存在**与「粘贴 JD」「粘贴岗位 URL」并列的第三颗虚线按钮，
  // 因此没有原值可取值。
  //
  // 取值理由：与已有的品牌蓝（[primaryBlue] / [inputBorderBrand]）、
  // 品牌紫（[primaryPurple] / [inputBorderPurple]）拉开区分，用中性灰。
  //
  // 调整方式：**只改下面两处** → 全系统统一变化（`CLAUDE.md` §8.2）。
  // 登记表见 `docs/05_progress/CURRENT_STATUS.md` §3.6。
  // ---------------------------------------------------------------------------

  /// 「从历史岗位添加」虚线按钮的**图标 / 文字**色。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D117）**。
  /// 字面量与 [textSecondary] 相同，但**故意不复用** —— 它是可独立调整的
  /// 暂定值，复用会让「改这里」连带改掉 [textSecondary] 的十余处引用。
  static const Color addFromHistoryTint = Color(0xFF6B7280);

  /// 「从历史岗位添加」虚线按钮的**描边**色。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D117）**。
  /// alpha `0x4D`（≈30%）与 [inputBorderBrand]（`0x40`）/ [inputBorderPurple]
  /// （`0x47`）同量级，避免三颗按钮的虚线浓淡不一致。
  static const Color inputBorderNeutral = Color(0x4D6B7280);

  // ---------------------------------------------------------------------------
  // 首页（Phase 5）
  //
  // 真值来源：Figma `HomePage`（`src/App.tsx` L987-1182）。
  //
  // ⚠️ 首页是**三态共用同一套 Figma 视觉**（产品侧裁决 **D64** ①bis：
  // 「只替换文字内容，不要修改 figma 视觉设计」），因此本节色值
  // 三个状态都走同一份，不按状态分叉。
  // ---------------------------------------------------------------------------

  /// 首页 Hero 卡渐变。
  /// Figma：`linear-gradient(151.5deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)`。
  ///
  /// ⚠️ **不是 [brandGradient]**（`135deg`）—— 角度相差 16.5°，
  /// 在 190px 高的卡片上能看出高光走向不同。
  ///
  /// Flutter 换算：CSS 角度 151.5deg → `(sin θ, -cos θ) = (0.477, 0.879)`。
  static const LinearGradient homeHeroGradient = LinearGradient(
    begin: Alignment(-0.477, -0.879),
    end: Alignment(0.477, 0.879),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  /// 最新首页欢迎区渐变（Figma：169.47deg）。
  static const LinearGradient homeWelcomeGradient = LinearGradient(
    begin: Alignment(-0.183, -0.983),
    end: Alignment(0.183, 0.983),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  static const Color homeWelcomeCircle = Color(0x1AFFFFFF);

  /// Hero 卡内的浅色装饰圆（小）。
  /// Figma：`rgba(255,255,255,0.07)`。
  static const Color homeHeroCircleFaint = Color(0x12FFFFFF);

  /// Hero 卡内的浅色装饰圆（大）。
  /// Figma：`rgba(255,255,255,0.10)`。
  static const Color homeHeroCircleSoft = Color(0x1AFFFFFF);

  /// Hero 卡装饰弧线的轨道色。
  /// Figma `arcTrack`：`fill="#F1F3F9" fillOpacity="0.95"`。
  static const Color homeHeroArcTrack = Color(0xF2F1F3F9);

  /// Hero 卡装饰弧线的填充渐变（水平，左 → 右）。
  /// Figma `hpArcGrad`：`x1=0 y1=0 x2=173 y2=0`（`userSpaceOnUse`），
  /// `stop 0 / 0.519 → #A39EFA`，`stop 1 → #F7A8D8 @ 0.8`。
  ///
  /// ⚠️ 弧线只扫过 **252°**（`arcFill` 的几何），与读数的 `86` **不成比例**
  /// —— 它是纯装饰，Flutter 侧按 252° 硬还原，**不得据分数反推角度**。
  static const LinearGradient homeHeroArcGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFFA39EFA), Color(0xFFA39EFA), Color(0xCCF7A8D8)],
    stops: <double>[0, 0.519, 1],
  );

  /// Hero 卡内文字的三种白色档（Figma 逐处内联）。
  ///
  /// ⚠️ 与 [onBrandSurface]（`0.20`）**不是同一组值**，不可互换。
  /// 三者顺序：说明文字 < 标签 < 单位。
  static const Color onBrandFaint = Color(0x8CFFFFFF); // 0.55
  static const Color onBrandMuted = Color(0x99FFFFFF); // 0.60
  static const Color onBrandStrong = Color(0xCCFFFFFF); // 0.80

  /// 首页 2×2 卡片底。
  /// Figma：`rgba(255,255,255,0.68)` —— 与 [glassFill] **同值**，
  /// 但这里是**无 `backdrop-filter` 的素面**（见 [homeCardBorder] 的说明），
  /// 故不复用 glass 系列 Token，另立一个表达「无模糊的浅面板」。
  static const Color homeCardFill = Color(0xADFFFFFF);

  /// 首页 2×2 卡片描边。
  /// Figma：`1.5px solid rgba(255,255,255,0.25)`。
  ///
  /// ⚠️ 比 [glassBorder]（`0.55`）**弱得多** —— 这两组卡片在 Figma 里
  /// **没有 `backdrop-filter`**，因此不是 Glass 材质，是「磨砂白面板」，
  /// 描边只作极淡的分隔。不可用 [glassBorder] 代替。
  static const Color homeCardBorder = Color(0x40FFFFFF);

  /// 首页卡片主标题色。Figma `Inter:Bold` / `#181a20`。
  ///
  /// ⚠️ 比 [textPrimary]（`#111827`）**更冷、更黑**，是独立取值。
  static const Color homeCardTitle = Color(0xFF181A20);

  /// 卡片描述文字的中性色。Figma：`#6e717c`。
  ///
  /// ⚠️ 与 [textSecondary]（`#6B7280`）**不同值**（更冷、略亮），
  /// 是首页卡片专用的描述灰。
  static const Color homeCardDesc = Color(0xFF6E717C);

  static const LinearGradient homeStatusCardGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0x8CF7A8D8), Color(0x8CFFCCD5)],
  );

  static const Color homeStatusCardBorder = Color(0xFFFFFFFF);
  static const Color homeStatusChipFill = Color(0x1A4F7EF5);
  static const Color homeStatusChipText = Color(0xFF4F70D8);
  static const Color homeStatusScoreLabel = Color(0xFF737887);
  static const Color homeStatusActionText = Color(0xFF4F70D8);
  static const Color homeCardActionText = Color(0xFF000000);
  static const Color homeQuoteBorder = Color(0xFFC49EF7);
  static const Color homeQuoteDate = Color(0xFF6D55A0);
  static const Color homeQuoteDateMuted = Color(0xFF9978BF);
  static const Color homeQuoteMark = Color(0x387C3AED);

  /// 卡片描述文字的高亮色（橙）。Figma:「影响 3 个目标岗位」：`#e07840`。
  static const Color homeCardHighlight = Color(0xFFE07840);

  /// 卡片描述文字的品牌紫。Figma「今日一句」正文：`#7c3aed`。
  static const Color homeCardPurple = Color(0xFF7C3AED);

  /// 2×2 卡片的图标底板渐变（四张，**均为 `90deg` 水平**）。
  ///
  /// Flutter 换算：CSS `90deg` → `(sin 90°, -cos 90°) = (1, 0)`，
  /// 即严格从左到右。
  static const LinearGradient homeStilGradientAi = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFFA39EFA), Color(0xFFB8C0FF)],
  );

  static const LinearGradient homeStilGradientStatus = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFFF7A8D8), Color(0xFFFFCCD5)],
  );

  static const LinearGradient homeStilGradientGrowth = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF8CB8FA), Color(0xFFBEE3F8)],
  );

  static const LinearGradient homeStilGradientDaily = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFFC49EF7), Color(0xFFE9D8FD)],
  );

  /// 首页胶囊 Tab 的描边。Figma：`1px solid #e4e7ec`。
  static const Color homeTabBorder = Color(0xFFE4E7EC);

  /// 岗位匹配进度条的轨道。Figma：`rgba(229,231,235,0.8)`。
  static const Color homeMatchTrack = Color(0xCCE5E7EB);

  /// 岗位匹配进度条的填充渐变。
  /// Figma：`linear-gradient(178deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)`。
  ///
  /// Flutter 换算：CSS `178deg` → `(sin θ, -cos θ) = (0.035, 0.999)`，几乎垂直。
  static const LinearGradient homeMatchBarGradient = LinearGradient(
    begin: Alignment(-0.035, -0.999),
    end: Alignment(0.035, 0.999),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  /// 岗位匹配度**数字**的渐变文字填充。
  /// Figma：`linear-gradient(142deg, …)` + `background-clip: text`。
  ///
  /// ⚠️ 与 [homeMatchBarGradient]（`178deg`）**角度不同** ——
  /// 一个是文字、一个是进度条，Figma 分别给了值。
  ///
  /// Flutter 换算：CSS `142deg` → `(sin θ, -cos θ) = (0.616, 0.788)`。
  static const LinearGradient homeMatchTextGradient = LinearGradient(
    begin: Alignment(-0.616, -0.788),
    end: Alignment(0.616, 0.788),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  /// 岗位行之间的分隔线。Figma：`rgba(229,231,235,0.7)`。
  static const Color homeJobDivider = Color(0xB3E5E7EB);

  /// 岗位列表排名列的颜色。Figma：`#000`。
  ///
  /// ⚠️ **不是** [textPrimary]（`#111827`）—— 设计稿在这里写的是纯黑。
  /// 两者肉眼几乎无差，但依 §3.1「Figma 已明确设计细节 → 采纳 Figma」
  /// 逐位还原，不自行「统一」成中性色令牌。
  static const Color homeJobRank = Color(0xFF000000);

  /// 首页头像的在线绿点描边。Figma：`1.217px solid white`。
  static const Color homeAvatarRing = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // 我的（Phase 8）
  //
  // 真值来源：Figma `ProfilePage`（`src/App.tsx` L3102-3339）与
  // `CareerAssetsPage`（L3342-3634）。
  //
  // 与首页段同样的定位：**逐位照抄 Figma 原值**，不做归纳、不做合并。
  //
  // ⚠️ 本节**不重复**已存在的跨页色 —— 复用下列既有令牌：
  // `textPrimary` / `textSecondary` / `primaryBlue` / `primaryPurple` /
  // `success` / `successSurface` / `pro` / `surfaceDark` / `brandGradient` /
  // `glassFill` / `glassBorder` / `glassFillLight` / `glassBorderLight` /
  // `primaryBlueSurface` / `primaryPurpleSurface` / `brandPillFill`。
  // ---------------------------------------------------------------------------

  /// 我的 · 信息卡里的姓名。Figma：`#181a20`。
  ///
  /// ⚠️ 与 [profileInkDeep]（`#1e1f22`）、[textPrimary]（`#111827`）**三个都不同**。
  /// Figma 在这一屏里同时用了这三种「近黑」，逐位还原，不自行统一。
  static const Color profileNameInk = Color(0xFF181A20);

  /// 我的 · 信息卡里的账号与统计标签。Figma：`#6e717c`。
  ///
  /// ⚠️ 与 [textSecondary]（`#6B7280`）**不是同一个值** —— `#6e717c` 偏冷。
  /// 同值令牌 [homeCardTitle] 的邻居 `homeCardDesc` 也是 `#6E717C`，
  /// 但两者分属不同页面段，各自持名，便于任一页单独调整。
  static const Color profileMetaGray = Color(0xFF6E717C);

  /// 我的 · 信息卡统计行的竖分隔线。Figma：`1px × 28px rgba(18,18,18,0.082)`。
  static const Color profileStatDivider = Color(0x15121212);

  /// 我的 · 信息卡**独有**的描边。Figma：`1.5px solid rgba(255,255,255,0.23)`。
  ///
  /// ⚠️ 比 [glassBorder]（`0.55`）**弱得多**，且线宽是 `1.5px` 而非 `1px`。
  /// 这是全项目**唯一**用 `0.23` 描边的 Glass 卡，不可用 [glassBorder] 代替。
  static const Color profileInfoCardBorder = Color(0x3BFFFFFF);

  /// 我的 · 胶囊 Tab 的未选中描边。Figma：`1px solid #eaeafa`。
  ///
  /// ⚠️ 与首页胶囊 Tab 的描边 [homeTabBorder]（`#e4e7ec`）**不是同一个值**。
  static const Color profileTabBorder = Color(0xFFEAEAFA);

  /// 我的 · 深墨色的 60% 次级文字。
  ///
  /// Figma 原值 `rgba(30,31,34,0.6)`，在本屏**两处复用**：
  /// 胶囊 Tab 未选中态文字（L3210）与浅色卡上的日期行（L3401 / L3415 / L3430 / L3444）。
  /// 同一色值、同一意图（深墨降到 60%），故合为一个令牌。
  static const Color profileInkMuted = Color(0x991E1F22);

  /// 我的 · 深色卡上的 68% 白次级文字。Figma：`rgba(255,255,255,0.68)`。
  ///
  /// ⚠️ 落在 [onBrandFaint]（`0.55`）/ [onBrandMuted]（`0.60`）/
  /// [onBrandStrong]（`0.80`）**三档之间**，四者不可互换。
  static const Color profileOnDarkMuted = Color(0xADFFFFFF);

  /// 我的 · Pro 横幅的说明行。Figma：`#f4f5fc`。
  ///
  /// 这是**横幅专用**的近白，不是 [onBrandStrong] 那种半透明白。
  static const Color profileProBannerSub = Color(0xFFF4F5FC);

  /// 我的 · 资产渐变卡上的子卡底衬。Figma：`rgba(255,255,255,0.15)`。
  ///
  /// 同屏还出现 `0.18`（子卡图标底板，见 [profileAssetTileIconFill]）与
  /// `0.20`（[onBrandSurface]）—— 三档并存，不可合并。
  static const Color profileAssetTileFill = Color(0x26FFFFFF);

  /// 我的 · 资产渐变卡上「⭐」图标底板。Figma：`rgba(255,255,255,0.18)`。
  static const Color profileAssetTileIconFill = Color(0x2EFFFFFF);

  /// 我的 · 资产渐变卡上子卡的说明行。Figma：`rgba(255,255,255,0.65)`。
  static const Color profileAssetCardSub = Color(0xA6FFFFFF);

  /// 我的 · 资产渐变卡上子卡的单位与标签。Figma：`rgba(255,255,255,0.7)`。
  static const Color profileAssetTileLabel = Color(0xB3FFFFFF);

  /// 我的 · 简历卡图标底板。Figma：`rgba(52,199,89,0.1)`。
  ///
  /// ⚠️ 与 [successSurface]（`0.12`，同页的「最新版」Chip 底色）**不是同一个值** ——
  /// 同一张卡上两块绿底相差 2 个百分点，Figma 确实分别写了。
  static const Color profileResumeIconSurface = Color(0x1A34C759);

  /// 职业资产页 · 浅色面板底。Figma：`#f1f2f6`（项目经历卡 L3411 / 能力画像卡 L3593）。
  static const Color profilePanelFill = Color(0xFFF1F2F6);

  /// 职业资产页 · 浅色面板上的主标题。Figma：`#171827`（项目经历卡 L3412）。
  static const Color profileTitleInk = Color(0xFF171827);

  /// 职业资产页 · 页标题 / 计数 / 时钟图标。Figma：`#1e1f22`。
  ///
  /// 见 `CareerAssetsPage` L3414 / L3428 / L3429 / L3442 / L3443 / L3490 / L3622。
  static const Color profileInkDeep = Color(0xFF1E1F22);

  /// 职业资产页 · 工作经历卡的计数。Figma：`#a2d84c`。
  ///
  /// 也是能力画像条填充渐变的**终点色**（见 [profileCapabilityBarGradient]）。
  static const Color profileAccentLime = Color(0xFFA2D84C);

  /// 职业资产页 · 能力画像卡标题。Figma：`#b4c481`。
  static const Color profileCapabilityTitle = Color(0xFFB4C481);

  /// 职业资产页 · 能力画像条填充的**起点色**。Figma：`#cadb8f`。
  static const Color profileCapabilityBar = Color(0xFFCADB8F);

  /// 职业资产页 · 能力画像条的轨道。Figma：`#e1e2e8`。
  static const Color profileCapabilityTrack = Color(0xFFE1E2E8);

  /// 职业资产页 · 荣誉成果卡底。Figma：`#c3aff1`。
  static const Color profileAwardCardFill = Color(0xFFC3AFF1);

  /// 职业资产页 · 荣誉成果的强调色（图标描边 / 年份组织行 / 列表圆点）。
  /// Figma：`#C44B8A`。
  static const Color profileAwardAccent = Color(0xFFC44B8A);

  /// 职业资产页 · 专业技能卡图标描边。Figma：`#7B5CCC`。
  static const Color profileSkillIconInk = Color(0xFF7B5CCC);

  /// 职业资产页 · 项目经历卡图标描边。Figma：`#201E22`。
  static const Color profileIconInk = Color(0xFF201E22);

  /// 我的 · 头部齿轮钮的图标描边。Figma：`#515151`（`ProfilePage` L3151）。
  ///
  /// ⚠️ 与 [textSecondary]（`#6b7280`）**不是同一个灰** —— 这个更深、更中性。
  /// 同一个页面里的齿轮**图标**用本值、**卡片副标题**用 [profileMetaGray]。
  static const Color profileGearInk = Color(0xFF515151);

  /// 职业资产页 · 二级页玻璃返回钮的底。Figma：`rgba(255,255,255,0.7)`。
  ///
  /// ⚠️ 与 [glassFillLight]（`0.45`）不是同一个值：那是「我的」主页齿轮钮的底。
  static const Color profileBackButtonFill = Color(0xB3FFFFFF);

  /// 职业资产页 · 二级页玻璃返回钮的描边。Figma：`1px solid rgba(220,220,240,0.5)`。
  ///
  /// ⚠️ 全项目**唯一**一处**带蓝紫倾向**的 Glass 描边（`220,220,240`），
  /// 其余 Glass 描边都是纯白。不可用 [glassBorderLight] 代替。
  static const Color profileBackButtonBorder = Color(0x80DCDCF0);

  /// 职业资产页 · 二级页玻璃返回钮的图标。Figma：`#0088ff`。
  ///
  /// ⚠️ 与同项目 Onboarding 返回钮的 [onboardingBackIcon]**同值不同段** ——
  /// 依本文件的既定做法（页面段各自持名，便于任一页单独调整），
  /// 不复用那个名字。
  static const Color profileBackIconInk = Color(0xFF0088FF);

  /// 职业资产页 · 「查看全部」磨砂胶囊底。Figma：`rgba(255,255,255,0.62)`。
  static const Color profileViewAllPillFill = Color(0x9EFFFFFF);

  /// 职业资产页 · 展开后磨砂面板的底。Figma：`rgba(255,255,255,0.72)`。
  static const Color profileFrostPanelFill = Color(0xB8FFFFFF);

  /// 职业资产页 · 展开后磨砂面板的描边。Figma：`1px solid rgba(255,255,255,0.8)`。
  static const Color profileFrostPanelBorder = Color(0xCCFFFFFF);

  /// 职业资产页 · 时间轴的竖轨。Figma：`rgba(79,126,245,0.2)`。
  static const Color profileTimelineRail = Color(0x334F7EF5);

  /// 项目成果卡 · 「影响的岗位匹配」底。Figma：`rgba(52,199,89,0.08)`。
  static const Color profileImpactCardFill = Color(0x1434C759);

  /// 项目成果卡 · 「影响的岗位匹配」描边。Figma：`1px solid rgba(52,199,89,0.20)`。
  static const Color profileImpactCardBorder = Color(0x3334C759);

  /// 项目成果卡 · 「影响的岗位匹配」小标题。Figma：`#15803D`。
  ///
  /// ⚠️ 与 [success]（`#34C759`）**不是同一个值** —— 这是同色系更深的一档，
  /// 只用于该小标题，不可互换。
  static const Color profileImpactTitle = Color(0xFF15803D);

  /// 项目经历页 · 「类型」Chip 底。Figma：`rgba(79,126,245,0.10)`（L3738）。
  ///
  /// ⚠️ 与 [primaryBlueSurface]（`0.08`）**不是同一个值** ——
  /// 同一份原型在职业资产页的技能 Chip 上写 `0.08`、在项目类型 Chip 上写 `0.10`。
  /// 依本文件既定做法（页面段各自持名，见 [profileBackIconInk]），另立一个令牌，
  /// **不**用 `withOpacity` 在页面里临时拼。
  static const Color profileProjectTypeChipFill = Color(0x1A4F7EF5);

  /// 详情页 Hero · 类型 Chip 底（品牌渐变之上）。Figma：`rgba(255,255,255,0.25)`（L3780）。
  ///
  /// ⚠️ 与 [onBrandSurface]（`0.20`）**不是同一个值**。
  static const Color profileHeroChipFill = Color(0x40FFFFFF);

  /// 详情页 Hero · 右上角装饰圆。Figma：`rgba(255,255,255,0.08)`。
  ///
  /// ## ⚠️ 这是一处**显式合并**
  ///
  /// 四处 Hero 的装饰圆 Figma 分别写了 `0.08`（工作详情 L3678 / 项目详情 L3774）、
  /// `0.08` 与 `0.06`（会员页 L4853-4854）、`0.07` 与 `0.05`（简历历史 L4502-4503）。
  ///
  /// 它们是**纯装饰**（品牌渐变上 5%–8% 的白），四档之间在真实屏幕上
  /// 不可分辨；且本轮**无法**逐档验证（K1 字体缺口下排版本身已待复核）。
  /// 因此合并为一个值（取出现次数最多的 `0.08`），并在交付报告中显式声明。
  ///
  /// 若视觉走查认为该差异可见 → 拆回四档，**只改本令牌**即可。
  static const Color profileHeroDecoration = Color(0x14FFFFFF);

  /// 简历历史 · 当前简历卡上的三格统计底。Figma：`rgba(255,255,255,0.14)`（L4536）。
  static const Color profileOnBrandTileFill = Color(0x24FFFFFF);

  /// 简历历史 · 当前简历卡的文档图标底板。Figma：`rgba(255,255,255,0.18)`（L4527）。
  ///
  /// ⚠️ 与 [profileAssetTileIconFill]**同值不同用途**（那是「我的」资产卡的
  /// 图标底板）—— 依本文件既定做法各自持名，便于任一页单独调整。
  static const Color profileOnBrandTileStrong = Color(0x2EFFFFFF);

  /// 会员页 · 免费体验进度条的轨道。Figma：`rgba(229,231,235,0.8)`（L4871）。
  ///
  /// ⚠️ 与 [divider]（`rgba(229,231,235,0.7)`）**同色不同透明度** ——
  /// 这是**实心轨道**不是分隔线，不可互换。
  static const Color profileTrialTrackFill = Color(0xCCE5E7EB);

  /// 简历历史 · 当前简历卡上「变化摘要」行的 75% 白。
  /// Figma：`text-white/75`（L4523）。
  ///
  /// ⚠️ 落在 [onBrandMuted]（`0.60`）与 [onBrandStrong]（`0.80`）之间，
  /// 三档不可互换。
  static const Color profileOnBrandStrong = Color(0xBFFFFFFF);

  // ---------------------------------------------------------------------------
  // 我的 · 渐变（Phase 8）
  //
  // ⚠️ 本屏**四处**渐变角度各不相同（156° / 162.6° / 170° / 178°），
  // 起点终点色却都是品牌蓝紫。Figma 确实分开写了 ——
  // 156°（我的主页资产卡）与 170°（Pro 横幅）在同一张信息卡上下相邻，
  // 角度差 14° 在 156px 高的卡上能看出高光走向不同，**不可合并**。
  //
  // Flutter 换算：CSS `θdeg` → `(sin θ, -cos θ)`。
  // ---------------------------------------------------------------------------

  /// 我的主页 · 职业资产渐变卡。Figma：`linear-gradient(156deg, …)`（L3219）。
  ///
  /// Flutter 换算：`(sin 156°, -cos 156°) = (0.407, 0.914)`。
  static const LinearGradient profileAssetsCardGradient = LinearGradient(
    begin: Alignment(-0.407, -0.914),
    end: Alignment(0.407, 0.914),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  /// 我的主页 · Careerly Pro 横幅。Figma：`linear-gradient(170deg, …)`（L3191）。
  ///
  /// Flutter 换算：`(sin 170°, -cos 170°) = (0.174, 0.985)`。
  static const LinearGradient profileProBannerGradient = LinearGradient(
    begin: Alignment(-0.174, -0.985),
    end: Alignment(0.174, 0.985),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  /// 职业资产页 · 专业技能卡。Figma：`linear-gradient(162.6deg, …)`（L3426）。
  ///
  /// Flutter 换算：`(sin 162.6°, -cos 162.6°) = (0.299, 0.954)`。
  static const LinearGradient profileSkillsCardGradient = LinearGradient(
    begin: Alignment(-0.299, -0.954),
    end: Alignment(0.299, 0.954),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  /// 职业资产页 · 能力画像条填充。Figma：`linear-gradient(178deg, #cadb8f 0%, #a2d84c 100%)`（L3468）。
  ///
  /// ⚠️ 与 [homeMatchBarGradient] **角度相同（178°）但色不同** ——
  /// 那条是品牌蓝紫，这条是草绿。角度可按同一公式复用，颜色不可。
  ///
  /// Flutter 换算：`(sin 178°, -cos 178°) = (0.035, 0.999)`。
  static const LinearGradient profileCapabilityBarGradient = LinearGradient(
    begin: Alignment(-0.035, -0.999),
    end: Alignment(0.035, 0.999),
    colors: <Color>[profileCapabilityBar, profileAccentLime],
  );

  // ---------------------------------------------------------------------------
  // 奖项页 / 能力页（Phase 8 批 2）
  // ---------------------------------------------------------------------------

  /// 奖项页 · 奖杯图标底板。Figma：`rgba(255,149,0,0.10)`（L3849）。
  ///
  /// ⚠️ 与 [warningSurface]（`0.12`）**同色不同透明度** —— 后者是年份胶囊
  /// 的底板，两者在同一张卡上左右相邻，不可互换。
  static const Color profileAwardTileFill = Color(0x1AFF9500);

  /// 能力页 · 能力详情条轨道。Figma：`rgba(229,231,235,0.8)`（L3899）。
  ///
  /// ⚠️ 与 [profileTrialTrackFill]**同值不同页** —— 依本文件既定做法
  /// 各自持名，便于任一页单独调整。
  static const Color profileCapabilityDetailTrack = Color(0xCCE5E7EB);

  /// 能力页 · 能力详情条的「上次」填充（叠在轨道上）。Figma：`rgba(167,123,230,0.25)`（L3901）。
  static const Color profileCapabilityPrevBar = Color(0x40A77BE6);

  /// 能力页 · 无增量时「—」胶囊的底板。Figma：`rgba(107,114,128,0.08)`（L3895）。
  static const Color profileCapabilityFlatChipFill = Color(0x146B7280);

  /// 能力页 · 雷达图网格多边形。Figma：`rgba(229,231,235,0.6)`（`RadarChart` L349）。
  static const Color profileRadarGridStroke = Color(0x99E5E7EB);

  /// 能力页 · 雷达图辐条。Figma：`rgba(229,231,235,0.5)`（`RadarChart` L350）。
  ///
  /// ⚠️ 与 [profileRadarGridStroke] 差 `0.1` 透明度 —— 网格是面、辐条是线，
  /// 混用会让图形层次糊掉。
  static const Color profileRadarSpokeStroke = Color(0x80E5E7EB);

  /// 能力页 · 雷达图「上次」多边形填充。Figma：`rgba(167,123,230,0.08)`（L351）。
  static const Color profileRadarPrevFill = Color(0x14A77BE6);

  /// 能力页 · 雷达图「上次」多边形描边。Figma：`rgba(167,123,230,0.3)`（L351）。
  static const Color profileRadarPrevStroke = Color(0x4DA77BE6);

  /// 能力页 · 雷达图图例里「上次」那条短线。Figma：`rgba(167,123,230,0.45)`（L3862）。
  ///
  /// ⚠️ 与 [profileRadarPrevStroke]（`0.3`）差 `0.15` —— 图例要在卡面上独立可辨，
  /// 原型确实调高了，不可统一成一个值。
  static const Color profileRadarLegendPrev = Color(0x73A77BE6);

  /// 能力页 · 雷达图「当前」多边形的填充与描边。
  /// Figma：`linearGradient` 由 `#4F7EF5/0.5` 到 `#A77BE6/0.4`
  /// （`x1=0,y1=0 → x2=1,y2=1`，`RadarChart` L347-348）。
  ///
  /// SVG 的 `(0,0) → (1,1)` 就是 Flutter 的对角线，**无需角度换算** ——
  /// 与本文件其余渐变不同，别照搬 `(sin θ, -cos θ)` 那套。
  static const LinearGradient profileRadarCurrentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0x804F7EF5), Color(0x66A77BE6)],
  );

  // ---------------------------------------------------------------------------
  // 语义别名：让业务页面表达意图，而不是表达色值
  // ---------------------------------------------------------------------------

  static const Color pageBackground = backgroundFallback;
  static const Color primaryText = textPrimary;
  static const Color secondaryText = textSecondary;

  /// 禁用态填充。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D43）** —— `rgba(17,24,39,0.38)` 在 Figma 中**出现 0 次**。
  /// Figma 的 `PrimaryBtn` 不可用时**只把文字调灰**，没有定义背景 / 边框
  /// （见 D16），因此这是 Flutter 侧为凑齐四态而推导的值。
  /// 影响面：**7 处引用**（按钮 / Chip / 卡片）。
  static const Color disabled = Color(0x61111827);

  /// 禁用态底衬。Figma `rgba(255,255,255,0.08)`（8 处引用，有依据）。
  static const Color disabledSurface = Color(0x14FFFFFF);

  /// 不可用态文字。Figma 的空输入按钮文字色 `rgba(156,163,175,0.6)`。
  ///
  /// 即 [textTertiary] 降到 60% —— 与 Figma 原值逐位一致。
  static const Color textDisabled = Color(0x999CA3AF);

  // ---------------------------------------------------------------------------
  // 分析 —— 「AI 正在分析」（Phase 6，`App.tsx` L1864-2118）
  //
  // 全部为 **Figma 逐位原值**（就近内联色值），无暂定值。
  // 唯一的例外已在注释里逐条标明。
  // ---------------------------------------------------------------------------

  /// 上下文胶囊底色。Figma `rgba(79,126,245,0.08)`。
  static const Color analysisChipFill = Color(0x144F7EF5);

  /// 上下文胶囊描边。Figma `0.5px rgba(79,126,245,0.15)`。
  static const Color analysisChipBorder = Color(0x264F7EF5);

  /// 外层光晕。Figma `radial-gradient(circle, rgba(79,126,245,0.14) 0%, transparent 65%)`。
  ///
  /// `circle` 的默认尺寸是 `farthest-corner`，方形盒下半径 = `√2/2 ≈ 0.71`。
  static const RadialGradient analysisHaloBlue = RadialGradient(
    radius: 0.71,
    colors: <Color>[Color(0x244F7EF5), Color(0x004F7EF5)],
    stops: <double>[0, 0.65],
  );

  /// 内层光晕。Figma `radial-gradient(circle, rgba(167,123,230,0.16) 0%, transparent 65%)`。
  static const RadialGradient analysisHaloPurple = RadialGradient(
    radius: 0.71,
    colors: <Color>[Color(0x29A77BE6), Color(0x00A77BE6)],
    stops: <double>[0, 0.65],
  );

  /// 主球体。Figma
  /// `radial-gradient(ellipse at 38% 36%, rgba(196,168,246,0.97) 0%,
  /// rgba(110,148,248,0.92) 44%, rgba(79,126,245,0.88) 68%,
  /// rgba(140,175,255,0.72) 100%)`。
  ///
  /// `38% 36%` → `Alignment(-0.24, -0.28)`；
  /// 半径按 `farthest-corner` 复算（圆心到最远角 117.6 / 盒宽 132 ≈ 0.89）。
  static const RadialGradient analysisOrbGradient = RadialGradient(
    center: Alignment(-0.24, -0.28),
    radius: 0.89,
    colors: <Color>[
      Color(0xF7C4A8F6),
      Color(0xEB6E94F8),
      Color(0xE04F7EF5),
      Color(0xB88CAFFF),
    ],
    stops: <double>[0, 0.44, 0.68, 1],
  );

  /// 主球左上高光。Figma `rgba(255,255,255,0.42)` + `blur(5px)`。
  static const Color analysisOrbSpecular = Color(0x6BFFFFFF);

  /// 主球右下副微光。Figma `rgba(255,255,255,0.18)` + `blur(4px)`。
  static const Color analysisOrbShimmer = Color(0x2EFFFFFF);

  /// 主球内缩高光。
  ///
  /// Figma 是 `inset 0 3px 10px rgba(255,255,255,0.38)` —— Flutter 的
  /// [BoxShadow] **不支持 inset**（同 K5）。本组件用一层自上而下的
  /// 线性渐变近似（见 `careerly_analysis_progress.dart` 的说明）。
  static const Color analysisOrbInset = Color(0x61FFFFFF);

  /// 主球内缩高光的近似渐变。自顶部 [analysisOrbInset] 淡出到全透明，
  /// 终点在球心附近（Figma inset 阴影的视觉收敛范围）。
  static const LinearGradient analysisOrbInsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.center,
    colors: <Color>[analysisOrbInset, Color(0x00FFFFFF)],
  );

  /// 步骤徽标 · 已完成。Figma `rgba(52,199,89,0.14)`。
  static const Color analysisStepBadgeDone = Color(0x2434C759);

  /// 步骤徽标 · 未到达。Figma `rgba(229,231,235,0.55)`。
  static const Color analysisStepBadgeIdle = Color(0x8CE5E7EB);

  /// 步骤徽标 · 未到达时的序号。Figma `rgba(156,163,175,0.75)`。
  ///
  /// ⚠️ 不等于 [textDisabled]（`0.6`）—— 那是表单禁用文字，
  /// 这里是时间线徽标的序号，两处透明度不同，不可互相替代。
  static const Color analysisStepBadgeIdleInk = Color(0xBF9CA3AF);

  /// 标题栏返回钮的底。Figma `rgba(255,255,255,0.55)`。
  ///
  /// ⚠️ 不等于 [glassFillLight]（`0.45`）—— 那是「我的」齿轮钮的底。
  static const Color analysisBarButtonFill = Color(0x8CFFFFFF);

  /// 步骤连接线 · 已完成。Figma `rgba(52,199,89,0.28)`。
  static const Color analysisStepRailDone = Color(0x4734C759);

  /// 步骤连接线 / 当前步进度条轨道 · 未完成。
  /// Figma 两处同值：`rgba(229,231,235,0.7)`。
  static const Color analysisStepRailIdle = Color(0xB3E5E7EB);

  /// 步骤状态文字 · 未到达。Figma `rgba(185,186,190,1)`。
  static const Color analysisStepStatusIdle = Color(0xFFB9BABE);

  /// 步骤副行。Figma `rgba(160,163,172,0.9)`。
  static const Color analysisStepSubInk = Color(0xE6A0A3AC);

  /// 「退出分析」按钮底色。Figma `rgba(0,0,0,0.03)`。
  static const Color analysisExitFill = Color(0x08000000);

  /// 「退出分析」按钮文字。Figma `rgba(160,163,172,1)`。
  static const Color analysisExitInk = Color(0xFFA0A3AC);

  /// 当前步徽标的脉冲环。Figma `_ai-step-pulse` 的
  /// `rgba(79,126,245,0.5)`，扩散到 `0`。
  static const Color analysisStepPulse = Color(0x804F7EF5);

  /// 「更新分析」选项卡（增加目标岗位）底色。Figma `rgba(79,126,245,0.07)`。
  static const Color analysisSheetOptionBrandFill = Color(0x124F7EF5);

  /// 「更新分析」选项卡（更新简历后重新分析）底色。Figma `rgba(167,123,230,0.07)`。
  static const Color analysisSheetOptionPurpleFill = Color(0x12A77BE6);

  /// 「更新分析」选项卡（更新简历后重新分析）描边。Figma `rgba(167,123,230,0.18)`。
  static const Color analysisSheetOptionPurpleBorder = Color(0x2EA77BE6);

  /// Bottom Sheet 的「取消 / 次级」按钮底色。Figma `rgba(0,0,0,0.04)`。
  static const Color analysisSheetGhostFill = Color(0x0A000000);

  /// 分析进度时间线卡的填充。Figma `rgba(255,255,255,0.62)` + `blur(10px)`。
  ///
  /// ⚠️ 不等于 [glassFill]（`0.68`）—— 这是分析进度卡独有的第四档
  /// Glass 透明度，不可互相替代（同 K10 / K12 的「按值立 Token」原则）。
  static const Color analysisTimelineFill = Color(0x9EFFFFFF);

  /// 分析进度时间线卡的描边。Figma `rgba(255,255,255,0.65)` / `1px`。
  ///
  /// ⚠️ 与 [frostedFill] **同值但角色不同**：那是「无模糊浅面板」的填充，
  /// 这里是 Glass 卡的描边。为避免语义混淆不互相引用。
  static const Color analysisTimelineBorder = Color(0xA6FFFFFF);

  // ---------------------------------------------------------------------------
  // 成长足迹（我的 → 成长足迹 Detail · Figma GrowthRecordPage L3973-4114）
  // ---------------------------------------------------------------------------

  // —— 成长时间线 · 类型配色（Figma L3977-3994，逐位一致）——
  //
  // D91 裁决（2026-09-22）：项目模型的 5 类事件映射到 Figma 的 4 套配色，
  // 排名变化（rank）单独新增第 5 套。
  //
  // ```text
  // experience(新增经历) → Figma project    项目
  // skill(技能变化)      → Figma resume     简历
  // capability(能力变化) → Figma capability 能力
  // matchScore(匹配度变化) → Figma analysis  分析
  // rank(排名变化)       → 新增第 5 套（暂定值，见 D96）
  // ```

  /// 新增经历 · 圆点 / 徽章。Figma `dotColor.project = #6c7ee1`。
  static const Color growthExperienceDot = Color(0xFF6C7EE1);

  /// 新增经历 · 事件卡底色。Figma `cardBg.project = #eef1fe`。
  static const Color growthExperienceCardBg = Color(0xFFEEF1FE);

  /// 新增经历 · 连接线渐变起点。Figma `lineColor.project = rgb(197,200,224)`。
  static const Color growthExperienceLine = Color(0xFFC5C8E0);

  /// 技能变化 · 圆点 / 徽章。Figma `dotColor.resume = #b08ae0`。
  static const Color growthSkillDot = Color(0xFFB08AE0);

  /// 技能变化 · 事件卡底色。Figma `cardBg.resume = #f3effe`。
  static const Color growthSkillCardBg = Color(0xFFF3EFFE);

  /// 技能变化 · 连接线渐变起点。Figma `lineColor.resume = rgb(204,192,224)`。
  static const Color growthSkillLine = Color(0xFFCCC0E0);

  /// 能力变化 · 圆点 / 徽章。Figma `dotColor.capability = #ff9c6e`。
  static const Color growthCapabilityDot = Color(0xFFFF9C6E);

  /// 能力变化 · 事件卡底色。Figma `cardBg.capability = #fff2ec`。
  static const Color growthCapabilityCardBg = Color(0xFFFFF2EC);

  /// 能力变化 · 连接线渐变起点。Figma `lineColor.capability = rgb(217,191,176)`。
  static const Color growthCapabilityLine = Color(0xFFD9BFB0);

  /// 匹配度变化 · 圆点 / 徽章。Figma `dotColor.analysis = #4cc87a`。
  static const Color growthMatchScoreDot = Color(0xFF4CC87A);

  /// 匹配度变化 · 事件卡底色。Figma `cardBg.analysis = rgba(202,219,143,0.35)`。
  static const Color growthMatchScoreCardBg = Color(0x59CADB8F);

  /// 匹配度变化 · 连接线渐变起点。
  /// Figma `lineColor.analysis = rgb(176,217,192)`。
  static const Color growthMatchScoreLine = Color(0xFFB0D9C0);

  /// 排名变化 · 圆点 / 徽章。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D96）** —— Figma 只有 4 套时间线配色，
  /// 第 5 套由 D91 裁决新增：色相取品牌渐变的粉端（蓝紫粉 → 粉），
  /// 饱和度 / 明度对齐其余四套。视觉走查后如需调整改这里即可。
  static const Color growthRankDot = Color(0xFFE878A6);

  /// 排名变化 · 事件卡底色。⚠️ **暂定值 · 待裁决 D96**（同 [growthRankDot]）。
  static const Color growthRankCardBg = Color(0xFFFDEFF4);

  /// 排名变化 · 连接线渐变起点。⚠️ **暂定值 · 待裁决 D96**（同 [growthRankDot]）。
  static const Color growthRankLine = Color(0xFFE0C4D2);

  // —— 周日历条（Figma L4024-4056）——

  /// 周条 · 「今天」星期标签。Figma `#5b6ad0`。
  static const Color growthWeekTodayInk = Color(0xFF5B6AD0);

  /// 周条 · 非今日圆的描边。Figma `#ededf2`。
  static const Color growthWeekDayStroke = Color(0xFFEDEDF2);

  /// 周条 · 非今日日期数字 / 返回钮箭头。Figma `#374151`。
  static const Color growthWeekDayInk = Color(0xFF374151);

  /// 周条 · 星期标签（非今日）。Figma `#b0b7c3`。
  static const Color growthWeekDowMuted = Color(0xFFB0B7C3);

  /// 「今天」圆的渐变。Figma `135deg, #6c7ee1 0%, #a07fe8 100%`。
  static const LinearGradient growthTodayCircleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF6C7EE1), Color(0xFFA07FE8)],
  );

  /// 成长记录页 · 标题区下的分割线。Figma `#e8e4f0`。
  static const Color growthPageDivider = Color(0xFFE8E4F0);

  /// 成长时间线 · 标题墨色。Figma `#1f2937`。
  ///
  /// ⚠️ 不等于 [textPrimary]（`#111827`）—— 成长记录页的标题 / 事件卡标题
  /// 用的是更深一档的灰黑，两处不可互替。
  static const Color growthTitleInk = Color(0xFF1F2937);

  /// 成长时间线 · 日期标签墨色。Figma `#a0a7b8`。
  static const Color growthMetaInk = Color(0xFFA0A7B8);

  // —— 月网格日历（Figma ProfilePage · GrowthCalendar L2989-3086）——
  //
  // 四色 Figma 原值（L3002-3005）；rank 为 D96 暂定值。
  // 注意：月网格的配色体系与时间线**不是同一套**（Figma 两处各自定义，
  // 例如「分析」在月网格是品牌蓝、在时间线是绿）—— 按值立 Token，不合并。

  /// 月网格 · 匹配度变化。Figma `EVENT_COLORS.analysis = #4f7ef5`。
  static const Color growthGridMatchScoreDot = primaryBlue;

  /// 月网格 · 技能变化。Figma `EVENT_COLORS.resume = #a77be6`。
  static const Color growthGridSkillDot = primaryPurple;

  /// 月网格 · 新增经历。Figma `EVENT_COLORS.project = #34c759`。
  static const Color growthGridExperienceDot = success;

  /// 月网格 · 能力变化。Figma `EVENT_COLORS.capability = #ff9500`。
  static const Color growthGridCapabilityDot = warning;

  /// 月网格 · 排名变化。⚠️ **暂定值 · 待裁决 D96**（同 [growthRankDot] 的粉调）。
  static const Color growthGridRankDot = Color(0xFFFF6B9D);

  /// 月网格 · 「今天」底色。Figma `rgba(79,126,245,0.08)`。
  static const Color growthGridTodayFill = Color(0x144F7EF5);

  /// 月网格 · 选中日的活动圆点。Figma `rgba(255,255,255,0.8)`。
  static const Color growthGridSelectedDot = Color(0xCCFFFFFF);

  /// 月网格 · 当日事件卡填充。Figma `rgba(255,255,255,0.65)`。
  static const Color growthGridEventCardFill = Color(0xA6FFFFFF);

  /// 月网格 · 当日事件卡描边。Figma `rgba(255,255,255,0.55)`。
  static const Color growthGridEventCardBorder = Color(0x8CFFFFFF);

  /// 月网格事件卡 · 图标圆底色。Figma `${color}18`（alpha 0x18 ≈ 0.094）。
  static Color growthIconSurface(Color dot) => dot.withValues(alpha: 0x18 / 255);

  /// 月网格事件卡 · 图标圆描边。Figma `${color}40`（alpha 0x40 = 0.25）。
  static Color growthIconRing(Color dot) => dot.withValues(alpha: 0x40 / 255);

  /// 月网格事件卡 · 类型 Chip 底色。Figma `${color}15`（alpha 0x15 ≈ 0.082）。
  static Color growthTagSurface(Color dot) => dot.withValues(alpha: 0x15 / 255);

  /// 月网格事件卡 · 类型 Chip 描边。Figma `${color}25`（alpha 0x25 ≈ 0.145）。
  static Color growthTagRing(Color dot) => dot.withValues(alpha: 0x25 / 255);

  // ---------------------------------------------------------------------------
  // 登录 / 注册（Figma 重新导出 · 2026-10-04）
  //
  // 真值来源：`src/App.tsx` 的 `OnSplash`（L392-452）、`OnLogin`（L455-623）、
  // `OnRegister`（L661-797）。
  //
  // ⚠️ 这一节相对 Phase 4 是一次**结构性改版**，不是微调：
  // 旧版 Figma 没有登录屏、注册页只有「姓名 / 手机号 / 邮箱（选填）」，
  // 新版引入了**独立登录屏**、**密码字段**、**记住我 / 忘记密码**、
  // **微信 / QQ 社交入口**，以及一整套**方框输入**的视觉。
  // 对应的产品裁决与作废的旧裁决见 `docs/05_progress/CHANGELOG.md`。
  //
  // ⚠️ Figma 的社交按钮图标是 `public/assets/*.svg`，工程内**没有**这些资源，
  // 且项目**禁止自行下载资产** —— Flutter 侧用 Material 近似图标，
  // 与 `_RegisterAvatar` 对头像 SVG 的既有处置先例一致。
  // ---------------------------------------------------------------------------

  /// 登录 / 注册表单的字段标签。Figma：`#664293`。
  ///
  /// ⚠️ **不是** [inputLabel]（`#727272`）—— 新稿把标签从「大写加粗灰」
  /// 换成了「常规紫」，两者是两代设计，不可互换。
  static const Color authLabelInk = Color(0xFF664293);

  /// 登录页底部「点击注册」文字链。Figma：`#332065`。
  static const Color authLinkInk = Color(0xFF332065);

  /// 「记住我」/「忘记密码?」。Figma：`#352459`。
  ///
  /// ⚠️ 与 [authLinkInk]（`#332065`）**不是同一个值** ——
  /// 二者在登录页同一屏出现，Figma 分别写了。
  static const Color authMetaInk = Color(0xFF352459);

  /// 方框输入框的描边。Figma：`1px solid #c5b7d5`（登录 / 注册）。
  ///
  /// 同一色值也是社交按钮的描边（`App.tsx` L598 / L779）。
  static const Color authFieldBorder = Color(0xFFC5B7D5);

  /// 社交分隔线的细线。Figma：`#c9bcd5`。
  static const Color authDividerLine = Color(0xFFC9BCD5);

  /// 社交分隔线上的文字（`sign in with` / `Or sign up with`）。
  /// Figma：`#bdb0cc`。
  static const Color authDividerInk = Color(0xFFBDB0CC);

  /// 「记住我」勾选框的描边与对勾。Figma：`1px solid #57457c` + `#57457c`。
  static const Color authCheckboxInk = Color(0xFF57457C);

  /// 登录面板的标题「欢迎回来！」。Figma：`#090909`。
  ///
  /// ⚠️ 比 [textPrimary]（`#111827`）更纯黑，是登录页独有的墨色。
  static const Color authTitleInk = Color(0xFF090909);

  /// 社交按钮 · 微信文字。Figma：`#1872cf`。
  static const Color authWechatInk = Color(0xFF1872CF);

  /// 社交按钮 · QQ 文字。Figma：`#363333`。
  static const Color authQqInk = Color(0xFF363333);

  /// 登录页底部「还没有账号?」行。Figma：`#444`。
  static const Color authFooterInk = Color(0xFF444444);

  /// 开屏页底部「已经有账户了?」行。Figma：`#363333`。
  ///
  /// ⚠️ 与 [authQqInk]**同值不同页** —— 依本文件既定做法（页面段各自持名），
  /// 不复用那个名字。
  static const Color splashFooterInk = Color(0xFF363333);

  /// 登录页返回键（Glass 圆钮）的填充。Figma：`rgba(255,255,255,0.45)`。
  ///
  /// ⚠️ 与 [onboardingGlassFill]（`0.55`）**不是同一个值** ——
  /// 注册 / 提交简历等页顶部的进度条返回键是 0.55，
  /// 而登录页（`App.tsx` L490）单独写了 0.45。
  /// 两者形状与投影相同，只有填充浓度差 10 个百分点，**不合并**。
  static const Color authGlassFill = Color(0x73FFFFFF);

  /// 登录面板的渐变。
  /// Figma：`linear-gradient(149.75deg, #EEF2FF 8.49%, #F5F3FF 50%, #FFFFFF 91.51%)`。
  ///
  /// ⚠️ **不是** [onboardingGradient]（`142.84deg`，终点 `#FDF4FF`）——
  /// 本渐变的终点是**纯白**，角度也差近 7°。
  ///
  /// Flutter 换算：CSS `149.75deg` → `(sin θ, -cos θ) = (0.504, 0.864)`。
  static const LinearGradient authLoginPanelGradient = LinearGradient(
    begin: Alignment(-0.504, -0.864),
    end: Alignment(0.504, 0.864),
    colors: <Color>[Color(0xFFEEF2FF), Color(0xFFF5F3FF), Color(0xFFFFFFFF)],
    stops: <double>[0.0849, 0.5, 0.9151],
  );

  /// 登录 / 注册 / 开屏三处主按钮的渐变。
  /// Figma：`linear-gradient(172.01deg, #4F7EF5 0%, #A77BE6 100%)`。
  ///
  /// ⚠️ 与 [brandGradient]（`135deg`）**不是同一个角度**。
  /// 与 [progressGradient] / [brandGradientDown]（`172deg`）**色值与角度都一致** ——
  /// 按本文件既定做法（同值不同用途各自持名，见 [brandTint]）另立，
  /// 好让「改按钮配色」不会波及进度条。
  ///
  /// Flutter 换算：CSS `172.01deg` → `(0.139, 0.990)`。
  static const LinearGradient authPrimaryButtonGradient = LinearGradient(
    begin: Alignment(-0.139, -0.990),
    end: Alignment(0.139, 0.990),
    colors: <Color>[primaryBlue, primaryPurple],
  );

  // ---------------------------------------------------------------------------
  // 我的简历 · 简历历史 / 简历详情（Figma `ResumeHistoryPage` L4479-4600、
  // `ResumeDetailPage` L4599-4793，2026-10-04 导出版）
  //
  // ⚠️ 本段按本文件既定做法：**页面段各自持名**，即使与前面某处同值也不复用
  // （先例见 [brandTint] / [splashFooterInk] 的说明）。这样「改简历页配色」
  // 不会波及分析页 / Onboarding。
  // ---------------------------------------------------------------------------

  /// 简历详情页 · 分段切换器（PDF 预览 / 原始内容）**未选中**底色。
  /// Figma：`rgba(229,231,235,0.60)`（L4618）。
  static const Color resumeTabTrackFill = Color(0x99E5E7EB);

  /// 简历详情页 · 卡片上的半透明玻璃白。Figma：`rgba(255,255,255,0.90)`
  /// —— 原始内容卡（L4700）与左滑卡本体（L4455）同值。
  static const Color resumeGlassCardFill = Color(0xE6FFFFFF);

  /// 简历详情页 · PDF 卡页脚底色。Figma：`#fafafa`（L4673）。
  static const Color resumePdfFooterFill = Color(0xFFFAFAFA);

  /// 简历详情页 · PDF 卡页脚上边线。Figma：`0.5px solid #f3f4f6`（L4672）。
  static const Color resumePdfFooterBorder = Color(0xFFF3F4F6);

  /// 简历详情页 · PDF 卡页脚文字（`Resume V3 · 由 Careerly 生成` / `第 1 页`）。
  /// Figma：`#d1d5db`（L4675 / L4676）。
  static const Color resumePdfFooterInk = Color(0xFFD1D5DB);

  /// 简历详情页 · 分段条目名（左列）。Figma：`#1f2937`（L4652）。
  ///
  /// ⚠️ 与 [textBody]（`#374151`）**不是同一个灰**，不可互换。
  static const Color resumeItemLabelInk = Color(0xFF1F2937);

  /// 简历历史页 · 历史版本卡的文档图标底板（**非当前**版本）。
  /// Figma：`rgba(229,231,235,0.55)`（L4470）。
  static const Color resumeDocTileNeutralFill = Color(0x8CE5E7EB);

  /// 简历历史页 · 历史版本卡的「归档」胶囊底。Figma：`rgba(229,231,235,0.70)`（L4482）。
  static const Color resumeArchivePillFill = Color(0xB3E5E7EB);

  /// 导入简历弹层 · 「拍照上传」「粘贴文本」两个中性选项的底色。
  /// Figma：`rgba(229,231,235,0.40)`（L4961 / L4979）。
  ///
  /// ⚠️ 与 [inputSurfaceFilled]**同值**（`0x66E5E7EB`），但**语义不同**：
  /// 那个是「输入框填充」，这个是「中性选项卡」。按本段既定做法不复用。
  static const Color resumeNeutralOptionFill = Color(0x66E5E7EB);

  /// 导入简历弹层 · 「取消」按钮底。Figma：`rgba(55,59,77,0.87)`（L4993）。
  ///
  /// ⚠️ 色相等于 [surfaceDark]（`#373B4D`），但**带了 87% 透明度** ——
  /// 在玻璃面板上会透出底层模糊，与实心的 [surfaceDark] 不是一回事。
  static const Color resumeSheetCancelFill = Color(0xDE373B4D);

  /// 简历详情页 · 底部动作条的玻璃底。Figma：`rgba(255,255,255,0.92)`（L4715）。
  static const Color resumeActionBarFill = Color(0xEBFFFFFF);

  /// 简历详情页 · 底部动作条的上边线。Figma：`0.5px solid rgba(0,0,0,0.06)`（L4714）。
  ///
  /// ⚠️ 与 [rowDivider]（`0x0D000000` = 5%）**不是同一个透明度**，不可互换。
  static const Color resumeActionBarBorder = Color(0x0F000000);

  /// 分享 / 导出弹层 · 「发送邮件」选项的图标色。Figma：`#34D399`（L4785）。
  ///
  /// ⚠️ 与 [success]（`#34C759`）**不是同一个绿** —— 原型在这里用了
  /// Tailwind 的 `emerald-400`，不是它自己的 success 色。
  static const Color resumeShareMail = Color(0xFF34D399);

  /// 分享 / 导出弹层 · 「发送邮件」选项的底色。
  /// Figma：`{ #34D399 }15`（图标色的 8% —— 三个选项卡同一算法，L4774）。
  static const Color resumeShareMailFill = Color(0x1534D399);

  // ---------------------------------------------------------------------------
  // 分析页 · 顶部「新建分析 | 历史分析」切换器
  // （Figma `AnalysisHome` L1511-1539，2026-10-04 导出版）
  //
  // ⚠️ 与简历详情页的分段切换器（[resumeTabTrackFill] / `#373b4d`）**不同款**：
  // 那个是实心浅灰轨道 + 深色选中段；这个是**毛玻璃轨道**（blur 18）
  // + 深色选中段。两者不可互换。
  // ---------------------------------------------------------------------------

  /// 分析页 · 切换器轨道底。Figma：`rgba(248,248,248,0.28)`（L1515）。
  ///
  /// ⚠️ 这是**近白**（`#f8f8f8`）而不是浅蓝 —— 与前几版的
  /// `primaryBlueSurface` 观感差别明显。
  static const Color analysisSegmentedTrackFill = Color(0x47F8F8F8);

  /// 分析页 · 切换器轨道描边。Figma：`1px solid rgba(255,255,255,0.55)`（L1516）。
  static const Color analysisSegmentedTrackBorder = Color(0x8CFFFFFF);

  /// 分析页 · 切换器**未选中**段文字。Figma：`#B3B3B3`（L1529）。
  static const Color analysisSegmentedIdleInk = Color(0xFFB3B3B3);

  /// 分析页 · 切换器**选中**段文字。Figma：`#F0F4FF`（L1529）。
  ///
  /// ⚠️ **不是纯白** —— 它是带一点冷调的近白。底是 [surfaceDark]，
  /// 两者相配才是设计稿的观感。
  static const Color analysisSegmentedActiveInk = Color(0xFFF0F4FF);
}
