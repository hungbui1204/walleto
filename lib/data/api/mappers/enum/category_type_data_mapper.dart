import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class CategoryTypeDataMapper extends BaseDataMapper<String, CategoryType> with DataMapperMixin {
  const CategoryTypeDataMapper();

  @override
  CategoryType mapToEntity(String? data) {
    return switch (data) {
      'expense' => CategoryType.expense,
      'income' => CategoryType.income,
      _ => CategoryType.expense,
    };
  }

  @override
  String mapToData(CategoryType entity) {
    return switch (entity) {
      CategoryType.expense => 'expense',
      CategoryType.income => 'income',
    };
  }
}
