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
  TransactionsBloc(this._getTransactionsUseCase, this._convertAmountsToCurrencyUseCase)
    : super(const TransactionsState()) {
    on<TransactionsViewInitialized>(_onTransactionsViewInitialized, transformer: log());
    on<TransactionsMonthSelected>(_onTransactionsMonthSelected, transformer: log());
    on<TransactionsDatePickerMethodExpandTriggered>(
      _onTransactionsDatePickerMethodExpandTriggered,
      transformer: log(),
    );
    on<TransactionsDateRangePicked>(_onTransactionsDateRangePicked, transformer: log());
    on<TransactionsWalletSelected>(_onWalletSelected, transformer: log());
    on<TransactionsWalletsUpdated>(_onTransactionsWalletsUpdated, transformer: log());
    on<TransactionsRefreshed>(_onTransactionsRefreshed, transformer: log());
  }

  final GetTransactionsUseCase _getTransactionsUseCase;
  final ConvertAmountsToCurrencyUseCase _convertAmountsToCurrencyUseCase;
  StreamSubscription<AppState>? _appBlocSubscription;

  @override
  Future<void> close() {
    _appBlocSubscription?.cancel();

    return super.close();
  }

  Future<void> _onTransactionsWalletsUpdated(
    TransactionsWalletsUpdated event,
    Emitter<TransactionsState> emit,
  ) async {
    final wallets = await _buildWallets();
    if (_hasSameWalletBalances(state.wallets, wallets)) {
      return;
    }

    final selectedWallet = wallets.firstWhere(
      (wallet) => wallet.id == state.selectedWallet.id,
      orElse: () => wallets.firstOrNull ?? const Wallet(),
    );

    emit(state.copyWith(wallets: wallets, selectedWallet: selectedWallet));
  }

  Future<void> _onTransactionsViewInitialized(
    TransactionsViewInitialized event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final now = DateTime.now();
        await _appBlocSubscription?.cancel();
        _appBlocSubscription = appBloc.stream.listen((_) {
          add(const TransactionsWalletsUpdated());
        });

        final wallets = await _buildWallets();
        emit(
          state.copyWith(
            selectedDate: now,
            selectedDateRange: null,
            selectedWallet: wallets.firstOrNull ?? const Wallet(),
            wallets: wallets,
          ),
        );

        if (appBloc.state.wallets.isEmpty) {
          emit(state.copyWith(allDayTransactions: const []));
          return;
        }

        final transactionsOutput = await _getTransactionsUseCase.execute(
          GetTransactionsInput(targetMonth: now.month, targetYear: now.year),
        );

        final allDayTransactions = await _getDayTransFromTrans(transactionsOutput.transactions);

        emit(state.copyWith(allDayTransactions: allDayTransactions));
      },
    );
  }

  Future<void> _onTransactionsRefreshed(
    TransactionsRefreshed event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      handleLoading: false,
      action: () async {
        if (appBloc.state.wallets.isEmpty) {
          emit(state.copyWith(allDayTransactions: const [], wallets: const []));
          return;
        }

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
        } else {
          return;
        }

        final transactionsOutput = await _getTransactionsUseCase.execute(transactionsInput);

        final allDayTransactions = await _getDayTransFromTrans(transactionsOutput.transactions);

        emit(state.copyWith(allDayTransactions: allDayTransactions));
      },
    );
  }

  /// Convert a list of [Transaction] to a list of [DayTransactions]
  Future<List<DayTransactions>> _getDayTransFromTrans(List<Transaction> transactions) async {
    final targetCurrencyCode = _targetCurrencyCode();
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

    final dayTransactions = <DayTransactions>[];
    for (final entry in groupedTransactions.entries) {
      final converted = await _convertAmountsToCurrencyUseCase.execute(
        ConvertAmountsToCurrencyInput(
          targetCurrencyCode: targetCurrencyCode,
          amounts:
              entry.value
                  .map(
                    (transaction) => AmountInCurrency(
                      amount: transaction.amount,
                      currencyCode: transaction.currencyCode,
                      sign: transaction.type == CategoryType.income ? 1 : -1,
                    ),
                  )
                  .toList(),
        ),
      );

      dayTransactions.add(
        DayTransactions(
          date: entry.key.toDateTime(format: DateTimeFormatConstants.commonDateFormat),
          transactions: entry.value.sortedWith((a, b) {
            return b.transactionDate!.compareTo(a.transactionDate!);
          }),
          totalAmount: converted.total,
          currencyCode: targetCurrencyCode,
        ),
      );
    }

    return dayTransactions.sortedWith((a, b) => b.date!.compareTo(a.date!));
  }

  Future<void> _onTransactionsMonthSelected(
    TransactionsMonthSelected event,
    Emitter<TransactionsState> emit,
  ) async {
    await runBlocCatching(
      handleLoading: false,
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

        final allDayTransactions = await _getDayTransFromTrans(transactionsOutput.transactions);

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
      handleLoading: false,
      action: () async {
        final dateRangePicked = await navigator.showDateRangePicker(
          useRootNavigator: true,
          firstDate: DateTime(AppConstants.firstYear),
          lastDate: DateTime(AppConstants.lastYear, 12, 31),
          initialDateRange: state.selectedDateRange,
        );

        if (dateRangePicked == null || _isSameDateRange(state.selectedDateRange, dateRangePicked)) {
          return;
        }

        final transactionsOutput = await _getTransactionsUseCase.execute(
          GetTransactionsInput(
            fromDate: dateRangePicked.start,
            toDate: dateRangePicked.end.add(const Duration(days: 1)),
            walletId: _getWalletId(state.selectedWallet.id),
          ),
        );

        final allDayTransactions = await _getDayTransFromTrans(transactionsOutput.transactions);

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
      handleLoading: false,
      action: () async {
        if (state.selectedWallet == event.selectedWallet) return;

        final transactionsOutput = await _getTransactionsUseCase.execute(
          GetTransactionsInput(
            walletId: _getWalletId(event.selectedWallet.id),
            fromDate: state.selectedDateRange?.start,
            toDate: state.selectedDateRange?.end,
            targetMonth: state.selectedDate?.month,
            targetYear: state.selectedDate?.year,
          ),
        );

        emit(state.copyWith(selectedWallet: event.selectedWallet));
        final transactions = await _getDayTransFromTrans(transactionsOutput.transactions);

        emit(state.copyWith(allDayTransactions: transactions));
      },
    );
  }

  Future<List<Wallet>> _buildWallets() async {
    final realWallets = appBloc.state.wallets;
    if (realWallets.isEmpty) {
      return const [];
    }

    final targetCurrencyCode = _defaultCurrencyCode();
    final totalOutput = await _convertAmountsToCurrencyUseCase.execute(
      ConvertAmountsToCurrencyInput(
        targetCurrencyCode: targetCurrencyCode,
        amounts:
            realWallets
                .map(
                  (wallet) =>
                      AmountInCurrency(amount: wallet.amount, currencyCode: wallet.currencyCode),
                )
                .toList(),
      ),
    );

    final totalWallet = Wallet(
      name: S.current.total,
      amount: totalOutput.total,
      id: AppConstants.totalWalletId,
      currencyCode: targetCurrencyCode,
    );

    return [totalWallet, ...realWallets];
  }

  String _targetCurrencyCode() {
    if (state.selectedWallet.id == AppConstants.totalWalletId || state.selectedWallet.id == 0) {
      return _defaultCurrencyCode();
    }

    return state.selectedWallet.currencyCode.isNotEmpty
        ? state.selectedWallet.currencyCode
        : _defaultCurrencyCode();
  }

  String _defaultCurrencyCode() {
    if (appBloc.state.userDefaultCurrency.code.isNotEmpty) {
      return appBloc.state.userDefaultCurrency.code;
    }

    return AppConstants.defaultCurrencyCode;
  }

  bool _isSameDateRange(DateTimeRange? current, DateTimeRange picked) {
    return current != null && current.start == picked.start && current.end == picked.end;
  }

  bool _hasSameWalletBalances(List<Wallet> previous, List<Wallet> next) {
    if (previous.length != next.length) {
      return false;
    }

    for (var i = 0; i < previous.length; i++) {
      if (previous[i].id != next[i].id ||
          previous[i].amount != next[i].amount ||
          previous[i].currencyCode != next[i].currencyCode) {
        return false;
      }
    }

    return true;
  }

  /// Get the wallet ID for the selected wallet.
  /// If the selected wallet is the 'Total', return null to indicate no filtering.
  int? _getWalletId(int id) {
    return id == AppConstants.totalWalletId || id == 0 ? null : id;
  }
}
