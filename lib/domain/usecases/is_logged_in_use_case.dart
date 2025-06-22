import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'is_logged_in_use_case.freezed.dart';

@injectable
class IsLoggedInUseCase extends BaseFutureUseCase<IsLoggedInInput, IsLoggedInOutput> {
  const IsLoggedInUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<IsLoggedInOutput> buildUseCase(IsLoggedInInput input) async {
    return IsLoggedInOutput(isLoggedIn: await _repository.isLoggedIn);
  }
}

@freezed
sealed class IsLoggedInInput extends BaseInput with _$IsLoggedInInput {
  const IsLoggedInInput._();

  const factory IsLoggedInInput() = _IsLoggedInInput;
}

@freezed
sealed class IsLoggedInOutput extends BaseOutput with _$IsLoggedInOutput {
  const IsLoggedInOutput._();

  const factory IsLoggedInOutput({@Default(false) bool isLoggedIn}) = _IsLoggedInOutput;
}
