import 'package:careerly/design_system/components/components.dart';
import 'package:careerly/design_system/tokens/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Careerly `CareerlyInput` 测试。
///
/// 断言取向与批 1 / 批 2 一致：**能真的发现回归**，而不是「渲染不抛异常」。
///
/// 本文件钉死四类容易在后续被「顺手统一」掉的事：
///
/// 1. **四个变体的形态差异**（下边框 / 细边框 + 半透底 / 灰底无边框 / 全透明）
///    —— 「要不要统一成一套输入样式」是**设计决策**，
///    在裁决之前任何统一化都是回归。
/// 2. **字数计数器在标题行**，不在输入框右下角
///    （Material 默认位置，Figma 无依据）
/// 3. **`CareerlyInputTone.purple` 真的换色**（蓝紫两套不是同一个值）
/// 4. **Disabled 真的换色**，而不是只把 `enabled` 传下去
void main() {
  Widget host(Widget child) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );
  }

  /// 组件内所有 `BoxDecoration`，按树的顺序。
  ///
  /// ⚠️ 只取 `CareerlyInput` 的**后代** —— 避免把 `MaterialApp` / `Scaffold`
  /// 自身的装饰也算进来。
  List<BoxDecoration> decorations(WidgetTester tester) {
    return tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(CareerlyInput),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((DecoratedBox d) => d.decoration)
        .whereType<BoxDecoration>()
        .toList();
  }

  /// 只有下边框的外壳（`underline` 变体）。
  ///
  /// 按「上边框宽度为 0、下边框宽度为 1.217」识别 ——
  /// 这是 Figma `INPUT_BASE` 的原值，也是与 `boxed`（四边等宽 1.5）的区别。
  BoxDecoration? underlineShell(WidgetTester tester) {
    for (final BoxDecoration d in decorations(tester)) {
      final BoxBorder? b = d.border;
      if (b is Border && b.top.width == 0 && b.bottom.width > 0) {
        return d;
      }
    }
    return null;
  }

  /// 四边等宽边框的外壳（`boxed` 变体）。
  BoxDecoration? borderedShell(WidgetTester tester) {
    for (final BoxDecoration d in decorations(tester)) {
      final BoxBorder? b = d.border;
      if (b is Border && b.top.width > 0 && b.top.width == b.bottom.width) {
        return d;
      }
    }
    return null;
  }

  /// 有填充色的外壳（`boxed` / `filled`）。
  BoxDecoration? filledShell(WidgetTester tester) {
    for (final BoxDecoration d in decorations(tester)) {
      if (d.color != null && d.color != Colors.transparent) {
        return d;
      }
    }
    return null;
  }

  /// 组件内唯一的 `TextField`。
  TextField field(WidgetTester tester) => tester.widget<TextField>(
    find.descendant(
      of: find.byType(CareerlyInput),
      matching: find.byType(TextField),
    ),
  );

  /// `TextField` 的实际文字样式。
  ///
  /// `TextField.style` 为 `null` 时回退到 `theme.textTheme.bodyLarge`，
  /// 而本组件的形态全靠 `style` 表达，因此 `null` 一律视为失败。
  TextStyle fieldStyle(WidgetTester tester) {
    final TextStyle? style = field(tester).style;
    expect(style, isNotNull, reason: '输入值样式必须由 Token 提供，不能为 null');
    return style!;
  }

  /// `hint` 的实际样式。
  TextStyle hintStyle(WidgetTester tester) {
    final InputDecoration? decoration = field(tester).decoration;
    expect(decoration, isNotNull);
    final TextStyle? style = decoration!.hintStyle;
    expect(style, isNotNull, reason: 'hint 样式必须由 Token 提供，不能为 null');
    return style!;
  }

  // ---------------------------------------------------------------------------
  // 变体形态（核心：四个变体必须保持可区分）
  // ---------------------------------------------------------------------------

  group('CareerlyInput 变体', () {
    testWidgets('underline：仅下边框，宽 1.217，无填充、无圆角', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.underline,
            hint: '你的名字',
          ),
        ),
      );

      final BoxDecoration shell = underlineShell(tester)!;

      final Border border = shell.border! as Border;

      expect(border.bottom.width, 1.217, reason: 'Figma INPUT_BASE 的下边框宽度');
      expect(border.top.width, 0, reason: '其余三边不得有边框');
      expect(border.left.width, 0);
      expect(border.right.width, 0);
      expect(shell.color, isNull, reason: 'underline 是透明底');
      expect(shell.borderRadius, isNull, reason: 'underline 无圆角');
      expect(
        borderedShell(tester),
        isNull,
        reason: 'underline 不得出现四边边框 —— 出现了说明形态被改成 boxed',
      );
    });

    testWidgets('boxed：四边细边框 1.5 + 半透明底 + borderMd 圆角', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.boxed,
            hint: '粘贴招聘描述（JD）内容…',
          ),
        ),
      );

      final BoxDecoration shell = borderedShell(tester)!;

      expect(shell.border!.top.width, 1.5, reason: 'Figma 工作台内联表单的边框');
      expect(shell.color, AppColors.inputSurfaceBrand);
      expect(
        shell.border!.top.color,
        AppColors.inputBorderBrand,
        reason: '默认 tone 是品牌蓝',
      );
      expect(shell.borderRadius, AppRadius.borderMd);

      expect(
        underlineShell(tester),
        isNull,
        reason: 'boxed 不得退化成仅下边框',
      );
    });

    testWidgets('boxed + purple：换用紫色边与紫底，且与蓝**不是同一个值**', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.boxed,
            tone: CareerlyInputTone.purple,
            hint: 'https://www.zhipin.com/job/...',
          ),
        ),
      );

      final BoxDecoration shell = borderedShell(tester)!;

      expect(shell.border!.top.color, AppColors.inputBorderPurple);
      expect(shell.color, AppColors.inputSurfacePurple);

      expect(
        AppColors.inputBorderPurple,
        isNot(AppColors.inputBorderBrand),
        reason: 'Figma 的蓝紫两套是不同色值，不得被合并',
      );
      expect(
        AppColors.inputSurfacePurple,
        isNot(AppColors.inputSurfaceBrand),
      );
    });

    testWidgets('filled：灰底、**无边框**、borderXs 圆角', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.filled,
            hint: 'https://...',
          ),
        ),
      );

      final BoxDecoration shell = filledShell(tester)!;

      expect(shell.color, AppColors.inputSurfaceFilled);
      expect(shell.borderRadius, AppRadius.borderXs);
      expect(
        shell.border,
        isNull,
        reason: 'Figma 的 a-jd-step 输入区是无边框的 —— 加了边框即为回归',
      );
      expect(borderedShell(tester), isNull);
      expect(underlineShell(tester), isNull);
    });

    testWidgets('plain：完全无底色无边框', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const CareerlyInput(variant: CareerlyInputVariant.plain)),
      );

      expect(
        filledShell(tester),
        isNull,
        reason: 'Figma 的 AI 对话输入没有底色',
      );
      expect(borderedShell(tester), isNull);
      expect(underlineShell(tester), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // 文字样式
  // ---------------------------------------------------------------------------

  group('CareerlyInput 文字', () {
    testWidgets('underline 输入值 16px，紧凑变体 13px（Figma 两套原值）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const CareerlyInput(variant: CareerlyInputVariant.underline)),
      );
      expect(fieldStyle(tester).fontSize, 16, reason: 'Figma INPUT_BASE');

      await tester.pumpWidget(
        host(const CareerlyInput(variant: CareerlyInputVariant.boxed)),
      );
      expect(fieldStyle(tester).fontSize, 13, reason: 'Figma text-[13px]');
    });

    testWidgets('hint 用 textTertiary，且可被 label 单独区分', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.underline,
            hint: '你的名字',
          ),
        ),
      );

      expect(hintStyle(tester).color, AppColors.textTertiary);
      expect(find.text('你的名字'), findsOneWidget);
    });

    testWidgets('label 渲染为 inputLabel，且与 hint 是两条独立文字', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.underline,
            label: '姓名',
            hint: '你的名字',
          ),
        ),
      );

      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('你的名字'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 四态
  // ---------------------------------------------------------------------------

  group('CareerlyInput 状态', () {
    testWidgets('Error：errorText 抢占 helperText 的位置', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.filled,
            helperText: '支持 Boss 直聘、拉勾等链接',
            errorText: '链接格式不正确',
          ),
        ),
      );

      expect(find.text('链接格式不正确'), findsOneWidget);
      expect(
        find.text('支持 Boss 直聘、拉勾等链接'),
        findsNothing,
        reason: '错误态下辅助说明必须让位，否则两行文字相互矛盾',
      );

      final Text errorText = tester.widget<Text>(find.text('链接格式不正确'));
      expect(errorText.style!.color, AppColors.danger);
    });

    testWidgets('非 Error 时 helperText 正常渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.boxed,
            helperText: '支持 Boss 直聘、拉勾等链接',
          ),
        ),
      );

      expect(find.text('支持 Boss 直聘、拉勾等链接'), findsOneWidget);
      final Text helper = tester.widget<Text>(find.text('支持 Boss 直聘、拉勾等链接'));
      expect(helper.style!.color, AppColors.inputHelper);
    });

    testWidgets('Disabled：文字色、填充色、TextField.enabled 三者都变', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.boxed,
            enabled: false,
          ),
        ),
      );

      expect(field(tester).enabled, isFalse);
      expect(
        fieldStyle(tester).color,
        AppColors.textDisabled,
        reason: 'Disabled 必须真的换文字色，而不是只把 enabled 传下去',
      );
      expect(
        filledShell(tester)!.color,
        AppColors.inputSurfaceDisabled,
        reason: 'Disabled 必须真的换填充色',
      );
    });

    testWidgets('Disabled 的 hint 也换色', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.underline,
            hint: '你的名字',
            enabled: false,
          ),
        ),
      );

      expect(hintStyle(tester).color, AppColors.textDisabled);
    });
  });

  // ---------------------------------------------------------------------------
  // 字数计数器
  // ---------------------------------------------------------------------------

  group('CareerlyInput 字数计数器', () {
    testWidgets('maxLength 非空时在**标题行**显示 已输入 / 上限', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          CareerlyInput(
            variant: CareerlyInputVariant.filled,
            label: '岗位描述',
            controller: controller,
            maxLength: 5000,
            maxLines: 5,
          ),
        ),
      );

      expect(find.text('0 / 5000'), findsOneWidget);
      expect(find.text('岗位描述'), findsOneWidget);

      // 计数器的位置：与标题**同一行**。
      // Figma App.tsx L1711-1713 —— 不是输入框右下角。
      final double labelY = tester.getCenter(find.text('岗位描述')).dy;
      final double counterY = tester.getCenter(find.text('0 / 5000')).dy;
      expect(
        labelY,
        counterY,
        reason: '计数器必须在标题行，而不是输入框右下角（Material 默认位置）',
      );
    });

    testWidgets('输入后计数随之更新；maxLength 非空时也真的限长', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.filled,
            maxLength: 5,
            maxLines: 3,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();

      expect(find.text('3 / 5'), findsOneWidget);

      // 长度限制由 LengthLimitingTextInputFormatter 实现，
      // 而不是 TextField.maxLength（后者会带来 Material 自绘计数器）。
      expect(
        field(tester).maxLength,
        isNull,
        reason: '不得透传 maxLength —— 会与标题行计数器位置冲突',
      );

      await tester.enterText(find.byType(TextField), 'abcdefghij');
      await tester.pump();

      expect(find.text('5 / 5'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'abcde',
        reason: '超出上限的字符必须被真的拦住',
      );
    });

    testWidgets('maxLength 为空时不渲染计数器', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.underline,
            label: '姓名',
          ),
        ),
      );

      expect(find.textContaining(' / '), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // 不适用态：显式声明，而不是假装齐全
  // ---------------------------------------------------------------------------

  group('CareerlyInput 不适用的态', () {
    testWidgets('Loading / Retry 不内建 —— 组件不得凭空造出无依据的形态', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const CareerlyInput(
            variant: CareerlyInputVariant.boxed,
            hint: '你的名字',
          ),
        ),
      );

      // 正常态下不应出现任何进度指示器。
      // 若将来有人为「凑齐四态」往输入框里塞 loading，这条会失败。
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
        reason: '输入框自身没有「加载中」语义（CLAUDE.md §5.5 的四态不应硬塞）',
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
