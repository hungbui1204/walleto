part of 'edit_transaction_bloc.dart';

sealed class EditTransactionEvent extends BaseBlocEvent {
  const EditTransactionEvent();
}

@freezed
sealed class EditTransactionViewInitiated extends EditTransactionEvent
    with _$EditTransactionViewInitiated {
  const EditTransactionViewInitiated._();

  const factory EditTransactionViewInitiated(Transaction transaction) =
      _EditTransactionViewInitiated;
}

@freezed
sealed class EditTransactionConfirmButtonPressed extends EditTransactionEvent
    with _$EditTransactionConfirmButtonPressed {
  const EditTransactionConfirmButtonPressed._();

  const factory EditTransactionConfirmButtonPressed() = _EditTransactionConfirmButtonPressed;
}
