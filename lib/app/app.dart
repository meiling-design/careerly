import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/constants/app_constants.dart';
import '../data/api/api_client.dart';
import '../design_system/theme/careerly_theme.dart';
import '../design_system/tokens/tokens.dart';
import 'providers.dart';
import 'router/app_routes.dart';

/// Careerly 应用根节点。
///
/// 装配顺序（Phase 1 §十四）：
///
/// ```text
/// CareerlyApp
///  ├── MultiProvider          依赖注入（Repository / Router / State）
///  └── MaterialApp.router
///       ├── CareerlyTheme     统一主题（颜色 / 字体 / 形状 / 组件主题）
///       ├── 背景渐变           在这里绘制一次，所有页面透明穿透
///       └── AppRouter → CareerlyShell → 四个一级页面
/// ```
class CareerlyApp extends StatelessWidget {
  const CareerlyApp({
    super.key,
    this.initialLocation = AppRoutes.home,
    this.overrides = const <SingleChildWidget>[],
    this.apiClient,
    this.useApi = false,
  });

  /// 启动时落在哪条路由。
  ///
  /// ⚠️ 默认是**首页**，这不是遗漏 ——
  /// Onboarding 当前「可达但未接线」（见 `createAppRouter` 的说明），
  /// 是否改由会话持久化决定仍是待裁决项
  /// （**待裁决 · D54**，见 `docs/05_progress/TODO.md` §3.1）。
  ///
  /// 该参数存在的意义是让测试与调试可以**直接落在任意入口**，
  /// 而不必绕过整个 App 装配去手搓 Provider 列表。
  /// 开发期从命令行指定入口的开关见
  /// `lib/app/router/app_debug_entry.dart` ——
  /// 它只改「本次启动落哪」，**不改上面的默认值**。
  final String initialLocation;

  /// 测试 / 调试用的 Provider 尾部覆盖（语义见 [careerlyProviders]）。
  ///
  /// 例如 Widget 测试里把走平台通道的 `ResumeFilePicker`
  /// 换成返回固定文件的 Fake。生产代码**不要传**。
  final List<SingleChildWidget> overrides;

  /// 外部预建的 [ApiClient]（**P1-6 / D-B**）。
  ///
  /// `main()` 在 `runApp` 之前异步恢复会话（读 Keystore），
  /// 恢复完的客户端从这里注入。不传则由 `careerlyProviders` 自建。
  final ApiClient? apiClient;

  /// 是否把 Repository 绑到真实后端（见 [careerlyProviders] 的同名参数）。
  ///
  /// 默认 `false` = Mock。**`main()` 会显式传 `true`** —— 也就是说
  /// 这个默认值只服务于「测试与调试直接 pump [CareerlyApp]」的场景，
  /// 让那 17 处 widget 测试不必改一行就仍然是 Mock。
  final bool useApi;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: careerlyProviders(
        initialLocation: initialLocation,
        overrides: overrides,
        apiClient: apiClient,
        useApi: useApi,
      ),
      child: Builder(
        builder: (BuildContext context) {
          final GoRouter router = context.read<GoRouter>();

          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: CareerlyTheme.light(),
            routerConfig: router,
            // 本地化（K6）。Careerly 目前**只提供中文**，
            // 因此 supportedLocales 只登记 zh_CN —— 设备是任何语言时
            // Flutter 都会解析到唯一候选，Material 内建组件保持中文。
            //
            // ⚠️ 业务文案不经过这里（全部是硬编码中文）；
            // 本设置只影响 Material 内建组件的内建标签。
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const <Locale>[Locale('zh', 'CN')],
            // 背景渐变只在这里绘制一次。
            //
            // 放在 root builder 而不是每个页面里：页面的 `Scaffold` 都是透明的，
            // 渐变从最底层透上来，页面切换时不会出现背景断层或色带。
            builder: (BuildContext context, Widget? child) {
              return DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
