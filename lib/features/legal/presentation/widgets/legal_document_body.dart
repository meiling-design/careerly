import 'package:flutter/material.dart';

import '../../../../design_system/tokens/tokens.dart';
import '../../legal_markdown.dart';

/// 把 [LegalBlock] 序列渲染成正文。
///
/// 解析（`legal_markdown.dart`，纯 Dart）与排版（本文件，含 Flutter）分开，
/// 以便解析逻辑能脱离 widget 树单测。
///
/// ## 文字角色：全部复用，**未新增任何 Token**
///
/// 映射关系：
///
/// ```text
/// heading1     → AppTypography.title       (22 / w700)
/// heading2     → AppTypography.subtitle    (18 / w600)
/// heading3     → AppTypography.bodyStrong  (15 / w600)
/// paragraph    → AppTypography.body        (15 / w400)
/// bullet       → AppTypography.body        (15 / w400) + 行首标记
/// orderedItem  → AppTypography.body        (15 / w400) + 行首序号
/// codeBlock    → AppTypography.bodySmall   (13 / w400)
/// divider      → 1px 线，颜色取 AppColors.divider
/// ```
///
/// `app_typography.dart:60-66` 自述这 11 个通用角色是
/// 「Flutter 侧重新归纳」出来的、**非页面专有**，
/// 正是为这种跨页面复用准备的 —— 因此这里不新立 `legalXxx` 角色，
/// 也**不产生新的暂定值**（`CLAUDE.md` §8.2 的登记负担因此为零）。
///
/// ## 行内加粗**不新立角色、也不 copyWith 字重**
///
/// `**强调**` 的落点是既有的 [AppTypography.bodyStrong]（15 / w600）——
/// 它与 [AppTypography.body] **字号、行高、颜色完全相同，只差字重**，
/// 正是「正文里的强调」这一角色。因此不需要 `copyWith(fontWeight: ...)`，
/// 也就不会在组件里内联一个 token 之外的字重值。
///
/// 标题（`heading1` / `heading2`）**不叠加**强调：它们本身已是 w700 / w600，
/// 再套一层没有可辨差异 —— 见 [_strongStyleFor]。
///
/// ## ⚠️ 无 Figma 依据（Flutter 侧补齐，**不得盖章为视觉已定稿**）
///
/// Figma 里根本没有协议页 —— 这份视觉是 Flutter 侧定的。
/// 具体不定项是**块间距**（标题 / 段落 / 分隔线 / 代码块四档）、
/// **列表标记的悬挂缩进**、**分隔线的线宽与浓度**、
/// **代码块的底与圆角**，以及**行内加粗的处理方式**。
/// 取值方式与 `CareerlyTextLink` 的按压态同一处置：
/// **复用已有 Token 档位，不发明新数值**，但因为没有设计源，
/// 验收时不得当作「视觉已确认」
/// —— 登记为 **待裁决 · D124**（`docs/05_progress/TODO.md` §3.1）。
class LegalDocumentBody extends StatelessWidget {
  const LegalDocumentBody({super.key, required this.blocks});

  /// 已解析的正文块。
  final List<LegalBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < blocks.length; i++)
          Padding(
            // 第一块不留上边距：否则页面顶部会多出一段空白。
            padding: EdgeInsets.only(top: i == 0 ? 0 : _gapBefore(blocks[i])),
            child: _BlockView(block: blocks[i]),
          ),
      ],
    );
  }

  /// 块之前的间距。
  ///
  /// 标题前留得比段落大（`AppSpacing.lg` vs `AppSpacing.md`）——
  /// 章节之间需要有可辨的呼吸，否则长文档在视觉上是连续的一坨。
  /// 分隔线是**独立的视觉停顿**，又比标题松一档。
  static double _gapBefore(LegalBlock block) {
    return switch (block.kind) {
      LegalBlockKind.heading1 ||
      LegalBlockKind.heading2 ||
      LegalBlockKind.heading3 => AppSpacing.lg,
      LegalBlockKind.divider => AppSpacing.mdLg,
      LegalBlockKind.codeBlock ||
      LegalBlockKind.paragraph ||
      LegalBlockKind.bullet ||
      LegalBlockKind.orderedItem => AppSpacing.md,
    };
  }
}

/// 单个块。
class _BlockView extends StatelessWidget {
  const _BlockView({required this.block});

