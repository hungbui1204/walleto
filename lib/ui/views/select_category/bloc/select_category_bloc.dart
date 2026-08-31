import 'package:dartx/dartx.dart';
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
    on<SelectCategoryViewInitiated>(_onSelectCategoryViewInitiated, transformer: log());
  }

  final GetCategoriesUseCase _getCategoriesUseCase;

  Future<void> _onSelectCategoryViewInitiated(
    SelectCategoryViewInitiated event,
    Emitter<SelectCategoryState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final categoriesOutput = await _getCategoriesUseCase.execute(const GetCategoriesInput());
        final expenseCategories = categoriesOutput.categories
            .where((element) {
              return element.type == CategoryType.expense;
            })
            .toList()
            .sortedWith((a, b) => a.name.compareTo(b.name));
        final incomeCategories = categoriesOutput.categories
            .where((element) {
              return element.type == CategoryType.income;
            })
            .toList()
            .sortedWith((a, b) => a.name.compareTo(b.name));

        emit(
          state.copyWith(
            parentExpenseCategories: AppUtils.buildCategoryTree(expenseCategories),
            parentIncomeCategories: AppUtils.buildCategoryTree(incomeCategories),
          ),
        );
      },
    );
  }
}
