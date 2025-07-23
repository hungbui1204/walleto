import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_month_stat_use_case.freezed.dart';

@injectable
class GetMonthStatUseCase extends BaseFutureUseCase<GetMonthStatInput, GetMonthStatOutput> {
  const GetMonthStatUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetMonthStatOutput> buildUseCase(GetMonthStatInput input) async {
    final monthStat = await _repository.getMonthStat(
      targetMonth: input.targetMonth,
      targetYear: input.targetYear,
    );

    return GetMonthStatOutput(monthStat: monthStat);
  }
}

@freezed
sealed class GetMonthStatInput extends BaseInput with _$GetMonthStatInput {
  const GetMonthStatInput._();

  const factory GetMonthStatInput({required int targetMonth, required int targetYear}) =
      _GetMonthStatInput;
}

@freezed
sealed class GetMonthStatOutput extends BaseOutput with _$GetMonthStatOutput {
  const GetMonthStatOutput._();

  const factory GetMonthStatOutput({@Default(<DailyStat>[]) List<DailyStat> monthStat}) =
      _GetMonthStatOutput;
}
