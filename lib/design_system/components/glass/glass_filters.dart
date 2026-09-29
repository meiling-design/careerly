import 'dart:ui' as ui;

/// Careerly Glass 材质的 `backdrop-filter` 预设。
///
/// ## CSS → Flutter 的换算规则
///
/// ⚠️ CSS `blur(Npx)` 的参数是高斯**标准差**，对应 Flutter 的
/// `ImageFilter.blur(sigmaX:, sigmaY:)`，**不是直径**。二者可直接取同值。
///
/// 复合滤镜（如 `blur(10px) saturate(190%) ...`）在 CSS 中是**先写先应用**，
/// 而 [ui.ImageFilter.compose] 是 `inner` 先于 `outer`，
/// 因此最内层是 blur、最外层是最后应用的色彩矩阵。
///
/// ## 真值来源
///
/// `src/App.tsx` 行 25–34 的 `S` 对象：
///
/// | Token | CSS |
/// |---|---|
/// | [standard] | `blur(24px)` — `S.glass` |
/// | [light] | `blur(16px)` — `S.glassLight` |
///
/// > 底部导航特有的复合滤镜（`saturate` / `brightness` / `contrast`）
/// > 目前仍在 `CareerlyNavigationBar` 内，Phase 2 批 3 会合并到本文件。
abstract final class GlassFilters {
  /// 标准 Glass 卡片：`blur(24px)`。
  static final ui.ImageFilter standard = ui.ImageFilter.blur(
    sigmaX: 24,
    sigmaY: 24,
  );

  /// 轻量 Glass：`blur(16px)`。
  static final ui.ImageFilter light = ui.ImageFilter.blur(
    sigmaX: 16,
    sigmaY: 16,
  );

  /// 纯模糊滤镜，供需要自定义半径的场景使用。
  static ui.ImageFilter blur(double sigma) =>
      ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
}
