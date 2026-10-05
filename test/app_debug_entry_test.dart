import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_debug_entry.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/features/home/presentation/home_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_splash_page.dart';
import 'package:flutter_test/flutter_test.dart';

/// Careerly 开发期启动入口开关（`AppDebugEntry`）的守卫测试。
///
/// ## 这份测试钉住什么
///
/// 1. **默认入口是欢迎页** —— 当前未接入会话持久化，首次启动进入
///    Onboarding；后续 Auth / Cache 阶段再补充已注册用户跳过逻辑。
/// 2. **短名表指向真实路由** —— 表里写错一个字母，
///    验收当天就会落到错误的屏幕上，而 `flutter analyze` 抓不到。
/// 3. **未知值不猜路径** —— 回退语义必须是「交回调用方决定」，
///    而不是把 `confirm` 拼成 `/onboarding/confirm` 之类的想当然。
///
/// ## 这个文件是临时的
///
/// 与 `lib/app/router/app_debug_entry.dart` 同生共死：
/// **D54 裁决后两者应一并删除**（届时入口由会话持久化决定）。
void main() {
  // ---------------------------------------------------------------------------
  // 默认启动进入欢迎页
  // ---------------------------------------------------------------------------

  group('默认入口 · 欢迎页', () {
    test('未传 CAREERLY_ENTRY 时落在欢迎页', () {
      // `String.fromEnvironment` 在测试进程里恒为空串 ——
      // 因此这个断言**就是**「不传 --dart-define」的场景，不是模拟。
      expect(AppDebugEntry.initialLocation, AppRoutes.onboardingSplash);
    });

    testWidgets('默认启动渲染欢迎页', (WidgetTester tester) async {
      await tester.pumpWidget(
        CareerlyApp(initialLocation: AppDebugEntry.initialLocation),
      );

      // Mock 数据层默认延迟 600ms，推进假时钟走完，让首页离开 Loading 态。
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.byType(OnboardingSplashPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // 开关本身
  // ---------------------------------------------------------------------------

  group('AppDebugEntry · 入口值解析', () {
    test('短名映射到对应路由', () {
      expect(AppDebugEntry.resolve('home'), AppRoutes.home);
      expect(AppDebugEntry.resolve('analysis'), AppRoutes.analysis);
      expect(AppDebugEntry.resolve('ai'), AppRoutes.ai);
      expect(AppDebugEntry.resolve('profile'), AppRoutes.profile);
      expect(AppDebugEntry.resolve('splash'), AppRoutes.onboardingSplash);
      expect(AppDebugEntry.resolve('register'), AppRoutes.onboardingRegister);
      expect(AppDebugEntry.resolve('resume'), AppRoutes.onboardingResume);
      expect(AppDebugEntry.resolve('parsing'), AppRoutes.onboardingParsing);
      expect(AppDebugEntry.resolve('confirm'), AppRoutes.onboardingConfirm);
    });

    test('以 / 开头的完整路径原样透传', () {
      expect(
        AppDebugEntry.resolve('/onboarding/confirm'),
        AppRoutes.onboardingConfirm,
      );
    });

    test('首尾空白被忽略', () {
      expect(AppDebugEntry.resolve('  splash  '), AppRoutes.onboardingSplash);
    });

    test('空值返回 null，由调用方回退', () {
      expect(AppDebugEntry.resolve(''), isNull);
      expect(AppDebugEntry.resolve('   '), isNull);
    });

    test('未知短名返回 null —— 不猜测路径', () {
      expect(
        AppDebugEntry.resolve('onboarding'),
        isNull,
        reason: '这不是一条真实路由；猜成 /onboarding 会落到「页面不存在」页',
      );
      expect(AppDebugEntry.resolve('splashh'), isNull);
    });

    test('短名表里的每个值都是真实存在的路由', () {
      const Set<String> knownRoutes = <String>{
        AppRoutes.home,
        AppRoutes.analysis,
        AppRoutes.ai,
        AppRoutes.profile,
        AppRoutes.onboardingSplash,
        AppRoutes.onboardingRegister,
        // ⚠️ 2026-10-04 补入 —— `shortNames` 里的 `'login'` 指向
        // [AppRoutes.onboardingLogin]，而本白名单此前漏了它，
        // 于是「每个短名都指向真实路由」这条断言**恒失败**。
        // 该路由自登录页落地起就在 `app_router.dart` 注册过
        // （`location: AppRoutes.onboardingLogin`），是白名单没跟上，
        // 不是路由不存在 —— 故修白名单，不改断言。
        AppRoutes.onboardingLogin,
        AppRoutes.onboardingResume,
        AppRoutes.onboardingParsing,
        AppRoutes.onboardingConfirm,
      };

      for (final MapEntry<String, String> entry
          in AppDebugEntry.shortNames.entries) {
        expect(
          knownRoutes,
          contains(entry.value),
          reason: '短名 "${entry.key}" 指向了不存在的路由 "${entry.value}"',
        );
      }
    });

    test('defineKey 与文档里写的一致', () {
      // 改动这个键名会让文档、命令示例与实现三者脱节。
      expect(AppDebugEntry.defineKey, 'CAREERLY_ENTRY');
    });
  });
}
