import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/tokens.dart';

/// Careerly 输入框的形态。
///
/// ⚠️ **这四档不是设计侧定义的枚举，而是 Flutter 侧对 Figma 4 处
/// 独立输入写法的归纳。** Figma 里**不存在统一的 Input 组件**，
/// 这 4 处是各页面各写各的。
///
/// | 变体 | Figma 位置 | 形态 |
/// |---|---|---|
/// | [underline] | `App.tsx` L510-541（旧版 Onboarding 表单） | 透明底 + **仅下边框** + 无圆角 |
/// | [boxed] | L1344-1390（工作台内联表单） | 半透明底 + 细边框 + `rounded-2xl` |
/// | [filled] | L1673-1722（a-jd-step 展开区） | 灰底 + **无边框** + `rounded-xl` |
/// | [plain] | L2631-2644（AI 对话输入） | 完全无底色无边框 |
/// | [outlined] | L469-479 / L675-684（登录 / 注册页） | 透明底 + **实色中性描边** + `r10` + **固定高 52** |
///
/// ## 为什么做成 5 个变体而不是 5 个组件
///
/// 遵循 D18「**变体用参数，不用新组件**」——
/// 五者的**行为**完全相同（都是文本输入），**只有样式不同**，
/// 因此是 variant 而不是 5 个 class。
///
/// ## ⚠️ 未做的收敛（属设计决策，不自行拍板）
///
/// 「多套输入样式是否应该统一成 1 套」是**视觉方向的重大决策**，
/// 按 `CLAUDE.md` §0 第一禁令**不得由 Flutter 侧自行拍板**。
/// 因此这里**原样保留各档**，让真实页面各自取用 ——
/// 页面上看到实际效果后再裁决是否需要收敛。
/// 登记为 **待裁决 · D45**，见 `docs/05_progress/` 待裁决清单 §3.1。
///
/// ⚠️ [outlined] 是 2026-10-04 重新导出的 Figma 带来的**第 5 种**写法，
/// 它与 [underline] **不是一套**（旧稿 Onboarding 表单是下划线，新稿是方框）。
/// 旧的 [underline] 目前仍被 **Phase 4 批 2** 的提交简历 / 确认页引用，
/// 因此**不删除**；`underline` 的最终去留属视觉方向决策，不在此拍板。
enum CareerlyInputVariant {
  /// 透明底 + 仅下边框。旧版 Onboarding 表单（提交简历 / 确认页仍用）。
  underline,

  /// 半透明底 + 细边框 + `rounded-2xl`。工作台内联表单。
  boxed,

  /// 灰底 + 无边框 + `rounded-xl`。a-jd-step 展开区。
  filled,

  /// 无底色无边框。AI 对话输入。
  plain,

  /// 透明底 + 1px `#C5B7D5` 描边 + 圆角 10 + **固定高 52**。登录 / 注册页。
  ///
  /// 真值来源：`App.tsx` 登录页 L469-479 与注册页 L675-684 的 `inputStyle`
  /// —— 两处**逐位一致**。标签**在框外上方**（同 [underline]），
  /// 而不是 [boxed] / [filled] 的行内标题位。
  outlined,
}

/// [CareerlyInputVariant.boxed] 的品牌色取向。
///
/// 真值来源：Figma 工作台内联表单有两处同构但不同色的写法 ——
/// 「粘贴岗位 JD」用蓝（L1344），「粘贴岗位链接」用紫（L1375）。
enum CareerlyInputTone {
  /// 品牌蓝。
  brand,

  /// 品牌紫。
  purple,
}

