import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class WalletDataMapper extends BaseDataMapper<WalletData, Wallet> with DataMapperMixin {
  const WalletDataMapper();

  @override
  Wallet mapToEntity(WalletData? data) {
    return Wallet(
      id: data?.id ?? 0,
      name: data?.name ?? '',
      amount: data?.amount ?? 0.0,
      userId: data?.userId,
    );
  }

  @override
  WalletData mapToData(Wallet entity) {
    return WalletData(
      id: entity.id,
      name: entity.name,
      amount: entity.amount,
      userId: entity.userId,
    );
  }
}
