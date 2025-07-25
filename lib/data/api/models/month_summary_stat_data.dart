import 'package:freezed_annotation/freezed_annotation.dart';

part 'month_summary_stat_data.freezed.dart';
part 'month_summary_stat_data.g.dart';

@freezed
sealed class MonthSummaryStatData with _$MonthSummaryStatData {
  const factory MonthSummaryStatData({
    @JsonKey(name: 'total_income') double? totalIncome,
    @JsonKey(name: 'total_expense') double? totalExpense,
    @JsonKey(name: 'target_month') String? targetMonth,
  }) = _MonthSummaryStatData;

  factory MonthSummaryStatData.fromJson(Map<String, dynamic> json) =>
      _$MonthSummaryStatDataFromJson(json);
}
