import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpControl(WidgetTester tester, {required Widget control}) async {
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
                return Scaffold(body: Center(child: control));
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('renders segment labels', (tester) async {
    await pumpControl(
      tester,
      control: CommonSegmentedControl<int>(
        segments: const [(value: 0, label: 'Month summary'), (value: 1, label: 'Spent stats')],
        selected: 0,
        onSelected: (_) {},
      ),
    );

    expect(find.text('Month summary'), findsOneWidget);
    expect(find.text('Spent stats'), findsOneWidget);
    expect(find.byType(Pressable), findsNWidgets(2));
  });

  testWidgets('tap calls onSelected with the segment value', (tester) async {
    var selected = 0;

    await pumpControl(
      tester,
      control: CommonSegmentedControl<int>(
        segments: const [(value: 0, label: 'Month summary'), (value: 1, label: 'Spent stats')],
        selected: selected,
        onSelected: (value) => selected = value,
      ),
    );

    await tester.tap(find.text('Spent stats'));
    await tester.pump();

    expect(selected, 1);
  });
}
