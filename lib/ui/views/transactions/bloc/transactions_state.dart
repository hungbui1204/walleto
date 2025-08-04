part of 'transactions_bloc.dart';

@freezed
sealed class TransactionsState extends BaseBlocState with _$TransactionsState {
  const TransactionsState._();
  const factory TransactionsState({
    @Default(<DayTransactions>[]) List<DayTransactions> allDayTransactions,
    DateTime? selectedDate,
    DateTimeRange? selectedDateRange,
    @Default(false) bool isDatePickerMethodExpanded,
    @Default(Wallet()) Wallet selectedWallet,
    @Default(<Wallet>[]) List<Wallet> wallets,
  }) = _TransactionsState;
}
