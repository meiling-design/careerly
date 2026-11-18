import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/tokens/tokens.dart';
import '../../features/ai/presentation/ai_page.dart';
import '../../features/analysis/presentation/analysis_page.dart';
import '../../features/analysis/presentation/gap_page.dart';
import '../../features/analysis/presentation/job_detail_page.dart';
import '../../features/analysis/presentation/targets_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/legal/legal_document.dart';
import '../../features/legal/presentation/legal_document_page.dart';
import '../../features/onboarding/presentation/onboarding_confirm_page.dart';
import '../../features/onboarding/presentation/onboarding_login_page.dart';
import '../../features/onboarding/presentation/onboarding_parsing_page.dart';
import '../../features/onboarding/presentation/onboarding_register_page.dart';
import '../../features/onboarding/presentation/onboarding_reset_password_page.dart';
import '../../features/onboarding/presentation/onboarding_resume_page.dart';
import '../../features/onboarding/presentation/onboarding_splash_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/delete_account_page.dart';
import '../../features/profile/presentation/delete_career_data_page.dart';
import '../../features/profile/presentation/settings_page.dart';
import '../../features/profile/presentation/awards_page.dart';
import '../../features/profile/presentation/capability_page.dart';
import '../../features/profile/presentation/career_assets_page.dart';
import '../../features/profile/presentation/growth_record_page.dart';
import '../../features/profile/presentation/membership_page.dart';
import '../../features/profile/presentation/personal_info_page.dart';
import '../../features/profile/presentation/project_detail_page.dart';
import '../../features/profile/presentation/projects_page.dart';
import '../../features/profile/presentation/resume_detail_page.dart';
import '../../features/profile/presentation/resume_history_page.dart';
import '../../features/profile/presentation/skills_page.dart';
import '../../features/profile/presentation/work_detail_page.dart';
import '../../features/profile/presentation/work_experience_page.dart';
import '../../features/support/presentation/about_careerly_page.dart';
import '../../features/support/presentation/feedback_page.dart';
import '../../features/support/presentation/help_center_page.dart';
import '../shell/careerly_shell.dart';
import 'app_routes.dart';
import 'back_navigation.dart';
import 'page_transitions.dart';

