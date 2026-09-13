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

  testWidgets('Save commits the note and pops', (tester) async {
    var saved = '';

    await pumpSheet(
      tester,
      sheet: NoteInputBottomSheet(currentNote: 'Lunch', onNoteChanged: (note) => saved = note),
    );

    expect(find.text(S.current.save), findsOneWidget);
    expect(find.text(S.current.cancel), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Coffee');
    await tester.tap(find.text(S.current.save));
    await tester.pump();

    expect(saved, 'Coffee');
    verify(() => navigator.pop()).called(1);
  });

  testWidgets('Cancel pops without saving', (tester) async {
    var saved = 'unchanged';

    await pumpSheet(
      tester,
      sheet: NoteInputBottomSheet(currentNote: 'Lunch', onNoteChanged: (note) => saved = note),
    );

    await tester.tap(find.text(S.current.cancel));
    await tester.pump();

    expect(saved, 'unchanged');
    verify(() => navigator.pop()).called(1);
  });
}
