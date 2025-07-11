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
  AppBloc(this._signOutUseCase, this._getWalletsUseCase) : super(const AppState()) {
    on<SignOutButtonPressed>(_onSignOutButtonPressed);
    on<DataFetched>(_onDataFetched);
  }

  final SignOutUseCase _signOutUseCase;
  final GetWalletsUseCase _getWalletsUseCase;

  Future<void> _onSignOutButtonPressed(SignOutButtonPressed event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        await _signOutUseCase.execute(const SignOutInput());
      },
    );
  }

  Future<void> _onDataFetched(DataFetched event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        final wallets = await _getWalletsUseCase.execute(const GetWalletsInput());

        emit(state.copyWith(wallets: wallets.wallets));
      },
    );
  }
}
