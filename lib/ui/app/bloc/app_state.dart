part of 'app_bloc.dart';

@freezed
sealed class AppState extends BaseBlocState with _$AppState {
  const AppState._();

  const factory AppState({
    @Default(0) int totalBalance,
    @Default(<Wallet>[]) List<Wallet> wallets,
    @Default(<Currency>[]) List<Currency> currencies,

    /// Flags to indicate whether the transactions and statistical charts need to be reloaded.
    @Default(false) bool needReloadTransactions,
    @Default(false) bool needReloadStatisticalCharts,

    /// The default user currency used in the app
    /// This is set when user create their first wallet, and can be updated
    @Default(Currency()) Currency userDefaultCurrency,
  }) = _AppState;
}
