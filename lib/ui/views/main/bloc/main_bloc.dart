import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/ui/ui.dart';

part 'main_event.dart';
part 'main_state.dart';
part 'main_bloc.freezed.dart';

@injectable
class MainBloc extends BaseBloc<MainEvent, MainState> {
  MainBloc() : super(MainState()) {
    on<MainViewInitiated>(_onMainViewInitiated, transformer: log());
  }

  void _onMainViewInitiated(MainViewInitiated event, Emitter<MainState> emit) {
    LocalNotificationService.registerAndroidPushListeners();
  }
}
