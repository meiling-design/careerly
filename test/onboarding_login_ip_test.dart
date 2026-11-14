import 'package:careerly/features/onboarding/presentation/widgets/onboarding_login_ip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads the login SVG and responds with its message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: OnboardingLoginIp(width: 224))),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byType(SvgPicture), findsOneWidget);

    await tester.tap(find.byType(OnboardingLoginIp));
    await tester.pump();

    expect(find.text('欢迎回来，我陪你继续成长。'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pump();
    expect(find.text('欢迎回来，我陪你继续成长。'), findsNothing);
  });
}
