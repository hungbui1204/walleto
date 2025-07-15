part of 'transactions_bloc.dart';

sealed class TransactionsEvent extends BaseBlocEvent {
  const TransactionsEvent();
}

@freezed
sealed class TransactionsViewInitialized extends TransactionsEvent
    with _$TransactionsViewInitialized {
  const TransactionsViewInitialized._();

  const factory TransactionsViewInitialized() = _TransactionsViewInitialized;
}