/// Careerly 输入框。
///
/// ```dart
/// // Onboarding 表单
/// CareerlyInput(
///   variant: CareerlyInputVariant.underline,
///   label: '姓名',
///   hint: '你的名字',
///   controller: nameController,
/// )
///
/// // 工作台内联表单（带字数上限）
/// CareerlyInput(
///   variant: CareerlyInputVariant.boxed,
///   label: '粘贴岗位 JD',
///   hint: '粘贴招聘描述（JD）内容…',
///   maxLines: null,
///   minLines: 5,
///   maxLength: 5000,
///   errorText: jdError,
/// )
/// ```
///
/// ## 四态（`CLAUDE.md` §5.5）
///
/// | 态 | 本组件的处置 |
/// |---|---|
/// | Disabled | ✅ [enabled] = `false` |
/// | Error | ✅ [errorText] 非空 |
/// | Loading | ❌ **不适用** —— 输入框自身没有「加载中」语义（提交中的按钮才有） |
/// | Empty | ✅ 即 hint 可见的空态，**不作为独立状态** |
/// | Retry | ❌ **不适用** —— 重试的主体是提交动作，不是输入框 |
///
/// 这三项不是遗漏：把 Loading / Retry 硬塞进输入框会造出
/// 没有任何 Figma 依据的形态。此处**显式声明不适用**，而不是假装齐全。
///
/// ## ⚠️ Figma 未定义的状态
///
/// `App.tsx` 中**完全不存在** `:focus` / `::placeholder` / `disabled:` /
/// `::selection` 规则，占位符用的是浏览器默认色。因此：
///
/// ```text
/// 聚焦态     → 用 AppColors 已有 Token 推导（D44 同类处置）
/// 占位符色    → 取 textTertiary
/// 错误态     → Figma 无任何输入框错误态，用 danger
/// 光标色     → Figma 有 caretColor 声明 ✅（品牌色）
/// ```
///
/// 前三项是**补齐而不是设计值**，验收时**不得盖章为视觉已定稿**
/// （依据 D26 的先例）。登记为 **待裁决 · D46**。
///
/// ⚠️ **有意未做**：把错误态边框改成红色 ——
/// Figma 没有任何输入框错误态，改成红色会让它看起来像设计定稿。
/// 未知的两项保持中性，只有**有出处**的禁用态才真的换色。
class CareerlyInput extends StatefulWidget {
  const CareerlyInput({
    super.key,
    this.variant = CareerlyInputVariant.underline,
    this.tone = CareerlyInputTone.brand,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.prefix,
    this.suffix,
  });

  /// 形态。默认 [CareerlyInputVariant.underline]（Onboarding 表单）。
  final CareerlyInputVariant variant;

  /// 品牌色取向，仅对 [CareerlyInputVariant.boxed] 生效。
  final CareerlyInputTone tone;

  /// 字段标题。
  ///
  /// 渲染位置随 [variant] 变化 —— `underline` 在上方（大写样式），
  /// `boxed` / `filled` 在容器内的行内标题位。
  final String? label;

  /// 占位提示。Figma 未定义占位符样式，取 `textTertiary`（见类文档）。
  final String? hint;

  /// 字段下方的辅助说明。
  ///
  /// [errorText] 非空时**不渲染** —— 两者争同一位置。
  final String? helperText;

  /// 错误文案。非空即进入 Error 态。
  final String? errorText;

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// `false` 时进入 Disabled 态。
  final bool enabled;

  final bool obscureText;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;

  /// 字数上限。非空时在标题行右侧显示 `已输入 / 上限`。
  ///
  /// 计数器的位置与写法来自 Figma `App.tsx` L1711-1713
  /// （`岗位描述` 与 `{len} / 5000` 同一行，两端对齐）。
  final int? maxLength;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// 输入区前置 / 后置插槽（图标、单位等）。
  final Widget? prefix;
  final Widget? suffix;

  @override
  State<CareerlyInput> createState() => _CareerlyInputState();
}

class _CareerlyInputState extends State<CareerlyInput> {
  late TextEditingController _controller;
  bool _ownsController = false;

