/// Reset-password steps for [ResetPasswordView].
enum ResetPasswordStep {
  emailConfirm(1),
  otpConfirm(2),
  resettingPassword(3),
  resetPasswordComplete(4);

  const ResetPasswordStep(this.step);

  final int step;
}
