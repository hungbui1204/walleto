part of 'transactions_bloc.dart';

@freezed
sealed class TransactionsState extends BaseBlocState with _$TransactionsState {
  const TransactionsState._();
  const factory TransactionsState({
    @Default(<DayTransactions>[]) List<DayTransactions> allDayTransactions,
  }) = _TransactionsState;
}
