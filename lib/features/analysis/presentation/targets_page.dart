import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../data/models/analysis_project.dart';
import '../../../data/models/analysis_result.dart';
import '../../../data/models/job.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/analysis_provider.dart';
import 'analysis_loader.dart';

/// 目标岗位列表页（分析二级页，`/analysis/targets`）。
///
/// 真值来源：Figma `AnalysisTargetsPage`（`src/App.tsx` L1824-1862）。
///
/// ```text
/// TopBar「目标岗位」                            L1828
/// 统计行  「你正在关注 N 个岗位」+ 计数胶囊      L1831-1833
/// 岗位卡  #1 渐变排名徽标 / 其余浅蓝徽标
///         + 岗位名 + 「上次 prev% → 现在 match%」
///         + 渐变匹配度 + 变化徽标                L1835-1853
/// 虚线钮  「+ 添加目标岗位 JD」                 L1855-1858
/// ```
///
/// ## 入口说明（与 Figma 一致：已注册、未接线）
///
/// Figma 把 `a-targets` 注册为独立屏（`App.tsx` L5257），但原型里
/// **没有任何** `go('a-targets')` 调用 —— 它是一页「已规划、入口待定」
/// 的页面。Flutter 侧保持同一状态：路由已声明（`/analysis/targets`）、
/// 页面已实现、**不擅自接入口**，避免发明 Figma 里没有的导航。
///
/// ## 数据口径
///
/// 展示**最新一个分析项目**的岗位集合（列表首项，与分析结果页同源）。
/// 岗位卡点击 → `/analysis/job/:jobId`（Figma L1836）。
///
/// ## 「添加目标岗位 JD」按钮
///
/// Figma 里这个按钮**没有 onClick**（纯视觉占位，L1855）。
/// 这里同样只渲染视觉、不绑定行为 —— 添加 JD 的真实入口在
/// 分析 Tab 的「新建分析」表单里，不在这里发明第二条路径。
class AnalysisTargetsPage extends StatefulWidget {
  const AnalysisTargetsPage({super.key});

  @override
  State<AnalysisTargetsPage> createState() => _AnalysisTargetsPageState();
}

class _AnalysisTargetsPageState extends State<AnalysisTargetsPage> {
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

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyTopBar(title: '目标岗位', onBack: () => careerlyBack(context)),
          Expanded(
            child: CareerlyAsyncStateView<List<AnalysisProject>>(
              state: provider.state,
              isEmpty: (List<AnalysisProject> projects) =>
                  projects.isEmpty || projects.first.jobs.isEmpty,
              onRetry: provider.load,
              loadingMessage: '正在读取目标岗位',
              emptyTitle: '还没有目标岗位',
              emptyMessage: '添加目标岗位 JD 并完成一次分析后，这里会展示你关注的岗位。',
              builder: (BuildContext context, List<AnalysisProject> projects) =>
                  _TargetsBody(project: projects.first),
            ),
          ),
        ],
      ),
    );
  }
}

/// 列表正文。
class _TargetsBody extends StatelessWidget {
  const _TargetsBody({required this.project});

  final AnalysisProject project;

  @override
  Widget build(BuildContext context) {
    final AnalysisResult? latest = project.latestResult;
    final AnalysisResult? previous = project.results.length >= 2
        ? project.results[project.results.length - 2]
        : null;
    final Map<String, Job> jobs = <String, Job>{
      for (final Job job in project.jobs) job.id: job,
    };
    final Map<String, int> previousScores = <String, int>{
      for (final JobMatch m in previous?.matches ?? const <JobMatch>[])
        m.jobId: m.score,
    };
    final List<JobMatch> matches = List<JobMatch>.of(
      latest?.matches ?? const <JobMatch>[],
    )..sort((JobMatch a, JobMatch b) => a.rank.compareTo(b.rank));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _TargetsMetrics.inset,
        0,
        _TargetsMetrics.inset,
        _TargetsMetrics.bottom,
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '你正在关注 ${matches.length} 个岗位',
              style: AppTypography.bodySmall.copyWith(fontSize: 13),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlueSurface,
                borderRadius: AppRadius.borderPill,
              ),
              child: Text(
                '${matches.length} 个',
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _TargetsMetrics.gap),
        for (int i = 0; i < matches.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: _TargetsMetrics.cardGap),
          _TargetCard(
            match: matches[i],
            job: jobs[matches[i].jobId],
            previousScore: previousScores[matches[i].jobId],
            onTap: jobs[matches[i].jobId] == null
                ? null
                : () => context.push(AppRoutes.analysisJob(matches[i].jobId)),
          ),
        ],
        const SizedBox(height: _TargetsMetrics.gap),
        const _DashedAddButton(),
      ],
    );
  }
}

