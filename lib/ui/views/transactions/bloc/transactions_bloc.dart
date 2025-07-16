import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';
part 'transactions_bloc.freezed.dart';

@injectable
class TransactionsBloc extends BaseBloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc(this._getTransactionsUseCase) : super(const TransactionsState()) {
    on<TransactionsViewInitialized>(_onTransactionsViewInitialized);
  }

  final GetTransactionsUseCase _getTransactionsUseCase;

  Future<void> _onTransactionsViewInitialized(
    TransactionsViewInitialized event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final transactionsOutput = await _getTransactionsUseCase.execute(
          const GetTransactionsInput(),
        );

        final allDayTransactions =
            _getDayTransFromTrans(transactionsOutput.transactions).reversed.toList();

        emit(state.copyWith(allDayTransactions: allDayTransactions));
      },
    );
  }

  /// Convert a list of [Transaction] to a list of [DayTransactions]
  List<DayTransactions> _getDayTransFromTrans(List<Transaction> transactions) {
    final groupedTransactions = transactions.fold<Map<String, List<Transaction>>>({}, (
      acc,
      transaction,
    ) {
      final date = transaction.createdAt?.toStringWithFormat(
        DateTimeFormatConstants.commonDateFormat,
      );

      if (date == null) return acc;

      if (!acc.containsKey(date)) {
        acc[date] = [];
      }
      acc[date]!.add(transaction);
      return acc;
    });

    return groupedTransactions.entries.map((e) {
      final totalAmount = e.value.fold<double>(0, (sum, transaction) {
        return sum + transaction.amount;
      });

      return DayTransactions(
        date: e.key.toDateTime(format: DateTimeFormatConstants.commonDateFormat),
        transactions: e.value,
        totalAmount: totalAmount,
      );
    }).toList();
  }
}
