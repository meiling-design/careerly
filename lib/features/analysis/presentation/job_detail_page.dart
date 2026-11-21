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

/// 岗位详情页（分析二级页，`/analysis/job/:jobId`）。
///
/// 真值来源：Figma `AnalysisJobDetailPage`（`src/App.tsx` L2354-2440）。
///
/// ```text
/// TopBar（标题 = 岗位名）                      L2363
/// Hero  品牌渐变 + 装饰圆 + 排名眉标 + Gap + 匹配度大数字
///       + 「较上次」徽标 + 「来自 …」           L2366-2386
/// Card  为什么匹配？（绿勾行）                  L2389-2399
/// Card  ✅ 能力优势（名称 + 分数 + 高匹配胶囊）  L2402-2416
/// Card  △ 成长空间（名称 + 等级胶囊）           L2419-2431
/// 底部  「查看 Gap →」+「问问 AI」双按钮        L2433-2436
/// ```
///
/// ## 数据来源
///
/// 页面**不读 Mock 夹具**：通过 [AnalysisProvider] 的项目列表
/// 按 `jobId` 查找（[findAnalysisJobEntry]）。演示态数据
/// （`strengthScores` / `gapDetails` / `reasons`）挂在 `JobMatch` 上，
/// 真实分析接入后由匹配计算产出，页面不需要改。
///
/// ## 找不到 jobId 时
///
/// 走 Empty 态，文案是「找不到这个岗位」——深链 id 失效与
/// 「还没有岗位」是两件事，不共用一句话（同工作详情页处置）。
class AnalysisJobDetailPage extends StatefulWidget {
  const AnalysisJobDetailPage({
    super.key,
    required this.jobId,
    this.projectId,
    this.resultId,
  });

  /// 路由参数里的岗位 id（`/analysis/job/:jobId`）。
  final String jobId;

  /// 来源分析项目 id（可选，来自结果页的 `?projectId=`）。
  ///
  /// 同一岗位可以出现在多个项目里，只有它 + [resultId] 才能保证
  /// 详情页展示的是**用户点进来的那一次分析**，而不是最新一次。
  final String? projectId;

  /// 来源分析结果 id（可选，来自结果页的 `?resultId=`）。
  final String? resultId;

  @override
  State<AnalysisJobDetailPage> createState() => _AnalysisJobDetailPageState();
}

