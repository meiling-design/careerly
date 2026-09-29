import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// 底部导航的三个标准 Tab 所使用的图标字形。
///
/// ## 为什么是枚举，而不是 `IconData`
///
/// Figma 的三个 Tab 图标是**定制 SVG 路径**（见 `src/App.tsx` 的
/// `IconHome` / `IconChart` / `IconUser`），不是 Material 图标。
/// 其中「分析」是**三根圆角柱子**，与 Material 的折线图语义完全不同。
///
/// 按 Baseline §1.2「Figma 有视觉但 Flutter 没有实现方式 → 重新实现」，
/// 这里用 `CustomPainter` 逐条还原 SVG 路径，
/// 路径真值见 [_CareerlyNavGlyphPainter]。
enum CareerlyNavGlyph {
  /// 首页：房子轮廓（选中时填充）。
  home,

  /// 分析：三根圆角柱状条（选中 / 未选中都是实心，只换颜色）。
  analysis,

  /// 我的：头肩人像（选中时头部填充、肩部描边）。
  profile,
}

/// 底部导航的一个目的地。
@immutable
class CareerlyNavDestination {
  /// 标准 Tab（首页 / 分析 / 我的）。
  ///
  /// [label] 是**无障碍语义标签**——Figma 的三个标准 Tab **不显示文字**，
  /// 但 `Semantics` 仍需要标签，读屏用户才不至于面对三个无名按钮。
  const CareerlyNavDestination.standard({
    required this.label,
    required this.glyph,
  }) : isSpecial = false;

  /// AI 入口（条外的品牌渐变浮球）。
  ///
  /// Figma 中 AI 球**自带可见文字标签**「AI」，与三个标准 Tab 相反。
  const CareerlyNavDestination.ai({this.label = 'AI'})
    : glyph = null,
      isSpecial = true;

  /// 标签。标准 Tab 仅用于无障碍；AI 同时是可见文案。
  final String label;

  /// 图标字形。AI 入口为 `null`（它用 `✦` 字符 + 文字，不是路径字形）。
  final CareerlyNavGlyph? glyph;

  /// 是否为 AI 入口。
  final bool isSpecial;
}

