import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'verify_otp_for_email_use_case.freezed.dart';

@injectable
class VerifyOtpForEmailUseCase
    extends BaseFutureUseCase<VerifyOtpForEmailInput, VerifyOtpForEmailOutput> {
  const VerifyOtpForEmailUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<VerifyOtpForEmailOutput> buildUseCase(VerifyOtpForEmailInput input) async {
    await _repository.verifyOtpForEmail(email: input.email, otp: input.otp);

    return const VerifyOtpForEmailOutput();
  }
}

@freezed
sealed class VerifyOtpForEmailInput extends BaseInput with _$VerifyOtpForEmailInput {
  const VerifyOtpForEmailInput._();

  const factory VerifyOtpForEmailInput({required String email, required String otp}) =
      _VerifyOtpForEmailInput;
}

@freezed
sealed class VerifyOtpForEmailOutput extends BaseOutput with _$VerifyOtpForEmailOutput {
  const VerifyOtpForEmailOutput._();

  const factory VerifyOtpForEmailOutput() = _VerifyOtpForEmailOutput;
}
