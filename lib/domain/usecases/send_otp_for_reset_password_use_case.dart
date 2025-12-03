import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'send_otp_for_reset_password_use_case.freezed.dart';

@injectable
class SendOtpForResetPasswordUseCase
    extends BaseFutureUseCase<SendOtpForResetPasswordInput, SendOtpForResetPasswordOutput> {
  const SendOtpForResetPasswordUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<SendOtpForResetPasswordOutput> buildUseCase(SendOtpForResetPasswordInput input) async {
    await _repository.sendOtpForResetPassword(email: input.email);

    return const SendOtpForResetPasswordOutput();
  }
}

@freezed
sealed class SendOtpForResetPasswordInput extends BaseInput with _$SendOtpForResetPasswordInput {
  const SendOtpForResetPasswordInput._();

  const factory SendOtpForResetPasswordInput({required String email}) =
      _SendOtpForResetPasswordInput;
}

@freezed
sealed class SendOtpForResetPasswordOutput extends BaseOutput with _$SendOtpForResetPasswordOutput {
  const SendOtpForResetPasswordOutput._();

  const factory SendOtpForResetPasswordOutput() = _SendOtpForResetPasswordOutput;
}
