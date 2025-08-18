part of 'account_bloc.dart';

sealed class AccountEvent extends BaseBlocEvent {
  const AccountEvent();
}

@freezed
sealed class AccountViewInitiated extends AccountEvent with _$AccountViewInitiated {
  const AccountViewInitiated._();

  const factory AccountViewInitiated() = _AccountViewInitiated;
}
