import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class SelectCategoryPopup extends StatefulWidget {
  const SelectCategoryPopup({
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
  State<SelectCategoryPopup> createState() => _SelectCategoryPopupState();
}

class _SelectCategoryPopupState extends BasePageState<SelectCategoryPopup, SelectCategoryBloc>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController =
        widget.categoryType == null
            ? TabController(length: 2, vsync: this)
            : TabController(length: 1, vsync: this);
    bloc.add(const SelectCategoryViewInitiated());
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> buildTabBar() {
    switch (widget.categoryType) {
      case CategoryType.expense:
        return [_SelectCategoryTabLabel(S.current.expense)];
      case CategoryType.income:
        return [_SelectCategoryTabLabel(S.current.income)];
      case null:
        return [
          _SelectCategoryTabLabel(S.current.expense),
          _SelectCategoryTabLabel(S.current.income),
        ];
    }
  }

  List<Widget> buildTabBarView() {
    switch (widget.categoryType) {
      case CategoryType.expense:
        return [
          _ExpenseCategoryTab(
            onCategorySelected: widget.onCategorySelected,
            isSelectingParent: widget.isSelectingParent,
          ),
        ];
      case CategoryType.income:
        return [
          _IncomeCategoryTab(
            onCategorySelected: widget.onCategorySelected,
            isSelectingParent: widget.isSelectingParent,
          ),
        ];
      case null:
        return [
          _ExpenseCategoryTab(
            onCategorySelected: widget.onCategorySelected,
            isSelectingParent: widget.isSelectingParent,
          ),
          _IncomeCategoryTab(
            onCategorySelected: widget.onCategorySelected,
            isSelectingParent: widget.isSelectingParent,
          ),
        ];
    }
  }

  @override
  Widget buildPage(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxHeight: context.mediaQuery.size.height * 0.7),
          margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.d16.responsive(),
            vertical: Dimens.d20.responsive(),
          ),
          decoration: AppDecorations.glassPanel(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.current.selectCategory, style: AppTextStyles.s20wNormalBlack()),
              TabBar(controller: _tabController, tabs: buildTabBar()),
              SizedBox(height: Dimens.d20.responsive()),
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
                  borderRadius: BorderRadius.all(Radius.circular(Dimens.d16.responsive())),
                ),
                SizedBox(height: Dimens.d20.responsive()),
              ],
              Expanded(child: TabBarView(controller: _tabController, children: buildTabBarView())),
            ],
          ),
        ),
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
          shrinkWrap: true,
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
          itemCount: state.parentIncomeCategories.length,
          shrinkWrap: true,
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

class _SelectCategoryTabLabel extends StatelessWidget {
  const _SelectCategoryTabLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimens.d12.responsive()),
      child: Text(
        label,
        style: AppTextStyles.s15wBoldBlack().copyWith(
          color: DefaultTextStyle.of(context).style.color,
        ),
      ),
    );
  }
}
