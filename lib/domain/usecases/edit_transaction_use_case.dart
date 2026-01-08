import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'edit_transaction_use_case.freezed.dart';

@injectable
class EditTransactionUseCase
    extends BaseFutureUseCase<EditTransactionInput, EditTransactionOutput> {
  const EditTransactionUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<EditTransactionOutput> buildUseCase(EditTransactionInput input) async {
    final response = await _repository.updateTransaction(transaction: input.transaction);

    return EditTransactionOutput(transaction: response);
  }
}

@freezed
sealed class EditTransactionInput extends BaseInput with _$EditTransactionInput {
  const EditTransactionInput._();

  const factory EditTransactionInput({required Transaction transaction}) = _EditTransactionInput;
}

@freezed
sealed class EditTransactionOutput extends BaseOutput with _$EditTransactionOutput {
  const EditTransactionOutput._();

  const factory EditTransactionOutput({@Default(Transaction()) Transaction transaction}) =
      _EditTransactionOutput;
}
