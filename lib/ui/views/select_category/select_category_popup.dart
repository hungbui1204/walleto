import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class SelectCategoryPopup extends StatefulWidget {
  const SelectCategoryPopup({super.key, required this.onCategorySelected});

  final void Function(Category) onCategorySelected;

  @override
  State<SelectCategoryPopup> createState() => _SelectCategoryPopupState();
}

class _SelectCategoryPopupState extends BasePageState<SelectCategoryPopup, SelectCategoryBloc>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    bloc.add(const SelectCategoryViewInitiated());
    super.initState();
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
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.current.selectCategory, style: AppTextStyles.s20wNormalBlack()),
              TabBar(
                controller: _tabController,
                tabs: [
                  Padding(
                    padding: EdgeInsets.all(Dimens.d12.responsive()),
                    child: Text(
                      S.current.expense,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(Dimens.d12.responsive()),
                    child: Text(
                      S.current.income,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimens.d20.responsive()),
              CommonButton(
                text: S.current.newCategory,
                backgroundColor: secondaryColor,
                onTap: () {
                  // TODO: Add create category logic here
                },
                icon: Icon(
                  Icons.add_circle_outline,
                  size: Dimens.d20.responsive(),
                  color: blackColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(Dimens.d16.responsive())),
              ),
              SizedBox(height: Dimens.d20.responsive()),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    BlocBuilder<SelectCategoryBloc, SelectCategoryState>(
                      buildWhen: (previous, current) {
                        return previous.parentExpenseCategories != current.parentExpenseCategories;
                      },
                      builder: (context, state) {
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: state.parentExpenseCategories.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return _CategoryTreeWidget(
                              parentCategory: state.parentExpenseCategories[index],
                              onCategorySelected: widget.onCategorySelected,
                              onParentCategorySelected: widget.onCategorySelected,
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: Dimens.d20.responsive());
                          },
                        );
                      },
                    ),
                    BlocBuilder<SelectCategoryBloc, SelectCategoryState>(
                      buildWhen: (previous, current) {
                        return previous.parentIncomeCategories != current.parentIncomeCategories;
                      },
                      builder: (context, state) {
                        return ListView.separated(
                          itemCount: state.parentIncomeCategories.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return _CategoryTreeWidget(
                              parentCategory: state.parentIncomeCategories[index],
                              onCategorySelected: widget.onCategorySelected,
                              onParentCategorySelected: widget.onCategorySelected,
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: Dimens.d20.responsive());
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTreeWidget extends StatelessWidget {
  const _CategoryTreeWidget({
    required this.parentCategory,
    required this.onCategorySelected,
    required this.onParentCategorySelected,
  });

  final Category parentCategory;
  final void Function(Category) onCategorySelected;
  final void Function(Category) onParentCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.d10.responsive()),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
        border: Border.all(),
      ),
      child: Column(
        children: [
          _ParentCategoryWidget(
            category: parentCategory,
            onCategorySelected: onParentCategorySelected,
          ),
          if (parentCategory.children.isNotEmpty) ...[
            SizedBox(height: Dimens.d20.responsive()),
            ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: parentCategory.children.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _CategoryWidget(
                  category: parentCategory.children[index],
                  onCategorySelected: onCategorySelected,
                );
              },
              separatorBuilder: (context, index) {
                return CommonLine(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ParentCategoryWidget extends StatelessWidget {
  const _ParentCategoryWidget({required this.category, required this.onCategorySelected});

  final Category category;
  final void Function(Category) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transParentColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
        onTap: () {
          onCategorySelected.call(category);
          getIt.get<AppNavigator>().pop(useRootNavigator: true);
        },
        child: Row(
          children: [
            CommonCircleNetworkImage(
              imageUrl: category.iconUrl,
              size: Dimens.d38.responsive(),
              backgroundColor: secondaryColor,
            ),
            SizedBox(width: Dimens.d20.responsive()),
            Text(category.name, style: AppTextStyles.s18wNormalBlack()),
          ],
        ),
      ),
    );
  }
}

class _CategoryWidget extends StatelessWidget {
  const _CategoryWidget({required this.category, required this.onCategorySelected});

  final Category category;
  final void Function(Category) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transParentColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
        onTap: () {
          onCategorySelected.call(category);
          getIt.get<AppNavigator>().pop(useRootNavigator: true);
        },
        child: Row(
          children: [
            SizedBox(width: Dimens.d20.responsive()),
            CommonCircleNetworkImage(imageUrl: category.iconUrl),
            SizedBox(width: Dimens.d20.responsive()),
            Text(category.name, style: AppTextStyles.s14wNormalBlack()),
          ],
        ),
      ),
    );
  }
}
