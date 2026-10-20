import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockCreateTransactionUseCase extends Mock implements CreateTransactionUseCase {}

class _MockGetExchangeRateUseCase extends Mock implements GetExchangeRateUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  const eur = Currency(code: 'EUR');
  const jpy = Currency(code: 'JPY');

  late _MockCreateTransactionUseCase createTransactionUseCase;
  late _MockGetExchangeRateUseCase getExchangeRateUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  CreateTransactionBloc buildBloc() {
    return CreateTransactionBloc(createTransactionUseCase, getExchangeRateUseCase)
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..appBloc = appBloc
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  setUpAll(() {
    registerFallbackValue(const AppRouteInfo.main());
    registerFallbackValue(const CreateTransactionInput(transaction: Transaction()));
    registerFallbackValue(
      const GetExchangeRateInput(fromCurrencyCode: 'USD', toCurrencyCode: 'USD'),
    );
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
  });

  setUp(() {
    createTransactionUseCase = _MockCreateTransactionUseCase();
    getExchangeRateUseCase = _MockGetExchangeRateUseCase();
    navigator = _MockAppNavigator();
    appBloc = _MockAppBloc();
    commonBloc = _MockCommonBloc();
    exceptionHandler = _MockExceptionHandler();

    when(() => appBloc.add(any())).thenReturn(null);
    when(() => commonBloc.add(any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments.first;
      if (event is ExceptionEmitted) {
        event.appExceptionWrapper.exceptionCompleter?.complete();
      }
    });
    when(() => navigator.getCurrentRouteNames()).thenReturn(const <String?>[]);
    when(() => navigator.pop()).thenAnswer((_) async => true);
    when(
      () => createTransactionUseCase.execute(any()),
    ).thenAnswer((_) async => const CreateTransactionOutput());
  });

  blocTest<CreateTransactionBloc, CreateTransactionState>(
    'does not crash when initialized with no wallets',
    setUp: () {
      when(() => appBloc.state).thenReturn(const AppState());
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const CreateTransactionViewInitiated()),
    expect: () => const <CreateTransactionState>[],
  );

  blocTest<CreateTransactionBloc, CreateTransactionState>(
    'selects the first wallet when wallets exist',
    setUp: () {
      when(() => appBloc.state).thenReturn(
        const AppState(
          wallets: [Wallet(id: 1, name: 'Cash', currencyCode: 'USD')],
          currencies: [Currency(code: 'USD')],
        ),
      );
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const CreateTransactionViewInitiated()),
    verify: (bloc) {
      expect(bloc.state.selectedWallet?.id, 1);
      expect(bloc.state.selectedCurrency?.code, 'USD');
    },
  );

  blocTest<CreateTransactionBloc, CreateTransactionState>(
    'submits only once when confirm is tapped twice while the request is pending',
    build: buildBloc,
    seed: () => CreateTransactionState(
      amountInput: '10',
      selectedCategory: const Category(id: 1),
      selectedDate: DateTime(2026),
      selectedWallet: const Wallet(id: 1, currencyCode: 'USD'),
      selectedCurrency: const Currency(code: 'USD'),
      confirmButtonEnable: true,
    ),
    act: (bloc) async {
      final completion = Completer<CreateTransactionOutput>();
      final popCalled = Completer<void>();
      when(() => createTransactionUseCase.execute(any())).thenAnswer((_) => completion.future);
      when(() => navigator.pop()).thenAnswer((_) {
        if (!popCalled.isCompleted) popCalled.complete();
        return Future<bool>.value(true);
      });

      final disabled = bloc.stream.firstWhere((state) => !state.confirmButtonEnable);
      bloc.add(const CreateTransactionConfirmButtonPressed());
      bloc.add(const CreateTransactionConfirmButtonPressed());
      await disabled;
      completion.complete(const CreateTransactionOutput());
      await popCalled.future;
    },
    verify: (_) {
      verify(() => createTransactionUseCase.execute(any())).called(1);
    },
  );

  blocTest<CreateTransactionBloc, CreateTransactionState>(
    'keeps save disabled until the selected currency rate is ready',
    build: buildBloc,
    seed: () => CreateTransactionState(
      amountInput: '10',
      selectedCategory: const Category(id: 1),
      selectedDate: DateTime(2026),
      selectedWallet: const Wallet(id: 1, currencyCode: 'USD'),
      selectedCurrency: const Currency(code: 'USD'),
      confirmButtonEnable: true,
    ),
    act: (bloc) async {
      final rateCompletion = Completer<GetExchangeRateOutput>();
      when(() => getExchangeRateUseCase.execute(any())).thenAnswer((_) => rateCompletion.future);

      final loading = bloc.stream.firstWhere(
        (state) => state.selectedCurrency?.code == 'EUR' && !state.confirmButtonEnable,
      );
      bloc.add(const CreateTransactionCurrencySelected(currency: eur));
      await loading;
      expect(bloc.state.confirmButtonEnable, isFalse);

      bloc.add(const CreateTransactionConfirmButtonPressed());
      await Future<void>.delayed(Duration.zero);
      verifyNever(() => createTransactionUseCase.execute(any()));

      final ready = bloc.stream.firstWhere((state) => state.exchangeRate != null);
      rateCompletion.complete(const GetExchangeRateOutput(exchangeRate: ExchangeRate(rate: 2)));
      await ready;
    },
    verify: (bloc) {
      expect(bloc.state.confirmButtonEnable, isTrue);
      expect(bloc.state.convertedAmount, 20);
      verifyNever(() => createTransactionUseCase.execute(any()));
    },
  );

  blocTest<CreateTransactionBloc, CreateTransactionState>(
    'ignores an exchange rate response for an older currency selection',
    build: buildBloc,
    seed: () => CreateTransactionState(
      amountInput: '10',
      selectedCategory: const Category(id: 1),
      selectedDate: DateTime(2026),
      selectedWallet: const Wallet(id: 1, currencyCode: 'USD'),
      selectedCurrency: const Currency(code: 'USD'),
      confirmButtonEnable: true,
    ),
    act: (bloc) async {
      final eurRate = Completer<GetExchangeRateOutput>();
      final jpyRate = Completer<GetExchangeRateOutput>();
      when(() => getExchangeRateUseCase.execute(any())).thenAnswer((invocation) {
        final input = invocation.positionalArguments.single as GetExchangeRateInput;
        return input.fromCurrencyCode == 'EUR' ? eurRate.future : jpyRate.future;
      });

      final eurLoading = bloc.stream.firstWhere(
        (state) => state.selectedCurrency?.code == 'EUR' && !state.confirmButtonEnable,
      );
      bloc.add(const CreateTransactionCurrencySelected(currency: eur));
      await eurLoading;

      final jpyLoading = bloc.stream.firstWhere(
        (state) => state.selectedCurrency?.code == 'JPY' && !state.confirmButtonEnable,
      );
      bloc.add(const CreateTransactionCurrencySelected(currency: jpy));
      await jpyLoading;

      final jpyReady = bloc.stream.firstWhere(
        (state) => state.selectedCurrency?.code == 'JPY' && state.exchangeRate == 3,
      );
      jpyRate.complete(const GetExchangeRateOutput(exchangeRate: ExchangeRate(rate: 3)));
      await jpyReady;

      eurRate.complete(const GetExchangeRateOutput(exchangeRate: ExchangeRate(rate: 2)));
      await Future<void>.delayed(Duration.zero);
    },
    verify: (bloc) {
      expect(bloc.state.selectedCurrency?.code, 'JPY');
      expect(bloc.state.exchangeRate, 3);
      expect(bloc.state.convertedAmount, 30);
    },
  );
}
