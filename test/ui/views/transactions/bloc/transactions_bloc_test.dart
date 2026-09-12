import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockGetTransactionsUseCase extends Mock implements GetTransactionsUseCase {}

class _MockConvertAmountsToCurrencyUseCase extends Mock
    implements ConvertAmountsToCurrencyUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  const cashWallet = Wallet(id: 1, name: 'Cash', amount: 100, currencyCode: 'USD');
  const totalWallet = Wallet(id: AppConstants.totalWalletId, name: 'Total', amount: 100);
  final selectedMonth = DateTime(2026);
  final otherMonth = DateTime(2026, 2);

  late _MockGetTransactionsUseCase getTransactionsUseCase;
  late _MockConvertAmountsToCurrencyUseCase convertAmountsToCurrencyUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  TransactionsBloc buildBloc() {
    return TransactionsBloc(getTransactionsUseCase, convertAmountsToCurrencyUseCase)
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..appBloc = appBloc
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  setUpAll(() async {
    await S.load(const Locale('en', 'US'));
    registerFallbackValue(const GetTransactionsInput());
    registerFallbackValue(
      const ConvertAmountsToCurrencyInput(amounts: [], targetCurrencyCode: 'USD'),
    );
    registerFallbackValue(const AppRouteInfo.main());
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(DateTimeRange(start: DateTime(2026), end: DateTime(2026, 1, 2)));
  });

  setUp(() {
    getTransactionsUseCase = _MockGetTransactionsUseCase();
    convertAmountsToCurrencyUseCase = _MockConvertAmountsToCurrencyUseCase();
    navigator = _MockAppNavigator();
    appBloc = _MockAppBloc();
    commonBloc = _MockCommonBloc();
    exceptionHandler = _MockExceptionHandler();

    when(() => appBloc.state).thenReturn(const AppState(wallets: [cashWallet]));
    when(() => appBloc.stream).thenAnswer((_) => const Stream<AppState>.empty());
    when(() => appBloc.add(any())).thenReturn(null);
    when(() => commonBloc.add(any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments.first;
      if (event is ExceptionEmitted) {
        event.appExceptionWrapper.exceptionCompleter?.complete();
      }
    });
    when(
      () => convertAmountsToCurrencyUseCase.execute(any()),
    ).thenAnswer((_) async => const ConvertAmountsToCurrencyOutput(total: 100));
    when(() => navigator.getCurrentRouteNames()).thenReturn(const <String?>[]);
    when(
      () => getTransactionsUseCase.execute(any()),
    ).thenAnswer((_) async => const GetTransactionsOutput());
    when(
      () => navigator.showDateRangePicker(
        firstDate: any(named: 'firstDate'),
        lastDate: any(named: 'lastDate'),
        initialDateRange: any(named: 'initialDateRange'),
        useRootNavigator: true,
      ),
    ).thenAnswer((_) async => DateTimeRange(start: DateTime(2026, 2), end: DateTime(2026, 2, 10)));
  });

  blocTest<TransactionsBloc, TransactionsState>(
    'shows loading when the view is initialized',
    build: buildBloc,
    act: (bloc) => bloc.add(const TransactionsViewInitialized()),
    verify: (_) {
      verify(() => getTransactionsUseCase.execute(any())).called(1);
      verify(() => commonBloc.add(const LoadingVisibilityEmitted(isLoading: true))).called(1);
      verify(() => commonBloc.add(const LoadingVisibilityEmitted(isLoading: false))).called(1);
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'does not show loading when transactions are refreshed',
    seed:
        () => TransactionsState(
          selectedDate: selectedMonth,
          selectedWallet: totalWallet,
          wallets: const [totalWallet, cashWallet],
        ),
    build: buildBloc,
    act: (bloc) => bloc.add(const TransactionsRefreshed()),
    verify: (_) {
      verify(
        () => getTransactionsUseCase.execute(
          const GetTransactionsInput(targetMonth: 1, targetYear: 2026),
        ),
      ).called(1);
      verifyNever(() => commonBloc.add(const LoadingVisibilityEmitted(isLoading: true)));
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'does not show loading when a different month is selected',
    seed:
        () => TransactionsState(
          selectedDate: selectedMonth,
          selectedWallet: totalWallet,
          wallets: const [totalWallet, cashWallet],
        ),
    build: buildBloc,
    act: (bloc) => bloc.add(TransactionsMonthSelected(selectedDate: otherMonth)),
    verify: (_) {
      verify(
        () => getTransactionsUseCase.execute(
          const GetTransactionsInput(targetMonth: 2, targetYear: 2026),
        ),
      ).called(1);
      verifyNever(() => commonBloc.add(const LoadingVisibilityEmitted(isLoading: true)));
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'does not show loading when a wallet is selected',
    seed:
        () => TransactionsState(
          selectedDate: selectedMonth,
          selectedWallet: totalWallet,
          wallets: const [totalWallet, cashWallet],
        ),
    build: buildBloc,
    act: (bloc) => bloc.add(const TransactionsWalletSelected(selectedWallet: cashWallet)),
    verify: (_) {
      verify(
        () => getTransactionsUseCase.execute(
          const GetTransactionsInput(walletId: 1, targetMonth: 1, targetYear: 2026),
        ),
      ).called(1);
      verifyNever(() => commonBloc.add(const LoadingVisibilityEmitted(isLoading: true)));
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'does not show loading when a date range is picked',
    seed:
        () => const TransactionsState(
          selectedWallet: totalWallet,
          wallets: [totalWallet, cashWallet],
        ),
    build: buildBloc,
    act: (bloc) => bloc.add(const TransactionsDateRangePicked()),
    verify: (_) {
      verify(
        () => getTransactionsUseCase.execute(
          GetTransactionsInput(fromDate: DateTime(2026, 2), toDate: DateTime(2026, 2, 11)),
        ),
      ).called(1);
      verifyNever(() => commonBloc.add(const LoadingVisibilityEmitted(isLoading: true)));
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'fetches a new range when start and end change even if duration matches',
    seed:
        () => TransactionsState(
          selectedWallet: totalWallet,
          wallets: const [totalWallet, cashWallet],
          selectedDateRange: DateTimeRange(start: DateTime(2026), end: DateTime(2026, 1, 10)),
        ),
    build: buildBloc,
    act: (bloc) => bloc.add(const TransactionsDateRangePicked()),
    verify: (_) {
      verify(
        () => getTransactionsUseCase.execute(
          GetTransactionsInput(fromDate: DateTime(2026, 2), toDate: DateTime(2026, 2, 11)),
        ),
      ).called(1);
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'does not crash when initialized with no wallets',
    setUp: () {
      when(() => appBloc.state).thenReturn(const AppState());
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const TransactionsViewInitialized()),
    verify: (_) {
      verifyNever(() => getTransactionsUseCase.execute(any()));
    },
  );
}
