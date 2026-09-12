import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'update_user_default_currency_use_case.freezed.dart';

@injectable
class UpdateUserDefaultCurrencyUseCase
    extends BaseFutureUseCase<UpdateUserDefaultCurrencyInput, UpdateUserDefaultCurrencyOutput> {
  const UpdateUserDefaultCurrencyUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<UpdateUserDefaultCurrencyOutput> buildUseCase(UpdateUserDefaultCurrencyInput input) async {
    await _repository.updateUserDefaultCurrency(currencyCode: input.currencyCode);

    return const UpdateUserDefaultCurrencyOutput();
  }
}

@freezed
sealed class UpdateUserDefaultCurrencyInput extends BaseInput
    with _$UpdateUserDefaultCurrencyInput {
  const UpdateUserDefaultCurrencyInput._();

  const factory UpdateUserDefaultCurrencyInput({required String currencyCode}) =
      _UpdateUserDefaultCurrencyInput;
}

@freezed
sealed class UpdateUserDefaultCurrencyOutput extends BaseOutput
    with _$UpdateUserDefaultCurrencyOutput {
  const UpdateUserDefaultCurrencyOutput._();

  const factory UpdateUserDefaultCurrencyOutput() = _UpdateUserDefaultCurrencyOutput;
}
