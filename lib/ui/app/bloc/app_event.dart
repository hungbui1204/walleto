part of 'app_bloc.dart';

sealed class AppEvent extends BaseBlocEvent {
  const AppEvent();
}

@freezed
sealed class SignOutButtonPressed extends AppEvent with _$SignOutButtonPressed {
  const SignOutButtonPressed._();

  const factory SignOutButtonPressed() = _SignOutButtonPressed;
}

@freezed
sealed class DataFetched extends AppEvent with _$DataFetched {
  const DataFetched._();

  const factory DataFetched() = _DataFetched;
}
