import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'update_wallet_use_case.freezed.dart';

@injectable
class UpdateWalletUseCase extends BaseFutureUseCase<UpdateWalletInput, UpdateWalletOutput> {
  const UpdateWalletUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<UpdateWalletOutput> buildUseCase(UpdateWalletInput input) async {
    await _repository.editWallet(wallet: input.wallet);

    return const UpdateWalletOutput();
  }
}

@freezed
sealed class UpdateWalletInput extends BaseInput with _$UpdateWalletInput {
  const UpdateWalletInput._();

  const factory UpdateWalletInput({required Wallet wallet}) = _UpdateWalletInput;
}

@freezed
sealed class UpdateWalletOutput extends BaseOutput with _$UpdateWalletOutput {
  const UpdateWalletOutput._();

  const factory UpdateWalletOutput() = _UpdateWalletOutput;
}
