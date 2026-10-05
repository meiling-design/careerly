import 'package:flutter/foundation.dart';

import 'app_routes.dart';

/// 应用启动入口。
///
/// ## 为什么需要它
///
/// Figma 原型的入口是 `on-splash`。当前未接入会话持久化，因此首次启动统一进入
/// 欢迎页；已注册用户的跳过逻辑留待后续 Auth / Cache 阶段接入。
///
/// > 「已注册用户不该再看一遍引导」这个判断**只能由会话持久化提供**。
/// > D52 把本轮限定为「纯 Mock、不引入本地存储依赖」，
/// > 在该前提下硬把默认入口改成开屏，会得到
/// > 「每次启动都要求重新注册」的错误行为 —— **比暂时不接线更糟**。
///
/// `CAREERLY_ENTRY` 仍可在开发期覆盖启动入口：
///
/// ```text
/// 不传 define   →  欢迎页
/// 传入 `home`  →  首页
/// 传入其他入口 →  落到指定入口
/// ```
///
/// ⚠️ 它**没有**回答「App 启动该进哪一屏」这个产品问题 ——
/// 那个问题仍然挂在 D54 上，等产品侧裁决。
///
/// ## 用法
///
/// ```bash
/// flutter run --dart-define=CAREERLY_ENTRY=splash
/// flutter run --dart-define=CAREERLY_ENTRY=register
/// flutter run --dart-define=CAREERLY_ENTRY=confirm
/// flutter run --dart-define=CAREERLY_ENTRY=/onboarding/confirm   # 完整路径亦可
/// ```
///
/// ## 收口
///
/// **D54 裁决后，本文件应整体删除**：届时入口由会话持久化决定，
/// 下面的映射表与回退分支都不再需要。
/// 删除时同步移除 `main.dart` 的引用与
/// `test/app_debug_entry_test.dart`。
abstract final class AppDebugEntry {
  /// `--dart-define` 的键名。
  static const String defineKey = 'CAREERLY_ENTRY';

  /// 编译期传入的入口值。
  ///
  /// 未传时是**空串**而不是 `null` —— `String.fromEnvironment` 的语义如此。
  static const String _raw = String.fromEnvironment(defineKey);

  /// 短名 → 路由路径。
  ///
  /// 只登记**真实存在**的路由。不在这里的名字**不会被猜成某个路径** ——
  /// 见 [resolve] 的未知值处理。
  static const Map<String, String> shortNames = <String, String>{
    'home': AppRoutes.home,
    'analysis': AppRoutes.analysis,
    'ai': AppRoutes.ai,
    'profile': AppRoutes.profile,
    'splash': AppRoutes.onboardingSplash,
    'register': AppRoutes.onboardingRegister,
    'login': AppRoutes.onboardingLogin,
    'resume': AppRoutes.onboardingResume,
    'parsing': AppRoutes.onboardingParsing,
    'confirm': AppRoutes.onboardingConfirm,
  };

  /// 本次启动实际要落的路径。没有覆盖值时进入欢迎页。
  static String get initialLocation {
    if (!kDebugMode) return AppRoutes.onboardingSplash;
    return resolve(_raw) ?? AppRoutes.onboardingSplash;
  }

  /// 解析一个入口值；无法识别时返回 `null`（由调用方决定回退）。
  ///
  /// 接受两种写法：
  ///
  /// ```text
  /// 短名      splash · register · confirm …
  /// 完整路径  /onboarding/splash  —— 以 `/` 开头即原样透传
  /// ```
  ///
  /// ⚠️ 完整路径**不做白名单校验**：写错路径会落到 `errorBuilder` 的
  /// 「页面不存在」页 —— 那正是开发期想要看到的反馈，
  /// 比静默回退到首页更容易定位问题。
  ///
  /// 公开而非私有，是为了让 `test/phase4_entry_switch_test.dart`
  /// 能直接钉住映射表 —— 这张表错了，验收就会落到错误的屏幕上。
  static String? resolve(String value) {
    final String key = value.trim();
    if (key.isEmpty) return null;
    if (key.startsWith('/')) return key;
    return shortNames[key];
  }
}
