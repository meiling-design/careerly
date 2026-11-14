import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_error.dart';
import 'error_handler.dart';

/// 全局崩溃 / 未捕获异常的**单一入口**。
///
/// 2026-11-14 产品侧指定：程序遇到问题崩溃时，要弹出「休息」形象的
/// IP 与提示框（见 `CareerlyProblemDialog`）。
///
/// ## 为什么是「通知器」而不是直接弹窗
///
/// `FlutterError.onError` / `PlatformDispatcher.onError` 可能在
/// **build / layout / paint 阶段**被调用 —— 此时如果直接
/// `showDialog` 或 `setState`，会再抛一个异常（经典的
/// 「setState() or markNeedsBuild() called during build」）。
///
/// 因此这里只做两件事：
///
/// 1. 把异常归一化成 [AppError]；
/// 2. 在**下一帧之后**写入 [current]，由 `CareerlyApp` 最外层的
///    [ValueListenableBuilder] 决定怎么展示。
///
/// 展示层的位置见 `lib/app/app.dart` —— 它包在 `MaterialApp.router`
/// 的 `builder` 里，因此故障提示会盖住**任何**页面（包括 Navigator 之上）。
///
/// ## 去重
///
/// 一次故障往往连续触发多条 `FlutterError`。在用户关掉当前提示之前，
/// [current] 保持第一条错误不变，避免提示框不断刷新 / 堆叠。
abstract final class CrashReporter {
  /// 当前待展示的故障。`null` 表示没有故障。
  static final ValueNotifier<AppError?> current = ValueNotifier<AppError?>(
    null,
  );

  static bool _installed = false;

  /// 是否为「有故障待用户确认」状态。
  static bool get hasError => current.value != null;

  /// 安装全局错误钩子。**在 `runApp` 之前调用**（见 `main()`）。
  ///
  /// 幂等：重复调用不会重复挂钩。
  static void install() {
    if (_installed) return;
    _installed = true;

    // 保留 Flutter 默认 / 测试可能已安装的处理器 —— 否则 debug 控制台
    // 不再打印错误详情，排查问题会变难。
    final FlutterExceptionHandler? previousFlutterHandler =
        FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      previousFlutterHandler?.call(details);
      if (_shouldReport(details)) {
        report(details.exception, details.stack);
      }
    };

    final bool Function(Object, StackTrace)? previousPlatformHandler =
        PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      previousPlatformHandler?.call(error, stack);
      report(error, stack);
      // 返回 true：故障已经由 UI 提示接管，不再让平台直接终止进程。
      return true;
    };
  }

  /// 记录一个故障。可在任意时机调用。
  static void report(Object error, [StackTrace? stackTrace]) {
    if (current.value != null) return;

    final AppError appError = ErrorHandler.normalize(error, stackTrace);

    // 等当前帧结束后再写通知器：故障可能就发生在 build/layout 中。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (current.value != null) return;
      current.value = appError;
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// 用户确认后关闭故障提示。
  static void clear() {
    current.value = null;
  }

  /// 开发期常见的布局溢出属于**警告**，不是崩溃 —— 不弹故障框。
  static bool _shouldReport(FlutterErrorDetails details) {
    if (details.silent) return false;
    return !details.exceptionAsString().contains('overflowed');
  }
}
