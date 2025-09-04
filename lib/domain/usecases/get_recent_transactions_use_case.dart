import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_recent_transactions_use_case.freezed.dart';

@injectable
class GetRecentTransactionsUseCase
    extends BaseFutureUseCase<GetRecentTransactionsInput, GetRecentTransactionsOutput> {
  const GetRecentTransactionsUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetRecentTransactionsOutput> buildUseCase(GetRecentTransactionsInput input) async {
    final transactions = await _repository.getRecentTransactions(walletId: input.walletId);

    return GetRecentTransactionsOutput(transactions: transactions);
  }
}

@freezed
sealed class GetRecentTransactionsInput extends BaseInput with _$GetRecentTransactionsInput {
  const GetRecentTransactionsInput._();

  const factory GetRecentTransactionsInput({int? walletId}) = _GetRecentTransactionsInput;
}

@freezed
sealed class GetRecentTransactionsOutput extends BaseOutput with _$GetRecentTransactionsOutput {
  const GetRecentTransactionsOutput._();

  const factory GetRecentTransactionsOutput({required List<Transaction> transactions}) =
      _GetRecentTransactionsOutput;
}
