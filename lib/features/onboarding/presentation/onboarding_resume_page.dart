import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/services/resume_file_picker.dart';
import '../../../data/models/resume_file.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../profile/state/resume_provider.dart';
import 'widgets/onboarding_action_buttons.dart';
import 'widgets/onboarding_progress_header.dart';

/// 提交简历页 —— Onboarding 第 4 屏（六步链路里「提交简历」那一步）。
///
/// 真值来源：Figma `OnResume`（`src/App.tsx` L747-800）。
///
/// ```text
/// 背景   linear-gradient(143deg, #EEF2FF → #FDF4FF)   同 [AppColors.onboardingGradient]
/// 顶部   OnboardingProgressHeader(step: 3, total: 3)
/// 内容   标题「上传你的简历」→ 说明 → 虚线上传卡 → 「AI 将自动提取」清单
/// 底部   「选择文件」(主按钮) / 「粘贴简历文本」(白描边按钮)
/// ```
///
/// ## 这一屏**不是分析**
///
/// 它只**提交**简历；解析（建立职业基线）发生在下一屏 `on-parsing`。
/// 因此本页**不扣分析额度**（`CLAUDE.md` §5.2）、**不出现** JD / 岗位 /
/// 匹配度 / Gap（PRD §7.1；产品侧裁决 **D63**）。
///
/// ## 数据链路（D52：纯 Mock）
///
/// ```text
/// 本页 → ResumeProvider → ResumeRepository → MockResumeRepository
/// ```
///
/// **不落盘、不上传、不保存**。
///
/// ## ⚠️ Flutter 侧补齐的三处（Figma 未定义 / 未接线）
///
/// 1. **「粘贴简历文本」的 Bottom Sheet** —— Figma 里这个按钮
///    与「选择文件」**一样直接跳 `on-parsing`**（`App.tsx` L791/L794），
///    并没有取文本的界面。但本页的职责是「提交一份简历」，
///    不给输入界面就等于**什么都没提交**。故补一个弹层收文本，
///    文本经 `ResumeProvider.submitText` 落到 Repository。
///    登记 **待裁决 · D70**（`docs/05_progress/TODO.md` §3.1）。
/// 2. **提交中的 Loading** —— Figma 未定义。此处沿用**注册页的既有处理**：
///    提交期间把按钮置为不可用，防重复提交。**未发明任何新视觉**。
///    同 **D70**。
/// 3. **自绘图形用 Material 图标近似**（上传图标 / 清单勾选圆），
///    以及**虚线边框**的画法 —— Figma 是 SVG 路径与 CSS `dashed`，
///    两者都没有 Flutter 的逐位等价物。
///    处理方式与注册页头像（**D58**）一致：**不新建图标资源**。
///    登记 **待裁决 · D72**。
/// 4. **两处文案偏离 Figma** —— 选择器放行图片（走 OCR）后，
///    标题与卡内说明必须含图片，否则「说一套做一套」。
///    改法是产品侧 2026-10-02 拍板的草稿（**D107** 已裁决）：
///
///    ```text
///    标题   支持 PDF、Word、图片格式，…        （Figma：支持 PDF、Word 格式，…）
///    卡内   PDF / Word / 图片截图 · 最大 10MB  （Figma：PDF / Word · 最大 10MB）
///    ```
///
///    「AI 将自动提取」清单**不动** —— 它本就列了「技能与证书 / 获奖与荣誉」两项。
///
/// ## 「选择文件」链路（**D67 已关闭**）
///
/// ```text
/// 选择文件 → ResumeFilePicker（平台网关，DI 注入，测试可换 Fake）
///         → ResumeFileData（类型白名单在选择器层卡；10MB 上限在提交前卡）
///         → ResumeProvider.submitFile → ResumeRepository.submitResumeFile
///         → on-parsing（与「粘贴简历文本」同一条后续链路）
/// ```
///
/// 用户取消选择**不是失败**，不做任何提示、停留原页。
class OnboardingResumePage extends StatefulWidget {
  const OnboardingResumePage({super.key});

  @override
  State<OnboardingResumePage> createState() => _OnboardingResumePageState();
}

