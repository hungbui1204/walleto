import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_month_summary_stats_use_case.freezed.dart';

@injectable
class GetMonthSummaryStatsUseCase
    extends BaseFutureUseCase<GetMonthSummaryStatsInput, GetMonthSummaryStatsOutput> {
  const GetMonthSummaryStatsUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetMonthSummaryStatsOutput> buildUseCase(GetMonthSummaryStatsInput input) async {
    final monthSummaryStats = await _repository.getMonthSummaryStats(
      baseCurrency: input.baseCurrency,
    );

    return GetMonthSummaryStatsOutput(monthSummaryStats: monthSummaryStats);
  }
}

@freezed
sealed class GetMonthSummaryStatsInput extends BaseInput with _$GetMonthSummaryStatsInput {
  const GetMonthSummaryStatsInput._();

  const factory GetMonthSummaryStatsInput({String? baseCurrency}) = _GetMonthSummaryStatsInput;
}

@freezed
sealed class GetMonthSummaryStatsOutput extends BaseOutput with _$GetMonthSummaryStatsOutput {
  const GetMonthSummaryStatsOutput._();

  const factory GetMonthSummaryStatsOutput({
    @Default(<MonthSummaryStat>[]) List<MonthSummaryStat> monthSummaryStats,
  }) = _GetMonthSummaryStatsOutput;
}
