part of 'app_bloc.dart';

@freezed
class AppState extends BaseBlocState with _$AppState {
  const AppState._();
  
  const factory AppState() = _AppState;
}
