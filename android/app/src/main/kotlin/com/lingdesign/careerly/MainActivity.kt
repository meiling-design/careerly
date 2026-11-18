package com.lingdesign.careerly

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Careerly 宿主 Activity。
 *
 * 产品规则（2026-11-15）：首页再次 Back / 侧滑只能把 App 退到后台，
 * 不允许 `finish()`。Flutter 侧的 [SystemNavigator.pop] 在 Android 上
 * 实际就是 `finish()`，因此改由本 Activity 提供 `moveTaskToBack(true)`。
 *
 * 通道名与 Dart 侧 `lib/core/services/app_back_platform.dart` 一致。
 *
 * 另提供 `app_info` 通道，把 Gradle 从 `pubspec.yaml` 写入的
 * `versionName` / `versionCode` 读给「关于 Careerly」页 ——
 * 版本号在 Dart 侧不维护第二份字面量。
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val APP_BACK_CHANNEL = "com.lingdesign.careerly/app_back"
        private const val APP_INFO_CHANNEL = "com.lingdesign.careerly/app_info"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_BACK_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "moveTaskToBack" -> {
                    // true = 不把其他 Activity 一起带到后台。
                    // 失败也不调用 finish()：保持 App 在前台比误杀进程更安全。
                    result.success(moveTaskToBack(true))
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_INFO_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVersion" -> {
                    try {
                        val packageInfo = packageManager.getPackageInfo(packageName, 0)
                        val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                            packageInfo.longVersionCode
                        } else {
                            @Suppress("DEPRECATION")
                            packageInfo.versionCode.toLong()
                        }
                        result.success(
                            mapOf(
                                "versionName" to (packageInfo.versionName ?: ""),
                                "versionCode" to versionCode.toString(),
                            ),
                        )
                    } catch (error: Exception) {
                        // 读不到版本属于宿主异常，Dart 侧会如实显示「暂不可用」。
                        result.error("APP_INFO_UNAVAILABLE", error.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
