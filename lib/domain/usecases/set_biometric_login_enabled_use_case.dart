import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

part 'set_biometric_login_enabled_use_case.freezed.dart';

@injectable
class SetBiometricLoginEnabledUseCase
    extends BaseFutureUseCase<SetBiometricLoginEnabledInput, SetBiometricLoginEnabledOutput> {
  const SetBiometricLoginEnabledUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<SetBiometricLoginEnabledOutput> buildUseCase(SetBiometricLoginEnabledInput input) async {
    await _repository.setBiometricLoginEnabled(
      userId: input.userId,
      enabled: input.enabled,
      password: input.password,
    );
    return const SetBiometricLoginEnabledOutput();
  }
}

@freezed
sealed class SetBiometricLoginEnabledInput extends BaseInput with _$SetBiometricLoginEnabledInput {
  const SetBiometricLoginEnabledInput._();

  const factory SetBiometricLoginEnabledInput({
    required String userId,
    required bool enabled,
    String? password,
  }) = _SetBiometricLoginEnabledInput;

  @override
  String toString() =>
      'SetBiometricLoginEnabledInput(userId: $userId, enabled: $enabled, '
      'password: ${LogRedactor.placeholder})';
}

@freezed
sealed class SetBiometricLoginEnabledOutput extends BaseOutput
    with _$SetBiometricLoginEnabledOutput {
  const SetBiometricLoginEnabledOutput._();

  const factory SetBiometricLoginEnabledOutput() = _SetBiometricLoginEnabledOutput;
}
