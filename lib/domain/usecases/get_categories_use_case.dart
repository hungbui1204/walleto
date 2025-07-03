import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_categories_use_case.freezed.dart';

@injectable
class GetCategoriesUseCase extends BaseFutureUseCase<GetCategoriesInput, GetCategoriesOutput> {
  const GetCategoriesUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetCategoriesOutput> buildUseCase(GetCategoriesInput input) async {
    final response = await _repository.getCategories();

    return GetCategoriesOutput(categories: response);
  }
}

@freezed
sealed class GetCategoriesInput extends BaseInput with _$GetCategoriesInput {
  const GetCategoriesInput._();

  const factory GetCategoriesInput() = _GetCategoriesInput;
}

@freezed
sealed class GetCategoriesOutput extends BaseOutput with _$GetCategoriesOutput {
  const GetCategoriesOutput._();

  const factory GetCategoriesOutput({@Default([]) List<Category> categories}) =
      _GetCategoriesOutput;
}
