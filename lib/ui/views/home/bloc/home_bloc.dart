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
    this._getWalletStatsUseCase,
    this._getRecentTransactionsUseCase,
    this._getTopWalletStatsUseCase,
    this._getUserDefaultCurrencyUseCase,
  ) : super(const HomeState()) {
    on<HomeViewInitialized>(_onHomeViewInitialized, transformer: log());
    on<HomeCategoryTypeSelected>(_onHomeCategoryTypeSelected, transformer: log());
    on<HomeCurrencySelected>(_onHomeCurrencySelected, transformer: log());
  }

  final GetMonthSummaryStatsUseCase _getMonthSummaryStatsUseCase;
  final GetWalletStatsUseCase _getWalletStatsUseCase;
  final GetTopWalletStatsUseCase _getTopWalletStatsUseCase;
  final GetRecentTransactionsUseCase _getRecentTransactionsUseCase;
  final GetUserDefaultCurrencyUseCase _getUserDefaultCurrencyUseCase;

  Future<void> _onHomeViewInitialized(HomeViewInitialized event, Emitter<HomeState> emit) async {
    await runBlocCatching(
      action: () async {
        final now = DateTime.now();
        emit(state.copyWith(selectedDateTime: now));

        /// Get user default currency and set to app state
        final userDefaultCurrencyOutput = await _getUserDefaultCurrencyUseCase.execute(
          const GetUserDefaultCurrencyInput(),
        );

        appBloc.add(UserDefaultCurrencyUpdated(newCurrency: userDefaultCurrencyOutput.currency));

        /// Default currency is current user base currency from app state, which is used to get month summary stats.
        add(HomeCurrencySelected(currencyCode: appBloc.state.userDefaultCurrency.code));

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

        emit(
          state.copyWith(
            monthSummaryStats: monthSummaryStatsOutput.monthSummaryStats.reversed.toList(),
            walletStat: walletStatsOutput.walletStat,
            recentTransactions: recentTransactionsOutput.transactions,
            selectedCategoryType: CategoryType.expense,
          ),
        );
      },
    );
  }

  Future<void> _onHomeCategoryTypeSelected(
    HomeCategoryTypeSelected event,
    Emitter<HomeState> emit,
  ) async {
    await runBlocCatching(
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

  void _onHomeCurrencySelected(HomeCurrencySelected event, Emitter<HomeState> emit) {
    if (event.currencyCode == state.defaultCurrencyCode) {
      return;
    }

    /// TODO: update month summary stats

    emit(state.copyWith(defaultCurrencyCode: event.currencyCode));
  }
}
