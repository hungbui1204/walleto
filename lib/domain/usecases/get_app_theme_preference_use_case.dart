import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_app_theme_preference_use_case.freezed.dart';

@injectable
class GetAppThemePreferenceUseCase
    extends BaseFutureUseCase<GetAppThemePreferenceInput, GetAppThemePreferenceOutput> {
  const GetAppThemePreferenceUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetAppThemePreferenceOutput> buildUseCase(GetAppThemePreferenceInput input) async {
    return GetAppThemePreferenceOutput(preference: await _repository.getAppThemePreference());
  }
}

@freezed
sealed class GetAppThemePreferenceInput extends BaseInput with _$GetAppThemePreferenceInput {
  const GetAppThemePreferenceInput._();

  const factory GetAppThemePreferenceInput() = _GetAppThemePreferenceInput;
}

@freezed
sealed class GetAppThemePreferenceOutput extends BaseOutput with _$GetAppThemePreferenceOutput {
  const GetAppThemePreferenceOutput._();

  const factory GetAppThemePreferenceOutput({
    @Default(AppThemePreference.dark) AppThemePreference preference,
  }) = _GetAppThemePreferenceOutput;
}
