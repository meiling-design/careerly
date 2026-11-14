import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/design_system/components/careerly_navigation_bar.dart';
import 'package:careerly/design_system/tokens/tokens.dart';
import 'package:careerly/features/legal/legal_document.dart';
import 'package:careerly/features/legal/legal_markdown.dart';
import 'package:careerly/features/legal/presentation/legal_document_page.dart';
import 'package:careerly/features/legal/presentation/widgets/legal_document_body.dart';
import 'package:careerly/features/profile/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 协议正文（用户协议 / 隐私政策 / AI 数据使用说明）——
/// 解析器单测 + 页面四态 + 入口可达性。
///
/// ## 覆盖的是哪一半
///
/// ```text
/// ✅ 解析器：八种块型、行内加粗、并段、空输入、CRLF、不支持语法的降级行为
/// ✅ 页面：Success / Empty / Error + Retry、无底部导航、返回
/// ✅ 入口：设置页「隐私与数据」三个入口各自落到对应文档页
/// ❌ 视觉：字号 / 间距 / 缩进的**具体取值**不在此验证（那是 D124 的事）
/// ```
///
/// ## ⚠️ 断言**不与正文内容耦合**
///
/// `assets/legal/*.md` 已由产品侧交付**正式草案正文**（2026-10-07），
/// 但这里仍然只碰两类东西：
///
/// ```text
/// ① 结构      —— 渲染出了哪些块型、有没有底部导航、报错时是什么态
/// ② 页面自有文案 —— 标题栏文案（取 [LegalDocument.title]，不是正文）、
///                  Error / Empty 的提示语（写在页面里，不是资产里）
/// ```
///
/// **正文整份替换后本文件不需要改**：解析器的用例一律喂**自造的输入**
/// 而不是读资产，页面用例只断言「有没有渲染出正文」而不断言里面写了什么。
/// 唯一一处引用正文可见字符的断言是列表符号 `•`
/// （见 `legal_markdown.dart` 的 `_bulletGlyph`），那是渲染契约不是条文内容。
///
/// ## 2026-10-07 的扩充（子集扩容 + 第三份文档）
///
/// 上一轮的子集是**五种块型、无行内标记**，本轮的正式草案用到了
/// `---` / `**加粗**` / 围栏代码块 / 有序列表四类，解析器相应扩容到八种块型。
/// 本文件补上了这四类的用例，并把原先「`**` 原样保留」那条**改写成**
/// 「`**` 支持、其余仍原样保留」—— 契约变了，断言必须跟着变。
///
/// ## 为什么不用 `pumpAndSettle`
///
/// Loading 态的 `CircularProgressIndicator` 是**无限动画**，
/// `pumpAndSettle` 会一直等到超时（10s）然后失败。因此改用
/// 「推进到某一帧出现为止」的 [pumpUntilFound] —— 见该函数的文档。
void main() {
  /// 反复推进，直到 [finder] 命中，或推满 [maxPumps] 帧。
  ///
  /// ⚠️ **不能用固定帧数**：`rootBundle.loadString` 在测试里走的是
  /// **真实文件 I/O**，完成时刻不确定 —— 固定帧数会变成偶发失败
  /// （实测：同一个测试单独跑过、跟在前一条之后跑挂）。
  /// 这里的上限是 40×50ms = 2 秒假时钟 + 40 次事件循环机会，余量充足。
  ///
  /// 找不到时**不抛异常** —— 让调用方的 `expect` 去给出可读的失败信息。
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 40,
  }) async {
    for (int i = 0; i < maxPumps; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// 落在协议页并等到正文渲染出来。
  ///
  /// 找到正文后再多推 600ms，把页面转场走完 ——
  /// 否则上一页与本页同时在树上，会把 `find.byTooltip('返回')` 变成两处命中。
  Future<void> settleLoad(WidgetTester tester) async {
    await pumpUntilFound(tester, find.byType(LegalDocumentBody));
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// 启动 App 并直接落在指定入口。
  Future<void> pumpAt(WidgetTester tester, String location) async {
    await tester.pumpWidget(CareerlyApp(initialLocation: location));
    await settleLoad(tester);
  }

  /// 把测试画布加高，让整页（含设置页「更多」分组）一屏内可见。
  ///
  /// 照 `auth_logout_test.dart` 的写法 —— 800×600 的默认画布装不下设置页。
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// 取出正文区当前渲染出的所有 `Text`。
  List<Text> bodyTexts(WidgetTester tester) {
    return tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(LegalDocumentBody),
            matching: find.byType(Text),
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // 解析器
  // ---------------------------------------------------------------------------

  group('协议正文 · 最小渲染器（纯 Dart，不依赖 widget 树）', () {
    test('五种块型各归各位', () {
      final List<LegalBlock> blocks = parseLegalMarkdown(
        '# 一级\n\n## 二级\n\n### 三级\n\n一段正文\n\n- 列表项\n',
      );

      expect(blocks.map((LegalBlock b) => b.kind).toList(), <LegalBlockKind>[
        LegalBlockKind.heading1,
        LegalBlockKind.heading2,
        LegalBlockKind.heading3,
        LegalBlockKind.paragraph,
        LegalBlockKind.bullet,
      ]);
      // 标记本身必须被摘掉，不能印在屏幕上。
      expect(blocks.map((LegalBlock b) => b.text).toList(), <String>[
        '一级',
        '二级',
        '三级',
        '一段正文',
        '列表项',
      ]);
    });

    test('连续非空行合并为一个段落（软换行），空行才分段', () {
      final List<LegalBlock> blocks = parseLegalMarkdown('第一行\n第二行\n\n第三行');

      expect(blocks.length, 2);
      expect(blocks[0].kind, LegalBlockKind.paragraph);
      expect(blocks[0].text, '第一行 第二行');
      expect(blocks[1].text, '第三行');
    });

    test('标题与列表会打断正在累积的段落', () {
      final List<LegalBlock> blocks = parseLegalMarkdown(
        '前言\n## 一节\n- 条目\n后记',
      );

      expect(blocks.map((LegalBlock b) => b.kind).toList(), <LegalBlockKind>[
        LegalBlockKind.paragraph,
        LegalBlockKind.heading2,
        LegalBlockKind.bullet,
        LegalBlockKind.paragraph,
      ]);
      expect(blocks[0].text, '前言');
      expect(blocks[3].text, '后记');
    });

    test('列表项各自成块，不与相邻列表项并段', () {
      final List<LegalBlock> blocks = parseLegalMarkdown('- 一\n- 二\n* 三');

      expect(blocks.length, 3);
      expect(
        blocks.every((LegalBlock b) => b.kind == LegalBlockKind.bullet),
        isTrue,
      );
      // `* ` 与 `- ` 同义。
      expect(blocks.map((LegalBlock b) => b.text).toList(), <String>[
        '一',
        '二',
        '三',
      ]);
    });

    test('空输入与纯空白输入都返回空列表（页面据此走 Empty 态）', () {
      expect(parseLegalMarkdown(''), isEmpty);
      expect(parseLegalMarkdown('   \n\n\t\n \n'), isEmpty);
    });

    test('CRLF 正文与 LF 正文解析结果一致', () {
      // Windows 上手写 / 检出的 `.md` 极易带 `\r`，这是必须处理的情形。
      const String crlf = '# 标题\r\n\r\n正文\r\n';
      const String lf = '# 标题\n\n正文\n';

      final List<LegalBlock> fromCrlf = parseLegalMarkdown(crlf);
      final List<LegalBlock> fromLf = parseLegalMarkdown(lf);

      expect(fromCrlf.length, 2);
      expect(
        fromCrlf.map((LegalBlock b) => b.text).toList(),
        fromLf.map((LegalBlock b) => b.text).toList(),
      );
    });

    test('`**加粗**` 摘掉星号并标成 strong，其余文字照常', () {
      final List<LegalBlock> blocks = parseLegalMarkdown('这是 **重点** 的一句');

      final LegalBlock block = blocks.single;
      expect(block.kind, LegalBlockKind.paragraph);
      // 纯文本投影：星号必须被摘掉，不能印在屏幕上。
      expect(block.text, '这是 重点 的一句');
      expect(
        block.spans.map((LegalSpan s) => '${s.strong ? '*' : ''}${s.text}').toList(),
        <String>['这是 ', '*重点', ' 的一句'],
      );
      // 不变式：text 是 spans 的纯文本投影。
      expect(block.text, block.spans.map((LegalSpan s) => s.text).join());
    });

    test('一行里的多段加粗各自成段（非贪婪匹配）', () {
      final List<LegalBlock> blocks = parseLegalMarkdown('**甲** 与 **乙**、**丙**');

      expect(blocks.single.text, '甲 与 乙、丙');
      expect(
        blocks.single.spans.where((LegalSpan s) => s.strong).map((LegalSpan s) => s.text),
        <String>['甲', '乙', '丙'],
      );
    });

    test('不配对的孤立 `**` 原样保留，不吞掉半行', () {
      // 宁可多印两个星号，也不能因为标记写坏就把整段吃掉。
      final List<LegalBlock> blocks = parseLegalMarkdown('残标记 ** 后面还有话');

      expect(blocks.single.text, '残标记 ** 后面还有话');
      expect(blocks.single.spans.any((LegalSpan s) => s.strong), isFalse);
    });

    test('仍未支持的语法原样保留（不报错、也不猜着渲染）', () {
      final List<LegalBlock> blocks = parseLegalMarkdown(
        '斜体 *强调* 与 [链接](https://example.com)',
      );

      expect(blocks.single.kind, LegalBlockKind.paragraph);
      expect(blocks.single.text, '斜体 *强调* 与 [链接](https://example.com)');
    });

    test('`---` 是分隔线，且没有文字', () {
      final List<LegalBlock> blocks = parseLegalMarkdown('上文\n\n---\n\n下文');

      expect(blocks.map((LegalBlock b) => b.kind).toList(), <LegalBlockKind>[
        LegalBlockKind.paragraph,
        LegalBlockKind.divider,
        LegalBlockKind.paragraph,
      ]);
      expect(blocks[1].text, '');
      expect(blocks[1].marker, isNull);
    });

    test('`-` 少于三个、或与其它字符混排，都不是分隔线', () {
      // `--` 太短；`-x-` 不是同一种字符。两者都该落到普通段落。
      final List<LegalBlock> blocks = parseLegalMarkdown('--\n\n-x-');

      expect(
        blocks.every((LegalBlock b) => b.kind == LegalBlockKind.paragraph),
        isTrue,
      );
    });

    test('有序列表各自成块，序号进 marker 且不留在正文里', () {
      final List<LegalBlock> blocks = parseLegalMarkdown('1. 第一条\n2. 第二条\n3. 第三条');

      expect(blocks.length, 3);
      expect(
        blocks.every((LegalBlock b) => b.kind == LegalBlockKind.orderedItem),
        isTrue,
      );
      expect(
        blocks.map((LegalBlock b) => b.marker).toList(),
        <String>['1.', '2.', '3.'],
      );
      // 序号已经进了 marker，正文里不能再有一份。
      expect(
        blocks.map((LegalBlock b) => b.text).toList(),
        <String>['第一条', '第二条', '第三条'],
      );
    });

    test('以年份开头的段落不会被误判成有序列表', () {
      // 只认 1–2 位序号，否则「2026. 年度总结」会被当成列表项。
      final List<LegalBlock> blocks = parseLegalMarkdown('2026. 年度总结');

      expect(blocks.single.kind, LegalBlockKind.paragraph);
      expect(blocks.single.text, '2026. 年度总结');
    });

    test('围栏代码块逐字保留，块内的标记不被解析', () {
      final List<LegalBlock> blocks = parseLegalMarkdown(
        '前文\n\n```text\n用户\n  ↓\n---\n**不是加粗**\n```\n\n后文',
      );

      expect(blocks.map((LegalBlock b) => b.kind).toList(), <LegalBlockKind>[
        LegalBlockKind.paragraph,
        LegalBlockKind.codeBlock,
        LegalBlockKind.paragraph,
      ]);
      // 缩进与 `---` / `**` 都必须是**内容**，不是标记。
      expect(blocks[1].text, '用户\n  ↓\n---\n**不是加粗**');
      expect(blocks[1].spans.length, 1);
      expect(blocks[1].spans.single.strong, isFalse);
      expect(blocks[2].text, '后文');
    });

    test('围栏没闭合时按代码块收掉，不静默丢弃', () {
      // 少写一个 ``` 应当渲染得「多」，而不是让整段凭空消失。
      final List<LegalBlock> blocks = parseLegalMarkdown('```\n第一行\n第二行');

      expect(blocks.single.kind, LegalBlockKind.codeBlock);
      expect(blocks.single.text, '第一行\n第二行');
    });

    test('代码块首尾的空行被删掉，中间的空行保留', () {
      final List<LegalBlock> blocks = parseLegalMarkdown('```\n\n甲\n\n乙\n\n```');

      expect(blocks.single.text, '甲\n\n乙');
    });

    test('CRLF 正文里的代码块同样能正确解析', () {
      const String crlf = '```\r\n甲\r\n  ↓\r\n乙\r\n```\r\n';

      final List<LegalBlock> blocks = parseLegalMarkdown(crlf);

      expect(blocks.single.kind, LegalBlockKind.codeBlock);
      // `\r` 不能混进代码内容里，否则箭头会带着一个不可见字符右移。
      expect(blocks.single.text, '甲\n  ↓\n乙');
    });

    test('四级标题不认，落到普通段落且保留井号', () {
      final List<LegalBlock> blocks = parseLegalMarkdown('#### 四级');

      expect(blocks.single.kind, LegalBlockKind.paragraph);
      expect(blocks.single.text, '#### 四级');
    });

    test('不跟空格的 `-` 是正文，不是列表', () {
      // 否则「- 半小时」这类句子会被误判成列表项。
      final List<LegalBlock> blocks = parseLegalMarkdown('-半小时\n\n- 半小时');

      expect(blocks[0].kind, LegalBlockKind.paragraph);
      expect(blocks[0].text, '-半小时');
      expect(blocks[1].kind, LegalBlockKind.bullet);
      expect(blocks[1].text, '半小时');
    });

    test('引用标记被吃掉，其余按普通段落渲染', () {
      // 降级处理：不实现引用块样式，但也不能把 `>` 印在屏幕上。
      final List<LegalBlock> blocks = parseLegalMarkdown('> 被引用的一行');

      expect(blocks.single.kind, LegalBlockKind.paragraph);
      expect(blocks.single.text, '被引用的一行');
    });

    test('返回的列表是只读的（解析结果不应被调用方改坏）', () {
      final List<LegalBlock> blocks = parseLegalMarkdown('正文');

      expect(
        () => blocks.add(const LegalBlock(
          kind: LegalBlockKind.paragraph,
          text: 'x',
        )),
        throwsUnsupportedError,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 页面
  // ---------------------------------------------------------------------------

  group('协议页 · 两份文档共用一个页面类', () {
    testWidgets('落在 /legal/privacy 时渲染正文，且没有底部导航', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.legalPrivacy);

      expect(find.byType(LegalDocumentPage), findsOneWidget);
      expect(find.byType(LegalDocumentBody), findsOneWidget);

      // 标题栏文案取自 [LegalDocument.title]，不是正文里的标题 ——
      // 正文整份替换不影响这条断言。
      expect(
        find.text(LegalDocument.privacyPolicy.title),
        findsWidgets,
      );

      // 协议页是**二级页**：没有底部导航、不属于任何一级导航。
      expect(
        find.byType(CareerlyNavigationBar),
        findsNothing,
        reason: '协议页不属于任何一级导航，不应渲染 Shell 的导航栏',
      );
    });

    testWidgets('落在 /legal/terms 时渲染的是《用户协议》', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.legalTerms);

      expect(find.byType(LegalDocumentPage), findsOneWidget);
      expect(find.text(LegalDocument.termsOfService.title), findsWidgets);
      expect(find.byType(CareerlyNavigationBar), findsNothing);
    });

    testWidgets('落在 /legal/ai-data 时渲染的是《AI 数据使用说明》', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, AppRoutes.legalAiData);

      expect(find.byType(LegalDocumentPage), findsOneWidget);
      expect(find.text(LegalDocument.aiDataProcessing.title), findsWidgets);
      expect(find.byType(CareerlyNavigationBar), findsNothing);
    });

    testWidgets('三份文档的资产路径两两不同（枚举值不会互相覆盖）', (
      WidgetTester tester,
    ) async {
      // 枚举只有 title / assetPath 两个字段，「新增一个值」最容易犯的错
      // 就是复制粘贴时忘改路径 —— 那样第三份文档会**静默显示第一份的正文**。
      final List<String> paths =
          LegalDocument.values.map((LegalDocument d) => d.assetPath).toList();

      expect(paths.toSet().length, LegalDocument.values.length);
      expect(LegalDocument.values.length, 3, reason: 'E1 要求三份齐备');
    });

    testWidgets('标题与列表符号都落到 Text 上', (WidgetTester tester) async {
      await pumpAt(tester, AppRoutes.legalPrivacy);

      final List<Text> texts = bodyTexts(tester);

      expect(
        texts.any((Text t) => t.style == AppTypography.title),
        isTrue,
        reason: '一级标题应映射到 AppTypography.title',
      );
      expect(
        texts.any((Text t) => t.data == '•'),
        isTrue,
        reason: '列表项应渲染出列表符号（见 legal_markdown.dart 的 _bulletGlyph）',
      );
    });

    testWidgets('加粗的行内片段用的是 AppTypography.bodyStrong，而不是内联字重', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LegalDocumentPage(
            document: LegalDocument.privacyPolicy,
            // 注入缝：自造输入 —— 断言的是「strong 走哪个 Token」，
            // 与资产里到底哪几句被加粗无关。
            loader: () async => '普通 **重点** 普通\n',
          ),
        ),
      );
      await pumpUntilFound(tester, find.byType(LegalDocumentBody));

      final List<Text> texts = bodyTexts(tester);

      // 命中一条带 strong span 的富文本，其 strong 子 span 必须指向 Token
      // 里的 bodyStrong —— 页面不得出现 copyWith(fontWeight:) 这类内联字重。
      final bool foundStrong = texts.any((Text t) {
        final InlineSpan? span = t.textSpan;
        if (span is! TextSpan) return false;
        return span.children?.any(
              (InlineSpan child) =>
                  child is TextSpan && child.style == AppTypography.bodyStrong,
            ) ??
            false;
      });

      expect(
        foundStrong,
        isTrue,
        reason: '加粗片段应复用 AppTypography.bodyStrong（§8.2：不得硬编码字重）',
      );
    });

    testWidgets('读取失败时走 Error 态，点「重试」可恢复', (WidgetTester tester) async {
      int calls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: LegalDocumentPage(
            document: LegalDocument.privacyPolicy,
            // 注入缝 —— 真实资产永远读得成功，Error 态否则不可达、不可测。
            loader: () async {
              calls++;
              if (calls == 1) throw StateError('资产读取失败（测试注入）');
              return '# 标题\n\n正文\n';
            },
          ),
        ),
      );
      await pumpUntilFound(tester, find.text('协议内容读取失败，请重试'));

      expect(find.text('协议内容读取失败，请重试'), findsOneWidget);
      expect(find.byType(LegalDocumentBody), findsNothing);

      await tester.tap(find.text('重试'));
      await pumpUntilFound(tester, find.byType(LegalDocumentBody));

      expect(calls, 2, reason: '「重试」必须真的再读一次，而不是只切状态');
      expect(find.text('协议内容读取失败，请重试'), findsNothing);
      expect(find.byType(LegalDocumentBody), findsOneWidget);
    });

    testWidgets('文件存在但无可渲染的块时走 Empty 态', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LegalDocumentPage(
            document: LegalDocument.privacyPolicy,
            loader: () async => '   \n\n',
          ),
        ),
      );
      await pumpUntilFound(tester, find.text('协议内容为空'));

      // ⚠️ 文案按「内容事故」写，不写「暂无内容」—— 见 [`LegalDocumentPage`]
      // 类文档「四态」一节。
      expect(find.text('协议内容为空'), findsOneWidget);
      expect(find.byType(LegalDocumentBody), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // 入口
  // ---------------------------------------------------------------------------

  group('协议页 · 入口', () {
    /// 点协议页顶部的返回按钮，等它落回设置页。
    ///
    /// 二级页返回：顶部返回按钮走 `careerlyBack`（CLAUDE.md §5.6）。
    /// ⚠️ 必须把 finder **限定在协议页内** —— 设置页自己也有一枚「返回」，
    /// 直接 `find.byTooltip('返回')` 在转场期间会命中两处。
    ///
    /// ⚠️ 用不了 `tester.pageBack()`：它找的是 tooltip 为 `Back` 的按钮，
    /// 而 Careerly 的返回按钮 tooltip 是「返回」。
    Future<void> tapPageBack(WidgetTester tester) async {
      await tester.tap(
        find.descendant(
          of: find.byType(LegalDocumentPage),
          matching: find.byTooltip('返回'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    /// 从设置页点某个入口，断言落到 [document] 对应的正文页。
    ///
    /// ⚠️ 点的必须是**入口行自己的文案**，不是分区标题 ——
    /// 「隐私与数据」自 2026-10-07（D123 = A）起是**分区标题**，
    /// 它是一行不可点的 `Text`，点它什么都不会发生。
    Future<void> tapEntry(
      WidgetTester tester,
      LegalDocument document,
    ) async {
      await tester.tap(find.text(document.title));
      await settleLoad(tester);

      expect(find.byType(LegalDocumentPage), findsOneWidget);
      expect(find.text(document.title), findsWidgets);
    }

    testWidgets('设置页的三个入口各自打开对应文档', (WidgetTester tester) async {
      useTallViewport(tester);

      for (final LegalDocument document in LegalDocument.values) {
        await pumpAt(tester, AppRoutes.settings);
        expect(find.byType(SettingsPage), findsOneWidget);

        await tapEntry(tester, document);

        // 每次回到设置页重新来过，避免上一次的 push 残留在栈上。
        await tapPageBack(tester);
        expect(find.byType(SettingsPage), findsOneWidget);
      }
    });

    testWidgets('设置页「隐私与数据」进入隐私政策页，返回回到设置页', (
      WidgetTester tester,
    ) async {
      useTallViewport(tester);
      await pumpAt(tester, AppRoutes.settings);

      expect(find.byType(SettingsPage), findsOneWidget);

      await tapEntry(tester, LegalDocument.privacyPolicy);
      await tapPageBack(tester);

      // 返回落回设置页 —— 这条同时钉住了「是 push 进来而不是替换掉设置页」：
      // 若当初是替换，pop 之后不会有页面可回。
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(LegalDocumentPage), findsNothing);
    });
  });
}
