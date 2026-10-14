import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'login_with_biometrics_use_case.freezed.dart';

@injectable
class LoginWithBiometricsUseCase
    extends BaseFutureUseCase<LoginWithBiometricsInput, LoginWithBiometricsOutput> {
  const LoginWithBiometricsUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<LoginWithBiometricsOutput> buildUseCase(LoginWithBiometricsInput input) async {
    final authentication = await _repository.loginWithBiometrics();
    return LoginWithBiometricsOutput(authentication: authentication);
  }
}

@freezed
sealed class LoginWithBiometricsInput extends BaseInput with _$LoginWithBiometricsInput {
  const LoginWithBiometricsInput._();
  const factory LoginWithBiometricsInput() = _LoginWithBiometricsInput;
}

@freezed
sealed class LoginWithBiometricsOutput extends BaseOutput with _$LoginWithBiometricsOutput {
  const LoginWithBiometricsOutput._();
  const factory LoginWithBiometricsOutput({required Authentication authentication}) =
      _LoginWithBiometricsOutput;
}
