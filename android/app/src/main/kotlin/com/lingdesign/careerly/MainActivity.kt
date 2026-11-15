package com.lingdesign.careerly

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
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val APP_BACK_CHANNEL = "com.lingdesign.careerly/app_back"
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
    }
}
