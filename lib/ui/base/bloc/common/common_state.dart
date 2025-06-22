part of 'common_bloc.dart';

@freezed
sealed class CommonState extends BaseBlocState with _$CommonState {
  const CommonState._();

  const factory CommonState({
    AppExceptionWrapper? appExceptionWrapper,
    @Default(0) int loadingCount,
    @Default(false) bool isLoading,
  }) = _CommonState;
}
