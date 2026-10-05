import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/mock/mock.dart';
import 'package:careerly/data/repositories/repositories.dart';
import 'package:careerly/design_system/components/careerly_button.dart';
import 'package:careerly/design_system/components/careerly_navigation_bar.dart';
import 'package:careerly/design_system/components/careerly_social_button.dart';
import 'package:careerly/design_system/components/careerly_toast.dart';
import 'package:careerly/features/home/presentation/home_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_login_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_register_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_splash_page.dart';
import 'package:careerly/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:careerly/features/onboarding/state/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Careerly Phase 4 —— Onboarding 开屏 + 注册 + 登录 的验收测试。
///
/// 覆盖的是**可在单测里验证**的部分：路由可达性、字段集、表单可用态、
/// 提交链路（Loading → Success / Failure）、第三方登录失败时的可见行为。
///
/// 视觉部分（渐变、玻璃返回钮、面板圆角、社交按钮图标）不在此验证 ——
/// 见 `docs/05_progress/CURRENT_STATUS.md` 的视觉定稿流程。
///
/// ## ⚠️ 2026-10-04 改版：删除的两组测试
///
/// 本文件曾有一组 `账号页：登录形态（D85）` 与一组 `账号页：形态切换（D85）`。
/// 重新导出的 Figma 里 `OnLogin` 是一块**独立的屏**，D85 连同
/// `?mode=login` / `OnboardingAccountMode` 机制一并作废 ——
/// 那两组测试测的就是这套机制，故**整体删除**，由 `Phase 4 · 登录页`
/// 组取代。**不是**把它们改成通过，而是被测对象已经不存在了。
void main() {
  /// Mock 数据层的默认延迟是 600ms，测试里需要推进假时钟把它走完。
  ///
  /// ⚠️ 必须推进**两段**时钟，不能只推一段。
  ///
  /// 提交是**异步**的：600ms 延迟走完才触发跳转，而跳转的**页面转场
  /// 在那之后才开始**。只推一段时，转场恰好停在第一帧 ——
  /// 旧页仍在树上，断言 `findsNothing` 会误报失败。
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

  /// 点击一个可能位于滚动区之下的元素。
  ///
  /// ⚠️ 登录页的整块内容（含主按钮）都在**可滚动的面板里**，
  /// 而测试画布只有 800×600 —— 直接 `tap` 会命中不到或命中错的位置。
  /// 先 `ensureVisible` 把它滚进视野，这与真机上用户滚动是一回事。
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  /// 取出社交按钮当前是否可点（`onPressed == null` 即不可用）。
  bool isSocialEnabled(WidgetTester tester, String label) {
    final CareerlySocialButton button = tester.widget<CareerlySocialButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(CareerlySocialButton),
      ),
    );
    return button.onPressed != null;
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

    testWidgets('展示品牌名、一个渐变主按钮与一个文字链入口', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingSplash);

      expect(find.text('Careerly'), findsOneWidget);
      expect(find.text('看见能力 · 跨越 Gap'), findsOneWidget);
      expect(find.text('记录成长'), findsOneWidget);
      expect(find.text('你的职业成长，从看见自己开始。'), findsOneWidget);

      // ⚠️ 2026-10-04 改版：底部从「两个等权按钮」变成
      // 「一个渐变主按钮 + 一行文字」。注册是主线，登录是退路。
      expect(find.widgetWithText(CareerlyButton, '点击注册'), findsOneWidget);
      expect(
        find.widgetWithText(CareerlyButton, '点击登录'),
        findsNothing,
        reason: '新稿的登录入口是文字链，不再是第二个按钮',
      );
      expect(find.textContaining('已经有账户了'), findsOneWidget);
      expect(find.text('点击登录'), findsOneWidget);
    });

    testWidgets('「点击注册」进入注册页', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingSplash);

      await tester.tap(find.text('点击注册'));
      await settleMock(tester);

      expect(find.byType(OnboardingRegisterPage), findsOneWidget);
      expect(find.text('创建你的个人账号 📋'), findsOneWidget);
    });

    testWidgets('「点击登录」进入**独立登录页** /onboarding/login', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingSplash);

      await tester.tap(find.text('点击登录'));
      await settleMock(tester);

      // ⚠️ 本条在 2026-10-04 之前钉的是**相反**的结论：
      // 「登录仍是同一个账号页，没有独立登录页」（D85 的 `?mode=login`）。
      // 重新导出的 Figma 里 `OnLogin`（`App.tsx` L455-623）是一块独立屏，
      // 故断言翻转为「确实是一个新的页面类」。
      expect(
        find.byType(OnboardingLoginPage),
        findsOneWidget,
        reason: '登录已是独立页面，不再是注册页的第二种形态',
      );
      expect(find.byType(OnboardingRegisterPage), findsNothing);
      expect(find.text('欢迎回来！'), findsOneWidget);
    });
  });

  group('Phase 4 · 注册页', () {
    testWidgets('渲染进度头、标题与名字 / 手机号 / 密码三个字段', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      expect(find.byType(OnboardingProgressHeader), findsOneWidget);
      expect(find.text('创建你的个人账号 📋'), findsOneWidget);
      expect(find.text('名字'), findsOneWidget);
      expect(find.text('手机号'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('旧稿的字段与按钮已全部移除', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      // 新稿没有邮箱字段（后端仍接受选填 email，属**契约保留**，见 AuthRepository）。
      expect(find.text('姓名'), findsNothing);
      expect(find.text('邮箱（选填）'), findsNothing);
      // 新稿没有「跳过，稍后完善」；主按钮也从「继续」改成「创建账号」。
      expect(find.text('跳过，稍后完善'), findsNothing);
      expect(find.text('继续'), findsNothing);
      expect(find.widgetWithText(CareerlyButton, '创建账号'), findsOneWidget);
      // 注册页专有的分隔线文案（登录页是 `sign in with`，不同）。
      expect(find.text('Or sign up with'), findsOneWidget);
    });

    testWidgets('三个字段全空时「创建账号」不可用', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      expect(
        isEnabled(tester, '创建账号'),
        isFalse,
        reason: '三个必填项均为空时，主按钮必须是 Disabled 态（四态要求）',
      );
    });

    testWidgets('逐个填齐三字段后才解锁（密码需 >= 6 位）', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      final Finder fields = find.byType(TextField);

      await tester.enterText(fields.at(0), '张三');
      await tester.pump();
      expect(
        isEnabled(tester, '创建账号'),
        isFalse,
        reason: '手机号与密码仍是空的',
      );

      await tester.enterText(fields.at(1), '13800000000');
      await tester.pump();
      expect(
        isEnabled(tester, '创建账号'),
        isFalse,
        reason: '密码是必填项，只填名字与手机号不足以解锁',
      );

      // ⚠️ 先填一个**不合法**的短密码，确认它不解锁 —— 这条边界
      // 与后端 `passwords.MIN_PASSWORD_LENGTH` 同值（客户端只是提前拦）。
      await tester.enterText(fields.at(2), '12345');
      await tester.pump();
      expect(
        isEnabled(tester, '创建账号'),
        isFalse,
        reason: '5 位密码不足 6 位，应在按下按钮之前就被拦下',
      );

      await tester.enterText(fields.at(2), '123456');
      await tester.pump();
      expect(isEnabled(tester, '创建账号'), isTrue);
    });

    testWidgets('提交成功后离开注册页，继续 Onboarding', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingRegister);

      final Finder fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '张三');
      await tester.enterText(fields.at(1), '13800000000');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.pump();

      await tapVisible(tester, find.text('创建账号'));
      await settleMock(tester);

      expect(find.byType(OnboardingRegisterPage), findsNothing);
    });

    testWidgets('提交失败时停留原页并给出错误提示（网络类失败可重试）', (
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
      await tester.enterText(fields.at(2), 'secret123');
      await tester.pump();

      await tapVisible(tester, find.text('创建账号'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 失败必须停在原页，而不是假装成功跳走。
      expect(find.byType(OnboardingRegisterPage), findsOneWidget);
      // 错误文案来自 AppError.message，经 CareerlyToast 呈现。
      expect(find.textContaining('网络'), findsWidgets);

      // 且按钮回到可用态，用户能重试。
      expect(isEnabled(tester, '创建账号'), isTrue);
    });
  });

  group('Phase 4 · 登录页（独立页面，2026-10-04）', () {
    testWidgets('落在 /onboarding/login 时渲染登录页，且没有底部导航', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingLogin);

      expect(find.byType(OnboardingLoginPage), findsOneWidget);
      expect(find.text('欢迎回来！'), findsOneWidget);
      expect(find.text('继续成长从看见自己开始'), findsOneWidget);

      // 登录页**没有**进度头（进度属于注册侧的建立基线流程）。
      expect(find.byType(OnboardingProgressHeader), findsNothing);

      expect(
        find.text('首页'),
        findsNothing,
        reason: '登录页不属于任何一级导航，不应渲染 Shell 的导航栏',
      );
    });

    testWidgets('只有手机号与密码两个字段，且带记住我 / 忘记密码?', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingLogin);

      expect(find.byType(TextField), findsNWidgets(2));
      // ⚠️ 手机号的标签在 Figma 里写的是「注册手机号」—— 原样照抄，
      // 不顺手改成「手机号」（那是改产品文案）。
      expect(find.text('注册手机号'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);

      expect(find.text('记住我'), findsOneWidget);
      expect(find.text('忘记密码?'), findsOneWidget);

      // 注册页专有的东西不该出现。
      expect(find.text('名字'), findsNothing);
      expect(find.text('创建你的个人账号 📋'), findsNothing);
      expect(find.text('Or sign up with'), findsNothing);
      // 分隔线文案两页不同：登录页是全小写且**没有** `Or`。
      expect(find.text('sign in with'), findsOneWidget);
    });

    testWidgets('手机号与密码为空时「点击登录」不可用', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingLogin);

      expect(
        isEnabled(tester, '点击登录'),
        isFalse,
        reason: '两个必填项均为空时，主按钮必须是 Disabled 态（四态要求）',
      );

      // 只填手机号仍不解锁 —— 密码同样是必填。
      await tester.enterText(find.byType(TextField).at(0), '13800000000');
      await tester.pump();
      expect(isEnabled(tester, '点击登录'), isFalse);

      // 密码不足 6 位仍不解锁。
      await tester.enterText(find.byType(TextField).at(1), '12345');
      await tester.pump();
      expect(isEnabled(tester, '点击登录'), isFalse);

      await tester.enterText(find.byType(TextField).at(1), '123456');
      await tester.pump();
      expect(isEnabled(tester, '点击登录'), isTrue);
    });

    testWidgets('提交成功后**直接进入首页** —— 老用户已有职业基线', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingLogin);

      await tester.enterText(find.byType(TextField).at(0), '13800000000');
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.pump();

      await tapVisible(tester, find.text('点击登录'));
      await settleMock(tester);

      expect(find.byType(OnboardingLoginPage), findsNothing);
      expect(
        find.byType(HomePage),
        findsOneWidget,
        reason: '登录成功后直接进首页，不走注册侧的 Onboarding 剩余步骤',
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

      await pumpAt(tester, AppRoutes.onboardingLogin);

      await tester.enterText(find.byType(TextField).at(0), '13800000000');
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.pump();

      await tapVisible(tester, find.text('点击登录'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(OnboardingLoginPage), findsOneWidget);
      expect(find.textContaining('网络'), findsWidgets);
      expect(isEnabled(tester, '点击登录'), isTrue);
    });

    testWidgets('「点击注册」跳到注册页（两条路互达）', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingLogin);

      await tapVisible(tester, find.text('点击注册'));
      await settleMock(tester);

      expect(find.byType(OnboardingRegisterPage), findsOneWidget);
    });

    testWidgets('返回键回到开屏页', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingLogin);

      await tester.tap(find.bySemanticsLabel('返回'));
      await settleMock(tester);

      expect(find.byType(OnboardingSplashPage), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 第三方登录（2026-10-04：只建可配置契约，不做真实对接）
  //
  // 这组测试钉的是**契约的可见行为**：能力没上线这件事必须能被用户看见，
  // 而不是一个「点了没反应」的死按钮 —— 也不是一个假装成功的假按钮。
  // ---------------------------------------------------------------------------

  group('Phase 4 · 第三方登录（微信 / QQ）', () {
    testWidgets('登录页与注册页都渲染微信 / QQ 两个按钮', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingLogin);
      expect(find.widgetWithText(CareerlySocialButton, '微信'), findsOneWidget);
      expect(find.widgetWithText(CareerlySocialButton, 'QQ'), findsOneWidget);

      await pumpAt(tester, AppRoutes.onboardingRegister);
      expect(find.widgetWithText(CareerlySocialButton, '微信'), findsOneWidget);
      expect(find.widgetWithText(CareerlySocialButton, 'QQ'), findsOneWidget);
    });

    testWidgets('Mock 模式下点微信**如实失败**，不假装登录成功', (
      WidgetTester tester,
    ) async {
      MockSettings.config = const MockConfig(
        latency: Duration(milliseconds: 10),
      );
      addTearDown(() => MockSettings.config = MockConfig.standard);

      await pumpAt(tester, AppRoutes.onboardingLogin);

      await tapVisible(tester, find.text('微信'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // ⚠️ 这是本组最重要的一条：Mock 的 `signInWithOAuth` 刻意抛错，
      // 就是为了避免「只有 Mock 才存在的能力」被误当成已上线。
      expect(
        find.byType(OnboardingLoginPage),
        findsOneWidget,
        reason: '失败必须停在原页 —— 不得跳转、更不得假装已登录',
      );
      expect(find.byType(HomePage), findsNothing);
      // 失败原因必须**可见**（PRD §15）。
      expect(find.byType(CareerlyToast), findsOneWidget);

      // 且按钮回到可用态（请求不在途了）。
      expect(isSocialEnabled(tester, '微信'), isTrue);
      expect(isSocialEnabled(tester, 'QQ'), isTrue);
    });

    testWidgets('QQ 按钮走的是同一条链路', (WidgetTester tester) async {
      MockSettings.config = const MockConfig(
        latency: Duration(milliseconds: 10),
      );
      addTearDown(() => MockSettings.config = MockConfig.standard);

      await pumpAt(tester, AppRoutes.onboardingRegister);

      final Finder fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '张三');
      await tester.enterText(fields.at(1), '13800000000');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.pump();

      await tapVisible(tester, find.text('QQ'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(OnboardingRegisterPage), findsOneWidget);
      expect(find.byType(CareerlyToast), findsOneWidget);
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

      final bool ok = await provider.submit(
        name: ' 张三 ',
        phone: ' 138 ',
        password: ' secret123 ',
      );

      expect(ok, isTrue);
      expect(provider.status, OnboardingSubmitStatus.success);
      expect(provider.error, isNull);
    });

    test('注册会 trim 名字与手机号，但**不 trim 密码**', () async {
      final _RecordingAuthRepository repository = _RecordingAuthRepository();
      final OnboardingProvider provider = OnboardingProvider(repository);
      addTearDown(provider.dispose);

      await provider.submit(
        name: ' 张三 ',
        phone: ' 138 ',
        password: ' secret123 ',
      );

      expect(repository.lastName, '张三');
      expect(repository.lastPhone, '138');
      // ⚠️ 首尾空格是密码的一部分 —— trim 掉会让用户的密码与
      // 他自己以为的不一致，登录时就会莫名其妙地失败。
      expect(repository.lastPassword, ' secret123 ');
    });

    test('login 走 AuthRepository.login，trim 手机号但不 trim 密码', () async {
      final _RecordingAuthRepository repository = _RecordingAuthRepository();
      final OnboardingProvider provider = OnboardingProvider(repository);
      addTearDown(provider.dispose);

      final bool ok = await provider.login(
        phone: ' 138 ',
        password: ' secret123 ',
      );

      expect(ok, isTrue);
      expect(repository.lastLoginPhone, '138');
      expect(repository.lastLoginPassword, ' secret123 ');
      expect(provider.status, OnboardingSubmitStatus.success);
      expect(provider.error, isNull);
    });

    test('注册失败时状态为 failure 且不抛异常', () async {
      final OnboardingProvider provider = OnboardingProvider(
        _FailingAuthRepository(),
      );
      addTearDown(provider.dispose);

      final bool ok = await provider.submit(
        name: '张三',
        phone: '138',
        password: 'secret123',
      );

      expect(ok, isFalse);
      expect(provider.status, OnboardingSubmitStatus.failure);
      expect(provider.error, isNotNull);
    });

    test('登录失败时状态为 failure 且不抛异常', () async {
      final OnboardingProvider provider = OnboardingProvider(
        _FailingAuthRepository(),
      );
      addTearDown(provider.dispose);

      final bool ok = await provider.login(phone: '138', password: 'secret123');

      expect(ok, isFalse);
      expect(provider.status, OnboardingSubmitStatus.failure);
      expect(provider.error, isNotNull);
    });

    test('第三方登录与注册 / 登录走**同一条状态机**', () async {
      final _RecordingAuthRepository repository = _RecordingAuthRepository();
      final OnboardingProvider provider = OnboardingProvider(repository);
      addTearDown(provider.dispose);

      final bool ok = await provider.signInWithOAuth(provider: 'wechat');

      expect(ok, isTrue);
      expect(repository.lastOAuthProvider, 'wechat');
      expect(provider.status, OnboardingSubmitStatus.success);
    });

    test('reset 清掉失败态，回到 idle', () async {
      final OnboardingProvider provider = OnboardingProvider(
        _FailingAuthRepository(),
      );
      addTearDown(provider.dispose);

      await provider.submit(name: '张三', phone: '138', password: 'secret123');
      expect(provider.error, isNotNull);

      provider.reset();

      expect(provider.status, OnboardingSubmitStatus.idle);
      expect(provider.error, isNull);
    });
  });
}

