part of 'wallets_bloc.dart';

sealed class WalletsEvent extends BaseBlocEvent {
  const WalletsEvent();
}

@freezed
sealed class WalletsViewInitiated extends WalletsEvent with _$WalletsViewInitiated {
  const WalletsViewInitiated._();

  const factory WalletsViewInitiated() = _WalletsViewInitiated;
}
