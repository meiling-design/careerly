import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/models/resume_file.dart';
import 'package:careerly/data/models/resume_profile.dart';
import 'package:careerly/data/models/user_profile.dart';
import 'package:careerly/data/repositories/profile_repository.dart';
import 'package:careerly/data/repositories/resume_repository.dart';
import 'package:careerly/design_system/components/components.dart';
import 'package:careerly/features/profile/presentation/personal_info_page.dart';
import 'package:careerly/features/profile/state/resume_provider.dart';
import 'package:careerly/features/profile/state/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// 「设置 → 账户 → 个人信息」页（**只读**）的页面测试。
///
/// ## 本文件钉住两件事
///
/// 1. **数据如实渲染** —— 账户三项来自 `GET /api/v1/profile`、
///    简历三项来自 `GET /api/v1/resume`，两路**各自降级**；
/// 2. **本页没有任何输入控件** —— 这是 2026-10-07 用户裁决
///    「暂时先不支持信息修改，先跑通只读」的**范围护栏**。
///    将来谁在本页加了输入框 / 保存按钮，这里会立刻变红，
///    而不是让「只读」这条裁决被悄悄越过。
///
/// 页面无 Figma 规格，登记 **待裁决 · D125**（`docs/05_progress/TODO.md` §3.1）。
void main() {
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// `pumpAndSettle` **不可用** —— 页面上有 `CircularProgressIndicator`
  /// （无限动画），settle 会一直等下去。沿用 `delete_career_data_test.dart`
  /// 的固定节拍写法。
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  /// 挂起本页。
  ///
  /// ⚠️ **必须替换掉 `ChangeNotifierProvider<X>` 这一层本身**，
  /// 不能只在 `careerlyProviders` 的 `overrides` 里追加 `Provider<Repo>`：
  /// `UserProfileProvider` / `ResumeProvider` 的 `create` 已经先注册，
  /// 它们的 `context.read<Repo>()` 读的是**外层**上下文，
  /// 尾部追加的同类型 Repo 提供者**到不了**它们
  /// （`MultiProvider` 的 `create` 只见祖先）。写错了的表现是
  /// 「Fake 一次都没被调用、测试其实走 Mock」—— 静默通过，最难查。
  Future<void> pumpPage(
    WidgetTester tester, {
    required _FakeProfileRepository profile,
    required _FakeResumeRepository resume,
    String initialLocation = AppRoutes.settingsPersonalInfo,
  }) async {
    useTallViewport(tester);
    await tester.pumpWidget(
      CareerlyApp(
        initialLocation: initialLocation,
        overrides: <SingleChildWidget>[
          ChangeNotifierProvider<UserProfileProvider>.value(
            value: UserProfileProvider(profile),
          ),
          ChangeNotifierProvider<ResumeProvider>.value(
            value: ResumeProvider(resume),
          ),
        ],
      ),
    );
    await settle(tester);
  }

  testWidgets('设置页「个人信息」入口可到达本页', (WidgetTester tester) async {
    // 接线前那一行是空壳 `onTap: () {}`（`TODO.md` §2.2 · K22），
    // 点上去毫无反应 —— 这条用例钉住它真的能进。
    await pumpPage(
      tester,
      profile: _FakeProfileRepository(),
      resume: _FakeResumeRepository(),
      initialLocation: AppRoutes.settings,
    );

    expect(find.text('个人信息'), findsOneWidget);
    await tester.tap(find.text('个人信息'));
    await settle(tester);

    expect(find.byType(PersonalInfoPage), findsOneWidget);
  });

  testWidgets('账户三项如实渲染（姓名 / 脱敏手机号 / 会员状态）', (
    WidgetTester tester,
  ) async {
    await pumpPage(
      tester,
      profile: _FakeProfileRepository(
        profile: const UserProfile(
          displayName: '张伟',
          handle: '138****1111',
          membershipLabel: 'V1会员',
        ),
      ),
      resume: _FakeResumeRepository(),
    );

    expect(find.text('姓名'), findsOneWidget);
    expect(find.text('张伟'), findsOneWidget);
    expect(find.text('手机号'), findsOneWidget);
    // ⚠️ 只接受**脱敏**值 —— 后端 `GET /profile` 不下发完整号码，
    // 本页也不该是例外（`identity.py`）。
    expect(find.text('138****1111'), findsOneWidget);
    expect(find.text('登录凭据'), findsOneWidget);
    expect(find.text('会员状态'), findsOneWidget);
    expect(find.text('V1会员'), findsOneWidget);
  });

  testWidgets('简历三项如实渲染（邮箱 / 职位 / 工作经验）', (
    WidgetTester tester,
  ) async {
    await pumpPage(
      tester,
      profile: _FakeProfileRepository(),
      resume: _FakeResumeRepository(
        profile: const ResumeProfile(
          email: 'zhangwei@example.com',
          workExperiences: <String>['后端工程师', '架构师'],
          experienceYears: 5,
        ),
      ),
    );

    expect(find.text('邮箱'), findsOneWidget);
    expect(find.text('zhangwei@example.com'), findsOneWidget);
    // ⚠️ 后端 `roles` 是 LLM 抽取的数组、**没有顺序语义**，
    // 因此这里 join 全部而不是取首项 —— 取首项会把旧职位
    // 显示成「当前职位」（见 `_ResumeSection._entries` 的说明）。
    expect(find.text('后端工程师、架构师'), findsOneWidget);
    expect(find.text('工作经验'), findsOneWidget);
    // `double` 会渲染成「5.0 年」，故模型侧收成 `int?`。
    expect(find.text('5 年'), findsOneWidget);
  });

  testWidgets('简历为空时收起「来自简历」分区，换一句中性说明', (
    WidgetTester tester,
  ) async {
    // ⚠️ 这不是异常态 —— 只注册、**从没上传过简历**的用户本来就长这样
    // （后端实测确有此数据：某些用户的 `profile` 就是 `{}`）。
    await pumpPage(
      tester,
      profile: _FakeProfileRepository(),
      resume: _FakeResumeRepository(profile: ResumeProfile.empty),
    );

    expect(find.text('邮箱'), findsNothing);
    expect(find.text('职位'), findsNothing);
    expect(find.text('工作经验'), findsNothing);
    expect(find.textContaining('上传简历后'), findsOneWidget);
  });

  testWidgets('资料全空仍渲染（**不得**掉进 Empty 占位）', (WidgetTester tester) async {
    // ⚠️ 回归护栏：`UserProfile.isEmpty` 在三字段全空时为 `true`，
    // 而**新注册用户恰好就是全空**。若把 `isEmpty` 传给
    // `CareerlyAsyncStateView`，整页会渲染成 Empty 占位，
    // 用户**看不到自己已经有的资料**。本页刻意不消费那个 `isEmpty`。
    await pumpPage(
      tester,
      profile: _FakeProfileRepository(profile: UserProfile.empty),
      resume: _FakeResumeRepository(),
    );

    expect(find.text('姓名'), findsOneWidget);
    expect(find.text('未设置'), findsOneWidget);
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('未绑定'), findsOneWidget);
    // ⚠️ 「非会员」而不是「普通用户」—— 后者会暗示一套 PRD 未定义的
    // 等级体系（**D87**）。
    expect(find.text('非会员'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('暂无内容'), findsNothing);
    expect(find.text('重试'), findsNothing);
  });

  testWidgets('本页**没有任何输入控件**（只读裁决的范围护栏）', (
    WidgetTester tester,
  ) async {
    // ⚠️ 2026-10-07 用户裁决：「暂时先不支持信息修改，先跑通只读」。
    // 编辑昵称的方案（含后端 `PUT /api/v1/profile`）**已撤回**、后端一行未改。
    // 这条断言就是那条裁决的可执行形式 —— 谁加了输入框，这里变红。
    await pumpPage(
      tester,
      profile: _FakeProfileRepository(
        profile: const UserProfile(displayName: '张伟', handle: '138****1111'),
      ),
      resume: _FakeResumeRepository(
        profile: const ResumeProfile(email: 'zhangwei@example.com'),
      ),
    );

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(CareerlyInput), findsNothing);
    // 也没有「保存」这类写入口。
    expect(find.byType(CareerlyButton), findsNothing);
    expect(find.text('保存'), findsNothing);
  });

  testWidgets('读取失败展示错误与重试，重试后恢复', (WidgetTester tester) async {
    final _FakeProfileRepository profile = _FakeProfileRepository(
      profile: const UserProfile(displayName: '张伟'),
      failuresBeforeSuccess: 1,
    );
    await pumpPage(
      tester,
      profile: profile,
      resume: _FakeResumeRepository(),
    );

    expect(profile.fetchCalls, 1);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await settle(tester);

    expect(profile.fetchCalls, 2);
    expect(find.text('张伟'), findsOneWidget);
    expect(find.text('重试'), findsNothing);
  });

  testWidgets('简历块失败**不拖垮整页**（账户三项照常显示）', (
    WidgetTester tester,
  ) async {
    // `CLAUDE.md` §6.3 按领域拆分：两路数据各自降级。
    // 简历读不到只该让那一块显示降级文案，不该把姓名也一起吞掉。
    await pumpPage(
      tester,
      profile: _FakeProfileRepository(
        profile: const UserProfile(displayName: '张伟', handle: '138****1111'),
      ),
      resume: _FakeResumeRepository(failing: true),
    );

    expect(find.text('姓名'), findsOneWidget);
    expect(find.text('张伟'), findsOneWidget);
    expect(find.text('138****1111'), findsOneWidget);
    // 简历块的降级文案 —— **不**展开简历页的错误详情。
    expect(find.textContaining('暂时无法读取简历信息'), findsOneWidget);
    // 整页没有掉进错误态（也没有整页的重试按钮）。
    expect(find.text('重试'), findsNothing);
  });
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({
    this.profile = UserProfile.empty,
    this.failuresBeforeSuccess = 0,
  });

  final UserProfile profile;

  /// 前 N 次调用抛错，之后成功 —— 用于验证「错误 → 重试 → 恢复」。
  int failuresBeforeSuccess;

  int fetchCalls = 0;

  @override
  Future<UserProfile> fetchUserProfile() async {
    fetchCalls++;
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      throw const NetworkError(detail: 'test');
    }
    return profile;
  }
}

class _FakeResumeRepository implements ResumeRepository {
  _FakeResumeRepository({this.profile = ResumeProfile.empty, this.failing = false});

  final ResumeProfile profile;
  final bool failing;

  int fetchCalls = 0;

  @override
  Future<ResumeProfile> fetchProfile() async {
    fetchCalls++;
    if (failing) throw const NetworkError(detail: 'test');
    return profile;
  }

  @override
  Future<List<ResumeVersion>> fetchVersions() async => const <ResumeVersion>[];

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
