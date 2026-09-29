import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Careerly 字体 Token。
///
/// ## 字体决策（Phase 0 O1 / Phase 1 §二）
///
/// - 中文 UI 文案统一使用 **Noto Sans SC**。
/// - 英文 / 数字字体方案在 Phase 2 确认，本阶段不强行绑定。
/// - Logo 属于独立 Brand Asset，**不属于**本 Token。
///
/// ## ⚠️ 字体资源缺口（Phase 1 §11.2）
///
/// 当前工程内 **不存在** Noto Sans SC 字体文件，且 Phase 1 明确禁止自行从网络下载。
/// 因此本 Token 的处理方式是：
///
/// 1. 建立完整的 Typography Token（本文件）
/// 2. 在 Token 与 Theme 中**明确声明** `Noto Sans SC`
/// 3. 记录字体资源缺口（见 `assets/fonts/README.md` 与 `docs/phase_1_report.md`）
/// 4. **不使用其他中文字体偷偷替代产品决策**
///
/// 在字体文件补齐之前，运行时会由平台回退渲染——这是**已知且已上报**的缺口，
/// 不是本 Token 的字体选择。字体文件就位后只需注册 pubspec，本文件无需改动。
///
/// ## 字号来源
///
/// Figma Make 使用了 15 个非标字号（9/10/11/12/13/14/15/17/18/22/24/28/30/40），
/// 依据 Baseline §6.2，Flutter 侧**重新归纳为统一 Type Scale**，不 1:1 抄原型。
abstract final class AppTypography {
  // ---------------------------------------------------------------------------
  // 字体族
  // ---------------------------------------------------------------------------

  /// 中文 UI 字体族名。必须与 pubspec 中 `fonts.family` 完全一致。
  static const String fontFamilyChinese = 'Noto Sans SC';

  /// 数字 / 英文 UI 字体族。
  ///
  /// Phase 2 确认最终方案前保持为 `null`，
  /// 此时 material 会沿用 [fontFamilyChinese]（即与正文字体一致）。
  static const String? fontFamilyNumeric = null;

  /// Careerly 全局默认字体族。
  static const String fontFamily = fontFamilyChinese;

  // ---------------------------------------------------------------------------
  // Type Scale
  //
  // 每个角色都是一个“完整样式”，业务页面直接取用，不再自行叠加字号/字重。
  //
  // ⚠️ **整节都是归纳值 · 待视觉验证**
  //    → **待裁决 · D40**（集中登记见 `CURRENT_STATUS.md` §3.6）
  //
  // Figma 里**没有 Type Scale** —— 它是 22 个零散字号
  // （9/10/11/12/13/14/15/16/17/18/20/21/22/24/26/28/30/36/40/48/50/56），
  // 且 `text-[Npx]` 与内联 `fontSize` 两套写法混用。出现最多的三档是
  // **11 / 12 / 13px**。
  //
  // 下面 11 个角色是 Flutter 侧**重新归纳**出来的，`fontSize` 未必等于
  // 任何一处 Figma 原值；**行高与字距更是完全没有来源**（Figma 未定义）。
  //
  // 影响面：**全局**。若实际页面上字号层级观感不对，改本节即可。
  // 注意：组件级角色（`buttonPrimary` / `chipMedium` 等）是 Figma 原值，
  // **不在**归纳范围内。
  // ---------------------------------------------------------------------------

  /// 大标题：Onboarding 主标题、重大结果页标题。
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// 页面主标题。
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// 区块标题 / 卡片主标题。
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 次级标题。
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 正文。
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 正文（加强），用于卡片内的关键正文。
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 辅助正文。
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 标签：按钮文字、Chip、导航文字。
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 小标签 / 微文案：时间戳、脚注。
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 数字强调：匹配度分数、排名、统计值。
  ///
  /// 使用 tabular figures，保证数字在动画/列表中不跳动。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D38）** —— `fontSize: 32` **不在 Figma 的 22 个字号里**
  /// （最接近的是 30 与 36，各出现 1 次）。匹配度分数是 Careerly 的
  /// 核心视觉锚点，**这个字号尤其需要真实页面验证**。
  static const TextStyle numeric = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 32,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// 小号数字强调（列表行内的分数）。
  static const TextStyle numericSmall = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 20,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  // ---------------------------------------------------------------------------
  // 底部导航 AI 入口（Figma `App.tsx` BottomNav）
  //
  // Figma 原文用的是 `Plus Jakarta Sans` / `Inter`；按 §8.3，
  // 英文 / 数字字体族在 Phase 2 才定案，此处仍走 [fontFamily]，
  // 只把**字号 / 字重 / 行高 / 颜色**固化下来。
  // ---------------------------------------------------------------------------

