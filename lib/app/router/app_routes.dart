/// Careerly 路由常量。
///
/// 依据 Phase 1 §十三：
/// > 至少预留 `/`、`home`、`/analysis`、`/ai`、`/profile`。
/// > 这些是**工程层面的一级导航 route**。
/// > **不要因为 Router 而增加产品页面。**
///
/// 一级导航只有 4 个（PRD §6 / IA §2），不多不少。
abstract final class AppRoutes {
  /// 根路径。
  static const String root = '/';

  /// 首页 —— 「我现在怎么样？」
  static const String home = '/home';

  /// 分析 —— 「我离目标多远？」
  static const String analysis = '/analysis';

  /// AI —— 「我为什么？下一步怎么办？」
  static const String ai = '/ai';

  /// 我的 —— 「我积累了什么？」
  static const String profile = '/profile';

  /// 设置 —— 「我的」右上角齿轮进入的二级页面。
  static const String settings = '/settings';

  // ---------------------------------------------------------------------------
  // 分析二级页（Phase 6 扩展）
  //
  // 岗位详情 / Gap / 目标岗位是**分析结果页延伸出去的二级页**，
  // 挂进 analysis 这个 StatefulShellBranch 内部（路径以 /analysis/ 开头），
  // 底部导航保留、返回 = 分支内 pop（与「我的」二级页同一处置，K4）。
  //
  // ⚠️ IA §18 已裁决：分析准备 / 分析中 / 分析结果 / 更新分析 / 版本对比
  // 是「页面状态 / Bottom Sheet」，**不是**独立路由 —— 因此这里只建
  // 岗位详情 / Gap / 目标岗位三条**真正独立**的二级页。
  // ---------------------------------------------------------------------------

  /// 岗位详情。形如 `/analysis/job/:jobId`。
  static const String analysisJobSegment = 'job';
  static const String analysisJobIdParam = 'jobId';
  static String analysisJob(String jobId) =>
      '$analysis/$analysisJobSegment/$jobId';

  /// 成长空间（Gap）详情。形如 `/analysis/gap/:jobId`。
  static const String analysisGapSegment = 'gap';
  static const String analysisGapIdParam = 'jobId';
  static String analysisGap(String jobId) =>
      '$analysis/$analysisGapSegment/$jobId';

  /// 目标岗位列表。
  static const String analysisTargetsSegment = 'targets';
  static const String analysisTargets = '$analysis/$analysisTargetsSegment';

  // ---------------------------------------------------------------------------
  // 「我的」二级页（Phase 8）
  //
  // ⚠️ 这些是**二级页**，不是一级导航 —— 因此：
  //
  // ```text
  // ✅ 挂进 profile 这个 StatefulShellBranch 内部（路径以 /profile/ 开头）
  // ❌ 不进 [shellBranches] —— 一级导航永远只有 4 个（PRD §6 / IA §3.1）
  // ```
  //
  // 挂进分支而不是放 Shell 之外，是为了让**底部导航保留**、
  // 并且返回语义落在「分支内 pop」（K4 已裁决）—— 与 `/settings` 不同：
  // `/settings` 在 Phase 8 之前就已建成 Shell 外的独立路由，本轮不动它。
  //
  // 归属依据：IA §13 / §14 / §15。`/profile/membership` 的依据是
  // `CLAUDE.md` §4 决策 6（MVP = 静态页面 + 额度门禁，不做真实支付）。
  // ---------------------------------------------------------------------------

  // 每一页给出**两个**常量：相对段（`...Segment`，供路由表声明嵌套）
  // 与绝对路径（供页面 `context.push` 使用）。绝对路径**由段拼出**，
  // 因此两者不可能写岔。

  /// 职业资产 —— 四张分组卡 + 职业能力画像。
  static const String profileCareerAssetsSegment = 'career-assets';
  static const String profileCareerAssets =
      '$profile/$profileCareerAssetsSegment';

  /// 工作经历列表。
  static const String profileWorkExperienceSegment = 'work-experience';
  static const String profileWorkExperience =
      '$profile/$profileWorkExperienceSegment';

  /// 工作经历详情的子段（参数名 `id`）。
  static const String profileWorkDetailIdParam = 'id';

