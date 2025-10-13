import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'create_category_event.dart';
part 'create_category_state.dart';
part 'create_category_bloc.freezed.dart';

@injectable
class CreateCategoryBloc extends BaseBloc<CreateCategoryEvent, CreateCategoryState> {
  CreateCategoryBloc(this._createCategoryUseCase) : super(const CreateCategoryState()) {
    on<CreateCategoryViewInitiated>(_onCreateCategoryViewInitiated);
    on<CreateCategoryNameInputChanged>(_onCreateCategoryNameInputChanged);
    on<CreateCategoryConfirmButtonPressed>(_onCreateCategoryConfirmButtonPressed);
    on<CreateCategoryTypeChanged>(_onCreateCategoryTypeChanged);
    on<CreateCategoryParentChanged>(_onCreateCategoryParentChanged);
    on<CreateCategoryParentRemoved>(_onCreateCategoryParentRemoved);
    on<CreateCategoryIconChanged>(_onCreateCategoryIconChanged);
  }

  final CreateCategoryUseCase _createCategoryUseCase;

  bool isConfirmButtonEnabled(String categoryName) {
    return categoryName.isNotEmpty;
  }

  void _onCreateCategoryViewInitiated(
    CreateCategoryViewInitiated event,
    Emitter<CreateCategoryState> emit,
  ) {}

  void _onCreateCategoryNameInputChanged(
    CreateCategoryNameInputChanged event,
    Emitter<CreateCategoryState> emit,
  ) {
    emit(
      state.copyWith(
        categoryName: event.categoryName,
        confirmButtonEnable: isConfirmButtonEnabled(event.categoryName),
      ),
    );
  }

  void _onCreateCategoryTypeChanged(
    CreateCategoryTypeChanged event,
    Emitter<CreateCategoryState> emit,
  ) {
    if (event.categoryType == state.categoryType) return;

    // Clear selected parent when category type changes

    emit(state.copyWith(categoryType: event.categoryType, parent: null));
  }

  void _onCreateCategoryParentChanged(
    CreateCategoryParentChanged event,
    Emitter<CreateCategoryState> emit,
  ) {
    emit(state.copyWith(parent: event.parent));
  }

  void _onCreateCategoryParentRemoved(
    CreateCategoryParentRemoved event,
    Emitter<CreateCategoryState> emit,
  ) {
    emit(state.copyWith(parent: null));
  }

  Future<void> _onCreateCategoryConfirmButtonPressed(
    CreateCategoryConfirmButtonPressed event,
    Emitter<CreateCategoryState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final newCategory = Category(
          name: state.categoryName,
          type: state.categoryType,
          iconUrl: state.icon,
          parentId: state.parent?.id,
          isParent: state.parent == null,
        );

        await _createCategoryUseCase.execute(CreateCategoryInput(category: newCategory));
        event.onFetchNewCategories?.call();

        navigator.pop(useRootNavigator: true);
      },
    );
  }

  void _onCreateCategoryIconChanged(
    CreateCategoryIconChanged event,
    Emitter<CreateCategoryState> emit,
  ) {
    emit(state.copyWith(icon: event.icon));
  }
}
