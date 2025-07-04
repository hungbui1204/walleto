import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class CategoryDataMapper extends BaseDataMapper<CategoryData, Category> with DataMapperMixin {
  const CategoryDataMapper();

  @override
  Category mapToEntity(CategoryData? data) {
    return Category(
      id: data?.id ?? 0,
      name: data?.name ?? '',
      iconUrl: data?.iconUrl ?? '',
      isParent: data?.isParent ?? false,
      parentId: data?.parentId,
      userId: data?.userId,
    );
  }

  @override
  CategoryData mapToData(Category entity) {
    return CategoryData(
      id: entity.id,
      name: entity.name,
      iconUrl: entity.iconUrl,
      isParent: entity.isParent,
      parentId: entity.parentId,
      userId: entity.userId,
    );
  }
}
