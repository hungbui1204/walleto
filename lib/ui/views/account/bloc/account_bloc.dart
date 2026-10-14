import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'account_event.dart';
part 'account_state.dart';
part 'account_bloc.freezed.dart';

@injectable
class AccountBloc extends BaseBloc<AccountEvent, AccountState> {
  AccountBloc(
    this._getUserInfoUseCase,
    this._getBiometricLoginStatusUseCase,
    this._setBiometricLoginEnabledUseCase,
  ) : super(const AccountState()) {
    on<AccountViewInitiated>(_onAccountViewInitiated, transformer: log());
    on<AccountBiometricLoginToggled>(_onBiometricLoginToggled, transformer: log());
  }

  final GetUserInfoUseCase _getUserInfoUseCase;
  final GetBiometricLoginStatusUseCase _getBiometricLoginStatusUseCase;
  final SetBiometricLoginEnabledUseCase _setBiometricLoginEnabledUseCase;

  Future<void> _onAccountViewInitiated(
    AccountViewInitiated event,
    Emitter<AccountState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final userInfoOutput = await _getUserInfoUseCase.execute(const GetUserInfoInput());
        final biometricStatusOutput = await _getBiometricLoginStatusUseCase.execute(
          GetBiometricLoginStatusInput(userId: userInfoOutput.user.id, verifyServer: true),
        );

        emit(
          state.copyWith(
            user: userInfoOutput.user,
            biometricLoginStatus: biometricStatusOutput.status,
          ),
        );
      },
    );
  }

  Future<void> _onBiometricLoginToggled(
    AccountBiometricLoginToggled event,
    Emitter<AccountState> emit,
  ) async {
    if (state.isBiometricLoginUpdating) return;

    emit(state.copyWith(isBiometricLoginUpdating: true));
    await runBlocCatching(
      action: () async {
        await _setBiometricLoginEnabledUseCase.execute(
          SetBiometricLoginEnabledInput(
            userId: state.user.id,
            enabled: event.enabled,
            password: event.password,
          ),
        );
        final biometricStatusOutput = await _getBiometricLoginStatusUseCase.execute(
          GetBiometricLoginStatusInput(userId: state.user.id, verifyServer: true),
        );
        emit(state.copyWith(biometricLoginStatus: biometricStatusOutput.status));
      },
      doOnSuccessOrError: () async {
        emit(state.copyWith(isBiometricLoginUpdating: false));
      },
    );
  }
}
