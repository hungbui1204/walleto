part of 'login_bloc.dart';

sealed class LoginEvent extends BaseBlocEvent {
  const LoginEvent();
}

@freezed
sealed class LoginEmailInputChanged extends LoginEvent with _$LoginEmailInputChanged {
  const LoginEmailInputChanged._();
  const factory LoginEmailInputChanged({required String email}) = _LoginEmailInputChanged;
}

@freezed
sealed class LoginPasswordInputChanged extends LoginEvent with _$LoginPasswordInputChanged {
  const LoginPasswordInputChanged._();
  const factory LoginPasswordInputChanged({required String password}) = _LoginPasswordInputChanged;

  @override
  String toString() => 'LoginPasswordInputChanged(password: ${LogRedactor.placeholder})';
}

@freezed
sealed class SignInButtonPressed extends LoginEvent with _$SignInButtonPressed {
  const SignInButtonPressed._();
  const factory SignInButtonPressed() = _SignInButtonPressed;
}

@freezed
sealed class ConfirmEmailSignUpButtonPressed extends LoginEvent
    with _$ConfirmEmailSignUpButtonPressed {
  const ConfirmEmailSignUpButtonPressed._();
  const factory ConfirmEmailSignUpButtonPressed() = _ConfirmEmailSignUpButtonPressed;
}

@freezed
sealed class ConfirmOtpSignUpButtonPressed extends LoginEvent with _$ConfirmOtpSignUpButtonPressed {
  const ConfirmOtpSignUpButtonPressed._();
  const factory ConfirmOtpSignUpButtonPressed() = _ConfirmOtpSignUpButtonPressed;
}

@freezed
sealed class SignUpButtonPressed extends LoginEvent with _$SignUpButtonPressed {
  const SignUpButtonPressed._();
  const factory SignUpButtonPressed() = _SignUpButtonPressed;
}

@freezed
sealed class SignUpEmailInputChanged extends LoginEvent with _$SignUpEmailInputChanged {
  const SignUpEmailInputChanged._();
  const factory SignUpEmailInputChanged({required String email}) = _SignUpEmailInputChanged;
}

@freezed
sealed class SignUpPasswordInputChanged extends LoginEvent with _$SignUpPasswordInputChanged {
  const SignUpPasswordInputChanged._();
  const factory SignUpPasswordInputChanged({required String password}) =
      _SignUpPasswordInputChanged;

  @override
  String toString() => 'SignUpPasswordInputChanged(password: ${LogRedactor.placeholder})';
}

@freezed
sealed class SignUpConfirmPasswordInputChanged extends LoginEvent
    with _$SignUpConfirmPasswordInputChanged {
  const SignUpConfirmPasswordInputChanged._();
  const factory SignUpConfirmPasswordInputChanged({required String confirmPassword}) =
      _SignUpConfirmPasswordInputChanged;

  @override
  String toString() =>
      'SignUpConfirmPasswordInputChanged(confirmPassword: ${LogRedactor.placeholder})';
}

@freezed
sealed class SignUpOtpInputChanged extends LoginEvent with _$SignUpOtpInputChanged {
  const SignUpOtpInputChanged._();
  const factory SignUpOtpInputChanged({required String otp}) = _SignUpOtpInputChanged;
}

@freezed
sealed class SignUpBackToPreviousStepButtonPressed extends LoginEvent
    with _$SignUpBackToPreviousStepButtonPressed {
  const SignUpBackToPreviousStepButtonPressed._();
  const factory SignUpBackToPreviousStepButtonPressed() = _SignUpBackToPreviousStepButtonPressed;
}

@freezed
sealed class SignUpRemainingSecondsForReSendOtpChanged extends LoginEvent
    with _$SignUpRemainingSecondsForReSendOtpChanged {
  const SignUpRemainingSecondsForReSendOtpChanged._();
  const factory SignUpRemainingSecondsForReSendOtpChanged({required int seconds}) =
      _SignUpRemainingSecondsForReSendOtpChanged;
}

@freezed
sealed class SignUpResendOtpButtonPressed extends LoginEvent with _$SignUpResendOtpButtonPressed {
  const SignUpResendOtpButtonPressed._();
  const factory SignUpResendOtpButtonPressed() = _SignUpResendOtpButtonPressed;
}

@freezed
sealed class SignUpConfirmButtonPressed extends LoginEvent with _$SignUpConfirmButtonPressed {
  const SignUpConfirmButtonPressed._();
  const factory SignUpConfirmButtonPressed() = _SignUpConfirmButtonPressed;
}

@freezed
sealed class SignUpAcceptTermsCheckboxToggled extends LoginEvent
    with _$SignUpAcceptTermsCheckboxToggled {
  const SignUpAcceptTermsCheckboxToggled._();
  const factory SignUpAcceptTermsCheckboxToggled() = _SignUpAcceptTermsCheckboxToggled;
}
