import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/resume_provider.dart';
import 'widgets/resume_preview_sections.dart';
import 'widgets/resume_share_sheet.dart';

/// 简历详情 —— 「我的简历」→ 查看详情。
///
/// 真值来源：Figma `ResumeDetailPage`（`src/App.tsx` L4599-4793）。
///
/// ```text
/// 顶栏   Resume {version} + 右侧分享钮
/// 信息行 「当前简历」胶囊 + 更新于 {date}      （右端「最高匹配」见下）
/// 分段   PDF 预览 / 原始内容
/// 内容   PDF 卡（渐变头 + 分段 + 页脚）/ 原始内容的玻璃卡
/// 底栏   「导出 PDF」+「编辑简历」
/// ```
///
/// ## ⚠️ 「最高匹配」没有渲染 —— 数据层没有这个字段
///
/// Figma 的信息行右侧是 `最高匹配 {match}%`（L4611-4615），取值来自原型的
/// `allVersions[version].match`。而 [ResumeVersion] **没有匹配度字段**，
/// 后端 `GET /api/v1/resume` 返回的是**单一基线**，也没有按版本存过匹配度
/// —— 匹配度是**分析**的产物（PRD §5.3），不是简历版本的属性。
///
/// 这里**不编一个数字**（`CLAUDE.md` §7 明确点名「匹配度 86%」这类假数据），
/// 因此该行右侧整块不渲染。要补上它，先要在数据层定义「简历版本的匹配度」
/// 从哪来 —— 属产品侧裁决，已登记 `docs/05_progress/TODO.md` §3.1。
///
/// ## ⚠️ 「原始内容」不是简历的原始文本
///
/// Figma 的原始内容是**同一批分段的结构化排布**（`RESUME_SECTIONS`
/// 换个卡样式重画），并不是把简历原文贴出来。因此这里两页签读的是
/// **同一份数据**、不同的视觉层次，没有「原文」字段 ——
/// 后端 `GET /resume` 的 `text` 字段（简历原文）因此**没有进模型**。
///
/// ## 未接线的两处（Figma 有入口，App 里没有去向）
///
/// | 入口 | 状态 |
/// |---|---|
/// | 「编辑简历」 | 无编辑流程，也无独立路由 → 如实提示「尚未接入」 |
/// | 分享 / 导出弹层的三个选项 | 无分享 / 导出能力（不新增依赖）→ 同上 |
///
/// 两者都**不是**视觉问题，是功能缺口，已登记待裁决清单。
class ResumeDetailPage extends StatefulWidget {
  const ResumeDetailPage({super.key, required this.versionId});

  /// 要展示的简历版本 id（路由参数）。
  final String versionId;

  @override
  State<ResumeDetailPage> createState() => _ResumeDetailPageState();
}

