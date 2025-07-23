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

  const factory DataFetched() = _DataFetched;
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
