import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_biometric_login_status_use_case.freezed.dart';

@injectable
class GetBiometricLoginStatusUseCase
    extends BaseFutureUseCase<GetBiometricLoginStatusInput, GetBiometricLoginStatusOutput> {
  const GetBiometricLoginStatusUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetBiometricLoginStatusOutput> buildUseCase(GetBiometricLoginStatusInput input) async {
    final status = await _repository.getBiometricLoginStatus(
      userId: input.userId,
      verifyServer: input.verifyServer,
    );
    return GetBiometricLoginStatusOutput(status: status);
  }
}

@freezed
sealed class GetBiometricLoginStatusInput extends BaseInput with _$GetBiometricLoginStatusInput {
  const GetBiometricLoginStatusInput._();

  const factory GetBiometricLoginStatusInput({String? userId, @Default(false) bool verifyServer}) =
      _GetBiometricLoginStatusInput;
}

@freezed
sealed class GetBiometricLoginStatusOutput extends BaseOutput with _$GetBiometricLoginStatusOutput {
  const GetBiometricLoginStatusOutput._();

  const factory GetBiometricLoginStatusOutput({
    @Default(BiometricLoginStatus()) BiometricLoginStatus status,
  }) = _GetBiometricLoginStatusOutput;
}
