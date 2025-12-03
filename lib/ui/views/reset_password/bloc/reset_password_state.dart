part of 'reset_password_bloc.dart';

@freezed
sealed class ResetPasswordState extends BaseBlocState with _$ResetPasswordState {
  const ResetPasswordState._();
  const factory ResetPasswordState({
    @Default('') String email,
    @Default('') String emailError,
    @Default('') String otp,
    @Default('') String otpError,
    @Default('') String password,
    @Default('') String passwordError,
    @Default('') String confirmPassword,
    @Default('') String confirmPasswordError,
    @Default(false) bool isEnableConfirmEmailButton,
    @Default(false) bool isEnableConfirmOtpButton,
    @Default(false) bool isEnableResetPasswordButton,
    @Default(ResetPasswordStep.emailConfirm) ResetPasswordStep resetPasswordStep,
    @Default(0) int remainingSecondsForReSendOtp,
  }) = _ResetPasswordState;
}
