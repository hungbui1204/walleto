part of 'home_bloc.dart';

@freezed
sealed class HomeState extends BaseBlocState with _$HomeState {
  const HomeState._();
  const factory HomeState({
    @Default(<DailyStat>[]) List<DailyStat> monthStat,
    @Default(<MonthSummaryStat>[]) List<MonthSummaryStat> monthSummaryStats,
    @Default(<Transaction>[]) List<Transaction> recentTransactions,
    DateTime? selectedDateTime,
  }) = _HomeState;
}
