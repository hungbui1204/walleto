import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class _MockSignOutUseCase extends Mock implements SignOutUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const food = Category(id: 1, name: 'Food', isParent: true);
  const salary = Category(id: 2, name: 'Salary', isParent: true, type: CategoryType.income);

  late _MockGetCategoriesUseCase getCategoriesUseCase;
  late _MockSignOutUseCase signOutUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;

  setUpAll(() async {
    await S.load(const Locale('en', 'US'));
    registerFallbackValue(const GetCategoriesInput());
    registerFallbackValue(const AppPopupInfo.createCategory(null));
  });

  setUp(() async {
    await GetIt.instance.reset();
    getCategoriesUseCase = _MockGetCategoriesUseCase();
    signOutUseCase = _MockSignOutUseCase();
    navigator = _MockAppNavigator();
    appBloc = _MockAppBloc();

    when(() => appBloc.state).thenReturn(const AppState());
    when(() => navigator.pop(useRootNavigator: true)).thenAnswer((_) async => true);
    when(
      () => getCategoriesUseCase.execute(any()),
    ).thenAnswer((_) async => const GetCategoriesOutput(categories: [food, salary]));

    GetIt.instance
      ..registerSingleton<AppNavigator>(navigator)
      ..registerSingleton<AppBloc>(appBloc)
      ..registerFactory<CommonBloc>(() => CommonBloc(signOutUseCase))
      ..registerFactory<SelectCategoryBloc>(() => SelectCategoryBloc(getCategoriesUseCase));
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Future<void> pumpSheet(WidgetTester tester, {required SelectCategoryBottomSheet sheet}) async {
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
    await tester.pump();
  }

  testWidgets('renders as a picker sheet with segmented control and pops on select', (
    tester,
  ) async {
    Category? selected;

    await pumpSheet(
      tester,
      sheet: SelectCategoryBottomSheet(onCategorySelected: (category) => selected = category),
    );

    expect(find.byType(CommonPickerSheet), findsOneWidget);
    expect(find.byType(CommonSegmentedControl<CategoryType>), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);

    await tester.tap(find.text(S.current.income));
    await tester.pump();

    expect(find.text('Salary'), findsOneWidget);

    await tester.tap(find.text('Salary'));
    await tester.pump();

    expect(selected, salary);
    verify(() => navigator.pop(useRootNavigator: true)).called(1);
  });
}
