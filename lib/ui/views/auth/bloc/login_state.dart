part of 'login_bloc.dart';

@freezed
sealed class LoginState extends BaseBlocState with _$LoginState {
  const LoginState._();

  const factory LoginState({
    @Default('') String email,
    @Default('') String password,
    @Default(false) bool isEnableLoginButton,
    @Default('') String emailError,
    @Default('') String passwordError,
    @Default('') String signUpEmail,
    @Default('') String signUpEmailError,
    @Default('') String otp,
    @Default('') String otpError,
    @Default('') String signUpPassword,
    @Default('') String signUpPasswordError,
    @Default('') String signUpConfirmPassword,
    @Default('') String signUpConfirmPasswordError,
    @Default(false) bool isEnableConfirmEmailSignUpButton,
    @Default(false) bool isEnableConfirmOtpSignUpButton,
    @Default(false) bool isEnableSignUpButton,
    @Default(SignUpStep.emailConfirm) SignUpStep signUpStep,
    @Default(0) int remainingSecondsForReSendOtp,
    @Default(false) bool isCheckedAcceptTerms,
  }) = _LoginState;
}
