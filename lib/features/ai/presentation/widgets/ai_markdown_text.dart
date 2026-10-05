import 'package:flutter/material.dart';

import '../../../../design_system/tokens/tokens.dart';

/// 把 AI 回答里的 Markdown **子集**渲染成富文本。
///
/// ## 为什么不是完整的 Markdown 渲染器
///
/// 后端（`qwen3.5-plus`）实际只会吐出这几种结构：行内 `**粗体**`、
/// 行首的 `* ` / `- ` 列表项、以及空行分段。为此引入一个 Markdown 包
/// 不划算 —— `CLAUDE.md` §6.5 要求每个依赖「当前阶段**实际使用**」，
/// 而一个完整渲染器会顺带把标题、代码块、表格、链接都变成这个
/// 聊天气泡要面对的东西，那既不是设计稿的意图，也不是这里需要的。
///
/// 所以这里**只**解析 [_parse] 里列出的子集，其余语法一律按普通
/// 文字原样显示 —— **不猜、不吞**。宁可让用户看到一个多余的 `#`，
/// 也不要把看不清语义的内容悄悄渲染成别的样子。
///
/// ⚠️ 要往里加语法，先拿出「后端真的会吐它」的证据。
/// 没有证据就加，等于把渲染器变成一个猜谜游戏。
class AiMarkdownText extends StatelessWidget {
  const AiMarkdownText({super.key, required this.text, required this.style});

  /// 原始文本（可能含 Markdown 记号）。
  final String text;

  /// 基础文字样式。粗体由 [AppTypography.bodyStrong] 的字重派生，
  /// 不在本文件里硬编码字重。
  final TextStyle style;

  /// 行首列表项的记号：`*` / `-` / `•`，前面可有缩进。
  static final RegExp _bullet = RegExp(r'^(\s*)[*\-•]\s+(.*)$');

  /// 行内粗体：`**…**`。
  static final RegExp _strong = RegExp(r'\*\*(.+?)\*\*', dotAll: true);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final _Block block in _parse(text)) _buildBlock(block),
      ],
    );
  }

  Widget _buildBlock(_Block block) {
    return switch (block) {
      _Gap() => const SizedBox(height: AppSpacing.xs),
      _Paragraph(:final String text) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
          child: Text.rich(TextSpan(children: _inline(text)), style: style),
        ),
      _Bullet(:final String text, :final int level) => Padding(
          padding: EdgeInsets.only(
            left: level * AppSpacing.md,
            bottom: AppSpacing.xxs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('•', style: style),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child:
                    Text.rich(TextSpan(children: _inline(text)), style: style),
              ),
            ],
          ),
        ),
    };
  }

  /// 行内解析：只处理 `**粗体**`，其余原样成段。
  ///
  /// 未闭合的 `**` 不会被吞掉 —— 正则要求成对匹配，落单的记号会
  /// 作为普通文字留在 [TextSpan] 里。
  List<InlineSpan> _inline(String source) {
    final TextStyle strongStyle = style.copyWith(
      fontWeight: AppTypography.bodyStrong.fontWeight,
    );
    final List<InlineSpan> spans = <InlineSpan>[];
    int cursor = 0;
    for (final RegExpMatch match in _strong.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: source.substring(cursor, match.start)));
      }
      spans.add(TextSpan(text: match.group(1), style: strongStyle));
      cursor = match.end;
    }
    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor)));
    }
    return spans;
  }

  /// 按行切块。空行产生一个 [_Gap]（连续空行只算一个）。
  static List<_Block> _parse(String source) {
    final List<_Block> blocks = <_Block>[];
    for (final String line in source.split('\n')) {
      if (line.trim().isEmpty) {
        if (blocks.isNotEmpty && blocks.last is! _Gap) {
          blocks.add(const _Gap());
        }
        continue;
      }
      final RegExpMatch? bullet = _bullet.firstMatch(line);
      if (bullet != null) {
        // 两个空格算一级缩进，最多两级 —— 再深就只是挤窄文字，不再有信息量。
        final int level = (bullet.group(1)!.length ~/ 2).clamp(0, 2);
        blocks.add(_Bullet(text: bullet.group(2)!, level: level));
      } else {
        blocks.add(_Paragraph(text: line.trim()));
      }
    }
    // 结尾的空白不产生视觉间隔 —— 气泡自己的 padding 已经够了。
    while (blocks.isNotEmpty && blocks.last is _Gap) {
      blocks.removeLast();
    }
    return List<_Block>.unmodifiable(blocks);
  }
}

/// 一个渲染块。三种形态对应子集里的三种结构。
sealed class _Block {
  const _Block();
}

class _Paragraph extends _Block {
  const _Paragraph({required this.text});
  final String text;
}

class _Bullet extends _Block {
  const _Bullet({required this.text, required this.level});
  final String text;
  final int level;
}

class _Gap extends _Block {
  const _Gap();
}
