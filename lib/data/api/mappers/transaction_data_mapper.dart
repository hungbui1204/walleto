import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class TransactionDataMapper extends BaseDataMapper<TransactionData, Transaction>
    with DataMapperMixin {
  const TransactionDataMapper();

  @override
  Transaction mapToEntity(TransactionData? data) {
    return Transaction(
      id: data?.id ?? 0,
      amount: data?.amount ?? 0.0,
      date: data?.date ?? '',
      categoryId: data?.categoryId,
      walletId: data?.walletId,
      userId: data?.userId,
      note: data?.note ?? '',
    );
  }

  @override
  TransactionData mapToData(Transaction entity) {
    return TransactionData(
      id: entity.id,
      amount: entity.amount,
      date: entity.date,
      categoryId: entity.categoryId,
      walletId: entity.walletId,
      userId: entity.userId,
      note: entity.note,
    );
  }
}
