import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_stat.freezed.dart';

@freezed
sealed class CategoryStat with _$CategoryStat {
  const factory CategoryStat({
    @Default(0) int categoryId,
    @Default('') String categoryName,
    @Default(0) double totalAmount,
    @Default('') String categoryIconUrl,
  }) = _CategoryStat;
}
