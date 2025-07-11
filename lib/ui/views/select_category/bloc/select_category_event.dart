part of 'select_category_bloc.dart';

sealed class SelectCategoryEvent extends BaseBlocEvent {
  const SelectCategoryEvent();
}

@freezed
sealed class SelectCategoryViewInitiated extends SelectCategoryEvent
    with _$SelectCategoryViewInitiated {
  const SelectCategoryViewInitiated._();
  const factory SelectCategoryViewInitiated() = _SelectCategoryViewInitiated;
}
