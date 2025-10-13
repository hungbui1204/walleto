part of 'select_icon_bloc.dart';

sealed class SelectIconEvent extends BaseBlocEvent {
  const SelectIconEvent();
}

@freezed
sealed class SelectIconViewInitialized extends SelectIconEvent with _$SelectIconViewInitialized {
  const SelectIconViewInitialized._();

  const factory SelectIconViewInitialized({required IconType iconType}) =
      _SelectIconViewInitialized;
}
