import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class CategoryTypeDataMapper extends BaseDataMapper<String, CategoryType> with DataMapperMixin {
  const CategoryTypeDataMapper();

  @override
  CategoryType mapToEntity(String? data) {
    return CategoryType.values.firstOrNullWhere((element) => element.name == data) ??
        CategoryType.expense;
  }

  @override
  String mapToData(CategoryType entity) => entity.name;
}
