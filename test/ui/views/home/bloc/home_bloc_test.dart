import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockGetMonthSummaryStatsUseCase extends Mock implements GetMonthSummaryStatsUseCase {}

class _MockGetWalletStatsUseCase extends Mock implements GetWalletStatsUseCase {}

class _MockGetTopWalletStatsUseCase extends Mock implements GetTopWalletStatsUseCase {}

class _MockGetRecentTransactionsUseCase extends Mock implements GetRecentTransactionsUseCase {}

class _MockGetUserDefaultCurrencyUseCase extends Mock implements GetUserDefaultCurrencyUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  const usd = Currency(code: 'USD');
  const previousMonthUsd = MonthSummaryStat(
    totalIncome: 100,
    totalExpense: 40,
    targetMonth: TargetMonth.previous,
  );
  const currentMonthUsd = MonthSummaryStat(totalIncome: 250, totalExpense: 80);
  const previousMonthVnd = MonthSummaryStat(
    totalIncome: 2_000_000,
    totalExpense: 800_000,
    targetMonth: TargetMonth.previous,
  );
  const currentMonthVnd = MonthSummaryStat(totalIncome: 5_000_000, totalExpense: 1_500_000);

  late _MockGetMonthSummaryStatsUseCase getMonthSummaryStatsUseCase;
  late _MockGetWalletStatsUseCase getWalletStatsUseCase;
  late _MockGetTopWalletStatsUseCase getTopWalletStatsUseCase;
  late _MockGetRecentTransactionsUseCase getRecentTransactionsUseCase;
  late _MockGetUserDefaultCurrencyUseCase getUserDefaultCurrencyUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  HomeBloc buildBloc() {
    return HomeBloc(
        getMonthSummaryStatsUseCase,
        getWalletStatsUseCase,
        getRecentTransactionsUseCase,
        getTopWalletStatsUseCase,
        getUserDefaultCurrencyUseCase,
      )
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..appBloc = appBloc
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  setUpAll(() {
    registerFallbackValue(const GetMonthSummaryStatsInput());
    registerFallbackValue(
      const GetTopWalletStatsInput(
        targetMonth: 1,
        targetYear: 2026,
        categoryType: CategoryType.expense,
      ),
    );
    registerFallbackValue(const GetRecentTransactionsInput());
    registerFallbackValue(const GetUserDefaultCurrencyInput());
    registerFallbackValue(const AppRouteInfo.main());
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
    registerFallbackValue(const UserDefaultCurrencyUpdated(newCurrency: Currency()));
  });

  setUp(() {
    getMonthSummaryStatsUseCase = _MockGetMonthSummaryStatsUseCase();
    getWalletStatsUseCase = _MockGetWalletStatsUseCase();
    getTopWalletStatsUseCase = _MockGetTopWalletStatsUseCase();
    getRecentTransactionsUseCase = _MockGetRecentTransactionsUseCase();
    getUserDefaultCurrencyUseCase = _MockGetUserDefaultCurrencyUseCase();
    navigator = _MockAppNavigator();
    appBloc = _MockAppBloc();
    commonBloc = _MockCommonBloc();
    exceptionHandler = _MockExceptionHandler();

    when(() => appBloc.state).thenReturn(const AppState(userDefaultCurrency: usd));
    when(() => appBloc.add(any())).thenReturn(null);
    when(() => commonBloc.add(any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments.first;
      if (event is ExceptionEmitted) {
        event.appExceptionWrapper.exceptionCompleter?.complete();
      }
    });
    when(() => navigator.getCurrentRouteNames()).thenReturn(const <String?>[]);
  });

  blocTest<HomeBloc, HomeState>(
    'reloads month summary when a different currency is selected',
    setUp: () {
      when(
        () => getMonthSummaryStatsUseCase.execute(
          const GetMonthSummaryStatsInput(baseCurrency: 'VND'),
        ),
      ).thenAnswer(
        (_) async => const GetMonthSummaryStatsOutput(
          monthSummaryStats: [previousMonthVnd, currentMonthVnd],
        ),
      );
    },
    build: buildBloc,
    seed:
        () => const HomeState(
          defaultCurrencyCode: 'USD',
          monthSummaryStats: [currentMonthUsd, previousMonthUsd],
        ),
    act: (bloc) => bloc.add(const HomeCurrencySelected(currencyCode: 'VND')),
    expect:
        () => const [
          HomeState(
            defaultCurrencyCode: 'VND',
            monthSummaryStats: [currentMonthVnd, previousMonthVnd],
          ),
        ],
    verify: (_) {
      verify(
        () => getMonthSummaryStatsUseCase.execute(
          const GetMonthSummaryStatsInput(baseCurrency: 'VND'),
        ),
      ).called(1);
    },
  );

  blocTest<HomeBloc, HomeState>(
    'does not reload month summary when the same currency is selected',
    build: buildBloc,
    seed:
        () => const HomeState(
          defaultCurrencyCode: 'USD',
          monthSummaryStats: [currentMonthUsd, previousMonthUsd],
        ),
    act: (bloc) => bloc.add(const HomeCurrencySelected(currencyCode: 'USD')),
    expect: () => const <HomeState>[],
    verify: (_) {
      verifyNever(() => getMonthSummaryStatsUseCase.execute(any()));
    },
  );

  blocTest<HomeBloc, HomeState>(
    'stamps the initial currency without refetching month summary',
    build: buildBloc,
    seed: () => const HomeState(monthSummaryStats: [currentMonthUsd, previousMonthUsd]),
    act: (bloc) => bloc.add(const HomeCurrencySelected(currencyCode: 'USD')),
    expect:
        () => const [
          HomeState(
            defaultCurrencyCode: 'USD',
            monthSummaryStats: [currentMonthUsd, previousMonthUsd],
          ),
        ],
    verify: (_) {
      verifyNever(() => getMonthSummaryStatsUseCase.execute(any()));
    },
  );

  blocTest<HomeBloc, HomeState>(
    'loads month summary once when the view is initialized',
    setUp: () {
      when(
        () => getUserDefaultCurrencyUseCase.execute(any()),
      ).thenAnswer((_) async => const GetUserDefaultCurrencyOutput(currency: usd));
      when(() => getMonthSummaryStatsUseCase.execute(any())).thenAnswer(
        (_) async => const GetMonthSummaryStatsOutput(
          monthSummaryStats: [previousMonthUsd, currentMonthUsd],
        ),
      );
      when(
        () => getTopWalletStatsUseCase.execute(any()),
      ).thenAnswer((_) async => const GetTopWalletStatsOutput(walletStat: WalletStat()));
      when(
        () => getRecentTransactionsUseCase.execute(any()),
      ).thenAnswer((_) async => const GetRecentTransactionsOutput(transactions: []));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const HomeViewInitialized()),
    verify: (_) {
      verify(
        () => getMonthSummaryStatsUseCase.execute(
          const GetMonthSummaryStatsInput(baseCurrency: 'USD'),
        ),
      ).called(1);
    },
  );
}
