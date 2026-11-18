import 'dart:typed_data';

import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/core/services/resume_file_picker.dart';
import 'package:careerly/data/models/resume_file.dart';
import 'package:careerly/design_system/components/careerly_navigation_bar.dart';
import 'package:careerly/design_system/components/careerly_uploading_overlay.dart';
import 'package:careerly/design_system/tokens/app_motion.dart';
import 'package:careerly/features/home/presentation/home_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_confirm_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_parsing_page.dart';
import 'package:careerly/features/onboarding/presentation/onboarding_resume_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Careerly Phase 4 批 2 —— Onboarding「提交简历 / 建立职业基线 / 确认」三屏。
///
/// 覆盖**可在单测里验证**的部分：路由可达性、Figma 文案被逐字钉住、
/// 「建立职业基线」语义（**不得**出现岗位/匹配度/Gap）、
/// 两条时钟（时间线 + 数据）都完成才推进、以及 Mock 空档案下确认页走 Empty 态。
///
/// 视觉部分（光晕球的呼吸与扩散、虚线框、磨砂卡）不在此验证 ——
/// 见 `docs/05_progress/CURRENT_STATUS.md` 的视觉定稿流程。

/// 「选择文件」的测试替身 —— 不触发平台通道，返回构造好的结果。
///
/// 通过 [CareerlyApp.overrides] 尾部覆盖生产装配里的
/// [DefaultResumeFilePicker]（同类型后注册者胜出）。
class _FakeResumeFilePicker implements ResumeFilePicker {
  _FakeResumeFilePicker(this._result);

  final ResumeFileData? _result;

  @override
  Future<ResumeFileData?> pick() async => _result;
}

/// 构造一个合法的待提交文件（字节内容无意义，Mock 不解析）。
ResumeFileData _fakeFile({int sizeBytes = 4}) => ResumeFileData(
  name: '张三-产品经理.pdf',
  extension: 'pdf',
  sizeBytes: sizeBytes,
  bytes: Uint8List.fromList(List<int>.filled(sizeBytes, 1)),
);

