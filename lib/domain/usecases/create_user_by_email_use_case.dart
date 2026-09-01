import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

part 'create_user_by_email_use_case.freezed.dart';

@injectable
class CreateUserByEmailUseCase
    extends BaseFutureUseCase<CreateUserByEmailInput, CreateUserByEmailOutput> {
  const CreateUserByEmailUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<CreateUserByEmailOutput> buildUseCase(CreateUserByEmailInput input) async {
    await _repository.createUserByEmail(email: input.email, password: input.password);

    return const CreateUserByEmailOutput();
  }
}

@freezed
sealed class CreateUserByEmailInput extends BaseInput with _$CreateUserByEmailInput {
  const CreateUserByEmailInput._();

  const factory CreateUserByEmailInput({required String email, required String password}) =
      _CreateUserByEmailInput;

  @override
  String toString() =>
      'CreateUserByEmailInput(email: $email, password: ${LogRedactor.placeholder})';
}

@freezed
sealed class CreateUserByEmailOutput extends BaseOutput with _$CreateUserByEmailOutput {
  const CreateUserByEmailOutput._();

  const factory CreateUserByEmailOutput() = _CreateUserByEmailOutput;
}
