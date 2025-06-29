import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
sealed class User with _$User {
  const factory User({
    @Default('') String id,
    @Default('') String email,
    @Default('') String fullName,
    @Default('') String phoneNumber,
    @Default('') String avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;
}
