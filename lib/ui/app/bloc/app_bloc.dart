import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'app_event.dart';
part 'app_state.dart';
part 'app_bloc.freezed.dart';

@lazySingleton
class AppBloc extends BaseBloc<AppEvent, AppState> {
  AppBloc(this._signOutUseCase) : super(const AppState()) {
    on<SignOutButtonPressed>(_onSignOutButtonPressed);
  }

  final SignOutUseCase _signOutUseCase;

  Future<void> _onSignOutButtonPressed(SignOutButtonPressed event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        await _signOutUseCase.execute(const SignOutInput());
      },
    );
  }
}