class _ResumeDetailPageState extends State<ResumeDetailPage> {
  /// 当前页签：[_Tab.pdf] 或 [_Tab.raw]。
  _Tab _tab = _Tab.pdf;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ResumeProvider provider = context.read<ResumeProvider>();
      if (provider.data == null && !provider.isLoading) {
        provider.load();
      }
    });
  }

  /// 按 id 找版本；找不到时退回当前版本（深链容错 —— 版本可能已被删除）。
  ResumeVersion? _versionOf(ResumeProfile? profile) {
    if (profile == null) return null;
    for (final ResumeVersion version in profile.versions) {
      if (version.id == widget.versionId) return version;
    }
    return profile.currentVersion;
  }

  @override
  Widget build(BuildContext context) {
    final ResumeProvider provider = context.watch<ResumeProvider>();
    final ResumeVersion? version = _versionOf(provider.data);

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyTopBar(
            title: version?.label ?? '简历详情',
            onBack: () => careerlyBack(context),
            trailing: version == null
                ? null
                : _TopBarShareButton(
                    onTap: () => showResumeShareSheet(context),
                  ),
          ),
          Expanded(
            child: CareerlyAsyncStateView<ResumeProfile>(
              state: provider.state,
              isEmpty: (ResumeProfile profile) => profile.isEmpty,
              onRetry: provider.load,
              loadingMessage: '正在读取简历',
              emptyTitle: '还没有简历',
              emptyMessage: '提交第一份简历后，这里会展示它的完整内容',
              builder: (BuildContext context, ResumeProfile profile) {
                final ResumeVersion? resolved = _versionOf(profile);
                if (resolved == null) return const SizedBox.shrink();
                return _DetailBody(
                  profile: profile,
                  version: resolved,
                  tab: _tab,
                  onTabChanged: (_Tab value) => setState(() => _tab = value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 页签取值。
enum _Tab { pdf, raw }

/// 信息行 + 页签 + 内容 + 底栏。
class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.profile,
    required this.version,
    required this.tab,
    required this.onTabChanged,
  });

  final ResumeProfile profile;
  final ResumeVersion version;
  final _Tab tab;
  final ValueChanged<_Tab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final List<ResumeSection> sections = resumeSectionsOf(profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _VersionMetaRow(version: version),
        _TabSwitcher(current: tab, onChanged: onTabChanged),
        Expanded(
          child: ListView(
            // Figma `px-4 pb-8`。
            padding: const EdgeInsetsDirectional.fromSTEB(
              _DetailMetrics.contentInset,
              0,
              _DetailMetrics.contentInset,
              _DetailMetrics.contentBottom,
            ),
            children: <Widget>[
              if (tab == _Tab.pdf)
                _PdfPreviewCard(profile: profile, version: version, sections: sections)
              else
                for (final ResumeSection section in sections) ...<Widget>[
                  _RawSectionCard(section: section),
                  const SizedBox(height: _DetailMetrics.rawCardGap),
                ],
            ],
          ),
        ),
        const _BottomActions(),
      ],
    );
  }
}

/// 顶栏右侧的分享钮。Figma L4604-4609。
class _TopBarShareButton extends StatelessWidget {
  const _TopBarShareButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.xxs),
        child: Icon(
          // Figma 是自绘的「分享」描边 SVG；依 D58 用 Material 字形近似。
          Icons.ios_share,
          size: _DetailMetrics.topBarIconSize,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

/// 信息行：`当前简历` 胶囊 + `更新于 …`。
///
/// ⚠️ 右端的「最高匹配」**未渲染** —— 理由见 [ResumeDetailPage] 类文档。
class _VersionMetaRow extends StatelessWidget {
  const _VersionMetaRow({required this.version});

  final ResumeVersion version;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Figma `px-5 py-3`。
      padding: const EdgeInsets.symmetric(
        horizontal: _DetailMetrics.metaInset,
        vertical: _DetailMetrics.metaVertical,
      ),
      child: Row(
        children: <Widget>[
          const _CurrentPill(),
          if (version.uploadedAt != null) ...<Widget>[
            const SizedBox(width: _DetailMetrics.metaGap),
            Text(
              '更新于 ${formatResumeDate(version.uploadedAt!)}',
              style: AppTypography.resumeMetaTertiary,
            ),
          ],
        ],
      ),
    );
  }
}

/// 「当前简历」胶囊。Figma L4603-4606。
class _CurrentPill extends StatelessWidget {
  const _CurrentPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DetailMetrics.pillPaddingH,
        vertical: _DetailMetrics.pillPaddingV,
      ),
      decoration: const BoxDecoration(
        // Figma `rgba(79,126,245,0.10)` —— 与「当前简历」横幅里的品牌胶囊同值。
        color: AppColors.brandPillFill,
        borderRadius: AppRadius.borderPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: _DetailMetrics.pillDot,
            height: _DetailMetrics.pillDot,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: _DetailMetrics.pillDotGap),
          // 11 / w600 —— 与横幅徽章同一组合，只换颜色。
          Text(
            '当前简历',
            style: AppTypography.onSurfaceVariant(
              AppTypography.profileBrandChipLabel,
              AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

/// `PDF 预览` / `原始内容` 分段切换器。Figma L4617-4629。
class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.current, required this.onChanged});

  final _Tab current;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Figma `px-5 gap-2 mb-3`。
      padding: const EdgeInsetsDirectional.fromSTEB(
        _DetailMetrics.metaInset,
        0,
        _DetailMetrics.metaInset,
        _DetailMetrics.tabBottom,
      ),
      child: Row(
        children: <Widget>[
          _TabPill(
            label: 'PDF 预览',
            selected: current == _Tab.pdf,
            onTap: () => onChanged(_Tab.pdf),
          ),
          const SizedBox(width: _DetailMetrics.tabGap),
          _TabPill(
            label: '原始内容',
            selected: current == _Tab.raw,
            onTap: () => onChanged(_Tab.raw),
          ),
        ],
      ),
    );
  }
}

