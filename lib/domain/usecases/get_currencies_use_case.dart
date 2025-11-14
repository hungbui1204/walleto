import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_currencies_use_case.freezed.dart';

@injectable
class GetCurrenciesUseCase extends BaseFutureUseCase<GetCurrenciesInput, GetCurrenciesOutput> {
  const GetCurrenciesUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetCurrenciesOutput> buildUseCase(GetCurrenciesInput input) async {
    final response = await _repository.getCurrencies();

    return GetCurrenciesOutput(currencies: response);
  }
}

@freezed
sealed class GetCurrenciesInput extends BaseInput with _$GetCurrenciesInput {
  const GetCurrenciesInput._();

  const factory GetCurrenciesInput() = _GetCurrenciesInput;
}

@freezed
sealed class GetCurrenciesOutput extends BaseOutput with _$GetCurrenciesOutput {
  const GetCurrenciesOutput._();

  const factory GetCurrenciesOutput({@Default(<Currency>[]) List<Currency> currencies}) =
      _GetCurrenciesOutput;
}
