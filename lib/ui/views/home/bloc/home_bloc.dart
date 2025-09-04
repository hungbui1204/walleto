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
    this._getCategoryStatsUseCase,
    this._getRecentTransactionsUseCase,
  ) : super(const HomeState()) {
    on<HomeViewInitialized>(_onHomeViewInitialized);
  }

  final GetMonthSummaryStatsUseCase _getMonthSummaryStatsUseCase;
  final GetCategoryStatsUseCase _getCategoryStatsUseCase;
  final GetRecentTransactionsUseCase _getRecentTransactionsUseCase;

  Future<void> _onHomeViewInitialized(HomeViewInitialized event, Emitter<HomeState> emit) async {
    await runBlocCatching(
      action: () async {
        final now = DateTime.now();

        emit(state.copyWith(selectedDateTime: now));

        final monthSummaryStatsOutput = await _getMonthSummaryStatsUseCase.execute(
          const GetMonthSummaryStatsInput(),
        );

        final categoryStatsOutput = await _getCategoryStatsUseCase.execute(
          GetCategoryStatsInput(
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
            categoryStats: categoryStatsOutput.stats,
            recentTransactions: recentTransactionsOutput.transactions,
          ),
        );
      },
    );
  }
}
