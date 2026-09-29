import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/state/async_state.dart';
import '../../../data/models/resume_profile.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../profile/state/resume_provider.dart';
import 'widgets/onboarding_action_buttons.dart';

/// 「职业基线已建立」确认页 —— Onboarding 第 6 屏（最后一屏）。
///
/// 真值来源：Figma `OnConfirm`（`src/App.tsx` L926-981）。
///
/// ```text
/// 顶部   7px 渐变条（无返回键、无进度条 —— 这是流程终点）
/// 内容   渐变圆环 + 勾 → 标题 → 说明 → 磨砂汇总卡 → 起点横幅
/// 底部   「进入 Careerly」(主按钮) → 首页
/// ```
///
/// ## ⚠️ 这一屏的渐变**不是**品牌渐变
///
/// Figma 在本页用的是 `linear-gradient(135deg, rgb(91,124,246) 0%, …)`
/// —— 首色 `#5B7CF6`，而品牌渐变首色是 `#4F7EF5`。
/// 两者并排**能看出色差**，故依 §3.1「Figma 已明确设计细节 → 采纳 Figma」
/// 逐位还原为 [AppColors.confirmGradient]，本页四处（渐变条 / 圆环内圆 /
/// 序号圆 / 主按钮）统一使用它。
///
/// ## ⚠️ 汇总卡是**数据驱动**的，不是写死的 4 / 6 / 12 / 5
///
/// Figma 硬编码了 `4 段 / 6 个 / 12 项 / 5 项`。依 `CLAUDE.md` §7
/// 「**不编造产品数据**」与产品侧裁决 **D64 ⑥**，这些数字**不得**搬进 Mock：
/// 四行由 [ResumeProfile] 的真实长度驱动
/// （`workExperiences` / `projectExperiences` / `skills` / `awards`）。
///
/// **因此当前 Mock 下这一屏呈现的是 Empty 态**，不是设计稿那张卡
/// —— 这是 `CLAUDE.md` §7 的**要求**（让 Empty 态真实可见），
/// 而不是实现缺失。接入真实接口后，同一份页面代码会渲染出设计稿的样子。
///
/// ## ⚠️ 标题 / 说明 / 横幅文案
///
/// 三处都是 Figma 原文，但归属 **D66**（AI 侧核对、待产品侧确认），
/// 其中「你的职业档案已建立！」的「档案」与 **D63** 定的
/// 「职业基线」措辞并存 —— 待产品侧一并确认。
class OnboardingConfirmPage extends StatefulWidget {
  const OnboardingConfirmPage({super.key});

  @override
  State<OnboardingConfirmPage> createState() => _OnboardingConfirmPageState();
}

class _OnboardingConfirmPageState extends State<OnboardingConfirmPage> {
  @override
  void initState() {
    super.initState();
    // 正常路径下数据已由「解析」屏建立好；直接落到本页（深链 / 热重载）
    // 时状态还是 initial，这里补一次读取。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ResumeProvider provider = context.read<ResumeProvider>();
      if (provider.state is AsyncInitial<ResumeProfile>) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ResumeProvider provider = context.watch<ResumeProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const _TopGradientStrip(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    children: <Widget>[
                      const _HeroSeal(),
                      const Text(
                        '你的职业档案已建立！',
                        style: AppTypography.onboardingHeadline,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Careerly 已完成初步解析，你可以随时完善',
                        style: AppTypography.onboardingTextAction,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.blockGap),
                      CareerlyAsyncStateView<ResumeProfile>(
                        state: provider.state,
                        // 档案为空 → Empty 态（`ResumeProfile.isEmpty`）。
                        isEmpty: (ResumeProfile profile) => profile.isEmpty,
                        onRetry: provider.load,
                        emptyTitle: '档案暂无内容',
                        emptyMessage:
                            'Mock 数据源默认返回空档案，接入真实接口后'
                            '这里会显示解析结果。',
                        builder: (_, ResumeProfile profile) =>
                            _SummaryCard(profile: profile),
                      ),
                      const SizedBox(height: AppSpacing.mdLg),
                      const _StartBanner(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: OnboardingPrimaryButton(
                  label: '进入 Careerly',
                  // Figma 本页用 135deg 的 confirmGradient，不是品牌渐变。
                  gradient: AppColors.confirmGradient,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 顶部的 7px 渐变细条。
class _TopGradientStrip extends StatelessWidget {
  const _TopGradientStrip();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _ConfirmMetrics.stripHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.confirmGradient),
      ),
    );
  }
}

/// 渐变圆环 + 内圆勾。
///
/// Figma：外层 `126×126` 圆环（`2px solid rgba(79,126,245,0.20)`），
/// 内圆 `inset: 13` → `100×100`，渐变底 + `0 16px 40px` 投影，内嵌 `40×40` 白勾。
class _HeroSeal extends StatelessWidget {
  const _HeroSeal();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: SizedBox(
        width: _ConfirmMetrics.heroSize,
        height: _ConfirmMetrics.heroSize,
        child: Stack(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandBorderFaint,
                  width: _ConfirmMetrics.heroRingWidth,
                ),
              ),
              child: const SizedBox.expand(),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(_ConfirmMetrics.heroInset),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.confirmGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.orb,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: _ConfirmMetrics.heroCheckSize,
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 磨砂汇总卡 —— **四行全部由数据驱动**（见类文档）。
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.profile});

