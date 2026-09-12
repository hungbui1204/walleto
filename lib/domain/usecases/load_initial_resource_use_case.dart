import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'load_initial_resource_use_case.freezed.dart';

@injectable
class LoadInitialResourceUseCase
    extends BaseFutureUseCase<LoadInitialResourceInput, LoadInitialResourceOutput> {
  const LoadInitialResourceUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<LoadInitialResourceOutput> buildUseCase(LoadInitialResourceInput input) async {
    if (!await _repository.isLoggedIn) {
      return const LoadInitialResourceOutput(initialRoutes: [InitialAppRoute.login]);
    }

    try {
      final wallets = await _repository.getWallets();
      if (wallets.isEmpty) {
        return const LoadInitialResourceOutput(initialRoutes: [InitialAppRoute.createWallet]);
      }
    } catch (_) {
      /// Network/auth errors should not block Main; UI still guards empty wallets.
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