  /// AI 浮球内的星形字符 `✦`。Figma `22px / normal / line-height 24px`。
  static const TextStyle navAiGlyph = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 24 / 22,
    fontWeight: FontWeight.w400,
    color: AppColors.textInverse,
  );

  /// AI 浮球内的文字标签。Figma `9px / bold / line-height 13.5px`。
  static const TextStyle navAiLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.navAiLabel,
  );

  // ---------------------------------------------------------------------------
  // 按钮 / Chip（Phase 2 组件专用）
  //
  // Figma 的按钮与 Chip 字号不在正文 Type Scale 上（15/14/12/11），
  // 若在组件里写死就会出现「组件层绕过 Token」的硬编码。
  // 因此按底部导航 AI 入口的先例（见上方 navAiGlyph / navAiLabel），
  // 把组件级角色也固化进 Typography Token。
  // ---------------------------------------------------------------------------

  /// 主按钮文字。Figma `PrimaryBtn`：`15px / bold`。
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
  );

  /// 次按钮文字。Figma `SecondaryBtn`：`14px / semibold / #4F7EF5`。
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );

  /// 小号 Chip 标签。Figma 多数为 `11px / semibold`。
  ///
  /// 基色为中性色；各语义变体通过 [onSurfaceVariant] 换色。
  static const TextStyle chipSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// 中号 Chip 标签。Figma 多数为 `12px / medium`。
  static const TextStyle chipMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Input（Phase 2 · 输入组件）
  //
  // 同为组件级角色，全部是 Figma 原值，**不在** D40 的归纳范围内。
  // 真值来源：`App.tsx` L466-474（`LABEL` / `INPUT_BASE`）与各内联表单。
  // ---------------------------------------------------------------------------

  /// Onboarding 表单的大写标签。Figma `14px / bold / #727272 / ls 0.3px`。
  ///
  /// ⚠️ Figma 同时声明了 `text-transform: uppercase`，本 Token **未施加** ——
  /// Figma 自己的标签文案是中文（「姓名」「手机号」），uppercase 对中文无效果，
  /// 强行 `toUpperCase()` 只会在拉丁字母场景产生与设计稿不符的结果。
  /// 该取舍登记为 **待裁决 · D47**，见 `docs/05_progress/` 待裁决清单 §3.1。
  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 16.5 / 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.inputLabel,
  );

  /// 工作台内联表单的行内标题。Figma `12px / semibold`。
  ///
  /// 基色为品牌蓝；紫色变体通过 [onSurfaceVariant] 换色。
  static const TextStyle inputLabelInline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );

  /// Onboarding 输入值。Figma `INPUT_BASE`：`16px / regular / #111827`。
  ///
  /// ⚠️ `16px` **不在正文 Type Scale 上**（[body] 是 15）——
  /// 这是 Figma 的原值，不是归纳。
  static const TextStyle inputFieldUnderline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 紧凑输入值（工作台内联 / a-jd-step）。
  /// Figma `text-[13px] leading-relaxed` —— 行高 `1.625`。
  static const TextStyle inputFieldCompact = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.625,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 输入框辅助说明 / 字数计数。Figma `text-[11px]`。
  static const TextStyle inputHelper = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.inputHelper,
  );

  // ---------------------------------------------------------------------------
  // Onboarding（Phase 4 批 1）
  //
  // 同为组件级角色，全部是 Figma 原值，**不在** D40 的归纳范围内。
  // 真值来源：`App.tsx` L366-425（`OnSplash`）/ L460-560（`OnRegister`）。
  //
  // ⚠️ 这一节的字号（40 / 26）**不在**上方 Type Scale 上，
  // 行高（1.5 / 1.23 / 1.54）也是 Figma 逐条内联给出的 ——
  // 因此必须固化成角色，不能在页面里写死（CLAUDE.md §8.2）。
  // ---------------------------------------------------------------------------

  /// 开屏 Logo 文字「Careerly」。
  /// Figma `40px / bold / line-height 60px / letter-spacing -1px`。
  ///
  /// ⚠️ 该文字在 Figma 中是**渐变填充**（[AppColors.splashTitleGradient]），
  /// 本角色的 `color` 只是渐变不可用时的兜底。
  /// 填充由页面用 `ShaderMask` 施加。
  static const TextStyle splashBrandTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 1.5,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textInverse,
  );

  /// 开屏品牌标语「看见能力 跨越 Gap / 记录成长」。
  /// Figma `22px / bold / line-height 33px / #111827`。
  ///
  /// ⚠️ Figma 给第二行单独写了 `line-height: 37px`（第一行 33px），
  /// 这是原型里的手写间距而非两套样式，本角色**统一取 33px**。
  static const TextStyle splashTagline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 开屏说明文案「你的职业成长，从看见自己开始。」
  /// Figma `15px / normal / line-height 24px / #6B7280`。
  static const TextStyle splashDescription = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Onboarding 表单页主标题。Figma `26px / w900 / line-height 32px / #111827`。
  ///
  /// ⚠️ `w900` 在 Careerly 其他位置**没有出现过**（正文最高 w700），
  /// 这是 Onboarding 特有的重量级标题。
  static const TextStyle onboardingTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    height: 32 / 26,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  /// Onboarding 表单页副标题。Figma `13px / normal / line-height 20px / #6B7280`。
  static const TextStyle onboardingSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Onboarding（Phase 4 批 2 —— 提交简历 / 解析 / 确认）
  //
  // 同为**组件级角色，全部是 Figma 原值**，不在 D40 的归纳范围内。
  // 真值来源：`App.tsx` L747-800（`OnResume`）/ L806-920（`OnParsing`）/
  // L926-981（`OnConfirm`）。
  //
  // ⚠️ 本节的字号（24 / 16 / 15 / 14 / 13 / 12 / 11）与字重（900 / 700 /
  // 400）都是 Figma 逐条内联给出的，**多个落在上方 Type Scale 之外**
  // （例如 15/w700 与 `bodyStrong` 的 15/w600 不同）。因此必须固化成角色，
  // 不能在页面里写死（CLAUDE.md §8.2）。
  //
  // ⚠️ **`onboardingTitle`（26/w900/lh32）与 [onboardingPageHeading]
  // （24/w900/lh36）是 Figma 的两个不同取值** —— 注册页与提交简历页的
  // 主标题字号、行高都不同。此处**不合并**（采纳 Figma），已登记
  // **待裁决 · D68**（`docs/05_progress/TODO.md` §3.1）。
  // ---------------------------------------------------------------------------

  /// 提交简历页主标题。Figma `OnResume`：
  /// `24px / w900 / line-height 36px / #111827`。
  static const TextStyle onboardingPageHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 36 / 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  /// 卡片内主标题。Figma `OnResume` 上传卡：
  /// `15px / bold / #111827`（无显式行高）。
  static const TextStyle onboardingCardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 二级说明文字。Figma `OnResume` 上传卡副行 / 清单条目 /
  /// `OnConfirm` 行说明：`12px / normal`。
  ///
  /// 基色为弱灰；各语义变体通过 [onSurfaceVariant] 换色。
  static const TextStyle onboardingCaption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 区块小标题 / 步骤名。Figma：`13px / bold`。
  ///
  /// 同时服务于 `OnResume` 的「AI 将自动提取」与 `OnParsing` 的步骤标签
  /// —— 两者字号字重相同，仅颜色随状态变化。
  static const TextStyle onboardingSectionLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  /// 顶部栏标题 / 汇总数值。Figma `OnParsing` 顶栏 `16px / bold`，
  /// `OnConfirm` 数量 `16px / bold` —— 同值，合并为一个角色。
  static const TextStyle onboardingBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 结果页主结论。Figma `OnParsing` 完成态「解析完成！」：
  /// `18px / bold / #34C759`。
  ///
  /// 基色为成功色；若需中性展示，通过 [onSurfaceVariant] 换色。
  static const TextStyle onboardingResultLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  /// 结果页主标题。Figma `OnConfirm`「你的职业档案已建立！」：
  /// `22px / bold / #111827`。
  ///
  /// ⚠️ 与 [orbValue] **同字号不同色**（那个是球内的白色读数）；
  /// 与 [onboardingPageHeading]（24/w900）也不同。三者不可互换。
  static const TextStyle onboardingHeadline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 汇总行序号圆内的数字。Figma `OnConfirm`：`12px / bold / white`。
  ///
  /// ⚠️ 与 [stepBadgeNumber]（11/w700/白）**字号不同** ——
  /// 一个是解析步骤徽标，一个是汇总行序号，设计稿分开给了两个值。
  static const TextStyle onboardingSummaryIndex = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// 列表行标题。Figma `OnConfirm` 汇总行：`14px / bold / #111827`。
  static const TextStyle onboardingRowTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 无底次要动作的文字。Figma `OnParsing` 的「退出分析」：
  /// `14px / normal / #6B7280`。
  ///
  /// ⚠️ 与 `buttonSecondary`（`14px / w600 / #4F7EF5`）**不是同一个角色**
  /// —— 字重与颜色都不同，不可互换。
  static const TextStyle onboardingTextAction = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 白描边按钮的文字。Figma `OnResume`「粘贴简历文本」：
  /// `15px / normal / #4F7EF5`。
  ///
  /// ⚠️ 与 `buttonPrimary`（15/w700/白）**同字号不同字重**；
  /// 与 `buttonSecondary`（14/w600）**字号也不同**。三者不可互换。
  static const TextStyle onboardingOutlineAction = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryBlue,
  );

  /// 光晕球内的百分比。Figma `OnParsing`：`22px / bold / white`。
  static const TextStyle orbValue = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// 步骤卡里**当前步骤**的副行。Figma `OnParsing`：`11px / normal / #6B7280`。
  ///
  /// ⚠️ 与 [stepBadgeNumber]（11/w700/白）**同字号不同字重与颜色**；
  /// 与 [onboardingCaption]（12/w400）**也不同字号**。三者不可互换。
  static const TextStyle onboardingStepSub = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 步骤徽标内的序号。Figma `OnParsing`：`11px / bold`。
  static const TextStyle stepBadgeNumber = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// 大号百分比读数。Figma `OnParsing`：`36px / bold / #111827`。
  ///
  /// ⚠️ 与 [numeric]（`32px`）**不是同一档**。Figma 原值是 36，
  /// 而 [numeric] 的 32 是 Flutter 侧归纳值（**待裁决 · D38**）。
  /// 两者当前**并存**：本角色服务解析页，[numeric] 服务匹配度分数。
  static const TextStyle numericLarge = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 36,
    height: 1.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  // ---------------------------------------------------------------------------
  // 首页（Phase 5）
  //
  // 真值来源：Figma `HomePage`（`src/App.tsx` L987-1182）。
  //
  // 同为**组件级角色，全部是 Figma 原值**，不在 D40 的归纳范围内。
  // 首页的字号（56 / 22 / 21 / 17 / 16 / 15 / 14 / 12 / 11）与字重
  // （700 / 600 / 500 / 400）多为逐处内联，**多档落在上方 Type Scale 之外**
  // （例如 21px、17px、14/w700），因此必须固化成角色。
  //
  // ⚠️ **Figma 未给行高的角色，本节的 `height` 保持 `null`**（不替它编一个值）
  // —— 首页是 Figma 里行高最不完整的一屏：Hero 的时钟行、四张卡的标题、
  // 胶囊 Tab 都没有 `line-height`。这类角色由字体默认行高决定。
  //
  // ⚠️ 三态**共用**本节全部角色（D64 ①bis：只换文字、不换视觉），
  // 因此角色命名按**位置**（`homeHeroTitle`）而不是按状态。
  // ---------------------------------------------------------------------------

  /// 首页顶部的身份小标签。Figma：`12px / w400 / line-height 18px / #6B7280`。
  static const TextStyle homeLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 首页主标题（「<名字> 的职业主页」）。
  /// Figma：`22px / w700 / line-height 27.5px / #111827`。
  ///
  /// ⚠️ 与 [title]（22 / lh 1.3）**同字号不同行高**；
  /// 与 [onboardingHeadline]（22 / w700 / lh 1.4）也不同行高。三者不可互换。
  static const TextStyle homePageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 27.5 / 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 首页头像内的首字母。Figma：`17px / w700 / white`。
  static const TextStyle homeAvatarGlyph = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
  );

  /// Hero 卡的小标签（「最匹配岗位」）。
  /// Figma：`11px / w500 / line-height 16.5px / letter-spacing 1.1px /
  /// rgba(255,255,255,0.6)` 且声明 `text-transform: uppercase`。
  ///
  /// ⚠️ 与 [inputLabel] 同类的取舍：Figma 声明的 `uppercase` **未施加**
  /// —— 该标签在三态里的文案都是中文，uppercase 对中文无效，
  /// 强行 `toUpperCase()` 只会在混排拉丁字母时产生与设计稿不符的结果。
  static const TextStyle homeHeroLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.1,
    color: AppColors.onBrandMuted,
  );

  /// Hero 卡的主标题（岗位名）。Figma：`21px / w700 /
  /// line-height 26.25px / letter-spacing 2px / white`。
  static const TextStyle homeHeroTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 21,
    height: 26.25 / 21,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: AppColors.textInverse,
  );

  /// Hero 卡的附加说明行（岗位时间 / 三态的说明句）。
  /// Figma：`12px / w400 / rgba(255,255,255,0.6)`，**未给行高**。
  static const TextStyle homeHeroMeta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onBrandMuted,
  );

  /// Hero 卡的大号读数（`86`）。Figma：`56px / w700 / line-height 56px / white`。
  static const TextStyle homeHeroScore = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 56,
    height: 1,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// Hero 卡读数的百分号。Figma：`22px / w700 / line-height 33px /
  /// rgba(255,255,255,0.8)`。
  static const TextStyle homeHeroScoreUnit = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 22,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.onBrandStrong,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// Hero 卡读数的标签（「匹配度」）。
  /// Figma：`12px / w400 / line-height 18px / rgba(255,255,255,0.55)`。
  static const TextStyle homeHeroScoreLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.onBrandFaint,
  );

  /// Hero 卡的变化行（「▲ 较上次+8%」）。
  /// Figma：`12px / w700 / line-height 19.5px / white`。
  static const TextStyle homeHeroDelta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.625,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
  );

  /// Hero 卡内的深色小按钮（「查看分析」）。
  /// Figma：`14px / w600 / white`，**未给行高**。
  static const TextStyle homeHeroButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
  );

  /// 2×2 卡片的主标题。Figma：`15px / w700 / letter-spacing 0.75px /
  /// #181a20`，**未给行高**。
  ///
  /// ⚠️ Figma 声明的是 `Inter:Bold`，但文案是中文
  /// （「问问AI」/「当前状态」…）—— 依 `CLAUDE.md` §8.3「中文统一
  /// Noto Sans SC」，本角色**走中文字体族**，不采纳 Inter。
  static const TextStyle homeCardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.75,
    color: AppColors.homeCardTitle,
  );

  /// 2×2 卡片的描述行。Figma：`11px / w500 / line-height 15px`。
  ///
  /// 基色为中性灰；高亮行通过 [onSurfaceVariant] 换成
  /// [AppColors.homeCardHighlight] / [AppColors.homeCardPurple] / [AppColors.success]。
  static const TextStyle homeCardDesc = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 15 / 11,
    fontWeight: FontWeight.w500,
    color: AppColors.homeCardDesc,
  );

  /// 胶囊 Tab 的文字。Figma：`14px / w700`，**未给行高**。
  ///
  /// 基色为深色（白底那颗 Tab）；深底那颗通过 [onSurfaceVariant] 换成白色。
  static const TextStyle homeTabLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 区块标题（「岗位匹配变化」）。
  /// Figma：`16px / w700 / line-height 24px / #111827`。
  ///
  /// 三态共用：State 01 / 02 用它渲染「开始你的第一次分析」
  /// —— 同一位置、同一角色，只换文字（D64 ①bis）。
  static const TextStyle homeSectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 岗位列表的排名列。Figma：`15px / w400 / #000`。
  static const TextStyle homeJobRank = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.homeJobRank,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// 岗位名。Figma：`14px / w700 / line-height 21px / #111827`。
  static const TextStyle homeJobTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 岗位匹配度数字。Figma：`14px / w700` + 渐变文字填充。
  ///
  /// `color` 只是渐变不可用时的兜底；实际渲染由页面用 `ShaderMask`
  /// 施加 [AppColors.homeMatchTextGradient]。
  static const TextStyle homeJobScore = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBlue,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// 岗位变化 Chip 的文字。Figma：`11px / w600`。
  ///
  /// 基色为成功绿；无变化时通过 [onSurfaceVariant] 换成中性灰。
  static const TextStyle homeJobDelta = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  // ---------------------------------------------------------------------------
  // 首页 · 空态（State 01 / 02）的补齐角色
  //
  // ⚠️⚠️ **Figma 里没有空态**（`HomePage` L987-1182 全文无 Empty 分支），
  // 因此这两条**没有 Figma 依据**，是 Flutter 侧为 D64 的 State 01 / 02
  // 补的**槽位映射**：把 D64 给的文案放进「岗位匹配变化」卡原有的槽位上。
  //
  // ⚠️ **暂定值 · 待视觉验证** —— 集中登记见 `CURRENT_STATUS.md` §3.6，
  // 裁决登记 **待裁决 · D79**（`docs/05_progress/TODO.md` §3.1）。
  // 若实际观感不对，改这两条即可，页面不动。
  // ---------------------------------------------------------------------------

  /// 空态下「开始你的第一次分析」的说明句。
  ///
  /// 类比 [homeCardDesc]，但为空态正文，取 12px 而非 11px。
  static const TextStyle homeEmptyBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 空态下的行动行（「分析第一个岗位 →」）。
  ///
  /// 类比 [homeTabLabel]（14 / w700），换成品类色以示可点。
  static const TextStyle homeEmptyAction = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBlue,
  );

  // ---------------------------------------------------------------------------
  // 我的（Phase 8）
  //
  // 真值来源：Figma `ProfilePage`（`src/App.tsx` L3102-3339）、
  // `CareerAssetsPage`（L3342-3634）、`WorkExperiencePage` / `WorkDetailPage`
  // （L3636-3720）、`ProjectExperiencePage` / `ProjectDetailPage`（L3722-3815）。
  //
  // 同为**组件级角色，全部是 Figma 原值**，不在 D40 的归纳范围内。
  //
  // ⚠️ **Figma 未给行高的角色，本节的 `height` 保持 `null`**（不替它编一个值）。
  // Figma 在「我的」这一族页面里多数节点写的是 `lineHeight: "normal"` 或
  // 干脆不写，只有明确给了 `line-height` 的才有值。
  //
  // ⚠️ **同一个字号在本节出现多档字重是 Figma 的原样**，不是笔误：
  // 13px 就有 w400（正文）/ w700（小标题）两种，14px 有 w400 / w600 / w700 三种。
  // 各档对应的行高、颜色也不同，**不可互相替代**。
  //
  // ⚠️ 角色的颜色是**默认值**，不是唯一值。同一角色在不同卡上换色（例如
  // 资产分组标题在白卡 / 深卡 / 紫卡上是三种颜色）由调用方通过
  // [onSurfaceVariant] 替换 —— 与首页段同一套做法。
  // ---------------------------------------------------------------------------

  /// 我的 · 头部品牌字标「Careerly」。
  ///
  /// ⚠️ Figma 在这里放的是一张**位图 Logo**（109×27 的裁剪框，
  /// `ProfilePage` L3139-3143 → `imgCareerlyLogo`），仓库内**没有**该资源。
  /// 依 `CLAUDE.md` §3.1「Figma 有视觉，但 Flutter 没有对应实现方式
  /// → 重新实现，而不是放弃视觉」，本角色是**文字字标的近似实现** ——
  /// 与开屏页 [splashBrandTitle] 同一套做法（`ShaderMask` + 品牌渐变）。
  ///
  /// 字号 22 是**为填满 109×27 的框反推的**，不是 Figma 给出的值
  /// （图上没有文字节点，只有图片）。缺失资源已登记 **K16**。
  static const TextStyle profileHeaderWordmark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1,
    color: AppColors.textInverse,
  );

  /// 我的 · 资产卡左上角玻璃底板里的「⭐」。
  /// Figma：`18px`（`ProfilePage` L3215，`<span style={{fontSize: 18}}>⭐</span>`）。
  ///
  /// ⚠️ 这是原型的**字符型图标**，不是 SVG，因此本项目照原样用字符渲染 ——
  /// 换成 `Icons.star_rounded` 会得到与原型不同的字形。
  static const TextStyle profileAssetGlyph = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  /// 我的 · 头像字母。Figma：`28px / w700 / line-height 33px / white`。
  static const TextStyle profileAvatarGlyph = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 33 / 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// 我的 · 信息卡里的姓名。Figma：`18px / w700 / #181a20`。
  static const TextStyle profileName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.profileNameInk,
  );

  /// 我的 · 信息卡里的账号。Figma：`12px / w400 / #6e717c`。
  static const TextStyle profileHandle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.profileMetaGray,
  );

  /// 我的 · 会员徽章文字（「V1会员」）。Figma：`11px / w700 / white`。
  ///
  /// ⚠️ 徽章文案本身语义未定 → **待裁决 · D87**。
  static const TextStyle profileMemberBadge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// 我的 · 统计数字。Figma：`16px / w800 / #181a20`。
  ///
  /// ⚠️ **w800 是全项目仅有的两处之一**（另一处是 [profileAssetTileValue]），
  /// 不可用 [homeHeroScore] 之类的 w700 代替。
  static const TextStyle profileStatValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.profileNameInk,
  );

  /// 我的 · 统计标签。Figma：`11px / w600 / #6e717c`。
  static const TextStyle profileStatLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.profileMetaGray,
  );

  /// 我的 · Pro 横幅的「✦」。Figma：`20px / w400 / line-height 30px / #f2c94c`。
  static const TextStyle profileProGlyph = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 30 / 20,
    fontWeight: FontWeight.w400,
    color: AppColors.pro,
  );

  /// 我的 · Pro 横幅标题。Figma：`12px / w700 / white`。
  static const TextStyle profileProBannerTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// 我的 · Pro 横幅说明行。Figma：`10px / w400 / #f4f5fc`。
  static const TextStyle profileProBannerSub = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.profileProBannerSub,
  );

  /// 我的 · 胶囊 Tab 选中态。Figma：`14px / w600 / white`。
  ///
  /// ⚠️ 与 [profileTabLabelIdle]（w500）**字重不同** —— Figma 用字重而不是
  /// 颜色之外的手段区分选中态，两个角色不可合并。
  static const TextStyle profileTabLabelActive = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// 我的 · 胶囊 Tab 未选中态。Figma：`14px / w500 / rgba(30,31,34,0.6)`。
  static const TextStyle profileTabLabelIdle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.profileInkMuted,
  );

  /// 我的 · 资产渐变卡标题。Figma：`13px / w700 / line-height 19.5px / white`。
  static const TextStyle profileAssetsCardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 19.5 / 13,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// 我的 · 资产渐变卡副标题。Figma：`11px / w400 / line-height 16.5px / rgba(255,255,255,0.65)`。
  static const TextStyle profileAssetsCardSub = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16.5 / 11,
    fontWeight: FontWeight.w400,
    color: AppColors.profileAssetCardSub,
  );

  /// 我的 · 资产渐变卡上的「查看全部」胶囊文字。
  /// Figma：`11px / w600 / line-height 16.5px / white`。
  static const TextStyle profileAssetsPillLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16.5 / 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// 我的 · 资产子卡的数字。Figma：`17px / w800 / line-height 22px / white`。
  static const TextStyle profileAssetTileValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  /// 我的 · 资产子卡的单位（「段」/「个」/「项」）。Figma：`10px / w500 / white`。
  static const TextStyle profileAssetTileUnit = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  /// 我的 · 资产子卡的标签。Figma：`10px / w400 / line-height 15px / rgba(255,255,255,0.7)`。
  static const TextStyle profileAssetTileLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 15 / 10,
    fontWeight: FontWeight.w400,
    color: AppColors.profileAssetTileLabel,
  );

  /// 我的 · 区块标题（「我的职业成长」）。Figma：`16px / w700 / line-height 24px / #111827`。
  static const TextStyle profileSectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 我的 · 区块右侧文字动作（「查看全部 →」）。Figma：`12px / w400 / line-height 18px / #4f7ef5`。
  static const TextStyle profileSectionAction = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryBlue,
  );

  /// 我的 · 成长事件列表的日期行。Figma：`11px / w600 / #6B7280`。
  static const TextStyle profileGrowthDate = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// 我的 · 列表卡标题（「我的简历」）。Figma：`14px / w700 / line-height 21px / #111827`。
  static const TextStyle profileListCardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 我的 · 列表卡右侧状态 Chip 文字（「最新版」）。Figma：`10px / w600 / line-height 15px / #34c759`。
  static const TextStyle profileListCardChip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 15 / 10,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );

  /// 我的 · 11px 次级说明行。Figma：`11px / w400 / line-height 16.5px / #6B7280`。
  ///
  /// 本角色在四处复用（Figma 逐处写的是同一个组合）：
  /// 我的 · 列表卡副标题（L3287）、职业资产页 · 能力条标签（L3465）、
  /// 能力画像卡底部说明（L3623）。
  static const TextStyle profileSmallMeta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16.5 / 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 我的 · 11px 无行高说明行。Figma：`11px / w400 / #6B7280`（未给 `line-height`）。
  ///
  /// 两处复用：职业资产页展开面板的项目年份（L3556）、
  /// 项目经历列表的年份（L3739）。
  static const TextStyle profileMetaPlain = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 我的 · 13px 小标题。Figma：`13px / w700 / #111827`（未给 `line-height`）。
  ///
  /// 三处复用：职业资产页展开面板的经历标题（L3542）、项目名（L3555）、
  /// 荣誉名（L3575）。
  static const TextStyle profileSmallTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 我的 · 13px 正文。Figma：`13px / w400 / #6B7280`（未给 `line-height`）。
  ///
  /// 工作经历列表里的公司名（L3653）。
  static const TextStyle profileBodyMuted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 我的 · 13px 宽行高正文（`leading-relaxed`）。
  /// Figma：`13px / w400 / line-height 1.625 / #6B7280`。
  ///
  /// 三处复用：工作详情的「工作内容」（L3689）、
  /// 项目详情的「项目背景」（L3783）与「项目成果」（L3787）。
  static const TextStyle profileBodyRelaxed = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.625,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 我的 · 14px 深色正文。Figma：`14px / w400 / #111827`（未给 `line-height`）。
  ///
  /// 两处复用：工作详情的能力名（L3696）、相关项目名（L3710）。
  static const TextStyle profileBodyInk = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 二级页 · 玻璃圆返回钮那一版的大标题。
  /// Figma：`22px / w700 / #1e1f22`（`CareerAssetsPage` L3490）。
  ///
  /// ⚠️ 与 [profileTopBarTitle]（`15px`）是**同一屏族里两种顶栏字号** ——
  /// Figma 在 `CareerAssetsPage` 用大标题，在 `TopBar` 里用小标题，
  /// 由 [CareerlyTopBarStyle] 选择，不可互换。
  static const TextStyle profilePageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.profileInkDeep,
  );

  /// 二级页 · 页标题下方的说明句。Figma：`13px / w400 / #6B7280`（L3494）。
  static const TextStyle profilePageSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 二级页 `TopBar` 的「返回」文字。Figma：`14px / w600 / #4F7EF5`。
  static const TextStyle profileTopBarBack = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );

  /// 二级页 `TopBar` 的居中标题。Figma：`15px / w700 / #111827`。
  ///
  /// 与工作经历列表的经历标题（L3652）是同一个组合，共用本角色。
  static const TextStyle profileTopBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 二级页 `TopBar` 右侧文字（「4 段」/「6 个」）。
  /// Figma：`13px / w400 / #6B7280`。
  static const TextStyle profileTopBarTrailing = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 职业资产页 · 分组卡大标题（「工作经历」/「项目经历」…）。
  /// Figma：`20px / w700 / line-height 1.3`。
  ///
  /// ⚠️ 颜色由调用方按卡替换（白 / `#171827` / 白 / 白），默认给白色。
  static const TextStyle profileAssetGroupTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// 职业资产页 · 荣誉成果卡的大标题。
  /// Figma：`20px / w500 / line-height 1.3`（`awards` 一项被显式降到 500）。
  ///
  /// ⚠️ **不是** [profileAssetGroupTitle] 的换色版 —— 字重真的不同。
  static const TextStyle profileAssetGroupTitleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  /// 职业资产页 · 分组卡右侧计数（「4 段职业经历」）。
  /// Figma：`12px / w600`。颜色由调用方按卡替换。
  ///
  /// ⚠️ 用 `whiteSpace: nowrap`，不可换行。
  static const TextStyle profileAssetGroupCount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// 职业资产页 · 分组卡的日期行（「2021/6/8 - 2026/9/9」）。
  /// Figma：`12px / w400`。颜色由调用方按卡替换（白卡 / 深卡是两种 60% 墨色）。
  static const TextStyle profileAssetGroupDate = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.profileInkMuted,
  );

  /// 职业资产页 · 磨砂「查看全部」胶囊文字。
  /// Figma：`12px / w600`，白卡上是 `#171827`，其余是白色。
  static const TextStyle profileViewAllPillLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// 职业资产页 · 展开面板底部的「查看全部 →」。Figma：`12px / w600 / #4F7EF5`。
  static const TextStyle profileFrostAction = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );

  /// 职业资产页 · 能力画像卡标题。
  /// Figma：`20px / w700 / line-height 1.3 / #b4c481`。
  static const TextStyle profileCapabilityTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.profileCapabilityTitle,
  );

  /// 职业资产页 · 能力画像卡右侧提示（「点击查看」）。
  /// Figma：`12px / w600 / #a2d84c`。
  static const TextStyle profileCapabilityHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.profileAccentLime,
  );

  /// 职业资产页 · 能力画像进度条内的白字。
  /// Figma：`11px / w600 / rgba(255,255,255,0.9)`。
  static const TextStyle profileCapabilityBarLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xE6FFFFFF),
  );

  /// 职业资产页 · 能力条右侧分值。Figma：`11px / w700 / line-height 16.5px / #111827`。
  static const TextStyle profileSkillBarScore = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16.5 / 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 职业资产页 · 能力条的增量（「+5」）。Figma：`10px / w600 / line-height 15px / #34c759`。
  static const TextStyle profileSkillDelta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 15 / 10,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );

  /// 职业资产页 · 扁平技能 Chip 文字。Figma：`11px / w600 / #4F7EF5`。
  ///
  /// 与项目经历卡的「类型」Chip（L3738）是同一个组合，共用本角色。
  static const TextStyle profileBrandChipLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );

  /// 项目经历页 · 技能 Chip 文字。Figma：`10px / w500 / #A77BE6`。
  static const TextStyle profileProjectSkillChip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryPurple,
  );

  /// 工作经历页 · 时间轴上的时间区间。Figma：`10px / w500 / #6B7280`。
  static const TextStyle profileTimelinePeriod = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// 工作经历页 · 技能增量 Chip（「产品规划 +5」）。
  /// Figma：`10px / w600 / #34c759`（未给 `line-height`）。
  ///
  /// ⚠️ 与 [profileSkillDelta]（有 `line-height 15px`）**行高不同**，
  /// 不可互相替代。
  static const TextStyle profileSkillChipInk = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );

  /// 项目经历页 · 项目名。Figma：`16px / w700 / #111827`（未给 `line-height`）。
  ///
  /// ⚠️ 与 [profileSectionTitle]（16 / w700 / lh 24）**同字号同字重不同行高**。
  static const TextStyle profileProjectName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 项目经历页 · 角色行。Figma：`12px / w400 / #6B7280`。
  static const TextStyle profileProjectRole = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 项目经历页 · 卡片底部的「影响的岗位」行内文字。
  /// Figma：`11px / w600 / #34c759`。
  static const TextStyle profileJobImpactInline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );

  /// 详情页 Hero · 时间区间。
  /// Figma：`11px / w400 / white 60% / letter-spacing 0.1em`（`tracking-widest`）。
  ///
  /// ⚠️ Figma 还带了 `uppercase`，但**中文无大小写**，在 Flutter 上等价于无效果，
  /// 因此不设 `textTransform`。`letter-spacing` 保留 —— 中文加字距同样有观感差异。
  static const TextStyle profileHeroPeriod = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Color(0x99FFFFFF),
    letterSpacing: 1.1,
  );

  /// 详情页 Hero · 主标题。Figma：`22px / w700 / white`。
  static const TextStyle profileHeroTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// 工作详情 Hero · 公司名。Figma：`14px / w400 / white 75%`。
  static const TextStyle profileHeroCompany = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xBFFFFFFF),
  );

  /// 项目详情 Hero · 角色行。Figma：`13px / w400 / white 70%`。
  ///
  /// ⚠️ 与 [profileHeroCompany]（`75%`）**不是同一个透明度**。
  static const TextStyle profileHeroRole = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xB3FFFFFF),
  );

  /// 详情页 Hero · 类型 Chip 文字。Figma：`11px / w600 / white`。
  static const TextStyle profileHeroChip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// 详情页 · 信息卡小标题（「工作内容」/「相关能力」…）。
  /// Figma：`14px / w700 / #111827`（未给 `line-height`）。
  static const TextStyle profileDetailCardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 详情页 · 能力提升的增量胶囊文字。Figma：`13px / w700 / #34c759`。
  static const TextStyle profileAbilityDelta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  /// 项目详情 · 「影响的岗位匹配」小标题。Figma：`12px / w600 / #15803D`。
  static const TextStyle profileImpactTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.profileImpactTitle,
  );

  /// 项目详情 · 「影响的岗位匹配」岗位名。Figma：`14px / w600 / #111827`。
  ///
  /// ⚠️ 与 [profileBodyInk]（14 / w400）**字重不同**。
  static const TextStyle profileImpactJob = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 项目详情 · 「影响的岗位匹配」增量。Figma：`14px / w700 / #34c759`。
  static const TextStyle profileImpactDelta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  // ---------------------------------------------------------------------------
  // 会员页 / 简历历史页（Phase 8 批 1 的 P1 部分）
  // ---------------------------------------------------------------------------

  /// 会员页 Hero · 品牌眉标「Careerly Pro」。
  /// Figma：`12px / w500 / white 70% / letter-spacing 0.1em`（L4852）。
  ///
  /// ⚠️ Figma 还带 `uppercase`，中文无大小写、拉丁文已是首字母大写，
  /// 因此不设 `textTransform`（与 [profileHeroPeriod] 同一处置）。
  static const TextStyle profileProHeroEyebrow = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xB3FFFFFF),
    letterSpacing: 1.2,
  );

  /// 会员页 Hero · 主标题「让职业成长持续发生」。
  /// Figma：`28px / w700 / white`（L4853）。
  static const TextStyle profileProHeroTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// 会员页 Hero · 副标题。Figma：`13px / w400 / white 65%`（L4854）。
  static const TextStyle profileProHeroSub = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xA6FFFFFF),
  );

  /// 会员页 · 额度耗尽时那三行统计的**数值**。
  /// Figma：`12px / w700`，颜色由品牌渐变填充（`gradText`，L4881）。
  ///
  /// ⚠️ 这里给的是**兜底色**，实际渲染走 `ShaderMask` + 品牌渐变 ——
  /// 与开屏页字标 [splashBrandTitle] 同一手法。
  static const TextStyle profileProStatValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 会员页 · 权益图标底上的字符（`∞ ✦ ↗ ◈`）。
  /// Figma：`18px / w700 / white`（L4893）。
  ///
  /// ⚠️ 这是原型的**字符型图标**，不是 SVG —— 因此照原样用字符渲染，
  /// 与 [profileAssetGlyph]（「⭐」）同一处置。
  static const TextStyle profileProBenefitGlyph = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// 简历历史页 · 当前简历卡的三格统计数值。
  /// Figma：`17px / w700 / white`（L4537）。
  ///
  /// ⚠️ 与 [profileAssetTileValue]（`17px / w800`）**字重不同**，不可互换。
  static const TextStyle profileResumeStatValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// 简历历史页 · 当前简历卡的三格统计标签。
  /// Figma：`10px / w400 / white 65%`（L4538）。
  static const TextStyle profileResumeStatLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Color(0xA6FFFFFF),
  );

  // ---------------------------------------------------------------------------
  // 专业技能页 / 奖项页 / 能力页（Phase 8 批 2）
  // ---------------------------------------------------------------------------

  /// 专业技能页 · 技能 Chip 文字。Figma：`13px / w500 / #4F7EF5`（L3827）。
  static const TextStyle profileSkillsChipLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryBlue,
  );

  /// 奖项页 · 奖杯图标。Figma：`22px`（L3849）。
  static const TextStyle profileAwardGlyph = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
  );

  /// 奖项页 · 荣誉名。Figma：`15px / w700 / #111827`（L3852）。
  ///
  /// ⚠️ 与 [profileDetailCardTitle]（14 / w700）**字号不同**，不可互换。
  static const TextStyle profileAwardName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 奖项页 · 年份胶囊文字。Figma：`11px / w600 / #FF9500`（L3853）。
  static const TextStyle profileAwardYearChip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.warning,
  );

  /// 奖项页 · 颁发机构。Figma：`12px / w400 / #6B7280`（L3854）。
  static const TextStyle profileAwardMeta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 奖项页 · 一句话说明。Figma：`12px leading-relaxed`（L3855）。
  ///
  /// ⚠️ 与 [profileAwardMeta] **同字号不同行高**（`1.625` vs 默认）——
  /// 机构是一行、说明是整段，原型确实分开写。
  static const TextStyle profileAwardDescription = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.625,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 能力页 · 卡内小标题（「能力雷达图」/「能力详情」）。
  /// Figma：`15px / w700 / #111827`（L3860 / L3875）。
  static const TextStyle profileCapabilityCardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 能力页 · 雷达图图例文字。Figma：`10px / w400 / #6B7280`（L3862）。
  static const TextStyle profileRadarLegendLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 能力页 · 雷达图轴标签。Figma：`9.5px / w600 / #6B7280`（`RadarChart` L354）。
  static const TextStyle profileRadarAxisLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// 能力页 · 能力名。Figma：`13px / w600 / #111827`（L3885）。
  static const TextStyle profileCapabilityName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 能力页 · 能力分值。Figma：`15px / w700 / #111827`（L3887）。
  static const TextStyle profileCapabilityScore = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 能力页 · 增量胶囊文字（「+5」）。Figma：`11px / w700 / #34C759`（L3888）。
  static const TextStyle profileCapabilityDeltaChip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  /// 能力页 · 无增量时的「—」胶囊文字。Figma：`11px / w400 / #6B7280`（L3891）。
  static const TextStyle profileCapabilityFlatChip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 能力页 · 能力条下的脚注（「上次 80 → 现在 85」）。
  /// Figma：`10px / w400 / #6B7280`（L3904）。
  static const TextStyle profileCapabilityFootnote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // 变体辅助：只做颜色替换，不改动字号 / 字重 / 行高
  //
  // 目的：避免业务页面出现 fontSize / fontWeight / fontFamily 硬编码。
  // ---------------------------------------------------------------------------

  static TextStyle onSurfaceVariant(TextStyle base, Color color) =>
      base.copyWith(color: color);
  /// Material `TextTheme` 映射。
  ///
  // ---------------------------------------------------------------------------
  // 分析 —— 「AI 正在分析」与「更新分析」（Phase 6）
  //
  // 真值来源：Figma `AnalysisProcessing`（L1927-2115）与结果页的
  // 更新分析 Bottom Sheet（L2298-2347）。**全部为 Figma 逐位原值**。
  //
  // ⚠️ 与 `onboarding*` 一节的关系：两屏的字号**不共用** ——
  // 分析屏的大百分比是 48px，而 on-parsing 的球内读数是 22px
  // （即 `orbValue`）。因此不互相引用。
  // ---------------------------------------------------------------------------

  /// 标题栏标题（「AI 正在分析」）。Figma `16px` / `w700` / `textPrimary`。
  ///
  /// ⚠️ 与 [onboardingBarTitle] **同值但独立** —— 两屏的标题栏是各自
  /// 设计稿里的独立条目，与 `analysisEaseExponent` 的处理同理：
  /// 共用会让「改一屏影响另一屏」。若日后确认二者恒等，可合并（另立裁决）。
  static const TextStyle analysisTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 上下文胶囊的说明字（「正在分析」）。Figma `11px` / `textSecondary`。
  static const TextStyle analysisChipLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// 上下文胶囊的读数（「1 份简历 × N 个目标岗位」）。
  /// Figma `11px` / `w600` / `primaryBlue`。
  static const TextStyle analysisChipValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );

  /// 大百分比读数。Figma `48px` / `w700` / `letter-spacing: -2px` / `line-height: 1`。
  static const TextStyle analysisPercent = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 48,
    height: 1,
    letterSpacing: -2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// 大百分比的「%」。Figma `22px` / `w700` / `textSecondary`。
  static const TextStyle analysisPercentUnit = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 22,
    height: 1,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  /// 当前任务行。Figma `13px` / `textSecondary`；
  /// 完成态换 [AppColors.success] 且升到 `w600`，由
  /// `AppTypography.onSurfaceVariant` 处理颜色。
  static const TextStyle analysisTaskLine = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// 时间线卡的区块标题「分析进度」。
  /// Figma `11px` / `w600` / `letter-spacing: 0.04em`。
  ///
  /// `0.04em × 11px = 0.44px` —— 固化为绝对值。
  static const TextStyle analysisSectionLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.4,
    letterSpacing: 0.44,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// 步骤标题。Figma `14px` / `w600` / `leading-snug`（1.375）。
  static const TextStyle analysisStepLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.375,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 步骤状态（已完成 · 100% / 进行中 · N% / 等待中）。
  /// Figma `10px` / `w600`。
  static const TextStyle analysisStepStatus = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.analysisStepStatusIdle,
  );

  /// 步骤副行。Figma `11px` / `leading-relaxed`（1.625）。
  static const TextStyle analysisStepSub = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.625,
    color: AppColors.analysisStepSubInk,
  );

  /// 步骤徽标里的序号。Figma `11px` / `w700`。
  static const TextStyle analysisStepBadge = TextStyle(
    fontFamily: fontFamilyNumeric ?? fontFamilyChinese,
    fontSize: 11,
    height: 1,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// 「退出分析」按钮文字。Figma `13px` / `w500`。
  static const TextStyle analysisExitAction = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.analysisExitInk,
  );

  /// 退出确认 / 更新分析 Sheet 的标题。Figma `17px` / `w700`。
  static const TextStyle analysisSheetTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Sheet 的说明行。Figma `13px` / `leading-relaxed`（1.625）。
  static const TextStyle analysisSheetBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.625,
    color: AppColors.textSecondary,
  );

  /// Sheet 选项卡的标题。Figma `14px` / `w700`。
  static const TextStyle analysisSheetOptionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Sheet 选项卡的说明。Figma `12px`。
  static const TextStyle analysisSheetOptionDesc = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Sheet 的主按钮文字。Figma `14px` / `w600` / 白。
  static const TextStyle analysisSheetPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
  );

  /// Sheet 的次级 / 取消按钮文字。Figma `14px` / `w500`。
  static const TextStyle analysisSheetGhost = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // 成长足迹（我的 → 成长足迹 Detail · Figma GrowthRecordPage L3973-4114）
  // ---------------------------------------------------------------------------

  /// 成长记录页 · 大标题。Figma：`22px / w800 / #1f2937 / lh 28px`。
  static const TextStyle growthPageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w800,
    color: AppColors.growthTitleInk,
  );

  /// 成长记录页 · 副标题。Figma：`13px / w400 / #9ca3af / lh 18px`。
  static const TextStyle growthPageSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 周日历条 · 月份标签。Figma：`12px / w600 / #9ca3af / ls 0.5 / lh 16px`。
  static const TextStyle growthWeekMonthLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
  );

  /// 周日历条 · 星期标签（非今日）。Figma：`11px / w500 / #b0b7c3`。
  static const TextStyle growthWeekDowLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.growthWeekDowMuted,
  );

  /// 周日历条 · 星期标签（今日）。Figma：`11px / w700 / #5b6ad0`。
  static const TextStyle growthWeekDowLabelToday = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.growthWeekTodayInk,
  );

  /// 周日历条 · 日期数字（非今日）。Figma：`14px / w500 / #374151`。
  static const TextStyle growthWeekDayNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.growthWeekDayInk,
  );

  /// 周日历条 · 日期数字（今日）。Figma：`14px / w700 / white`。
  static const TextStyle growthWeekDayNumberToday = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
  );

  /// 月网格 · 月份标题。Figma：`13px / w600 / textPrimary`。
  static const TextStyle growthGridMonthTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 月网格 · 图例标签。Figma：`9px / textSecondary`。
  static const TextStyle growthGridLegendLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 月网格 · 星期标签。Figma：`10px / textSecondary / paddingBottom 4`。
  static const TextStyle growthGridDowLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 月网格 · 日期数字。Figma：`12px / w400 / textPrimary`；
  /// 今天 = `w700 / primaryBlue`、选中 = `w700 / white`，
  /// 两个变体通过 [onSurfaceVariant] 换色 / 换字重。
  static const TextStyle growthGridDayNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 月网格 · 当日事件区标题。Figma：`11px / w600 / textSecondary`。
  static const TextStyle growthGridDayHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// 月网格事件卡 · 标题。Figma：`13px / w600 / textPrimary / lh 18px`。
  static const TextStyle growthEventCardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 月网格事件卡 · 副行。Figma：`11px / w400 / textSecondary`。
  static const TextStyle growthEventCardSub = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 月网格事件卡 · 变化量。Figma：`10px / w700 / green`。
  static const TextStyle growthEventCardDelta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  /// 月网格事件卡 · 类型 Chip 文字。Figma：`9px / w600`，颜色随类型
  /// 通过 [onSurfaceVariant] 换色。
  static const TextStyle growthEventCardTag = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 成长时间线 · 日期标签。Figma：`11px / w600 / #a0a7b8 / ls -0.2 / lh 16px`。
  static const TextStyle growthTimelineDate = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w600,
    color: AppColors.growthMetaInk,
  );

  /// 成长时间线 · 事件标题。Figma：`15px / w700 / #1f2937 / lh 21px`。
  static const TextStyle growthTimelineTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w700,
    color: AppColors.growthTitleInk,
  );

  /// 成长时间线 · 事件描述。Figma：`13px / w400 / #6b7280 / lh 20px`。
  static const TextStyle growthTimelineDesc = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 成长时间线 · 徽章文字（类型短名）。Figma：`10px / w600 / white / lh 14px`。
  static const TextStyle growthTimelineBadge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
  );

  /// 只映射 Careerly 实际使用的角色，未映射的位置保持 `null`，
  /// 由 `ThemeData` 兜底——Careerly 的视觉不被 Material 默认样式主导。
  static TextTheme asTextTheme() {
    return const TextTheme(
      displayLarge: display,
      displayMedium: display,
      displaySmall: headline,
      headlineLarge: headline,
      headlineMedium: headline,
      headlineSmall: title,
      titleLarge: title,
      titleMedium: subtitle,
      titleSmall: bodyStrong,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: bodySmall,
      labelLarge: label,
      labelMedium: label,
      labelSmall: caption,
    );
  }
}
