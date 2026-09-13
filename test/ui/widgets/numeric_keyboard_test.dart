import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en', 'US'));
  });

  Future<void> pumpKeyboard(
    WidgetTester tester, {
    required void Function(String) onNumberKeyTap,
    required void Function(String) onOperatorKeyTap,
    required VoidCallback onBackspace,
    required VoidCallback onClear,
    required VoidCallback onDone,
    required VoidCallback onEqual,
  }) async {
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
                  body: NumericKeyboard(
                    onNumberKeyTap: onNumberKeyTap,
                    onOperatorKeyTap: onOperatorKeyTap,
                    onBackspace: onBackspace,
                    onClear: onClear,
                    onDone: onDone,
                    onEqual: onEqual,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('keys use Pressable instead of ElevatedButton', (tester) async {
    await pumpKeyboard(
      tester,
      onNumberKeyTap: (_) {},
      onOperatorKeyTap: (_) {},
      onBackspace: () {},
      onClear: () {},
      onDone: () {},
      onEqual: () {},
    );

    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(Pressable), findsWidgets);
  });

  testWidgets('number and done keys call the matching callbacks', (tester) async {
    final numbers = <String>[];
    var doneCount = 0;

    await pumpKeyboard(
      tester,
      onNumberKeyTap: numbers.add,
      onOperatorKeyTap: (_) {},
      onBackspace: () {},
      onClear: () {},
      onDone: () => doneCount++,
      onEqual: () {},
    );

    await tester.tap(find.text('7'));
    await tester.tap(find.text(S.current.done));
    await tester.pump();

    expect(numbers, ['7']);
    expect(doneCount, 1);
  });
}
