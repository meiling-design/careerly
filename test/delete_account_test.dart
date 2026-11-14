import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/repositories/auth_repository.dart';
import 'package:careerly/design_system/components/components.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_splash_page.dart';
import 'package:careerly/features/onboarding/state/auth_provider.dart';
import 'package:careerly/features/profile/presentation/delete_account_page.dart';
import 'package:careerly/features/profile/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// 注销账号（发布基线 K19）—— 设置入口 → 二级页 → 强确认 → 仓库 → 回登录入口。
///
/// ## 这里钉住的是什么
///
/// Google Play 要求 App 内提供账号删除入口。能钉住的是：
///
/// ```text
/// 入口可达      设置页「注销账号」不是死按钮，能进二级页
/// 不会误触      弹层未确认时**一次仓库调用都没有**
/// 取消安全      点 scrim / 取消 → 不删除、留在原页
/// 失败不跳转    仓库抛错 → 留在页面、可重试（按钮不永久禁用）
/// 成功回登录    删除成功 → 落到登录入口
/// 状态不串台    注销与退出的状态互相独立（两条流程共用一个字段会串）
/// ```
///
/// ⚠️ **本文件不验证「数据真的被删了」** —— 那是后端的事，
/// 由 `work_agent/tests/` 下的 `test_release_security_baseline.py`
/// （凭据立即失效）与 `test_account_purge.py`（级联清除且不误删他人数据）覆盖。
/// Mock 仓库没有账号也没有数据，在这里断言「删干净了」只会验证一个假象。
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
          ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider(repo)),
        ],
      ),
    );
    await settle(tester);
  }

  /// 弹层里的按钮（页面上也有同名按钮，必须限定范围）。
  Finder inSheet(String label) => find.descendant(
    of: find.byType(CareerlyBottomSheet),
    matching: find.text(label),
  );

  // ── State 层 ─────────────────────────────────────────────────────────────

  group('AuthProvider.deleteAccount', () {
    test('成功 → 返回 true 且状态为 success', () async {
      final _RecordingAuthRepository repo = _RecordingAuthRepository();
      final AuthProvider provider = AuthProvider(repo);

      final bool ok = await provider.deleteAccount();

      expect(ok, isTrue);
      expect(repo.deleteCalls, 1);
      expect(provider.deleteStatus, AuthDeleteAccountStatus.success);
      expect(provider.deleteError, isNull);
    });

    test('失败 → 返回 false 且错误被归一化进 deleteError（不抛异常）', () async {
      final _RecordingAuthRepository repo = _RecordingAuthRepository(failing: true);
      final AuthProvider provider = AuthProvider(repo);

      final bool ok = await provider.deleteAccount();

      expect(ok, isFalse);
      expect(provider.deleteStatus, AuthDeleteAccountStatus.failure);
      expect(provider.deleteError, isA<AppError>());
    });

    test('resetDeleteAccount 回到 idle，清掉错误', () async {
      final _RecordingAuthRepository repo = _RecordingAuthRepository(failing: true);
      final AuthProvider provider = AuthProvider(repo);
      await provider.deleteAccount();

      provider.resetDeleteAccount();

      expect(provider.deleteStatus, AuthDeleteAccountStatus.idle);
      expect(provider.deleteError, isNull);
    });

    test('⚠️ 注销与退出的状态互相独立（共用字段会串台）', () async {
      final _RecordingAuthRepository repo = _RecordingAuthRepository();
      final AuthProvider provider = AuthProvider(repo);

      // 先退出一 次，让「退出」状态停在 success。
      await provider.logout();
      expect(provider.status, AuthLogoutStatus.success);

      // 此时注销状态必须仍是 idle —— 否则注销页会读到一个
      // 属于**上一次操作**的 success。
      expect(provider.deleteStatus, AuthDeleteAccountStatus.idle);

      await provider.deleteAccount();
      expect(provider.status, AuthLogoutStatus.success, reason: '退出状态不该被注销改写');
      expect(provider.deleteStatus, AuthDeleteAccountStatus.success);
    });
  });

  // ── 页面与流程 ───────────────────────────────────────────────────────────

  testWidgets('设置页「注销账号」可进二级页（不是死按钮）', (WidgetTester tester) async {
    await pumpSettings(tester, repo: _RecordingAuthRepository());

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('注销账号'), findsOneWidget);
    await tester.tap(find.text('注销账号'));
    await settle(tester);

    expect(find.byType(DeleteAccountPage), findsOneWidget);
  });

  testWidgets('二级页说明缓冲期，且不谎称「立即永久删除」', (WidgetTester tester) async {
    await pumpSettings(tester, repo: _RecordingAuthRepository());
    await tester.tap(find.text('注销账号'));
    await settle(tester);

    // 缓冲期必须被说出来 —— 后端确实是 30 天后才物理清除。
    expect(
      find.textContaining('${DeleteAccountPage.purgeGraceDays} 天'),
      findsWidgets,
    );
    expect(find.textContaining('立即永久删除'), findsNothing);
  });

  testWidgets('点「注销账号」只弹确认层，不调用仓库', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository();
    await pumpSettings(tester, repo: repo);
    await tester.tap(find.text('注销账号'));
    await settle(tester);

    // 页面上有两个「注销账号」文本（TopBar 标题 + 按钮），必须定位到按钮。
    await tester.tap(find.widgetWithText(CareerlyButton, '注销账号'));
    await settle(tester);

    expect(find.byType(CareerlyBottomSheet), findsOneWidget);
    expect(inSheet('确认注销'), findsOneWidget);
    expect(repo.deleteCalls, 0, reason: '确认前一次仓库调用都不该有');
  });

  testWidgets('确认层选「取消」→ 不注销、留在二级页', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository();
    await pumpSettings(tester, repo: repo);
    await tester.tap(find.text('注销账号'));
    await settle(tester);
    // 页面上有两个「注销账号」文本（TopBar 标题 + 按钮），必须定位到按钮。
    await tester.tap(find.widgetWithText(CareerlyButton, '注销账号'));
    await settle(tester);
    await tester.tap(inSheet('取消'));
    await settle(tester);

    expect(repo.deleteCalls, 0, reason: '取消不得触发注销');
    expect(find.byType(DeleteAccountPage), findsOneWidget);
  });

  testWidgets('确认 → 调用仓库并落到登录入口', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository();
    await pumpSettings(tester, repo: repo);
    await tester.tap(find.text('注销账号'));
    await settle(tester);
    // 页面上有两个「注销账号」文本（TopBar 标题 + 按钮），必须定位到按钮。
    await tester.tap(find.widgetWithText(CareerlyButton, '注销账号'));
    await settle(tester);
    await tester.tap(inSheet('确认注销'));
    await settle(tester);

    expect(repo.deleteCalls, 1);
    expect(find.byType(OnboardingSplashPage), findsOneWidget);
  });

  testWidgets('失败 → 留在页面且按钮恢复可用（可重试）', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository(failing: true);
    await pumpSettings(tester, repo: repo);
    await tester.tap(find.text('注销账号'));
    await settle(tester);
    // 页面上有两个「注销账号」文本（TopBar 标题 + 按钮），必须定位到按钮。
    await tester.tap(find.widgetWithText(CareerlyButton, '注销账号'));
    await settle(tester);
    await tester.tap(inSheet('确认注销'));
    await settle(tester);

    expect(find.byType(DeleteAccountPage), findsOneWidget, reason: '失败不得跳转');
    expect(find.byType(OnboardingSplashPage), findsNothing);

    // 关键：状态必须被复位，否则按钮永久禁用、用户再也点不动。
    final CareerlyButton button = tester.widget<CareerlyButton>(
      find.widgetWithText(CareerlyButton, '注销账号'),
    );
    expect(button.onPressed, isNotNull, reason: '失败后必须恢复可点');
  });
}

/// 记录调用的假仓库；[failing] 为真时每次调用都失败。
class _RecordingAuthRepository implements AuthRepository {
  _RecordingAuthRepository({this.failing = false});

  final bool failing;
  int deleteCalls = 0;
  int deleteCareerDataCalls = 0;

  @override
  Future<void> register({
    required String name,
    required String phone,
    required String password,
  }) async {}

  @override
  Future<void> login({required String phone, required String password}) async {}

  @override
  Future<void> resetPassword({
    required String phone,
    required String newPassword,
  }) async {}

  @override
  Future<void> signInWithOAuth({required String provider}) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> deleteAccount() async {
    deleteCalls++;
    if (failing) throw const NetworkError(detail: 'test');
  }

  @override
  Future<CareerDataDeletionResult> deleteCareerData() async {
    deleteCareerDataCalls++;
    if (failing) throw const NetworkError(detail: 'test');
    return const CareerDataDeletionResult(
      deletedRows: 0,
      deletedFiles: 0,
      orphanArtifacts: 0,
      warnings: <String>[],
    );
  }
}
