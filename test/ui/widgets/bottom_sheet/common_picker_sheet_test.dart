import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSheet(WidgetTester tester, {required Widget sheet}) async {
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
                return Scaffold(body: sheet);
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('renders title and child', (tester) async {
    await pumpSheet(
      tester,
      sheet: const CommonPickerSheet(title: 'Choose wallet', child: Text('Cash')),
    );

    expect(find.text('Choose wallet'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.byType(CommonButton), findsNothing);
  });

  testWidgets('renders actions when provided', (tester) async {
    await pumpSheet(
      tester,
      sheet: CommonPickerSheet(
        title: 'Edit note',
        actions: CommonButton(compact: true, text: 'Save', onTap: () {}),
        child: const Text('Note field'),
      ),
    );

    expect(find.text('Edit note'), findsOneWidget);
    expect(find.text('Note field'), findsOneWidget);
    expect(find.byType(CommonButton), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('expandChild gives the child a bounded height', (tester) async {
    await pumpSheet(
      tester,
      sheet: const CommonPickerSheet(
        title: 'Select category',
        expandChild: true,
        child: Column(children: [Text('Header'), Expanded(child: Text('Body'))]),
      ),
    );

    expect(find.text('Select category'), findsOneWidget);
    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-expand child is the scroll body, not wrapped in ListView', (tester) async {
    await pumpSheet(
      tester,
      sheet: const CommonPickerSheet(title: 'Choose wallet', child: Text('Cash')),
    );

    expect(find.byType(ListView), findsNothing);
    expect(find.text('Cash'), findsOneWidget);
  });
}
