part of 'create_wallet_bloc.dart';

@freezed
sealed class CreateWalletState extends BaseBlocState with _$CreateWalletState {
  const CreateWalletState._();

  const factory CreateWalletState({
    @Default('') String walletName,
    @Default('') String initialBalance,
    @Default(false) bool isConfirmButtonEnabled,
    @Default('') String iconUrl,
    Currency? selectedCurrency,
  }) = _CreateWalletState;
}
