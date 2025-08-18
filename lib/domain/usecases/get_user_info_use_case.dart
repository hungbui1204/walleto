import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_user_info_use_case.freezed.dart';

@injectable
class GetUserInfoUseCase extends BaseFutureUseCase<GetUserInfoInput, GetUserInfoOutput> {
  const GetUserInfoUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetUserInfoOutput> buildUseCase(GetUserInfoInput input) async {
    final user = await _repository.getUserInfo();

    return GetUserInfoOutput(user: user);
  }
}

@freezed
sealed class GetUserInfoInput extends BaseInput with _$GetUserInfoInput {
  const GetUserInfoInput._();

  const factory GetUserInfoInput() = _GetUserInfoInput;
}

@freezed
sealed class GetUserInfoOutput extends BaseOutput with _$GetUserInfoOutput {
  const GetUserInfoOutput._();

  const factory GetUserInfoOutput({@Default(User()) User user}) = _GetUserInfoOutput;
}
