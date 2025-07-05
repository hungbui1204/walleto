import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class TransactionDataMapper extends BaseDataMapper<TransactionData, Transaction>
    with DataMapperMixin {
  const TransactionDataMapper(this._categoryDataMapper, this._walletDataMapper);

  final CategoryDataMapper _categoryDataMapper;
  final WalletDataMapper _walletDataMapper;

  @override
  Transaction mapToEntity(TransactionData? data) {
    return Transaction(
      id: data?.id ?? 0,
      amount: data?.amount ?? 0.0,
      date: data?.date ?? '',
      category: _categoryDataMapper.mapToEntity(data?.category),
      wallet: _walletDataMapper.mapToEntity(data?.wallet),
      categoryId: data?.categoryId ?? 0,
      walletId: data?.walletId ?? 0,
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
