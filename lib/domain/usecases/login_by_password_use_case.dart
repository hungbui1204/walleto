import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'login_by_password_use_case.freezed.dart';

@injectable
class LoginByPasswordUseCase
    extends BaseFutureUseCase<LoginByPasswordInput, LoginByPasswordOutput> {
  const LoginByPasswordUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<LoginByPasswordOutput> buildUseCase(LoginByPasswordInput input) async {
    await _repository.loginByPassword(email: input.email, password: input.password);

    return const LoginByPasswordOutput();
  }
}

@freezed
sealed class LoginByPasswordInput extends BaseInput with _$LoginByPasswordInput {
  const LoginByPasswordInput._();

  const factory LoginByPasswordInput({required String email, required String password}) =
      _LoginByPasswordInput;
}

@freezed
sealed class LoginByPasswordOutput extends BaseOutput with _$LoginByPasswordOutput {
  const LoginByPasswordOutput._();

  const factory LoginByPasswordOutput() = _LoginByPasswordOutput;
}
