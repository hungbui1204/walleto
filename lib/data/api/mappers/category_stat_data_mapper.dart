import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class CategoryStatDataMapper extends BaseDataMapper<CategoryStatData, CategoryStat> {
  const CategoryStatDataMapper();

  @override
  CategoryStat mapToEntity(CategoryStatData? data) {
    return CategoryStat(
      categoryId: data?.categoryId ?? 0,
      categoryName: data?.categoryName ?? '',
      totalAmount: data?.totalAmount ?? 0,
      categoryIconUrl: data?.categoryIconUrl ?? '',
    );
  }
}
