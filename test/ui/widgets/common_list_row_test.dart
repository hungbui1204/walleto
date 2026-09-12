import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpRow(WidgetTester tester, {required Widget row}) async {
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
                return Scaffold(body: Center(child: row));
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the title', (tester) async {
    await pumpRow(tester, row: const CommonListRow(title: Text('Cash')));

    expect(find.text('Cash'), findsOneWidget);
    expect(find.byType(Pressable), findsOneWidget);
  });

  testWidgets('tap calls onTap', (tester) async {
    var tapped = false;

    await pumpRow(
      tester,
      row: CommonListRow(title: const Text('Cash'), onTap: () => tapped = true),
    );

    await tester.tap(find.text('Cash'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('shows chevron when showChevron is true', (tester) async {
    await pumpRow(tester, row: const CommonListRow(title: Text('Cash'), showChevron: true));

    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
  });

  testWidgets('hides chevron when showChevron is false', (tester) async {
    await pumpRow(tester, row: const CommonListRow(title: Text('Cash')));

    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNothing);
  });
}
