/// 协议正文的**极简** Markdown 解析层。
///
/// ## 为什么自己写，而不是引 `flutter_markdown`
///
/// 依据 `CLAUDE.md` §6.5：新增依赖必须「明确必要」且「当前阶段实际使用」。
/// 协议正文只用到 Markdown 的极小一部分，为一个标题层级引一个
/// **已停止维护**的渲染包，代价大于收益。故只实现我们真正用到的那一档。
///
/// ## 支持子集 —— 这是本文档与正文之间的**唯一契约**
///
/// ```text
/// ✅ `# 标题`      一级标题（文档名 / 章节）
/// ✅ `## 标题`     二级标题
/// ✅ `### 标题`    三级标题
/// ✅ `- 条目`      无序列表项（`* ` 同义）
/// ✅ `1. 条目`     有序列表项（序号 1–99，标记后须跟空白）
/// ✅ `---`         分隔线（`***` `___` 同义，连续 3 个及以上）
/// ✅ ``` 围栏代码块  块内**逐字保留**（含缩进），不解析任何标记
/// ✅ `**强调**`    行内加粗（`*斜体*` **不**支持，见下）
/// ✅ 空行          分段 / 结束上一块
/// ✅ 连续非空行    合并为**一个**段落（与 Markdown 一致，行内换行不保留）
/// ✅ `> ` 前缀     引用标记会被**吃掉**，其余按普通段落渲染（降级，不报错）
/// ```
///
/// ### 明确不支持（原样当普通文字，**不报错**）
///
/// ```text
/// ❌ 斜体              `*x*`         → 星号原样显示
/// ❌ 链接 / 图片        `[x](y)` `![]()` → 原样显示（协议页不跳外链）
/// ❌ 表格              `|`           → 原样显示
/// ❌ 四级及更深标题     `####`        → 当作普通段落
/// ❌ HTML              `<br>` 等     → 原样显示
/// ```
///
/// **因此 `assets/legal/*.md` 的正文应当写在上述子集之内** ——
/// 这不是解析器的缺陷，是它被刻意收窄的边界。
///
/// ## 2026-10-07 子集扩容：从五种块型到八种
///
/// 上一轮（Session 023）建这个解析器时，正文还是骨架，子集只有
/// **五种块型 + 无行内标记**，并且明确把 `**` / `---` / 代码块列为「不支持」。
/// 产品侧交付的三份正式草案（`PRIVACY_POLICY` / `TERMS_OF_SERVICE` /
/// `AI_DATA_PROCESSING`）实际用到了这四类 —— 用词频统计确认过：
/// `---` 共 47 处、`**` 共 45 行、围栏代码块 2 处、有序列表 18 行。
///
/// 处理方式是**扩解析器**，而不是去改正文：正文是产品/法务侧的文本，
/// 为了让渲染器好过而删改它属于「自行修改产品规则」（`CLAUDE.md` §0）。
/// 扩容仍然守住「不引依赖」的裁决，新增的四种都是几十行纯 Dart。
///
/// ## 为什么解析与渲染分成两个文件
///
/// 本文件是**纯 Dart**（不 import Flutter），因此可以脱离 widget 树单测；
/// 渲染层 `presentation/widgets/legal_document_body.dart` 只做「块 → Text」的映射。
/// 把两者混在一起会让排版细节挡住解析逻辑的测试。
library;

/// 一个正文块的类型。
enum LegalBlockKind {
  /// `# 标题`
  heading1,

  /// `## 标题`
  heading2,

  /// `### 标题`
  heading3,

  /// 普通段落。
  paragraph,

  /// `- 条目`
  bullet,

  /// `1. 条目`
  ///
  /// 与 [bullet] 分开而不是塞进同一个 kind：两者的**标记形态**不同
  /// （圆点 vs 序号），而序号是有语义的，不能像圆点那样统一成一个常量。
  orderedItem,

  /// `---` 分隔线。**没有文字**（[LegalBlock.text] 为空串）。
  divider,

  /// ``` 围栏代码块。块内逐字保留。
  codeBlock,
}

/// 段落内部的一段行内文字。
///
/// 目前只有一种修饰：**加粗**（`**...**`）。之所以不直接把整块文字存成
/// `String` 而要多这一层，是因为 `**` 在正文里**成对出现于句中**，
/// 渲染时必须拆成多个 `TextSpan` 才能只加粗其中一段。
class LegalSpan {
  const LegalSpan(this.text, {this.strong = false});

  /// 文字（标记已摘掉）。
  final String text;

  /// 是否加粗。
  final bool strong;

  @override
  String toString() =>
      'LegalSpan(${strong ? 'strong, ' : ''}${text.length} chars)';
}

/// 解析后的一个正文块。
class LegalBlock {
  const LegalBlock({
    required this.kind,
    required this.text,
    this.marker,
    this.spans = const <LegalSpan>[],
  });