class _OnboardingResumePageState extends State<OnboardingResumePage> {
  @override
  void initState() {
    super.initState();
    // 进入本页时清掉上一次留下的成功 / 失败残状态。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ResumeProvider>().resetSubmit();
    });
  }

  /// 「选择文件」—— 选 → 校验 → 提交 → 交给解析页（D67 已关闭）。
  Future<void> _onPickFile() async {
    final ResumeFilePicker picker = context.read<ResumeFilePicker>();
    final ResumeProvider provider = context.read<ResumeProvider>();

    final ResumeFileData? file;
    try {
      file = await picker.pick();
    } catch (error, stackTrace) {
      if (!mounted) return;
      final AppError normalized = ErrorHandler.normalize(error, stackTrace);
      CareerlyToast.show(
        context,
        message: normalized.message,
        icon: Icons.error_outline,
        bottomOffset: AppSpacing.xxl,
      );
      return;
    }

    // 用户取消：不是失败，不做任何提示。
    if (!mounted || file == null) return;

    // 大小上限在提交前卡（选择器无法按大小过滤）。
    if (file.exceedsLimit) {
      CareerlyToast.show(
        context,
        message: '文件超过 10MB 上限，请更换后重试',
        icon: Icons.error_outline,
        bottomOffset: AppSpacing.xxl,
      );
      return;
    }

    final bool ok = await provider.submitFile(file);
    if (!mounted) return;

    if (!ok) {
      CareerlyToast.show(
        context,
        message: provider.submitError?.message ?? '提交失败，请重试',
        icon: Icons.error_outline,
        bottomOffset: AppSpacing.xxl,
      );
      return;
    }

    context.go(AppRoutes.onboardingParsing);
  }

  /// 「粘贴简历文本」—— 收文本 → 提交 → 交给解析页。
  Future<void> _onPasteText() async {
    final String? text = await CareerlyBottomSheet.show<String>(
      context,
      tone: CareerlyBottomSheetTone.action,
      child: const _PasteResumeSheet(),
    );

    if (!mounted || text == null) return;

    final ResumeProvider provider = context.read<ResumeProvider>();
    final bool ok = await provider.submitText(text);

    if (!mounted) return;

    if (!ok) {
      CareerlyToast.show(
        context,
        message: provider.submitError?.message ?? '提交失败，请重试',
        icon: Icons.error_outline,
        bottomOffset: AppSpacing.xxl,
      );
      return;
    }

    context.go(AppRoutes.onboardingParsing);
  }

  @override
  Widget build(BuildContext context) {
    final ResumeProvider provider = context.watch<ResumeProvider>();
    final bool busy = provider.isUploading;

    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Colors.transparent,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.onboardingGradient,
            ),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  OnboardingProgressHeader(
                    // Figma `OnResume` 写的是 `step: 3, total: 3`，
                    // 而注册页写的是 `1 / 4` —— 两屏的阶梯**对不上**。
                    // 这里**逐位照抄 Figma**，不自行统一；
                    // 分歧登记 **待裁决 · D69**（`TODO.md` §3.1）。
                    step: 3,
                    total: 3,
                    // Figma 的返回目标是 `on-welcome`（用户身份选择）。
                    // 该屏尚未实现（D61），故回退到链路里的上一屏。
                    onBack: () => context.go(AppRoutes.onboardingRegister),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const _ResumeTitle(),
                          _UploadCard(onTap: busy ? null : _onPickFile),
                          const _ExtractChecklist(),
                        ],
                      ),
                    ),
                  ),
                  _ResumeActions(
                    // 提交中禁用，避免重复提交。
                    onPickFile: busy ? null : _onPickFile,
                    onPasteText: busy ? null : _onPasteText,
                  ),
                ],
              ),
            ),
          ),
        ),
        // 上传 + 后端同步解析可能持续几分钟（见 ApiClient.resumeParseTimeout），
        // 期间铺一层忙等遮罩，明确「仍在进行」并拦住重复提交。
        if (busy) const Positioned.fill(child: CareerlyUploadingOverlay()),
      ],
    );
  }
}

