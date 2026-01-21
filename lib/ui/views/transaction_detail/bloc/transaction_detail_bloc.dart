import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'transaction_detail_event.dart';
part 'transaction_detail_state.dart';
part 'transaction_detail_bloc.freezed.dart';

@injectable
class TransactionDetailBloc extends BaseBloc<TransactionDetailEvent, TransactionDetailState> {
  TransactionDetailBloc(this._duplicateTransactionUseCase, this._deleteTransactionUseCase)
    : super(const TransactionDetailState()) {
    on<TransactionDetailDuplicateButtonPressed>(
      _onTransactionDetailDuplicateButtonPressed,
      transformer: log(),
    );
    on<TransactionDetailDeleteButtonPressed>(
      _onTransactionDetailDeleteButtonPressed,
      transformer: log(),
    );
  }

  final DuplicateTransactionUseCase _duplicateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;

  Future<void> _onTransactionDetailDuplicateButtonPressed(
    TransactionDetailDuplicateButtonPressed event,
    Emitter<TransactionDetailState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        await _duplicateTransactionUseCase.execute(
          DuplicateTransactionInput(
            transactionId: event.transactionId,
            newCreatedAt: event.selectedDate,
          ),
        );

        appBloc.add(const TransactionsReloaded(needReloadTransactions: true));

        await navigator.pop();
      },
    );
  }

  Future<void> _onTransactionDetailDeleteButtonPressed(
    TransactionDetailDeleteButtonPressed event,
    Emitter<TransactionDetailState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        await _deleteTransactionUseCase.execute(
          DeleteTransactionInput(transactionId: event.transactionId),
        );

        appBloc.add(const TransactionsReloaded(needReloadTransactions: true));

        await navigator.pop();
      },
    );
  }
}