  /// 块类型。
  final LegalBlockKind kind;

  /// 块文字（已去掉标记与首尾空白）。
  ///
  /// **不变式**：`text == spans.map((s) => s.text).join()` ——
  /// 也就是说 [text] 是 [spans] 的纯文本投影，两者不可能不一致。
  final String text;

  /// 列表项的标记：无序列表是 `•`，有序列表是 `1.` / `2.` …
  ///
  /// 仅 [LegalBlockKind.bullet] 与 [LegalBlockKind.orderedItem] 有值。
  ///
  /// ⚠️ 无序列表的圆点**由解析层给出**（而不是渲染层写死），
  /// 是为了让两种列表走同一条渲染路径 —— 见 `_bulletGlyph` 的说明。
  final String? marker;

  /// 行内分段（含加粗）。至少一段，也可能是空列表（[LegalBlockKind.divider]）。
  final List<LegalSpan> spans;

  @override
  String toString() => 'LegalBlock(${kind.name}, ${text.length} chars)';
}

/// 无序列表项的圆点。
///
/// 取值理由：正文里写的是 `- ` / `* `，两者在 Markdown 中**同义**，
/// 渲染时统一成一个符号。用 `•`（U+2022）是随行距最稳的那一档，
/// 见 `legal_document_body.dart` 的 `_BodyMetrics`。
const String _bulletGlyph = '•';

/// `1. ` 形态的有序列表标记。
///
/// 只认 1–2 位序号，且标记后**必须跟空白**：
/// `2026. 年度总结` 这类以年份开头的句子因此不会被误判成列表项。
final RegExp _orderedPattern = RegExp(r'^([0-9]{1,2})\.\s');

/// `**强调**` 的行内标记。
///
/// `.+?` 是**非贪婪**的 —— 否则 `**甲** 与 **乙**` 会被一个标记吞成
/// 一整段「甲** 与 **乙」。不配对的孤立 `**` 不会匹配，原样保留。
final RegExp _strongPattern = RegExp(r'\*\*(.+?)\*\*');

/// 把协议正文解析成块序列。
///
/// 输入为空 / 全是空白 → 返回空列表（调用方据此走 Empty 态）。
/// 行尾的 `\r` 会被去掉，因此 CRLF 与 LF 的正文都能正确解析
/// —— `assets/legal/*.md` 在 Windows 上极易带 CRLF，这是必须处理的情形
/// （产品侧 2026-10-07 交付的三份草案**全部是 CRLF**）。
List<LegalBlock> parseLegalMarkdown(String source) {
  final List<LegalBlock> blocks = <LegalBlock>[];
  final StringBuffer paragraph = StringBuffer();
  final List<String> codeLines = <String>[];
  bool inCodeFence = false;

  void flushParagraph() {
    final String text = paragraph.toString().trim();
    if (text.isNotEmpty) {
      // 行内强调在**并段之后**统一解析：这样跨行的标记（正文里不该出现，
      // 但万一有）也会被正确吃掉，而不是把 `**` 印在屏幕上。
      blocks.add(_textBlock(LegalBlockKind.paragraph, text));
    }
    paragraph.clear();
  }

  void flushCode() {
    // 首尾空行删掉，其余**逐字保留** —— 代码块里的缩进是内容，
    // 不能像段落那样 trim。三份草案里唯一一处代码块是 AI 数据流图，
    // 靠缩进对齐箭头。
    final List<String> kept = List<String>.of(codeLines);
    while (kept.isNotEmpty && kept.first.trim().isEmpty) {
      kept.removeAt(0);
    }
    while (kept.isNotEmpty && kept.last.trim().isEmpty) {
      kept.removeLast();
    }
    codeLines.clear();
    if (kept.isEmpty) return;

    final String text = kept.join('\n');
    blocks.add(
      LegalBlock(
        kind: LegalBlockKind.codeBlock,
        text: text,
        spans: List<LegalSpan>.unmodifiable(<LegalSpan>[LegalSpan(text)]),
      ),
    );
  }

  // `\r\n` / 单独 `\r` 一律归一成 `\n`：这样下面每一行都不必再操心行尾。
  final List<String> lines = source
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n');

  for (final String raw in lines) {
    // 围栏必须最先判，且只看 `trimLeft()` —— 代码块内部**不解析任何标记**，
    // 里面的 `---` / `**` 都是内容。
    if (raw.trimLeft().startsWith('```')) {
      if (inCodeFence) {
        flushCode();
        inCodeFence = false;
      } else {
        flushParagraph();
        inCodeFence = true;
      }
      continue;
    }
    if (inCodeFence) {
      codeLines.add(raw);
      continue;
    }

    // trim() 同时解决三件事：行首缩进（本子集无嵌套）、
    // 以及 `> ` 引用标记被吃掉后残留的空格。
    final String line = _stripQuoteMarker(raw).trim();

    if (line.isEmpty) {
      flushParagraph();
      continue;
    }

    if (_isDivider(line)) {
      flushParagraph();
      blocks.add(const LegalBlock(kind: LegalBlockKind.divider, text: ''));
      continue;
    }

    final LegalBlockKind? heading = _headingKind(line);
    if (heading != null) {
      // 标题天然分段：先收掉累积中的段落，否则
      // 「说明文字 / ## 下一节」会被并成一段。
      flushParagraph();
      blocks.add(_textBlock(heading, _headingText(line)));
      continue;
    }

    final RegExpMatch? ordered = _orderedPattern.firstMatch(line);
    if (ordered != null) {
      // 列表项各自成块，不与上一行并段。
      flushParagraph();
      final String body = line.substring(ordered.end).trim();
      blocks.add(
        LegalBlock(
          kind: LegalBlockKind.orderedItem,
          text: body,
          marker: '${ordered.group(1)}.',
          spans: _parseInline(body),
        ),
      );
      continue;
    }

    if (_isBullet(line)) {
      flushParagraph();
      final String body = line.substring(2).trim();
      blocks.add(
        LegalBlock(
          kind: LegalBlockKind.bullet,
          text: body,
          marker: _bulletGlyph,
          spans: _parseInline(body),
        ),
      );
      continue;
    }

    // 连续非空行并段（Markdown 的软换行语义）。
    if (paragraph.isNotEmpty) paragraph.write(' ');
    paragraph.write(line);
  }

  // 围栏没闭合（正文写坏了）：把已经攒下的代码按代码块收掉，不报错。
  // 静默丢弃会让「少写一个 ```」表现成整段凭空消失，那比渲染得丑更糟。
  if (inCodeFence) flushCode();
  flushParagraph();
  return List<LegalBlock>.unmodifiable(blocks);
}

