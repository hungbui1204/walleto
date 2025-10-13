part of 'select_icon_bloc.dart';

@freezed
sealed class SelectIconState extends BaseBlocState with _$SelectIconState {
  const SelectIconState._();

  const factory SelectIconState({
    @Default(<SupabaseImage>[]) List<SupabaseImage> icons,
    @Default(true) bool isLoading,
  }) = _SelectIconState;
}