  /// 工作经历详情。形如 `/profile/work-experience/work-0`。
  static String profileWorkDetail(String id) => '$profileWorkExperience/$id';

  /// 项目经历列表。
  static const String profileProjectsSegment = 'projects';
  static const String profileProjects = '$profile/$profileProjectsSegment';

  /// 项目经历详情的子段（参数名 `id`）。
  static const String profileProjectDetailIdParam = 'id';

  /// 项目经历详情。形如 `/profile/projects/project-0`。
  static String profileProjectDetail(String id) => '$profileProjects/$id';

  /// 专业技能 —— 按分类分组的技能页。
  ///
  /// 归属依据：IA §13「职业资产 → 技能」/ §21「技能 → 我的」。
  /// 模型侧早有预告 —— 见 `data/models/career_skill.dart` 类顶：
  /// 「专业技能页是按分类展示的（Figma `SKILL_CATS`）」。
  static const String profileSkillsSegment = 'skills';
  static const String profileSkills = '$profile/$profileSkillsSegment';

  /// 奖项 —— 荣誉成果列表。
  ///
  /// 归属依据：IA §13「职业资产 → 奖项」/ §21「技能 · 能力 → 我的」。
  static const String profileAwardsSegment = 'awards';
  static const String profileAwards = '$profile/$profileAwardsSegment';

  /// 能力 —— 能力雷达图 + 能力详情。
  ///
  /// 归属依据：IA §13「职业资产 → 能力」/ §21「能力 → 我的」。
  ///
  /// ⚠️ 与 [profileGrowthRecord] 里的**成长足迹**不是一回事：
  /// 本页是**当前快照**（分值 + 相对上次的增量），
  /// 成长足迹是**事件时间线**。两者数据源不同，不互相推导。
  static const String profileCapabilitySegment = 'capability';
  static const String profileCapability =
      '$profile/$profileCapabilitySegment';

  /// 会员（Careerly Pro）—— 静态页 + 额度门禁展示。
  ///
  /// 依据 `CLAUDE.md` §4 决策 6：MVP = 静态页面 + 额度门禁，**不做真实支付**。
  static const String profileMembershipSegment = 'membership';
  static const String profileMembership = '$profile/$profileMembershipSegment';

  /// 成长记录 —— 「我的职业成长」的详情页（**成长日历落地在这里**）。
  ///
  /// 依据 `CLAUDE.md` §2.2 / Baseline O2：成长日历属于
  /// 「我的 → 成长足迹 → **Detail**」内部，**不是**一级页面、
  /// 也**不**直接铺在「我的」主页上（Figma 把它铺在主页，本轮不照搬）。
  static const String profileGrowthRecordSegment = 'growth-record';
  static const String profileGrowthRecord =
      '$profile/$profileGrowthRecordSegment';

  /// 简历历史 —— 「我的简历」的详情页。
  static const String profileResumeHistorySegment = 'resume-history';
  static const String profileResumeHistory =
      '$profile/$profileResumeHistorySegment';

  /// 简历详情的子段（参数名 `versionId`）。
  ///
  /// ⚠️ **嵌在简历历史之下**而不是平铺：Figma 的入口只有一处
  /// （`ResumeHistoryPage` 的「查看详情」，`App.tsx` L4546），
  /// 返回语义因此是「回到我的简历」—— 与 IA 的 Tab → Card → Detail 一致。
  static const String profileResumeDetailIdParam = 'versionId';

  /// 简历详情。形如 `/profile/resume-history/current`。
  static String profileResumeDetail(String versionId) =>
      '$profileResumeHistory/$versionId';

  /// 一级导航路径集合。
  ///
  /// **顺序 = 底部导航顺序**，Shell 通过索引与之一一对应：
  /// `首页 · 分析 · AI · 我的`
  static const List<String> shellBranches = <String>[
    home,
    analysis,
    ai,
    profile,
  ];