  /// 已输入长度 —— 仅在 [CareerlyInput.maxLength] 非空时需要。
  int _length = 0;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant CareerlyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController();
    } else if (widget.controller == null) {
      // 自持控制器时，外部改 maxLength 不该丢内容；这里只同步一次长度。
      _length = _controller.text.length;
    }
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _attachController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _length = _controller.text.length;
  }

  void _detachController() {
    if (_ownsController) {
      _controller.dispose();
    }
  }

  bool get _isError => widget.errorText != null && widget.errorText!.isNotEmpty;

  /// 调用方传入的 formatter + 由 [CareerlyInput.maxLength] 推导的长度限制。
  List<TextInputFormatter>? get _effectiveFormatters {
    if (widget.maxLength == null) {
      return widget.inputFormatters;
    }
    return <TextInputFormatter>[
      ...?widget.inputFormatters,
      LengthLimitingTextInputFormatter(widget.maxLength),
    ];
  }

  void _handleChanged(String value) {
    if (widget.maxLength != null && value.length != _length) {
      setState(() => _length = value.length);
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final _InputSpec spec = _specFor(widget.variant, widget.tone);

    final TextStyle fieldStyle =
        widget.variant == CareerlyInputVariant.underline ||
            widget.variant == CareerlyInputVariant.outlined
        ? AppTypography.inputFieldUnderline
        : AppTypography.inputFieldCompact;

    final Color cursorColor = widget.tone == CareerlyInputTone.purple
        ? AppColors.primaryPurple
        : AppColors.primaryBlue;

    final Color hintColor = widget.enabled
        ? AppColors.textTertiary
        : AppColors.textDisabled;

    final Widget field = _buildField(
      spec: spec,
      fieldStyle: fieldStyle,
      cursorColor: cursorColor,
      hintColor: hintColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (_labelAbove) ...<Widget>[
          if (widget.label != null) ...<Widget>[
            Text(widget.label!, style: _labelAboveStyle),
            SizedBox(height: _labelAboveGap),
          ],
          _shell(spec, field),
        ] else ...<Widget>[
          _buildHeaderRow(),
          _SurfaceShell(spec: spec, enabled: widget.enabled, child: field),
        ],
        if (_isError)
          _buildFootnote(widget.errorText!, AppColors.danger)
        else if (widget.helperText != null)
          _buildFootnote(widget.helperText!, AppColors.inputHelper),
      ],
    );
  }

  /// 标签是否渲染在输入框**上方**（而不是容器内的行内标题位）。
  ///
  /// [CareerlyInputVariant.underline] 与 [CareerlyInputVariant.outlined]
  /// 的 Figma 结构都是 `label` → 间距 → 输入控件，两者同构。
  bool get _labelAbove =>
      widget.variant == CareerlyInputVariant.underline ||
      widget.variant == CareerlyInputVariant.outlined;

  /// 上方标签的文字角色。
  ///
  /// ⚠️ 两种形态的标签**视觉不同**（旧稿 `14/w700/#727272`，
  /// 新稿 `14/w400/#664293`），因此不是同一个 Token —— 见两个角色的文档。
  TextStyle get _labelAboveStyle =>
      widget.variant == CareerlyInputVariant.outlined
      ? AppTypography.authFieldLabel
      : AppTypography.inputLabel;

  /// 标签与输入控件之间的间距。
  ///
  /// 旧稿没有显式值，是 Flutter 侧补齐的（见 [_InputMetrics.underlineLabelGap]
  /// 与待裁决 · D48）；新稿 Figma 写的是 `gap-1.5`（6px），有明确依据。
  double get _labelAboveGap => widget.variant == CareerlyInputVariant.outlined
      ? AppSpacing.authLabelGap
      : _InputMetrics.underlineLabelGap;

  /// 输入区外壳：只有 [CareerlyInputVariant.underline] 是「仅下边框」。
  Widget _shell(_InputSpec spec, Widget field) {
    if (widget.variant == CareerlyInputVariant.underline) {
      return _UnderlineShell(
        color: widget.enabled ? AppColors.inputBorderBrand : AppColors.divider,
        child: field,
      );
    }
    return _SurfaceShell(spec: spec, enabled: widget.enabled, child: field);
  }

  /// `boxed` / `filled` / `plain` 的行内标题行。
  ///
  /// 计数器与标题**同一行、两端对齐** —— 还原 Figma `App.tsx` L1711-1713。
  Widget _buildHeaderRow() {
    final String? counter = widget.maxLength == null
        ? null
        : '$_length / ${widget.maxLength}';

    if (widget.label == null && counter == null) {
      return const SizedBox.shrink();
    }

    final TextStyle labelStyle =
        widget.variant == CareerlyInputVariant.plain
            ? AppTypography.inputHelper
            : AppTypography.onSurfaceVariant(
                AppTypography.inputLabelInline,
                widget.tone == CareerlyInputTone.purple
                    ? AppColors.primaryPurple
                    : AppColors.primaryBlue,
              );

    return Padding(
      padding: EdgeInsets.only(
        left: _InputMetrics.headerLeftInset(widget.variant),
        right: _InputMetrics.headerLeftInset(widget.variant),
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          if (widget.label != null)
            Expanded(
              child: Text(
                widget.label!,
                style: labelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          if (counter != null)
            Text(counter, style: AppTypography.inputHelper),
        ],
      ),
    );
  }

  Widget _buildFootnote(String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.xxs,
        left: _InputMetrics.footnoteLeftInset(widget.variant),
      ),
      child: Text(
        text,
        style: AppTypography.onSurfaceVariant(AppTypography.inputHelper, color),
      ),
    );
  }

  Widget _buildField({
    required _InputSpec spec,
    required TextStyle fieldStyle,
    required Color cursorColor,
    required Color hintColor,
  }) {
    final TextStyle effectiveStyle = widget.enabled
        ? fieldStyle
        : AppTypography.onSurfaceVariant(fieldStyle, AppColors.textDisabled);

    final Widget textField = TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: _effectiveFormatters,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      cursorColor: cursorColor,
      cursorWidth: _InputMetrics.cursorWidth,
      style: effectiveStyle,
      // ⚠️ 用 `collapsed` 彻底绕开 Material 的 `InputDecoration` ——
      // 依据 D44，`CareerlyTheme._inputDecorationTheme` 那套
      // `filled + OutlineInputBorder` 在 Figma 中**没有任何对应**，
      // 这里若沿用就会与 Figma 的 4 种真实形态全部冲突。
      //
      // ⚠️ **也不把 [CareerlyInput.maxLength] 透传给 `TextField.maxLength`** ——
      // 那会让 Material 在输入框右下角自绘一个计数器，与 Figma 的
      // 「标题行右端」计数器（`App.tsx` L1711-1713）位置冲突，且样式无依据。
      // 因此长度限制改用 `LengthLimitingTextInputFormatter` 实现，
      // 计数器由本组件在标题行自绘。
      decoration: InputDecoration.collapsed(
        hintText: widget.hint,
        hintStyle: AppTypography.onSurfaceVariant(
          fieldStyle,
          hintColor,
        ),
      ),
    );

    if (widget.prefix == null && widget.suffix == null) {
      return textField;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.prefix != null) ...<Widget>[
          widget.prefix!,
          const SizedBox(width: AppSpacing.xs),
        ],
        Expanded(child: textField),
        if (widget.suffix != null) ...<Widget>[
          const SizedBox(width: AppSpacing.xs),
          widget.suffix!,
        ],
      ],
    );
  }
}

