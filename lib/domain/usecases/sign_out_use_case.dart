import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'sign_out_use_case.freezed.dart';

@injectable
class SignOutUseCase extends BaseFutureUseCase<SignOutInput, SignOutOutput> {
  const SignOutUseCase(this._repository, this._navigator);

  final Repository _repository;
  final AppNavigator _navigator;

  @protected
  @override
  Future<SignOutOutput> buildUseCase(SignOutInput input) async {
    if (await _repository.isLoggedIn) {
      await _repository.signOut();
      await _navigator.replace(const AppRouteInfo.login());
    }

    return const SignOutOutput();
  }
}

@freezed
sealed class SignOutInput extends BaseInput with _$SignOutInput {
  const SignOutInput._();

  const factory SignOutInput() = _SignOutInput;
}

@freezed
sealed class SignOutOutput extends BaseOutput with _$SignOutOutput {
  const SignOutOutput._();

  const factory SignOutOutput() = _SignOutOutput;
}
