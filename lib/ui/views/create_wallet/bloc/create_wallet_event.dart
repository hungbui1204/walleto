part of 'create_wallet_bloc.dart';

sealed class CreateWalletEvent extends BaseBlocEvent {
  const CreateWalletEvent();
}

@freezed
sealed class CreateWalletConfirmButtonPressed extends CreateWalletEvent
    with _$CreateWalletConfirmButtonPressed {
  const CreateWalletConfirmButtonPressed._();

  const factory CreateWalletConfirmButtonPressed() = _CreateWalletConfirmButtonPressed;
}

@freezed
sealed class CreateWalletNameInputChanged extends CreateWalletEvent
    with _$CreateWalletNameInputChanged {
  const CreateWalletNameInputChanged._();

  const factory CreateWalletNameInputChanged({required String walletName}) =
      _CreateWalletNameInputChanged;
}

@freezed
sealed class CreateWalletInitialBalanceInputChanged extends CreateWalletEvent
    with _$CreateWalletInitialBalanceInputChanged {
  const CreateWalletInitialBalanceInputChanged._();

  const factory CreateWalletInitialBalanceInputChanged({required String initialBalance}) =
      _CreateWalletInitialBalanceInputChanged;
}

@freezed
sealed class CreateWalletIconChanged extends CreateWalletEvent with _$CreateWalletIconChanged {
  const CreateWalletIconChanged._();

  const factory CreateWalletIconChanged({required String iconUrl}) = _CreateWalletIconChanged;
}
