part of 'home_bloc.dart';

@freezed
sealed class HomeState extends BaseBlocState with _$HomeState {
  const HomeState._();
  const factory HomeState({
    @Default(<DailyStat>[]) List<DailyStat> monthStat,
    @Default(<Transaction>[]) List<Transaction> recentTransactions,
  }) = _HomeState;
}
