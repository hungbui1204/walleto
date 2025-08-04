import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';
part 'transactions_bloc.freezed.dart';

@injectable
class TransactionsBloc extends BaseBloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc(this._getTransactionsUseCase) : super(const TransactionsState()) {
    on<TransactionsViewInitialized>(_onTransactionsViewInitialized);
    on<TransactionsMonthSelected>(_onTransactionsMonthSelected);
    on<TransactionsDatePickerMethodExpandTriggered>(_onTransactionsDatePickerMethodExpandTriggered);
    on<TransactionsDateRangePicked>(_onTransactionsDateRangePicked);
    on<TransactionsWalletSelected>(_onWalletSelected);
  }

  final GetTransactionsUseCase _getTransactionsUseCase;

  Future<void> _onTransactionsViewInitialized(
    TransactionsViewInitialized event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final now = DateTime.now();

        emit(
          state.copyWith(
            selectedDate: now,
            selectedDateRange: null,
            selectedWallet: _getWallets().first,
          ),
        );

        // Fetch transactions for the current month and year
        final transactionsOutput = await _getTransactionsUseCase.execute(
          GetTransactionsInput(targetMonth: now.month, targetYear: now.year),
        );

        final allDayTransactions = _getDayTransFromTrans(transactionsOutput.transactions);

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

    return groupedTransactions.entries
        .map((e) {
          final totalAmount = e.value.fold<double>(0, (sum, transaction) {
            switch (transaction.type) {
              case CategoryType.income:
                return sum + transaction.amount;
              case CategoryType.expense:
                return sum - transaction.amount;
            }
          });

          return DayTransactions(
            date: e.key.toDateTime(format: DateTimeFormatConstants.commonDateFormat),
            transactions: e.value.sortedWith((a, b) => b.createdAt!.compareTo(a.createdAt!)),
            totalAmount: totalAmount,
          );
        })
        .sortedWith((a, b) => b.date!.compareTo(a.date!));
  }

  Future<void> _onTransactionsMonthSelected(
    TransactionsMonthSelected event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        if (event.selectedDate.month == state.selectedDate?.month &&
            event.selectedDate.year == state.selectedDate?.year) {
          return;
        }

        final transactionsOutput = await _getTransactionsUseCase.execute(
          GetTransactionsInput(
            targetMonth: event.selectedDate.month,
            targetYear: event.selectedDate.year,
          ),
        );

        final allDayTransactions =
            _getDayTransFromTrans(transactionsOutput.transactions).reversed.toList();

        emit(
          state.copyWith(
            allDayTransactions: allDayTransactions,
            selectedDate: event.selectedDate,
            selectedDateRange: null,
          ),
        );
      },
    );
  }

  void _onTransactionsDatePickerMethodExpandTriggered(
    TransactionsDatePickerMethodExpandTriggered event,
    Emitter<TransactionsState> emit,
  ) {
    emit(state.copyWith(isDatePickerMethodExpanded: !state.isDatePickerMethodExpanded));
  }

  Future<void> _onTransactionsDateRangePicked(
    TransactionsDateRangePicked event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final dateRangePicked = await navigator.showDateRangePicker(
          useRootNavigator: true,
          firstDate: DateTime(AppConstants.firstYear),
          lastDate: DateTime(AppConstants.lastYear, 12, 31),
          initialDateRange: state.selectedDateRange,
        );

        if (dateRangePicked == null ||
            dateRangePicked.duration == state.selectedDateRange?.duration) {
          return;
        }

        final transactionsOutput = await _getTransactionsUseCase.execute(
          GetTransactionsInput(
            fromDate: dateRangePicked.start,
            toDate: dateRangePicked.end.add(const Duration(days: 1)),
          ),
        );

        final allDayTransactions =
            _getDayTransFromTrans(transactionsOutput.transactions).reversed.toList();

        emit(
          state.copyWith(
            allDayTransactions: allDayTransactions,
            selectedDateRange: dateRangePicked,
            selectedDate: null,
          ),
        );
      },
    );
  }

  void _onWalletSelected(TransactionsWalletSelected event, Emitter<TransactionsState> emit) {
    if (state.selectedWallet == event.selectedWallet) return;

    emit(state.copyWith(selectedWallet: event.selectedWallet));
  }

  // Include the 'Total Wallet' in the list of wallets (first item)
  // 'Total Wallet' is a wallet that having total amount of all wallets
  List<Wallet> _getWallets() {
    final totalAmount = appBloc.state.wallets.fold<double>(0, (sum, wallet) => sum + wallet.amount);

    final totalWallet = Wallet(
      name: S.current.total,
      amount: totalAmount,
      id: AppConstants.totalWalletId,
    );

    return [totalWallet, ...appBloc.state.wallets];
  }
}
