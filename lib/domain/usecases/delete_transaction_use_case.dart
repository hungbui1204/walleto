import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'delete_transaction_use_case.freezed.dart';

@injectable
class DeleteTransactionUseCase
    extends BaseFutureUseCase<DeleteTransactionInput, DeleteTransactionOutput> {
  const DeleteTransactionUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<DeleteTransactionOutput> buildUseCase(DeleteTransactionInput input) async {
    await _repository.deleteTransaction(transactionId: input.transactionId);

    return const DeleteTransactionOutput();
  }
}

@freezed
sealed class DeleteTransactionInput extends BaseInput with _$DeleteTransactionInput {
  const DeleteTransactionInput._();

  const factory DeleteTransactionInput({required int transactionId}) = _DeleteTransactionInput;
}

@freezed
sealed class DeleteTransactionOutput extends BaseOutput with _$DeleteTransactionOutput {
  const DeleteTransactionOutput._();

  const factory DeleteTransactionOutput() = _DeleteTransactionOutput;
}