/// 一个变体的全部视觉取值。
typedef _InputSpec = ({
  EdgeInsets padding,
  double minHeight,
  /// 非空时输入区用**固定高度**（`SizedBox`），而不是 `minHeight` 约束。
  ///
  /// 两者不是一回事：`minHeight` 只保证「不低于」，单行内容会顶到上沿；
  /// 登录 / 注册页的方框是 Figma 写死的 `height: 52` 且文字**垂直居中**，
  /// 因此必须走固定高度 + 居中。
  double? height,
  Color fill,
  Color? border,
  double borderWidth,
  BorderRadius radius,
});

/// 变体 + 色调 → 视觉取值。
///
/// 全部取自 `AppColors` / `AppRadius` / `AppSpacing`，组件内不写死数值。
_InputSpec _specFor(CareerlyInputVariant variant, CareerlyInputTone tone) {
  final bool purple = tone == CareerlyInputTone.purple;

  return switch (variant) {
    // 透明底 + 仅下边框。边框由 `_UnderlineShell` 单独绘制，
    // 因此这里 border 为 null、padding 上下留白用 Figma 原值 4 / 10。
    CareerlyInputVariant.underline => (
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      minHeight: 0,
      height: null,
      fill: Colors.transparent,
      border: null,
      borderWidth: 0,
      radius: BorderRadius.zero,
    ),
    // 半透明底 + 细边框 + rounded-2xl。Figma L1344 / L1375。
    CareerlyInputVariant.boxed => (
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      minHeight: _InputMetrics.multilineMinHeight,
      height: null,
      fill: purple ? AppColors.inputSurfacePurple : AppColors.inputSurfaceBrand,
      border: purple
          ? AppColors.inputBorderPurple
          : AppColors.inputBorderBrand,
      borderWidth: _InputMetrics.boxedBorderWidth,
      radius: AppRadius.borderMd,
    ),
    // 灰底 + 无边框 + rounded-xl。Figma L1677-1678。
    CareerlyInputVariant.filled => (
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      minHeight: _InputMetrics.multilineMinHeight,
      height: null,
      fill: AppColors.inputSurfaceFilled,
      border: null,
      borderWidth: 0,
      radius: AppRadius.borderXs,
    ),
    // 无底色无边框。Figma L2631-2644。
    CareerlyInputVariant.plain => (
      padding: EdgeInsets.zero,
      minHeight: 0,
      height: null,
      fill: Colors.transparent,
      border: null,
      borderWidth: 0,
      radius: BorderRadius.zero,
    ),
    // 透明底 + 实色中性描边 + r10 + 固定高 52。Figma L469-479 / L675-684。
    //
    // ⚠️ 描边色用 `authFieldBorder`（`#C5B7D5`）而**不是**品牌色 ——
    // 新稿这里刻意是中性紫灰，与 [boxed] 的两种品牌色取向都不是一套。
    // 因此本变体**忽略 [CareerlyInputTone]**（`tone` 的文档已声明该字段
    // 只对 `boxed` 生效）。
    CareerlyInputVariant.outlined => (
      padding: const EdgeInsets.symmetric(
        horizontal: _InputMetrics.outlinedHorizontalPadding,
      ),
      minHeight: 0,
      height: _InputMetrics.outlinedHeight,
      fill: Colors.transparent,
      border: AppColors.authFieldBorder,
      borderWidth: _InputMetrics.outlinedBorderWidth,
      radius: AppRadius.borderAuthField,
    ),
  };
}

