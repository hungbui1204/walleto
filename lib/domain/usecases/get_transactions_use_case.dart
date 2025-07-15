import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_transactions_use_case.freezed.dart';

@injectable
class GetTransactionsUseCase
    extends BaseFutureUseCase<GetTransactionsInput, GetTransactionsOutput> {
  const GetTransactionsUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetTransactionsOutput> buildUseCase(GetTransactionsInput input) async {
    final response = await _repository.getTransactions(
      targetMonth: input.targetMonth,
      targetYear: input.targetYear,
      fromDate: input.fromDate,
      toDate: input.toDate,
    );

    return GetTransactionsOutput(transactions: response);
  }
}

@freezed
sealed class GetTransactionsInput extends BaseInput with _$GetTransactionsInput {
  const GetTransactionsInput._();

  const factory GetTransactionsInput({
    int? targetMonth,
    int? targetYear,
    DateTime? fromDate,
    DateTime? toDate,
  }) = _GetTransactionsInput;
}

@freezed
sealed class GetTransactionsOutput extends BaseOutput with _$GetTransactionsOutput {
  const GetTransactionsOutput._();

  const factory GetTransactionsOutput({@Default(<Transaction>[]) List<Transaction> transactions}) =
      _GetTransactionsOutput;
}
