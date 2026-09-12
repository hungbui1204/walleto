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
                return Scaffold(
                  body: Center(child: SizedBox(width: 80, height: 64, child: button)),
                );
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('uses opacity Pressable and has no InkWell', (tester) async {
    await pumpButton(
      tester,
      button: BottomBarIconButton(
        icon: const Icon(Icons.home_outlined),
        label: 'Home',
        selected: true,
        onTap: () {},
      ),
    );

    expect(find.byType(InkWell), findsNothing);
    final pressable = tester.widget<Pressable>(find.byType(Pressable));
    expect(pressable.feedback, PressableFeedback.opacity);
  });

  testWidgets('tap calls onTap', (tester) async {
    var tapped = false;

    await pumpButton(
      tester,
      button: BottomBarIconButton(
        icon: const Icon(Icons.home_outlined),
        label: 'Home',
        selected: false,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.text('Home'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
