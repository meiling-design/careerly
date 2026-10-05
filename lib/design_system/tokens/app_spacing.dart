import 'package:flutter/widgets.dart';

/// Careerly 间距 Token。
///
/// 8pt 基准体系的细化版本：4 作为最小步进，用于图标与文字之间这类紧凑场景。
///
/// 依据 Baseline §7.5：Screen 负责组合，Component 负责表现——
/// 间距必须来自 Token，不得在页面里写魔数。
abstract final class AppSpacing {
  /// 4 — 图标与文字之间的紧凑间距。
  static const double xxs = 4;

  /// 8 — 元素内最小间隔。
  static const double xs = 8;

  /// 12 — 卡片内元素间距。
  static const double sm = 12;

  /// 16 — 页面横向安全边距 / 卡片内边距。
  static const double md = 16;

  /// 20 — 卡片内边距（宽松）。
  static const double mdLg = 20;

  /// 24 — 区块之间间距。
  static const double lg = 24;

  /// 32 — 大区块之间间距。
  static const double xl = 32;

  /// 40 — 页面顶部留白。
  static const double xxl = 40;

  /// 48 — 强分隔留白。
  static const double xxxl = 48;

  // ---------------------------------------------------------------------------
  // 语义别名
  //
  // ⚠️ **本节全部是归纳值 · 待视觉验证**
  //    → **待裁决 · D41**（集中登记见 `CURRENT_STATUS.md` §3.6）
  //
  // Figma 里**没有这些语义名** —— 它直接用 Tailwind 类（`px-5` / `p-4` …）。
  // 下面每个别名都是 Flutter 侧「挑一档最常见的当语义值」的结果。
  //
  // 各档在 Figma 中的实际出现次数（供调整时参考）：
  //
  //   页面横向：px-5(20) = 47 次  ← 最主流
  //             px-6(24) = 22 次
  //             px-4(16) = 12 次
  //   卡片内边距：p-5(20) = 21 次 / p-4(16) = 20 次  ← 接近
  //   区块之间：space-y-4(16) = 20 次 / space-y-3(12) = 13 次
  //
  // ⚠️ **注意 [pageHorizontal]**：取的是 16，而 Figma 最主流的是 **20**。
  // 这是**最可能需要在真实页面上调整**的一项（影响所有页面的左右留白）。
  // ---------------------------------------------------------------------------

  /// 页面横向安全边距。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D37）** —— 取 `16`，但 Figma 中
  /// `px-5`(20) 出现 **47 次**、`px-4`(16) 仅 12 次。**20 更可能是真值。**
  /// 若实际页面左右留白偏窄，把这里改成 `mdLg` 即可全局生效。
  static const double pageHorizontal = md;

  /// 页面顶部内容起始边距。⚠️ **暂定值 · 待视觉验证**（Figma 无对应语义名）。
  static const double pageTop = lg;

  /// 页面底部内容结束边距（不含底部导航）。⚠️ **暂定值 · 待视觉验证**。
  static const double pageBottom = xl;

  /// 卡片内边距。⚠️ **暂定值 · 待视觉验证**（Figma 中 `p-5` 21 次 / `p-4` 20 次，几乎持平）。
  static const double cardPadding = md;

  /// 卡片之间的间距。
  ///
  /// ✅ **与 Figma 主流一致** —— `gap-3`（12）出现 **37 次**，是最常见的一档。
  /// （语义名仍是归纳的，但**取值**有依据 → D41）
  static const double cardGap = sm;

  /// 列表项之间的间距。⚠️ **暂定值 · 待视觉验证**（D41，Figma 无对应语义名）。
  static const double listGap = sm;

  // ---------------------------------------------------------------------------
  // Onboarding（Phase 4 批 1）
  //
  // ✅ 两个值都是 **Figma 原值**（不是从刻度里挑的），但它们**不在 8pt 刻度上**：
  // 14 落在 sm(12) 与 md(16) 之间，28 落在 lg(24) 与 xl(32) 之间。
  //
  // 处理：**不就地取整**（取整会让页面与设计稿差 2–4px，且无从追溯），
  // 而是按 `CLAUDE.md` §8.2 的「暂定值集中管理」原则作为独立 Token 落在这里。
  // 若视觉验证后认为该并入刻度，改这两处即可，页面无需改动。
  // ---------------------------------------------------------------------------

  /// 主 / 次按钮之间的垂直间距。
  /// Figma `OnSplash`：`space-y-[14px]`。
  static const double buttonStack = 14;

  /// Onboarding 的成块内容间距。
  ///
  /// Figma 在两处独立写了同一个值 `28`：
  /// - `OnRegister`：表单字段容器 `marginTop: 28`
  /// - `OnSplash`：「记录成长」到说明文案 `marginBottom: 28`
  ///
  /// 两处同值且同为「块与块之间」，故收敛为**一个** Token
  /// （两个同值 Token 迟早会各自漂移）。
  static const double blockGap = 28;

  // ---------------------------------------------------------------------------
  // 登录 / 注册页（新版 Figma 重新导出 · 2026-10-04）
  //
  // ✅ 三个值都是 **Figma 原值**，且各自在**登录页与注册页各出现一次**
  //    （`App.tsx` L517/L588/L594 与 L714/L769/L775）—— 两页同构。
  //    这是页级几何里唯一「跨页重复」的部分，故提到 Token 层。
  //
  // ⚠️ 其余页级数值（面板内边距 31 / 副标题上距 20 / 表单上距 34 与 32 /
  //    头像上距 34 / 主按钮上距 20 与 32 等）**只在单页出现**，
  //    按本仓库既定做法留在该页面私有的 `_XxxMetrics` 里，**不上提** ——
  //    它们不是「共用间距」，只是恰好数值相近。
  //
  // ⚠️ 6 与 21 **不在** 8pt 刻度上（分别落在 xxs(4)–xs(8) 与 mdLg(20)–lg(24) 之间）。
  //    同 [buttonStack] / [blockGap]：**不就地取整**，避免页面与设计稿差像素。
  // ---------------------------------------------------------------------------

  /// 登录 / 注册页表单字段之间的垂直间距。Figma 两页均为 `gap-5`。
  static const double authFieldGap = 20;

  /// 登录 / 注册页「标签 ↔ 输入框」的间距。Figma 两页均为 `gap-1.5`（6px）。
  static const double authLabelGap = 6;

  /// 登录 / 注册页「微信 / QQ」两个按钮之间的横向间距。
  /// Figma 两页均为 `gap-[21px]`。
  static const double authSocialGap = 21;

  // ---------------------------------------------------------------------------
  // 便捷 EdgeInsets
  // ---------------------------------------------------------------------------

  static const EdgeInsets pageInsets = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
  );

  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);

  /// 考虑底部安全区与自绘导航之后的内容内边距。
  static EdgeInsets pageWithBottomBar({
    required double bottomBarHeight,
    double top = pageTop,
    double bottom = pageBottom,
  }) {
    return EdgeInsets.only(
      top: top,
      bottom: bottomBarHeight + bottom,
    );
  }
}