  // ---------------------------------------------------------------------------
  // Onboarding（Phase 4）
  //
  // ⚠️ 这几条**不是一级导航**，不进 [shellBranches] ——
  // 它们没有底部导航、不属于任何一个 Tab，是一条**一次性流程**。
  // 一级导航永远只有 4 个（PRD §6 / IA §3.1）。
  //
  // 步骤顺序取 **Figma**（见 `docs/05_progress/TODO.md` §3.2 D53）：
  //   开屏 → 注册/登录 → on-welcome → 提交简历 → 解析 → 确认
  //
  // ⚠️ `on-welcome` 的**真实语义不是「价值介绍」** —— 产品侧 2026-09-18 裁决
  // （**D61**）：「figma的价值介绍页面其实是用户身份选择」，
  // 且本轮**不单做价值介绍页**。该屏规格未给出，**未进入实现队列**。
  //
  // ✅ 与 PRD / IA 的两处分歧**均已裁决**（见 §3.2）：
  //   · 分歧 1（价值介绍的位置）—— D61
  //   · 分歧 2（「职业画像」一步的存废）—— **D65：确认删除，维持六步**
  // ---------------------------------------------------------------------------

  /// Onboarding 开屏。
  static const String onboardingSplash = '/onboarding/splash';

  /// Onboarding 注册。
  static const String onboardingRegister = '/onboarding/register';

  /// Onboarding 登录。
  ///
  /// ⚠️ **2026-10-04 起登录是独立页面、独立路由。**
  /// 这**推翻了 2026-09-21 的 D85**（「登录是注册页的第二种形态，
  /// 用 `?mode=login` 表达」）—— 依据是重新导出的 Figma：
  /// `OnLogin`（`src/App.tsx` L455-623）与 `OnRegister`（L661-797）
  /// 是**两个独立的屏**，字段集、标题、按钮文案、分隔线文案全都不同。
  ///
  /// D85 连同 `?mode=` 查询参数机制（`accountModeQuery` /
  /// `accountModeRegister` / `accountModeLogin` / `onboardingRegisterLogin`）
  /// 一并**删除**。登记见 `docs/05_progress/TODO.md`。
  ///
  /// ⚠️ 当时 D85 之所以禁止新增路由，是为了守 `CLAUDE.md` §0 的
  /// 第二禁令（不得自行增加一级页面）。**登录页不是一级页面** ——
  /// 它和注册页一样属于同一条一次性的 Onboarding 流程，
  /// 不进 [shellBranches]、没有底部导航、不是任何一个 Tab。
  static const String onboardingLogin = '/onboarding/login';

  /// Onboarding 提交简历。
  ///
  /// ⚠️ `on-welcome`（用户身份选择）在它**之前**，但本轮未建
  /// —— 见上方的 D61 说明与 `TODO.md` §3.2 D61。
  static const String onboardingResume = '/onboarding/resume';

  /// Onboarding 解析（建立职业基线）。
  static const String onboardingParsing = '/onboarding/parsing';

  /// Onboarding 确认职业信息。
  static const String onboardingConfirm = '/onboarding/confirm';
}

/// 路由名称常量，用于 `context.goNamed`。
abstract final class AppRouteNames {
  static const String home = 'home';
  static const String analysis = 'analysis';
  static const String ai = 'ai';
  static const String profile = 'profile';
  static const String settings = 'settings';

  // 分析二级页（Phase 6 扩展）
  static const String analysisJob = 'analysisJob';
  static const String analysisGap = 'analysisGap';
  static const String analysisTargets = 'analysisTargets';

  // 「我的」二级页（Phase 8）
  static const String profileCareerAssets = 'profileCareerAssets';
  static const String profileWorkExperience = 'profileWorkExperience';
  static const String profileWorkDetail = 'profileWorkDetail';
  static const String profileProjects = 'profileProjects';
  static const String profileProjectDetail = 'profileProjectDetail';
  static const String profileSkills = 'profileSkills';
  static const String profileAwards = 'profileAwards';
  static const String profileCapability = 'profileCapability';
  static const String profileMembership = 'profileMembership';
  static const String profileGrowthRecord = 'profileGrowthRecord';
  static const String profileResumeHistory = 'profileResumeHistory';
  static const String profileResumeDetail = 'profileResumeDetail';
  static const String onboardingSplash = 'onboardingSplash';
  static const String onboardingRegister = 'onboardingRegister';
  static const String onboardingLogin = 'onboardingLogin';
  static const String onboardingResume = 'onboardingResume';
  static const String onboardingParsing = 'onboardingParsing';
  static const String onboardingConfirm = 'onboardingConfirm';
}
