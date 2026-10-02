import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/repositories/auth_repository.dart';
import 'package:careerly/design_system/components/careerly_bottom_sheet.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_splash_page.dart';
import 'package:careerly/features/onboarding/state/auth_provider.dart';
import 'package:careerly/features/profile/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// 「退出登录」接通真实功能 —— 设置页按钮 → 确认 → 清会话 → 回登录入口。
///
/// ## 这一步接的是什么
///
/// 此前 `settings_page.dart` 的「退出登录」是 `onPressed: () {}`（死按钮）。
/// 现在它接到 [AuthRepository.logout]：
///
/// ```text
/// 设置页 → AuthProvider → AuthRepository → ApiClient.clearSession()
/// ```
///
/// ⚠️ 后端**没有 logout 端点** —— 退出 = 客户端丢弃令牌（内存 + 安全存储）。
/// 因此**没有** HTTP 断言可写，能钉住的是：仓库方法被调用、失败不跳转、
/// 成功落到登录入口。
///
/// ## 为什么用 `ChangeNotifierProvider<AuthProvider>.value` 注入
///
/// [AuthProvider] 在 `careerlyProviders` 里**早于**尾部 overrides 注册，
/// 而它的构造依赖 (`AuthRepository`) 是**在 create 时从上层解析**的 ——
/// 尾部追加的 `Provider<AuthRepository>` 到不了它。因此这里直接替换
/// [AuthProvider] 这一层（它在页面之下，尾部覆盖有效）。
void main() {
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  /// 落在设置页，并把 [AuthProvider] 换成由 [repo] 驱动的实例。
  Future<void> pumpSettings(
    WidgetTester tester, {
    required _RecordingAuthRepository repo,
  }) async {
    useTallViewport(tester);
    await tester.pumpWidget(
      CareerlyApp(
        initialLocation: AppRoutes.settings,
        overrides: <SingleChildWidget>[
          ChangeNotifierProvider<AuthProvider>.value(
            value: AuthProvider(repo),
          ),
        ],
      ),
    );
    await settle(tester);
  }

  /// 弹层里的按钮（页面上的「退出登录」是另一个同名按钮，必须限定范围）。
  Finder inSheet(String label) => find.descendant(
    of: find.byType(CareerlyBottomSheet),
    matching: find.text(label),
  );

  testWidgets('设置页「退出登录」不再是死按钮：点击后弹出确认层', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository();
    await pumpSettings(tester, repo: repo);

    expect(find.byType(SettingsPage), findsOneWidget);

    await tester.tap(find.text('退出登录'));
    await settle(tester);

    expect(find.byType(CareerlyBottomSheet), findsOneWidget);
    expect(inSheet('退出登录'), findsOneWidget);
    expect(inSheet('取消'), findsOneWidget);

    // 只弹层、还没退出。
    expect(repo.logoutCalls, 0);
  });

  testWidgets('确认层选「取消」→ 不退出、仍留在设置页', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository();
    await pumpSettings(tester, repo: repo);

    await tester.tap(find.text('退出登录'));
    await settle(tester);
    await tester.tap(inSheet('取消'));
    await settle(tester);

    expect(repo.logoutCalls, 0, reason: '取消不得触发退出');
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byType(OnboardingSplashPage), findsNothing);
  });

  testWidgets('确认退出 → 调用仓库并回到登录入口', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository();
    await pumpSettings(tester, repo: repo);

    await tester.tap(find.text('退出登录'));
    await settle(tester);
    await tester.tap(inSheet('退出登录'));
    await settle(tester);

    expect(repo.logoutCalls, 1, reason: '确认后必须真的清会话');
    expect(find.byType(OnboardingSplashPage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);
  });

  testWidgets('退出失败 → 不跳转、留在设置页并提示', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository(failing: true);
    await pumpSettings(tester, repo: repo);

    await tester.tap(find.text('退出登录'));
    await settle(tester);
    await tester.tap(inSheet('退出登录'));
    await settle(tester);

    expect(repo.logoutCalls, 1);
    expect(find.byType(SettingsPage), findsOneWidget, reason: '失败不得离开当前页');
    expect(find.byType(OnboardingSplashPage), findsNothing);
    expect(find.byIcon(Icons.error_outline), findsOneWidget, reason: '失败必须可见（四态）');
  });

  group('AuthProvider · 退出状态机', () {
    test('成功 → status=success，返回 true', () async {
      final AuthProvider provider = AuthProvider(_RecordingAuthRepository());
      expect(provider.status, AuthLogoutStatus.idle);

      final bool ok = await provider.logout();

      expect(ok, isTrue);
      expect(provider.status, AuthLogoutStatus.success);
      expect(provider.error, isNull);
    });

    test('失败 → status=failure，返回 false，错误可读', () async {
      final AuthProvider provider = AuthProvider(
        _RecordingAuthRepository(failing: true),
      );

      final bool ok = await provider.logout();

      expect(ok, isFalse);
      expect(provider.status, AuthLogoutStatus.failure);
      expect(provider.error, isA<AppError>());
    });

    test('reset() → 回到 idle，清掉旧失败态', () async {
      final AuthProvider provider = AuthProvider(
        _RecordingAuthRepository(failing: true),
      );
      await provider.logout();

      provider.reset();

      expect(provider.status, AuthLogoutStatus.idle);
      expect(provider.error, isNull);
    });
  });
}

/// 记录调用的假仓库；[failing] 为真时每次调用都失败。
class _RecordingAuthRepository implements AuthRepository {
  _RecordingAuthRepository({this.failing = false});

  final bool failing;
  int logoutCalls = 0;

  @override
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  }) async {}

  @override
  Future<void> login({required String phone}) async {}

  @override
  Future<void> logout() async {
    logoutCalls++;
    if (failing) throw const NetworkError(detail: 'test');
  }
}
