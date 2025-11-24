part of 'app_bloc.dart';

@freezed
sealed class AppState extends BaseBlocState with _$AppState {
  const AppState._();

  const factory AppState({
    @Default(0) int totalBalance,
    @Default(<Wallet>[]) List<Wallet> wallets,
    @Default(<Currency>[]) List<Currency> currencies,
    @Default(false) bool needReloadTransactions,
    @Default(false) bool needReloadStatisticalCharts,
  }) = _AppState;
}
