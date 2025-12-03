import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'reset_user_password_use_case.freezed.dart';

@injectable
class ResetUserPasswordUseCase
    extends BaseFutureUseCase<ResetUserPasswordInput, ResetUserPasswordOutput> {
  const ResetUserPasswordUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<ResetUserPasswordOutput> buildUseCase(ResetUserPasswordInput input) async {
    await _repository.resetUserPassword(email: input.email, password: input.password);

    return const ResetUserPasswordOutput();
  }
}

@freezed
sealed class ResetUserPasswordInput extends BaseInput with _$ResetUserPasswordInput {
  const ResetUserPasswordInput._();

  const factory ResetUserPasswordInput({required String email, required String password}) =
      _ResetUserPasswordInput;
}

@freezed
sealed class ResetUserPasswordOutput extends BaseOutput with _$ResetUserPasswordOutput {
  const ResetUserPasswordOutput._();

  const factory ResetUserPasswordOutput() = _ResetUserPasswordOutput;
}
