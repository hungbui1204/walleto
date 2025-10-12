import 'package:freezed_annotation/freezed_annotation.dart';

part 'supabase_image.freezed.dart';

@freezed
sealed class SupabaseImage with _$SupabaseImage {
  const factory SupabaseImage({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? url,
  }) = _SupabaseImage;
}
