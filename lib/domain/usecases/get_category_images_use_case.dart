import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_category_images_use_case.freezed.dart';

@injectable
class GetCategoryImagesUseCase
    extends BaseFutureUseCase<GetCategoryImagesInput, GetCategoryImagesOutput> {
  const GetCategoryImagesUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetCategoryImagesOutput> buildUseCase(GetCategoryImagesInput input) async {
    final images = await _repository.getCategoryImages();

    return GetCategoryImagesOutput(images: images);
  }
}

@freezed
sealed class GetCategoryImagesInput extends BaseInput with _$GetCategoryImagesInput {
  const GetCategoryImagesInput._();

  const factory GetCategoryImagesInput() = _GetCategoryImagesInput;
}

@freezed
sealed class GetCategoryImagesOutput extends BaseOutput with _$GetCategoryImagesOutput {
  const GetCategoryImagesOutput._();

  const factory GetCategoryImagesOutput({@Default(<SupabaseImage>[]) List<SupabaseImage> images}) =
      _GetCategoryImagesOutput;
}
