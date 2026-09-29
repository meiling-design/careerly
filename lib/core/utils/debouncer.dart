import 'dart:async';

import 'package:flutter/foundation.dart';

/// 简易防抖工具。
///
/// 用途：JD 粘贴 / 输入这类高频触发场景（Phase 6 分析流程）。
/// Phase 1 只提供工具本身，不接入任何业务。
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 300)});

  final Duration duration;
  Timer? _timer;

  /// 触发一次。[action] 会在 [duration] 内没有新触发时才执行。
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// 立即执行并取消待执行的调用。
  void flush(VoidCallback action) {
    _timer?.cancel();
    action();
  }

  /// 取消待执行的调用。
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 是否有待执行的调用。
  bool get isPending => _timer?.isActive ?? false;

  void dispose() => cancel();
}