/// 只有下边框的外壳（`underline` 变体）。
///
/// Figma `borderBottom: 1.217px solid rgba(79,126,245,0.25)` ——
/// 其余三边无边框、无圆角。
class _UnderlineShell extends StatelessWidget {
  const _UnderlineShell({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: color, width: _InputMetrics.underlineWidth),
        ),
      ),
      child: child,
    );
  }
}

/// 带填充 / 可选边框 / 圆角的外壳（`boxed` / `filled` / `plain`）。
class _SurfaceShell extends StatelessWidget {
  const _SurfaceShell({
    required this.spec,
    required this.enabled,
    required this.child,
  });

  final _InputSpec spec;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool hasFill = spec.fill != Colors.transparent;
    final bool hasBorder = spec.border != null;

    return ClipRRect(
      borderRadius: spec.radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: hasFill
              ? (enabled ? spec.fill : AppColors.inputSurfaceDisabled)
              : null,
          borderRadius: spec.radius,
          border: hasBorder
              ? Border.all(
                  color: enabled ? spec.border! : AppColors.divider,
                  width: spec.borderWidth,
                )
              : null,
        ),
        child: Padding(
          padding: spec.padding,
          child: _sizedContent(child),
        ),
      ),
    );
  }

  /// 固定高度（[outlined]）走 `SizedBox` + 垂直居中；其余走 `minHeight` 约束。
  ///
  /// ⚠️ 居中这一层是必须的：单行的 `TextField` 只有约 24px 高，
  /// 在 52px 的框里若不居中就会顶到上沿 —— 这与 Figma 的
  /// `height: 52` + 浏览器默认 `input` 居中行为不符。
  Widget _sizedContent(Widget child) {
    if (spec.height != null) {
      return SizedBox(
        height: spec.height,
        child: Align(alignment: Alignment.centerLeft, child: child),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: spec.minHeight),
      child: child,
    );
  }
}

