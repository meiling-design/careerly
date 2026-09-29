import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../state/career_assets_provider.dart';

/// 职业资产族页面的**取数兜底**。
///
/// ## 为什么需要它
///
/// 常规路径是：「我的」主页在 `initState` 里 [CareerAssetsProvider.load]，
/// 之后用户点进任何二级页 —— 此时数据**已经在手上**，二级页不重复取。
///
/// 但有两条路径会绕过主页：
///
/// ```text
/// 1. 深链直达        /profile/work-experience/0（AppDebugEntry 可指定）
/// 2. 浏览器式回退     直接落到历史栈里的某个二级页
/// ```
///
/// 这两种情况下 provider 还是空的，页面会永远停在 Loading。
/// 因此每个职业资产族页面都在 [State.initState] 的下一帧调一次本函数。
///
/// ## 为什么是「下一帧」而不是 `initState` 里直接调
///
/// `initState` 期间**不能** `read` provider（`Provider.of` 会因
/// `listen: false` 之外的原因在 build 期抛错），也不该在此时触发
/// `notifyListeners` —— 那会在同一帧内引发额外的重建。
/// `addPostFrameCallback` 让取数发生在首帧渲染之后。
///
/// ## 为什么不是「每个页面各自 `if (data == null) load()`」
///
/// 这条判断**本身就是规则**（什么时候该补取、什么时候不该重复取），
/// 写 7 遍就会漂移。集中在这里，7 个页面只表达「我要兜底」。
void ensureCareerAssetsLoaded(BuildContext context) {
  final CareerAssetsProvider provider = context.read<CareerAssetsProvider>();
  // `data == null` 且有在途请求 → 什么都不做，避免重复取。
  // `data != null` → 已经有数据，重进页面不刷新（Figma 无下拉刷新）。
  if (provider.data == null && !provider.isLoading) {
    provider.load();
  }
}
