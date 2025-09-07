part of 'categories_bloc.dart';

@freezed
sealed class CategoriesState extends BaseBlocState with _$CategoriesState {
  const CategoriesState._();

  const factory CategoriesState({
    @Default(<Category>[]) List<Category> parentExpenseCategories,
    @Default(<Category>[]) List<Category> parentIncomeCategories,
  }) = _CategoriesState;
}
