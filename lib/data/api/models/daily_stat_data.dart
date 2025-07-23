import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_stat_data.freezed.dart';
part 'daily_stat_data.g.dart';

@freezed
sealed class DailyStatData with _$DailyStatData {
  const factory DailyStatData({
    @JsonKey(name: 'total_income') double? totalIncome,
    @JsonKey(name: 'total_expense') double? totalExpense,
    @JsonKey(name: 'date') String? date,
  }) = _DailyStatData;

  factory DailyStatData.fromJson(Map<String, dynamic> json) => _$DailyStatDataFromJson(json);
}
