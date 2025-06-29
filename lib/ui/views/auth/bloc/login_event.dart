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
}

@freezed
sealed class SignInButtonPressed extends LoginEvent with _$SignInButtonPressed {
  const SignInButtonPressed._();
  const factory SignInButtonPressed() = _SignInButtonPressed;
}
