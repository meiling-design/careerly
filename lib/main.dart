import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/router/app_debug_entry.dart';
import 'data/api/api_client.dart';
import 'data/api/token_store.dart';
import 'data/mock/mock_config.dart';

/// Careerly 启动入口。
///
/// 这里**只做启动**，不放任何产品逻辑：
/// 依赖装配在 `lib/app/providers.dart`，
/// 路由在 `lib/app/router/app_router.dart`，
/// 主题在 `lib/design_system/theme/careerly_theme.dart`。
///
/// ⚠️ 不要往这个文件里堆代码——Baseline §7.5 明确反对
/// 「把整个 Figma Frame 写成一个巨大 Widget」这类做法，
/// 根节点也一样。
///
/// ## 启动开关（都只影响开发期）
///
/// ```text
/// CAREERLY_USE_API    是否接真实后端    → 本文件（默认 true）
/// CAREERLY_API_BASE_URL 后端地址        → ApiClient（默认 127.0.0.1:8000）
/// CAREERLY_ENTRY      App 落在哪一屏   → AppDebugEntry
/// CAREERLY_DEMO_DATA  Mock 是否返回样例数据 → MockSettings
/// ```
///
/// ```bash
/// adb reverse tcp:8000 tcp:8000   # 每次重插 USB 后跑一次（见下）
/// flutter run                      # 首页 + 真实后端
/// flutter run --dart-define=CAREERLY_USE_API=false   # 强制回到 Mock
/// flutter run --dart-define=CAREERLY_ENTRY=profile   # 直接进「我的」
/// flutter run --dart-define=CAREERLY_DEMO_DATA=true  # 演示数据
/// ```
///
/// ## 为什么默认接真实后端
///
/// 此前默认是 Mock，想看真实链路必须每次手打一长串 `--dart-define`。
/// 现在默认值由**入口**决定：`main()` 取真实后端，测试与
/// [CareerlyApp] 的自身默认仍是 Mock —— 两者不再互相牵制。
///
/// 后端地址默认 `http://127.0.0.1:8000`，依赖 `adb reverse`
/// 把设备的回环端口转发到开发机。**每次重插 USB 后要重跑一次**，
/// 否则请求会打到设备自己身上、表现为「连不上后端」。
///
/// ⚠️ 「App 究竟该从哪一屏启动」**是尚未裁决的产品问题（D54）**，
/// [AppDebugEntry] 不回答它；[MockSettings] 的演示数据也**不是需求**
/// （`CLAUDE.md` §7）—— 详见各自文件的说明。
///
/// ## 为什么 main 变成 async（P1-6 / 裁决 D-B）
///
/// 会话恢复是异步的（读 Keystore），且**必须在 `runApp` 之前**完成：
/// 否则首帧发出的请求会带着「还没恢复」的空凭据，命中 401。
/// 这里只做「恢复凭据」这一件事，**不**决定启动落在哪一屏（那是 D54）。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MockSettings.applyDemoDataFromEnvironment();

  final ApiClient apiClient = ApiClient(tokenStore: SecureTokenStore());
  // 恢复失败不算错误：就是「没有已保存的会话」，正常走登录流程。
  await apiClient.restoreSession();

  runApp(
    CareerlyApp(
      initialLocation: AppDebugEntry.initialLocation,
      apiClient: apiClient,
      // 未显式指定 CAREERLY_USE_API 时接真实后端；
      // --dart-define=CAREERLY_USE_API=false 可强制回到 Mock。
      useApi: ApiClient.useApiOverride ?? true,
    ),
  );
}