/// Careerly 路由表。
///
/// ## 结构（Phase 1 §十三 / §十四）
///
/// ```text
/// GoRouter
/// └── StatefulShellRoute.indexedStack   ← CareerlyShell（自绘底部导航）
///     ├── /home       首页
///     ├── /analysis   分析
///     ├── /ai         AI
///     └── /profile    我的
/// ```
///
/// **一级导航只有这 4 个，永远不加第 5 个**（PRD §6 / IA §3.1）。
///
/// ## 尚不建立的 Route
///
/// 以下内容 PRD / IA 已确认**不作为独立页面**，因此这里也不建路径：
/// - 分析准备 / 分析中 / 分析结果 / 更新分析 / 版本对比
///   （IA §18 明确：这些是**页面状态 / Bottom Sheet**）
/// - 成长日历 / 成长时间线
///   （Phase 1 §三 O2 已裁决：属于「我的 → 成长足迹 → Detail」内部）
/// - 设置 `/settings` —— Phase 8 建立，且只有「我的」右上角 ⚙ 一个入口
/// - Onboarding 其余步骤（价值介绍 / 提交简历 / 解析 / 确认）—— Phase 4 后续批次
///
/// **路由只表达页面层级，不承载业务状态。**
///
/// ## Android Back 行为（2026-11-14 产品侧更新）
///
/// ```text
/// 一级页面 · 首页        ：moveTaskToBack(true) 退到后台（不 finish）
/// 一级页面 · 分析/AI/我的：先回到首页；在首页再次 Back 才退到后台
/// 二级 / 三级页面        ：统一 Back = 当前栈 pop（回到上一个操作上下文）
/// Shell 之外的顶级路由    ：栈底先补首页，首页才退后台
/// ```
///
/// - 「回到哪一页」**由这里的嵌套层级决定**（三级嵌在二级内、二级嵌在分支内），
///   Back 只是 `pop`，不跳固定页面。
/// - 三个返回入口（顶部按钮 / 系统 Back / 左边缘右滑）共用同一个
///   Back Action —— 执行层在 `back_navigation.dart`（`careerlyBack` +
///   `CareerlyBackScope`）。新增页面按同一层级形状挂进来即自动继承，
///   **不需要**为单页设计返回逻辑。
/// - 离开确认（未保存修改 / 分析进行中）用 `CareerlyBackScope` 的守卫，
///   由页面声明「脏不脏」，不由路由表管理。
///
/// ## 启动入口与会话恢复
///
/// 本函数的默认值仍是 `/home`；真实启动入口由 `main()` 决定：
///
/// ```text
/// restoreSession() 成功（已登录） →  /home
/// 没有已保存会话                 →  /onboarding/splash
/// CAREERLY_ENTRY 显式指定         →  开发者选择的入口
/// ```
///
/// 依据 2026-11-15 产品规则：重新打开 App 必须保持登录状态。
///
/// 📌 真机上做视觉验收时，用 `AppDebugEntry` 指定本次启动的入口：
/// `flutter run --dart-define=CAREERLY_ENTRY=splash`。
GoRouter createAppRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: kDebugMode,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => CareerlyShell(
              navigationShell: navigationShell,
              currentLocation: state.uri.path,
            ),
        branches: <StatefulShellBranch>[
          _branch(
            location: AppRoutes.home,
            name: AppRouteNames.home,
            page: const HomePage(),
          ),
          _analysisBranch(),
          _branch(
            location: AppRoutes.ai,
            name: AppRouteNames.ai,
            page: const AIPage(),
          ),
          _profileBranch(),
        ],
      ),
      // -------------------------------------------------------------------------
      // Onboarding（Phase 4）
      //
      // ⚠️ 这几条在 Shell **之外** —— 它们没有底部导航、不属于任何 Tab。
      // 放进 StatefulShellRoute 会让开屏页也带上导航栏，那是错的。
      //
      // 转场用 [CareerlyPageTransitions.onboarding]：Baseline §6.6 把
      // Onboarding 单列为「Progressive Flow」。
      // Figma 的 `_onboard-in` 是**水平** `translateX(24px)`（300ms），
      // 早先误用垂直的 `fadeUp`，Phase 3 已更正。
      // -------------------------------------------------------------------------
      _onboardingRoute(
        location: AppRoutes.onboardingSplash,
        name: AppRouteNames.onboardingSplash,
        page: const OnboardingSplashPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRouteNames.settings,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CareerlyPageTransitions.slide<void>(
              key: const ValueKey<String>(AppRouteNames.settings),
              name: AppRouteNames.settings,
              child: const CareerlyRootBackScope(child: SettingsPage()),
            ),
        // 设置下的二级页。嵌在 /settings 之下（而不是平铺成
        // /settings-delete-account）是为了让返回语义自然落在
        // 「回到设置」—— 与 /profile 下的二级页同一处置（K4）。
        routes: <RouteBase>[
          _subRoute(
            segment: AppRoutes.settingsPersonalInfoSegment,
            name: AppRouteNames.settingsPersonalInfo,
            builder: (_, _) => const PersonalInfoPage(),
          ),
          _subRoute(
            segment: AppRoutes.settingsDeleteAccountSegment,
            name: AppRouteNames.settingsDeleteAccount,
            builder: (_, _) => const DeleteAccountPage(),
          ),
          _subRoute(
            segment: AppRoutes.settingsDeleteCareerDataSegment,
            name: AppRouteNames.settingsDeleteCareerData,
            builder: (_, _) => const DeleteCareerDataPage(),
          ),
          // 帮助 / 反馈 / 关于 —— 设置页「帮助与反馈」分组的三个二级页。
          _subRoute(
            segment: AppRoutes.settingsHelpSegment,
            name: AppRouteNames.settingsHelp,
            builder: (_, _) => const HelpCenterPage(),
          ),
          _subRoute(
            segment: AppRoutes.settingsFeedbackSegment,
            name: AppRouteNames.settingsFeedback,
            builder: (_, _) => const FeedbackPage(),
          ),
          _subRoute(
            segment: AppRoutes.settingsAboutSegment,
            name: AppRouteNames.settingsAbout,
            builder: (_, _) => const AboutCareerlyPage(),
          ),
        ],
      ),
      // -------------------------------------------------------------------------
      // 协议页（发布基线 §1.0f · E2 / E3）
      //
      // ⚠️ 与 `/settings` 同类：在 Shell **之外** —— 协议页没有底部导航。
      //
      // ⚠️ 与 `/settings/...` 的嵌套写法不同：`/legal` **没有自己的页面**，
      // 因此这里建两条**顶级路由**，而不是「父路由 + 子路由」——
      // 硬套父子会多出一个没有实体的中间节点。
      //
      // 返回语义不受影响：两条都由 `context.push` 进入，
      // Back = 当前导航栈 pop（CLAUDE.md §5.6 / K4）——
      // 从注册页进就回注册页，从设置进就回设置。
      // -------------------------------------------------------------------------
      _legalRoute(
        document: LegalDocument.termsOfService,
        location: AppRoutes.legalTerms,
        name: AppRouteNames.legalTerms,
      ),
      _legalRoute(
        document: LegalDocument.privacyPolicy,
        location: AppRoutes.legalPrivacy,
        name: AppRouteNames.legalPrivacy,
      ),
      // AI 数据使用说明 —— 2026-10-07 产品侧裁决 D123 = A 之后新增。
      // 上面那段注释里的「两条顶级路由」在本轮变成三条，写法完全同构。
      _legalRoute(
        document: LegalDocument.aiDataProcessing,
        location: AppRoutes.legalAiData,
        name: AppRouteNames.legalAiData,
      ),
      _onboardingRoute(
        location: AppRoutes.onboardingRegister,
        name: AppRouteNames.onboardingRegister,
        page: const OnboardingRegisterPage(),
      ),
      // 登录页 —— 2026-10-04 起是**独立路由**。
      //
      // ⚠️ 不再是「注册页 + `?mode=login`」（那是已废弃的 D85）。
      // 本路由曾一度是本文件里唯一要读 `state.uri.queryParameters` 的一条，
      // 且因此没走 `_onboardingRoute`；现在它与其余 Onboarding 页面
      // **完全同构**，故回归辅助函数，转场也回到
      // `CareerlyPageTransitions.onboarding`（不是 slide）。
      _onboardingRoute(
        location: AppRoutes.onboardingLogin,
        name: AppRouteNames.onboardingLogin,
        page: const OnboardingLoginPage(),
      ),
      // 重置密码 —— 登录页的二级页面（`context.push` 进入，Back 回登录页）。
      // 不是一级页面，也没有底部导航。
      _onboardingRoute(
        location: AppRoutes.onboardingResetPassword,
        name: AppRouteNames.onboardingResetPassword,
        page: const OnboardingResetPasswordPage(),
      ),
      _onboardingRoute(
        location: AppRoutes.onboardingResume,
        name: AppRouteNames.onboardingResume,
        page: const OnboardingResumePage(),
      ),
      _onboardingRoute(
        location: AppRoutes.onboardingParsing,
        name: AppRouteNames.onboardingParsing,
        page: const OnboardingParsingPage(),
      ),
      _onboardingRoute(
        location: AppRoutes.onboardingConfirm,
        name: AppRouteNames.onboardingConfirm,
        page: const OnboardingConfirmPage(),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        _RouteNotFoundPage(location: state.uri.toString()),
  );
}

