part of 'create_transaction_bloc.dart';

sealed class CreateTransactionEvent extends BaseBlocEvent {
  const CreateTransactionEvent();
}

@freezed
sealed class CreateTransactionViewInitiated extends CreateTransactionEvent
    with _$CreateTransactionViewInitiated {
  const CreateTransactionViewInitiated._();

  const factory CreateTransactionViewInitiated() = _CreateTransactionViewInitiated;
}

@freezed
sealed class CreateTransactionKeyboardToggled extends CreateTransactionEvent
    with _$CreateTransactionKeyboardToggled {
  const CreateTransactionKeyboardToggled._();

  const factory CreateTransactionKeyboardToggled({required bool show}) =
      _CreateTransactionKeyboardToggled;
}

@freezed
sealed class CreateTransactionAmountChanged extends CreateTransactionEvent
    with _$CreateTransactionAmountChanged {
  const CreateTransactionAmountChanged._();

  const factory CreateTransactionAmountChanged({required String number}) =
      _CreateTransactionAmountChanged;
}

@freezed
sealed class CreateTransactionOperationChanged extends CreateTransactionEvent
    with _$CreateTransactionOperationChanged {
  const CreateTransactionOperationChanged._();

  const factory CreateTransactionOperationChanged({required String operation}) =
      _CreateTransactionOperationChanged;
}

@freezed
sealed class CreateTransactionEqualButtonPressed extends CreateTransactionEvent
    with _$CreateTransactionEqualButtonPressed {
  const CreateTransactionEqualButtonPressed._();

  const factory CreateTransactionEqualButtonPressed() = _CreateTransactionEqualButtonPressed;
}

@freezed
sealed class CreateTransactionBackspacePressed extends CreateTransactionEvent
    with _$CreateTransactionBackspacePressed {
  const CreateTransactionBackspacePressed._();

  const factory CreateTransactionBackspacePressed() = _CreateTransactionBackspacePressed;
}

@freezed
sealed class CreateTransactionClearPressed extends CreateTransactionEvent
    with _$CreateTransactionClearPressed {
  const CreateTransactionClearPressed._();

  const factory CreateTransactionClearPressed() = _CreateTransactionClearPressed;
}