/// 一个页签胶囊。
class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _DetailMetrics.tabPaddingH,
          vertical: _DetailMetrics.tabPaddingV,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.surfaceDark
              : AppColors.resumeTabTrackFill,
          borderRadius: AppRadius.borderPill,
        ),
        child: Text(
          label,
          style: selected
              ? AppTypography.resumeDetailTabActive
              : AppTypography.resumeDetailTabIdle,
        ),
      ),
    );
  }
}

/// PDF 预览卡。Figma L4632-4680。
class _PdfPreviewCard extends StatelessWidget {
  const _PdfPreviewCard({
    required this.profile,
    required this.version,
    required this.sections,
  });

  final ResumeProfile profile;
  final ResumeVersion version;
  final List<ResumeSection> sections;

  /// 渐变头下方的分段 —— **跳过「基本信息」**：它已经画在头部里了。
  ///
  /// Figma 写的是 `RESUME_SECTIONS.slice(1)`（L4648），即从第二段开始。
  List<ResumeSection> get _bodySections {
    return <ResumeSection>[
      for (final ResumeSection s in sections)
        if (s.title != resumeBasicInfoTitle) s,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<ResumeSection> body = _bodySections;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderXl,
        boxShadow: AppShadows.resumePdfCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PdfHeader(profile: profile, version: version),
          for (final ResumeSection section in body)
            _PdfSectionBlock(section: section),
          _PdfFooter(version: version),
        ],
      ),
    );
  }
}

/// PDF 卡的渐变头部。Figma L4633-4647。
class _PdfHeader extends StatelessWidget {
  const _PdfHeader({required this.profile, required this.version});

  final ResumeProfile profile;
  final ResumeVersion version;

  @override
  Widget build(BuildContext context) {
    final String title = profile.fullName ?? version.label;
    final String? role = profile.workExperiences.isEmpty
        ? null
        : profile.workExperiences.first;
    final String contact = <String>[
      if (profile.email != null) profile.email!,
      if (profile.phone != null) profile.phone!,
    ].join('  ·  ');

    return Container(
      // Figma `px-6 py-5`。
      padding: const EdgeInsets.symmetric(
        horizontal: _DetailMetrics.pdfHeaderPaddingH,
        vertical: _DetailMetrics.pdfHeaderPaddingV,
      ),
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            // Figma 22 / w700 / white —— 与工作 / 项目详情 Hero 同一组合。
            style: AppTypography.profileHeroTitle,
          ),
          if (role != null) ...<Widget>[
            const SizedBox(height: _DetailMetrics.pdfHeaderGap),
            Text(role, style: AppTypography.resumeDetailHeaderSubtitle),
          ],
          if (contact.isNotEmpty) ...<Widget>[
            const SizedBox(height: _DetailMetrics.pdfHeaderContactGap),
            Text(contact, style: AppTypography.resumeDetailHeaderContact),
          ],
        ],
      ),
    );
  }
}

/// PDF 卡里的一个分段。Figma L4649-4669。
class _PdfSectionBlock extends StatelessWidget {
  const _PdfSectionBlock({required this.section});

  final ResumeSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Figma `px-6 py-4`。
      padding: const EdgeInsets.symmetric(
        horizontal: _DetailMetrics.pdfHeaderPaddingH,
        vertical: _DetailMetrics.pdfSectionPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Figma：`1px × 4px` 的竖向渐变条（`180deg`）。
              // ⚠️ 这里用 [AppColors.brandGradient]（`135deg`）——
              // 在 1×4 的条上角度差不可辨；不为此另立一个 Token。
              Container(
                width: _DetailMetrics.pdfSectionBarWidth,
                height: _DetailMetrics.pdfSectionBarHeight,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: AppRadius.borderPill,
                ),
              ),
              const SizedBox(width: _DetailMetrics.pdfSectionBarGap),
              Text(section.title, style: AppTypography.resumeDetailSectionTitle),
            ],
          ),
          for (final ResumeItem item in section.items) ...<Widget>[
            const SizedBox(height: _DetailMetrics.pdfItemGap),
            ResumeItemRow(item: item),
          ],
        ],
      ),
    );
  }
}

