part of 'select_category_bloc.dart';

@freezed
sealed class SelectCategoryState extends BaseBlocState with _$SelectCategoryState {
  const SelectCategoryState._();

  const factory SelectCategoryState({
    @Default(<Category>[]) List<Category> parentExpenseCategories,
    @Default(<Category>[]) List<Category> parentIncomeCategories,
  }) = _SelectCategoryState;
}
