import 'package:flutter/material.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

/// 用户在「导入新简历」弹层里选了什么。
enum ResumeImportChoice {
  /// 从手机文件里选 PDF / Word / 图片。
  file,

  /// 拍一张简历照片。
  camera,

  /// 直接粘贴简历文本。
  paste,
}

/// 弹出「导入新简历」弹层，返回用户的选择。点「取消」或点空白处返回 `null`。
///
/// 真值来源：Figma `ResumeHistoryPage` 的导入弹层（`src/App.tsx` L4905-4996）。
///
/// ```text
/// 标题   导入新简历
/// 说明   「从手机文件选择 PDF 或 Word 简历，Careerly 会自动解析。」
/// 选项卡 从文件选择（品牌浅底） · 拍照上传 · 粘贴文本
/// 取消   深色胶囊
/// ```
///
/// ⚠️ 本组件**只负责选择**，不执行导入 —— 真正的工作（取文件、提交、
/// 刷新画像）留在页面里做，这样弹层不依赖 Provider，也好单测。
Future<ResumeImportChoice?> showResumeImportSheet(BuildContext context) {
  return CareerlyBottomSheet.show<ResumeImportChoice>(
    context,
    tone: CareerlyBottomSheetTone.action,
    child: const _ResumeImportSheet(),
  );
}

/// 弹出「粘贴简历文本」输入弹层，返回文本；取消返回 `null`。
///
/// ⚠️ Figma 的导入弹层里**没有**输入界面 —— 点「粘贴文本」直接就解析了。
/// 但本页的职责是导入一份简历，不给输入界面就等于什么都没导入。
/// 这与 Onboarding 提交简历页的 **D70** 是同一处缺口、同一处置。
Future<String?> showResumePasteSheet(BuildContext context) {
  return CareerlyBottomSheet.show<String>(
    context,
    tone: CareerlyBottomSheetTone.action,
    child: const _PasteResumeSheet(),
  );
}

/// 弹层内容。
class _ResumeImportSheet extends StatelessWidget {
  const _ResumeImportSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Figma `px-5 pt-3 pb-8`。
      padding: const EdgeInsetsDirectional.fromSTEB(
        _ImportMetrics.inset,
        0,
        _ImportMetrics.inset,
        _ImportMetrics.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('导入新简历', style: AppTypography.analysisSheetTitle),
          const SizedBox(height: _ImportMetrics.titleGap),
          const Text(
            // Figma 逐字（L4927-4929）——按 Figma 的分行位置断行：
            // 「从手机文件选择 PDF 或 Word 简历，」/「Careerly 会自动解析。」
            '从手机文件选择 PDF 或 Word 简历，\nCareerly 会自动解析。',
            style: AppTypography.resumeImportBody,
          ),
          const SizedBox(height: _ImportMetrics.descGap),
          _ImportOption(
            label: '从文件选择',
            description: '支持 PDF / DOCX',
            icon: Icons.folder_open,
            iconSize: _ImportMetrics.folderIcon,
            titleColor: AppColors.primaryBlue,
            fill: AppColors.primaryBlueSurface,
            borderColor: AppColors.brandBorderFaint,
            onTap: () => Navigator.of(context).pop(ResumeImportChoice.file),
          ),
          const SizedBox(height: _ImportMetrics.optionGap),
          _ImportOption(
            label: '拍照上传',
            description: '拍摄简历照片',
            icon: Icons.photo_camera_outlined,
            iconSize: _ImportMetrics.cameraIcon,
            titleColor: AppColors.surfaceDark,
            fill: AppColors.resumeNeutralOptionFill,
            borderColor: null,
            onTap: () => Navigator.of(context).pop(ResumeImportChoice.camera),
          ),
          const SizedBox(height: _ImportMetrics.optionGap),
          _ImportOption(
            label: '粘贴文本',
            description: '直接粘贴简历内容',
            icon: Icons.add,
            iconSize: _ImportMetrics.pasteIcon,
            titleColor: AppColors.surfaceDark,
            fill: AppColors.resumeNeutralOptionFill,
            borderColor: null,
            onTap: () => Navigator.of(context).pop(ResumeImportChoice.paste),
          ),
          const SizedBox(height: _ImportMetrics.cancelGap),
          _CancelButton(onTap: () => Navigator.of(context).maybePop()),
        ],
      ),
    );
  }
}

