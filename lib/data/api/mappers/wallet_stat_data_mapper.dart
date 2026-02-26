import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class WalletStatDataMapper extends BaseDataMapper<WalletStatData, WalletStat> {
  const WalletStatDataMapper(this._categoryStatDataMapper);

  final CategoryStatDataMapper _categoryStatDataMapper;

  @override
  WalletStat mapToEntity(WalletStatData? data) {
    return WalletStat(
      categoryStats: _categoryStatDataMapper.mapToListEntity(data?.categoryStats),
      currencyCode: data?.currencyCode ?? '',
      totalAmount: data?.totalAmount ?? 0,
      walletId: data?.walletId ?? 0,
      walletName: data?.walletName ?? '',
    );
  }
}
