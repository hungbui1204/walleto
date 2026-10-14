import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

part 'load_initial_resource_use_case.freezed.dart';

@injectable
class LoadInitialResourceUseCase
    extends BaseFutureUseCase<LoadInitialResourceInput, LoadInitialResourceOutput> {
  const LoadInitialResourceUseCase(this._repository, this._refreshTokenManager);

  final Repository _repository;
  final RefreshTokenManager _refreshTokenManager;

  @protected
  @override
  Future<LoadInitialResourceOutput> buildUseCase(LoadInitialResourceInput input) async {
    if (!await _refreshTokenManager.ensureFreshSession()) {
      return const LoadInitialResourceOutput(initialRoutes: [InitialAppRoute.login]);
    }

    var wallets = <Wallet>[];
    try {
      wallets = await _repository.getWallets();
    } on RemoteException catch (error) {
      if (error.kind != RemoteExceptionKind.invalidToken) rethrow;

      // A request may race with expiry after the initial preflight; refresh once, then retry once.
      await _refreshTokenManager.refreshToken();
      wallets = await _repository.getWallets();
    }

    if (wallets.isEmpty) {
      return const LoadInitialResourceOutput(initialRoutes: [InitialAppRoute.createWallet]);
    }

    return const LoadInitialResourceOutput();
  }
}

@freezed
sealed class LoadInitialResourceInput extends BaseInput with _$LoadInitialResourceInput {
  const LoadInitialResourceInput._();

  const factory LoadInitialResourceInput() = _LoadInitialResourceInput;
}

@freezed
sealed class LoadInitialResourceOutput extends BaseOutput with _$LoadInitialResourceOutput {
  const LoadInitialResourceOutput._();

  const factory LoadInitialResourceOutput({
    @Default([InitialAppRoute.main]) List<InitialAppRoute> initialRoutes,
  }) = _LoadInitialResourceOutput;
}
