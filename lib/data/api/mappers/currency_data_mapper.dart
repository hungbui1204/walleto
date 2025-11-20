import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class CurrencyDataMapper extends BaseDataMapper<CurrencyData, Currency> with DataMapperMixin {
  const CurrencyDataMapper();

  @override
  Currency mapToEntity(CurrencyData? data) {
    return Currency(
      code: data?.code ?? '',
      name: data?.name ?? '',
      symbol: data?.symbol ?? '',
      decimalPlaces: data?.decimalPlaces ?? 0,
      isActive: data?.isActive ?? true,
      createdAt: data?.createdAt?.toDateTime(),
      iconUrl: data?.iconUrl ?? '',
    );
  }

  @override
  CurrencyData mapToData(Currency entity) {
    return CurrencyData(
      code: entity.code,
      name: entity.name,
      symbol: entity.symbol,
      decimalPlaces: entity.decimalPlaces,
      isActive: entity.isActive,
      createdAt: entity.createdAt?.toIso8601String(),
      iconUrl: entity.iconUrl,
    );
  }
}
