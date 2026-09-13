import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockHomeBloc homeBloc;

  setUpAll(() async {
    await S.load(const Locale('en', 'US'));
  });

  setUp(() {
    homeBloc = _MockHomeBloc();
    whenListen(
      homeBloc,
      const Stream<HomeState>.empty(),
      initialState: HomeState(selectedDateTime: DateTime(2026, 3)),
    );
  });

  Future<void> pumpWidget(WidgetTester tester) async {
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
                  body: BlocProvider<HomeBloc>.value(
                    value: homeBloc,
                    child: const StatisticWidget(),
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

  testWidgets('spent stats date chip is display-only and not Pressable', (tester) async {
    await pumpWidget(tester);

    await tester.tap(find.text(S.current.spentStats));
    await tester.pump();

    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byIcon(Icons.calendar_today_outlined),
        matching: find.byType(Pressable),
      ),
      findsNothing,
    );
  });
}
