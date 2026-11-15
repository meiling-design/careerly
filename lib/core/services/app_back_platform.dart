import 'package:flutter/services.dart';

/// 「回到桌面」的平台通道。
///
/// ## 为什么需要它
///
/// 产品规则（2026-11-15）明确：**首页再次 Back / 侧滑只能把 App 退到后台**
/// （Android `moveTaskToBack(true)`），
/// ❌ 不允许调用 `finish()` / `exit(0)` / `logout()` / `clearToken()`。
///
/// Flutter 自带的 [SystemNavigator.pop] 在 Android 上走的是 `finish()` ——
/// 它会销毁 Activity，下一次打开 App 需要重新冷启动，且部分 ROM 会连带
/// 清理后台任务。因此这里改用自定义 MethodChannel，
/// 由宿主 `MainActivity.moveTaskToBack(true)` 实现「退到后台」。
///
/// ## 失败时的行为
///
/// 通道不可用（单元测试 / 非 Android 宿主）时**静默返回 false**，
/// 绝不回退到 `SystemNavigator.pop()` —— 那会破坏上面的红线。
abstract final class AppBackPlatform {
  /// 与 `android/app/src/main/kotlin/.../MainActivity.kt` 约定的通道名。
  static const String channelName = 'com.lingdesign.careerly/app_back';

  /// 通道实例。测试用同名 [MethodChannel] 注册 mock handler 即可拦截。
  static const MethodChannel channel = MethodChannel(channelName);

  /// 把当前任务退到后台（不结束进程、不清理登录态）。
  ///
  /// 返回 `true` 表示宿主已执行；通道缺失或调用失败时返回 `false`。
  static Future<bool> moveTaskToBack() async {
    try {
      return await channel.invokeMethod<bool>('moveTaskToBack') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
