import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careerly/app/router/back_navigation.dart';

/// Careerly Android Back Navigation Rule —— 回归测试。
///
/// 覆盖规则的四条硬约束：
///
/// 1. **三个入口同一个 Back Action**：顶部返回按钮（[careerlyBack]）与
///    系统 Back（`handlePopRoute`）走同一条 `Navigator.maybePop` 路径。
/// 2. **Back = 栈的 pop**：二级页返回上一页，不跳固定页面。
/// 3. **未保存修改先确认**：有守卫时 Back 先弹确认，
///    「继续编辑」留下、「放弃修改」才真正离开。
/// 4. **无守卫的页完全透明**：Back 立即 pop，不弹任何确认。
///
/// ⚠️ 本测试**不依赖 `app_router.dart`**（它是纯 Navigator 层的行为），
/// 因此不受分析三级页批次（`gap_page` 等）是否完成的影响。
void main() {
  group('CareerlyBackScope + careerlyBack', () {
    testWidgets('无守卫：顶部按钮 Back 直接 pop 回上一页', (tester) async {
      await tester.pumpWidget(const _Harness(guarded: false));

      await tester.tap(find.text('进入第二页'));
      await tester.pumpAndSettle();
      expect(find.text('第二页'), findsOneWidget);

      // 顶部返回按钮 = careerlyBack（统一 Back Action）。
      await tester.tap(find.text('返回'));
      await tester.pumpAndSettle();
      expect(find.text('第二页'), findsNothing);
      expect(find.text('进入第二页'), findsOneWidget);
    });

    testWidgets('有守卫：顶部按钮 Back 被拦截，「继续编辑」后仍在原页', (tester) async {
      await tester.pumpWidget(const _Harness(guarded: true));

      await tester.tap(find.text('进入第二页'));
      await tester.pumpAndSettle();

      // 顶部按钮触发的 Back 同样走 PopScope（这是本规则的关键：
      // go_router 18 的 context.pop() 不会经过守卫）。
      await tester.tap(find.text('返回'));
      await tester.pumpAndSettle();

      expect(find.text('是否放弃修改？'), findsOneWidget);
      await tester.tap(find.text('继续编辑'));
      await tester.pumpAndSettle();

      expect(find.text('第二页'), findsOneWidget);
    });

    testWidgets('有守卫：系统 Back 被拦截，「放弃修改」后离开', (tester) async {
      await tester.pumpWidget(const _Harness(guarded: true));

      await tester.tap(find.text('进入第二页'));
      await tester.pumpAndSettle();

      // 系统 Back / 边缘右滑（预测性返回）在框架层即 popRoute。
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('是否放弃修改？'), findsOneWidget);
      expect(find.text('第二页'), findsOneWidget); // 确认前不能离开

      await tester.tap(find.text('放弃修改'));
      await tester.pumpAndSettle();

      expect(find.text('第二页'), findsNothing);
    });

    testWidgets('有守卫：点 scrim 收掉确认层 = 留下，不离开', (tester) async {
      await tester.pumpWidget(const _Harness(guarded: true));

      await tester.tap(find.text('进入第二页'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('是否放弃修改？'), findsOneWidget);

      // 点弹层外的 scrim（barrierDismissible）—— 结果 null 一律按「留下」。
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.text('是否放弃修改？'), findsNothing);
      expect(find.text('第二页'), findsOneWidget);
    });

    testWidgets('守卫关闭后（guard 变 null）Back 恢复直接 pop', (tester) async {
      await tester.pumpWidget(const _Harness(guarded: true));

      await tester.tap(find.text('进入第二页'));
      await tester.pumpAndSettle();

      // 模拟「内容已保存」：守卫撤掉。
      await tester.tap(find.text('标记已保存'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('返回'));
      await tester.pumpAndSettle();
      expect(find.text('是否放弃修改？'), findsNothing);
      expect(find.text('第二页'), findsNothing);
    });
  });
}

/// 测试夹具：第一页一个「进入第二页」按钮；
/// 第二页带「返回」按钮（顶部返回）与「标记已保存」开关。
class _Harness extends StatelessWidget {
  const _Harness({required this.guarded});

  final bool guarded;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _SecondPage(guarded: guarded),
            ),
          ),
          child: const Text('进入第二页'),
        ),
      ),
    );
  }
}

class _SecondPage extends StatefulWidget {
  const _SecondPage({required this.guarded});

  final bool guarded;

  @override
  State<_SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<_SecondPage> {
  late bool _dirty = widget.guarded;

  @override
  Widget build(BuildContext context) {
    return CareerlyBackScope(
      guard: _dirty ? const CareerlyBackGuard.unsavedChanges() : null,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            const Text('第二页'),
            TextButton(
              onPressed: () => careerlyBack(context),
              child: const Text('返回'),
            ),
            TextButton(
              onPressed: () => setState(() => _dirty = false),
              child: const Text('标记已保存'),
            ),
          ],
        ),
      ),
    );
  }
}
