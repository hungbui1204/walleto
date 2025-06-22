import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'common_bloc.freezed.dart';
part 'common_event.dart';
part 'common_state.dart';

@injectable
class CommonBloc extends BaseBloc<CommonEvent, CommonState> {
  CommonBloc(this._signOutUseCase) : super(const CommonState()) {
    on<LoadingVisibilityEmitted>(_onLoadingVisibilityEmitted, transformer: log());
    on<ExceptionEmitted>(_onExceptionEmitted, transformer: log());
    on<ForceLogoutButtonPressed>(_onForceLogoutButtonPressed, transformer: log());
  }

  final SignOutUseCase _signOutUseCase;

  FutureOr<void> _onLoadingVisibilityEmitted(
    LoadingVisibilityEmitted event,
    Emitter<CommonState> emit,
  ) {
    emit(
      state.copyWith(
        isLoading:
            state.loadingCount == 0 && event.isLoading
                ? true
                : state.loadingCount == 1 && !event.isLoading || state.loadingCount <= 0
                ? false
                : state.isLoading,
        loadingCount: event.isLoading ? state.loadingCount + 1 : state.loadingCount - 1,
      ),
    );
  }

  FutureOr<void> _onExceptionEmitted(ExceptionEmitted event, Emitter<CommonState> emit) {
    emit(state.copyWith(appExceptionWrapper: event.appExceptionWrapper));
  }

  FutureOr<void> _onForceLogoutButtonPressed(
    ForceLogoutButtonPressed event,
    Emitter<CommonState> emit,
  ) {
    return runBlocCatching(
      action: () async {
        await _signOutUseCase.execute(const SignOutInput());
      },
    );
  }
}
