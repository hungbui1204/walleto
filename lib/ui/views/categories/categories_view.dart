import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends BasePageState<CategoriesView, CategoriesBloc>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    bloc.add(const CategoriesViewInitiated());
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.categories),
      body: NoirScaffoldBody(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.d16.responsive(),
            vertical: Dimens.d16.responsive(),
          ),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  return CommonSegmentedControl<int>(
                    segments: [
                      (value: 0, label: S.current.expense),
                      (value: 1, label: S.current.income),
                    ],
                    selected: _tabController.index,
                    onSelected: (index) => _tabController.animateTo(index),
                  );
                },
              ),
              SizedBox(height: Dimens.d20.responsive()),
              BlocBuilder<CategoriesBloc, CategoriesState>(
                buildWhen: (previous, current) {
                  return previous.parentIncomeCategories != current.parentIncomeCategories ||
                      previous.parentExpenseCategories != current.parentExpenseCategories;
                },
                builder: (context, state) {
                  return CommonButton(
                    text: S.current.newCategory,
                    onTap: () {
                      navigator.showDialog(
                        AppPopupInfo.createCategory(() {
                          bloc.add(const CategoriesViewInitiated());
                        }),
                      );
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: Dimens.d20.responsive(),
                      color: onPrimaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(Dimens.d16.responsive())),
                  );
                },
              ),
              SizedBox(height: Dimens.d20.responsive()),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    BlocBuilder<CategoriesBloc, CategoriesState>(
                      buildWhen: (previous, current) {
                        return previous.parentExpenseCategories != current.parentExpenseCategories;
                      },
                      builder: (context, state) {
                        if (state.parentExpenseCategories.isEmpty) {
                          return CommonEmptyPanel(
                            icon: Icons.category_outlined,
                            message: S.current.noCategories,
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimens.d8.responsive()),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: state.parentExpenseCategories.length,
                            itemBuilder: (context, index) {
                              return CategoryTreeWidget(
                                parentCategory: state.parentExpenseCategories[index],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(height: Dimens.d20.responsive());
                            },
                          ),
                        );
                      },
                    ),
                    BlocBuilder<CategoriesBloc, CategoriesState>(
                      buildWhen: (previous, current) {
                        return previous.parentIncomeCategories != current.parentIncomeCategories;
                      },
                      builder: (context, state) {
                        if (state.parentIncomeCategories.isEmpty) {
                          return CommonEmptyPanel(
                            icon: Icons.category_outlined,
                            message: S.current.noCategories,
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimens.d8.responsive()),
                          child: ListView.separated(
                            itemCount: state.parentIncomeCategories.length,
                            itemBuilder: (context, index) {
                              return CategoryTreeWidget(
                                parentCategory: state.parentIncomeCategories[index],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(height: Dimens.d20.responsive());
                            },
                          ),
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
