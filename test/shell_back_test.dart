import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/features/home/presentation/home_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_login_page.dart';
import 'package:careerly/features/profile/presentation/capability_page.dart';
import 'package:careerly/features/profile/presentation/profile_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 一级页面的 Android Back / 边缘右滑规则（2026-11-14 产品侧更新）。
///
/// ```text
/// 首页            → 直接退出 App
/// 分析 / AI / 我的 → 第一次回到首页；在首页再 Back 才退出
/// ```
///
/// 执行层在 `CareerlyShell` 的 `PopScope`；本文件只验证「按下的那一刻
/// 当前分支是否切到了首页 / 是否真的调用了 SystemNavigator.pop」。
void main() {
  Future<void> pumpAt(WidgetTester tester, String location) async {
    await tester.pumpWidget(CareerlyApp(initialLocation: location));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  for (final String location in <String>[
    AppRoutes.analysis,
    AppRoutes.ai,
    AppRoutes.profile,
  ]) {
    testWidgets('一级页面 $location：Back 先回首页，不退出', (WidgetTester tester) async {
      final List<MethodCall> platformCalls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          platformCalls.add(call);
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

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
    });
  }

  testWidgets('首页：Back 直接退出 App', (WidgetTester tester) async {
    final List<MethodCall> platformCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        platformCalls.add(call);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await pumpAt(tester, AppRoutes.home);
    expect(find.byType(HomePage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(
      platformCalls.where(
        (MethodCall call) => call.method == 'SystemNavigator.pop',
      ),
      isNotEmpty,
      reason: '首页 Back 必须交给系统退出',
    );
    // 「退出程序」≠「退出账号」：不得把用户送回登录页 / 清掉登录态。
    expect(find.byType(OnboardingLoginPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
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
