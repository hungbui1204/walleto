import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class ExchangeRateDataMapper extends BaseDataMapper<ExchangeRateData, ExchangeRate> {
  const ExchangeRateDataMapper();

  @override
  ExchangeRate mapToEntity(ExchangeRateData? data) {
    return ExchangeRate(
      id: data?.id ?? 0,
      fromCurrency: data?.fromCurrency ?? '',
      toCurrency: data?.toCurrency ?? '',
      rate: data?.rate ?? 0.0,
      source: data?.source ?? '',
      createdAt: data?.createdAt?.toDateTime(),
      isActive: data?.isActive ?? false,
    );
  }
}