/// 记录最后一次调用参数的假 Repository。
///
/// ⚠️ 密码**只是被记下来用于断言 trim 行为**，不参与任何计算、
/// 也不产生任何持久化副作用 —— 真实哈希由后端做。
class _RecordingAuthRepository implements AuthRepository {
  String? lastName;
  String? lastPhone;
  String? lastPassword;
  String? lastLoginPhone;
  String? lastLoginPassword;
  String? lastOAuthProvider;
  bool lastLogoutCalled = false;

  @override
  Future<void> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    lastName = name;
    lastPhone = phone;
    lastPassword = password;
  }

  @override
  Future<void> login({
    required String phone,
    required String password,
  }) async {
    lastLoginPhone = phone;
    lastLoginPassword = password;
  }

  @override
  Future<void> signInWithOAuth({required String provider}) async {
    lastOAuthProvider = provider;
  }

  @override
  Future<void> logout() async {
    lastLogoutCalled = true;
  }
}

/// 恒定失败的假 Repository（三条链路都失败）。
class _FailingAuthRepository implements AuthRepository {
  @override
  Future<void> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    throw const NetworkError(detail: 'test');
  }

  @override
  Future<void> login({
    required String phone,
    required String password,
  }) async {
    throw const NetworkError(detail: 'test');
  }

  @override
  Future<void> signInWithOAuth({required String provider}) async {
    throw const NetworkError(detail: 'test');
  }

  @override
  Future<void> logout() async {
    throw const NetworkError(detail: 'test');
  }
}
