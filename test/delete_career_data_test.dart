import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/repositories/auth_repository.dart';
import 'package:careerly/design_system/components/components.dart';
import 'package:careerly/features/onboarding/state/auth_provider.dart';
import 'package:careerly/features/profile/presentation/delete_career_data_page.dart';
import 'package:careerly/features/profile/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

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

  Finder inSheet(String label) => find.descendant(
    of: find.byType(CareerlyBottomSheet),
    matching: find.text(label),
  );

  group('AuthProvider.deleteCareerData', () {
    test('清理成功后保留账号删除状态独立', () async {
      final _RecordingAuthRepository repo = _RecordingAuthRepository();
      final AuthProvider provider = AuthProvider(repo);

      final bool ok = await provider.deleteCareerData();

      expect(ok, isTrue);
      expect(repo.deleteCareerDataCalls, 1);
      expect(repo.deleteAccountCalls, 0);
      expect(provider.careerDataStatus, AuthDeleteCareerDataStatus.success);
      expect(provider.careerDataResult?.deletedRows, 4);
      expect(provider.deleteStatus, AuthDeleteAccountStatus.idle);
    });

    test('失败时留在可重试状态并保存错误', () async {
      final AuthProvider provider = AuthProvider(
        _RecordingAuthRepository(failing: true),
      );

      expect(await provider.deleteCareerData(), isFalse);
      expect(provider.careerDataStatus, AuthDeleteCareerDataStatus.failure);
      expect(provider.careerDataError, isA<AppError>());

      provider.resetDeleteCareerData();

      expect(provider.careerDataStatus, AuthDeleteCareerDataStatus.idle);
      expect(provider.careerDataError, isNull);
    });
  });

  testWidgets('隐私与数据入口可到达独立删除页', (WidgetTester tester) async {
    await pumpSettings(tester, repo: _RecordingAuthRepository());

    expect(find.byType(SettingsPage), findsOneWidget);
    await tester.tap(find.text('删除职业数据'));
    await settle(tester);

    expect(find.byType(DeleteCareerDataPage), findsOneWidget);
    expect(find.text('账号会保留'), findsOneWidget);
    expect(find.textContaining('当前登录状态不会被删除'), findsOneWidget);
  });

  testWidgets('二次确认前不触发删除；取消保持原页', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository();
    await pumpSettings(tester, repo: repo);
    await tester.tap(find.text('删除职业数据'));
    await settle(tester);
    await tester.tap(find.widgetWithText(CareerlyButton, '删除职业数据'));
    await settle(tester);

    expect(repo.deleteCareerDataCalls, 0);
    expect(inSheet('确认删除'), findsOneWidget);
    await tester.tap(inSheet('取消'));
    await settle(tester);

    expect(repo.deleteCareerDataCalls, 0);
    expect(find.byType(DeleteCareerDataPage), findsOneWidget);
  });

  testWidgets('确认后清理职业数据但不退出登录', (WidgetTester tester) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository();
    await pumpSettings(tester, repo: repo);
    await tester.tap(find.text('删除职业数据'));
    await settle(tester);
    await tester.tap(find.widgetWithText(CareerlyButton, '删除职业数据'));
    await settle(tester);
    await tester.tap(inSheet('确认删除'));
    await settle(tester);

    expect(repo.deleteCareerDataCalls, 1);
    expect(repo.deleteAccountCalls, 0);
    expect(find.byType(DeleteCareerDataPage), findsOneWidget);
  });

  testWidgets('无法归属的文件以警告提示，不报告为完全删除', (
    WidgetTester tester,
  ) async {
    final _RecordingAuthRepository repo = _RecordingAuthRepository(
      result: const CareerDataDeletionResult(
        deletedRows: 4,
        deletedFiles: 2,
        orphanArtifacts: 3,
        warnings: <String>['部分历史文件无法确认归属，未被删除。'],
      ),
    );
    await pumpSettings(tester, repo: repo);
    await tester.tap(find.text('删除职业数据'));
    await settle(tester);
    await tester.tap(find.widgetWithText(CareerlyButton, '删除职业数据'));
    await settle(tester);
    await tester.tap(inSheet('确认删除'));
    await settle(tester);

    expect(find.textContaining('3 个历史文件无法确认归属'), findsOneWidget);
  });
}

class _RecordingAuthRepository implements AuthRepository {
  _RecordingAuthRepository({
    this.failing = false,
    this.result = const CareerDataDeletionResult(
      deletedRows: 4,
      deletedFiles: 2,
      orphanArtifacts: 0,
      warnings: <String>[],
    ),
  });

  final bool failing;
  final CareerDataDeletionResult result;
  int deleteCareerDataCalls = 0;
  int deleteAccountCalls = 0;

  @override
  Future<void> register({
    required String name,
    required String phone,
    required String password,
  }) async {}

  @override
  Future<void> login({required String phone, required String password}) async {}

  @override
  Future<void> signInWithOAuth({required String provider}) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<CareerDataDeletionResult> deleteCareerData() async {
    deleteCareerDataCalls++;
    if (failing) throw const NetworkError(detail: 'test');
    return result;
  }

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalls++;
  }
}
