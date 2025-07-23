import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_stat.freezed.dart';

@freezed
sealed class DailyStat with _$DailyStat {
  const factory DailyStat({
    @Default(0) double totalIncome,
    @Default(0) double totalExpense,
    DateTime? date,
  }) = _DailyStat;
}
