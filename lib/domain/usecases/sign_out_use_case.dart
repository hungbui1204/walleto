import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'sign_out_use_case.freezed.dart';

@injectable
class SignOutUseCase extends BaseFutureUseCase<SignOutInput, SignOutOutput> {
  const SignOutUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<SignOutOutput> buildUseCase(SignOutInput input) async {
    var serverSessionRevoked = false;
    var retainedForBiometric = false;
    if (await _repository.isLoggedIn) {
      final result = await _repository.signOut();
      serverSessionRevoked = result.serverSessionRevoked;
      retainedForBiometric = result.retainedForBiometric;
    }

    return SignOutOutput(
      serverSessionRevoked: serverSessionRevoked,
      retainedForBiometric: retainedForBiometric,
    );
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

  const factory SignOutOutput({
    @Default(false) bool serverSessionRevoked,
    @Default(false) bool retainedForBiometric,
  }) = _SignOutOutput;
}
