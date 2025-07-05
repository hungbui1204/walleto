part of 'app_bloc.dart';

@freezed
sealed class AppState extends BaseBlocState with _$AppState {
  const AppState._();

  const factory AppState({
    @Default(0) int totalBalance,
    @Default(<Category>[]) List<Category> categories,
    @Default(<Wallet>[]) List<Wallet> wallets,
  }) = _AppState;
}
