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
sealed class EditTransactionKeyboardToggled extends EditTransactionEvent
    with _$EditTransactionKeyboardToggled {
  const EditTransactionKeyboardToggled._();

  const factory EditTransactionKeyboardToggled({required bool show}) =
      _EditTransactionKeyboardToggled;
}

@freezed
sealed class EditTransactionAmountChanged extends EditTransactionEvent
    with _$EditTransactionAmountChanged {
  const EditTransactionAmountChanged._();

  const factory EditTransactionAmountChanged({required String number}) =
      _EditTransactionAmountChanged;
}

@freezed
sealed class EditTransactionOperationChanged extends EditTransactionEvent
    with _$EditTransactionOperationChanged {
  const EditTransactionOperationChanged._();

  const factory EditTransactionOperationChanged({required String operation}) =
      _EditTransactionOperationChanged;
}

@freezed
sealed class EditTransactionEqualButtonPressed extends EditTransactionEvent
    with _$EditTransactionEqualButtonPressed {
  const EditTransactionEqualButtonPressed._();

  const factory EditTransactionEqualButtonPressed() = _EditTransactionEqualButtonPressed;
}

@freezed
sealed class EditTransactionBackspacePressed extends EditTransactionEvent
    with _$EditTransactionBackspacePressed {
  const EditTransactionBackspacePressed._();

  const factory EditTransactionBackspacePressed() = _EditTransactionBackspacePressed;
}

@freezed
sealed class EditTransactionClearPressed extends EditTransactionEvent
    with _$EditTransactionClearPressed {
  const EditTransactionClearPressed._();

  const factory EditTransactionClearPressed() = _EditTransactionClearPressed;
}

@freezed
sealed class EditTransactionCategorySelected extends EditTransactionEvent
    with _$EditTransactionCategorySelected {
  const EditTransactionCategorySelected._();

  const factory EditTransactionCategorySelected({required Category category}) =
      _EditTransactionCategorySelected;
}

@freezed
sealed class EditTransactionConfirmButtonPressed extends EditTransactionEvent
    with _$EditTransactionConfirmButtonPressed {
  const EditTransactionConfirmButtonPressed._();

  const factory EditTransactionConfirmButtonPressed() = _EditTransactionConfirmButtonPressed;
}

@freezed
sealed class EditTransactionDateSelected extends EditTransactionEvent
    with _$EditTransactionDateSelected {
  const EditTransactionDateSelected._();

  const factory EditTransactionDateSelected({required DateTime date}) =
      _EditTransactionDateSelected;
}

@freezed
sealed class EditTransactionNoteChanged extends EditTransactionEvent
    with _$EditTransactionNoteChanged {
  const EditTransactionNoteChanged._();

  const factory EditTransactionNoteChanged({required String note}) = _EditTransactionNoteChanged;
}

@freezed
sealed class EditTransactionWalletSelected extends EditTransactionEvent
    with _$EditTransactionWalletSelected {
  const EditTransactionWalletSelected._();

  const factory EditTransactionWalletSelected({required Wallet wallet}) =
      _EditTransactionWalletSelected;
}

@freezed
sealed class EditTransactionCurrencySelected extends EditTransactionEvent
    with _$EditTransactionCurrencySelected {
  const EditTransactionCurrencySelected._();

  const factory EditTransactionCurrencySelected({required Currency currency}) =
      _EditTransactionCurrencySelected;
}
