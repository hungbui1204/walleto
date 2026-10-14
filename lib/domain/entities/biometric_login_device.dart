import 'package:freezed_annotation/freezed_annotation.dart';

part 'biometric_login_device.freezed.dart';

@freezed
sealed class BiometricLoginDevice with _$BiometricLoginDevice {
  const factory BiometricLoginDevice({
    @Default('') String userId,
    @Default('') String installationId,
    @Default(false) bool enabled,
    DateTime? updatedAt,
  }) = _BiometricLoginDevice;
}