/// 分段条目：名称在左、值在右、补充说明独占整行。
///
/// ⚠️ 值为空时**只画名称** —— 不填「—」或空占位：那是编出来的信息。
class ResumeItemRow extends StatelessWidget {
  const ResumeItemRow({super.key, required this.item});

  final ResumeItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                item.label,
                style: AppTypography.resumeDetailItemLabel,
              ),
            ),
            if (item.value != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              Text(item.value!, style: AppTypography.resumeDetailItemValue),
            ],
          ],
        ),
        if (item.detail != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xxs),
          Text(item.detail!, style: AppTypography.resumeDetailItemDetail),
        ],
      ],
    );
  }
}

/// PDF 卡的页脚。Figma L4671-4678。
class _PdfFooter extends StatelessWidget {
  const _PdfFooter({required this.version});

  final ResumeVersion version;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Figma `px-6 py-3` + `border-top: 0.5px`。
      padding: const EdgeInsets.symmetric(
        horizontal: _DetailMetrics.pdfHeaderPaddingH,
        vertical: _DetailMetrics.pdfFooterPaddingV,
      ),
      decoration: const BoxDecoration(
        color: AppColors.resumePdfFooterFill,
        border: Border(
          top: BorderSide(
            color: AppColors.resumePdfFooterBorder,
            width: _DetailMetrics.pdfFooterBorderWidth,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${version.label} · 由 Careerly 生成',
            style: AppTypography.resumeDetailPdfFooter,
          ),
          const Text('第 1 页', style: AppTypography.resumeDetailPdfFooter),
        ],
      ),
    );
  }
}

/// 「原始内容」里的一个分段卡。Figma L4693-4709。
class _RawSectionCard extends StatelessWidget {
  const _RawSectionCard({required this.section});

