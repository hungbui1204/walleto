import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpButton(WidgetTester tester, {required Widget button}) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(
          DeviceConstants.designDeviceWidth,
          DeviceConstants.designDeviceHeight,
        ),
        builder: (context, child) {
          return MaterialApp(
            home: Builder(
              builder: (context) {
                AppDimen.of(context);
                return Scaffold(body: Center(child: button));
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('renders title, rounded chevron, and Pressable', (tester) async {
    await pumpButton(tester, button: const CommonForwardButton(title: 'Currency'));

    expect(find.text('Currency'), findsOneWidget);
    expect(find.byType(Pressable), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
  });

  testWidgets('tap calls onTap', (tester) async {
    var tapped = false;

    await pumpButton(
      tester,
      button: CommonForwardButton(title: 'Currency', onTap: () => tapped = true),
    );

    await tester.tap(find.text('Currency'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('showBorder uses secondaryCta decoration', (tester) async {
    await pumpButton(tester, button: const CommonForwardButton(title: 'Currency'));

    final decorated = tester.widget<DecoratedBox>(
      find.descendant(of: find.byType(CommonForwardButton), matching: find.byType(DecoratedBox)),
    );
    expect(decorated.decoration, isA<BoxDecoration>());
    final box = decorated.decoration as BoxDecoration;
    expect(box.border, isNotNull);
  });
}
