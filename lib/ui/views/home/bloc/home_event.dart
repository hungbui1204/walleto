part of 'home_bloc.dart';

sealed class HomeEvent extends BaseBlocEvent {
  const HomeEvent();
}

@freezed
sealed class HomeViewInitialized extends HomeEvent with _$HomeViewInitialized {
  const HomeViewInitialized._();
  const factory HomeViewInitialized() = _HomeViewInitialized;
}

@freezed
sealed class HomeCategoryTypeSelected extends HomeEvent with _$HomeCategoryTypeSelected {
  const HomeCategoryTypeSelected._();
  const factory HomeCategoryTypeSelected({required CategoryType categoryType}) =
      _HomeCategoryTypeSelected;
}

@freezed
sealed class HomeCurrencySelected extends HomeEvent with _$HomeCurrencySelected {
  const HomeCurrencySelected._();
  const factory HomeCurrencySelected({required String currencyCode}) = _HomeCurrencySelected;
}
