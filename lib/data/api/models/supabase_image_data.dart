import 'package:freezed_annotation/freezed_annotation.dart';

part 'supabase_image_data.freezed.dart';
part 'supabase_image_data.g.dart';

@freezed
sealed class SupabaseImageData with _$SupabaseImageData {
  const factory SupabaseImageData({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _SupabaseImageData;

  factory SupabaseImageData.fromJson(Map<String, dynamic> json) =>
      _$SupabaseImageDataFromJson(json);
}