/// 构造一条 Onboarding 路由（Shell 之外的一级流程页）。
GoRoute _onboardingRoute({
  required String location,
  required String name,
  required Widget page,
}) {
  return GoRoute(
    path: location,
    name: name,
    pageBuilder: (BuildContext context, GoRouterState state) =>
        CareerlyPageTransitions.onboarding<void>(
          key: ValueKey<String>(name),
          name: name,
          // 登录前没有「首页」：栈底 Back 只退后台，不补首页、不 finish。
          child: CareerlyRootBackScope(
            fallbackToHome: false,
            child: page,
          ),
        ),
  );
}

/// 构造一条协议页路由（Shell 之外的二级页）。
///
/// 两条协议路由只有 [document] 不同，因此共用一个构造器 ——
/// 与页面层「一个类 + 一个枚举」的处置一致（`CLAUDE.md` §8.4）。
///
/// 页面 key 用**路由名**：这两条都不带参数，不存在详情页那种
/// 「不同 id 撞 key」的问题（对照 [_subRoutePage] 的注释）。
GoRoute _legalRoute({
  required LegalDocument document,
  required String location,
  required String name,
}) {
  return GoRoute(
    path: location,
    name: name,
    pageBuilder: (BuildContext context, GoRouterState state) =>
        CareerlyPageTransitions.slide<void>(
          key: ValueKey<String>(name),
          name: name,
          child: CareerlyRootBackScope(
            child: LegalDocumentPage(document: document),
          ),
        ),
  );
}

