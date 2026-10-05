import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/job.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../state/analysis_provider.dart';

/// 弹出「历史岗位」选择列表，返回用户选中的岗位；取消 / 点空白返回 `null`。
///
/// 依据 PRD §9.3「从历史岗位中添加」与 `careerly-analysis-structure.md`
/// §七「历史岗位」：
///
/// ```text
/// 添加岗位 → 提供：粘贴 JD / 岗位 URL / 从历史岗位选择
/// 历史岗位展示：  AI 产品经理   2026.09.01 分析过
/// 选择后直接加入当前分析。
/// ```
///
/// 数据来源：`GET /api/v1/analysis/jobs`（历史岗位库 —— 从本项目移除岗位
/// **不删除**岗位记录，见 `work_agent/app/careerly/router.py`）。
///
/// ## ⚠️ 这个弹层在 Figma 里**没有**
///
/// 设计稿的「添加岗位」是**单按钮 + 三项选择菜单**
/// （`careerly-analysis-structure.md` §六），不存在与「粘贴 JD」
/// 「粘贴岗位 URL」并列的第三颗虚线按钮。因此：
///
/// - **入口形态**（第三颗虚线按钮）与**弹层形态**（Bottom Sheet）
///   均为 2026-10-05 产品侧裁决，不是从 Figma 取的值；
/// - 第三颗按钮的两个色值因 Figma 无依据，登记为
///   **暂定值 · 待裁决 D117**（见 `app_colors.dart` 同名注释）；
/// - 本文件内部的间距一律取既有 `AppSpacing` 刻度，**不新造数值**
///   —— 没有 Figma 值可转写时，沿用系统既有的那一套。
///
/// ## 职责边界
///
/// 本弹层**只负责选择**，不发起分析、不扣额度、不建任务
/// （`CLAUDE.md` §5.2：只有「开始分析」扣）。回填表单与后续动作留在页面里
/// —— 同 `resume_import_sheet.dart` 的分工。
Future<Job?> showJobLibrarySheet(BuildContext context) {
  return CareerlyBottomSheet.show<Job>(
    context,
    // 「操作类」面板：与简历分享 / 导入同档（半透明面板 + 重 scrim）。
    tone: CareerlyBottomSheetTone.action,
    child: const _JobLibrarySheet(),
  );
}

/// 弹层内容。读取历史岗位库并渲染四态。
class _JobLibrarySheet extends StatelessWidget {
  const _JobLibrarySheet();

  @override
  Widget build(BuildContext context) {
    // 弹层由 `showGeneralDialog` push 到**根** Navigator，但仍在
    // `MaterialApp` 之下 —— Provider 挂在更外层，故 `watch` 有效。
    final AnalysisProvider provider = context.watch<AnalysisProvider>();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.mdLg,
        0,
        AppSpacing.mdLg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('历史岗位', style: AppTypography.analysisSheetTitle),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            '选一个分析过的岗位直接加入本次分析，不必重新粘贴 JD。',
            style: AppTypography.analysisSheetBody,
          ),
          const SizedBox(height: AppSpacing.md),
          // ⚠️ 列表必须有一个**有界高度**。
          //
          // `CareerlyAsyncStateView` 的四态外壳以 `Center` 为根，拿到无界
          // 高度就会撑满整个弹层（弹层自身是自适应高度，见
          // `careerly_bottom_sheet.dart` 的「内容高度」一节）。
          //
          // 两层分工：`Flexible` 负责「剩余空间不够时压缩」，
          // `ConstrainedBox` 负责「空间充足时不被撑满」。
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: _JobLibraryMetrics.listMaxHeight,
              ),
              child: CareerlyAsyncStateView<List<Job>>(
                state: provider.jobLibraryState,
                isEmpty: (List<Job> jobs) => jobs.isEmpty,
                onRetry: provider.loadJobLibrary,
                loadingMessage: '正在读取历史岗位…',
                emptyTitle: '还没有历史岗位',
                // 空库是**真实的**空，不是故障：第一次用的用户必然会看到
                // 它（Mock 也返回空，见 `mock_analysis_repository.dart`）。
                emptyMessage: '分析过一个岗位之后它就会出现在这里，下次可以直接复用。',
                builder: (BuildContext context, List<Job> jobs) =>
                    _JobList(jobs: jobs),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CancelButton(onTap: () => Navigator.of(context).maybePop()),
        ],
      ),
    );
  }
}

