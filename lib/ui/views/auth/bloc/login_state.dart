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
  }) = _LoginState;
}
