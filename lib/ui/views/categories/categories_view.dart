import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.categories),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d16.responsive(),
          vertical: Dimens.d16.responsive(),
        ),
        child: Column(
          children: [
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
                  BlocBuilder<CategoriesBloc, CategoriesState>(
                    buildWhen: (previous, current) {
                      return previous.parentExpenseCategories != current.parentExpenseCategories;
                    },
                    builder: (context, state) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimens.d8.responsive()),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: state.parentExpenseCategories.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return SingleChildScrollView(
                              child: CategoryTreeWidget(
                                parentCategory: state.parentExpenseCategories[index],
                                onCategorySelected: (category) {
                                  // TODO: Navigate to category edit page
                                },
                                onParentCategorySelected: (category) {
                                  // TODO: Navigate to category edit page
                                },
                              ),
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
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimens.d8.responsive()),
                        child: ListView.separated(
                          itemCount: state.parentIncomeCategories.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return SingleChildScrollView(
                              child: CategoryTreeWidget(
                                parentCategory: state.parentIncomeCategories[index],
                                onCategorySelected: (category) {
                                  // TODO: Navigate to category edit page
                                },
                                onParentCategorySelected: (category) {
                                  // TODO: Navigate to category edit page
                                },
                              ),
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
    );
  }
}