  final ResumeSection section;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.borderXl,
      child: BackdropFilter(
        filter: GlassFilters.blur(_DetailMetrics.rawCardBlur),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.resumeGlassCardFill,
            borderRadius: AppRadius.borderXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                section.title,
                style: AppTypography.resumeDetailRawTitle,
              ),
              for (final ResumeItem item in section.items) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTypography.resumeDetailRawLabel,
                      ),
                    ),
                    if (item.value != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        item.value!,
                        style: AppTypography.resumeDetailRawValue,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 底部动作条：`导出 PDF` + `编辑简历`。Figma L4712-4740。
class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Figma `px-5 pb-6 pt-3`。
      padding: const EdgeInsetsDirectional.fromSTEB(
        _DetailMetrics.metaInset,
        _DetailMetrics.actionBarTop,
        _DetailMetrics.metaInset,
        _DetailMetrics.actionBarBottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.resumeActionBarFill,
        border: Border(
          top: BorderSide(
            color: AppColors.resumeActionBarBorder,
            width: _DetailMetrics.actionBarBorderWidth,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _BottomActionButton(
              label: '导出 PDF',
              icon: Icons.ios_share,
              gradient: null,
              fill: AppColors.primaryBlueSurface,
              borderColor: AppColors.brandBorderFaint,
              labelColor: AppColors.primaryBlue,
              // Figma 的「导出 PDF」与顶栏的分享钮**同一去向** ——
              // 都打开分享 / 导出弹层（L4628 / L4726）。
              onTap: () => showResumeShareSheet(context),
            ),
          ),
          const SizedBox(width: _DetailMetrics.actionGap),
          Expanded(
            child: _BottomActionButton(
              label: '编辑简历',
              icon: Icons.edit_outlined,
              gradient: AppColors.brandGradient,
              fill: null,
              borderColor: null,
              labelColor: AppColors.textInverse,
              onTap: () => _notWired(context, '编辑简历'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 尚未接线的入口的如实提示。
///
/// ⚠️ 不是占位文案 —— 这些入口在 Figma 里有，但 App 里**没有对应的功能**
/// （没有编辑流程、没有分享 / 导出能力，也没有为它们新增依赖）。
/// 静默无反应会让真机验收误判为「按钮坏了」，故如实说明。
void _notWired(BuildContext context, String feature) {
  CareerlyToast.show(
    context,
    message: '$feature尚未接入',
    icon: Icons.info_outline,
    bottomOffset: _DetailMetrics.toastOffset,
  );
}

/// 打开分享 / 导出弹层。
void showResumeShareSheet(BuildContext context) {
  CareerlyBottomSheet.show<void>(
    context,
    tone: CareerlyBottomSheetTone.action,
    child: const ResumeShareSheet(),
  );
}

/// 底栏的一个按钮。
class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.fill,
    required this.borderColor,
    required this.labelColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Gradient? gradient;
  final Color? fill;
  final Color? borderColor;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ⚠️ `gradient` 与 `color` 必须互斥 —— 见 `CareerlyButton` 类文档
    // 「`color` 与 `gradient` 必须互斥」（2026-10-04 修复）。
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _DetailMetrics.actionHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gradient == null ? fill : null,
          gradient: gradient,
          borderRadius: AppRadius.borderPill,
          border: borderColor == null
              ? null
              : Border.all(
                  color: borderColor!,
                  width: _DetailMetrics.actionBorderWidth,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: _DetailMetrics.actionIconSize, color: labelColor),
            const SizedBox(width: _DetailMetrics.actionIconGap),
            Text(
              label,
              style: AppTypography.onSurfaceVariant(
                AppTypography.resumeDetailActionLabel,
                labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 简历详情页的内部几何（Figma 逐条内联给出）。
abstract final class _DetailMetrics {
  /// Figma `px-4`（内容区）。
  static const double contentInset = 16;

  /// Figma `pb-8`（内容区）。
  static const double contentBottom = 32;

  /// Figma `px-5`（信息行 / 页签 / 底栏）。
  static const double metaInset = 20;

  /// Figma `py-3`。
  static const double metaVertical = 12;

  /// Figma `gap-1.5`（胶囊内 点 与 文字）。
  static const double metaGap = 8;

  // ── 「当前简历」胶囊 ────────────────────────────────────────────────
  static const double pillPaddingH = 10;
  static const double pillPaddingV = 4;
  static const double pillDot = 6;
  static const double pillDotGap = 6;

  // ── 页签 ────────────────────────────────────────────────────────────
  /// Figma `gap-2`。
  static const double tabGap = 8;

  /// Figma `mb-3`。
  static const double tabBottom = 12;

  /// Figma `px-4 py-1.5`。
  static const double tabPaddingH = 16;
  static const double tabPaddingV = 6;

  // ── PDF 卡 ──────────────────────────────────────────────────────────
  /// Figma `px-6`。
  static const double pdfHeaderPaddingH = 24;

  /// Figma `py-5`。
  static const double pdfHeaderPaddingV = 20;

  /// 头部的行距（Flutter 侧取值：Figma 用 `gap` 分布，未逐条给数）。
  static const double pdfHeaderGap = 6;
  static const double pdfHeaderContactGap = 8;

  /// Figma `py-4`。
  static const double pdfSectionPaddingV = 16;

  /// Figma：`1px × 4px` 渐变条。
  static const double pdfSectionBarWidth = 3;
  static const double pdfSectionBarHeight = 14;

  /// Flutter 侧取值：Figma 的条与标题之间是 `gap-2` 的近似。
  static const double pdfSectionBarGap = 8;

  /// 条目之间的行距（Figma `space-y-2`）。
  static const double pdfItemGap = 8;

  /// Figma `py-3`。
  static const double pdfFooterPaddingV = 12;

  /// Figma `border-top: 0.5px`。
  static const double pdfFooterBorderWidth = 0.5;

  // ── 原始内容卡 ─────────────────────────────────────────────────────
  /// Figma `blur(12px)`。
  static const double rawCardBlur = 12;
  static const double rawCardGap = 12;

  // ── 底栏 ────────────────────────────────────────────────────────────
  static const double actionBarTop = 12;
  static const double actionBarBottom = 24;
  static const double actionBarBorderWidth = 0.5;
  static const double actionHeight = 48;
  static const double actionGap = 12;
  static const double actionBorderWidth = 1;
  static const double actionIconSize = 16;
  static const double actionIconGap = 8;

  // ── 顶栏 ────────────────────────────────────────────────────────────
  static const double topBarIconSize = 20;

  /// 提示的贴底距离（工程取值，非设计值）。
  static const double toastOffset = AppSpacing.xxl;
}
