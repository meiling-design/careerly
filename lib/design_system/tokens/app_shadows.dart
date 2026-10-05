import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Careerly 阴影 Token。
///
/// 取值来自 `src/App.tsx` 的 `S.glass` / `S.glassLight` 与按钮样式。
///
/// 注意：Careerly 的 Glass 卡片在 Figma 中同时使用了
/// `box-shadow` 与多层 `inset box-shadow`（见 `BottomNav` 的 6 层内阴影）。
/// Flutter 的 `BoxShadow` 不支持 inset，这部分高光由
/// `BackdropFilter` + 边框渐变在 Phase 2 的 `GlassSurface` 中重新实现
/// （Baseline §1.2：「Figma 有视觉效果但 Flutter 没有对应实现方式 → 重新实现」）。
abstract final class AppShadows {
  static const List<BoxShadow> none = <BoxShadow>[];

  /// rgba(79,126,245,0.05) / 0 4px 16px — 轻量 Glass。
  static const List<BoxShadow> glassLight = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D4F7EF5),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  /// rgba(79,126,245,0.08) / 0 8px 32px — 标准 Glass 卡片。
  static const List<BoxShadow> glass = <BoxShadow>[
    BoxShadow(
      color: Color(0x144F7EF5),
      offset: Offset(0, 8),
      blurRadius: 32,
    ),
  ];

  /// 极轻分层阴影，用于列表卡片。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D42）** —— `rgba(155,177,201,0.06) / 0 2px 8px`
  /// 在 Figma 中**没有对应原值**。以 `155,177,201` 为色的阴影只有两处
  /// （`App.tsx` L1113 `0 8px 20px 0.25` / L3166 `0 12px 24px 0.25`），
  /// **都不匹配本值**。这是 Flutter 侧为「比 [md] 更轻」推导出来的档位。
  /// 影响面：`cardSmall`。
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F9BB1C9),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  /// rgba(155,177,201,0.25) / 0 12px 24px — 信息卡。
  ///
  /// ✅ Figma `App.tsx` L3166 逐位一致，**有明确依据**。
  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(
      color: Color(0x409BB1C9),
      offset: Offset(0, 12),
      blurRadius: 24,
    ),
  ];

  /// rgba(79,126,245,0.28) / 0 8px 12px — 品牌主按钮。
  static const List<BoxShadow> button = <BoxShadow>[
    BoxShadow(
      color: Color(0x474F7EF5),
      offset: Offset(0, 8),
      blurRadius: 12,
    ),
  ];

  /// 可复用主按钮 `PrimaryBtn` 的投影。
  ///
  /// Figma `PrimaryBtn`（`src/App.tsx` 行 142–155）：
  /// `0 8px 24px rgba(79,126,245,0.30)`。
  ///
  /// ⚠️ **与 [button] 不是同一个值**：Onboarding 的内联按钮用的是
  /// `0 8px 12px`（更紧），而可复用的 `PrimaryBtn` 用 `0 8px 24px`。
  /// 两者来源不同，不要合并。
  static const List<BoxShadow> primaryButton = <BoxShadow>[
    BoxShadow(
      color: Color(0x4D4F7EF5),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  /// 品牌渐变卡片的投影。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D42）** —— `rgba(79,126,245,0.20) / 0 10px 24px`
  /// 在 Figma 中**没有逐位一致的原值**。最接近的是 `App.tsx` L589
  /// `0 10px 14px rgba(79,126,245,0.28)`（**偏移相同，模糊与透明度不同**）。
  /// 品牌渐变卡片在 Figma 里用的是多套近似值
  /// （`0 16px 40px 0.28` / `0 20px 48px 0.28` / `0 8px 24px 0.25`），
  /// 本值是其中间档，**属归纳**。
  static const List<BoxShadow> brand = <BoxShadow>[
    BoxShadow(
      color: Color(0x334F7EF5),
      offset: Offset(0, 10),
      blurRadius: 24,
    ),
  ];

  /// 底部导航的浮起投影（Phase 1 通栏底栏版本，保留供旧引用）。
  ///
  /// ⚠️ **遗留项 · 待清理** —— 这是 Phase 1 通栏底栏的兜底阴影，
  /// **没有 Figma 依据**；自绘 `CareerlyNavigationBar` 用的是
  /// [navGlass] / [navPill] / [navAiOrb]。
  /// 当前仍被引用，删除会误伤，故保留并标注。
  static const List<BoxShadow> navigationBar = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F4F7EF5),
      offset: Offset(0, -4),
      blurRadius: 24,
    ),
  ];

  // ---------------------------------------------------------------------------
  // 底部导航 Glass（Figma `App.tsx` BottomNav 外阴影层）
  // ---------------------------------------------------------------------------

  /// 玻璃胶囊条外阴影。
  /// Figma `0 6px 24px rgba(0,0,0,0.08)` + `0 1px 4px rgba(0,0,0,0.04)`。
  static const List<BoxShadow> navGlass = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 6), blurRadius: 24),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 4),
  ];

  /// 选中态滑动药丸外阴影。Figma `0 1px 6px rgba(0,0,0,0.07)`。
  static const List<BoxShadow> navPill = <BoxShadow>[
    BoxShadow(color: Color(0x12000000), offset: Offset(0, 1), blurRadius: 6),
  ];

  /// AI 浮球外阴影。
  /// Figma `0 8px 24px rgba(79,126,245,0.30)` + `0 2px 6px rgba(0,0,0,0.06)`。
  static const List<BoxShadow> navAiOrb = <BoxShadow>[
    BoxShadow(color: Color(0x4D4F7EF5), offset: Offset(0, 8), blurRadius: 24),
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 2), blurRadius: 6),
  ];

  // ---------------------------------------------------------------------------
  // Onboarding（Phase 4 批 1）
  //
  // 真值来源：Figma `OnSplash` L371 / L418、`OnRegister` L475 / L520。
  // 三者都是**逐位一致的原值**，不是归纳。
  // ---------------------------------------------------------------------------

  /// 开屏 Logo 球的投影。
  /// Figma `OnSplash`：`0px 20px 48px 0px rgba(79,126,245,0.35)`。
  ///
  /// ⚠️ 与导航栏 AI 浮球的 [navAiOrb]（`0 8px 24px`）**不是同一个值** ——
  /// 开屏球更大（141 vs 62），投影也更远更重。
  static const List<BoxShadow> splashOrb = <BoxShadow>[
    BoxShadow(color: Color(0x594F7EF5), offset: Offset(0, 20), blurRadius: 48),
  ];

  /// Onboarding 白色按钮的投影。
  /// Figma `OnSplash`「点击注册」：`0px 4px 2px rgba(186,185,188,0.24)`。
  static const List<BoxShadow> neutralButton = <BoxShadow>[
    BoxShadow(color: Color(0x3DBAB5BC), offset: Offset(0, 4), blurRadius: 2),
  ];

  /// Onboarding 头像（渐变圆 + 白描边人像）的投影。
  /// Figma `OnRegister`：`0px 12px 16px rgba(79,126,245,0.28)`。
  static const List<BoxShadow> onboardingAvatar = <BoxShadow>[
    BoxShadow(color: Color(0x474F7EF5), offset: Offset(0, 12), blurRadius: 16),
  ];

  /// Onboarding 头像右下角「编辑」徽标的投影。
  /// Figma `OnRegister`：`0px 2px 4px rgba(0,0,0,0.12)`。
  static const List<BoxShadow> onboardingBadge = <BoxShadow>[
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  /// Onboarding 顶部返回键（Glass 圆钮）的投影。
  ///
  /// Figma `OnboardingProgress` 给了 6 层 `box-shadow`，其中 **4 层是 inset**
  /// （`inset 0 40px 10px -40px #e6e6e6` 等）。Flutter 的 `BoxShadow`
  /// **不支持 inset**，这部分高光按既有先例（见本文件头部说明 /
  /// `GlassSurface`）在组件里用边框与叠加层重新实现。
  /// 这里只登记可直接表达的**外阴影**：`0 8px 15px rgba(0,0,0,0.02)`。
  static const List<BoxShadow> onboardingBackPill = <BoxShadow>[
    BoxShadow(color: Color(0x05000000), offset: Offset(0, 8), blurRadius: 15),
  ];

  // ---------------------------------------------------------------------------
  // Onboarding（Phase 4 批 2）
  //
  // 真值来源：Figma `OnParsing`（L806-920）/ `OnConfirm`（L926-981）。
  // 两者都是**逐位一致的原值**，不是归纳。
  // ---------------------------------------------------------------------------

  /// 光晕球 / 确认页圆心的投影。
  /// Figma：`0 16px 40px rgba(79,126,245,0.35)`。
  ///
  /// ⚠️ 与开屏球的 [splashOrb]（`0 20px 48px`）**不是同一个值** ——
  /// 虽然透明度相同，但偏移与模糊都更小（球体本身也更小：96 vs 141）。
  static const List<BoxShadow> orb = <BoxShadow>[
    BoxShadow(color: Color(0x594F7EF5), offset: Offset(0, 16), blurRadius: 40),
  ];

  /// 磨砂卡片（步骤卡 / 汇总卡）的投影。
  /// Figma：`0 2px 20px rgba(79,126,245,0.08)`。
  ///
  /// ⚠️ 与 [glass]（`0 8px 32px`）**不是同一个值** —— 更贴、更收。
  static const List<BoxShadow> frosted = <BoxShadow>[
    BoxShadow(color: Color(0x144F7EF5), offset: Offset(0, 2), blurRadius: 20),
  ];

  /// 「退出解析」按钮的外描边。
  /// Figma：`box-shadow: 0 0 0 1px rgba(79,126,245,0.20)`。
  ///
  /// 用 `spreadRadius` 而不是 `Border` 表达，是因为 Figma 写的是**外扩环**
  /// —— `Border` 画在盒子内侧，会把内容区压窄 1px。色值取自
  /// [AppColors.brandBorderFaint]（同值，Figma 中另有 2 处用途）。
  static const List<BoxShadow> ghostRing = <BoxShadow>[
    BoxShadow(color: AppColors.brandBorderFaint, spreadRadius: 1),
  ];

  // ---------------------------------------------------------------------------
  // 首页（Phase 5）
  //
  // 真值来源：Figma `HomePage`（`src/App.tsx` L987-1182）。
  // ---------------------------------------------------------------------------

  /// 首页 Hero 卡投影。
  /// Figma：`0px 20px 48px 0px rgba(79,126,245,0.28)`。
  ///
  /// ⚠️ 与 [brand]（归纳值 `0 10px 24px`）**不是同一个值** ——
  /// 本值有 Figma 依据，[brand] 是归纳档。此处逐位还原，不复用。
  static const List<BoxShadow> homeHero = <BoxShadow>[
    BoxShadow(color: Color(0x474F7EF5), offset: Offset(0, 20), blurRadius: 48),
  ];

  /// 首页 2×2 卡片投影。
  /// Figma：`0px 8px 20px 0px rgba(155,177,201,0.25)`。
  ///
  /// ⚠️ 这是首页**独有**的投影色（`#9BB1C9` 冷灰，不是品牌蓝），
  /// 在 `AppShadows` 其他位置**没有出现过**，不可用 [md] / [glass] 近似。
  static const List<BoxShadow> homeStilCard = <BoxShadow>[
    BoxShadow(
      color: Color(0x409BB1C9),
      offset: Offset(0, 8),
      blurRadius: 20,
    ),
  ];

  /// 首页头像投影。
  /// Figma：`0 4px 7px rgba(79,126,245,0.35)`。
  ///
  /// ⚠️ 模糊半径 `7` 在 `AppShadows` 中**没有第二处**（其余均为 4 的倍数），
  /// 是 Figma 原值。
  static const List<BoxShadow> homeAvatar = <BoxShadow>[
    BoxShadow(color: Color(0x594F7EF5), offset: Offset(0, 4), blurRadius: 7),
  ];

  // ---------------------------------------------------------------------------
  // 我的（Phase 8）
  //
  // 真值来源：Figma `ProfilePage`（`src/App.tsx` L3102-3339）与
  // `CareerAssetsPage`（L3342-3634）。
  //
  // ✅ 本段三条均能在 `App.tsx` 中找到逐位一致的原值，**有明确依据**。
  //
  // 另外两处**复用既有令牌、不新增**：
  // - 信息卡投影 = [md]（`App.tsx` L3166，正是这张卡）
  // - 简历卡 / 历史分析卡 / 设置卡投影 = [glass]（L3277 / L3302 / L3322）
  // - 主页齿轮钮投影 = [glassLight]（L3148）
  // ---------------------------------------------------------------------------

  /// 我的主页头像投影。Figma：`0px 8px 12px rgba(79,126,245,0.3)`（L3159）。
  ///
  /// ⚠️ 与 [button]（`0.28` / `0 8px 12px`）**偏移与模糊相同、透明度不同**；
  /// 与 [primaryButton]（`0.30` / `0 8px 24px`）**透明度相同、模糊不同**。
  /// 三者互相都不是同一个值，Figma 分别写了三次，不可合并。
  static const List<BoxShadow> profileAvatar = <BoxShadow>[
    BoxShadow(color: Color(0x4D4F7EF5), offset: Offset(0, 8), blurRadius: 12),
  ];

  /// 我的主页资产渐变卡 / 职业资产页专业技能卡投影。
  /// Figma：`0px 8px 24px rgba(79,126,245,0.25)`（L3219 / L3426）。
  ///
  /// ⚠️ 与 [primaryButton]（`0.30`）**只有透明度差 5 个百分点**，
  /// 但一个是按钮、一个是卡片，Figma 确实写了两套，逐位还原。
  static const List<BoxShadow> profileBrandCard = <BoxShadow>[
    BoxShadow(color: Color(0x404F7EF5), offset: Offset(0, 8), blurRadius: 24),
  ];

  /// 职业资产页工作经历卡投影。Figma：`0px 8px 16px rgba(0,0,0,0.06)`（L3397）。
  ///
  /// ⚠️ `AppShadows` 中**唯一**一条纯黑（非品牌蓝、非冷灰）投影 ——
  /// 只出现在这张深色卡上，不可用 [sm] / [glass] 近似。
  static const List<BoxShadow> profileNeutralCard = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 8), blurRadius: 16),
  ];

  // ---------------------------------------------------------------------------
  // 语义别名
  //
  // ✅ [glass] / [glassLight] / [md] / [button] / [primaryButton] 及全部
  // `nav*` 系列均能在 `App.tsx` 中找到逐位一致的原值，**有明确依据**。
  // ⚠️ [sm] / [brand] 属归纳或近似值 → **待裁决 · D42**
  //    本节语义别名中的 [sheet] 来源存疑 → **待裁决 · D35**
  //    集中登记见 `CURRENT_STATUS.md` §3.6。
  // ---------------------------------------------------------------------------

  /// 标准卡片投影。
  static const List<BoxShadow> card = glass;

  /// 次级卡片投影。⚠️ 继承 [sm] 的暂定状态。
  static const List<BoxShadow> cardSmall = sm;

  /// 模态 / Bottom Sheet 投影。
  ///
  /// ⚠️ **暂定值 · 待视觉验证，且来源存疑** —— 本值指向 [md]，
  /// 而 [md] 的真值是 `App.tsx` L3166 的一张 **Glass 信息卡**，
  /// **不是 Bottom Sheet**。Figma 里 Bottom Sheet 的阴影是**向上**的
  /// （L4603 `0px -2px 48px rgba(0,0,0,0.18)`），与 [md] 方向相反。
  /// 即：**该别名很可能取错了源**。登记为待裁决 · D35。
  ///
  /// 当前 `CareerlyBottomSheet` **未引用本值**（用自己的内联投影），
  /// 因此改动无风险。
  static const List<BoxShadow> sheet = md;

  // ---------------------------------------------------------------------------
  // 分析 —— 「AI 正在分析」的球体投影（Phase 6）
  //
  // 真值来源：Figma `AnalysisProcessing`（`App.tsx` L1976-1977），逐位原值。
  //
  // ⚠️ Figma 的同一条 `boxShadow` 里还带 `inset 0 3px 10px
  // rgba(255,255,255,0.38 / 0.45)` —— Flutter 的 [BoxShadow] **不支持 inset**
  // （同 K5），该内缩高光由 `careerly_analysis_progress.dart` 用一层
  // 线性渐变近似，**不在本文件表达**。
  // ---------------------------------------------------------------------------

  /// 主球常态投影。Figma
  /// `0 14px 44px rgba(79,126,245,0.28), 0 4px 18px rgba(167,123,230,0.18)`。
  static const List<BoxShadow> analysisOrb = <BoxShadow>[
    BoxShadow(color: Color(0x474F7EF5), offset: Offset(0, 14), blurRadius: 44),
    BoxShadow(color: Color(0x2EA77BE6), offset: Offset(0, 4), blurRadius: 18),
  ];

  /// 主球完成态投影。Figma
  /// `0 0 64px rgba(79,126,245,0.55), 0 0 32px rgba(167,123,230,0.45)`。
  ///
  /// 与 [analysisOrb] 的区别是**无偏移**（外发光而非下投影）且更亮 ——
  /// 所以两者不能合成一条。
  static const List<BoxShadow> analysisOrbDone = <BoxShadow>[
    BoxShadow(color: Color(0x8C4F7EF5), blurRadius: 64),
    BoxShadow(color: Color(0x73A77BE6), blurRadius: 32),
  ];

  // ---------------------------------------------------------------------------
  // 成长足迹（我的 → 成长足迹 Detail · Figma GrowthRecordPage L3973-4114）
  // ---------------------------------------------------------------------------

  /// 周日历条 · 「今天」圆的投影。
  /// Figma `0 4px 6px rgba(123,126,218,0.25)`（L4043）。
  static const List<BoxShadow> growthTodayCircle = <BoxShadow>[
    BoxShadow(color: Color(0x407B7EDA), offset: Offset(0, 4), blurRadius: 6),
  ];

  /// 成长记录页 · 返回钮投影。
  /// Figma `0 2px 4px rgba(0,0,0,0.06)`（L4007）。
  static const List<BoxShadow> growthBackButton = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  // ---------------------------------------------------------------------------
  // 登录 / 注册 / 开屏页（新版 Figma 重新导出 · 2026-10-04）
  //
  // 真值来源：`OnSplash` L439、`OnLogin` L582、`OnRegister` L764 ——
  // **三处逐位一致**，是同一个按钮形态（渐变胶囊主按钮）。
  // ---------------------------------------------------------------------------

  /// 登录 / 注册 / 开屏页渐变主按钮的投影。
  /// Figma：`0 8px 12px rgba(79,126,245,0.30)`。
  ///
  /// ⚠️ 数值与 [profileAvatar]（L3159）**逐位相同**，但**不合并** ——
  /// 沿用本文件既有先例（见 [profileAvatar] 的说明）：Figma 在不同版面
  /// 各写了一次，语义一个是「头像」一个是「按钮」，合并后改一处会误伤另一处。
  /// 与 [button]（`0.28`）/ [primaryButton]（`0 8px 24px`）同为 `0 8px 12px`
  /// 家族，**只有透明度不同**，同样不可互相替代。
  static const List<BoxShadow> authPrimaryButton = <BoxShadow>[
    BoxShadow(color: Color(0x4D4F7EF5), offset: Offset(0, 8), blurRadius: 12),
  ];

  // ---------------------------------------------------------------------------
  // 我的简历 · 简历历史 / 简历详情（Figma `ResumeHistoryPage` L4479-4600、
  // `ResumeDetailPage` L4599-4793）
  // ---------------------------------------------------------------------------

  /// 简历详情页 · PDF 预览卡的投影。
  /// Figma：`0 4px 24px rgba(0,0,0,0.10)`（L4626）。
  static const List<BoxShadow> resumePdfCard = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 24),
  ];

  /// 简历历史页 · 「新建」悬浮按钮的投影。
  /// Figma：`0 8px 24px rgba(79,126,245,0.40)`（L4580）。
  ///
  /// ⚠️ 与 [primaryButton]（`0 8px 24px` / `0.30`）**只差透明度**
  /// （`0.40` vs `0.30`），与 [splashOrb]（`0 20px 48px`）差得更多 ——
  /// 三者不可互换。
  static const List<BoxShadow> resumeFab = <BoxShadow>[
    BoxShadow(color: Color(0x664F7EF5), offset: Offset(0, 8), blurRadius: 24),
  ];

  // ---------------------------------------------------------------------------
  // 分析页 · 顶部「新建分析 | 历史分析」切换器
  // （Figma `AnalysisHome` L1511-1539）
  // ---------------------------------------------------------------------------

  /// 分析页 · 切换器轨道的四层投影。
  /// Figma（L1519）逐字：
  /// `1.25px 0 0 -0.75px #d0d0d0, -1.25px 0 0 -0.75px #d0d0d0,
  ///  0 0 0 0.5px #e8e8e8, 0 8px 15px rgba(0,0,0,0.02)`
  ///
  /// 这是「Glass FillShadow」那套边缘高光的 Flutter 侧近似：
  /// 左右各 `±1.25px` 偏移、`-0.75px` 收缩画侧边高光，
  /// `0.5px` 收缩画外描边，最后一层是柔和投影。
  /// ⚠️ 原型的 `inset` 两层 Flutter 画不了（`BoxShadow` 无 inset），
  /// 与 `GlassSurface` / `OnboardingProgressHeader` 同一处置。
  static const List<BoxShadow> analysisSegmentedTrack = <BoxShadow>[
    BoxShadow(
      color: Color(0xFFD0D0D0),
      offset: Offset(1.25, 0),
      spreadRadius: -0.75,
    ),
    BoxShadow(
      color: Color(0xFFD0D0D0),
      offset: Offset(-1.25, 0),
      spreadRadius: -0.75,
    ),
    BoxShadow(color: Color(0xFFE8E8E8), spreadRadius: 0.5),
    BoxShadow(color: Color(0x05000000), offset: Offset(0, 8), blurRadius: 15),
  ];

  /// 分析页 · 切换器**选中段**的投影。
  /// Figma：`0 2px 4px rgba(79,126,245,0.12)`（L1530）。
  static const List<BoxShadow> analysisSegmentedActive = <BoxShadow>[
    BoxShadow(color: Color(0x1F4F7EF5), offset: Offset(0, 2), blurRadius: 4),
  ];
}
