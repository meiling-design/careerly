import 'package:flutter/widgets.dart';

/// Careerly 圆角 Token。
///
/// 取值归纳自 Figma Make 实际使用的圆角（12 / 14 / 16 / 20 / 22 / 24 / 999）。
/// 依据 Baseline §6.2 的同一原则：原型数值需要重新归纳，不 1:1 抄——
/// 因此这里收敛成 6 档 + pill。
abstract final class AppRadius {
  /// 12 — 小元素：Chip、输入框、小图标容器。
  static const double xs = 12;

  /// 14 — 列表行 / 次级块。
  static const double sm = 14;

  /// 16 — 常规卡片。
  static const double md = 16;

  /// 20 — 大卡片 / Bottom Sheet 顶部。
  static const double lg = 20;

  /// 24 — 主卡片 / Glass 面板。
  static const double xl = 24;

  /// 28 — 特大面板（模态、全宽卡片）。
  static const double xxl = 28;

  /// 36 — 首页 Hero 卡（Figma 原值，**不在**上方的归纳阶梯内）。
  ///
  /// ⚠️ Figma 首页 Hero 卡写死 `borderRadius: 36`（`App.tsx` L1048）。
  /// 它比阶梯的最大档 [xxl]（28）还大 8，**未收敛进阶梯**是为了与设计稿
  /// 逐位一致 —— 首页这张卡的圆角是它的主要视觉特征，改小会明显变味。
  ///
  /// 用途当前**只有 1 处**。若后续出现更多 36，再考虑并入阶梯。
  static const double hero = 36;

  /// 18 — 图标底板（Figma 原值，**不在**上方的归纳阶梯内）。
  ///
  /// ⚠️ Figma 在 Onboarding 的 **60×60 渐变图标底板**上写死
  /// `borderRadius: 18`（`App.tsx` L763）。它落在阶梯的 16 与 20 之间，
  /// **未收敛进阶梯**是为了与设计稿逐位一致。
  ///
  /// 用途当前**只有 1 处**。若后续出现更多 18，再考虑并入阶梯。
  static const double iconTile = 18;

  /// 全圆角：胶囊按钮、Tab 指示器、头像。
  static const double pill = 999;

  // ---------------------------------------------------------------------------
  // 登录 / 注册页（新版 Figma · 2026-10-04）
  //
  // 真值来源：Figma `OnLogin`（`src/App.tsx` L473 / L598）与
  // `OnRegister`（L679 / L779）。两处**逐位一致**，不是归纳。
  //
  // ⚠️ 这一档（10）**故意不并入上面的归纳阶梯**：它比最小档 [xs]（12）
  //    还小 2，而新稿的方框输入框是**实色中性描边**形态（见
  //    `CareerlyInputVariant.outlined`），圆角大小直接决定「方正感」——
  //    改成 12 会明显变圆。这与 [hero] / [iconTile] 的处置同理。
  // ---------------------------------------------------------------------------

  /// 10 — 登录 / 注册页的方框输入框与社交按钮圆角。
  ///
  /// Figma 为这两个控件各写了两次 `borderRadius: 10`
  /// （登录页输入框 + 社交按钮、注册页输入框 + 社交按钮），
  /// 形态与数值完全相同，故只立**一个** Token。
  static const double authField = 10;

  /// 登录页底部面板的**顶部**圆角半径。
  ///
  /// Figma `OnLogin` L503：`rounded-t-[40px]` —— 只有上方两个角。
  /// 该面板占满屏宽、贴底，是**页面内的常驻面板**而不是
  /// `CareerlyBottomSheet`（后者是 `show()` 出来的模态）。
  static const double authPanelTop = 40;

  // ---------------------------------------------------------------------------
  // 便捷 BorderRadius
  // ---------------------------------------------------------------------------

  static const BorderRadius borderIconTile = BorderRadius.all(
    Radius.circular(iconTile),
  );

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderHero = BorderRadius.all(
    Radius.circular(hero),
  );
  static const BorderRadius borderPill = BorderRadius.all(
    Radius.circular(pill),
  );

  /// 登录 / 注册页方框输入框、社交按钮圆角（[authField]）。
  static const BorderRadius borderAuthField = BorderRadius.all(
    Radius.circular(authField),
  );

  /// 登录页底部面板顶圆角（[authPanelTop]）。
  static const BorderRadius borderAuthPanel = BorderRadius.vertical(
    top: Radius.circular(authPanelTop),
  );

  // ---------------------------------------------------------------------------
  // 语义别名
  //
  // ⚠️ **本节是归纳值 · 待视觉验证**
  //    → **待裁决 · D41**（集中登记见 `CURRENT_STATUS.md` §3.6）
  //
  // Figma 里没有这些语义名，只有 Tailwind 类与内联 `borderRadius`。
  // 各档实际出现次数（Tailwind 类 + 内联数值合计）供调整参考：
  //
  //   rounded-full / 99  = 81 + 57 次  ← 压倒性主流
  //   rounded-2xl  (16)  = 25 次
  //   rounded-xl   (12)  = 17 次
  //   rounded-3xl  (24)  =  8 次
  //   rounded-t-3xl(24)  =  5 次（仅顶部）
  //   28                 =  3 次（其中 2 次是 rounded-t-[28px]，即 BottomSheet）
  //
  // ✅ **六个刻度值本身都有 Figma 依据**（12/14/16/20/24/28 均能在
  // `App.tsx` 的内联 `borderRadius` 中找到），但**「分成六档」是归纳的** ——
  // Figma 并未定义一套圆角阶梯。
  // ---------------------------------------------------------------------------

  /// 标准卡片圆角。
  static const BorderRadius card = borderXl;

  /// 次级卡片圆角。
  static const BorderRadius cardSmall = borderMd;

  /// 按钮圆角。
  static const BorderRadius button = borderPill;

  /// 输入框圆角。
  ///
  /// ⚠️ **暂定值 · 待视觉验证（待裁决 · D39）** —— Figma 的输入框**并不统一**：
  /// 工作台内联表单用 `rounded-2xl`（**16**，与本值一致），
  /// 而 a-jd-step 展开区用 `rounded-xl`（**12**）。
  /// 取 16 是因为它出现在更完整的那一版表单上。
  ///
  /// ⚠️ **登录 / 注册页的方框输入框不走本值**，走 [borderAuthField]（10）——
  /// 那是 2026-10-04 重新导出的 Figma 为登录 / 注册页**单独定义**的形态，
  /// 与工作台内联表单的 16 不是同一套。**不要为了「统一」把它们合并**。
  static const BorderRadius input = borderMd;

  /// Bottom Sheet 顶部圆角。
  ///
  /// ⚠️ **暂定值 · 待视觉验证，且与 D29 冲突** —— 本值 `28` 只对应
  /// Figma 变体 C / D；变体 A / B / E / F 用的是 `24`。
  /// **该 Token 把两种取值收敛成了一档。** 详见待裁决清单 D29。
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}
