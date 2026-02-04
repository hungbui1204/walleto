import 'dart:async';

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
    on<TransactionsWalletsUpdated>(_onTransactionsWalletsUpdated);
    on<TransactionsRefreshed>(_onTransactionsRefreshed);
  }

  final GetTransactionsUseCase _getTransactionsUseCase;
  StreamSubscription<AppState>? _appBlocSubscription;

  @override
  Future<void> close() {
    _appBlocSubscription?.cancel();

    return super.close();
  }

  void _onTransactionsWalletsUpdated(
    TransactionsWalletsUpdated event,
    Emitter<TransactionsState> emit,
  ) {
    emit(state.copyWith(wallets: event.wallets));
  }

  Future<void> _onTransactionsViewInitialized(
    TransactionsViewInitialized event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final now = DateTime.now();
        final wallets = _getWallets();

        // Handle refresh wallets from AppBloc
        // Depend on the wallets amount
        _appBlocSubscription = appBloc.stream.listen((appState) {
          final currentWalletsAmount = wallets.first.amount;

          final appBlocWalletsAmount = appState.wallets.fold<double>(0, (sum, wallet) {
            return sum + wallet.amount;
          });

          if (appBlocWalletsAmount != currentWalletsAmount) {
            add(TransactionsWalletsUpdated(wallets: _getWallets()));
          }
        });

        emit(
          state.copyWith(
            selectedDate: now,
            selectedDateRange: null,
            selectedWallet: wallets.first,
            wallets: wallets,
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

  Future<void> _onTransactionsRefreshed(
    TransactionsRefreshed event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        // Fetch transactions for the month-year or date range based on current state
        late final GetTransactionsInput transactionsInput;

        if (state.selectedDate != null) {
          transactionsInput = GetTransactionsInput(
            targetMonth: state.selectedDate!.month,
            targetYear: state.selectedDate!.year,
            walletId: _getWalletId(state.selectedWallet.id),
          );
        } else if (state.selectedDateRange != null) {
          transactionsInput = GetTransactionsInput(
            fromDate: state.selectedDateRange!.start,
            toDate: state.selectedDateRange!.end.add(const Duration(days: 1)),
            walletId: _getWalletId(state.selectedWallet.id),
          );
        }

        final transactionsOutput = await _getTransactionsUseCase.execute(transactionsInput);

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
      final date = transaction.transactionDate?.toStringWithFormat(
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
            transactions: e.value.sortedWith((a, b) {
              return b.transactionDate!.compareTo(a.transactionDate!);
            }),
            totalAmount: totalAmount,
            currencyCode: e.value.first.currencyCode,
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
            walletId: _getWalletId(state.selectedWallet.id),
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
            walletId: _getWalletId(state.selectedWallet.id),
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

  Future<void> _onWalletSelected(
    TransactionsWalletSelected event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        if (state.selectedWallet == event.selectedWallet) return;

        // Filter transactions by selected wallet
        final transactionsOutput = await _getTransactionsUseCase.execute(
          GetTransactionsInput(
            walletId: _getWalletId(event.selectedWallet.id),
            fromDate: state.selectedDateRange?.start,
            toDate: state.selectedDateRange?.end,
            targetMonth: state.selectedDate?.month,
            targetYear: state.selectedDate?.year,
          ),
        );

        final transactions =
            _getDayTransFromTrans(transactionsOutput.transactions).reversed.toList();

        emit(
          state.copyWith(selectedWallet: event.selectedWallet, allDayTransactions: transactions),
        );
      },
    );
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

  /// Get the wallet ID for the selected wallet.
  /// If the selected wallet is the 'Total', return null to indicate no filtering.
  int? _getWalletId(int id) {
    return id == AppConstants.totalWalletId ? null : id;
  }
}
