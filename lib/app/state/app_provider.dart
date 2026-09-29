import 'package:flutter/foundation.dart';

/// App 级状态。
///
/// Baseline §7.3 列的六个 Provider 之一。
///
/// 职责边界（**刻意保持很小**）：
/// 只放**跨 feature 的 App 级状态**，不放任何领域数据。
/// 领域数据各自归 HomeProvider / AnalysisProvider / ResumeProvider /
/// GrowthProvider 所有——避免 Baseline §7.3 警告的
/// 「无限膨胀的 Global AppState」。
///
/// Phase 1 只承载 bootstrap 就绪标志；
/// 会员 / 主题 / 语言等 App 级状态在 Phase 9（Global States）接入。
class AppProvider extends ChangeNotifier {
  bool _isReady = false;

  /// 应用是否已完成启动准备。
  bool get isReady => _isReady;

  /// 标记启动准备完成。
  ///
  /// Phase 1 不做真实的启动任务（无鉴权、无本地存储）——
  /// Onboarding / Splash 在 Phase 4 接入时，这里会变成
  /// 「检查登录态 → 检查职业基线是否已建立」。
  void markReady() {
    if (_isReady) return;
    _isReady = true;
    notifyListeners();
  }
}
