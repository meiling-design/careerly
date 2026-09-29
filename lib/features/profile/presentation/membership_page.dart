import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../analysis/state/analysis_provider.dart';
import '../state/career_assets_provider.dart';
import 'profile_assets_loader.dart';

/// Careerly Pro 会员页。
///
/// 真值来源：Figma `MembershipPage`（`src/App.tsx` L4843-4911）。
///
/// ```text
/// TopBar「Careerly Pro」                       L4847
/// Hero  品牌渐变 + 两个装饰圆 + 居中三行        L4850-4861
/// Card  免费体验额度（额度条 + 用尽后的三行）    L4864-4881
/// 标题  「Pro 权益」                            L4884
/// Card ×4 权益（渐变图标板 + 标题 + 说明）       L4886-4897
/// 主按钮「开通 Careerly Pro」                   L4900
/// 脚注  「安全支付 · 随时取消 · 不自动续费」     L4901
/// ```
///
/// ## ⚠️ MVP 边界（`CLAUDE.md` §4 决策 6）
///
/// ```text
/// ✅ 静态页 + 额度门禁展示
/// ❌ 不做真实支付
/// ```
///
/// 因此「开通 Careerly Pro」按钮**不接任何支付**。
/// 这不是遗漏 —— 按决策 6，MVP 里就没有支付这一步。
/// 按钮点下去的行为由 [CareerlyButton] 的 `onPressed` 决定，
/// 本轮给的是**提示语**而不是假装下单（见 [_MembershipCopy.purchaseHint]）。
///
/// ## ⚠️ 「用尽后三行」只还原**可派生**的两行
///
/// Figma 在额度为 0 时展示三行（L4874-4878）：
///
/// | Figma | 本轮 | 理由 |
/// |---|---|---|
/// | 能力变化 `+12` | ❌ **不渲染** | 「能力变化」的口径未定义 —— Σ增量？最高项？快照差？`+12` 与任何算法都对不上（**待裁决 · D87**） |
/// | 最高岗位匹配 `86%` | ✅ 由 `latestTopScore` 取最大 | 标签本身就说清了口径；且 §7 明令禁止写死 `86%` |
/// | 已积累资产 `4段 + 6个 + 12项` | ✅ 由 `CareerAssets` 计数派生 | 计数与数组长度不一致（**D89** 家族），一律派生 |
///
/// 「能力变化」那一行**不是忘了**：口径没定义时，写死或猜一个都是
/// 「用代码解决产品问题」（`CLAUDE.md` §0）。等产品侧裁决后再补。
class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ensureCareerAssetsLoaded(context);
      final AnalysisProvider analysis = context.read<AnalysisProvider>();
      // 额度可能已在「分析」页取过；没有才补。
      if (analysis.quota == null) {
        analysis.loadQuota();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AnalysisProvider analysis = context.watch<AnalysisProvider>();
    final CareerAssetsProvider assets = context
        .watch<CareerAssetsProvider>();
    final QuotaState? quota = analysis.quota;

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyTopBar(
            title: 'Careerly Pro',
            onBack: () => careerlyBack(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                _MembershipMetrics.inset,
                0,
                _MembershipMetrics.inset,
                _MembershipMetrics.bottom,
              ),
              children: <Widget>[
                const _ProHero(),
                // ⚠️ 额度未到位（读取中 / 读取失败）时**不渲染**这张卡。
                // [AnalysisProvider.loadQuota] 的约定是「失败就保持 null，
                // 只影响门禁」——那这里就不该凭空显示一个额度。
                if (quota != null) ...<Widget>[
                  const SizedBox(height: _MembershipMetrics.gap),
                  _TrialCard(
                    quota: quota,
                    stats: _trialStats(
                      quota: quota,
                      assets: assets.data,
                      topMatch: _topMatchScore(analysis),
                    ),
                  ),
                ],
                const SizedBox(height: _MembershipMetrics.gap),
                const Text(
                  'Pro 权益',
                  // 15 / w700 / #111827 —— 与二级页顶栏标题、工作经历列表
                  // 的经历标题是**同一个组合**，故复用同一角色
                  // （该角色的注释已声明这层共用关系）。
                  style: AppTypography.profileTopBarTitle,
                ),
                const SizedBox(height: _MembershipMetrics.gap),
                for (final _Benefit benefit in _Benefit.values) ...<Widget>[
                  _BenefitCard(benefit: benefit),
                  if (benefit != _Benefit.values.last)
                    const SizedBox(height: _MembershipMetrics.benefitGap),
                ],
                const SizedBox(height: _MembershipMetrics.gap),
                CareerlyButton(
                  label: '开通 Careerly Pro',
                  onPressed: () => _showTrialNotice(context),
                ),
                const SizedBox(height: _MembershipMetrics.gap),
                const Text(
                  _MembershipCopy.footer,
                  style: AppTypography.profileSmallMeta,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 额度用尽后那三行里**可派生**的两行。
  static List<_TrialStat> _trialStats({
    required QuotaState quota,
    required CareerAssets? assets,
    required int? topMatch,
  }) {
    return <_TrialStat>[
      if (topMatch != null)
        _TrialStat(label: '最高岗位匹配', value: '$topMatch%'),
      if (assets != null && assets.isNotEmpty)
        _TrialStat(
          label: '已积累资产',
          value:
              '${assets.workCount}段 + ${assets.projectCount}个 + ${assets.skillCount}项',
        ),
    ];
  }

  /// 全部分析项目里，最新一次结果中的最高匹配分。
  ///
  /// 取各项目 `latestTopScore` 的**最大值** —— 与「最高岗位匹配」这个标签一致。
  /// 没有任何分析结果时返回 `null`（不渲染该行，而不是显示 0%）。
  static int? _topMatchScore(AnalysisProvider provider) {
    int? best;
    for (final AnalysisProject project
        in provider.data ?? const <AnalysisProject>[]) {
      final int? score = project.latestTopScore;
      if (score != null && (best == null || score > best)) best = score;
    }
    return best;
  }

  /// 「开通」按钮的当前行为：**只提示，不支付**。
  ///
  /// MVP 无支付通道（§4 决策 6）。这里用 [CareerlyToast] 如实说明，
  /// 而不是给一个毫无反应的按钮、也不是伪造一个成功态。
  static void _showTrialNotice(BuildContext context) {
    CareerlyToast.show(
      context,
      message: _MembershipCopy.purchaseHint,
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

/// 会员页 Hero。Figma L4850-4861。
///
/// ⚠️ 与其他 Hero 的两点不同：
///
/// ```text
/// ① 两个装饰圆，分别在左上与右下（其他页只有一个、在右上）
/// ② 内容**居中**（其他页左对齐）
/// ```
///
/// 这正是「不把 Hero 抽成共享组件」的理由之一 —— 见
/// `work_detail_page.dart` 的 `_WorkHero` 说明。
class _ProHero extends StatelessWidget {
  const _ProHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.borderXl,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _MembershipMetrics.heroCircleOffset,
            left: _MembershipMetrics.heroCircleOffset,
            child: const _HeroCircle(size: _MembershipMetrics.heroCircle),
          ),
          Positioned(
            bottom: _MembershipMetrics.heroCircleOffset,
            right: _MembershipMetrics.heroCircleOffset,
            child: const _HeroCircle(size: _MembershipMetrics.heroCircle),
          ),
          const Padding(
            padding: EdgeInsets.all(_MembershipMetrics.heroPadding),
            child: Column(
              children: <Widget>[
                Text(
                  'Careerly Pro',
                  style: AppTypography.profileProHeroEyebrow,
                ),
                SizedBox(height: _MembershipMetrics.heroEyebrowGap),
                Text(
                  _MembershipCopy.heroTitle,
                  style: AppTypography.profileProHeroTitle,
                ),
                SizedBox(height: _MembershipMetrics.heroTitleGap),
                Text(
                  _MembershipCopy.heroSubtitle,
                  style: AppTypography.profileProHeroSub,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero 上的装饰圆。
///
/// Figma 两个圆的透明度不同（`0.08` / `0.06`），本轮合并为
/// [AppColors.profileHeroDecoration] —— 理由见该令牌。
class _HeroCircle extends StatelessWidget {
  const _HeroCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.profileHeroDecoration,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 额度卡
// ---------------------------------------------------------------------------

/// 免费体验额度卡。Figma L4864-4881。
class _TrialCard extends StatelessWidget {
  const _TrialCard({required this.quota, required this.stats});

  final QuotaState quota;

  /// 额度用尽后展示的统计行（可派生的那些）。
  final List<_TrialStat> stats;

  @override
  Widget build(BuildContext context) {
    final bool exhausted = quota.isExhausted;
    final Color accent = exhausted ? AppColors.danger : AppColors.primaryBlue;
    final double ratio = quota.total <= 0
        ? 0
        : (quota.remaining / quota.total).clamp(0.0, 1.0);

    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_MembershipMetrics.trialPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  exhausted
                      ? _MembershipCopy.trialExhausted
                      : _MembershipCopy.trialActive,
                  style: AppTypography.onSurfaceVariant(
                    AppTypography.profileDetailCardTitle,
                    exhausted ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: _MembershipMetrics.trialTitleGap),
              Text(
                // Figma 写死 `/ 3 次`（L4868）；3 就是免费额度总量，
                // 因此从 [QuotaState.total] 派生而不是照抄数字。
                '${quota.remaining} / ${quota.total} 次',
                style: AppTypography.onSurfaceVariant(
                  AppTypography.profileDetailCardTitle,
                  accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: _MembershipMetrics.trialBarGap),
          _TrialBar(ratio: ratio, exhausted: exhausted),
          if (exhausted && stats.isNotEmpty) ...<Widget>[
            const SizedBox(height: _MembershipMetrics.trialStatsGap),
            for (final _TrialStat stat in stats)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _MembershipMetrics.trialStatRowPaddingV,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        stat.label,
                        style: AppTypography.profileProjectRole,
                      ),
                    ),
                    Text(
                      stat.value,
                      style: AppTypography.onSurfaceVariant(
                        AppTypography.profileProStatValue,
                        AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// 额度进度条。Figma L4869-4871。
///
/// 轨道高 8（`h-2`）、圆角为 pill；填充用**品牌渐变**，额度用尽时改用
/// [AppColors.danger]（Figma L4870 的三元表达式）。
class _TrialBar extends StatelessWidget {
  const _TrialBar({required this.ratio, required this.exhausted});

  final double ratio;
  final bool exhausted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _MembershipMetrics.trialBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.profileTrialTrackFill,
        borderRadius: AppRadius.borderPill,
      ),
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: exhausted ? null : AppColors.brandGradient,
            color: exhausted ? AppColors.danger : null,
            borderRadius: AppRadius.borderPill,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 权益
// ---------------------------------------------------------------------------

/// 四项 Pro 权益。Figma L4848-4853。
enum _Benefit {
  analysis(glyph: '∞', label: '职业分析', desc: '不限完整职业分析次数'),
  advisor(glyph: '✦', label: 'AI 职业顾问', desc: '持续获得 AI 洞察与行动建议'),
  capability(glyph: '↗', label: '能力变化', desc: '持续记录职业能力变化'),
  assets(glyph: '◈', label: '职业资产', desc: '完整保存职业成长记录');

  const _Benefit({
    required this.glyph,
    required this.label,
    required this.desc,
  });

  /// 图标位上的字符。
  ///
  /// ⚠️ Figma 在这里用的是**文本字符**（`∞ ✦ ↗ ◈`），不是 SVG。
  /// 因此这里也原样渲染字符，**不套用 D58 的图标近似** ——
  /// 没有需要近似的东西。
  final String glyph;

  final String label;
  final String desc;
}

/// 一张权益卡。Figma L4887-4896。
class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.benefit});

  final _Benefit benefit;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_MembershipMetrics.trialPadding),
      child: Row(
        children: <Widget>[
          Container(
            width: _MembershipMetrics.benefitTile,
            height: _MembershipMetrics.benefitTile,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: AppRadius.borderMd,
            ),
            child: Text(
              benefit.glyph,
              style: AppTypography.profileProBenefitGlyph,
            ),
          ),
          const SizedBox(width: _MembershipMetrics.benefitTileGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  benefit.label,
                  style: AppTypography.profileDetailCardTitle,
                ),
                Text(benefit.desc, style: AppTypography.profileProjectRole),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 额度用尽后的一行统计。
class _TrialStat {
  const _TrialStat({required this.label, required this.value});

  final String label;
  final String value;
}

// ---------------------------------------------------------------------------
// 文案
// ---------------------------------------------------------------------------

/// 会员页文案。
///
/// [heroTitle] / [heroSubtitle] / [footer] / [trialActive] / [trialExhausted]
/// 逐字来自 Figma（L4857 / L4858 / L4901 / L4868 / L4867）。
/// [purchaseHint] 是 **Flutter 侧自拟** —— MVP 无支付（§4 决策 6），
/// 需要一个「点了说明白」的反馈，原型里没有对应文案。归属 **待裁决 · D87**。
abstract final class _MembershipCopy {
  static const String heroTitle = '让职业成长持续发生';
  static const String heroSubtitle = '不限次数分析 · 持续 AI 陪伴 · 完整成长记录';
  static const String trialActive = '当前免费体验';
  static const String trialExhausted = '免费次数已用完';
  static const String footer = '安全支付 · 随时取消 · 不自动续费';
  static const String purchaseHint = 'MVP 阶段暂未接入支付，开通流程待产品侧确认';
}

// ---------------------------------------------------------------------------
// 页面几何
// ---------------------------------------------------------------------------

/// 会员页的内部几何（Figma 逐条内联给出）。
abstract final class _MembershipMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 16;

  // ── Hero（Figma L4851-4858）────────────────────────────────────────
  static const double heroPadding = 24;
  static const double heroCircle = 160;
  static const double heroCircleOffset = -40;
  static const double heroEyebrowGap = 8;
  static const double heroTitleGap = 8;

  // ── 额度卡（Figma L4865-4879）──────────────────────────────────────
  static const double trialPadding = 16;
  static const double trialTitleGap = 8;
  static const double trialBarGap = 8;
  static const double trialBarHeight = 8;
  static const double trialStatsGap = 12;
  static const double trialStatRowPaddingV = 2;

  // ── 权益（Figma L4886-4897）────────────────────────────────────────
  static const double benefitGap = 10;
  static const double benefitTile = 40;
  static const double benefitTileGap = 12;
}
