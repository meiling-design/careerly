import 'package:flutter/material.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

/// 分享 / 导出弹层。Figma `ResumeDetailPage` L4750-4793。
///
/// ```text
/// 标题   分享 / 导出
/// 三格   存为 PDF（蓝） · 复制链接（紫） · 发送邮件（绿）
/// 取消   深色胶囊
/// ```
///
/// ## ⚠️ 三个选项卡**尚未接线**
///
/// Figma 只画了入口，没有定义导出 / 分享的产物（文件从哪来、链接指向哪、
/// 邮件送给谁）。App 也**没有**分享能力，且按 `CLAUDE.md` §6.5
/// 不为此新增依赖。因此三个选项卡如实提示「尚未接入」，
/// **不假装导出成功**。缺口已登记 `docs/05_progress/TODO.md` §3.1。
///
/// 「取消」是真实可用的 —— 它关闭面板。
class ResumeShareSheet extends StatelessWidget {
  const ResumeShareSheet({super.key});

  /// 三个选项卡的取值。真值来源 Figma L4766-4789。
  static const List<_ShareOption> _options = <_ShareOption>[
    _ShareOption(
      label: '存为 PDF',
      icon: Icons.picture_as_pdf_outlined,
      color: AppColors.primaryBlue,
      fill: AppColors.primaryBlueSurface,
    ),
    _ShareOption(
      label: '复制链接',
      icon: Icons.link,
      color: AppColors.primaryPurple,
      fill: AppColors.primaryPurpleSurface,
    ),
    _ShareOption(
      label: '发送邮件',
      icon: Icons.mail_outline,
      color: AppColors.resumeShareMail,
      fill: AppColors.resumeShareMailFill,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Figma `px-5 pt-3 pb-8`。把手与面板内边距由 `CareerlyBottomSheet` 负责。
      padding: const EdgeInsetsDirectional.fromSTEB(
        _ShareMetrics.inset,
        0,
        _ShareMetrics.inset,
        _ShareMetrics.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('分享 / 导出', style: AppTypography.resumeShareSheetTitle),
          const SizedBox(height: _ShareMetrics.titleGap),
          Row(
            children: <Widget>[
              for (int i = 0; i < _options.length; i++) ...<Widget>[
                Expanded(child: _ShareTile(option: _options[i])),
                if (i != _options.length - 1)
                  const SizedBox(width: _ShareMetrics.tileGap),
              ],
            ],
          ),
          const SizedBox(height: _ShareMetrics.cancelGap),
          _CancelButton(onTap: () => Navigator.of(context).maybePop()),
        ],
      ),
    );
  }
}

/// 一个选项卡。
class _ShareTile extends StatelessWidget {
  const _ShareTile({required this.option});

  final _ShareOption option;

  @override
  Widget build(BuildContext context) {
    return CareerlyPressFeedback(
      onTap: () => CareerlyToast.show(
        context,
        message: '${option.label}尚未接入',
        icon: Icons.info_outline,
        bottomOffset: _ShareMetrics.toastOffset,
      ),
      child: Container(
        // Figma `py-4`。
        padding: const EdgeInsets.symmetric(
          vertical: _ShareMetrics.tilePaddingV,
        ),
        decoration: BoxDecoration(
          color: option.fill,
          borderRadius: AppRadius.borderXl,
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: _ShareMetrics.iconCircle,
              height: _ShareMetrics.iconCircle,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                size: _ShareMetrics.iconSize,
                color: AppColors.textInverse,
              ),
            ),
            const SizedBox(height: _ShareMetrics.iconLabelGap),
            Text(option.label, style: AppTypography.resumeShareOptionLabel),
          ],
        ),
      ),
    );
  }
}

/// 「取消」—— Figma `rgba(55,59,77,0.87)` 深色胶囊。
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _ShareMetrics.cancelHeight,
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

/// 一个选项卡的取值。
class _ShareOption {
  const _ShareOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.fill,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color fill;
}

/// 弹层内部几何（Figma 逐条内联给出）。
abstract final class _ShareMetrics {
  /// Figma `px-5`。
  static const double inset = 20;

  /// Figma `pb-8`。
  static const double bottom = 32;

  /// 标题与卡片之间（Flutter 侧取值：Figma 用 `mb-5` 近似）。
  static const double titleGap = 20;

  /// Figma `gap-3`。
  static const double tileGap = 12;

  /// Figma `py-4`。
  static const double tilePaddingV = 16;

  /// Figma：圆形图标底 `40×40`。
  static const double iconCircle = 40;

  /// Figma：圆内图标 `18×18`。
  static const double iconSize = 18;

  /// Figma `mt-2`。
  static const double iconLabelGap = 8;

  /// Figma `mt-4`。
  static const double cancelGap = 16;

  /// Figma `height: 48`。
  static const double cancelHeight = 48;

  /// 提示的贴底距离（工程取值，非设计值）。
  static const double toastOffset = AppSpacing.xxl;
}