/// 标题与说明。
class _ResumeTitle extends StatelessWidget {
  const _ResumeTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('上传你的简历', style: AppTypography.onboardingPageHeading),
        SizedBox(height: _ResumeMetrics.titleGap),
        Text(
          '支持 PDF、Word、图片格式，AI 将自动解析你的职业经历',
          style: AppTypography.onboardingSubtitle,
        ),
        SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

/// 虚线上传卡。
///
/// Figma：`1.5px dashed rgba(79,126,245,0.35)` · `radius 20` ·
/// `padding 32px 24px` · `background rgba(255,255,255,0.55)`。
///
/// ⚠️ 卡片底色与设计稿的**返回键**同值（`rgba(255,255,255,0.55)`），
/// 因此复用 [AppColors.onboardingGlassFill]，未另立别名
/// —— 两者是**同一个设计意图**（渐变底上的半透明白面板），
/// 与 `brandTint` / `brandGradientDown` 那种「同值不同义」的情形不同。
///
/// ⚠️ 整卡可点：Figma 的文案是「点击或拖拽上传简历」，
/// 点击 = 「选择文件」（D67 已关闭）。
class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CareerlyPressFeedback(
      onTap: onTap,
      child: CustomPaint(
        painter: const _DashedRoundedBorderPainter(
          radius: _ResumeMetrics.uploadCardRadius,
          strokeWidth: _ResumeMetrics.uploadCardBorderWidth,
          color: AppColors.brandBorderSoft,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.onboardingGlassFill,
            borderRadius: BorderRadius.circular(
              _ResumeMetrics.uploadCardRadius,
            ),
          ),
          child: Column(
            children: <Widget>[
              const _UploadIconTile(),
              const SizedBox(height: AppSpacing.md),
              const Text('点击或拖拽上传简历', style: AppTypography.onboardingCardTitle),
              const SizedBox(height: _ResumeMetrics.uploadCardTextGap),
              const Text(
                'PDF / Word / 图片截图 · 最大 10MB',
                style: AppTypography.onboardingCaption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 上传卡里的 60×60 渐变图标底板。
///
/// Figma：`60×60 · radius 18 · linear-gradient(135deg, #4F7EF5 → #A77BE6)`
/// —— 正是 [AppColors.brandGradient]。
class _UploadIconTile extends StatelessWidget {
  const _UploadIconTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _ResumeMetrics.uploadIconTileSize,
      height: _ResumeMetrics.uploadIconTileSize,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.borderIconTile,
      ),
      child: const Center(
        // Figma 是自绘 SVG（上箭头 + 底线）。这里用 Material 字形近似，
        // 同 D58 的处理，见类文档第 3 条。
        child: Icon(
          Icons.upload,
          size: _ResumeMetrics.uploadIconSize,
          color: AppColors.textInverse,
        ),
      ),
    );
  }
}

/// 「AI 将自动提取」清单。
///
/// Figma：标题 `13px / bold` + 下方两列网格（列间距 12 · 行间距 8），
/// 每项 = `14×14` 勾选圆 + 文案。
class _ExtractChecklist extends StatelessWidget {
  const _ExtractChecklist();

  /// Figma 原文逐条抄录。
  static const List<String> _items = <String>[
    '工作经历与职位信息',
    '项目经历与成果',
    '教育背景',
    '技能与证书',
    '获奖与荣誉',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('AI 将自动提取', style: AppTypography.onboardingSectionLabel),
        const SizedBox(height: AppSpacing.sm),
        // Figma 是 `grid-template-columns: repeat(2, 1fr)`：
        // 两列等宽、末行可只有一个。
        for (int i = 0; i < _items.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : _ResumeMetrics.checklistRowGap,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _ChecklistItem(text: _items[i])),
                const SizedBox(width: _ResumeMetrics.checklistColumnGap),
                Expanded(
                  child: i + 1 < _items.length
                      ? _ChecklistItem(text: _items[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// 清单的一项：勾选圆 + 文案。
class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: _ResumeMetrics.checkCircleSize,
          height: _ResumeMetrics.checkCircleSize,
          decoration: const BoxDecoration(
            color: AppColors.brandTint,
            shape: BoxShape.circle,
          ),
          child: const Center(
            // Figma 是 1.5px 描边的勾路径；字形近似见 D72。
            child: Icon(
              Icons.check,
              size: _ResumeMetrics.checkGlyphSize,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.onSurfaceVariant(
              AppTypography.onboardingCaption,
              AppColors.textBody,
            ),
          ),
        ),
      ],
    );
  }
}

/// 底部两个动作。
class _ResumeActions extends StatelessWidget {
  const _ResumeActions({required this.onPickFile, required this.onPasteText});

  final VoidCallback? onPickFile;
  final VoidCallback? onPasteText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        children: <Widget>[
          OnboardingPrimaryButton(label: '选择文件', onPressed: onPickFile),
          const SizedBox(height: AppSpacing.sm),
          OnboardingOutlineButton(label: '粘贴简历文本', onPressed: onPasteText),
        ],
      ),
    );
  }
}

/// 「粘贴简历文本」弹层。
///
/// ⚠️ **Figma 无此界面**（见类文档第 1 条 / **D70**）。
/// 它取的是既有 [CareerlyBottomSheet]（`tone: action`）与
/// [CareerlyInput] 的 `boxed` 变体，**未新增任何组件或视觉**。
class _PasteResumeSheet extends StatefulWidget {
  const _PasteResumeSheet();

