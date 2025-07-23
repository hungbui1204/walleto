part of 'home_bloc.dart';

sealed class HomeEvent extends BaseBlocEvent {
  const HomeEvent();
}

@freezed
sealed class HomeViewInitialized extends HomeEvent with _$HomeViewInitialized {
  const HomeViewInitialized._();
  const factory HomeViewInitialized() = _HomeViewInitialized;
}