  final LegalBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block.kind) {
      LegalBlockKind.heading1 => _RichBody(
        block: block,
        style: AppTypography.title,
      ),
      LegalBlockKind.heading2 => _RichBody(
        block: block,
        style: AppTypography.subtitle,
      ),
      LegalBlockKind.heading3 => _RichBody(
        block: block,
        style: AppTypography.bodyStrong,
      ),
      LegalBlockKind.paragraph => _RichBody(
        block: block,
        style: AppTypography.body,
      ),
      // 两种列表用同一条路径，只在 marker 上分叉 ——
      // 无序给 `•`、有序给 `1.`，都由解析层填进 [LegalBlock.marker]。
      LegalBlockKind.bullet || LegalBlockKind.orderedItem => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: _BodyMetrics.markerColumn,
            child: Text(block.marker ?? '', style: AppTypography.body),
          ),
          Expanded(
            child: _RichBody(block: block, style: AppTypography.body),
          ),
        ],
      ),
      // `Divider` 而不是 `Container(height: 1)`：它是 Material 的自带控件，
      // 语义上是「分隔」，读屏软件会跳过它（纯装饰）。
      LegalBlockKind.divider => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.divider,
      ),
      LegalBlockKind.codeBlock => _CodeBlock(text: block.text),
    };
  }
}

/// 带行内强调的文字块。
///
/// 没有强调时退化成普通 [Text]（保留 `Text.data`，也少一层 `TextSpan`）。
class _RichBody extends StatelessWidget {
  const _RichBody({required this.block, required this.style});

  final LegalBlock block;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final bool hasStrong = block.spans.any((LegalSpan s) => s.strong);
    if (!hasStrong) {
      return Text(block.text, style: style);
    }

    final TextStyle? strongStyle = _strongStyleFor(block.kind);
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          for (final LegalSpan span in block.spans)
            TextSpan(
              text: span.text,
              // `null` = 沿用父级的做法：标题类块不叠加字重。
              style: span.strong ? strongStyle : null,
            ),
        ],
      ),
      style: style,
    );
  }
}

/// 强调段落在该块型下应当用哪个既有角色。
///
/// 返回 `null` 表示「不叠加」—— 父级 [Text.rich] 的 `style` 会直接继承。
///
/// ⚠️ **不返回 `copyWith(fontWeight: ...)` 的临时样式**：那会在组件里
/// 内联一个 token 之外的字重，正是 `CLAUDE.md` §8.2 要防的散落。
/// [AppTypography.bodyStrong] 与 [AppTypography.body] 在字号 / 行高 / 颜色上
/// 完全一致，只差字重，因此正文类块的强调可以直接换角色，无缝。
TextStyle? _strongStyleFor(LegalBlockKind kind) {
  return switch (kind) {
    LegalBlockKind.paragraph ||
    LegalBlockKind.bullet ||
    LegalBlockKind.orderedItem ||
    LegalBlockKind.heading3 => AppTypography.bodyStrong,
    // 标题（h1 22/w700、h2 18/w600）本身已是粗体，再叠一层看不出差别，
    // 因此 `**` 只被摘掉、不做额外处理 —— 标记仍然不会印到屏幕上。
    LegalBlockKind.heading1 ||
    LegalBlockKind.heading2 ||
    LegalBlockKind.divider ||
    LegalBlockKind.codeBlock => null,
  };
}

/// 围栏代码块。
///
/// 三份草案里唯一一处是 AI 数据流图 —— 内容是 ASCII 箭头与缩进。
/// 因此**不换字体族**（`CLAUDE.md` §8.3 要求中文统一 Noto Sans SC，
/// 且工程内没有等宽字体角色），只用一个浅底面板把它与正文区分开。
class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(text, style: AppTypography.bodySmall),
    );
  }
}

/// 组件内部常量。
abstract final class _BodyMetrics {
  /// 列表标记列的宽度，也是条目的悬挂缩进量。
  ///
  /// 这一列要同时容下 `•`（无序）与 `1.`–`99.`（有序）——
  /// 交付的三份草案里序号都是 1 位，`•` / `1.` 在 15px 字号下都远窄于 16，
  /// 长条目换行时第二行与第一行的**文字**对齐，不会回到标记下面。
  ///
  /// ⚠️ **不进 `AppSpacing`** —— 它不是一个页面级间距档位，
  /// 而是这一个控件的内部几何（同 `CareerlyCheckbox` 的 `labelGap` 处置）。
  static const double markerColumn = 16;
}