/// 组件内不被 Token 覆盖的几何常量。
///
/// ⚠️ 这里的数值分两类 ——
/// **Figma 原值**（`underlineWidth` / `boxedBorderWidth` / 两处 padding /
/// `multilineMinHeight` 的 120）与 **Flutter 侧补齐**（`cursorWidth` /
/// `underlineLabelGap`）。后者登记为 **待裁决 · D48**，
/// 见 `docs/05_progress/` 待裁决清单 §3.1。
abstract final class _InputMetrics {
  /// Figma `1.217px`（`INPUT_BASE` 的 `borderBottom`）。
  static const double underlineWidth = 1.217;

  /// Figma `1.5px`（工作台内联表单容器边框）。
  static const double boxedBorderWidth = 1.5;

  /// Figma `minHeight: 120`（JD 多行输入区）。
  static const double multilineMinHeight = 120;

  /// Figma `height: 52`（登录 / 注册页方框输入框）。
  static const double outlinedHeight = 52;

  /// Figma `1px solid #c5b7d5`（登录 / 注册页方框输入框描边宽度）。
  static const double outlinedBorderWidth = 1;

  /// Figma `padding: '0 14px'`（登录 / 注册页方框输入框内边距）。
  ///
  /// ⚠️ 取 `14` 而**不是** [AppSpacing.sm]（12）或 [AppSpacing.md]（16）——
  /// 它是 Figma 原值，落在刻度之间，同 [boxedBorderWidth] 的处置。
  static const double outlinedHorizontalPadding = 14;

  /// ⚠️ **Flutter 侧补齐 · 待视觉验证（待裁决 · D48）** ——
  /// Figma 的 `LABEL` 与输入框之间**没有显式间距**（靠 `p` 的默认边距，
  /// 而 Tailwind preflight 会把它清零），因此没有设计原值可取。
  /// 取 `4` 是因为输入框自身有 `paddingTop: 4`，视觉上形成连续留白。
  ///
  /// ⚠️ 这是**在真实页面上最可能看出问题**的一项 ——
  /// 它影响所有 Onboarding 表单的纵向节奏。
  static const double underlineLabelGap = AppSpacing.xxs;

  /// ⚠️ **Flutter 侧补齐（待裁决 · D48）** —— Figma 未定义光标宽度。
  /// 取 `1.5` 与输入框描边同量级。
  static const double cursorWidth = 1.5;

  /// `boxed` 变体的行内标题需要同容器内边距对齐。
  static double headerLeftInset(CareerlyInputVariant variant) {
    return switch (variant) {
      CareerlyInputVariant.boxed => AppSpacing.sm,
      CareerlyInputVariant.filled => AppSpacing.sm,
      // `plain` / `underline` / `outlined` 的标题在容器之外（见
      // [CareerlyInputVariant.outlined] 的说明），不需要额外缩进。
      CareerlyInputVariant.plain ||
      CareerlyInputVariant.underline ||
      CareerlyInputVariant.outlined => 0,
    };
  }

  /// 字段下方说明文字的缩进，与输入区左沿对齐。
  static double footnoteLeftInset(CareerlyInputVariant variant) {
    return switch (variant) {
      CareerlyInputVariant.boxed => AppSpacing.sm,
      CareerlyInputVariant.filled => AppSpacing.sm,
      // Figma 的辅助说明（L1387）自带 `mt-2`，左沿与输入区一致，
      // 而 `underline` / `outlined` 变体没有对应设计，取 0 保持与标签左对齐。
      CareerlyInputVariant.plain ||
      CareerlyInputVariant.underline ||
      CareerlyInputVariant.outlined => 0,
    };
  }
}
