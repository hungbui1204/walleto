import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockGetExchangeRateUseCase extends Mock implements GetExchangeRateUseCase {}

class _MockEditTransactionUseCase extends Mock implements EditTransactionUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  const eur = Currency(code: 'EUR');
  const jpy = Currency(code: 'JPY');

  late _MockGetExchangeRateUseCase getExchangeRateUseCase;
  late _MockEditTransactionUseCase editTransactionUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  EditTransactionBloc buildBloc() {
    return EditTransactionBloc(getExchangeRateUseCase, editTransactionUseCase)
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..appBloc = appBloc
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  EditTransactionState validState({bool confirmButtonEnable = false}) {
    return EditTransactionState(
      amountInput: '10',
      selectedCategory: const Category(id: 1),
      selectedDate: DateTime(2026),
      note: 'Original note',
      selectedWallet: const Wallet(id: 1, currencyCode: 'USD'),
      selectedCurrency: const Currency(code: 'USD'),
      transactionId: 10,
      confirmButtonEnable: confirmButtonEnable,
    );
  }

  setUpAll(() {
    registerFallbackValue(const AppRouteInfo.main());
    registerFallbackValue(const EditTransactionInput(transaction: Transaction()));
    registerFallbackValue(
      const GetExchangeRateInput(fromCurrencyCode: 'USD', toCurrencyCode: 'USD'),
    );
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
  });

  setUp(() {
    getExchangeRateUseCase = _MockGetExchangeRateUseCase();
    editTransactionUseCase = _MockEditTransactionUseCase();
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
    when(
      () => editTransactionUseCase.execute(any()),
    ).thenAnswer((_) async => const EditTransactionOutput());
  });

  blocTest<EditTransactionBloc, EditTransactionState>(
    'enables save when only the date changes',
    build: buildBloc,
    seed: () => validState(),
    act: (bloc) async {
      final enabled = bloc.stream.firstWhere((state) => state.confirmButtonEnable);
      bloc.add(EditTransactionDateSelected(date: DateTime(2026, 1, 2)));
      await enabled;
      expect(bloc.state.confirmButtonEnable, isTrue);

      final disabled = bloc.stream.firstWhere((state) => !state.confirmButtonEnable);
      bloc.add(const EditTransactionConfirmButtonPressed());
      await disabled;
    },
    verify: (bloc) {
      expect(bloc.state.selectedDate, DateTime(2026, 1, 2));
      expect(bloc.state.confirmButtonEnable, isFalse);
      final input =
          verify(() => editTransactionUseCase.execute(captureAny())).captured.single
              as EditTransactionInput;
      expect(input.transaction.transactionDate, DateTime(2026, 1, 2));
      expect(input.transaction.note, 'Original note');
    },
  );

  blocTest<EditTransactionBloc, EditTransactionState>(
    'enables save when only the note changes',
    build: buildBloc,
    seed: () => validState(),
    act: (bloc) async {
      final enabled = bloc.stream.firstWhere((state) => state.confirmButtonEnable);
      bloc.add(const EditTransactionNoteChanged(note: 'Updated note'));
      await enabled;
      expect(bloc.state.confirmButtonEnable, isTrue);

      final disabled = bloc.stream.firstWhere((state) => !state.confirmButtonEnable);
      bloc.add(const EditTransactionConfirmButtonPressed());
      await disabled;
    },
    verify: (bloc) {
      expect(bloc.state.note, 'Updated note');
      expect(bloc.state.confirmButtonEnable, isFalse);
      final input =
          verify(() => editTransactionUseCase.execute(captureAny())).captured.single
              as EditTransactionInput;
      expect(input.transaction.note, 'Updated note');
      expect(input.transaction.transactionDate, DateTime(2026));
    },
  );

  blocTest<EditTransactionBloc, EditTransactionState>(
    'keeps save disabled until the selected currency rate is ready',
    build: buildBloc,
    seed: () => validState(confirmButtonEnable: true),
    act: (bloc) async {
      final rateCompletion = Completer<GetExchangeRateOutput>();
      when(() => getExchangeRateUseCase.execute(any())).thenAnswer((_) => rateCompletion.future);

      final loading = bloc.stream.firstWhere(
        (state) => state.selectedCurrency?.code == 'EUR' && !state.confirmButtonEnable,
      );
      bloc.add(const EditTransactionCurrencySelected(currency: eur));
      await loading;
      expect(bloc.state.confirmButtonEnable, isFalse);

      bloc.add(const EditTransactionConfirmButtonPressed());
      await Future<void>.delayed(Duration.zero);
      verifyNever(() => editTransactionUseCase.execute(any()));

      final ready = bloc.stream.firstWhere((state) => state.exchangeRate != null);
      rateCompletion.complete(const GetExchangeRateOutput(exchangeRate: ExchangeRate(rate: 2)));
      await ready;
    },
    verify: (bloc) {
      expect(bloc.state.confirmButtonEnable, isTrue);
      expect(bloc.state.convertedAmount, 20);
      verifyNever(() => editTransactionUseCase.execute(any()));
    },
  );

  blocTest<EditTransactionBloc, EditTransactionState>(
    'ignores an exchange rate response for an older currency selection',
    build: buildBloc,
    seed: () => validState(confirmButtonEnable: true),
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
      bloc.add(const EditTransactionCurrencySelected(currency: eur));
      await eurLoading;

      final jpyLoading = bloc.stream.firstWhere(
        (state) => state.selectedCurrency?.code == 'JPY' && !state.confirmButtonEnable,
      );
      bloc.add(const EditTransactionCurrencySelected(currency: jpy));
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
