import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/router/app_debug_entry.dart';
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
/// ## 两个启动开关（都只影响开发期）
///
/// ```text
/// CAREERLY_ENTRY      App 落在哪一屏   → AppDebugEntry
/// CAREERLY_DEMO_DATA  Mock 是否返回样例数据 → MockSettings
/// ```
///
/// ```bash
/// flutter run                                              # 首页 + 空数据
/// flutter run --dart-define=CAREERLY_ENTRY=profile          # 直接进「我的」
/// flutter run --dart-define=CAREERLY_DEMO_DATA=true         # 演示数据
/// flutter run --dart-define=CAREERLY_ENTRY=profile \
///             --dart-define=CAREERLY_DEMO_DATA=true         # 逐位比对 Figma
/// ```
///
/// ⚠️ 「App 究竟该从哪一屏启动」**是尚未裁决的产品问题（D54）**，
/// [AppDebugEntry] 不回答它；[MockSettings] 的演示数据也**不是需求**
/// （`CLAUDE.md` §7）—— 详见各自文件的说明。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MockSettings.applyDemoDataFromEnvironment();
  runApp(CareerlyApp(initialLocation: AppDebugEntry.initialLocation));
}