/// 历史岗位行列表。
///
/// ⚠️ `shrinkWrap: true` —— 短列表按内容高度收拢，否则会被弹层拉到
/// `_JobLibraryMetrics.listMaxHeight` 那么高、留下一大片空白；
/// 长列表超过上限时由 [ListView] 自己滚动
/// （`CareerlyBottomSheet` **不代为插入滚动视图**，见其组件文档）。
class _JobList extends StatelessWidget {
  const _JobList({required this.jobs});

  final List<Job> jobs;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: jobs.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(
        height: _JobLibraryMetrics.dividerThickness,
        thickness: _JobLibraryMetrics.dividerThickness,
        color: AppColors.rowDivider,
      ),
      itemBuilder: (BuildContext context, int index) =>
          _JobRow(job: jobs[index]),
    );
  }
}

/// 一行历史岗位：岗位名（公司 · 岗位）+ 分析日期 + 右侧箭头。
class _JobRow extends StatelessWidget {
  const _JobRow({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    // 这里的 `context` 来自**弹层内部**的子树，解析到的是弹层所在的
    // 根 Navigator —— 可以直接 pop。⚠️ 若在外层页面里闭包捕获页面
    // `context`，那会解析到分支 Navigator，pop 掉的是页面而不是弹层
    //（`back_navigation.dart` 的 `CareerlyBackGuard.confirm` 有同款警告）。
    final String? analyzed = _analyzedLabel(job.createdAt);

    return CareerlyPressFeedback(
      onTap: () => Navigator.of(context).pop(job),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    // `Job.displayName` = 公司 · 岗位（公司为空时只有岗位名）。
                    job.displayName,
                    style: AppTypography.analysisSheetOptionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (analyzed != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(analyzed, style: AppTypography.analysisSheetOptionDesc),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: _JobLibraryMetrics.chevron,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 「YYYY.MM.DD 分析过」。`createdAt` 缺失时返回 `null`。
///
/// **不回落**到「最近」「今天」之类的相对时间 —— 那是编造
///（`CLAUDE.md` §7：不编造产品数据）。取不到就整行不显示。
String? _analyzedLabel(DateTime? createdAt) {
  if (createdAt == null) return null;
  final DateTime local = createdAt.toLocal();
  return '${local.year}.${_twoDigits(local.month)}.${_twoDigits(local.day)} 分析过';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// 「取消」—— 深色胶囊，与其余操作类弹层同款
///（`resume_import_sheet` / `resume_share_sheet`）。
///
/// 色值复用 [AppColors.resumeSheetCancelFill]：它虽以 `resume` 命名，
/// 但注释已载明是「暗色胶囊（87% 透明度，透出玻璃底）」这一**交互语言**，
/// 不是简历专属色。改 Token 一处 → 三个弹层一起变。
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _JobLibraryMetrics.cancelHeight,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.resumeSheetCancelFill,
          borderRadius: AppRadius.borderPill,
        ),
        child: const Text('取消', style: AppTypography.analysisSheetPrimary),
      ),
    );
  }
}

/// 弹层内部几何。
///
/// 间距一律取 `AppSpacing` 既有刻度，这里只放**刻度之外的工程取值**
/// （控件尺寸 / 高度上限）。⚠️ 全部为工程取值，**非设计值** ——
/// Figma 里没有这个弹层（见 [showJobLibrarySheet] 的说明）。
abstract final class _JobLibraryMetrics {
  /// 面板高度上限（工程兜底）。
  ///
  /// 取值理由：连同标题 / 说明 / 取消钮，整块内容要能装进
  /// `CareerlyBottomSheet` 的 `0.9 × 屏高` 上限而不触发溢出
  /// —— 按 600 逻辑像素高的视口算，内容合计约 460 < 540。
  static const double listMaxHeight = 280;

  /// 行内右侧箭头。
  static const double chevron = 18;

  /// 「取消」胶囊高度（与其余两个操作类弹层一致）。
  static const double cancelHeight = 48;

  /// 行分隔线粗细。Figma 清单行用的是 `1px`（见 [AppColors.rowDivider]）。
  static const double dividerThickness = 1;
}
