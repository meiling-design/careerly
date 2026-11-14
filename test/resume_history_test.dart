import 'package:careerly/data/models/career_assets.dart';
import 'package:careerly/data/models/resume_file.dart';
import 'package:careerly/data/models/resume_profile.dart';
import 'package:careerly/data/repositories/career_assets_repository.dart';
import 'package:careerly/data/repositories/resume_repository.dart';
import 'package:careerly/core/services/resume_file_picker.dart';
import 'package:careerly/design_system/components/careerly_button.dart';
import 'package:careerly/design_system/theme/careerly_theme.dart';
import 'package:careerly/features/profile/presentation/resume_detail_page.dart';
import 'package:careerly/features/profile/presentation/resume_history_page.dart';
import 'package:careerly/features/profile/state/career_assets_provider.dart';
import 'package:careerly/features/profile/state/resume_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// 我的简历 —— 简历历史 / 简历详情 / 导入弹层。
///
/// 真值来源：Figma `ResumeHistoryPage`（`src/App.tsx` L4795-4896）、
/// `SwipeableResumeCard`（L4438-4545）、`ResumeDetailPage`（L4599-4793）、
/// 导入弹层（L4910-4994）。
///
/// ## 这份测试钉住什么
///
/// 1. **不得编造产品数据**（`CLAUDE.md` §7）——
///    Figma 的「最高匹配 86%」在数据层**没有来源**，因此页面上
///    **一个数字都不许出现**。这条是硬约束：它是本轮刻意不做的部分，
///    必须有测试守着，否则以后很容易被「顺手补上」。
/// 2. **四态中的 Empty**（§5.5）—— Mock 默认空画像时两页都走 Empty。
/// 3. **入口可用**：`查看详情` → 详情页；FAB → 导入弹层；导入弹层可选可取消。
/// 4. **归档版本列表按数据出现**：没有归档版本时整段不渲染
///    （Figma 的 `archivedList.length > 0 &&`）。
void main() {
  // ---------------------------------------------------------------------------
  // fixture
  // ---------------------------------------------------------------------------

  /// 一份有内容的画像：1 个当前版本 + 1 个归档版本。
  final ResumeProfile seededProfile = ResumeProfile(
    versions: <ResumeVersion>[
      ResumeVersion(
        id: 'v2',
        label: '2026 春招版',
        uploadedAt: DateTime(2026, 8, 27),
        isCurrent: true,
      ),
      ResumeVersion(
        id: 'v1',
        label: '2026 初版',
        uploadedAt: DateTime(2026, 1, 3),
      ),
    ],
    workExperiences: const <String>['一段经历'],
    projectExperiences: const <String>['一个项目'],
    skills: const <String>['一项技能'],
    fullName: '张明远',
    email: 'zhangy@example.com',
    phone: '+86 138 0000 0000',
    updatedAt: DateTime(2026, 8, 27),
  );

  // ---------------------------------------------------------------------------
  // 宿主
  // ---------------------------------------------------------------------------

  /// `/profile/resume-history` + `/profile/resume-history/:versionId` 两条真实路由
  /// 的最小宿主 —— 只装配本页真正用到的 Provider。
  ///
  /// 路由表**照抄** `app_router.dart` 的 `AppRoutes.profileResumeHistory` /
  /// `profileResumeDetail` 形态（父 + `:versionId` 子路由），
  /// 这样「查看详情」走的是真实的 `context.push` + 路径参数解析，
  /// 而不是一个假的 push 回调。
  Widget host({
    ResumeProfile? profile,
    CareerAssets? assets,
  }) {
    final GoRouter router = GoRouter(
      initialLocation: '/profile/resume-history',
      routes: <RouteBase>[
        GoRoute(
          path: '/profile/resume-history',
          builder: (_, _) => const ResumeHistoryPage(),
          routes: <RouteBase>[
            GoRoute(
              path: ':versionId',
              builder: (_, GoRouterState state) => ResumeDetailPage(
                versionId: state.pathParameters['versionId'] ?? '',
              ),
            ),
          ],
        ),
      ],
    );

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<ResumeRepository>.value(
          value: _StubResumeRepository(profile ?? ResumeProfile.empty),
        ),
        Provider<CareerAssetsRepository>.value(
          value: _StubCareerAssetsRepository(assets ?? CareerAssets.empty),
        ),
        Provider<ResumeFilePicker>.value(value: const _StubFilePicker()),
        ChangeNotifierProvider<ResumeProvider>(
          create: (BuildContext context) =>
              ResumeProvider(context.read<ResumeRepository>()),
        ),
        ChangeNotifierProvider<CareerAssetsProvider>(
          create: (BuildContext context) =>
              CareerAssetsProvider(context.read<CareerAssetsRepository>()),
        ),
      ],
      child: MaterialApp.router(
        theme: CareerlyTheme.light(),
        routerConfig: router,
      ),
    );
  }

  /// 首帧 → postFrameCallback 的 `load()` → 完成 → 重建。
  Future<void> pumpHost(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pump(); // 首帧 → postFrameCallback → load()
    await tester.pump(const Duration(milliseconds: 1)); // Future 完成
    await tester.pump(); // 重建
  }

  // ---------------------------------------------------------------------------
  // 一、简历历史 —— 横幅与「不得编造数据」
  // ---------------------------------------------------------------------------

  group('简历历史 · 横幅', () {
    testWidgets('展示当前版本名、更新日期、文档块与三格统计', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));

      expect(find.text('我的简历'), findsOneWidget);
      expect(find.text('2026 春招版'), findsOneWidget);
      expect(find.text('更新于 2026.08.27'), findsOneWidget);
      expect(find.text('当前简历'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsWidgets);

      // 三格统计的**标签**恒在（数值来自 CareerAssets 计数）。
      expect(find.text('段经历'), findsOneWidget);
      expect(find.text('个项目'), findsOneWidget);
      expect(find.text('项技能'), findsOneWidget);
    });

    testWidgets('⚠️ 不渲染「最高匹配」与任何匹配度数字（§7 不得编造）', (
      WidgetTester tester,
    ) async {
      await pumpHost(tester, host(profile: seededProfile));

      // Figma 这两屏都写了 `最高匹配 86%`，取值来自原型的 `allVersions` 表。
      // [ResumeVersion] 没有匹配度字段 → 一个都不许出现。
      expect(find.text('最高匹配'), findsNothing);
      expect(find.text('86%'), findsNothing);
      expect(find.text('79%'), findsNothing);
      expect(find.text('68%'), findsNothing);

      // 同理：Figma 的版本名带 `Resume` 前缀，「本次变化」按版本存 —— 两者都没有。
      expect(find.textContaining('Resume V'), findsNothing);
      expect(find.textContaining('新增 AI Agent 项目'), findsNothing);
    });

    testWidgets('空画像 → Empty 态，横幅不渲染', (WidgetTester tester) async {
      await pumpHost(tester, host());

      expect(find.text('还没有简历'), findsOneWidget);
      expect(find.text('当前简历'), findsNothing);
      expect(find.text('查看详情'), findsNothing);
      // 没有简历就没有可换的东西 —— FAB 仍在（它正是用来导入的）。
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 二、归档版本列表
  // ---------------------------------------------------------------------------

  group('简历历史 · 归档版本', () {
    testWidgets('有归档版本时渲染「历史版本 · 左滑操作」与左滑卡', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));

      expect(find.text('历史版本 · 左滑操作'), findsOneWidget);
      // 归档卡只渲染**非**当前版本。
      expect(find.text('2026 初版'), findsOneWidget);
      expect(find.text('归档'), findsOneWidget);
      // 当前版本名只出现在横幅里（出现 1 次），不被复制进列表。
      expect(find.text('2026 春招版'), findsOneWidget);
    });

    testWidgets('点击归档版本打开该版本的详情内容', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));

      await tester.tap(find.text('2026 初版'));
      await tester.pumpAndSettle();

      expect(find.byType(ResumeDetailPage), findsOneWidget);
      expect(find.text('2026 初版'), findsOneWidget);
      expect(find.text('PDF 预览'), findsOneWidget);
      expect(find.text('原始内容'), findsOneWidget);
      expect(find.text('工作经历'), findsOneWidget);
    });

    testWidgets('只有当前版本时整段不渲染（Figma 的 length > 0 门禁）', (
      WidgetTester tester,
    ) async {
      final ResumeProfile single = ResumeProfile(
        versions: <ResumeVersion>[
          ResumeVersion(
            id: 'v1',
            label: '唯一版本',
            uploadedAt: DateTime(2026, 1, 1),
            isCurrent: true,
          ),
        ],
      );
      await pumpHost(tester, host(profile: single));

      expect(find.text('唯一版本'), findsOneWidget);
      expect(find.text('历史版本 · 左滑操作'), findsNothing);
      expect(find.text('归档'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // 三、「查看详情」→ 简历详情
  // ---------------------------------------------------------------------------

  group('简历历史 →「查看详情」', () {
    testWidgets('点「查看详情」进入详情页，页签为 PDF 预览 / 原始内容', (
      WidgetTester tester,
    ) async {
      await pumpHost(tester, host(profile: seededProfile));

      await tester.tap(find.text('查看详情'));
      await tester.pumpAndSettle();

      expect(find.byType(ResumeDetailPage), findsOneWidget);
      expect(find.text('PDF 预览'), findsOneWidget);
      expect(find.text('原始内容'), findsOneWidget);
      // 详情页顶栏标题 = 该版本名。
      expect(find.text('2026 春招版'), findsOneWidget);
    });

    testWidgets('详情页两个页签都能切，且底栏两个动作都在', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));
      await tester.tap(find.text('查看详情'));
      await tester.pumpAndSettle();

      // PDF 预览卡**跳过**「基本信息」段 —— 它已经画在卡片头部的渐变区里
      // （Figma `slice(1)`，L4660 起）。因此这里断言它**不在**。
      expect(find.text('基本信息'), findsNothing);
      expect(find.text('工作经历'), findsOneWidget);

      await tester.tap(find.text('原始内容'));
      await tester.pumpAndSettle();
      // 原始内容必须是实际上传的文件；这个 fixture 没有 PDF 文件名，
      // 因此不能用解析画像伪装成原稿。
      expect(find.text('此版本没有上传 PDF 原稿'), findsOneWidget);
      expect(find.text('基本信息'), findsNothing);
      expect(find.text('张明远'), findsNothing);

      expect(find.text('导出 PDF'), findsOneWidget);
      expect(find.text('编辑简历'), findsOneWidget);
    });

    testWidgets('详情页不渲染「最高匹配」（同 §7 约束）', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));
      await tester.tap(find.text('查看详情'));
      await tester.pumpAndSettle();

      expect(find.text('最高匹配'), findsNothing);
      expect(find.text('86%'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // 四、FAB → 导入弹层
  // ---------------------------------------------------------------------------

  group('简历历史 · FAB 与导入弹层', () {
    testWidgets('点 FAB 弹出「导入新简历」，含三个选项与取消', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('导入新简历'), findsOneWidget);
      expect(find.text('从文件选择'), findsOneWidget);
      expect(find.text('拍照上传'), findsOneWidget);
      expect(find.text('粘贴文本'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('「取消」关闭弹层，回到简历历史', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('导入新简历'), findsOneWidget);

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(find.text('导入新简历'), findsNothing);
      expect(find.text('我的简历'), findsOneWidget);
    });

    testWidgets('「粘贴文本」打开输入弹层，「导入」在空文本时禁用', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('粘贴文本'));
      await tester.pumpAndSettle();

      expect(find.text('粘贴简历文本'), findsOneWidget);
      // 空文本 → 禁用（§5.5 Disabled）。
      final Finder importButton = find.widgetWithText(CareerlyButton, '导入');
      expect(importButton, findsOneWidget);
      expect(tester.widget<CareerlyButton>(importButton).onPressed, isNull);

      // 有文本 → 可提交。
      await tester.enterText(find.byType(TextField).first, '一段简历文本');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CareerlyButton>(find.widgetWithText(CareerlyButton, '导入'))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('「拍照上传」如实提示尚未接入 —— 不假装导入成功', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('拍照上传'));
      await tester.pumpAndSettle();

      expect(find.textContaining('尚未接入'), findsOneWidget);
      // 仍在简历历史页，没有跳到详情页。
      expect(find.byType(ResumeDetailPage), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // 五、分享 / 导出弹层
  // ---------------------------------------------------------------------------

  group('简历详情 · 分享弹层', () {
    testWidgets('三个选项都在，且各自如实提示尚未接入', (WidgetTester tester) async {
      await pumpHost(tester, host(profile: seededProfile));
      await tester.tap(find.text('查看详情'));
      await tester.pumpAndSettle();

      // 顶栏右侧分享钮 —— 用图标定位。
      // ⚠️ `Icons.ios_share` 在本页出现**两次**：顶栏分享钮（20）
      // 与底栏「导出 PDF」（16）——Figma 里两者同一去向（L4655 的注释）。
      // 取首个即顶栏那颗。
      await tester.tap(find.byIcon(Icons.ios_share).first);
      await tester.pumpAndSettle();

      expect(find.text('分享 / 导出'), findsOneWidget);
      expect(find.text('存为 PDF'), findsOneWidget);
      expect(find.text('复制链接'), findsOneWidget);
      expect(find.text('发送邮件'), findsOneWidget);

      await tester.tap(find.text('存为 PDF'));
      await tester.pump();
      expect(find.textContaining('尚未接入'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// 桩
// ---------------------------------------------------------------------------

class _StubResumeRepository implements ResumeRepository {
  _StubResumeRepository(this.profile);

  final ResumeProfile profile;

  @override
  Future<ResumeProfile> fetchProfile() async => profile;

  @override
  Future<List<ResumeVersion>> fetchVersions() async => profile.versions;

  @override
  Future<List<int>> fetchVersionOriginalPdf(String versionId) async =>
      const <int>[];

  @override
  Future<void> setCurrentVersion(String versionId) async {}

  @override
  Future<void> deleteVersion(String versionId) async {}

  @override
  Future<void> submitResumeText(String text) async {}

  @override
  Future<void> submitResumeFile(ResumeFileData file) async {}

  @override
  Future<ResumeProfile> buildBaseline() async => profile;
}

class _StubCareerAssetsRepository implements CareerAssetsRepository {
  _StubCareerAssetsRepository(this.assets);

  final CareerAssets assets;

  @override
  Future<CareerAssets> fetchAssets() async => assets;
}

/// 永远返回「用户取消」的选择器 —— 本测试不真的取文件。
class _StubFilePicker implements ResumeFilePicker {
  const _StubFilePicker();

  @override
  Future<ResumeFileData?> pick() async => null;
}
