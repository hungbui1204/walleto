part of 'main_bloc.dart';

sealed class MainEvent extends BaseBlocEvent {
  const MainEvent();
}

@freezed
sealed class MainViewInitiated extends MainEvent with _$MainViewInitiated {
  const MainViewInitiated._();

  const factory MainViewInitiated() = _MainViewInitiated;
}