  @override
  State<_PasteResumeSheet> createState() => _PasteResumeSheetState();
}

class _PasteResumeSheetState extends State<_PasteResumeSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 空文本时「提交」应不可用，故监听输入重算。
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ [Material] 是**必需的**：`CareerlyBottomSheet` 走 `showGeneralDialog`，
    // 面板里**没有** Material 祖先，而 [CareerlyInput] 内部是原生 `TextField`
    // —— 没有它会在构建时直接抛 `No Material widget found`。
    //
    // 透明 Material（零视觉影响），只补祖先。
    // 该组合缺陷已登记 → `TODO.md` §3.1 · **D74**。
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        // 弹层由父级贴底（`Align(bottomCenter)`），键盘弹起时不会被顶起，
        // 故自带一份 viewInsets 下边距。
        padding: EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('粘贴简历文本', style: AppTypography.onboardingBarTitle),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              '把简历内容复制进来，AI 会据此建立你的职业基线。',
              style: AppTypography.onboardingCaption,
            ),
            const SizedBox(height: AppSpacing.mdLg),
            CareerlyInput(
              variant: CareerlyInputVariant.boxed,
              hint: '在此粘贴简历文本',
              controller: _controller,
              maxLines: _ResumeMetrics.pasteSheetLines,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            OnboardingPrimaryButton(
              label: '提交',
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 虚线圆角边框。
///
/// Flutter 的 [BoxDecoration] **不支持**虚线边框（`BorderStyle` 只有
/// `none` / `solid`），CSS 的 `dashed` 也没有逐位等价的 dash / gap 取值，
/// 故自绘。虚线节奏（6 / 4）是 Flutter 侧按视觉近似取的
/// —— 见 **D72**。仅本页使用，故不升为 design-system 组件（`CLAUDE.md` §6.4）。
class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.color,
  });

  final double radius;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    // 描边以路径为中心向两侧各铺 strokeWidth / 2，
    // 因此路径要内缩半个线宽，否则外半侧会被裁掉。
    final RRect border = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(strokeWidth / 2);

    final Path path = Path()..addRRect(border);

    for (final PathMetric metric in path.computeMetrics()) {
      double start = 0;
      while (start < metric.length) {
        final double end = (start + _ResumeMetrics.dashLength).clamp(
          0,
          metric.length,
        );
        canvas.drawPath(metric.extractPath(start, end), paint);
        start = end + _ResumeMetrics.dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRoundedBorderPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.color != color;
}

/// 页面内部几何与节奏（Figma 原值）。
///
/// 与 `_RegisterMetrics` 同理：这些是**本页的内部比例**，
/// 不是可跨页面复用的间距档，故不进 `AppSpacing`。
abstract final class _ResumeMetrics {
  /// Figma：标题与说明之间 `margin-bottom: 6px`。
  static const double titleGap = 6;

  /// Figma：上传卡 `border-radius: 20`。
  static const double uploadCardRadius = 20;

  /// Figma：上传卡 `border: 1.5px dashed`。
  static const double uploadCardBorderWidth = 1.5;

  /// Figma：图标底板与文案之间 `gap: 16`，卡片整体 `gap` 亦为 16。
  static const double uploadIconTileSize = 60;

  /// Figma：底板内 SVG 为 `28×28`。
  static const double uploadIconSize = 28;

  /// Figma：卡内两行文案间距 `margin-top: 4px`。
  static const double uploadCardTextGap = 4;

  /// Figma：清单网格 `gap: 8px 12px`（行 / 列）。
  static const double checklistRowGap = 8;
  static const double checklistColumnGap = 12;

  /// Figma：清单勾选圆 `14×14`。
  static const double checkCircleSize = 14;

  /// 勾选字形尺寸 —— Flutter 侧近似值，见 D72。
  static const double checkGlyphSize = 10;

  /// 粘贴弹层里输入框的行数 —— Flutter 侧取值（Figma 无此界面），见 D70。
  static const int pasteSheetLines = 8;

  /// 虚线节奏 —— Flutter 侧近似值，见 D72。
  static const double dashLength = 6;
  static const double dashGap = 4;
}
