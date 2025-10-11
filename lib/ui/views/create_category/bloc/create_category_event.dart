part of 'create_category_bloc.dart';

sealed class CreateCategoryEvent extends BaseBlocEvent {
  const CreateCategoryEvent();
}

@freezed
sealed class CreateCategoryViewInitiated extends CreateCategoryEvent
    with _$CreateCategoryViewInitiated {
  const CreateCategoryViewInitiated._();

  const factory CreateCategoryViewInitiated() = _CreateCategoryViewInitiated;
}

@freezed
sealed class CreateCategoryNameInputChanged extends CreateCategoryEvent
    with _$CreateCategoryNameInputChanged {
  const CreateCategoryNameInputChanged._();

  const factory CreateCategoryNameInputChanged({required String categoryName}) =
      _CreateCategoryNameInputChanged;
}

@freezed
sealed class CreateCategoryTypeChanged extends CreateCategoryEvent
    with _$CreateCategoryTypeChanged {
  const CreateCategoryTypeChanged._();

  const factory CreateCategoryTypeChanged({required CategoryType categoryType}) =
      _CreateCategoryTypeChanged;
}

@freezed
sealed class CreateCategoryIconChanged extends CreateCategoryEvent
    with _$CreateCategoryIconChanged {
  const CreateCategoryIconChanged._();

  const factory CreateCategoryIconChanged({required String icon}) = _CreateCategoryIconChanged;
}

@freezed
sealed class CreateCategoryParentChanged extends CreateCategoryEvent
    with _$CreateCategoryParentChanged {
  const CreateCategoryParentChanged._();

  const factory CreateCategoryParentChanged({required Category? parent}) =
      _CreateCategoryParentChanged;
}

@freezed
sealed class CreateCategoryParentRemoved extends CreateCategoryEvent
    with _$CreateCategoryParentRemoved {
  const CreateCategoryParentRemoved._();

  const factory CreateCategoryParentRemoved() = _CreateCategoryParentRemoved;
}

@freezed
sealed class CreateCategoryConfirmButtonPressed extends CreateCategoryEvent
    with _$CreateCategoryConfirmButtonPressed {
  const CreateCategoryConfirmButtonPressed._();

  const factory CreateCategoryConfirmButtonPressed(void Function()? onFetchNewCategories) =
      _CreateCategoryConfirmButtonPressed;
}
