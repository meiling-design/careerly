import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// `BuildContext` 便捷扩展。
///
/// 目的：减少业务页面里的样板代码，同时让「页面只能通过 State 层拿数据」
/// 这条分层规则更容易被遵守（读 Provider 比直接 new Repository 更省事）。
///
/// 注意：这里**不**封装 `watch<XProvider>()`。
/// Provider 的状态读取统一写成：
/// ```dart
/// final HomeProvider provider = context.watch<HomeProvider>();
/// final AsyncState<HomeSummary> state = provider.state;
/// ```
/// 显式写出类型，比泛型推断出来的包装类更容易读，也更少出错。
extension CareerlyContextX on BuildContext {
  /// 读取主题。
  ThemeData get theme => Theme.of(this);

  /// 读取 Careerly 文本样式。
  ///
  /// 业务页面统一从这里取样式，不自行构造 `TextStyle`。
  TextTheme get textStyles => Theme.of(this).textTheme;

  /// 读取配色。
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// 屏幕尺寸。
  Size get screenSize => MediaQuery.sizeOf(this);

  /// 是否为小屏（Android 小屏适配检查用）。
  bool get isSmallScreen => MediaQuery.sizeOf(this).width < 360;

  /// 底部安全区高度。
  double get bottomSafeInset => MediaQuery.viewPaddingOf(this).bottom;

  /// 订阅 Provider 并重建（`listen: true`）。
  P watchProvider<P extends ChangeNotifier>() => watch<P>();

  /// 读取 Provider 但不重建。
  P readProvider<P extends ChangeNotifier>() => read<P>();

  /// 显示统一风格的提示。
  void showCareerlySnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
