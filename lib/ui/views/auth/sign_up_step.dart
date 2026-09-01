/// Sign-up steps for [SignUpTab] in [LoginView].
enum SignUpStep {
  emailConfirm(1),
  otpConfirm(2),
  signingUp(3),
  signUpComplete(4);

  const SignUpStep(this.step);

  final int step;
}
