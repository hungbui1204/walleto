import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_out_result.freezed.dart';

@freezed
sealed class SignOutResult with _$SignOutResult {
  const factory SignOutResult({
    @Default(false) bool serverSessionRevoked,
    @Default(false) bool retainedForBiometric,
  }) = _SignOutResult;
}