/// Careerly 自绘底部导航。
///
/// ## 结构（严格取自 Figma `src/App.tsx` 的 `BottomNav`，行 235–334）
///
/// ```text
///         ┌──────────────┐
///         │ ▢   ▢   ▢    │        ╭───╮
///         └──────────────┘        │ ✦ │
///                                 │ AI│
///                                 ╰───╯
///          玻璃条 232×60            AI 62×62
///                    ←── gap 10 ──→
/// ```
///
/// 它是**居中的玻璃胶囊条 + 条外右侧的独立 AI 浮球**，
/// **不是**一根通栏底栏。因此本组件应当以浮层形式压在内容之上，
/// 而不是占据 `Scaffold.bottomNavigationBar` 的流式位置。
///
/// ## 为什么不用 Material 3 `NavigationBar`
///
/// Baseline §6.5 / 决策 9：自绘 Careerly Navigation，**不使用 M3 `NavigationBar`**。
/// M3 无法表达：Liquid Glass 材质、选中态滑动 morph、
/// 定制字形、条外 AI 浮球。
///
/// ## 与 Figma 的逐项对应
///
/// | Figma | 实现位置 |
/// |---|---|
/// | 6 层 `inset box-shadow` | [_GlassEdgePainter]（Flutter `BoxShadow` 不支持 inset） |
/// | `backdrop-filter` | [_GlassFilters.navBar]（blur + saturate + brightness + contrast 合成） |
/// | 滑动药丸 `left` 过渡 | [AnimatedPositioned] + [AppMotion.emphasized] |
/// | 图标 SVG 路径 | [_CareerlyNavGlyphPainter] |
/// | AI 球 `opacity` 切换 | [Opacity] |
///
/// > ⚠️ **Phase 1 的 4 等分通栏实现已被本版本取代。**
/// > 那次实现把 AI 放在条内第 3 个位置、用 Material 图标 + 中文标签，
/// > 与 Figma 不符；本版本按「Figma 视觉优先」重做。
class CareerlyNavigationBar extends StatelessWidget {
  const CareerlyNavigationBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
  });

  /// 目的地列表，**顺序必须与 `AppRoutes.shellBranches` 一致**。
  final List<CareerlyNavDestination> destinations;

  /// 当前选中索引（对 [destinations] 的下标）。
  final int currentIndex;

  /// 点击回调。
  final ValueChanged<int> onSelect;

  /// 玻璃胶囊条的三个标准 Tab（顺序即展示顺序）。
  ///
  /// Figma 把 AI **排除在玻璃条之外**，所以这里先按 [isSpecial] 分流。
  List<int> get _barIndices => <int>[
    for (int i = 0; i < destinations.length; i++)
      if (!destinations[i].isSpecial) i,
  ];

  /// 条外 AI 入口的下标；没有则为 `null`。
  int? get _aiIndex {
    for (int i = 0; i < destinations.length; i++) {
      if (destinations[i].isSpecial) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<int> barIndices = _barIndices;
    final int? aiIndex = _aiIndex;

    // 自适应：标准 Tab 决定玻璃条宽度，避免把 3 写死。
    final double barWidth =
        _NavMetrics.barPaddingH * 2 +
        barIndices.length * _NavMetrics.tabWidth +
        (barIndices.length - 1).clamp(0, 99) * _NavMetrics.tabGap;

    // 选中项在当前可见的标准 Tab 中的序号；选中 AI 时为 -1（药丸不出现）。
    final int activeSlot = barIndices.indexOf(currentIndex);

    return SafeArea(
      top: false,
      child: Padding(
        // Figma：`pt-2 pb-5` → 上 8 / 下 20。
        padding: const EdgeInsets.only(
          top: _NavMetrics.rowPaddingTop,
          bottom: _NavMetrics.rowPaddingBottom,
        ),
        child: Row(
          // `mainAxisSize.min` + `center`：整组居中，而不是撑满。
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _GlassBar(
              width: barWidth,
              slots: barIndices,
              destinations: destinations,
              currentIndex: currentIndex,
              activeSlot: activeSlot,
              onSelect: onSelect,
            ),
            if (aiIndex != null) ...<Widget>[
              // Figma：玻璃条与 AI 球之间 `gap: 10px`。
              const SizedBox(width: _NavMetrics.rowGap),
              _AiOrb(
                destination: destinations[aiIndex],
                isSelected: aiIndex == currentIndex,
                onTap: () => onSelect(aiIndex),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 玻璃胶囊条
// -----------------------------------------------------------------------------

/// Figma `BottomNav` 的玻璃胶囊条：外圈高光 → 玻璃面 → 滑动药丸 → 三个按钮。
class _GlassBar extends StatelessWidget {
  const _GlassBar({
    required this.width,
    required this.slots,
    required this.destinations,
    required this.currentIndex,
    required this.activeSlot,
    required this.onSelect,
  });

  final double width;

  /// 参与玻璃条的标准 Tab 下标（相对 [destinations]）。
  final List<int> slots;

  final List<CareerlyNavDestination> destinations;
  final int currentIndex;

  /// 选中项在 [slots] 中的序号；`-1` 表示选中的是 AI（药丸收起）。
  final int activeSlot;

  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // 外圈高光比玻璃条大 1px（Figma `inset: -1px`），需要负向溢出。
      clipBehavior: Clip.none,
      children: <Widget>[
        // ① 外圈高光：比玻璃条大 1px 的环，只露出 1px 边框。
        Positioned(
          left: -1,
          top: -1,
          right: -1,
          bottom: -1,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.navGlassEdgeFill,
                borderRadius: BorderRadius.circular(_NavMetrics.barRadius + 1),
                border: Border.all(
                  color: AppColors.navGlassEdgeBorder,
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),

        // ② 玻璃面。
        ClipRRect(
          borderRadius: BorderRadius.circular(_NavMetrics.barRadius),
          child: BackdropFilter(
            filter: _GlassFilters.navBar,
            child: SizedBox(
              width: width,
              height: _NavMetrics.barHeight,
              child: CustomPaint(
                // glass 的描边 + 4 层 inset 高光。Flutter 无 inset shadow，
                // 由 painter 以「裁剪到圆角矩形 + 内缩色带」重绘。
                foregroundPainter: const _GlassEdgePainter(
                  radius: _NavMetrics.barRadius,
                  borderColor: AppColors.navGlassBorder,
                  borderWidth: 0.5,
                  highlights: _NavHighlights.bar,
                ),
                child: Stack(
                  children: <Widget>[
                    // ③ 选中态滑动玻璃药丸。选中 AI 时 Figma 直接不渲染它
                    //    （条件渲染，无退出过渡），这里保持一致。
                    if (activeSlot >= 0)
                      AnimatedPositioned(
                        duration: AppMotion.navPill,
                        // Figma `cubic-bezier(0.34, 1.2, 0.64, 1)` ——
                        // 带回弹过冲，正是 AppMotion.emphasized 的原值。
                        curve: AppMotion.emphasized,
                        left:
                            _NavMetrics.barPaddingH +
                            activeSlot *
                                (_NavMetrics.tabWidth + _NavMetrics.tabGap),
                        top: _NavMetrics.barPaddingV,
                        width: _NavMetrics.tabWidth,
                        height: _NavMetrics.tabHeight,
                        child: const _SelectionPill(),
                      ),

                    // ④ 三个 Tab 按钮。
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _NavMetrics.barPaddingH,
                        vertical: _NavMetrics.barPaddingV,
                      ),
                      child: Row(
                        children: <Widget>[
                          for (int i = 0; i < slots.length; i++) ...<Widget>[
                            if (i > 0)
                              const SizedBox(width: _NavMetrics.tabGap),
                            _NavTabButton(
                              destination: destinations[slots[i]],
                              isSelected: slots[i] == currentIndex,
                              onTap: () => onSelect(slots[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 选中态滑动玻璃药丸。
class _SelectionPill extends StatelessWidget {
  const _SelectionPill();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_NavMetrics.pillRadius),
      child: BackdropFilter(
        // Figma 药丸：`backdrop-filter: blur(6px)`。
        filter: _GlassFilters.navPill,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.navPillFill,
            borderRadius: BorderRadius.circular(_NavMetrics.pillRadius),
            boxShadow: AppShadows.navPill,
          ),
          child: CustomPaint(
            foregroundPainter: const _GlassEdgePainter(
              radius: _NavMetrics.pillRadius,
              borderColor: AppColors.navPillBorder,
              borderWidth: _NavMetrics.pillBorderWidth,
              highlights: _NavHighlights.pill,
            ),
          ),
        ),
      ),
    );
  }
}

/// 玻璃条上的一个标准 Tab。
class _NavTabButton extends StatefulWidget {
  const _NavTabButton({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final CareerlyNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavTabButton> createState() => _NavTabButtonState();
}

class _NavTabButtonState extends State<_NavTabButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          // Figma：`transform 120ms cubic-bezier(0.25,0.46,0.45,0.94)`。
          scale: _pressed ? AppMotion.pressScale : 1.0,
          duration: AppMotion.micro,
          curve: AppMotion.standard,
          child: SizedBox(
            width: _NavMetrics.tabWidth,
            height: _NavMetrics.tabHeight,
            child: Center(
              child: CustomPaint(
                size: const Size.square(_NavMetrics.iconSize),
                painter: _CareerlyNavGlyphPainter(
                  glyph: widget.destination.glyph!,
                  active: widget.isSelected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// AI 浮球
// -----------------------------------------------------------------------------

/// 条外的 AI 入口：品牌渐变玻璃球 + `✦` + 「AI」。
class _AiOrb extends StatefulWidget {
  const _AiOrb({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final CareerlyNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<_AiOrb> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          // Figma：AI 球按下 `scale(0.94)`，比标准 Tab 的 0.96 更深。
          scale: _pressed ? AppMotion.pressScaleOrb : 1.0,
          duration: AppMotion.micro,
          curve: AppMotion.standard,
          // Figma 选中态只改 `opacity`（1 / 0.88），尺寸与配色都不变。
          child: AnimatedOpacity(
            opacity: widget.isSelected ? 1.0 : _NavMetrics.aiIdleOpacity,
            duration: AppMotion.smallComponent,
            curve: AppMotion.standard,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppShadows.navAiOrb,
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: _GlassFilters.aiOrb,
                  child: Container(
                    width: _NavMetrics.aiSize,
                    height: _NavMetrics.aiSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.aiOrbGradient,
                      border: Border.all(
                        color: AppColors.navOrbBorder,
                        width: 0.5,
                      ),
                    ),
                    child: CustomPaint(
                      foregroundPainter: const _GlassEdgePainter(
                        radius: _NavMetrics.aiSize / 2,
                        borderColor: AppColors.navOrbBorder,
                        borderWidth: 0.5,
                        highlights: _NavHighlights.aiOrb,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('✦', style: AppTypography.navAiGlyph),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'AI',
                              style: AppTypography.navAiLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// -----------------------------------------------------------------------------
// 几何常量（真值来源：Figma `src/App.tsx` BottomNav，行 240–331）
// -----------------------------------------------------------------------------

/// 底部导航的几何取值。
///
/// 这些是**组件内部比例**，不是业务可调项，因此留在组件文件内，
/// 不进入 `AppSpacing`（间距 Token 服务于页面级排布）。
abstract final class _NavMetrics {
  /// 玻璃条内边距：Figma `padding: 5px 6px`。
  static const double barPaddingH = 6;
  static const double barPaddingV = 5;

  /// 单个 Tab 按钮：Figma `width: 72, height: 50`。
  static const double tabWidth = 72;
  static const double tabHeight = 50;

  /// Tab 之间：Figma `gap: 2`。
  static const double tabGap = 2;

  /// 玻璃条圆角：Figma `borderRadius: 30`。
  static const double barRadius = 30;

  // 条高 = 5×2 + 50 = 60；条宽由 Tab 数量推导（3 个 → 232）。
  static const double barHeight = barPaddingV * 2 + tabHeight;

  /// 选中态药丸圆角：Figma `borderRadius: 22`。
  static const double pillRadius = 22;

  /// 药丸描边：Figma `1.163px`。
  static const double pillBorderWidth = 1.163;

  /// 图标尺寸：Figma `width/height = 22`。
  static const double iconSize = 22;

  /// 玻璃条与 AI 球之间：Figma `gap: 10`。
  static const double rowGap = 10;

  /// 整组上 / 下留白：Figma `pt-2 pb-5` → 8 / 20。
  static const double rowPaddingTop = 8;
  static const double rowPaddingBottom = 20;

  /// AI 浮球直径：Figma `62 × 62`。
  static const double aiSize = 62;

  /// AI 球未选中时的不透明度：Figma `opacity: 0.88`。
  static const double aiIdleOpacity = 0.88;
}

// -----------------------------------------------------------------------------
// Backdrop 滤镜
// -----------------------------------------------------------------------------

/// 把 CSS `backdrop-filter` 翻译成 Flutter [ui.ImageFilter]。
///
/// CSS 的滤镜链是**先写先应用**：`blur(10px) saturate(190%) ...`
/// 意味着先模糊、再饱和、最后对比度。
/// [ui.ImageFilter.compose] 则是 `inner` 先于 `outer`，
/// 因此最内层是 blur，最外层是最后应用的色彩矩阵。
///
/// 三个色彩函数被**预先乘成一个矩阵**，避免每帧叠 3 层 compose。
abstract final class _GlassFilters {
  /// 玻璃条：`blur(10px) saturate(190%) brightness(1.06) contrast(1.01)`。
  static final ui.ImageFilter navBar = ui.ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate190Brightness106Contrast101),
    // ⚠️ CSS `blur(Npx)` 的参数是高斯**标准差**，
    //    对应 Flutter 的 `sigmaX/sigmaY`，不是直径。
    inner: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  );

  /// 药丸：`blur(6px)`。
  static final ui.ImageFilter navPill = ui.ImageFilter.blur(
    sigmaX: 6,
    sigmaY: 6,
  );

  /// AI 球：`blur(10px) saturate(200%) brightness(1.1)`。
  static final ui.ImageFilter aiOrb = ui.ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate200Brightness110),
    inner: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  );

  // saturate(1.9) → brightness(1.06) → contrast(1.01) 的乘积。
  // 对比度偏移 = (1 - 1.01) × 0.5 × 255 ≈ -1.275。
  static const List<double> _saturate190Brightness106Contrast101 =
      <double>[
        1.82891, -0.68893, -0.06938, 0, -1.275, //
        -0.20524, 1.34521, -0.06938, 0, -1.275, //
        -0.20524, -0.68893, 1.96477, 0, -1.275, //
        0, 0, 0, 1, 0,
      ];

  // saturate(2.0) → brightness(1.1) 的乘积。
  static const List<double> _saturate200Brightness110 = <double>[
    1.9657, -0.7865, -0.0792, 0, 0, //
    -0.2343, 1.4135, -0.0792, 0, 0, //
    -0.2343, -0.7865, 2.1208, 0, 0, //
    0, 0, 0, 1, 0,
  ];
}

// -----------------------------------------------------------------------------
// Glass 描边 + inset 高光
// -----------------------------------------------------------------------------

/// inset 高光的贴边方向。
enum _GlassEdge { top, bottom, left, right }

/// 一层 inset 高光：`(edge, color, thickness)`。
///
/// 用 record 而非 class —— record 自带结构化相等，
/// 让 [_GlassEdgePainter.shouldRepaint] 可以逐层比较。
typedef _InsetHighlight = ({_GlassEdge edge, Color color, double thickness});

/// Figma 各 Glass 层的 inset 高光集合。
abstract final class _NavHighlights {
  /// 玻璃条：4 层。
  /// `inset 0 1.5px 0 rgba(255,255,255,.62)`（视觉主导）
  /// + 底 1px / 左 1px / 右 1px。
  static const List<_InsetHighlight> bar = <_InsetHighlight>[
    (edge: _GlassEdge.top, color: AppColors.navInsetTop, thickness: 1.5),
    (
      edge: _GlassEdge.bottom,
      color: AppColors.navInsetBottom,
      thickness: 1,
    ),
    (edge: _GlassEdge.left, color: AppColors.navInsetLeft, thickness: 1),
    (edge: _GlassEdge.right, color: AppColors.navInsetRight, thickness: 1),
  ];

  /// 药丸：`inset 0 1px 0 rgba(255,255,255,.55)`。
  static const List<_InsetHighlight> pill = <_InsetHighlight>[
    (edge: _GlassEdge.top, color: AppColors.navPillInsetTop, thickness: 1),
  ];

  /// AI 球：顶 `rgba(255,255,255,.5)` + 底 `rgba(79,126,245,.2)`。
  static const List<_InsetHighlight> aiOrb = <_InsetHighlight>[
    (edge: _GlassEdge.top, color: AppColors.navOrbInsetTop, thickness: 1.5),
    (
      edge: _GlassEdge.bottom,
      color: AppColors.navOrbInsetBottom,
      thickness: 1,
    ),
  ];
}

/// 绘制 Glass 的描边与 inset 高光。
///
/// ## 为什么需要它
///
/// Flutter 的 `BoxShadow` **不支持 `inset`**，而 Figma 的 Glass 材质
/// 主要靠 inset 高光撑起「玻璃厚度」（见 K5）。
/// 这里用最贴近 CSS 语义的方式重绘：
/// **裁剪到圆角矩形，再沿指定边画一条内缩色带**。
///
/// CSS `inset 0 1.5px 0 <c>` 在 blur / spread 均为 0 时，
/// 正是「顶边内侧 1.5px 的一条实心带」——与此实现一一对应。
class _GlassEdgePainter extends CustomPainter {
  const _GlassEdgePainter({
    required this.radius,
    required this.borderColor,
    required this.borderWidth,
    required this.highlights,
  });

  final double radius;
  final Color borderColor;
  final double borderWidth;
  final List<_InsetHighlight> highlights;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    // 高光：裁剪到形状内，沿边画带。
    canvas.save();
    canvas.clipRRect(shape);
    for (final _InsetHighlight h in highlights) {
      final Rect band = switch (h.edge) {
        _GlassEdge.top => Rect.fromLTWH(0, 0, size.width, h.thickness),
        _GlassEdge.bottom => Rect.fromLTWH(
          0,
          size.height - h.thickness,
          size.width,
          h.thickness,
        ),
        _GlassEdge.left => Rect.fromLTWH(0, 0, h.thickness, size.height),
        _GlassEdge.right => Rect.fromLTWH(
          size.width - h.thickness,
          0,
          h.thickness,
          size.height,
        ),
      };
      canvas.drawRect(band, Paint()..color = h.color);
    }
    canvas.restore();

    // 描边最后画，压在高光之上。
    // 描边以路径为中心线，内缩半个线宽才能让整条线落在形状内。
    final double inset = borderWidth / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          inset,
          inset,
          size.width - borderWidth,
          size.height - borderWidth,
        ),
        Radius.circular(radius - inset),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor,
    );
  }

  @override
  bool shouldRepaint(covariant _GlassEdgePainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth ||
      !listEquals(oldDelegate.highlights, highlights);
}

// -----------------------------------------------------------------------------
// 导航图标字形
// -----------------------------------------------------------------------------

/// 按 Figma 的 SVG 路径绘制导航图标。
///
/// 路径真值：`src/App.tsx` 的 `IconHome` / `IconChart` / `IconUser`（行 194–232）。
/// 所有坐标都在 **24×24 viewBox** 内，绘制时整体缩放到 [Size]，
/// 因此 `strokeWidth: 1.7` 也随之缩放 ——
/// 22px 下即为 `1.7 × 22/24 ≈ 1.558`，
/// 与 Figma 原始导出的 `strokeWidth="1.55822"` 完全吻合。
///
/// 选中态不是「换一个图标」，而是**同一路径改用品牌渐变**：
/// 首页由描边变填充、分析只换颜色、我的头部填充且肩部描边。
class _CareerlyNavGlyphPainter extends CustomPainter {
  const _CareerlyNavGlyphPainter({required this.glyph, required this.active});

  final CareerlyNavGlyph glyph;
  final bool active;

  /// Figma SVG 的 viewBox 边长。
  static const double _viewBox = 24;

  /// Figma 统一描边宽度（24 单位空间内）。
  static const double _strokeWidth = 1.7;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _viewBox);

    switch (glyph) {
      case CareerlyNavGlyph.home:
        _paintHome(canvas);
      case CareerlyNavGlyph.analysis:
        _paintAnalysis(canvas);
      case CareerlyNavGlyph.profile:
        _paintProfile(canvas);
    }

    canvas.restore();
  }

  /// 首页：房子轮廓。选中时**同时填充与描边**。
  void _paintHome(Canvas canvas) {
    final Path path = Path()
      ..moveTo(3, 10.5)
      ..lineTo(12, 3)
      ..lineTo(21, 10.5)
      ..lineTo(21, 20)
      ..cubicTo(21, 20.55, 20.55, 21, 20, 21)
      ..lineTo(15, 21)
      ..lineTo(15, 15)
      ..lineTo(9, 15)
      ..lineTo(9, 21)
      ..lineTo(4, 21)
      ..cubicTo(3.45, 21, 3, 20.55, 3, 20)
      ..close();

    if (active) {
      canvas.drawPath(path, _paint());
    }
    canvas.drawPath(
      path,
      _paint(stroke: true, join: StrokeJoin.round),
    );
  }

  /// 分析：三根圆角柱状条。填充图形，选中只换颜色。
  void _paintAnalysis(Canvas canvas) {
    const List<Rect> bars = <Rect>[
      Rect.fromLTWH(3, 14, 4, 7),
      Rect.fromLTWH(10, 9, 4, 12),
      Rect.fromLTWH(17, 4, 4, 17),
    ];
    final Paint paint = _paint();
    for (final Rect bar in bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, const Radius.circular(1.5)),
        paint,
      );
    }
  }

  /// 我的：头部圆形 + 肩部弧线。
  ///
  /// 未选中时头部只有描边；选中时头部为实心渐变、肩部描边换成渐变。
  void _paintProfile(Canvas canvas) {
    const Offset head = Offset(12, 8);
    const double headRadius = 4;

    canvas.drawCircle(
      head,
      headRadius,
      _paint(stroke: !active),
    );

    final Path shoulders = Path()
      ..moveTo(4, 20)
      ..cubicTo(4, 16.69, 7.58, 14, 12, 14)
      ..cubicTo(16.42, 14, 20, 16.69, 20, 20);

    canvas.drawPath(
      shoulders,
      _paint(stroke: true, cap: StrokeCap.round),
    );
  }

  /// 构造一个 Paint：**选中 = 品牌渐变，未选中 = 中性描边色**。
  Paint _paint({
    bool stroke = false,
    StrokeCap cap = StrokeCap.butt,
    StrokeJoin join = StrokeJoin.miter,
  }) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..style = stroke ? PaintingStyle.stroke : PaintingStyle.fill;

    if (stroke) {
      paint
        ..strokeWidth = _strokeWidth
        ..strokeCap = cap
        ..strokeJoin = join;
    }

    if (active) {
      // Figma 的渐变是 `userSpaceOnUse`，每个图标起止点略有不同。
      paint.shader = AppColors.brandGradient.createShader(_gradientRect);
    } else {
      paint.color = AppColors.navIconInactive;
    }
    return paint;
  }

  /// 图标渐变的作用矩形（24 单位空间）。
  ///
  /// Figma：home `(3,3)→(21,21)`、chart `(3,4)→(21,21)`、
  /// user `(4,4)→(20,20)`。三者几乎一致，统一取 `(3,3)→(21,21)`。
  Rect get _gradientRect => const Rect.fromLTRB(3, 3, 21, 21);

  @override
  bool shouldRepaint(covariant _CareerlyNavGlyphPainter oldDelegate) =>
      oldDelegate.glyph != glyph || oldDelegate.active != active;
}