  final ResumeProfile profile;

  @override
  Widget build(BuildContext context) {
    // 文案（标题 / 说明 / 单位）是 Figma 原文；数字来自真实数据。
    final List<_SummaryRowData> rows = <_SummaryRowData>[
      _SummaryRowData(
        index: 1,
        title: '工作经历',
        desc: '已识别你的职业经历',
        count: profile.workExperiences.length,
        unit: '段',
      ),
      _SummaryRowData(
        index: 2,
        title: '项目经历',
        desc: '已整理你的项目经验',
        count: profile.projectExperiences.length,
        unit: '个',
      ),
      _SummaryRowData(
        index: 3,
        title: '能力与技能',
        desc: '已提取你的职业能力与技能',
        count: profile.skills.length,
        unit: '项',
      ),
      _SummaryRowData(
        index: 4,
        title: '获奖经历',
        desc: '已提取你的职业荣誉',
        count: profile.awards.length,
        unit: '项',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mdLg,
        vertical: AppSpacing.xxs,
      ),
      decoration: const BoxDecoration(
        // ⚠️ Figma 另配 `backdrop-filter: blur(16px)` —— 见 D72。
        color: AppColors.frostedFill,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.frosted,
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++)
            _SummaryRow(
              data: rows[i],
              showDivider: i < rows.length - 1,
            ),
        ],
      ),
    );
  }
}

/// 一行汇总数据。
class _SummaryRowData {
  const _SummaryRowData({
    required this.index,
    required this.title,
    required this.desc,
    required this.count,
    required this.unit,
  });

  final int index;
  final String title;
  final String desc;
  final int count;
  final String unit;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.data, required this.showDivider});

  final _SummaryRowData data;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.rowDivider))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _ConfirmMetrics.rowPadding,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: _ConfirmMetrics.indexSize,
              height: _ConfirmMetrics.indexSize,
              decoration: const BoxDecoration(
                gradient: AppColors.confirmGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${data.index}',
                  style: AppTypography.onboardingSummaryIndex,
                ),
              ),
            ),
            const SizedBox(width: _ConfirmMetrics.rowGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(data.title, style: AppTypography.onboardingRowTitle),
                  const SizedBox(height: _ConfirmMetrics.rowTitleGap),
                  Text(data.desc, style: AppTypography.onboardingCaption),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Row(
              children: <Widget>[
                Container(
                  width: _ConfirmMetrics.dotSize,
                  height: _ConfirmMetrics.dotSize,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: _ConfirmMetrics.countGap),
                Text('${data.count}', style: AppTypography.onboardingBarTitle),
                const SizedBox(width: _ConfirmMetrics.countGap),
                Text(
                  data.unit,
                  style: AppTypography.onSurfaceVariant(
                    AppTypography.onboardingCaption,
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部的「起点」横幅。
class _StartBanner extends StatelessWidget {
  const _StartBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlueSurface,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        children: <Widget>[
          const Text('🚀', style: TextStyle(fontSize: _ConfirmMetrics.emojiSize)),
          const SizedBox(width: _ConfirmMetrics.bannerGap),
          Expanded(
            child: Text(
              '你的职业基线已建立 · 这是你成长的起点',
              style: AppTypography.onSurfaceVariant(
                AppTypography.onboardingCaption,
                AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 页面内部几何（Figma 原值）。
abstract final class _ConfirmMetrics {
  /// Figma：顶部渐变条 `height: 7`。
  static const double stripHeight = 7;

  /// Figma：圆环 `126×126`。
  static const double heroSize = 126;

  /// Figma：圆环 `border: 2px solid`。
  static const double heroRingWidth = 2;

  /// Figma：内圆 `inset: 13`（126 - 13×2 = 100）。
  static const double heroInset = 13;

  /// Figma：勾的字形 `40×40`。
  static const double heroCheckSize = 40;

  /// Figma：汇总行 `padding: 14px 0`。
  static const double rowPadding = 14;

  /// Figma：序号圆 `28×28`。
  static const double indexSize = 28;

  /// Figma：序号圆与文字 `gap: 14`。
  static const double rowGap = 14;

  /// Figma：行标题与说明 `margin-top: 2`。
  static const double rowTitleGap = 2;

  /// Figma：绿点 `8×8`。
  static const double dotSize = 8;

  /// Figma：数量组内 `gap: 6`。
  static const double countGap = 6;

  /// Figma：横幅内 `gap: 10`。
  static const double bannerGap = 10;

  /// Figma：横幅 emoji `font-size: 18px`。
  static const double emojiSize = 18;
}
