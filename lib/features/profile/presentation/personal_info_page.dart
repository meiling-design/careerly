import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../core/state/state.dart';
import '../../../data/models/resume_profile.dart';
import '../../../data/models/user_profile.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/resume_provider.dart';
import '../state/user_profile_provider.dart';

/// 个人信息 —— 「设置 → 账户 → 个人信息」的二级页面。
///
/// ## ⚠️ 本页**只读**（2026-10-07 裁决）
///
/// 页面内**没有任何输入控件**，也不存在「保存」按钮。
/// 用户对本轮范围的裁决原话是「**先跑通只读**」——
/// 编辑昵称的方案（后端新增 `PUT /api/v1/profile`）**已撤回**，
/// 后端一行未改。
///
/// `test/personal_info_test.dart` 有一条**范围护栏**用例断言本页
/// `TextField` / `CareerlyInput` 均为空 —— 将来谁加了输入框会立刻变红，
/// 而不是悄悄越过这条裁决。
///
/// ## ⚠️ 本页**没有 Figma 规格**（登记 **待裁决 · D125**）
///
/// Figma 全稿**不存在**这一页。它是按「设置 → 账户」的既有形态
/// （对照同目录的 `delete_career_data_page.dart`）+ 两个**已存在**的接口
/// 拼出来的，**没有新增任何数据来源**：
///
/// ```text
/// 姓名 / 手机号 / 会员状态   ← GET /api/v1/profile   （账号身份）
/// 邮箱 / 职位 / 工作经验      ← GET /api/v1/resume     （简历画像）
/// ```
///
/// 因此**不得**据本页反推「视觉已定稿」。三处 Flutter 侧自拟见各类的注释，
/// 一并在 `docs/05_progress/TODO.md` §3.1 · D125 登记。
///
/// ## 归属与为何复用两个既有 Provider
///
/// 两段数据来自**不同领域**（账号 vs 简历），`CLAUDE.md` §6.3 要求按领域拆分。
/// 这里直接消费既有的 [UserProfileProvider] 与 [ResumeProvider]，
/// **不新建聚合 Provider** —— 那会制造第二份数据所有权，并让
/// 「简历读不到」连带「姓名也显示不出来」。
/// 两个 Provider **各自降级**：简历块失败只让那一块显示降级文案。
///
/// ## ⚠️ 为什么**不**给 [CareerlyAsyncStateView.isEmpty]
///
/// [UserProfile.isEmpty] 在三个字段**全空**时为 `true`，而**新注册用户
/// 恰好就是全空**（`user_profile.dart` 顶部的 D90 说明）。
/// 若把 `isEmpty` 传给 [CareerlyAsyncStateView]，页面会整页渲染成
/// Empty 占位 —— 用户**看不到自己已经有的资料**，只看到一句「暂无内容」。
///
/// 那个 `isEmpty` 是给「我的」主页顶部身份卡用的（那里空态要显示中性占位），
/// **本页不消费它**。空字段在本页逐行降级为「未设置」/「未绑定」。
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  @override
  void initState() {
    super.initState();

    // 照 `resume_history_page.dart` 的既有写法：在首帧之后读 Provider 并
    // 按需加载。「按需」很要紧 —— 这两个 Provider 可能已被别处加载过
    // （「我的」主页读身份、「我的简历」读画像），重复 load 会白跑一次网络。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final UserProfileProvider profile = context.read<UserProfileProvider>();
      if (profile.data == null && !profile.isLoading) {
        profile.load();
      }

      final ResumeProvider resume = context.read<ResumeProvider>();
      if (resume.data == null && !resume.isLoading) {
        resume.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProfileProvider profile = context.watch<UserProfileProvider>();
    final ResumeProvider resume = context.watch<ResumeProvider>();

    return CareerlyScaffold(
      title: '个人信息',
      leading: IconButton(
        onPressed: () => careerlyBack(context),
        icon: const Icon(Icons.arrow_back),
        tooltip: '返回',
      ),
      // 本页无未保存状态，因此**不**包 `CareerlyBackScope`
      // （`back_navigation.dart` 明确：无守卫的页面「完全透明、一字不用改」）。
      // 返回目标由路由层级表达（二级 → 回设置），页面不自己决定回到哪
      // （`CLAUDE.md` §5.6）。
      child: CareerlyAsyncStateView<UserProfile>(
        state: profile.state,
        // ⚠️ 刻意**不传** isEmpty —— 理由见类文档。
        onRetry: profile.load,
        loadingMessage: '正在加载个人信息',
        builder: (BuildContext context, UserProfile user) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: <Widget>[
            _Section(
              title: '账户',
              children: <Widget>[
                // ⚠️ 账户三项**始终渲染**，空值降级为中性文案而不是跳过该行。
                //
                // 与下面「来自简历」的处置**刻意不同**：这三项描述的是
                // 「这个账号本身」，行存在但为空本身就是一条信息；
                // 简历三项是**派生数据**，没有简历时它们没有意义（见下）。
                _ReadOnlyRow(
                  label: '姓名',
                  // ⚠️ Flutter 侧自拟文案（Figma 无此态）。在**只读**语境下
                  // 「未设置」是如实的 —— 它只陈述「这里空着」，
                  // 不暗示可以在这里填写。随 D125 登记。
                  value: _orFallback(user.displayName, '未设置'),
                ),
                _ReadOnlyRow(
                  label: '手机号',
                  // 只显示 `GET /profile` 下发的**脱敏**值（`138****1111`）——
                  // 完整号码不下发，本页也不该是例外。见 `identity.py` 的说明。
                  value: _orFallback(user.handle, '未绑定'),
                  note: '登录凭据',
                ),
                _ReadOnlyRow(
                  label: '会员状态',
                  // ⚠️ 后端对非会员下发**空串**（`identity.py` 刻意的裁决：
                  // 「说『你什么都没有』的徽章比没有徽章更糟」）。
                  // 但那是**徽章**的处置；本页是一个带标签的信息行，
                  // 空着会让人以为没加载出来，故降级为「非会员」。
                  //
                  // ⚠️ 用「非会员」而**不是**「普通用户」—— 后者会暗示一套
                  // PRD 尚未定义的等级体系（**D87**）。本页只说
                  // 「是不是会员」，不发明等级名。随 D125 登记。
                  value: _orFallback(user.membershipLabel, '非会员'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _ResumeSection(state: resume.state),
          ],
        ),
      ),
    );
  }
}

/// 空串 / 纯空白 → 中性降级文案。
String _orFallback(String value, String fallback) {
  return value.trim().isEmpty ? fallback : value.trim();
}

/// 「来自简历」分区。
///
/// ⚠️ 数据源是 [ResumeProvider]，与上面的账户三项**不是同一路**。
/// 它自己处理三种降级，**不让整页跟着掉进错误态**（`CLAUDE.md` §6.3）：
///
/// ```text
/// 读取中        → 一行「正在读取简历信息…」
/// 读取失败      → 一行降级说明（账户三项照常显示）
/// 读取成功但空  → 收起整个分区，换一句说明（见下）
/// ```
///
/// ## ⚠️ 空字段逐项**跳过**，不填占位符
///
/// 沿用 `resume_profile.dart` 既有约定：「解析不出时为空 —— 页面**不渲染**
/// 该行，而不是填占位符」。简历解析常抽出 `email: ""`，填「—」会让
/// 「解析不出」看起来像「用户没填」。
///
/// 三项**全空**时整个分区收起，换一句中性说明 —— 这不是异常态，
/// 而是**只注册、没上传过简历**的真实用户的正常样子
/// （已实测确有此数据：某用户的 `profile` 就是 `{}`）。
class _ResumeSection extends StatelessWidget {
  const _ResumeSection({required this.state});

  final AsyncState<ResumeProfile> state;

  /// 简历三项的取值。空串收敛为 `null`，由调用方决定是否跳过该行。
  static List<({String label, String? value})> _entries(
    ResumeProfile profile,
  ) {
    // 「职位」= 后端 `roles`（字符串数组）。
    //
    // ⚠️ **join 全部而不是取首项**：后端 `roles` 是 LLM 抽取的结果，
    // **没有「最近 / 当前」的顺序语义**。取 `first` 是在赌一个不存在的
    // 约定 —— 赌错就会把用户**旧**的职位显示成当前职位，而这比
    // 「一次显示两个」错得更隐蔽。join 是**如实呈现**。
    // 随 D125 登记（若产品侧要「只显示当前职位」，需要后端给排序依据）。
    final String? position = profile.workExperiences.isEmpty
        ? null
        : profile.workExperiences.join('、');

    return <({String label, String? value})>[
      (label: '邮箱', value: _clean(profile.email)),
      (label: '职位', value: position),
      (
        label: '工作经验',
        // 后端给的是整数年（`experience_years`，实测为 `5.0`）。
        // `ResumeProfile` 已把它收成 `int?`，见该字段的说明。
        value: profile.experienceYears == null
            ? null
            : '${profile.experienceYears} 年',
      ),
    ];
  }

  static String? _clean(String? value) {
    final String text = (value ?? '').trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ 注意 `data == null` 的两种情况必须分开：加载中 vs 已失败。
    // 只看 `data` 会把「还在读」显示成「读不到」。
    if (state is AsyncLoading<ResumeProfile> || state is AsyncInitial<ResumeProfile>) {
      return _Section(
        title: '来自简历',
        children: const <Widget>[
          _PlaceholderRow('正在读取简历信息…'),
        ],
      );
    }

    if (state is AsyncFailure<ResumeProfile>) {
      return _Section(
        title: '来自简历',
        children: const <Widget>[
          // 降级文案**不**复用上面的错误对象详情 —— 那是简历块的失败，
          // 不该在个人信息页展开一段属于简历页的错误。
          _PlaceholderRow('暂时无法读取简历信息，可在「我的简历」查看'),
        ],
      );
    }

    final ResumeProfile? profile = state.dataOrNull;
    if (profile == null) {
      return _Section(
        title: '来自简历',
        children: const <Widget>[
          _PlaceholderRow('暂时无法读取简历信息，可在「我的简历」查看'),
        ],
      );
    }

    final List<({String label, String? value})> filled = _entries(profile)
        .where((({String label, String? value}) e) => e.value != null)
        .toList(growable: false);

    if (filled.isEmpty) {
      // ⚠️ 全部为空 ⇒ 收起分区，换一句说明。
      // 这句是 Flutter 侧自拟文案（Figma 无此态），随 D125 登记。
      return _Section(
        title: '来自简历',
        children: const <Widget>[
          _PlaceholderRow('上传简历后，邮箱、职位与工作经验会自动显示在这里'),
        ],
      );
    }

    return _Section(
      title: '来自简历',
      children: <Widget>[
        // 分区标题下的一句说明：这三项**只能**从简历来，本页改不了。
        const _PlaceholderRow('以下信息来自你的简历，请到「我的简历」更新'),
        for (final ({String label, String? value}) entry in filled)
          _ReadOnlyRow(label: entry.label, value: entry.value!),
      ],
    );
  }
}

/// 分区：小标题 + 玻璃卡（照 `delete_career_data_page.dart` / `settings_page.dart`）。
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Text(title, style: AppTypography.caption),
        ),
        CareerlyCard(
          variant: CareerlyCardVariant.glassLight,
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// 只读信息行：左标签（可选副注）+ 右值。
///
/// 值右对齐并允许折两行 —— 邮箱这类长值折行比溢出好。
class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value, this.note});

  final String label;

  /// 已经过降级处理的**非空**值（调用方负责空值处置）。
  final String value;

  /// 标签下方的补充说明（例如「登录凭据」）。
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: AppTypography.onSurfaceVariant(
                  AppTypography.bodySmall,
                  AppColors.textSecondary,
                ),
              ),
              if (note != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: Text(
                    note!,
                    style: AppTypography.onSurfaceVariant(
                      AppTypography.caption,
                      AppColors.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.onSurfaceVariant(
                AppTypography.bodySmall,
                AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 分区内的一行说明文字（非「键 → 值」形态）。
class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        text,
        style: AppTypography.onSurfaceVariant(
          AppTypography.caption,
          AppColors.textTertiary,
        ),
      ),
    );
  }
}
