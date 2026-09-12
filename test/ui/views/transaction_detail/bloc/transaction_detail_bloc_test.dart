import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockDuplicateTransactionUseCase extends Mock implements DuplicateTransactionUseCase {}

class _MockDeleteTransactionUseCase extends Mock implements DeleteTransactionUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  late _MockDuplicateTransactionUseCase duplicateTransactionUseCase;
  late _MockDeleteTransactionUseCase deleteTransactionUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  TransactionDetailBloc buildBloc() {
    return TransactionDetailBloc(duplicateTransactionUseCase, deleteTransactionUseCase)
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..appBloc = appBloc
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  setUpAll(() {
    registerFallbackValue(
      DuplicateTransactionInput(transactionId: 1, newCreatedAt: DateTime(2026)),
    );
    registerFallbackValue(const DeleteTransactionInput(transactionId: 1));
    registerFallbackValue(const AppRouteInfo.main());
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
  });

  setUp(() {
    duplicateTransactionUseCase = _MockDuplicateTransactionUseCase();
    deleteTransactionUseCase = _MockDeleteTransactionUseCase();
    navigator = _MockAppNavigator();
    appBloc = _MockAppBloc();
    commonBloc = _MockCommonBloc();
    exceptionHandler = _MockExceptionHandler();

    when(() => appBloc.state).thenReturn(const AppState());
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
      () => duplicateTransactionUseCase.execute(any()),
    ).thenAnswer((_) async => const DuplicateTransactionOutput());
    when(
      () => deleteTransactionUseCase.execute(any()),
    ).thenAnswer((_) async => const DeleteTransactionOutput());
  });

  blocTest<TransactionDetailBloc, TransactionDetailState>(
    'reloads transactions, charts, and wallets after duplicate',
    build: buildBloc,
    act:
        (bloc) => bloc.add(
          TransactionDetailDuplicateButtonPressed(
            transactionId: 1,
            selectedDate: DateTime(2026, 3),
          ),
        ),
    verify: (_) {
      verify(() => appBloc.add(const TransactionsReloaded(needReloadTransactions: true))).called(1);
      verify(
        () => appBloc.add(const StatisticalChartsReloaded(needReloadStatisticalCharts: true)),
      ).called(1);
      verify(() => appBloc.add(const DataFetched(walletsFetched: true))).called(1);
    },
  );

  blocTest<TransactionDetailBloc, TransactionDetailState>(
    'reloads transactions, charts, and wallets after delete',
    build: buildBloc,
    act: (bloc) => bloc.add(const TransactionDetailDeleteButtonPressed(transactionId: 1)),
    verify: (_) {
      verify(() => appBloc.add(const TransactionsReloaded(needReloadTransactions: true))).called(1);
      verify(
        () => appBloc.add(const StatisticalChartsReloaded(needReloadStatisticalCharts: true)),
      ).called(1);
      verify(() => appBloc.add(const DataFetched(walletsFetched: true))).called(1);
    },
  );
}
