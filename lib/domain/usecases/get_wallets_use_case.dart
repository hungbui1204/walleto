import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_wallets_use_case.freezed.dart';

@injectable
class GetWalletsUseCase extends BaseFutureUseCase<GetWalletsInput, GetWalletsOutput> {
  const GetWalletsUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetWalletsOutput> buildUseCase(GetWalletsInput input) async {
    final response = await _repository.getWallets();

    return GetWalletsOutput(wallets: response);
  }
}

@freezed
sealed class GetWalletsInput extends BaseInput with _$GetWalletsInput {
  const GetWalletsInput._();

  const factory GetWalletsInput() = _GetWalletsInput;
}

@freezed
sealed class GetWalletsOutput extends BaseOutput with _$GetWalletsOutput {
  const GetWalletsOutput._();

  const factory GetWalletsOutput({@Default(<Wallet>[]) List<Wallet> wallets}) = _GetWalletsOutput;
}
