import 'package:freezed_annotation/freezed_annotation.dart';

part 'biometric_login_status.freezed.dart';

@freezed
sealed class BiometricLoginStatus with _$BiometricLoginStatus {
  const factory BiometricLoginStatus({
    @Default(false) bool isAvailable,
    @Default(false) bool isEnabled,
    @Default(false) bool hasStoredSession,
  }) = _BiometricLoginStatus;
}
