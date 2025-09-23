import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'create_wallet_use_case.freezed.dart';

@injectable
class CreateWalletUseCase extends BaseFutureUseCase<CreateWalletInput, CreateWalletOutput> {
  const CreateWalletUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<CreateWalletOutput> buildUseCase(CreateWalletInput input) async {
    await _repository.createWallet(input.wallet);

    return const CreateWalletOutput();
  }
}

@freezed
sealed class CreateWalletInput extends BaseInput with _$CreateWalletInput {
  const CreateWalletInput._();

  const factory CreateWalletInput({required Wallet wallet}) = _CreateWalletInput;
}

@freezed
sealed class CreateWalletOutput extends BaseOutput with _$CreateWalletOutput {
  const CreateWalletOutput._();

  const factory CreateWalletOutput() = _CreateWalletOutput;
}
