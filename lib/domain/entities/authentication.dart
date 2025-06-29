import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'authentication.freezed.dart';

@freezed
sealed class Authentication with _$Authentication {
  const factory Authentication({
    @Default('') String accessToken,
    @Default('') String refreshToken,
    @Default(0) int expiresIn,
    DateTime? expiresAt,
    @Default(User()) User user,
  }) = _Authentication;
}
