import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../data/models/analysis_project.dart';
import '../../../data/models/analysis_result.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/analysis_provider.dart';
import 'analysis_loader.dart';

/// 成长空间（Gap）页（分析二级页，`/analysis/gap/:jobId`）。
///
/// 真值来源：Figma `AnalysisGapPage`（`src/App.tsx` L2442-2496）。
///
/// ```text
/// TopBar「成长空间」                            L2452
/// 橙色横幅  目标岗位 / 岗位名 / 当前 Gap         L2454-2458
/// 引导语    「Gap 不是缺点，而是成长空间」        L2460-2462
/// Gap 卡   名称 + 等级胶囊 + 三格数值（你的能力 /
///          岗位要求 / Gap）+ 差距原因 + 行动建议 L2464-2490
/// 底部     「和 AI 深入讨论 →」                 L2492
/// ```
///
/// ## 数据来源
///
/// 与岗位详情页同一查找入口（[findAnalysisJobEntry]），
/// 渲染 `JobMatch.gapDetails` 的完整字段（yours / target / why /
/// actions）。这些数值目前是 Figma 演示值（见 `GapDetail` 类顶声明），
/// 真实能力模型接入后由匹配计算产出，页面不需要改。
///
/// ## Figma 原型自身矛盾的处置
///
/// 岗位详情页的「成长空间」列表与 Gap 页卡片**对不上**（详见
/// `demo_analysis_fixture.dart` 类顶）。已裁决：以 Gap 页这份为唯一
/// 数据源，本页渲染其完整内容，不补齐缺失的第 3 项。
class AnalysisGapPage extends StatefulWidget {
  const AnalysisGapPage({
    super.key,
    required this.jobId,
    this.projectId,
    this.resultId,
  });

  /// 路由参数里的岗位 id（`/analysis/gap/:jobId`）。
  final String jobId;

  /// 来源分析项目 / 结果 id（与岗位详情页同一套来源上下文）。
  ///
  /// Gap 页必须读「打开它的那一次分析结果」，不能读最新一次。
  final String? projectId;
  final String? resultId;

  @override
  State<AnalysisGapPage> createState() => _AnalysisGapPageState();
}

class _AnalysisGapPageState extends State<AnalysisGapPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ensureAnalysisProjectsLoaded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AnalysisProvider provider = context.watch<AnalysisProvider>();
    final AnalysisJobEntry? entry = findAnalysisJobEntry(
      provider.data ?? const <AnalysisProject>[],
      widget.jobId,
      projectId: widget.projectId,
      resultId: widget.resultId,
    );

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyTopBar(title: '成长空间', onBack: () => careerlyBack(context)),
          Expanded(
            child: CareerlyAsyncStateView<List<AnalysisProject>>(
              state: provider.state,
              isEmpty: (List<AnalysisProject> projects) => entry == null,
              onRetry: provider.load,
              loadingMessage: '正在读取成长空间',
              emptyTitle: '找不到这个岗位',
              emptyMessage: '这个岗位可能已被移除，或链接已失效',
              builder: (BuildContext context, List<AnalysisProject> projects) =>
                  _GapBody(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gap 页正文。
class _GapBody extends StatelessWidget {
  const _GapBody({required this.entry});

  final AnalysisJobEntry? entry;

  @override
  Widget build(BuildContext context) {
    final AnalysisJobEntry? item = entry;
    if (item == null) return const SizedBox.shrink();
    final List<GapDetail> details = item.match.gapDetails;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _GapMetrics.inset,
        0,
        _GapMetrics.inset,
        _GapMetrics.bottom,
      ),
      children: <Widget>[
        _TargetBanner(entry: item),
        const SizedBox(height: _GapMetrics.gap),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Gap 不是「缺点」，而是你当前能力与目标之间的成长空间。',
            style: AppTypography.bodySmall.copyWith(fontSize: 13, height: 1.6),
          ),
        ),
        const SizedBox(height: _GapMetrics.gap),
        for (int i = 0; i < details.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: _GapMetrics.gap),
          _GapCard(detail: details[i]),
        ],
        const SizedBox(height: _GapMetrics.gap),
        CareerlyButton(
          label: '和 AI 深入讨论 →',
          onPressed: () => context.go(AppRoutes.ai),
        ),
      ],
    );
  }
}

/// 顶部橙色横幅：目标岗位 + 当前 Gap。Figma L2454-2458。
class _TargetBanner extends StatelessWidget {
  const _TargetBanner({required this.entry});

  final AnalysisJobEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_GapMetrics.bannerPadding),
      decoration: BoxDecoration(
        // Figma：bg rgba(255,149,0,0.08) + border rgba(255,149,0,0.18)。
        color: const Color(0x14FF9500),
        border: Border.all(color: const Color(0x2EFF9500)),
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '目标岗位',
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            entry.job.title,
            style: AppTypography.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '当前 Gap：${entry.gapPercent}%',
            style: AppTypography.bodySmall.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// 单张 Gap 卡。Figma L2464-2490。
class _GapCard extends StatelessWidget {
  const _GapCard({required this.detail});

  final GapDetail detail;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_GapMetrics.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  detail.name,
                  style: AppTypography.bodyStrong.copyWith(fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              // Figma 里等级胶囊恒为「关键 Gap」橙色（L2468）。
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: AppRadius.borderPill,
                ),
                child: Text(
                  detail.level ?? '关键 Gap',
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _StatBox(value: detail.yours, label: '你的能力'),
              const SizedBox(width: 12),
              _StatBox(value: detail.target, label: '岗位要求'),
              const SizedBox(width: 12),
              _StatBox(value: detail.gap, label: 'Gap', highlight: true),
            ],
          ),
          if (detail.why != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              detail.why!,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ],
          if (detail.actions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: AppColors.divider),
            const SizedBox(height: 12),
            Text(
              '如何缩小？',
              style: AppTypography.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < detail.actions.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          detail.actions[i],
                          style: AppTypography.body.copyWith(
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
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

/// 三格数值里的一格。Figma L2471-2476：
/// 浅蓝底（rgba(79,126,245,0.06)）+ 18px 粗体数值 + 10px 标签。
/// 「你的能力 / 岗位要求」用渐变文字（`gradText`），「Gap」用橙色。
class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final int? value;
  final String label;

  /// 是否为 Gap 格（橙色数值）。
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = AppTypography.numeric.copyWith(
      fontSize: 18,
      letterSpacing: 0,
      color: highlight ? AppColors.warning : Colors.white,
    );

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.primaryBlueSurfaceSubtle,
          borderRadius: AppRadius.borderXs,
        ),
        child: Column(
          children: <Widget>[
            if (highlight)
              Text(value == null ? '—' : '$value', style: valueStyle)
            else
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) =>
                    AppColors.homeMatchTextGradient.createShader(bounds),
                child: Text(value == null ? '—' : '$value', style: valueStyle),
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gap 页的内部几何（Figma 逐条内联给出）。
abstract final class _GapMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 16;

  static const double bannerPadding = 16;
  static const double cardPadding = 20;
}
