import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'glass/glass_filters.dart';

/// BottomSheet 的呈现类别。
///
/// ## ⚠️ 这是**分析归纳**，不是设计侧定义的枚举
///
/// Figma 中**不存在统一的 BottomSheet 组件** —— 一共 6 处**内联变体**
/// （`src/App.tsx` L2082 / L2298 / L4431 / L4595 / L5056 / L5098）。
/// 它们的差异维度是可枚举的，但**没有任何一处把它们抽象成一个组件**。
///
/// 下面的三分类是按 **scrim 取值 + 使用场景**归纳出来的，
/// 依据 `CLAUDE.md` §3.2「设计稿负责视觉，Flutter 负责真实交互逻辑」，
/// **属于 Flutter 侧的工程归纳**，不是产品规则。**待产品侧确认**。
///
/// | 类别 | 对应 Figma 变体 | 场景 |
/// |---|---|---|
/// | [confirm] | A（L2082）· B（L2298） | 分析中退出确认、结果页更新分析 |
/// | [action] | C（L4431）· D（L4595） | 简历分享 / 导出、导入新简历 |
/// | [overlay] | E（L5056）· F（L5098） | 退出登录、额度用尽 / 最后 1 次 |
///
/// ## ⚠️ 与既有 `AppRadius.sheet` 的关系
///
/// `AppRadius.sheet`（顶部圆角 `28`）**只等于本枚举中 [action] 一档**。
/// Figma 的另外四档用的是 `24`。该 Token 因而**欠定义**（把两种取值
/// 收敛成了一档），本组件**不改动它**（属批 1 既有实现），
/// 改为按 [tone] 分别取 `AppRadius.xxl` / `AppRadius.xl`。
/// **待裁决 · D29** —— 见 `docs/05_progress/` 待裁决清单 §3.1。
enum CareerlyBottomSheetTone {
  /// 确认类：**实心白**面板 + 轻 scrim。`rgba(0,0,0,0.28)` + `blur(3px)`。
  confirm,

  /// 操作类：**半透明**面板 + 重 scrim。`rgba(0,0,0,0.40)` + `blur(6px)`。
  action,

  /// 浮层类：**Glass 材质**面板 + 中 scrim。`rgba(0,0,0,0.45)` + `blur(4px)`。
  overlay,
}

/// Careerly 底部弹层。
///
/// ```dart
/// CareerlyBottomSheet.show(
///   context,
///   tone: CareerlyBottomSheetTone.confirm,
///   child: Column(children: <Widget>[ ... ]),
/// );
/// ```
///
/// ## 这个组件负责什么
///
/// Figma 的 6 处内联变体的**共性**是：
/// 铺满的 scrim + 贴底面板 + 顶部圆角 + 拖拽把手。
/// 本组件把这四样收敛成一个壳，业务侧只需要提供**内容**。
///
/// ## 为什么不复用 `GlassSurface`
///
/// [CareerlyBottomSheetTone.overlay] 的面板用的是 Figma `S.glass`，
/// 但它的圆角是 `rounded-t-3xl` —— **只有顶部两角**。
/// 而 `GlassSurface` / `GlassEdgePainter` 的圆角参数是单个 `double`，
/// 其文档要求**四角一致**（「Figma 的所有 Glass 面都是均匀圆角」）。
///
/// > ⚠️ **该前提在本例中不成立** —— BottomSheet 就是非均匀圆角的 Glass 面。
/// > 因此这里**旁路** `GlassSurface`，直接组合其底层基元
/// > （[GlassFilters] 的 `ImageFilter` + `AppColors` 的 Glass 填充 / 描边）。
/// >
/// > 代价：项目里出现了**第三处 Glass 组合**（K12；另两处见 K10）。
/// > 是否把 `GlassSurface` 扩展为接受 `BorderRadius`
/// > —— **待裁决 · D30**，见 `docs/05_progress/` 待裁决清单 §3.1。
/// >
/// > ✅ `S.glass` **本身没有 inset 高光**（`GlassSurface` 文档已载明），
/// > 所以不需要 `GlassEdgePainter` —— 只需填充 + 1px 描边 + blur，
/// > 这三样对非均匀圆角都成立。
///
/// ## 明确未做（有意保留）
///
/// - **下滑关闭（drag-to-dismiss）**：Figma 无法表达拖拽手势，
///   而阈值（位移 / 速度）属 Flutter 侧需自定的交互参数。
///   当前唯一的关闭方式是「点击 scrim」（或业务侧自行调用 `Navigator.pop`）。
/// - **高度档位**：Figma 未定义 half / full 之类的档位，面板为自适应高度。
///
/// 两项均登记为 **待裁决 · D34**，见 `docs/05_progress/` 待裁决清单 §3.1。
///
/// ## 内容高度
///
/// 面板**自适应内容高度**，上限为屏幕高度的
/// [_BottomSheetMetrics.maxHeightRatio]（工程兜底，非设计值）。
/// 内容过高时请**自行使用可滚动容器**（如 `ListView`），
/// 否则会溢出 —— 本组件不代为插入滚动视图（那会破坏自适应高度）。
class CareerlyBottomSheet extends StatelessWidget {
  const CareerlyBottomSheet({
    super.key,
    required this.child,
    this.tone = CareerlyBottomSheetTone.confirm,
    this.showHandle = true,
    this.radius,
    this.fill,
    this.handleWidth,
    this.handleColor,
    this.handleSpacing = AppSpacing.mdLg,
    this.padding,
  });

