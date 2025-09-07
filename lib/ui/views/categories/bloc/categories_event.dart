part of 'categories_bloc.dart';

sealed class CategoriesEvent extends BaseBlocEvent {
  const CategoriesEvent();
}

@freezed
class CategoriesViewInitiated extends CategoriesEvent with _$CategoriesViewInitiated {
  const CategoriesViewInitiated._();

  const factory CategoriesViewInitiated() = _CategoriesViewInitiated;
}
