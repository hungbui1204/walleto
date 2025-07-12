import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_data.freezed.dart';
part 'category_data.g.dart';

@freezed
sealed class CategoryData with _$CategoryData {
  const factory CategoryData({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'is_parent') bool? isParent,
    @JsonKey(name: 'parent_id') int? parentId,
    @JsonKey(name: 'type') String? type,
  }) = _CategoryData;

  factory CategoryData.fromJson(Map<String, dynamic> json) => _$CategoryDataFromJson(json);
}