  /// 面板内容。
  final Widget child;

  /// 呈现类别。
  final CareerlyBottomSheetTone tone;

  /// 是否显示顶部拖拽把手。
  final bool showHandle;

  /// 顶部圆角半径。为 `null` 时按 [tone] 取默认值。
  final double? radius;

  /// 面板填充色。为 `null` 时按 [tone] 取默认值。
  final Color? fill;

  /// 把手宽度。为 `null` 时按 [tone] 取默认值。
  final double? handleWidth;

  /// 把手颜色。为 `null` 时按 [tone] 取默认值。
  final Color? handleColor;

  /// 把手与内容之间的间距。
  ///
  /// Figma 各处不一致（`mb-2` / `mb-5` / `mb-12` / `mb-16`）。
  /// 默认取 `mb-5`（`20`）—— 那是**出现次数最多**的一档（变体 A / B）。
  final double handleSpacing;

  /// 内容内边距。为 `null` 时**不加**内边距，由业务侧自行控制。
  final EdgeInsetsGeometry? padding;

  /// 以模态方式弹出。
  ///
  /// 使用 [showGeneralDialog] 而非 Material 的 `showModalBottomSheet`：
  /// 后者的 scrim 是纯色，**无法表达 Figma 的 `backdrop-filter: blur()`**，
  /// 且会带出 M3 默认的 `bottomSheetTheme` 造型。
  /// 依据 Baseline §6.5，Careerly 的视觉系统不由 M3 默认样式主导。
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    CareerlyBottomSheetTone tone = CareerlyBottomSheetTone.confirm,
    bool barrierDismissible = true,
    bool showHandle = true,
  }) {
    final _BottomSheetSpec spec = _specFor(tone);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      // 语义标签交给本地化，不写死中文字面量。
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      // scrim 由本组件自绘（需要 blur），因此 Material 的 barrier 保持透明。
      barrierColor: Colors.transparent,
      transitionDuration: AppMotion.sheet,
      pageBuilder: (_, _, _) => CareerlyBottomSheet(
        tone: tone,
        showHandle: showHandle,
        child: child,
      ),
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.enter,
          reverseCurve: AppMotion.exit,
        );

        return Stack(
          children: <Widget>[
            // scrim 是**纯视觉**：必须 IgnorePointer，
            // 否则会吃掉本该由 Material barrier 处理的关闭点击。
            Positioned.fill(
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: curved,
                  child: _SheetScrim(spec: spec),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _BottomSheetSpec spec = _specFor(tone);

    final BorderRadius borderRadius = BorderRadius.vertical(
      top: Radius.circular(radius ?? spec.radius),
    );

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return ConstrainedBox(
      // 面板高度上限。⚠️ Figma 未定义（**待裁决 · D34**）——
      // 这是**防止内容溢出**的工程兜底，不是设计值。
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height * _BottomSheetMetrics.maxHeightRatio,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: AppShadows.sheet,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: _SheetSurface(
            spec: spec,
            fill: fill ?? spec.fill,
            child: SafeArea(
              // 面板底色延伸到手势条之下，但内容不侵入。
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (showHandle) ...<Widget>[
                    const SizedBox(height: AppSpacing.sm),
                    _SheetHandle(
                      width: handleWidth ?? spec.handleWidth,
                      color: handleColor ?? spec.handleColor,
                    ),
                    SizedBox(height: handleSpacing),
                  ],
                  Flexible(child: content),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 面板材质：填充 + 可选描边 + 可选 backdrop blur。
///
/// 见 [CareerlyBottomSheet] 类文档「为什么不复用 `GlassSurface`」。
class _SheetSurface extends StatelessWidget {
  const _SheetSurface({
    required this.spec,
    required this.fill,
    required this.child,
  });

  final _BottomSheetSpec spec;
  final Color fill;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        border: spec.bordered
            ? Border.all(
                color: AppColors.glassBorder,
                width: _BottomSheetMetrics.borderWidth,
              )
            : null,
      ),
      child: child,
    );

    if (spec.panelBlur <= 0) return surface;

    // CSS `blur(Npx)` 的参数即高斯标准差，与 Flutter 的 sigma 同值。
    return BackdropFilter(
      filter: GlassFilters.blur(spec.panelBlur),
      child: surface,
    );
  }
}

/// scrim：背面模糊 + 着色。本身不定位，由调用处以 `Positioned.fill` 铺满。
class _SheetScrim extends StatelessWidget {
  const _SheetScrim({required this.spec});

  final _BottomSheetSpec spec;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: GlassFilters.blur(spec.scrimBlur),
      child: ColoredBox(color: spec.scrim),
    );
  }
}

/// 顶部拖拽把手（纯视觉，不响应手势 —— 见类文档「明确未做」）。
class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: _BottomSheetMetrics.handleHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.borderPill,
        ),
      ),
    );
  }
}