void main() {
  /// Mock 数据层的默认延迟是 600ms。
  Future<void> settleMock(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  /// 推进 [milliseconds] 毫秒 —— **逐帧**推进。
  ///
  /// ⚠️ **不能用 `pumpAndSettle`**：解析页的光晕球是 `repeat()` 的无限动画，
  /// `pumpAndSettle` 会一直等不到静止而超时。
  /// 也不能一次 `pump` 一个大跨度 —— 时间线由 **ticker** 驱动，
  /// 只有真的产生帧才会前进（定时器不等价）。
  Future<void> advance(WidgetTester tester, int milliseconds) async {
    const int frame = 50;
    for (int elapsed = 0; elapsed < milliseconds; elapsed += frame) {
      await tester.pump(const Duration(milliseconds: frame));
    }
  }

  /// Figma 时间线的总时长：5 步 + 4 次步间停顿 + 完成后的 700ms。
  /// 由 [AppMotion.baselineBeats] 推导，避免手抄一份平行数字。
  int timelineTotalMs() {
    int total = 0;
    for (final AppMotionBeat beat in AppMotion.baselineBeats) {
      total += beat.duration.inMilliseconds;
    }
    total += AppMotion.baselineStepPause.inMilliseconds * 4;
    total += AppMotion.baselineAdvance.inMilliseconds;
    return total;
  }

  Future<void> pumpAt(WidgetTester tester, String location) async {
    await tester.pumpWidget(CareerlyApp(initialLocation: location));
    await settleMock(tester);
  }

  // ---------------------------------------------------------------------------
  // 提交简历页
  // ---------------------------------------------------------------------------

  group('Phase 4 批 2 · 提交简历页', () {
    testWidgets('渲染 Figma 的标题、清单与两个动作按钮', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingResume);

      expect(find.byType(OnboardingResumePage), findsOneWidget);
      expect(find.text('上传你的简历'), findsOneWidget);
      expect(find.text('点击或拖拽上传简历'), findsOneWidget);
      // ⚠️ 卡内文案含「图片截图」是**有意偏离 Figma** 的
      // （选择器放行图片走 OCR，说一套做一套不行）→ D107 已裁决。
      expect(find.text('PDF / Word / 图片截图 · 最大 10MB'), findsOneWidget);
      expect(find.text('AI 将自动提取'), findsOneWidget);
      expect(find.text('选择文件'), findsOneWidget);
      expect(find.text('粘贴简历文本'), findsOneWidget);

      // Figma 的五条清单**逐字**（少一条就是漏实现）。
      for (final String item in <String>[
        '工作经历与职位信息',
        '项目经历与成果',
        '教育背景',
        '技能与证书',
        '获奖与荣誉',
      ]) {
        expect(find.text(item), findsOneWidget, reason: '缺少清单项：$item');
      }

      // Onboarding 在 Shell 之外：不得出现底部导航。
      //
      // ⚠️ 断言**导航栏组件**而不是它的某个文字标签：
      // Phase 5 之后首页不再有 AppBar 标题，`find.text('首页')` 会恒为空
      // —— 那样这条断言就变成永远成立的废断言了。
      expect(find.byType(CareerlyNavigationBar), findsNothing);
    });

    testWidgets('「选择文件」选中文件 → 提交 → 进入「建立职业基线」页（D67 已关闭）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        CareerlyApp(
          initialLocation: AppRoutes.onboardingResume,
          overrides: <SingleChildWidget>[
            Provider<ResumeFilePicker>.value(
              value: _FakeResumeFilePicker(_fakeFile()),
            ),
          ],
        ),
      );
      await settleMock(tester);

      await tester.tap(find.text('选择文件'));
      // 选择（瞬时）→ 提交（Mock 600ms）→ 转场（300ms）。
      await advance(tester, 2500);

      expect(find.byType(OnboardingParsingPage), findsOneWidget);

      // 收尾：走完整个时间线，别把挂起的定时器留给下一个测试。
      await advance(tester, timelineTotalMs() + 2000);
    });

    testWidgets('提交期间显示「正在上传简历」遮罩与循环图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        CareerlyApp(
          initialLocation: AppRoutes.onboardingResume,
          overrides: <SingleChildWidget>[
            Provider<ResumeFilePicker>.value(
              value: _FakeResumeFilePicker(_fakeFile()),
            ),
          ],
        ),
      );
      await settleMock(tester);

      await tester.tap(find.text('选择文件'));
      await tester.pump(); // 选择器返回
      await tester.pump(const Duration(milliseconds: 100)); // 提交已开始

      // 后端解析很慢（实测 173–199s），提交期间必须有可见反馈。
      expect(find.byType(CareerlyUploadingOverlay), findsOneWidget);
      expect(find.text('正在上传简历'), findsOneWidget);
      expect(find.byIcon(Icons.upload_rounded), findsOneWidget);
      // 循环图标：持续旋转（开启「减少动态效果」时才退化为静态）。
      expect(find.byType(RotationTransition), findsWidgets);
      // 仍在原页，尚未进入解析页。
      expect(find.byType(OnboardingResumePage), findsOneWidget);
      expect(find.byType(OnboardingParsingPage), findsNothing);

      // Mock 600ms 提交完成 → 转场到解析页，遮罩消失。
      await advance(tester, 2500);
      expect(find.byType(OnboardingParsingPage), findsOneWidget);
      expect(find.byType(CareerlyUploadingOverlay), findsNothing);

      // 收尾：走完整个时间线，别把挂起的定时器留给下一个测试。
      await advance(tester, timelineTotalMs() + 2000);
    });

    testWidgets('「选择文件」用户取消 → 停留原页、无任何提示', (WidgetTester tester) async {
      await tester.pumpWidget(
        CareerlyApp(
          initialLocation: AppRoutes.onboardingResume,
          overrides: <SingleChildWidget>[
            Provider<ResumeFilePicker>.value(
              value: _FakeResumeFilePicker(null),
            ),
          ],
        ),
      );
      await settleMock(tester);

      await tester.tap(find.text('选择文件'));
      await advance(tester, 1500);

      // 取消不是失败：不跳转、不出 Toast、不出错误。
      expect(find.byType(OnboardingResumePage), findsOneWidget);
      expect(find.byType(OnboardingParsingPage), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('「选择文件」超过 10MB → 提示更换，且不提交不跳转', (WidgetTester tester) async {
      await tester.pumpWidget(
        CareerlyApp(
          initialLocation: AppRoutes.onboardingResume,
          overrides: <SingleChildWidget>[
            Provider<ResumeFilePicker>.value(
              value: _FakeResumeFilePicker(
                _fakeFile(sizeBytes: ResumeFileData.maxSizeBytes + 1),
              ),
            ),
          ],
        ),
      );
      await settleMock(tester);

      await tester.tap(find.text('选择文件'));
      await tester.pump();
      await advance(tester, 400);

      expect(find.textContaining('超过 10MB'), findsOneWidget);
      expect(find.byType(OnboardingResumePage), findsOneWidget);
      expect(find.byType(OnboardingParsingPage), findsNothing);

      // 让 Toast 的停留计时走完，避免测试结束时仍有挂起定时器。
      await advance(tester, 3000);
    });

    testWidgets('「粘贴简历文本」打开弹层；空文本时提交不可用', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingResume);

      await tester.tap(find.text('粘贴简历文本'));
      await tester.pump();
      await advance(tester, 500);

      // 弹层自己的标题（与按钮同名，故此时应有 2 处）。
      expect(find.text('粘贴简历文本'), findsNWidgets(2));
      expect(find.text('提交'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // 空文本 → 提交不可用（Figma 未定义，属 D70 的补齐项）。
      expect(find.byType(OnboardingResumePage), findsOneWidget);
      await tester.tap(find.text('提交'));
      await tester.pump();
      await advance(tester, 500);
      expect(find.text('提交'), findsOneWidget, reason: '空文本时不应提交并关掉弹层');
    });

    testWidgets('粘贴文本 → 提交 → 进入「建立职业基线」页', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingResume);

      await tester.tap(find.text('粘贴简历文本'));
      await tester.pump();
      await advance(tester, 500);

      await tester.enterText(find.byType(TextField), '2019-2024 在某公司做产品经理');
      await tester.pump();
      await tester.tap(find.text('提交'));

      // 弹层关闭（350ms）→ 提交（Mock 600ms）→ 转场（300ms）
      await advance(tester, 2500);

      expect(find.byType(OnboardingParsingPage), findsOneWidget);

      // 收尾：走完整个时间线，别把挂起的定时器留给下一个测试。
      await advance(tester, timelineTotalMs() + 2000);
    });
  });

  // ---------------------------------------------------------------------------
  // 建立职业基线页
  // ---------------------------------------------------------------------------

  group('Phase 4 批 2 · 建立职业基线页', () {
    testWidgets('文案是「职业基线」语义，**不含**岗位 / 匹配度 / Gap（D63 钉死）', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingParsing);

      expect(find.text('正在解析'), findsOneWidget);
      expect(find.text('正在认识'), findsOneWidget);
      expect(find.text('退出解析'), findsOneWidget);

      // 第 1 步的 label 出现在状态药丸与步骤卡两处。
      expect(find.text('读取简历'), findsNWidgets(2));
      expect(find.text('整理工作经历'), findsOneWidget);

      for (final String forbidden in <String>[
        '岗位需求解析',
        '简历信息解析',
        '能力匹配分析',
        '识别能力 Gap',
        '生成分析报告',
        '匹配度',
        '排名',
        '岗位要求',
      ]) {
        expect(
          find.textContaining(forbidden),
          findsNothing,
          reason: 'D63 明令：本屏不得出现「$forbidden」',
        );
      }

      await advance(tester, timelineTotalMs() + 2000);
    });

    testWidgets('时间线跑完后进入确认页，并呈现完成态文案', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingParsing);

      // 中途不该已经完成。
      await advance(tester, 1000);
      expect(find.text('解析完成！'), findsNothing);

      // 时间线 + 数据都完成才推进（D73）。
      await advance(tester, timelineTotalMs() + 1500);
      expect(find.byType(OnboardingConfirmPage), findsOneWidget);

      await settleMock(tester);
    });
  });

  // ---------------------------------------------------------------------------
  // 确认页
  // ---------------------------------------------------------------------------

  group('Phase 4 批 2 · 确认页', () {
    testWidgets('渲染 Figma 的标题 / 说明 / 横幅 / 主按钮', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingConfirm);

      expect(find.byType(OnboardingConfirmPage), findsOneWidget);
      expect(find.text('你的职业档案已建立！'), findsOneWidget);
      expect(find.text('Careerly 已完成初步解析，你可以随时完善'), findsOneWidget);
      expect(find.text('你的职业基线已建立 · 这是你成长的起点'), findsOneWidget);
      expect(find.text('进入 Careerly'), findsOneWidget);

      // 终点页：没有返回键，也没有底部导航。
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.byType(CareerlyNavigationBar), findsNothing);
    });

    testWidgets('Mock 空档案 → 汇总卡走 Empty 态，且**不编造** 4 / 6 / 12 / 5', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.onboardingConfirm);

      expect(find.text('档案暂无内容'), findsOneWidget);

      // 汇总行的标题在 Empty 态下**不应**出现（它只在有数据时渲染）。
      expect(find.text('工作经历'), findsNothing);

      // Figma 硬编码的四个数字不得出现在界面上（CLAUDE.md §7 / D64 ⑥）。
      for (final String faked in <String>['4', '6', '12', '5']) {
        expect(
          find.text(faked),
          findsNothing,
          reason: 'Figma 的假数据「$faked」不得进入 Mock',
        );
      }
    });

    testWidgets('「进入 Careerly」回到首页，并出现底部导航', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.onboardingConfirm);

      await tester.tap(find.text('进入 Careerly'));
      await advance(tester, 1000);

      // 回到首页 = 落在首页**页面**（而不是「某处出现了『首页』二字」——
      // Phase 5 之后首页没有 AppBar 标题，见上一条测试的说明）。
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(CareerlyNavigationBar), findsOneWidget);
    });
  });
}
