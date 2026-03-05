import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_user_default_currency_use_case.freezed.dart';

@injectable
class GetUserDefaultCurrencyUseCase
    extends BaseFutureUseCase<GetUserDefaultCurrencyInput, GetUserDefaultCurrencyOutput> {
  const GetUserDefaultCurrencyUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetUserDefaultCurrencyOutput> buildUseCase(GetUserDefaultCurrencyInput input) async {
    final response = await _repository.getUserDefaultCurrency();

    return GetUserDefaultCurrencyOutput(currency: response);
  }
}

@freezed
sealed class GetUserDefaultCurrencyInput extends BaseInput with _$GetUserDefaultCurrencyInput {
  const GetUserDefaultCurrencyInput._();

  const factory GetUserDefaultCurrencyInput() = _GetUserDefaultCurrencyInput;
}

@freezed
sealed class GetUserDefaultCurrencyOutput extends BaseOutput with _$GetUserDefaultCurrencyOutput {
  const GetUserDefaultCurrencyOutput._();

  const factory GetUserDefaultCurrencyOutput({@Default(Currency()) Currency currency}) =
      _GetUserDefaultCurrencyOutput;
}
