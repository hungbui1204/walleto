import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'duplicate_transaction_use_case.freezed.dart';

@injectable
class DuplicateTransactionUseCase
    extends BaseFutureUseCase<DuplicateTransactionInput, DuplicateTransactionOutput> {
  const DuplicateTransactionUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<DuplicateTransactionOutput> buildUseCase(DuplicateTransactionInput input) async {
    final response = await _repository.duplicateTransaction(
      transactionId: input.transactionId,
      newCreatedAt: input.newCreatedAt,
    );

    return DuplicateTransactionOutput(transaction: response);
  }
}

@freezed
sealed class DuplicateTransactionInput extends BaseInput with _$DuplicateTransactionInput {
  const DuplicateTransactionInput._();

  const factory DuplicateTransactionInput({
    required int transactionId,
    required DateTime newCreatedAt,
  }) = _DuplicateTransactionInput;
}

@freezed
sealed class DuplicateTransactionOutput extends BaseOutput with _$DuplicateTransactionOutput {
  const DuplicateTransactionOutput._();

  const factory DuplicateTransactionOutput({@Default(Transaction()) Transaction transaction}) =
      _DuplicateTransactionOutput;
}
