import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class TransactionDataMapper extends BaseDataMapper<TransactionData, Transaction>
    with DataMapperMixin {
  const TransactionDataMapper(
    this._categoryDataMapper,
    this._walletDataMapper,
    this._categoryTypeDataMapper,
  );

  final CategoryDataMapper _categoryDataMapper;
  final WalletDataMapper _walletDataMapper;
  final CategoryTypeDataMapper _categoryTypeDataMapper;

  @override
  Transaction mapToEntity(TransactionData? data) {
    return Transaction(
      id: data?.id ?? 0,
      amount: data?.amount ?? 0.0,
      createdAt: data?.createdAt?.toDateTime(),
      category: _categoryDataMapper.mapToEntity(data?.category),
      wallet: _walletDataMapper.mapToEntity(data?.wallet),
      categoryId: data?.categoryId ?? 0,
      walletId: data?.walletId ?? 0,
      userId: data?.userId,
      note: data?.note ?? '',
      type: _categoryTypeDataMapper.mapToEntity(data?.type),
    );
  }

  @override
  TransactionData mapToData(Transaction entity) {
    return TransactionData(
      id: entity.id,
      amount: entity.amount,
      createdAt: entity.createdAt?.toIso8601String(),
      categoryId: entity.categoryId,
      walletId: entity.walletId,
      userId: entity.userId,
      note: entity.note,
    );
  }
}