/// 造一个「文字 + 行内分段」的块。
LegalBlock _textBlock(LegalBlockKind kind, String text) => LegalBlock(
  kind: kind,
  text: text,
  spans: _parseInline(text),
);

/// 把一行文字拆成「普通 / 加粗」交替的段。
///
/// 不配对的孤立 `**` 不产生任何段，原样留在普通文字里 —— 正文里偶尔会有
/// 数学或代码语境下的星号，宁可多印两个星号，也不能把半行吞掉。
List<LegalSpan> _parseInline(String text) {
  final List<LegalSpan> spans = <LegalSpan>[];
  int cursor = 0;

  for (final RegExpMatch match in _strongPattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(LegalSpan(text.substring(cursor, match.start)));
    }
    spans.add(LegalSpan(match.group(1)!, strong: true));
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(LegalSpan(text.substring(cursor)));
  }

  return List<LegalSpan>.unmodifiable(spans);
}

/// 行首的 `> ` / `>` 引用标记。
///
/// **降级处理**：不实现引用块样式，只把标记摘掉，其余按普通段落渲染。
/// 这样正文里写了 `>` 也只是少一种排版，不会把 `>` 字符印在屏幕上。
String _stripQuoteMarker(String line) {
  final String left = line.trimLeft();
  if (!left.startsWith('>')) return left;
  final String rest = left.substring(1);
  return rest.startsWith(' ') ? rest.substring(1) : rest;
}

/// 该行是不是分隔线。
///
/// 三个及以上**同一种** `-` / `*` / `_` 构成。`- `（破折号加空格）不算 ——
/// 那种是列表项，见 [_isBullet]。
bool _isDivider(String line) {
  if (line.length < 3) return false;
  final String marker = line[0];
  if (marker != '-' && marker != '*' && marker != '_') return false;
  for (int i = 1; i < line.length; i++) {
    if (line[i] != marker) return false;
  }
  return true;
}

/// 该行是不是标题，是的话是哪一级。
///
/// 只认 `# ` / `## ` / `### `（井号后必须跟空格）。
/// `#### ` 及更深**不认**，会落到普通段落 —— 见文件头「明确不支持」。
LegalBlockKind? _headingKind(String line) {
  if (line.startsWith('### ')) return LegalBlockKind.heading3;
  if (line.startsWith('## ')) return LegalBlockKind.heading2;
  if (line.startsWith('# ')) return LegalBlockKind.heading1;
  return null;
}

/// 取标题文字。
///
/// 只在 [_headingKind] 已判定为标题时调用，故这里的井号数必定是 1–3。
String _headingText(String line) {
  final int hashes = line.startsWith('### ')
      ? 3
      : line.startsWith('## ')
      ? 2
      : 1;
  return line.substring(hashes + 1).trim();
}

/// 该行是不是无序列表项（`- ` 与 `* ` 同义）。
///
/// 要求标记后**必须跟空格**：`-` 单独一行是普通段落，
/// 否则「半小时」这类以 `-` 开头的句子会被误判成列表。
bool _isBullet(String line) => line.startsWith('- ') || line.startsWith('* ');
