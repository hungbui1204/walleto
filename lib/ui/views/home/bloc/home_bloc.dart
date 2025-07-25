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
    this._getDailyStatsUseCase,
    this._getMonthSummaryStatsUseCase,
    this._getCategoryStatsUseCase,
  ) : super(const HomeState()) {
    on<HomeViewInitialized>(_onHomeViewInitialized);
  }

  final GetMonthStatUseCase _getDailyStatsUseCase;
  final GetMonthSummaryStatsUseCase _getMonthSummaryStatsUseCase;
  final GetCategoryStatsUseCase _getCategoryStatsUseCase;

  Future<void> _onHomeViewInitialized(HomeViewInitialized event, Emitter<HomeState> emit) async {
    await runBlocCatching(
      action: () async {
        final now = DateTime.now();

        emit(state.copyWith(selectedDateTime: now));

        // TODO: Uncomment when daily stats are needed
        // final dailyStatsOutput = await _getDailyStatsUseCase.execute(
        //   GetMonthStatInput(targetMonth: now.month, targetYear: now.year),
        // );

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

        emit(
          state.copyWith(
            // monthStat: dailyStatsOutput.monthStat,
            monthSummaryStats: monthSummaryStatsOutput.monthSummaryStats.reversed.toList(),
            categoryStats: categoryStatsOutput.stats,
          ),
        );
      },
    );
  }
}
