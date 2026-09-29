import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../tokens/tokens.dart';

/// Careerly 轻提示（Toast）。
///
/// ```dart
/// CareerlyToast.show(context, message: '已保存');
/// CareerlyToast.show(context, message: '链接已复制', icon: Icons.check_rounded);
/// ```
///
/// ## ⚠️ 视觉是 **Flutter 侧补齐**的，不是设计侧产出（**D26**）
///
/// **Figma 中不存在 Toast 组件或任何使用点。** 核查 `src/App.tsx`（5310 行）
/// 的结果是：只有 `src/index.css` 的两个关键帧 `.toast-in` / `.toast-out`，
/// 且这两个 class **无任何元素引用**。
///
/// | 项 | 设计侧是否给出 |
/// |---|---|
/// | 进入 / 退出动画 | ✅ `160ms ease-out` / `180ms ease-in`，`translateY(8px)` |
/// | 定位 | ✅ 底部（`motion-spec` §） |
/// | 用途限定 | ✅ 保存 / 复制 / 删除 / 简历更新 **成功** |
/// | **容器背景 / 圆角 / 内边距** | ❌ **未给出** |
/// | **图标、文字字号 / 字重 / 颜色** | ❌ **未给出** |
/// | **成功 / 错误变体** | ❌ **未给出** |
/// | **停留时长** | ❌ **未给出** |
///
/// 补齐依据 `CLAUDE.md` §7「不编造产品数据」与 §0「禁止自行修改产品规则」
/// 的边界处理：**只用项目已有的 Token 组合，不新造视觉语言**，
/// 并在此显式声明 —— 与 `CareerlyButton` 的 Disabled 态（D16）同一处置方式。
///
/// | Flutter 取值 | 来源 |
/// |---|---|
/// | 底 `AppColors.surfaceDark` | 与 `CareerlyTheme` 的 `snackBarTheme` 一致 |
/// | 字 `AppColors.textInverse` | 同上 |
/// | 圆角 `AppRadius.borderMd` | 同上 |
/// | 无投影 | 同上（`snackBarTheme.elevation = 0`） |
/// | 字号 `AppTypography.body` | 同上（`contentTextStyle`） |
///
/// ## 未实现（因设计侧未定义 · 见 **D26** 与 **K11**）
///
/// - **变体 / 色调**：设计侧没有成功 / 错误 / 警告的任何视觉区分。
///   因此本组件只有一个外观。`motion-spec` 提及的「已删除 · 撤销」
///   需要一个带操作按钮的 Toast，其视觉同样未定义。
/// - **不确定型的停留时长**：见 [_ToastMetrics.displayDuration]。
class CareerlyToast extends StatelessWidget {
  const CareerlyToast({super.key, required this.message, this.icon});

  /// 提示文字。
  final String message;

  /// 可选的前置图标。
  final IconData? icon;

  /// 在 Overlay 上展示一条轻提示。
  ///
  /// 不经过 Material `SnackBar` —— 依据 Baseline §6.5，
  /// Careerly 的视觉系统不由 M3 默认样式主导。
  /// `snackBarTheme` 仅作为第三方组件的兜底存在。
  ///
  /// [bottomOffset] 默认取 [AppConstants.navigationBarContentInset]，
  /// 即「避开浮起的底部导航」这一**既有项目常量**（Figma 内容区 `pb-24`），
  /// 而不是新造数值。
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Duration duration = _ToastMetrics.displayDuration,
    double bottomOffset = AppConstants.navigationBarContentInset,
  }) {
    final OverlayState overlay = Overlay.of(context);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) => _ToastPresenter(
        message: message,
        icon: icon,
        duration: duration,
        bottomOffset: bottomOffset,
        onDismissed: entry.remove,
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = AppTypography.onSurfaceVariant(
      AppTypography.body,
      AppColors.textInverse,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.borderMd,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(
                icon,
                size: _ToastMetrics.iconSize,
                color: AppColors.textInverse,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                message,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 组件的内部比例与补齐取值。
abstract final class _ToastMetrics {
  /// Figma `index.css`：`translateY(8px)`。
  static const double offset = 8;

  /// 图标尺寸。
  static const double iconSize = 18;

  /// 停留时长。
  ///
  /// ⚠️ **设计侧未定义**（核查结果：Figma 只给了进出动画的 160 / 180ms，
  /// 没有给停留时长）。此处 `2500ms` 是 **Flutter 侧补齐**，
  /// 可通过 [CareerlyToast.show] 的 `duration` 参数覆盖。
  ///
  /// **待裁决 · D32** —— 见 `docs/05_progress/` 待裁决清单 §3.1。
  /// ⚠️ 它**不在 D26 的授权范围内** —— D26 授权的是「用**已有** Token 补齐」，
  /// 而「停留时长」这个值在 Token 里根本不存在，属于**新造的数字**。
  static const Duration displayDuration = Duration(milliseconds: 2500);
}

/// 承载进出动画与自动消失的 Overlay 内容。
///
/// 动画真值（Figma `index.css` L225-235）：
/// - 进入 `160ms ease-out`，`translateY(8px) → 0`
/// - 退出 `180ms ease-in`，`translateY(0) → 8px`
///
/// ⚠️ **时长偏差（待裁决 · D33）**：两者统一取 [AppMotion.button]（`160ms`）。
/// 退出比 Figma 真值少 `20ms` —— 该 Token 自述区间为 `120–200ms`，
/// 160 与 180 均落在区间内，故**未自行新增 Token**。
/// 语义上 `button` 并非「轻提示」档，**是否补一档待裁决**。
class _ToastPresenter extends StatefulWidget {
  const _ToastPresenter({
    required this.message,
    required this.duration,
    required this.bottomOffset,
    required this.onDismissed,
    this.icon,
  });

  final String message;
  final IconData? icon;
  final Duration duration;
  final double bottomOffset;
  final VoidCallback onDismissed;

  @override
  State<_ToastPresenter> createState() => _ToastPresenterState();
}

class _ToastPresenterState extends State<_ToastPresenter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.button,
      reverseDuration: AppMotion.button,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.enter,
      reverseCurve: AppMotion.exit,
    );

    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;

    await _controller.reverse();
    if (!mounted) return;

    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      // 轻提示不应拦截其下方内容的点击。
      child: IgnorePointer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: widget.bottomOffset,
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget? child) {
                  final double t = _animation.value;
                  return Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * _ToastMetrics.offset),
                      child: child,
                    ),
                  );
                },
                // 轻提示是**瞬态**内容：用 liveRegion 让辅助技术主动播报，
                // 否则读屏用户会完全错过它。
                child: Semantics(
                  liveRegion: true,
                  container: true,
                  child: CareerlyToast(
                    message: widget.message,
                    icon: widget.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