class _AnalysisJobDetailPageState extends State<AnalysisJobDetailPage> {
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
          CareerlyTopBar(
            // P1-02：标题优先取本次分析的岗位快照，历史记录不随岗位改名漂移。
            title: entry?.snapshot?.title.isNotEmpty == true
                ? entry!.snapshot!.title
                : (entry?.job.title ?? '岗位详情'),
            onBack: () => careerlyBack(context),
          ),
          Expanded(
            child: CareerlyAsyncStateView<List<AnalysisProject>>(
              state: provider.state,
              isEmpty: (List<AnalysisProject> projects) => entry == null,
              onRetry: provider.load,
              loadingMessage: '正在读取岗位详情',
              emptyTitle: '找不到这个岗位',
              emptyMessage: '这个岗位可能已被移除，或链接已失效',
              builder: (BuildContext context, List<AnalysisProject> projects) =>
                  _JobDetailBody(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

/// 详情正文。
class _JobDetailBody extends StatelessWidget {
  const _JobDetailBody({required this.entry});

  /// 查不到时为 `null` —— 理论上不会走到（外层已判过 empty），
  /// 这里渲染空盒子而不是抛异常。
  final AnalysisJobEntry? entry;

  @override
  Widget build(BuildContext context) {
    final AnalysisJobEntry? item = entry;
    if (item == null) return const SizedBox.shrink();
    final JobMatch match = item.match;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _JobDetailMetrics.inset,
        0,
        _JobDetailMetrics.inset,
        _JobDetailMetrics.bottom,
      ),
      children: <Widget>[
        _JobHero(entry: item),
        const SizedBox(height: _JobDetailMetrics.gap),
        _JobDescriptionCard(entry: item),
        const SizedBox(height: _JobDetailMetrics.gap),
        if (match.reasons.isNotEmpty) ...<Widget>[
          _WhyMatchCard(reasons: match.reasons),
          const SizedBox(height: _JobDetailMetrics.gap),
        ],
        if (match.strengthScores.isNotEmpty) ...<Widget>[
          _StrengthsCard(scores: match.strengthScores),
          const SizedBox(height: _JobDetailMetrics.gap),
        ],
        if (match.gapDetails.isNotEmpty) ...<Widget>[
          _GapsCard(details: match.gapDetails, gapPercent: item.gapPercent),
          const SizedBox(height: _JobDetailMetrics.gap),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: CareerlyButton(
                label: '查看 Gap →',
                onPressed: () => context.push(
                  AppRoutes.analysisGap(
                    item.job.id,
                    projectId: item.project.id,
                    resultId: item.result.id,
                  ),
                ),
              ),
            ),
            const SizedBox(width: _JobDetailMetrics.buttonGap),
            Expanded(
              child: CareerlyButton(
                label: '问问 AI',
                variant: CareerlyButtonVariant.secondary,
                onPressed: () => context.go(AppRoutes.ai),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Hero：品牌渐变 + 右上装饰圆 + 排名眉标 + 匹配度大数字。
/// Figma L2366-2386（结构与结果页 Hero 同族，但内部布局不同，不合并）。
class _JobHero extends StatelessWidget {
  const _JobHero({required this.entry});

  final AnalysisJobEntry entry;

  @override
  Widget build(BuildContext context) {
    final JobMatch match = entry.match;
    final int? delta = entry.delta;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.borderXl,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x474F7EF5), // rgba(79,126,245,0.28)
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            top: _JobDetailMetrics.heroCircleOffset,
            right: _JobDetailMetrics.heroCircleOffset,
            child: _HeroCircle(),
          ),
          Padding(
            padding: const EdgeInsets.all(_JobDetailMetrics.heroPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '岗位详情 · 排名 #${match.rank}',
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: const Color(0x99FFFFFF), // white/60
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // 快照里的岗位名才是这次分析实际使用的名称。
                  entry.snapshot?.title.isNotEmpty == true
                      ? entry.snapshot!.title
                      : entry.job.title,
                  style: AppTypography.title.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gap ${entry.gapPercent}%',
                  style: AppTypography.caption.copyWith(
                    fontSize: 12,
                    color: const Color(0x8CFFFFFF), // white/55
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: <Widget>[
                            Text(
                              '${match.score}',
                              style: AppTypography.numeric.copyWith(
                                fontSize: 50,
                                height: 1,
                                letterSpacing: 0,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '%',
                              style: AppTypography.numeric.copyWith(
                                fontSize: 20,
                                letterSpacing: 0,
                                color: const Color(0xCCFFFFFF), // white/80
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '匹配度',
                          style: AppTypography.caption.copyWith(
                            fontSize: 12,
                            color: const Color(0x8CFFFFFF), // white/55
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (delta != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.onBrandSurface,
                                  borderRadius: AppRadius.borderPill,
                                ),
                                child: Text(
                                  delta > 0 ? '较上次 ↑ +$delta%' : '较上次 —',
                                  style: AppTypography.label.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            if (entry.snapshot?.sourceUrl?.isNotEmpty == true) ...<Widget>[
                              const SizedBox(height: 6),
                              Text(
                                '来自 ${entry.snapshot!.sourceUrl}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11,
                                  color: const Color(0x8CFFFFFF), // white/55
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero 右上角装饰圆（白 0.08，144px，Figma `-top-8 -right-8 w-36 h-36`）。
class _HeroCircle extends StatelessWidget {
  const _HeroCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _JobDetailMetrics.heroCircle,
      height: _JobDetailMetrics.heroCircle,
      decoration: const BoxDecoration(
        color: AppColors.resultHeroDecoration,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 「岗位原文」—— 本次分析实际使用的 JD 快照（P1-02）。
///
/// - 默认折叠，只露出前几行；展开 / 收起保留原文段落与换行；
/// - 来源行说明这份 JD 是粘贴、链接抓取还是历史岗位导入；
/// - 历史数据没有快照时显示**明确的缺失态**，绝不拿当前岗位的 JD 冒充。
class _JobDescriptionCard extends StatefulWidget {
  const _JobDescriptionCard({required this.entry});

  final AnalysisJobEntry entry;

  @override
  State<_JobDescriptionCard> createState() => _JobDescriptionCardState();
}

class _JobDescriptionCardState extends State<_JobDescriptionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final JobSnapshot? snapshot = widget.entry.snapshot;
    final bool hasText =
        snapshot != null && snapshot.available && snapshot.rawJd.trim().isNotEmpty;

    return _DetailCard(
      title: '岗位原文',
      titleGap: 10,
      child: !hasText
          ? Text(
              '这次分析没有保存岗位原文（历史数据），无法还原当时的 JD。',
              style: AppTypography.bodySmall.copyWith(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _JobSourceLine(snapshot: snapshot),
                const SizedBox(height: 10),
                Text(
                  snapshot.rawJd,
                  maxLines: _expanded ? null : 6,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
                if (_needsToggle(snapshot.rawJd)) ...<Widget>[
                  const SizedBox(height: 8),
                  CareerlyPressFeedback(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _expanded ? '收起原文' : '展开全文',
                          style: AppTypography.label.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  static bool _needsToggle(String rawJd) {
    if (rawJd.length > 180) return true;
    return '\n'.allMatches(rawJd).length >= 5;
  }
}

/// 岗位来源行：导入方式 +（链接导入时的）URL + 快照时间。
class _JobSourceLine extends StatelessWidget {
  const _JobSourceLine({required this.snapshot});

  final JobSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final JobSnapshot? snap = snapshot;
    if (snap == null) return const SizedBox.shrink();
    final String source = snap.source ?? snap.importMethod ?? '';
    final String label = switch (source) {
      'url' => '链接导入',
      'history' => '历史岗位',
      'paste' => '粘贴导入',
      _ => '岗位导入',
    };
    final List<String> parts = <String>[
      '来源：$label',
      if (snap.sourceUrl?.isNotEmpty == true) snap.sourceUrl!,
      if (snap.capturedAt != null) '快照于 ${_formatDate(snap.capturedAt!)}',
    ];
    return Text(
      parts.join(' · '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.caption.copyWith(
        fontSize: 11,
        color: AppColors.textTertiary,
      ),
    );
  }

  static String _formatDate(DateTime at) {
    final DateTime local = at.toLocal();
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    return '${local.year}.$month.$day';
  }
}

/// 「为什么匹配？」—— 绿勾行列表。Figma L2389-2399。
class _WhyMatchCard extends StatelessWidget {
  const _WhyMatchCard({required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: '为什么匹配？',
      titleGap: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final String reason in reasons)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.successSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 10,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reason,
                      style: AppTypography.body.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 「✅ 能力优势」—— 名称 + 分数 + 「高匹配」胶囊，行间分隔线。
/// Figma L2402-2416。
class _StrengthsCard extends StatelessWidget {
  const _StrengthsCard({required this.scores});

  final List<StrengthScore> scores;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: '✅ 能力优势',
      titleGap: 4,
      child: _DividedRows(
        rows: <Widget>[
          for (final StrengthScore score in scores)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      score.name,
                      style: AppTypography.body.copyWith(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${score.score}',
                    style: AppTypography.bodyStrong.copyWith(fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: AppRadius.borderPill,
                    ),
                    child: Text(
                      '高匹配',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 「△ 成长空间」—— 名称 + 等级胶囊，行间分隔线。Figma L2419-2431。
///
/// 数据源是 `JobMatch.gapDetails`（取 Figma Gap 页那份最完整的），
/// 这里只渲染 `name` + `level` —— 与原型一致，不在这里编造数值。
class _GapsCard extends StatelessWidget {
  const _GapsCard({required this.details, required this.gapPercent});

  final List<GapDetail> details;
  final int gapPercent;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: '△ 成长空间',
      titleGap: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '当前 Gap：$gapPercent%',
            style: AppTypography.bodySmall.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          _DividedRows(
            rows: <Widget>[
              for (final GapDetail detail in details)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          detail.name,
                          style: AppTypography.body.copyWith(fontSize: 14),
                        ),
                      ),
                      _GapLevelPill(level: detail.level ?? '关键 Gap'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gap 等级胶囊。「关键 Gap」橙底橙字（Figma L2426），其余中性灰。
class _GapLevelPill extends StatelessWidget {
  const _GapLevelPill({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final bool critical = level == '关键 Gap';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: critical ? AppColors.warningSurface : AppColors.neutralSurface,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(
        level,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: critical ? AppColors.warning : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// 信息卡：GlassSurface + 小标题 + 内容。
/// 与工作详情页同一处置：不新建共享组件（CLAUDE.md §8.4）。
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.titleGap,
    required this.child,
  });

  final String title;
  final double titleGap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_JobDetailMetrics.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: AppTypography.bodyStrong.copyWith(fontSize: 15)),
          SizedBox(height: titleGap),
          child,
        ],
      ),
    );
  }
}

/// 竖排的行 + 行间 1px 分隔线（最后一行后无分隔线）。
class _DividedRows extends StatelessWidget {
  const _DividedRows({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < rows.length; i++) ...<Widget>[
          rows[i],
          if (i != rows.length - 1)
            const Divider(height: 1, thickness: 1, color: AppColors.divider),
        ],
      ],
    );
  }
}

/// 岗位详情页的内部几何（Figma 逐条内联给出）。
abstract final class _JobDetailMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 16;

  // ── Hero（Figma L2366-2386）───────────────────────────────────────
  static const double heroPadding = 20;
  static const double heroCircle = 144;
  static const double heroCircleOffset = -32;

  // ── 信息卡与底部按钮 ───────────────────────────────────────────────
  static const double cardPadding = 20;
  static const double buttonGap = 12;
}
