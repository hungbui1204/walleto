import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'verify_otp_for_reset_password_use_case.freezed.dart';

@injectable
class VerifyOtpForResetPasswordUseCase
    extends BaseFutureUseCase<VerifyOtpForResetPasswordInput, VerifyOtpForResetPasswordOutput> {
  const VerifyOtpForResetPasswordUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<VerifyOtpForResetPasswordOutput> buildUseCase(VerifyOtpForResetPasswordInput input) async {
    await _repository.verifyOtpForResetPassword(email: input.email, code: input.code);

    return const VerifyOtpForResetPasswordOutput();
  }
}

@freezed
sealed class VerifyOtpForResetPasswordInput extends BaseInput
    with _$VerifyOtpForResetPasswordInput {
  const VerifyOtpForResetPasswordInput._();

  const factory VerifyOtpForResetPasswordInput({required String email, required String code}) =
      _VerifyOtpForResetPasswordInput;
}

@freezed
sealed class VerifyOtpForResetPasswordOutput extends BaseOutput
    with _$VerifyOtpForResetPasswordOutput {
  const VerifyOtpForResetPasswordOutput._();

  const factory VerifyOtpForResetPasswordOutput() = _VerifyOtpForResetPasswordOutput;
}
