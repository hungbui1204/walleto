import 'package:bloc_test/bloc_test.dart';
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

class _MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const usd = Currency(code: 'USD', name: 'US Dollar');
  const vnd = Currency(code: 'VND', name: 'Vietnamese Dong');

  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;

  setUpAll(() async {
    await S.load(const Locale('en', 'US'));
  });

  setUp(() {
    navigator = _MockAppNavigator();
    appBloc = _MockAppBloc();
    when(() => navigator.pop()).thenAnswer((_) async => true);
    when(() => appBloc.state).thenReturn(const AppState(currencies: [usd, vnd]));
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
                  body: RepositoryProvider<AppNavigator>.value(
                    value: navigator,
                    child: BlocProvider<AppBloc>.value(value: appBloc, child: sheet),
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

  testWidgets('tap selects a currency and pops', (tester) async {
    Currency? selected;

    await pumpSheet(
      tester,
      sheet: ChooseCurrencyBottomSheet(
        currentCurrency: usd,
        onCurrencySelected: (currency) => selected = currency,
      ),
    );

    await tester.tap(find.text('Vietnamese Dong'));
    await tester.pump();

    expect(selected, vnd);
    verify(() => navigator.pop()).called(1);
  });
}
