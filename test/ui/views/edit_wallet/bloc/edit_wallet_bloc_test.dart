import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockUpdateWalletUseCase extends Mock implements UpdateWalletUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  const wallet = Wallet(id: 4, name: 'Savings', amount: 250, currencyCode: 'USD');

  late _MockUpdateWalletUseCase updateWalletUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  EditWalletBloc buildBloc() {
    return EditWalletBloc(updateWalletUseCase)
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..appBloc = appBloc
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  setUpAll(() {
    registerFallbackValue(const UpdateWalletInput(wallet: Wallet()));
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const TransactionsReloaded(needReloadTransactions: false));
    registerFallbackValue(const StatisticalChartsReloaded(needReloadStatisticalCharts: false));
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
  });

  setUp(() {
    updateWalletUseCase = _MockUpdateWalletUseCase();
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
    when(() => navigator.pop()).thenAnswer((_) async => true);
    when(
      () => updateWalletUseCase.execute(any()),
    ).thenAnswer((_) async => const UpdateWalletOutput());
  });

  blocTest<EditWalletBloc, EditWalletState>(
    'does not enable or save a pasted nonnumeric balance',
    build: buildBloc,
    seed: () => const EditWalletState(wallet: wallet),
    act: (bloc) {
      bloc.add(const EditWalletAmountInputChanged('not-a-number'));
      bloc.add(const EditWalletConfirmButtonPressed());
    },
    verify: (bloc) {
      expect(bloc.state.isConfirmButtonEnabled, isFalse);
      verifyNever(() => updateWalletUseCase.execute(any()));
      verifyNever(() => navigator.pop());
    },
  );

  blocTest<EditWalletBloc, EditWalletState>(
    'does not enable save for a negative balance',
    build: buildBloc,
    seed: () => const EditWalletState(wallet: wallet),
    act: (bloc) => bloc.add(const EditWalletAmountInputChanged('-1')),
    verify: (bloc) {
      expect(bloc.state.isConfirmButtonEnabled, isFalse);
    },
  );
}
