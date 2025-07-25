import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'month_summary_stat.freezed.dart';

@freezed
sealed class MonthSummaryStat with _$MonthSummaryStat {
  const factory MonthSummaryStat({
    @Default(0) double totalIncome,
    @Default(0) double totalExpense,
    @Default(TargetMonth.current) TargetMonth targetMonth,
  }) = _MonthSummaryStat;
}
