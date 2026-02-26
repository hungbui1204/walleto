part of 'home_bloc.dart';

@freezed
sealed class HomeState extends BaseBlocState with _$HomeState {
  const HomeState._();
  const factory HomeState({
    /// This is used to display month summary stats in the home view.
    @Default(<MonthSummaryStat>[]) List<MonthSummaryStat> monthSummaryStats,

    /// WalletStat will contain its own list of CategoryStat, which contain parent category info.
    /// This is used to display top wallet statistics (for the selected month and category type).
    @Default(WalletStat()) WalletStat walletStat,

    /// Display category type for the wallet stats, which is either expense or income.
    @Default(CategoryType.expense) CategoryType selectedCategoryType,

    /// This is used to display 5 recent transactions in the home view.
    @Default(<Transaction>[]) List<Transaction> recentTransactions,
    DateTime? selectedDateTime,
  }) = _HomeState;
}
