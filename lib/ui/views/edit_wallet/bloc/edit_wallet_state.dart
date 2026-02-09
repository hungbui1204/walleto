part of 'edit_wallet_bloc.dart';

@freezed
sealed class EditWalletState extends BaseBlocState with _$EditWalletState {
  const EditWalletState._();

  const factory EditWalletState({
    @Default('') String amount,
    @Default(Wallet()) Wallet wallet,
    @Default(false) bool isConfirmButtonEnabled,
  }) = _EditWalletState;
}
