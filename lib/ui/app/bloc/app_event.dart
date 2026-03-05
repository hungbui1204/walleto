part of 'app_bloc.dart';

sealed class AppEvent extends BaseBlocEvent {
  const AppEvent();
}

@freezed
sealed class SignOutButtonPressed extends AppEvent with _$SignOutButtonPressed {
  const SignOutButtonPressed._();

  const factory SignOutButtonPressed() = _SignOutButtonPressed;
}

@freezed
sealed class DataFetched extends AppEvent with _$DataFetched {
  const DataFetched._();

  const factory DataFetched({
    @Default(false) bool walletsFetched,
    @Default(false) bool currenciesFetched,
  }) = _DataFetched;
}

@freezed
sealed class GetUserDefaultCurrency extends AppEvent with _$GetUserDefaultCurrency {
  const GetUserDefaultCurrency._();

  const factory GetUserDefaultCurrency() = _GetUserDefaultCurrency;
}

@freezed
sealed class TransactionsReloaded extends AppEvent with _$TransactionsReloaded {
  const TransactionsReloaded._();

  const factory TransactionsReloaded({required bool needReloadTransactions}) =
      _TransactionsReloaded;
}

@freezed
sealed class StatisticalChartsReloaded extends AppEvent with _$StatisticalChartsReloaded {
  const StatisticalChartsReloaded._();

  const factory StatisticalChartsReloaded({required bool needReloadStatisticalCharts}) =
      _StatisticalChartsReloaded;
}

@freezed
sealed class UserDefaultCurrencyUpdated extends AppEvent with _$UserDefaultCurrencyUpdated {
  const UserDefaultCurrencyUpdated._();

  const factory UserDefaultCurrencyUpdated({required Currency newCurrency}) =
      _UserDefaultCurrencyUpdated;
}
