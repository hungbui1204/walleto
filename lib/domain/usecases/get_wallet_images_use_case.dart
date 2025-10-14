import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_wallet_images_use_case.freezed.dart';

@injectable
class GetWalletImagesUseCase
    extends BaseFutureUseCase<GetWalletImagesInput, GetWalletImagesOutput> {
  const GetWalletImagesUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetWalletImagesOutput> buildUseCase(GetWalletImagesInput input) async {
    final images = await _repository.getWalletImages();

    return GetWalletImagesOutput(images: images);
  }
}

@freezed
sealed class GetWalletImagesInput extends BaseInput with _$GetWalletImagesInput {
  const GetWalletImagesInput._();

  const factory GetWalletImagesInput() = _GetWalletImagesInput;
}

@freezed
sealed class GetWalletImagesOutput extends BaseOutput with _$GetWalletImagesOutput {
  const GetWalletImagesOutput._();

  const factory GetWalletImagesOutput({required List<SupabaseImage> images}) =
      _GetWalletImagesOutput;
}