/// 构造一个一级导航分支。
///
/// 使用 [CareerlyPageTransitions.slide] 而不是默认转场——
/// Baseline §6.6：「不使用 M3 默认转场」。
StatefulShellBranch _branch({
  required String location,
  required String name,
  required Widget page,
}) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: location,
        name: name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CareerlyPageTransitions.slide<void>(
              key: ValueKey<String>(name),
              name: name,
              child: page,
            ),
      ),
    ],
  );
}

/// 「分析」分支 —— **一级导航 `/analysis` + 其三个二级页**。
///
/// 二级页（岗位详情 / Gap / 目标岗位）是分析结果页延伸出去的
/// **独立页面**，不是「页面状态」—— IA §18 只把分析准备/分析中/
/// 分析结果/更新分析/版本对比 裁决为状态/Sheet，岗位详情/Gap/目标岗位
/// 有独立 TopBar + 返回，故挂成子路由（同「我的」分支的二级页）。
///
/// ## 一级导航仍然只有 4 个
///
/// 这些二级路径**不进** [AppRoutes.shellBranches]。
StatefulShellBranch _analysisBranch() {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.analysis,
        name: AppRouteNames.analysis,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CareerlyPageTransitions.slide<void>(
              key: const ValueKey<String>(AppRouteNames.analysis),
              name: AppRouteNames.analysis,
              child: const AnalysisPage(),
            ),
        routes: <RouteBase>[
          _subRoute(
            segment:
                '${AppRoutes.analysisJobSegment}/:${AppRoutes.analysisJobIdParam}',
            name: AppRouteNames.analysisJob,
            builder: (BuildContext context, GoRouterState state) =>
                AnalysisJobDetailPage(
                  jobId:
                      state.pathParameters[AppRoutes.analysisJobIdParam] ?? '',
                ),
          ),
          _subRoute(
            segment:
                '${AppRoutes.analysisGapSegment}/:${AppRoutes.analysisGapIdParam}',
            name: AppRouteNames.analysisGap,
            builder: (BuildContext context, GoRouterState state) =>
                AnalysisGapPage(
                  jobId:
                      state.pathParameters[AppRoutes.analysisGapIdParam] ?? '',
                ),
          ),
          _subRoute(
            segment: AppRoutes.analysisTargetsSegment,
            name: AppRouteNames.analysisTargets,
            builder: (_, _) => const AnalysisTargetsPage(),
          ),
        ],
      ),
    ],
  );
}

