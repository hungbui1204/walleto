import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_exchange_rate_use_case.freezed.dart';

@injectable
class GetExchangeRateUseCase
    extends BaseFutureUseCase<GetExchangeRateInput, GetExchangeRateOutput> {
  const GetExchangeRateUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetExchangeRateOutput> buildUseCase(GetExchangeRateInput input) async {
    final response = await _repository.getExchangeRate(
      fromCurrencyCode: input.fromCurrencyCode,
      toCurrencyCode: input.toCurrencyCode,
    );

    return GetExchangeRateOutput(exchangeRate: response);
  }
}

@freezed
sealed class GetExchangeRateInput extends BaseInput with _$GetExchangeRateInput {
  const GetExchangeRateInput._();

  const factory GetExchangeRateInput({
    required String fromCurrencyCode,
    required String toCurrencyCode,
  }) = _GetExchangeRateInput;
}

@freezed
sealed class GetExchangeRateOutput extends BaseOutput with _$GetExchangeRateOutput {
  const GetExchangeRateOutput._();

  const factory GetExchangeRateOutput({@Default(ExchangeRate()) ExchangeRate exchangeRate}) =
      _GetExchangeRateOutput;
}
