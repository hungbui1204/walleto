import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_stat_data.freezed.dart';
part 'category_stat_data.g.dart';

@freezed
sealed class CategoryStatData with _$CategoryStatData {
  const factory CategoryStatData({
    @JsonKey(name: 'category_id') int? categoryId,
    @JsonKey(name: 'category_name') String? categoryName,
    @JsonKey(name: 'total_amount') double? totalAmount,
    @JsonKey(name: 'category_icon_url') String? categoryIconUrl,
  }) = _CategoryStatData;

  factory CategoryStatData.fromJson(Map<String, dynamic> json) => _$CategoryStatDataFromJson(json);
}
