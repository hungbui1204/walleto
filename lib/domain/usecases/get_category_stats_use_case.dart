import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_category_stats_use_case.freezed.dart';

@injectable
class GetCategoryStatsUseCase
    extends BaseFutureUseCase<GetCategoryStatsInput, GetCategoryStatsOutput> {
  const GetCategoryStatsUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetCategoryStatsOutput> buildUseCase(GetCategoryStatsInput input) async {
    final stats = await _repository.getCategoryStats(
      targetMonth: input.targetMonth,
      targetYear: input.targetYear,
      categoryType: input.categoryType,
    );

    return GetCategoryStatsOutput(stats: stats);
  }
}

@freezed
sealed class GetCategoryStatsInput extends BaseInput with _$GetCategoryStatsInput {
  const GetCategoryStatsInput._();

  const factory GetCategoryStatsInput({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  }) = _GetCategoryStatsInput;
}

@freezed
sealed class GetCategoryStatsOutput extends BaseOutput with _$GetCategoryStatsOutput {
  const GetCategoryStatsOutput._();

  const factory GetCategoryStatsOutput({@Default(<CategoryStat>[]) List<CategoryStat> stats}) =
      _GetCategoryStatsOutput;
}
