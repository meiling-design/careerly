import 'package:flutter/services.dart';

/// App 版本信息。
class AppVersion {
  const AppVersion({required this.name, this.buildNumber = ''});

  /// 版本名，例如 `1.0.0`（来自 `pubspec.yaml` 的 `version` 前半段）。
  final String name;

  /// 构建号，例如 `1`（Android `versionCode`）。
  final String buildNumber;

  /// 展示文案，例如 `1.0.0（1）`。
  String get label => buildNumber.isEmpty ? name : '$name（$buildNumber）';
}

/// 读取宿主 App 的真实版本号。
///
/// ## 为什么不写死
///
/// 「关于 Careerly」页底部的版本号必须来自**应用实际配置**。版本号定义在
/// `pubspec.yaml`，Flutter 构建时由 Gradle 写入 `versionName` / `versionCode`，
/// 因此这里通过平台通道向宿主读取，而不是在 Dart 里维护第二份字面量。
///
/// ## 失败时的行为
///
/// 通道不可用（单元测试 / 非 Android 宿主）时返回 `null`，
/// 界面如实显示「版本信息暂不可用」，不编造一个版本号。
abstract final class AppInfoPlatform {
  /// 与 `android/app/src/main/kotlin/.../MainActivity.kt` 约定的通道名。
  static const String channelName = 'com.lingdesign.careerly/app_info';

  /// 通道实例。测试用同名 [MethodChannel] 注册 mock handler 即可拦截。
  static const MethodChannel channel = MethodChannel(channelName);

  /// 读取版本名与构建号。
  static Future<AppVersion?> readVersion() async {
    try {
      final Map<String, Object?>? raw = await channel
          .invokeMapMethod<String, Object?>('getVersion');
      if (raw == null) return null;

      final String name = raw['versionName']?.toString() ?? '';
      if (name.isEmpty) return null;

      return AppVersion(
        name: name,
        buildNumber: raw['versionCode']?.toString() ?? '',
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
