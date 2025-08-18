part of 'account_bloc.dart';

@freezed
sealed class AccountState extends BaseBlocState with _$AccountState {
  const AccountState._();

  const factory AccountState({@Default(User()) User user}) = _AccountState;
}