/// 一个 tone 的完整取值。
///
/// 与 `_ButtonMetrics` 同理：这是**组件内部比例**，不进入 `AppSpacing`。
typedef _BottomSheetSpec = ({
  Color scrim,
  double scrimBlur,
  Color fill,
  double panelBlur,
  double radius,
  double handleWidth,
  Color handleColor,
  bool bordered,
});

/// tone → 取值。真值来源为 Figma 6 处内联变体，逐项见下。
_BottomSheetSpec _specFor(CareerlyBottomSheetTone tone) {
  return switch (tone) {
    // A（L2082）/ B（L2298）：纯白面板 + 圆角 24 + 把手 36。
    // 面板无 blur（实心白）。
    CareerlyBottomSheetTone.confirm => (
      scrim: AppColors.sheetScrimConfirm,
      scrimBlur: 3,
      fill: AppColors.surface,
      panelBlur: 0,
      radius: AppRadius.xl,
      handleWidth: 36,
      handleColor: AppColors.sheetHandleLight,
      bordered: false,
    ),

    // C（L4431，fill 0.95）/ D（L4595，fill 0.88）：
    // 圆角 28 + 把手 40 + 面板 blur 24。
    // 默认取 C 的 0.95；D 的 0.88 由 `fill` 参数覆盖（AppColors.sheetFillMid）。
    CareerlyBottomSheetTone.action => (
      scrim: AppColors.sheetScrimAction,
      scrimBlur: 6,
      fill: AppColors.sheetFillHigh,
      panelBlur: 24,
      radius: AppRadius.xxl,
      handleWidth: 40,
      handleColor: AppColors.sheetHandleDark,
      bordered: false,
    ),

    // E（L5056）/ F（L5098）：`S.glass` 面板 + 圆角 24 + 面板 blur 24。
    // （F 的把手为 48，由 `handleWidth` 参数覆盖。）
    CareerlyBottomSheetTone.overlay => (
      scrim: AppColors.sheetScrimOverlay,
      scrimBlur: 4,
      fill: AppColors.glassFill,
      panelBlur: 24,
      radius: AppRadius.xl,
      handleWidth: 40,
      handleColor: AppColors.sheetHandleDark,
      bordered: true,
    ),
  };
}

/// 组件的内部几何与兜底值。
abstract final class _BottomSheetMetrics {
  /// Figma 各处把手高度统一为 `4`。
  static const double handleHeight = 4;

  /// Figma `S.glass` 描边 `1px`。
  static const double borderWidth = 1;

  /// 面板高度上限（占屏幕比例）。
  ///
  /// ⚠️ **Figma 未定义** —— 这是防止内容溢出的**工程兜底**，不是设计值。
  /// **待裁决 · D34**，见 `docs/05_progress/` 待裁决清单 §3.1。
  static const double maxHeightRatio = 0.9;
}
