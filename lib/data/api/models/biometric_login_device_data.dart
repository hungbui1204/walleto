import 'package:freezed_annotation/freezed_annotation.dart';

part 'biometric_login_device_data.freezed.dart';
part 'biometric_login_device_data.g.dart';

@freezed
sealed class BiometricLoginDeviceData with _$BiometricLoginDeviceData {
  const factory BiometricLoginDeviceData({
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'installation_id') String? installationId,
    @JsonKey(name: 'enabled') bool? enabled,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _BiometricLoginDeviceData;

  factory BiometricLoginDeviceData.fromJson(Map<String, dynamic> json) =>
      _$BiometricLoginDeviceDataFromJson(json);
}
