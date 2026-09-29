import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/errors/app_error.dart';

/// Mock 数据层开关。
///
/// 依据 Phase 1 §十八「Mock First」：
/// 先跑通 UI → State → Repository → Mock 的完整链路，
/// 真实 API 之后再替换。
///
/// [latency] 与 [failNext] 存在的意义是让 Phase 1 的
/// **Loading / Success / Empty / Error 四种状态可被真实验证**——
/// 否则 Mock 立即返回，UI 的 Loading 与 Error 分支永远不会被走到。
@immutable
class MockConfig {
  const MockConfig({
    this.latency = const Duration(milliseconds: 600),
    this.failNext = false,
    this.throwError,
    this.demoData = false,
  });

  /// 默认：600ms 延迟，成功返回，**空数据**。
  static const MockConfig standard = MockConfig();

  /// 模拟网络延迟。
  final Duration latency;

  /// 下一次调用是否直接失败（用于人工验证 Error State）。
  final bool failNext;

  /// 失败时抛出的错误类型。为 `null` 时使用 [NetworkError]。
  final AppError? throwError;

  /// 是否返回**演示数据**。
  ///
  /// ```text
  /// false（默认）  → 各 Mock 返回空数据，让 Empty 态真实可见（CLAUDE.md §7）
  /// true           → 返回 Figma 原型里的样例数据，供视觉逐位比对
  /// ```
  ///
  /// ⚠️ 演示数据**逐条来自 Figma 原型**（`src/App.tsx` 的
  /// `WORK_EXP` / `PROJECTS_DATA` / `SKILL_CATS` / `AWARDS` / `SKILLS_DATA`），
  /// **不是需求**。开启方式见 `main.dart`：
  ///
  /// ```bash
  /// flutter run --dart-define=CAREERLY_DEMO_DATA=true
  /// ```
  final bool demoData;

  /// 等待模拟延迟，必要时抛出错误。
  Future<void> simulate() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
    if (failNext) {
      throw throwError ?? const NetworkError(detail: 'MockConfig.failNext');
    }
  }

  MockConfig copyWith({
    Duration? latency,
    bool? failNext,
    AppError? throwError,
    bool? demoData,
  }) {
    return MockConfig(
      latency: latency ?? this.latency,
      failNext: failNext ?? this.failNext,
      throwError: throwError ?? this.throwError,
      demoData: demoData ?? this.demoData,
    );
  }
}

/// 全局 Mock 配置。
///
/// Phase 9（Global States）会把这里换成可运行时切换的调试开关。
/// 启动时的取值由 `main.dart` 调用 [applyDemoDataFromEnvironment] 写入
/// （`--dart-define=CAREERLY_DEMO_DATA`，见 [MockConfig.demoData]）——
/// **默认仍是**「成功 + 空数据」。
class MockSettings {
  const MockSettings._();

  static MockConfig config = MockConfig.standard;

  /// 演示数据开关的 `--dart-define` 键名。
  static const String demoDataDefineKey = 'CAREERLY_DEMO_DATA';

  /// 编译期传入的演示数据开关。
  ///
  /// 未传时是 `false` —— `bool.fromEnvironment` 的语义如此。
  static const bool _rawDemoData = bool.fromEnvironment(demoDataDefineKey);

  /// 本次构建是否启用了演示数据。
  static bool get demoDataEnabled => _rawDemoData;

  /// 把编译期开关写进 [config]。**在 `main()` 里调用一次**。
  ///
  /// ```bash
  /// flutter run                                  # 空数据（默认）
  /// flutter run --dart-define=CAREERLY_DEMO_DATA=true   # Figma 样例数据
  /// ```
  ///
  /// ⚠️ 用 `copyWith` 而不是整体替换 —— 保留 [MockConfig.standard] 的
  /// 延迟与失败开关，避免这个开关顺带改掉四态验证的前提。
  static void applyDemoDataFromEnvironment() {
    if (demoDataEnabled) {
      config = config.copyWith(demoData: true);
    }
  }
}
