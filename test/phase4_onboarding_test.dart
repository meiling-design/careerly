import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/mock/mock.dart';
import 'package:careerly/data/repositories/repositories.dart';
import 'package:careerly/design_system/components/careerly_button.dart';
import 'package:careerly/design_system/components/careerly_chip.dart';
import 'package:careerly/design_system/components/careerly_navigation_bar.dart';
import 'package:careerly/features/home/presentation/home_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_register_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_splash_page.dart';
import 'package:careerly/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:careerly/features/onboarding/state/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Careerly Phase 4 批 1 —— Onboarding 开屏 + 注册 的验收测试。
///
/// 覆盖的是**可在单测里验证**的部分：路由可达性、表单可用态、
/// 提交链路（Loading → Success / Failure）、以及 Figma 那条
/// 「两个按钮都跳注册页」的行为**被显式钉住**（防止后人顺手"修好"它）。
///
/// 视觉部分（渐变、玻璃返回钮、玻璃球的观感）不在此验证 ——
/// 见 `docs/05_progress/CURRENT_STATUS.md` 的视觉定稿流程。
void main() {
  /// Mock 数据层的默认延迟是 600ms，测试里需要推进假时钟把它走完。
  ///
  /// ⚠️ 必须推进**两段**时钟，不能只推一段。
  ///
  /// 提交是**异步**的：600ms 延迟走完才触发跳转，而跳转的**页面转场
  /// 在那之后才开始**。只推一段时，转场恰好停在第一帧 ——
  /// 旧页仍在树上，断言 `findsNothing` 会误报失败。
  /// （「邮箱是选填：留空也能提交」曾因此长期红灯，实为夹具缺陷，非产品缺陷。）
  Future<void> settleMock(WidgetTester tester) async {
    await tester.pump();

    // 第一段：走完 Mock 的网络延迟。
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    // 第二段：走完延迟之后才开始的页面转场。
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  /// 启动 App 并直接落在指定入口。
  Future<void> pumpAt(WidgetTester tester, String location) async {
    await tester.pumpWidget(CareerlyApp(initialLocation: location));
    await settleMock(tester);
  }

  /// 取出某个按钮当前是否可点。
  ///
  /// `CareerlyButton.onPressed == null` 即 Disabled 态。
  bool isEnabled(WidgetTester tester, String label) {
    final CareerlyButton button = tester.widget<CareerlyButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(CareerlyButton),
      ),
    );
    return button.onPressed != null;
  }

  /// 取出账号页当前的**初始形态**（进入本页时由路由 `?mode=` 决定）。
  ///
  /// ⚠️ 它**不跟随页内切换**：页内切换改的是 State 私有字段，
  /// 组件上的 `initialMode` 始终是进入时的值。断言「页内切到了哪」要看
  /// 渲染结果（字段数 / 按钮文案）或 [isModeSelected]。
  OnboardingAccountMode initialModeOf(WidgetTester tester) {
    return tester
        .widget<OnboardingRegisterPage>(find.byType(OnboardingRegisterPage))
        .initialMode;
  }

  /// 形态切换控件里的某枚 Chip。
  ///
  /// 用 `find.ancestor` 收窄，因为切换控件与主按钮可能**同名**
  /// （登录形态下「登录」既是 Chip 也是按钮）。
  Finder modeChip(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byType(CareerlyChip),
    );
  }

  /// 某枚形态 Chip 是否为选中态（选中 = `dark` 色调，见 `_AccountModeSwitch`）。
  bool isModeSelected(WidgetTester tester, String label) {
    return tester.widget<CareerlyChip>(modeChip(label)).tone ==
        CareerlyChipTone.dark;
  }

  group('Phase 4 · 开屏页', () {
    testWidgets('落在 /onboarding/splash 时渲染开屏页，且没有底部导航', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingSplash);

      expect(find.byType(OnboardingSplashPage), findsOneWidget);

      // Onboarding 在 Shell 之外：**不得**出现底部导航。
      expect(
        find.text('首页'),
        findsNothing,
        reason: 'Onboarding 不属于任何一级导航，不应渲染 Shell 的导航栏',
      );
    });

    testWidgets('展示品牌名与两个入口按钮', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingSplash);

      expect(find.text('Careerly'), findsOneWidget);
      expect(find.text('看见能力 · 跨越 Gap'), findsOneWidget);
      expect(find.text('记录成长'), findsOneWidget);
      expect(find.text('你的职业成长，从看见自己开始。'), findsOneWidget);

      expect(find.text('点击登录'), findsOneWidget);
      expect(find.text('点击注册'), findsOneWidget);
    });

    testWidgets('「点击注册」进入**注册形态**的账号页', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingSplash);

      await tester.tap(find.text('点击注册'));
      await settleMock(tester);

      expect(find.byType(OnboardingRegisterPage), findsOneWidget);
      expect(initialModeOf(tester), OnboardingAccountMode.register);
      expect(find.text('创建你的个人账号 📋'), findsOneWidget);
    });

    testWidgets('「点击登录」进入**登录形态**的同一个页面 —— D85 已改写 Figma 原行为', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingSplash);

      await tester.tap(find.text('点击登录'));
      await settleMock(tester);

      // 这条断言在 D85 之前钉的是「两个按钮**都**进注册页」
      // （Figma `App.tsx` L409 / L416 的 onClick 都是 go('on-register')）。
      //
      // D85（2026-09-21 产品侧裁决）把登录补成账号页的**模式切换**：
      // 页面类没变、路径没变、**没有新增路由**，只是带上了 `?mode=login`。
      // 因此这里改钉「同一页面的登录形态」，而不是「多了个登录页」。
      expect(
        find.byType(OnboardingRegisterPage),
        findsOneWidget,
        reason: '登录仍是同一个账号页，没有独立登录页',
      );
      expect(
        initialModeOf(tester),
        OnboardingAccountMode.login,
        reason: '「点击登录」应带 ?mode=login 进入，而不是落回注册形态',
      );
      expect(find.text('登录你的账号'), findsOneWidget);
    });
  });

  group('Phase 4 · 注册页', () {
    testWidgets('渲染进度头、标题与三个字段', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      expect(find.byType(OnboardingProgressHeader), findsOneWidget);
      expect(find.text('创建你的个人账号 📋'), findsOneWidget);
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('手机号'), findsOneWidget);
      expect(find.text('邮箱（选填）'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('必填为空时「继续」不可用', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      expect(
        isEnabled(tester, '继续'),
        isFalse,
        reason: '姓名与手机号均为空时，主按钮必须是 Disabled 态（四态要求）',
      );
    });

    testWidgets('只填姓名仍不可用，填齐姓名 + 手机号后可用', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      final Finder fields = find.byType(TextField);

      await tester.enterText(fields.at(0), '张三');
      await tester.pump();
      expect(
        isEnabled(tester, '继续'),
        isFalse,
        reason: '手机号是必填项，只填姓名不足以解锁',
      );

      await tester.enterText(fields.at(1), '13800000000');
      await tester.pump();
      expect(isEnabled(tester, '继续'), isTrue);
    });

    testWidgets('邮箱是选填：留空也能提交', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      final Finder fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '张三');
      await tester.enterText(fields.at(1), '13800000000');
      await tester.pump();

      await tester.tap(find.text('继续'));
      await settleMock(tester);

      // 提交成功后离开 Onboarding（本批的临时接线：先回首页）。
      expect(find.byType(OnboardingRegisterPage), findsNothing);
    });

    testWidgets('「跳过，稍后完善」不提交表单，直接离开', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      // 什么都不填就能跳 —— 它不经过 Repository。
      expect(isEnabled(tester, '继续'), isFalse);
      await tester.tap(find.text('跳过，稍后完善'));
      await settleMock(tester);

      expect(find.byType(OnboardingRegisterPage), findsNothing);
    });

    testWidgets('提交失败时停留原页并给出错误提示（额度 / 网络类失败可重试）', (
      WidgetTester tester,
    ) async {
      MockSettings.config = const MockConfig(
        latency: Duration(milliseconds: 10),
        failNext: true,
      );
      addTearDown(() => MockSettings.config = MockConfig.standard);

      await pumpAt(tester, AppRoutes.onboardingRegister);

      final Finder fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '张三');
      await tester.enterText(fields.at(1), '13800000000');
      await tester.pump();

      await tester.tap(find.text('继续'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 失败必须停在原页，而不是假装成功跳走。
      expect(find.byType(OnboardingRegisterPage), findsOneWidget);
      // 错误文案来自 AppError.message，经 CareerlyToast 呈现。
      expect(find.textContaining('网络'), findsWidgets);

      // 且按钮回到可用态，用户能重试。
      expect(isEnabled(tester, '继续'), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // 登录形态（D85）—— Figma 无登录屏，字段集 / 文案 / 布局均为 Flutter 侧补齐
  // ---------------------------------------------------------------------------

  group('Phase 4 · 账号页：登录形态（D85）', () {
    testWidgets('只有手机号一个字段，主按钮为「登录」，没有「跳过，稍后完善」', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingRegisterLogin);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('手机号'), findsOneWidget);

      // 注册形态专有的三样都不该出现。
      expect(find.text('姓名'), findsNothing);
      expect(find.text('邮箱（选填）'), findsNothing);
      expect(find.text('跳过，稍后完善'), findsNothing);
      expect(find.text('继续'), findsNothing);

      // 仍然是同一个页面：进度头在，底部导航不在。
      expect(find.byType(OnboardingProgressHeader), findsOneWidget);
      expect(
        find.text('首页'),
        findsNothing,
        reason: '账号页不属于任何一级导航，不应渲染 Shell 的导航栏',
      );
    });

    testWidgets('手机号为空时「登录」不可用（沿用 D57 的最小规则）', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingRegisterLogin);

      expect(
        isEnabled(tester, '登录'),
        isFalse,
        reason: '手机号为空时必须是 Disabled 态（四态要求）',
      );

      await tester.enterText(find.byType(TextField), '13800000000');
      await tester.pump();

      expect(isEnabled(tester, '登录'), isTrue);
    });

    testWidgets('提交成功后**直接进入首页** —— 与注册形态的去向不同（D85）', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingRegisterLogin);

      await tester.enterText(find.byType(TextField), '13800000000');
      await tester.pump();

      // ⚠️ 「登录」既是形态 Chip 也是主按钮，必须收窄到 CareerlyButton。
      await tester.tap(find.widgetWithText(CareerlyButton, '登录'));
      await settleMock(tester);

      // 登录用户已有职业基线：不去「提交简历」，而是落到一级导航的首页。
      expect(find.byType(OnboardingRegisterPage), findsNothing);
      expect(
        find.byType(HomePage),
        findsOneWidget,
        reason: 'D85：登录成功后直接进首页，不走注册侧的 Onboarding 剩余步骤',
      );
      // 落地的是 Shell 内的一级页面 —— 底部导航随之出现。
      // ⚠️ 断言导航栏**组件**而不是「首页」文字：Figma 的三个标准 Tab
      // 是纯图标，文字标签只存在于 Semantics 里（见 `widget_test.dart`）。
      expect(
        find.byType(CareerlyNavigationBar),
        findsOneWidget,
        reason: '登录成功应落在 Shell 内（一级导航可见），而不是 Onboarding 流程页',
      );
    });

    testWidgets('提交失败时停留原页并给出错误提示，按钮回到可用态', (
      WidgetTester tester,
    ) async {
      MockSettings.config = const MockConfig(
        latency: Duration(milliseconds: 10),
        failNext: true,
      );
      addTearDown(() => MockSettings.config = MockConfig.standard);

      await pumpAt(tester, AppRoutes.onboardingRegisterLogin);

      await tester.enterText(find.byType(TextField), '13800000000');
      await tester.pump();

      await tester.tap(find.widgetWithText(CareerlyButton, '登录'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(OnboardingRegisterPage), findsOneWidget);
      expect(find.textContaining('网络'), findsWidgets);
      expect(isEnabled(tester, '登录'), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // 形态切换（D85）—— 同一页两种形态，不是两条路由
  // ---------------------------------------------------------------------------

  group('Phase 4 · 账号页：形态切换（D85）', () {
    testWidgets('注册形态下点「登录」Chip → 切到登录形态', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      expect(find.byType(TextField), findsNWidgets(3));
      expect(isModeSelected(tester, '注册'), isTrue);
      expect(isModeSelected(tester, '登录'), isFalse);

      await tester.tap(modeChip('登录'));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.widgetWithText(CareerlyButton, '登录'), findsOneWidget);
      expect(find.text('跳过，稍后完善'), findsNothing);
      expect(isModeSelected(tester, '登录'), isTrue);
      expect(isModeSelected(tester, '注册'), isFalse);
    });

    testWidgets('登录形态下点「注册」Chip → 切回注册形态', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegisterLogin);

      expect(find.byType(TextField), findsOneWidget);
      expect(isModeSelected(tester, '登录'), isTrue);

      await tester.tap(modeChip('注册'));
      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('创建你的个人账号 📋'), findsOneWidget);
      expect(find.widgetWithText(CareerlyButton, '继续'), findsOneWidget);
      expect(find.text('跳过，稍后完善'), findsOneWidget);
      expect(isModeSelected(tester, '注册'), isTrue);
    });

    testWidgets('切换形态**不清空**已填的手机号', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      // 注册形态下第 2 个字段是手机号。
      await tester.enterText(find.byType(TextField).at(1), '13800000000');
      await tester.pump();

      // ⚠️ 输入后焦点会把内容自动滚动一点（让光标回到可视区，实测 13px）。
      // 形态切换就贴在滚动区顶部，因此这点位移足以把它挤出命中区。
      // 测试里先把它滚回视野 —— 这不是产品缺陷，真机上用户同样可以滚回去
      // （该观感问题已记入 **待裁决 · D86**）。
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 60));
      await tester.pumpAndSettle();

      await tester.tap(modeChip('登录'));
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '13800000000',
        reason: '走错形态不该逼用户重填',
      );
      // 且登录按钮直接可用 —— 校验拿到的是同一个手机号。
      expect(isEnabled(tester, '登录'), isTrue);
    });
  });

  group('Phase 4 · OnboardingProvider', () {
    test('初始状态为 idle，提交成功后为 success', () async {
      final OnboardingProvider provider = OnboardingProvider(
        _RecordingAuthRepository(),
      );
      addTearDown(provider.dispose);

      expect(provider.status, OnboardingSubmitStatus.idle);
      expect(provider.error, isNull);

      final bool ok = await provider.submit(name: ' 张三 ', phone: ' 138 ');

      expect(ok, isTrue);
      expect(provider.status, OnboardingSubmitStatus.success);
      expect(provider.error, isNull);
    });

    test('提交前会 trim，空邮箱转成 null', () async {
      final _RecordingAuthRepository repository = _RecordingAuthRepository();
      final OnboardingProvider provider = OnboardingProvider(repository);
      addTearDown(provider.dispose);

      await provider.submit(name: ' 张三 ', phone: ' 138 ', email: '   ');

      expect(repository.lastName, '张三');
      expect(repository.lastPhone, '138');
      expect(repository.lastEmail, isNull);
    });

    test('失败时状态为 failure 且不抛异常', () async {
      final OnboardingProvider provider = OnboardingProvider(
        _FailingAuthRepository(),
      );
      addTearDown(provider.dispose);

      final bool ok = await provider.submit(name: '张三', phone: '138');

      expect(ok, isFalse);
      expect(provider.status, OnboardingSubmitStatus.failure);
      expect(provider.error, isNotNull);
    });

    test('login 走 AuthRepository.login，并 trim 手机号', () async {
      final _RecordingAuthRepository repository = _RecordingAuthRepository();
      final OnboardingProvider provider = OnboardingProvider(repository);
      addTearDown(provider.dispose);

      final bool ok = await provider.login(phone: ' 138 ');

      expect(ok, isTrue);
      expect(repository.lastLoginPhone, '138');
      expect(provider.status, OnboardingSubmitStatus.success);
      expect(provider.error, isNull);
    });

    test('login 失败时状态为 failure 且不抛异常', () async {
      final OnboardingProvider provider = OnboardingProvider(
        _FailingAuthRepository(),
      );
      addTearDown(provider.dispose);

      final bool ok = await provider.login(phone: '138');

      expect(ok, isFalse);
      expect(provider.status, OnboardingSubmitStatus.failure);
      expect(provider.error, isNotNull);
    });

    test('reset 清掉失败态，回到 idle', () async {
      final OnboardingProvider provider = OnboardingProvider(
        _FailingAuthRepository(),
      );
      addTearDown(provider.dispose);

      await provider.submit(name: '张三', phone: '138');
      expect(provider.error, isNotNull);

      provider.reset();

      expect(provider.status, OnboardingSubmitStatus.idle);
      expect(provider.error, isNull);
    });
  });
}

/// 记录最后一次调用参数的假 Repository。
class _RecordingAuthRepository implements AuthRepository {
  String? lastName;
  String? lastPhone;
  String? lastEmail;
  String? lastLoginPhone;
  bool lastLogoutCalled = false;

  @override
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    lastName = name;
    lastPhone = phone;
    lastEmail = email;
  }

  @override
  Future<void> login({required String phone}) async {
    lastLoginPhone = phone;
  }

  @override
  Future<void> logout() async {
    lastLogoutCalled = true;
  }
}

/// 恒定失败的假 Repository（注册 / 登录两条链路都失败）。
class _FailingAuthRepository implements AuthRepository {
  @override
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    throw const NetworkError(detail: 'test');
  }

  @override
  Future<void> login({required String phone}) async {
    throw const NetworkError(detail: 'test');
  }

  @override
  Future<void> logout() async {
    throw const NetworkError(detail: 'test');
  }
}
