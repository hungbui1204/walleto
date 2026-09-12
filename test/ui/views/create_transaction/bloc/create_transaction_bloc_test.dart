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
}
