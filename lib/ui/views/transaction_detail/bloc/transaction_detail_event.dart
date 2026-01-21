part of 'transaction_detail_bloc.dart';

sealed class TransactionDetailEvent extends BaseBlocEvent {
  const TransactionDetailEvent();
}

@freezed
sealed class TransactionDetailDuplicateButtonPressed extends TransactionDetailEvent
    with _$TransactionDetailDuplicateButtonPressed {
  const TransactionDetailDuplicateButtonPressed._();

  const factory TransactionDetailDuplicateButtonPressed({
    required int transactionId,
    required DateTime selectedDate,
  }) = _TransactionDetailDuplicateButtonPressed;
}

@freezed
sealed class TransactionDetailDeleteButtonPressed extends TransactionDetailEvent
    with _$TransactionDetailDeleteButtonPressed {
  const TransactionDetailDeleteButtonPressed._();

  const factory TransactionDetailDeleteButtonPressed({required int transactionId}) =
      _TransactionDetailDeleteButtonPressed;
}