/// 「我的」分支 —— **一级导航 `/profile` + 其全部二级页**。
///
/// ## 为什么二级页要**嵌在分支内部**，而不是平铺在 Shell 之外
///
/// ```text
/// ✅ 嵌在分支里：底部导航保留；返回落回「我的」Tab 的栈（K4 已裁决）
/// ❌ 平铺在外面：切走再切回会丢掉「我的」的导航栈
/// ```
///
/// ⚠️ `/settings` **仍然留在 Shell 之外** —— 它在 Phase 8 之前就已建成，
/// 本轮不改动它的位置（避免让「验收对象」与「已交付物」不一致，
/// `D30` / `D74` 先例）。两者的位置差异是有意保留的，不是遗漏。
///
/// ## 一级导航仍然只有 4 个
///
/// 这些二级路径**不进** [AppRoutes.shellBranches]（PRD §6 / IA §3.1）。
StatefulShellBranch _profileBranch() {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.profile,
        name: AppRouteNames.profile,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CareerlyPageTransitions.slide<void>(
              key: const ValueKey<String>(AppRouteNames.profile),
              name: AppRouteNames.profile,
              child: const ProfilePage(),
            ),
        routes: <RouteBase>[
          _subRoute(
            segment: AppRoutes.profileCareerAssetsSegment,
            name: AppRouteNames.profileCareerAssets,
            builder: (_, _) => const CareerAssetsPage(),
          ),
          _subRoute(
            segment: AppRoutes.profileWorkExperienceSegment,
            name: AppRouteNames.profileWorkExperience,
            builder: (_, _) => const WorkExperiencePage(),
            routes: <RouteBase>[
              _subRoute(
                segment: ':${AppRoutes.profileWorkDetailIdParam}',
                name: AppRouteNames.profileWorkDetail,
                builder: (_, GoRouterState state) => WorkDetailPage(
                  workId:
                      state.pathParameters[AppRoutes
                          .profileWorkDetailIdParam] ??
                      '',
                ),
              ),
            ],
          ),
          _subRoute(
            segment: AppRoutes.profileProjectsSegment,
            name: AppRouteNames.profileProjects,
            builder: (_, _) => const ProjectsPage(),
            routes: <RouteBase>[
              _subRoute(
                segment: ':${AppRoutes.profileProjectDetailIdParam}',
                name: AppRouteNames.profileProjectDetail,
                builder: (_, GoRouterState state) => ProjectDetailPage(
                  projectId:
                      state.pathParameters[AppRoutes
                          .profileProjectDetailIdParam] ??
                      '',
                ),
              ),
            ],
          ),
          _subRoute(
            segment: AppRoutes.profileSkillsSegment,
            name: AppRouteNames.profileSkills,
            builder: (_, _) => const SkillsPage(),
          ),
          _subRoute(
            segment: AppRoutes.profileAwardsSegment,
            name: AppRouteNames.profileAwards,
            builder: (_, _) => const AwardsPage(),
          ),
          _subRoute(
            segment: AppRoutes.profileCapabilitySegment,
            name: AppRouteNames.profileCapability,
            builder: (_, _) => const CapabilityPage(),
          ),
          _subRoute(
            segment: AppRoutes.profileMembershipSegment,
            name: AppRouteNames.profileMembership,
            builder: (_, _) => const MembershipPage(),
          ),
          _subRoute(
            segment: AppRoutes.profileGrowthRecordSegment,
            name: AppRouteNames.profileGrowthRecord,
            builder: (_, _) => const GrowthRecordPage(),
          ),
          _subRoute(
            segment: AppRoutes.profileResumeHistorySegment,
            name: AppRouteNames.profileResumeHistory,
            builder: (_, _) => const ResumeHistoryPage(),
            routes: <RouteBase>[
              // 简历详情 —— 嵌在「我的简历」之下，Back = 回到我的简历。
              _subRoute(
                segment: ':${AppRoutes.profileResumeDetailIdParam}',
                name: AppRouteNames.profileResumeDetail,
                builder: (_, GoRouterState state) => ResumeDetailPage(
                  versionId:
                      state.pathParameters[AppRoutes
                          .profileResumeDetailIdParam] ??
                      '',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 构造一条二级页路由（**相对段**，嵌在父路由的 `routes` 里）。
///
/// [builder] 收 `GoRouterState` 是为了让详情页能读 `pathParameters`；
/// 不带参数的页写成 `(_, _) => const XxxPage()` 即可。
///
/// 转场统一走 [CareerlyPageTransitions.slide]（Baseline §6.6：
/// 不使用 M3 默认转场），因此调用方**不需要**自己包转场。
///
/// ⚠️ 返回类型是 `Page<void>` 而**不是** `Widget` ——
/// [GoRoute.pageBuilder] 要求 `Page`。写成 `Widget` 会被
/// `CustomTransitionPage<void>` 拒绝（编译期报
/// `return_of_invalid_type_from_closure`）。
///
/// ⚠️ 页面 key 用**当前 location** 而不是路由名 —— 详情页是带参路由
/// （`work-experience/:id`），用路由名做 key 会让不同 id 的页面**撞 key**。
Page<void> _subRoutePage({
  required String name,
  required Widget child,
  required GoRouterState state,
}) {
  return CareerlyPageTransitions.slide<void>(
    key: ValueKey<String>(state.uri.toString()),
    name: name,
    child: child,
  );
}

GoRoute _subRoute({
  required String segment,
  required String name,
  required Widget Function(BuildContext context, GoRouterState state) builder,
  List<RouteBase> routes = const <RouteBase>[],
}) {
  return GoRoute(
    path: segment,
    name: name,
    routes: routes,
    pageBuilder: (BuildContext context, GoRouterState state) =>
        _subRoutePage(name: name, child: builder(context, state), state: state),
  );
}

/// 未知路由的兜底页。
///
/// 存在的意义：开发期输错路径时能立刻看到，而不是白屏。
class _RouteNotFoundPage extends StatelessWidget {
  const _RouteNotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return CareerlyScaffold(
      title: '页面不存在',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.explore_off_outlined,
              size: 40,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(location, style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}
