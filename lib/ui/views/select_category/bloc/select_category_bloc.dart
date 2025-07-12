import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'select_category_event.dart';
part 'select_category_state.dart';
part 'select_category_bloc.freezed.dart';

@injectable
class SelectCategoryBloc extends BaseBloc<SelectCategoryEvent, SelectCategoryState> {
  SelectCategoryBloc(this._getCategoriesUseCase) : super(const SelectCategoryState()) {
    on<SelectCategoryViewInitiated>(_onSelectCategoryViewInitiated);
  }

  final GetCategoriesUseCase _getCategoriesUseCase;

  Future<void> _onSelectCategoryViewInitiated(
    SelectCategoryViewInitiated event,
    Emitter<SelectCategoryState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final categoriesOutput = await _getCategoriesUseCase.execute(const GetCategoriesInput());
        final expenseCategories =
            categoriesOutput.categories.where((element) {
              return element.type == CategoryType.expense;
            }).toList();
        final incomeCategories =
            categoriesOutput.categories.where((element) {
              return element.type == CategoryType.income;
            }).toList();

        emit(
          state.copyWith(
            parentExpenseCategories: _buildCategoryTree(expenseCategories),
            parentIncomeCategories: _buildCategoryTree(incomeCategories),
          ),
        );
      },
    );
  }

  // Builds a tree structure of categories from a flat list of categories.
  List<Category> _buildCategoryTree(List<Category> allCategories) {
    final Map<String, Category> categoryMap = {
      for (var category in allCategories) '${category.id}': category,
    };

    for (var category in allCategories) {
      if (category.isParent) {
      } else if (category.parentId != null && categoryMap.containsKey('${category.parentId}')) {
        final parent = categoryMap['${category.parentId}']!;
        categoryMap['${category.parentId}'] = parent.copyWith(
          children: [...parent.children, category],
        );
      }
    }

    return categoryMap.values.where((category) => category.isParent).toList();
  }
}
