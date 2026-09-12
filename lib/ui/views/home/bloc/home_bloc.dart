import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

@injectable
class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  HomeBloc(
    this._getMonthSummaryStatsUseCase,
    this._getRecentTransactionsUseCase,
    this._getTopWalletStatsUseCase,
    this._getUserDefaultCurrencyUseCase,
    this._convertAmountsToCurrencyUseCase,
  ) : super(const HomeState()) {
    on<HomeViewInitialized>(_onHomeViewInitialized, transformer: log());
    on<HomeDataRefreshed>(_onHomeDataRefreshed, transformer: log());
    on<HomeCategoryTypeSelected>(_onHomeCategoryTypeSelected, transformer: log());
    on<HomeCurrencySelected>(_onHomeCurrencySelected, transformer: log());
    on<HomeBalanceRecalculated>(_onHomeBalanceRecalculated, transformer: log());
  }

  final GetMonthSummaryStatsUseCase _getMonthSummaryStatsUseCase;
  final GetTopWalletStatsUseCase _getTopWalletStatsUseCase;
  final GetRecentTransactionsUseCase _getRecentTransactionsUseCase;
  final GetUserDefaultCurrencyUseCase _getUserDefaultCurrencyUseCase;
  final ConvertAmountsToCurrencyUseCase _convertAmountsToCurrencyUseCase;

  Future<void> _onHomeViewInitialized(HomeViewInitialized event, Emitter<HomeState> emit) async {
    await runBlocCatching(action: () => _loadHomeData(emit));
  }

  Future<void> _onHomeDataRefreshed(HomeDataRefreshed event, Emitter<HomeState> emit) async {
    await runBlocCatching(handleLoading: false, action: () => _loadHomeData(emit));
  }

  Future<void> _loadHomeData(Emitter<HomeState> emit) async {
    final now = DateTime.now();

    /// Get user default currency and set to app state
    final userDefaultCurrencyOutput = await _getUserDefaultCurrencyUseCase.execute(
      const GetUserDefaultCurrencyInput(),
    );

    appBloc.add(UserDefaultCurrencyUpdated(newCurrency: userDefaultCurrencyOutput.currency));

    final monthSummaryStatsOutput = await _getMonthSummaryStatsUseCase.execute(
      GetMonthSummaryStatsInput(baseCurrency: userDefaultCurrencyOutput.currency.code),
    );

    final walletStatsOutput = await _getTopWalletStatsUseCase.execute(
      GetTopWalletStatsInput(
        targetMonth: now.month,
        targetYear: now.year,
        categoryType: CategoryType.expense,
      ),
    );

    final recentTransactionsOutput = await _getRecentTransactionsUseCase.execute(
      const GetRecentTransactionsInput(),
    );

    final totalBalance = await _totalBalanceInCurrency(userDefaultCurrencyOutput.currency.code);

    emit(
      state.copyWith(
        selectedDateTime: now,
        defaultCurrencyCode: userDefaultCurrencyOutput.currency.code,
        monthSummaryStats: monthSummaryStatsOutput.monthSummaryStats.reversed.toList(),
        walletStat: walletStatsOutput.walletStat,
        recentTransactions: recentTransactionsOutput.transactions,
        selectedCategoryType: CategoryType.expense,
        totalBalance: totalBalance,
      ),
    );
  }

  Future<void> _onHomeCategoryTypeSelected(
    HomeCategoryTypeSelected event,
    Emitter<HomeState> emit,
  ) async {
    await runBlocCatching(
      handleLoading: false,
      action: () async {
        if (event.categoryType == state.selectedCategoryType) {
          return;
        }

        final now = DateTime.now();

        final walletStatsOutput = await _getTopWalletStatsUseCase.execute(
          GetTopWalletStatsInput(
            targetMonth: now.month,
            targetYear: now.year,
            categoryType: event.categoryType,
          ),
        );

        emit(
          state.copyWith(
            walletStat: walletStatsOutput.walletStat,
            selectedCategoryType: event.categoryType,
          ),
        );
      },
    );
  }

  Future<void> _onHomeCurrencySelected(HomeCurrencySelected event, Emitter<HomeState> emit) async {
    if (event.currencyCode == state.defaultCurrencyCode) {
      return;
    }

    /// Init already loaded summary; this event only stamps the currency code.
    if (state.defaultCurrencyCode.isEmpty) {
      emit(state.copyWith(defaultCurrencyCode: event.currencyCode));
      return;
    }

    await runBlocCatching(
      handleLoading: false,
      action: () async {
        final monthSummaryStatsOutput = await _getMonthSummaryStatsUseCase.execute(
          GetMonthSummaryStatsInput(baseCurrency: event.currencyCode),
        );
        final totalBalance = await _totalBalanceInCurrency(event.currencyCode);
        final currency = appBloc.state.currencies.where((c) => c.code == event.currencyCode);
        appBloc.add(
          UserDefaultCurrencyUpdated(
            newCurrency: currency.isNotEmpty ? currency.first : Currency(code: event.currencyCode),
            persist: true,
          ),
        );

        emit(
          state.copyWith(
            defaultCurrencyCode: event.currencyCode,
            monthSummaryStats: monthSummaryStatsOutput.monthSummaryStats.reversed.toList(),
            totalBalance: totalBalance,
          ),
        );
      },
    );
  }

  Future<void> _onHomeBalanceRecalculated(
    HomeBalanceRecalculated event,
    Emitter<HomeState> emit,
  ) async {
    await runBlocCatching(
      handleLoading: false,
      action: () async {
        final currencyCode =
            state.defaultCurrencyCode.isNotEmpty
                ? state.defaultCurrencyCode
                : appBloc.state.userDefaultCurrency.code;
        final totalBalance = await _totalBalanceInCurrency(currencyCode);
        emit(state.copyWith(totalBalance: totalBalance));
      },
    );
  }

  Future<double> _totalBalanceInCurrency(String currencyCode) async {
    final wallets = appBloc.state.wallets;
    if (wallets.isEmpty || currencyCode.isEmpty) {
      return 0;
    }

    final output = await _convertAmountsToCurrencyUseCase.execute(
      ConvertAmountsToCurrencyInput(
        targetCurrencyCode: currencyCode,
        amounts:
            wallets
                .map(
                  (wallet) =>
                      AmountInCurrency(amount: wallet.amount, currencyCode: wallet.currencyCode),
                )
                .toList(),
      ),
    );

    return output.total;
  }
}
