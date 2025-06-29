import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/data/data.dart';

part 'authentication_data.freezed.dart';
part 'authentication_data.g.dart';

@freezed
sealed class AuthenticationData with _$AuthenticationData {
  const factory AuthenticationData({
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'expires_in') int? expiresIn,
    @JsonKey(name: 'expires_at') int? expiresAt,
    @JsonKey(name: 'user') UserData? user,
  }) = _AuthenticationData;

  factory AuthenticationData.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationDataFromJson(json);
}
