part of 'create_category_bloc.dart';

@freezed
sealed class CreateCategoryState extends BaseBlocState with _$CreateCategoryState {
  const CreateCategoryState._();

  const factory CreateCategoryState({
    @Default('') String categoryName,
    @Default(CategoryType.expense) CategoryType categoryType,
    @Default('') String icon,
    Category? parent,
    @Default(false) bool confirmButtonEnable,
  }) = _CreateCategoryState;
}
