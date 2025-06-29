part of 'app_bloc.dart';

sealed class AppEvent extends BaseBlocEvent {
  const AppEvent();
}

@freezed
sealed class SignOutButtonPressed extends AppEvent with _$SignOutButtonPressed {
  const SignOutButtonPressed._();

  const factory SignOutButtonPressed() = _SignOutButtonPressed;
}
