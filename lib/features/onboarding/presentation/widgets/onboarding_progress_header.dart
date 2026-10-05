import 'package:flutter/material.dart';

import '../../../../design_system/components/components.dart';
import 'back_pill.dart';

/// Onboarding 顶部的「返回键 + 进度条」。
///
/// 真值来源：Figma `OnboardingProgress`（2026-10-04 重新导出版
/// `src/App.tsx` L626-658）。
///
/// ```text
/// flex items-center gap-[29px] px-6 py-[10px]
///   + style={{ paddingInline: 'unset', paddingRight: 75 }}
/// ├── 44×44 Glass 圆钮（rgba(255,255,255,0.55) + blur(12px)），内嵌 17×17 返回箭头
/// └── flex-1 translate-x-px 进度条（height 7，填充 172deg 渐变）
/// ```
///
/// ## 横向内边距：**左 0 / 右 75**（2026-10-04 产品侧指令后采纳）
///
/// Figma 在 `px-6` 之外又内联了 `paddingInline: 'unset', paddingRight: 75`。
/// `px-6` 写的是 `padding-left/right`，而内联的 `padding-inline` 是它俩的
/// 逻辑简写 —— `unset` 会把左右**一起清成 0**，随后 `paddingRight: 75`
/// 只把右端补回 75。**浏览器里实际渲染的就是左 0 / 右 75**。
///
/// 早先的判断是「这更像导出产物的覆盖痕迹」因而**保持现状并登记待裁决**。
/// 产品侧 2026-10-04 真机联调时明确要求「首次注册上方进度条对齐设计稿」，
/// 因此**按 Figma 实渲染值采纳**：
///
/// ```text
/// start: 0   end: 75   （竖直仍是 py-[10px]）
/// ```
///
/// ⚠️ **影响面：本组件被 5 个 Onboarding 页面共用**
/// （注册 / 价值介绍 / 提交简历 / 解析 / 确认），因此**五屏的横向节奏
/// 一起变**。Figma 侧也只有一个 `OnboardingProgress`，是同一处境 ——
/// 但它是一处集中改动，若产品侧只想要注册页变化，需要先把本组件
/// 按页面参数化（属产品决策，未自行做）。
///
/// ## 进度条本体的三处细节
///
/// `translate-x-px`（整条右移 1px）由本文件的 [_HeaderMetrics.barShiftX] 还原；
/// 填充层的 `left: -4px` + `width: calc(pct% + 4px)` 已在
/// [CareerlyProgress] 内部实现（见该组件文档）。
///
/// ## 归属：feature-local，**不进 design-system**
///
/// 它是**页面级复合体**（Glass 圆钮 + 进度条 + 布局间距），
/// 不是可被任意项目复用的原子件；且当前只被 Onboarding 内部使用
/// （注册 / 价值介绍 / 提交简历 / 解析 / 确认 五步）。
/// 按 `CLAUDE.md` §8.4 的判定标准「有没有 Careerly 业务语义」——
/// 它有（引导流程步骤），但它同时**只服务于一个 feature**，
/// 提到 design-system 会让它成为无人复用的空壳。
///
/// 进度条本体是 design-system 组件 [CareerlyProgress]，
/// 本文件只负责「返回键 + 间距 + 组合」。
///
/// ⚠️ **未做的部分**：Figma 的 Glass 圆钮有 4 层 `inset box-shadow` 高光，
/// Flutter 的 `BoxShadow` 不支持 inset。当前只落了外阴影
/// （[AppShadows.onboardingBackPill]）+ 半透明底 + 边框近似，
/// **未做完整的 Glass 边缘高光**。这与导航栏 `GlassSurface` 的处理先例一致，
/// 但**观感需要视觉验证**。
class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.step,
    required this.total,
    required this.onBack,
  });

  /// 当前步骤（从 1 开始）。
  final int step;

  /// 总步数。
  final int total;

  /// 返回回调。
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // Figma: `Math.round((step / total) * 100)` —— 同样先取整再转比例，
    // 保证与设计稿的百分比数字逐位一致（7 / 4 与 1.75 会渲染出不同的宽度）。
    final int percent = total <= 0 ? 0 : ((step / total) * 100).round();
    final double value = percent / 100;

    return Padding(
      // Figma 实渲染值：`padding-inline: unset` + `padding-right: 75`
      // → 左 0 / 右 75；竖直仍是 `py-[10px]`。理由见类文档。
      padding: const EdgeInsetsDirectional.only(
        end: _HeaderMetrics.paddingEnd,
        top: _HeaderMetrics.verticalPadding,
        bottom: _HeaderMetrics.verticalPadding,
      ),
      child: Row(
        children: <Widget>[
          BackPill(onTap: onBack),
          const SizedBox(width: _HeaderMetrics.gap),
          Expanded(
            // Figma `translate-x-px` —— 整条进度条右移 1px。
            // 它是 1px 量级的对齐微调（让填充条左圆角不贴返回键），
            // 与填充层的 `left: -4px` 是一组配套的视觉修正。
            child: Transform.translate(
              offset: const Offset(_HeaderMetrics.barShiftX, 0),
              child: CareerlyProgress(
                value: value,
                semanticsLabel: '引导流程进度',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 组件的内部几何。
///
/// 与 `_ButtonMetrics` / `_NavMetrics` / `_ProgressMetrics` 同理：
/// 这些是**组件内部比例**，不是页面级可调项，故留在文件内，
/// 不进入 `AppSpacing`。
abstract final class _HeaderMetrics {
  /// Figma：右端内边距 `paddingRight: 75`（左端被 `padding-inline: unset` 清成 0）。
  static const double paddingEnd = 75;

  /// Figma `py-[10px]`。
  static const double verticalPadding = 10;

  /// Figma：返回键与进度条之间 `gap-[29px]`。
  static const double gap = 29;

  /// Figma：进度条 `translate-x-px`。
  static const double barShiftX = 1;
}
