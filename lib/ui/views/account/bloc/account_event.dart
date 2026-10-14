part of 'account_bloc.dart';

sealed class AccountEvent extends BaseBlocEvent {
  const AccountEvent();
}

@freezed
sealed class AccountViewInitiated extends AccountEvent with _$AccountViewInitiated {
  const AccountViewInitiated._();

  const factory AccountViewInitiated() = _AccountViewInitiated;
}

@freezed
sealed class AccountBiometricLoginToggled extends AccountEvent with _$AccountBiometricLoginToggled {
  const AccountBiometricLoginToggled._();

  const factory AccountBiometricLoginToggled({required bool enabled, String? password}) =
      _AccountBiometricLoginToggled;

  @override
  String toString() =>
      'AccountBiometricLoginToggled(enabled: $enabled, password: ${LogRedactor.placeholder})';
}
