import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockAppNavigator extends Mock implements AppNavigator {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAppNavigator navigator;

  setUpAll(() async {
    await S.load(const Locale('en', 'US'));
  });

  setUp(() {
    navigator = _MockAppNavigator();
    when(() => navigator.pop()).thenAnswer((_) async => true);
  });

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
                return Scaffold(
                  body: RepositoryProvider<AppNavigator>.value(value: navigator, child: sheet),
                );
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('tap selects a month and pops', (tester) async {
    DateTime? selected;

    await pumpSheet(
      tester,
      sheet: SelectMonthBottomSheet(
        firstYear: 2020,
        lastYear: 2030,
        initialDate: DateTime(2026, 3),
        onMonthSelected: (date) => selected = date,
      ),
    );

    await tester.tap(find.text('January'));
    await tester.pump();

    expect(selected, DateTime(2026));
    verify(() => navigator.pop()).called(1);
  });
}
