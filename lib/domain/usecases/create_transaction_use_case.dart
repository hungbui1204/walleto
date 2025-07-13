import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'create_transaction_use_case.freezed.dart';

@injectable
class CreateTransactionUseCase
    extends BaseFutureUseCase<CreateTransactionInput, CreateTransactionOutput> {
  const CreateTransactionUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<CreateTransactionOutput> buildUseCase(CreateTransactionInput input) async {
    await _repository.createTransaction(input.transaction);

    return const CreateTransactionOutput();
  }
}

@freezed
sealed class CreateTransactionInput extends BaseInput with _$CreateTransactionInput {
  const CreateTransactionInput._();

  const factory CreateTransactionInput({required Transaction transaction}) =
      _CreateTransactionInput;
}

@freezed
sealed class CreateTransactionOutput extends BaseOutput with _$CreateTransactionOutput {
  const CreateTransactionOutput._();

  const factory CreateTransactionOutput() = _CreateTransactionOutput;
}
