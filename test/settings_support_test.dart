import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/core/services/app_info_platform.dart';
import 'package:careerly/core/services/support_mail.dart';
import 'package:careerly/data/local/settings_store.dart';
import 'package:careerly/data/models/assistant_settings.dart';
import 'package:careerly/design_system/components/components.dart';
import 'package:careerly/design_system/theme/careerly_theme.dart';
import 'package:careerly/features/profile/state/settings_provider.dart';
import 'package:careerly/features/support/presentation/about_careerly_page.dart';
import 'package:careerly/features/support/presentation/feedback_page.dart';
import 'package:careerly/features/support/presentation/help_center_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// 设置页的「帮助与反馈」与偏好持久化。
///
/// ## 钉住什么
///
/// ```text
/// ✅ 开关 / 单选：改动会写入 SettingsStore，重建 Provider 后仍在
/// ✅ 帮助中心：分类齐全、默认收起、单项展开
/// ✅ 联系邮箱：走 mailto，收件人是公开支持邮箱（不是假提交）
/// ✅ 意见反馈：类型 + 正文 + 选填邮箱进入邮件 body；正文为空时按钮禁用
/// ✅ 关于 Careerly：版本号来自注入的真实读取器，不写死
/// ✅ 设置页三个入口都能进入对应二级页
/// ```
///
/// ⚠️ 不断言具体字号 / 间距 —— 这些没有 Figma 规格，属视觉验收范围。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void useTallViewport(WidgetTester tester, {double height = 2600}) {
    tester.view.physicalSize = Size(800, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
  }

  Widget directPage(Widget child) {
    return MaterialApp(theme: CareerlyTheme.light(), home: child);
  }

  Future<SettingsProvider> pumpSettings(
    WidgetTester tester, {
    InMemorySettingsStore? store,
  }) async {
    useTallViewport(tester);
    final SettingsProvider provider = SettingsProvider(
      store ?? InMemorySettingsStore(),
    );
    await provider.ready;

    await tester.pumpWidget(
      CareerlyApp(
        initialLocation: AppRoutes.settings,
        overrides: <SingleChildWidget>[
          ChangeNotifierProvider<SettingsProvider>.value(value: provider),
        ],
      ),
    );
    await settle(tester);
    return provider;
  }

  group('偏好模型与本地存储', () {
    test('AssistantSettings JSON 往返保留四个字段', () {
      const AssistantSettings source = AssistantSettings(
        proactiveAdvice: false,
        dailyBriefing: true,
        matchAlert: false,
        answerStyle: AiAnswerStyle.detailed,
      );

      final AssistantSettings restored = AssistantSettings.fromJson(
        source.toJson(),
      );

      expect(restored, source);
    });

    test('单个字段损坏只回退该项，其余保留', () {
      final AssistantSettings restored = AssistantSettings.fromJson(
        <String, Object?>{
          'proactiveAdvice': 'not-a-bool',
          'dailyBriefing': true,
          'matchAlert': false,
          'answerStyle': 'unknown-style',
        },
      );

      expect(restored.proactiveAdvice, isTrue, reason: '回退默认值');
      expect(restored.dailyBriefing, isTrue);
      expect(restored.matchAlert, isFalse);
      expect(restored.answerStyle, AiAnswerStyle.actionOriented);
    });

    test('Provider 写入后，新实例能从同一 Store 恢复', () async {
      final InMemorySettingsStore store = InMemorySettingsStore();
      final SettingsProvider first = SettingsProvider(store);
      await first.ready;

      await first.setProactiveAdvice(false);
      await first.setDailyBriefing(true);
      await first.setAnswerStyle(AiAnswerStyle.concise);

      final SettingsProvider second = SettingsProvider(store);
      await second.ready;

      expect(second.proactiveAdvice, isFalse);
      expect(second.dailyBriefing, isTrue);
      expect(second.answerStyle, AiAnswerStyle.concise);
    });
  });

  group('设置页的开关与单选', () {
    testWidgets('切换「AI 主动建议」会真实写入 Store', (WidgetTester tester) async {
      final InMemorySettingsStore store = InMemorySettingsStore();
      final SettingsProvider provider = await pumpSettings(
        tester,
        store: store,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('settings-proactive-advice')),
      );
      await settle(tester);

      expect(provider.proactiveAdvice, isFalse);
      expect(store.value?.proactiveAdvice, isFalse);
    });

    testWidgets('选择「详细」回答风格会真实写入 Store', (WidgetTester tester) async {
      final InMemorySettingsStore store = InMemorySettingsStore();
      final SettingsProvider provider = await pumpSettings(
        tester,
        store: store,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('settings-answer-style-detailed')),
      );
      await settle(tester);

      expect(provider.answerStyle, AiAnswerStyle.detailed);
      expect(store.value?.answerStyle, AiAnswerStyle.detailed);
    });
  });

  group('帮助中心', () {
    testWidgets('五个分类齐全，FAQ 默认收起', (WidgetTester tester) async {
      useTallViewport(tester, height: 4000);
      await tester.pumpWidget(directPage(const HelpCenterPage()));
      await settle(tester);

      expect(find.text('快速入门'), findsOneWidget);
      expect(find.text('岗位分析'), findsOneWidget);
      expect(find.text('AI 职业助手'), findsOneWidget);
      expect(find.text('职业成长'), findsOneWidget);
      expect(find.text('账号与服务'), findsOneWidget);

      expect(find.textContaining('建立你的职业基线'), findsNothing);
      expect(find.text('还没有解决你的问题？'), findsOneWidget);
    });

    testWidgets('点击问题展开答案；展开另一项时上一项收起', (WidgetTester tester) async {
      useTallViewport(tester, height: 4000);
      await tester.pumpWidget(directPage(const HelpCenterPage()));
      await settle(tester);

      await tester.tap(find.text('如何开始使用 Careerly？'));
      await settle(tester);
      expect(find.textContaining('建立你的职业基线'), findsOneWidget);

      await tester.tap(find.text('如何上传和管理简历？'));
      await settle(tester);
      expect(find.textContaining('建立你的职业基线'), findsNothing);
      expect(find.textContaining('保留简历版本'), findsOneWidget);
    });

    testWidgets('「联系我们」打开 mailto，收件人是公开支持邮箱', (
      WidgetTester tester,
    ) async {
      useTallViewport(tester, height: 4000);
      Uri? launched;

      await tester.pumpWidget(
        directPage(
          HelpCenterPage(
            mailLauncher: (Uri uri) async {
              launched = uri;
              return true;
            },
          ),
        ),
      );
      await settle(tester);

      await tester.tap(find.text('联系我们'));
      await settle(tester);

      expect(launched, isNotNull);
      expect(launched!.scheme, 'mailto');
      expect(launched!.path, SupportMail.address);
    });
  });

  group('意见反馈', () {
    testWidgets('正文为空时发送按钮禁用', (WidgetTester tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(directPage(const FeedbackPage()));
      await settle(tester);

      final CareerlyButton button = tester.widget<CareerlyButton>(
        find.widgetWithText(CareerlyButton, '通过邮件发送'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('类型 + 正文 + 选填邮箱进入 mailto body', (WidgetTester tester) async {
      useTallViewport(tester);
      Uri? launched;

      await tester.pumpWidget(
        directPage(
          FeedbackPage(
            mailLauncher: (Uri uri) async {
              launched = uri;
              return true;
            },
          ),
        ),
      );
      await settle(tester);

      await tester.tap(
        find.byKey(const ValueKey<String>('feedback-type-issue')),
      );
      await settle(tester);

      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey<String>('feedback-description')),
          matching: find.byType(TextField),
        ),
        '分析结果里有一项能力没有识别出来。',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey<String>('feedback-email')),
          matching: find.byType(TextField),
        ),
        'me@example.com',
      );
      await settle(tester);

      await tester.tap(find.widgetWithText(CareerlyButton, '通过邮件发送'));
      await settle(tester);

      expect(launched, isNotNull);
      final String decoded = Uri.decodeFull(launched.toString());
      expect(decoded, contains('使用问题'));
      expect(decoded, contains('分析结果里有一项能力没有识别出来。'));
      expect(decoded, contains('me@example.com'));
    });
  });

  group('关于 Careerly', () {
    test('AppInfoPlatform 从宿主通道解析 versionName / versionCode', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AppInfoPlatform.channel, (
            MethodCall call,
          ) async {
            expect(call.method, 'getVersion');
            return <String, Object?>{
              'versionName': '9.9.9',
              'versionCode': '42',
            };
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(AppInfoPlatform.channel, null),
      );

      final AppVersion? version = await AppInfoPlatform.readVersion();

      expect(version, isNotNull);
      expect(version!.name, '9.9.9');
      expect(version.buildNumber, '42');
      expect(version.label, '9.9.9（42）');
    });

    testWidgets('版本号来自真实读取器（不是写死）', (WidgetTester tester) async {
      useTallViewport(tester, height: 3000);
      await tester.pumpWidget(
        directPage(
          AboutCareerlyPage(
            versionLoader: () async =>
                const AppVersion(name: '1.2.3', buildNumber: '4'),
          ),
        ),
      );
      await settle(tester);

      expect(find.text('版本 1.2.3（4）'), findsOneWidget);
      expect(find.text('AI 职业成长伙伴'), findsOneWidget);
      expect(find.text('看见能力'), findsOneWidget);
      expect(find.text('跨越 Gap'), findsOneWidget);
      expect(find.text('记录成长'), findsOneWidget);
      expect(find.text('© 2026 Careerly'), findsOneWidget);
    });

    testWidgets('读取失败时如实显示不可用，不编造版本号', (WidgetTester tester) async {
      useTallViewport(tester, height: 3000);
      await tester.pumpWidget(
        directPage(AboutCareerlyPage(versionLoader: () async => null)),
      );
      await settle(tester);

      expect(find.text('版本信息暂不可用'), findsOneWidget);
    });
  });

  group('设置页入口可达', () {
    Future<void> openEntry(WidgetTester tester, String label) async {
      await pumpSettings(tester);
      final Finder entry = find.text(label);
      await tester.scrollUntilVisible(
        entry,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(entry);
      await settle(tester);
    }

    testWidgets('帮助中心', (WidgetTester tester) async {
      await openEntry(tester, '帮助中心');
      expect(find.byType(HelpCenterPage), findsOneWidget);
    });

    testWidgets('意见反馈', (WidgetTester tester) async {
      await openEntry(tester, '意见反馈');
      expect(find.byType(FeedbackPage), findsOneWidget);
    });

    testWidgets('关于 Careerly', (WidgetTester tester) async {
      await openEntry(tester, '关于 Careerly');
      expect(find.byType(AboutCareerlyPage), findsOneWidget);
    });
  });
}