/// 一个导入方式。
class _ImportOption extends StatelessWidget {
  const _ImportOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.iconSize,
    required this.titleColor,
    required this.fill,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final double iconSize;
  final Color titleColor;
  final Color fill;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CareerlyPressFeedback(
      onTap: onTap,
      child: Container(
        // Figma `padding: 10px 20px` + `gap-3`。
        padding: const EdgeInsetsDirectional.fromSTEB(
          _ImportMetrics.optionPaddingH,
          _ImportMetrics.optionPaddingV,
          _ImportMetrics.optionPaddingH,
          _ImportMetrics.optionPaddingV,
        ),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: _ImportMetrics.optionBorderWidth,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: iconSize, color: AppColors.textPrimary),
            const SizedBox(width: _ImportMetrics.optionIconGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTypography.onSurfaceVariant(
                      AppTypography.resumeImportOptionTitle,
                      titleColor,
                    ),
                  ),
                  const SizedBox(height: _ImportMetrics.optionTextGap),
                  Text(
                    description,
                    style: AppTypography.resumeImportOptionDesc,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 「取消」—— 深色胶囊。
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _ImportMetrics.cancelHeight,
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

/// 「粘贴简历文本」输入弹层。
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
    // 空文本时「导入」不可用，故监听输入重算。
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
    // —— 没有它会在构建时直接抛 `No Material widget found`（同 D74）。
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        // 弹层由父级贴底，键盘弹起时不会被顶起，故自带一份 viewInsets 下边距。
        padding: EdgeInsetsDirectional.fromSTEB(
          _ImportMetrics.inset,
          AppSpacing.xs,
          _ImportMetrics.inset,
          _ImportMetrics.inset + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('粘贴简历文本', style: AppTypography.analysisSheetTitle),
            const SizedBox(height: _ImportMetrics.titleGap),
            const Text(
              '把简历内容复制进来，Careerly 会据此更新你的简历版本。',
              style: AppTypography.resumeImportBody,
            ),
            const SizedBox(height: _ImportMetrics.descGap),
            CareerlyInput(
              variant: CareerlyInputVariant.boxed,
              hint: '在此粘贴简历文本',
              controller: _controller,
              maxLines: _ImportMetrics.pasteLines,
              autofocus: true,
            ),
            const SizedBox(height: _ImportMetrics.cancelGap),
            CareerlyButton(
              label: '导入',
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 弹层内部几何（Figma 逐条内联给出）。
abstract final class _ImportMetrics {
  /// Figma `px-5`。
  static const double inset = 20;

  /// Figma `pb-8`。
  static const double bottom = 32;

  /// 标题与说明之间（Flutter 侧取值：Figma 用 `mt-2.5` 近似）。
  static const double titleGap = 10;

  /// Figma `mt-[18px]`。
  static const double descGap = 18;

  /// Figma `gap-3`。
  static const double optionGap = 12;

  /// Figma `padding: 10px 20px`。
  static const double optionPaddingH = 20;
  static const double optionPaddingV = 10;

  /// Figma `border: 1.25px`。
  static const double optionBorderWidth = 1.25;

  /// Figma `gap-3`（图标与文字之间）。
  static const double optionIconGap = 12;

  /// 标题与说明之间（Flutter 侧取值）。
  static const double optionTextGap = 2;

  /// Figma：文件夹图标 `22×22`。
  static const double folderIcon = 22;

  /// Figma：相机图标 `21×16`（这里按正方取 21）。
  static const double cameraIcon = 21;

  /// Figma：加号图标 `18×18`。
  static const double pasteIcon = 18;

  /// Figma `margin-top: 14px`。
  static const double cancelGap = 14;

  /// Figma `height: 48`。
  static const double cancelHeight = 48;

  /// 粘贴输入框的行数 —— Flutter 侧取值（Figma 无此界面），同 D70。
  static const int pasteLines = 8;
}
