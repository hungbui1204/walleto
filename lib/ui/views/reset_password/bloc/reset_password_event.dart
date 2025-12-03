part of 'reset_password_bloc.dart';

sealed class ResetPasswordEvent extends BaseBlocEvent {
  const ResetPasswordEvent();
}

@freezed
sealed class ResetPasswordConfirmEmailButtonPressed extends ResetPasswordEvent
    with _$ResetPasswordConfirmEmailButtonPressed {
  const ResetPasswordConfirmEmailButtonPressed._();
  const factory ResetPasswordConfirmEmailButtonPressed() = _ResetPasswordConfirmEmailButtonPressed;
}

@freezed
sealed class ResetPasswordConfirmOtpButtonPressed extends ResetPasswordEvent
    with _$ResetPasswordConfirmOtpButtonPressed {
  const ResetPasswordConfirmOtpButtonPressed._();
  const factory ResetPasswordConfirmOtpButtonPressed() = _ResetPasswordConfirmOtpButtonPressed;
}

@freezed
sealed class ResetPasswordButtonPressed extends ResetPasswordEvent
    with _$ResetPasswordButtonPressed {
  const ResetPasswordButtonPressed._();
  const factory ResetPasswordButtonPressed() = _ResetPasswordButtonPressed;
}

@freezed
sealed class ResetPasswordEmailInputChanged extends ResetPasswordEvent
    with _$ResetPasswordEmailInputChanged {
  const ResetPasswordEmailInputChanged._();
  const factory ResetPasswordEmailInputChanged({required String email}) =
      _ResetPasswordEmailInputChanged;
}

@freezed
sealed class ResetPasswordPasswordInputChanged extends ResetPasswordEvent
    with _$ResetPasswordPasswordInputChanged {
  const ResetPasswordPasswordInputChanged._();
  const factory ResetPasswordPasswordInputChanged({required String password}) =
      _ResetPasswordPasswordInputChanged;
}

@freezed
sealed class ResetPasswordConfirmPasswordInputChanged extends ResetPasswordEvent
    with _$ResetPasswordConfirmPasswordInputChanged {
  const ResetPasswordConfirmPasswordInputChanged._();
  const factory ResetPasswordConfirmPasswordInputChanged({required String confirmPassword}) =
      _ResetPasswordConfirmPasswordInputChanged;
}

@freezed
sealed class ResetPasswordOtpInputChanged extends ResetPasswordEvent
    with _$ResetPasswordOtpInputChanged {
  const ResetPasswordOtpInputChanged._();
  const factory ResetPasswordOtpInputChanged({required String otp}) = _ResetPasswordOtpInputChanged;
}

@freezed
sealed class ResetPasswordBackToPreviousStepButtonPressed extends ResetPasswordEvent
    with _$ResetPasswordBackToPreviousStepButtonPressed {
  const ResetPasswordBackToPreviousStepButtonPressed._();
  const factory ResetPasswordBackToPreviousStepButtonPressed() =
      _ResetPasswordBackToPreviousStepButtonPressed;
}

@freezed
sealed class ResetPasswordRemainingSecondsForReSendOtpChanged extends ResetPasswordEvent
    with _$ResetPasswordRemainingSecondsForReSendOtpChanged {
  const ResetPasswordRemainingSecondsForReSendOtpChanged._();
  const factory ResetPasswordRemainingSecondsForReSendOtpChanged({required int seconds}) =
      _ResetPasswordRemainingSecondsForReSendOtpChanged;
}

@freezed
sealed class ResetPasswordResendOtpButtonPressed extends ResetPasswordEvent
    with _$ResetPasswordResendOtpButtonPressed {
  const ResetPasswordResendOtpButtonPressed._();
  const factory ResetPasswordResendOtpButtonPressed() = _ResetPasswordResendOtpButtonPressed;
}
