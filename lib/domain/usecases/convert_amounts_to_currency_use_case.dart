import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'convert_amounts_to_currency_use_case.freezed.dart';

@injectable
class ConvertAmountsToCurrencyUseCase
    extends BaseFutureUseCase<ConvertAmountsToCurrencyInput, ConvertAmountsToCurrencyOutput> {
  const ConvertAmountsToCurrencyUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<ConvertAmountsToCurrencyOutput> buildUseCase(ConvertAmountsToCurrencyInput input) async {
    final rates = <String, double>{};
    var total = 0.0;

    for (final item in input.amounts) {
      final rate = await _rateFor(
        fromCurrencyCode: item.currencyCode,
        toCurrencyCode: input.targetCurrencyCode,
        cache: rates,
      );
      total += item.amount * rate * item.sign;
    }

    return ConvertAmountsToCurrencyOutput(total: total);
  }

  Future<double> _rateFor({
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required Map<String, double> cache,
  }) async {
    if (fromCurrencyCode.isEmpty || toCurrencyCode.isEmpty || fromCurrencyCode == toCurrencyCode) {
      return 1;
    }

    final cacheKey = '$fromCurrencyCode->$toCurrencyCode';
    final cached = cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final exchangeRate = await _repository.getExchangeRate(
      fromCurrencyCode: fromCurrencyCode,
      toCurrencyCode: toCurrencyCode,
    );
    final rate = exchangeRate.rate > 0 ? exchangeRate.rate : 1.0;
    cache[cacheKey] = rate;

    return rate;
  }
}

@freezed
sealed class ConvertAmountsToCurrencyInput extends BaseInput with _$ConvertAmountsToCurrencyInput {
  const ConvertAmountsToCurrencyInput._();

  const factory ConvertAmountsToCurrencyInput({
    required List<AmountInCurrency> amounts,
    required String targetCurrencyCode,
  }) = _ConvertAmountsToCurrencyInput;
}

@freezed
sealed class ConvertAmountsToCurrencyOutput extends BaseOutput
    with _$ConvertAmountsToCurrencyOutput {
  const ConvertAmountsToCurrencyOutput._();

  const factory ConvertAmountsToCurrencyOutput({@Default(0) double total}) =
      _ConvertAmountsToCurrencyOutput;
}
