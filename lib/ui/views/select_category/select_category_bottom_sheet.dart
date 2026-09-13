import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class SelectCategoryBottomSheet extends StatefulWidget {
  const SelectCategoryBottomSheet({
    super.key,
    required this.onCategorySelected,
    this.isSelectingParent = false,
    this.categoryType,
  });

  final void Function(Category) onCategorySelected;

  // If true, it means we are selecting a parent category
  final bool isSelectingParent;

  // If not null, just only show categories of this type
  final CategoryType? categoryType;

  @override
  State<SelectCategoryBottomSheet> createState() => _SelectCategoryBottomSheetState();
}

class _SelectCategoryBottomSheetState
    extends BasePageState<SelectCategoryBottomSheet, SelectCategoryBloc> {
  late CategoryType _selectedType;

  @override
  void initState() {
    _selectedType = widget.categoryType ?? CategoryType.expense;
    bloc.add(const SelectCategoryViewInitiated());
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonPickerSheet(
      title: S.current.selectCategory,
      expandChild: true,
      child: Column(
        children: [
          if (widget.categoryType == null) ...[
            CommonSegmentedControl<CategoryType>(
              segments: [
                (value: CategoryType.expense, label: S.current.expense),
                (value: CategoryType.income, label: S.current.income),
              ],
              selected: _selectedType,
              onSelected: (type) => setState(() => _selectedType = type),
            ),
            SizedBox(height: Dimens.d20.responsive()),
          ],
          if (!widget.isSelectingParent) ...[
            CommonButton(
              text: S.current.newCategory,
              onTap: () {
                navigator.showDialog(
                  AppPopupInfo.createCategory(() {
                    bloc.add(const SelectCategoryViewInitiated());
                  }),
                );
              },
              icon: Icon(
                Icons.add_circle_outline,
                size: Dimens.d20.responsive(),
                color: onPrimaryColor,
              ),
              borderRadius: AppDecorations.panelRadius(),
            ),
            SizedBox(height: Dimens.d20.responsive()),
          ],
          Expanded(
            child:
                _selectedType == CategoryType.income
                    ? _IncomeCategoryTab(
                      onCategorySelected: widget.onCategorySelected,
                      isSelectingParent: widget.isSelectingParent,
                    )
                    : _ExpenseCategoryTab(
                      onCategorySelected: widget.onCategorySelected,
                      isSelectingParent: widget.isSelectingParent,
                    ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCategoryTab extends StatelessWidget {
  const _ExpenseCategoryTab({required this.onCategorySelected, this.isSelectingParent = false});

  final void Function(Category) onCategorySelected;
  final bool isSelectingParent;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectCategoryBloc, SelectCategoryState>(
      buildWhen: (previous, current) {
        return previous.parentExpenseCategories != current.parentExpenseCategories;
      },
      builder: (context, state) {
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: state.parentExpenseCategories.length,
          itemBuilder: (context, index) {
            return CategoryTreeWidget(
              isSelectingParent: isSelectingParent,
              parentCategory: state.parentExpenseCategories[index],
              onCategorySelected: onCategorySelected,
              onParentCategorySelected: onCategorySelected,
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: Dimens.d20.responsive());
          },
        );
      },
    );
  }
}

class _IncomeCategoryTab extends StatelessWidget {
  const _IncomeCategoryTab({required this.onCategorySelected, this.isSelectingParent = false});

  final void Function(Category) onCategorySelected;
  final bool isSelectingParent;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectCategoryBloc, SelectCategoryState>(
      buildWhen: (previous, current) {
        return previous.parentIncomeCategories != current.parentIncomeCategories;
      },
      builder: (context, state) {
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: state.parentIncomeCategories.length,
          itemBuilder: (context, index) {
            return CategoryTreeWidget(
              parentCategory: state.parentIncomeCategories[index],
              onCategorySelected: onCategorySelected,
              onParentCategorySelected: onCategorySelected,
              isSelectingParent: isSelectingParent,
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: Dimens.d20.responsive());
          },
        );
      },
    );
  }
}
