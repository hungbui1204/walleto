import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPanel(WidgetTester tester, {required Widget panel}) async {
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
                return Scaffold(body: Center(child: panel));
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the message without a CTA when action is missing', (tester) async {
    await pumpPanel(
      tester,
      panel: const CommonEmptyPanel(icon: Icons.inbox_outlined, message: 'Nothing here'),
    );

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byType(CommonButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('CTA uses CommonButton and tap calls onAction', (tester) async {
    var tapped = false;

    await pumpPanel(
      tester,
      panel: CommonEmptyPanel(
        icon: Icons.inbox_outlined,
        message: 'Nothing here',
        actionLabel: 'Add item',
        onAction: () => tapped = true,
      ),
    );

    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(CommonButton), findsOneWidget);

    await tester.tap(find.text('Add item'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
