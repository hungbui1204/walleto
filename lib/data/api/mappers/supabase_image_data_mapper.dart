import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class SupabaseImageDataMapper extends BaseDataMapper<SupabaseImageData, SupabaseImage> {
  const SupabaseImageDataMapper();

  @override
  SupabaseImage mapToEntity(SupabaseImageData? data) {
    return SupabaseImage(
      id: data?.id,
      name: data?.name,
      createdAt: data?.createdAt != null ? DateTime.parse(data!.createdAt!) : null,
      updatedAt: data?.updatedAt != null ? DateTime.parse(data!.updatedAt!) : null,
    );
  }
}
