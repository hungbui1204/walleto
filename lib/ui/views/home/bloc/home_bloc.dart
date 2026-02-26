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
  ) : super(const HomeState()) {
    on<HomeViewInitialized>(_onHomeViewInitialized);
    on<HomeCategoryTypeSelected>(_onHomeCategoryTypeSelected);
  }

  final GetMonthSummaryStatsUseCase _getMonthSummaryStatsUseCase;
  final GetWalletStatsUseCase _getWalletStatsUseCase;
  final GetTopWalletStatsUseCase _getTopWalletStatsUseCase;
  final GetRecentTransactionsUseCase _getRecentTransactionsUseCase;

  Future<void> _onHomeViewInitialized(HomeViewInitialized event, Emitter<HomeState> emit) async {
    await runBlocCatching(
      action: () async {
        final now = DateTime.now();

        emit(state.copyWith(selectedDateTime: now));

        final monthSummaryStatsOutput = await _getMonthSummaryStatsUseCase.execute(
          const GetMonthSummaryStatsInput(),
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
}
