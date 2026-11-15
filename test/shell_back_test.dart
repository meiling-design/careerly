import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/core/services/app_back_platform.dart';
import 'package:careerly/features/home/presentation/home_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_login_page.dart';
import 'package:careerly/features/profile/presentation/capability_page.dart';
import 'package:careerly/features/profile/presentation/profile_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 一级页面的 Android Back / 边缘右滑规则（2026-11-15 产品侧更新）。
///
/// ```text
/// 首页            → moveTaskToBack(true) 退到后台（不 finish）
/// 分析 / AI / 我的 → 第一次回到首页；在首页再 Back 才退到后台
/// Shell 之外的顶级页（/settings、/legal/*）→ 栈底先补首页
/// ```
///
/// 执行层在 `CareerlyShell` / `CareerlyRootBackScope`；本文件验证
/// 「按下的那一刻当前分支是否切到了首页 / 是否调用了退后台通道」。
/// ❌ 不允许出现 `SystemNavigator.pop`（Android 上等于 finish）。
void main() {
  Future<void> pumpAt(WidgetTester tester, String location) async {
    await tester.pumpWidget(CareerlyApp(initialLocation: location));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  /// 记录并对「退后台」通道与 Flutter 系统通道打桩。
  List<MethodCall> installPlatformMocks(WidgetTester tester) {
    final List<MethodCall> platformCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      AppBackPlatform.channel,
      (MethodCall call) async {
        platformCalls.add(call);
        return true;
      },
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        platformCalls.add(call);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        AppBackPlatform.channel,
        null,
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
    return platformCalls;
  }

  for (final String location in <String>[
    AppRoutes.analysis,
    AppRoutes.ai,
    AppRoutes.profile,
  ]) {
    testWidgets('一级页面 $location：Back 先回首页，不退出', (WidgetTester tester) async {
      final List<MethodCall> platformCalls = installPlatformMocks(tester);

      await pumpAt(tester, location);
      expect(find.byType(HomePage), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // 首页被切回来后，会重新走一遍 Mock 数据加载（600ms）——
      // 必须在测试结束前把这些定时器走完，否则会报 pending timer。
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(
        find.byType(HomePage),
        findsOneWidget,
        reason: '非首页一级页面 Back 必须落到首页',
      );
      expect(
        platformCalls.where(
          (MethodCall call) => call.method == 'SystemNavigator.pop',
        ),
        isEmpty,
        reason: '第一次 Back 不应退出 App',
      );
      expect(
        platformCalls.where(
          (MethodCall call) => call.method == 'moveTaskToBack',
        ),
        isEmpty,
        reason: '非首页一级页面第一次 Back 不应退后台',
      );
    });
  }

  testWidgets('首页：Back 退到后台，不 finish、不退出登录', (WidgetTester tester) async {
    final List<MethodCall> platformCalls = installPlatformMocks(tester);

    await pumpAt(tester, AppRoutes.home);
    expect(find.byType(HomePage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(
      platformCalls.where(
        (MethodCall call) => call.method == 'moveTaskToBack',
      ),
      isNotEmpty,
      reason: '首页 Back 必须走 moveTaskToBack 退到后台',
    );
    expect(
      platformCalls.where(
        (MethodCall call) => call.method == 'SystemNavigator.pop',
      ),
      isEmpty,
      reason: '红线：返回路径不得调用 finish()（SystemNavigator.pop）',
    );
    // 「退到后台」≠「退出账号」：不得把用户送回登录页 / 清掉登录态。
    expect(find.byType(OnboardingLoginPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('首页：软键盘打开时 Back 只收键盘，不退后台', (WidgetTester tester) async {
    final List<MethodCall> platformCalls = installPlatformMocks(tester);

    await pumpAt(tester, AppRoutes.home);
    // 模拟软键盘把页面顶起。
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(
      platformCalls.where(
        (MethodCall call) => call.method == 'moveTaskToBack',
      ),
      isEmpty,
      reason: '软键盘优先：第一次 Back 只收键盘',
    );
  });

  testWidgets('Onboarding 栈底 Back：退后台，不 finish、不进入首页', (
    WidgetTester tester,
  ) async {
    final List<MethodCall> platformCalls = installPlatformMocks(tester);

    await pumpAt(tester, AppRoutes.onboardingLogin);
    expect(find.byType(OnboardingLoginPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(
      platformCalls.where(
        (MethodCall call) => call.method == 'moveTaskToBack',
      ),
      isNotEmpty,
      reason: '登录前栈底 Back 只能退后台',
    );
    expect(
      platformCalls.where(
        (MethodCall call) => call.method == 'SystemNavigator.pop',
      ),
      isEmpty,
      reason: '红线：返回路径不得调用 finish()',
    );
    expect(
      find.byType(HomePage),
      findsNothing,
      reason: '未登录不能借 Back 进入首页',
    );
  });

  testWidgets('Shell 之外顶级页直接进入：Back 先补首页，不退后台', (WidgetTester tester) async {
    final List<MethodCall> platformCalls = installPlatformMocks(tester);

    await pumpAt(tester, AppRoutes.settings);
    expect(find.byType(HomePage), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(
      find.byType(HomePage),
      findsOneWidget,
      reason: '深链 / 调试直接进 /settings 时，Back 必须把首页补到栈底',
    );
    expect(
      platformCalls.where(
        (MethodCall call) => call.method == 'moveTaskToBack',
      ),
      isEmpty,
      reason: '非首页的栈底页不应直接退后台',
    );
  });

  testWidgets('分支内二级页：Back 只 pop 回分支根，不回首页', (WidgetTester tester) async {
    await pumpAt(tester, AppRoutes.profileCapability);
    expect(find.byType(CapabilityPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(
      find.byType(CapabilityPage),
      findsNothing,
      reason: '二级页应该被 go_router 先 pop 掉',
    );
    expect(
      find.byType(ProfilePage),
      findsOneWidget,
      reason: 'pop 后回到「我的」分支根，而不是首页',
    );
    expect(find.byType(HomePage), findsNothing);
  });
}