/// 岗位卡。Figma L1837-1852。
class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.match,
    required this.job,
    required this.previousScore,
    this.onTap,
  });

  final JobMatch match;
  final Job? job;
  final int? previousScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isFirst = match.rank == 1;
    final int delta = previousScore == null ? 0 : match.score - previousScore!;

    return CareerlyCard(
      variant: CareerlyCardVariant.glass,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          // 排名徽标：40×40 / r12；#1 渐变底白字，其余浅蓝底蓝字。
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isFirst ? AppColors.brandGradient : null,
              color: isFirst ? null : AppColors.primaryBlueSurfaceSubtle,
              borderRadius: AppRadius.borderXs,
            ),
            child: Text(
              '#${match.rank}',
              style: AppTypography.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isFirst ? Colors.white : AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  job?.title ?? '目标岗位',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (previousScore != null)
                  Text(
                    '上次 $previousScore% → 现在 ${match.score}%',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // 匹配度：20px 粗体渐变文字（Figma `gradText`）。
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) =>
                    AppColors.homeMatchTextGradient.createShader(bounds),
                child: Text(
                  '${match.score}%',
                  style: AppTypography.numeric.copyWith(
                    fontSize: 20,
                    height: 1,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _TrendBadge(delta: delta),
            ],
          ),
        ],
      ),
    );
  }
}

/// 变化徽标。Figma `TrendBadge`（L134-138）：
/// `0` → 中性「—」；正 → 绿「↑ +N%」；负 → 红「↓ N%」。
class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final bool positive = delta > 0;
    final bool negative = delta < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: positive
            ? AppColors.successSurface
            : negative
            ? AppColors.dangerSurface
            : AppColors.neutralSurface,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(
        positive
            ? '↑ +$delta%'
            : negative
            ? '↓ $delta%'
            : '—',
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: positive
              ? AppColors.success
              : negative
              ? AppColors.danger
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// 虚线「添加目标岗位 JD」按钮。Figma L1855-1858。
///
/// ⚠️ Figma 里它**没有 onClick** —— 纯视觉占位。
/// 这里同样不绑定行为：添加 JD 的真实入口在分析 Tab 的
/// 「新建分析」表单，不在这里发明第二条路径（见类顶说明）。
class _DashedAddButton extends StatelessWidget {
  const _DashedAddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        // Figma：border 2px dashed rgba(79,126,245,0.30) +
        // bg rgba(79,126,245,0.04)。Flutter 无原生虚线描边，
        // 用 CustomPainter 画（与分析页 _DashedAddButton 同款做法）。
        color: const Color(0x0A4F7EF5),
        borderRadius: AppRadius.borderMd,
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '+',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(width: 10),
            Text(
              '添加目标岗位 JD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 圆角虚线描边（2px · rgba(79,126,245,0.30) · 6/4 虚线节律）。
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0x4D4F7EF5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadius.md),
    );
    final Path path = Path()..addRRect(rrect);
    const double dashWidth = 6;
    const double dashGap = 4;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashWidth).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 目标岗位页的内部几何（Figma 逐条内联给出）。
abstract final class _TargetsMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 16;
  static const double cardGap = 12;
}
