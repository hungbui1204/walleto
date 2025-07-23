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
  HomeBloc(this._getDailyStatsUseCase) : super(const HomeState()) {
    on<HomeViewInitialized>(_onHomeViewInitialized);
  }

  final GetMonthStatUseCase _getDailyStatsUseCase;

  Future<void> _onHomeViewInitialized(HomeViewInitialized event, Emitter<HomeState> emit) async {
    await runBlocCatching(
      action: () async {
        final now = DateTime.now();

        final dailyStatsOutput = await _getDailyStatsUseCase.execute(
          GetMonthStatInput(targetMonth: now.month, targetYear: now.year),
        );

        emit(state.copyWith(monthStat: dailyStatsOutput.monthStat));
      },
    );
  }
}
