import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'send_otp_for_email_checking_use_case.freezed.dart';

@injectable
class SendOtpForEmailCheckingUseCase
    extends BaseFutureUseCase<SendOtpForEmailCheckingInput, SendOtpForEmailCheckingOutput> {
  const SendOtpForEmailCheckingUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<SendOtpForEmailCheckingOutput> buildUseCase(SendOtpForEmailCheckingInput input) async {
    await _repository.sendOtpForEmailChecking(email: input.email);

    return const SendOtpForEmailCheckingOutput();
  }
}

@freezed
sealed class SendOtpForEmailCheckingInput extends BaseInput with _$SendOtpForEmailCheckingInput {
  const SendOtpForEmailCheckingInput._();

  const factory SendOtpForEmailCheckingInput({required String email}) =
      _SendOtpForEmailCheckingInput;
}

@freezed
sealed class SendOtpForEmailCheckingOutput extends BaseOutput with _$SendOtpForEmailCheckingOutput {
  const SendOtpForEmailCheckingOutput._();

  const factory SendOtpForEmailCheckingOutput() = _SendOtpForEmailCheckingOutput;
}
