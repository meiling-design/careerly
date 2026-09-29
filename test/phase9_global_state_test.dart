import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/core/state/state.dart';
import 'package:careerly/design_system/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host<T>(AsyncState<T> state, {VoidCallback? onRetry}) {
    return MaterialApp(
      home: Scaffold(
        body: CareerlyAsyncStateView<T>(
          state: state,
          builder: (BuildContext context, T data) => Text('$data'),
          isEmpty: (T data) => data is List && data.isEmpty,
          onRetry: onRetry,
          emptyTitle: '暂无内容',
          emptyMessage: '完成操作后会显示在这里',
          loadingMessage: '正在加载',
        ),
      ),
    );
  }

  testWidgets('Loading 显示统一加载反馈', (WidgetTester tester) async {
    await tester.pumpWidget(
      host(const AsyncState<String>.loading(message: '正在加载')),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('正在加载'), findsOneWidget);
  });

  testWidgets('空列表显示 Empty 状态', (WidgetTester tester) async {
    await tester.pumpWidget(host(const AsyncState<List<String>>.success(<String>[])));

    expect(find.text('暂无内容'), findsOneWidget);
    expect(find.text('完成操作后会显示在这里'), findsOneWidget);
  });

  testWidgets('可重试错误显示原因与重试按钮', (WidgetTester tester) async {
    bool retried = false;
    await tester.pumpWidget(
      host(
        const AsyncState<String>.failure(
          NetworkError(message: '网络暂时不可用'),
        ),
        onRetry: () => retried = true,
      ),
    );

    expect(find.text('网络暂时不可用'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    await tester.tap(find.text('重试'));
    expect(retried, isTrue);
  });

  testWidgets('不可重试错误不显示重试按钮', (WidgetTester tester) async {
    await tester.pumpWidget(
      host(
        const AsyncState<String>.failure(
          QuotaError(remaining: 0),
        ),
        onRetry: () {},
      ),
    );

    expect(find.text('分析次数已用完'), findsOneWidget);
    expect(find.text('重试'), findsNothing);
  });
}
