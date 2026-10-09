import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'set_app_theme_preference_use_case.freezed.dart';

@injectable
class SetAppThemePreferenceUseCase
    extends BaseFutureUseCase<SetAppThemePreferenceInput, SetAppThemePreferenceOutput> {
  const SetAppThemePreferenceUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<SetAppThemePreferenceOutput> buildUseCase(SetAppThemePreferenceInput input) async {
    await _repository.setAppThemePreference(input.preference);

    return const SetAppThemePreferenceOutput();
  }
}

@freezed
sealed class SetAppThemePreferenceInput extends BaseInput with _$SetAppThemePreferenceInput {
  const SetAppThemePreferenceInput._();

  const factory SetAppThemePreferenceInput({required AppThemePreference preference}) =
      _SetAppThemePreferenceInput;
}

@freezed
sealed class SetAppThemePreferenceOutput extends BaseOutput with _$SetAppThemePreferenceOutput {
  const SetAppThemePreferenceOutput._();

  const factory SetAppThemePreferenceOutput() = _SetAppThemePreferenceOutput;
}
