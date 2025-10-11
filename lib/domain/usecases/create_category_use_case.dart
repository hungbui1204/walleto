import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'create_category_use_case.freezed.dart';

@injectable
class CreateCategoryUseCase extends BaseFutureUseCase<CreateCategoryInput, CreateCategoryOutput> {
  const CreateCategoryUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<CreateCategoryOutput> buildUseCase(CreateCategoryInput input) async {
    await _repository.createCategory(input.category);

    return const CreateCategoryOutput();
  }
}

@freezed
sealed class CreateCategoryInput extends BaseInput with _$CreateCategoryInput {
  const CreateCategoryInput._();

  const factory CreateCategoryInput({required Category category}) = _CreateCategoryInput;
}

@freezed
sealed class CreateCategoryOutput extends BaseOutput with _$CreateCategoryOutput {
  const CreateCategoryOutput._();

  const factory CreateCategoryOutput() = _CreateCategoryOutput;
}
