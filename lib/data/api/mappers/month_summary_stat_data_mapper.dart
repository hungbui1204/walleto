import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class MonthSummaryStatDataMapper extends BaseDataMapper<MonthSummaryStatData, MonthSummaryStat> {
  const MonthSummaryStatDataMapper(this._targetMonthDataMapper);

  final TargetMonthDataMapper _targetMonthDataMapper;

  @override
  MonthSummaryStat mapToEntity(MonthSummaryStatData? data) {
    return MonthSummaryStat(
      totalIncome: data?.totalIncome ?? 0,
      totalExpense: data?.totalExpense ?? 0,
      targetMonth: _targetMonthDataMapper.mapToEntity(data?.targetMonth),
    );
  }
}
