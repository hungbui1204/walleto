part of 'edit_wallet_bloc.dart';

sealed class EditWalletEvent extends BaseBlocEvent {
  const EditWalletEvent();
}

@freezed
sealed class EditWalletViewInitialized extends EditWalletEvent with _$EditWalletViewInitialized {
  const EditWalletViewInitialized._();

  const factory EditWalletViewInitialized(Wallet wallet) = _EditWalletViewInitialized;
}

@freezed
sealed class EditWalletAmountInputChanged extends EditWalletEvent
    with _$EditWalletAmountInputChanged {
  const EditWalletAmountInputChanged._();

  const factory EditWalletAmountInputChanged(String amount) = _EditWalletAmountInputChanged;
}

@freezed
sealed class EditWalletConfirmButtonPressed extends EditWalletEvent
    with _$EditWalletConfirmButtonPressed {
  const EditWalletConfirmButtonPressed._();

  const factory EditWalletConfirmButtonPressed() = _EditWalletConfirmButtonPressed;
}
