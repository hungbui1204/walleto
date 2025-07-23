import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class DailyStatDataMapper extends BaseDataMapper<DailyStatData, DailyStat> {
  const DailyStatDataMapper();

  @override
  DailyStat mapToEntity(DailyStatData? data) {
    return DailyStat(
      totalIncome: data?.totalIncome ?? 0,
      totalExpense: data?.totalExpense ?? 0,
      date: data?.date?.toDateTime(),
    );
  }
}
