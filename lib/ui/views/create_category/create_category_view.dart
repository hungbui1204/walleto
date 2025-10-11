import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class CreateCategoryView extends StatefulWidget {
  const CreateCategoryView({super.key, this.onFetchNewCategories});

  final void Function()? onFetchNewCategories;

  @override
  State<CreateCategoryView> createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends BasePageState<CreateCategoryView, CreateCategoryBloc> {
  late final TextEditingController _categoryNameController;

  @override
  void initState() {
    super.initState();
    _categoryNameController = TextEditingController();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context) {
    return GestureDetector(
      onTap: () => ViewUtils.hideKeyboard(context),
      child: Scaffold(
        appBar: CommonAppBar(title: S.current.newCategory),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(Dimens.d16.responsive()),
            child: Column(
              children: [
                SizedBox(height: Dimens.d20.responsive()),
                Container(
                  padding: EdgeInsets.all(Dimens.d10.responsive()),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
                    border: Border.all(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              // TODO: implement choosing category icon
                            },
                            child: CommonCircleNetworkImage(
                              imageUrl: '',
                              size: Dimens.d36.responsive(),
                            ),
                          ),
                          SizedBox(width: Dimens.d10.responsive()),
                          Expanded(
                            child: CommonTextField2(
                              controller: _categoryNameController,
                              hintText: S.current.nameYourCategoryHere,
                              onChanged: (name) {
                                bloc.add(CreateCategoryNameInputChanged(categoryName: name));
                              },
                            ),
                          ),
                        ],
                      ),
                      const CommonLine(),
                      Row(
                        children: [
                          Icon(
                            Icons.legend_toggle_rounded,
                            color: primaryColor,
                            size: Dimens.d28.responsive(),
                          ),
                          SizedBox(width: Dimens.d8.responsive()),
                          BlocBuilder<CreateCategoryBloc, CreateCategoryState>(
                            buildWhen: (previous, current) {
                              return previous.categoryType != current.categoryType;
                            },
                            builder: (context, state) {
                              return SegmentedButton<CategoryType>(
                                style: SegmentedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimens.d12.responsive(),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Dimens.d4.responsive()),
                                  ),
                                  backgroundColor: whiteColor,
                                  selectedBackgroundColor: secondaryColor,
                                  selectedForegroundColor: blackColor,
                                  foregroundColor: blackColor,
                                ),
                                segments: [
                                  ButtonSegment(
                                    value: CategoryType.expense,
                                    label: Text(S.current.expense),
                                  ),
                                  ButtonSegment(
                                    value: CategoryType.income,
                                    label: Text(S.current.income),
                                  ),
                                ],
                                selected: {state.categoryType},
                                showSelectedIcon: false,
                                onSelectionChanged: (type) {
                                  bloc.add(CreateCategoryTypeChanged(categoryType: type.first));
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const CommonLine(),
                      BlocBuilder<CreateCategoryBloc, CreateCategoryState>(
                        buildWhen:
                            (previous, current) =>
                                previous.parent != current.parent ||
                                previous.categoryType != current.categoryType,
                        builder: (context, state) {
                          return InkWell(
                            onTap: () {
                              navigator.showDialog(
                                AppPopupInfo.selectCategory(
                                  isSelectingParent: true,
                                  categoryType: state.categoryType,
                                  onCategorySelected: (category) {
                                    bloc.add(CreateCategoryParentChanged(parent: category));
                                  },
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Positioned(
                                  left: Dimens.d30.responsive(),
                                  child: Text(
                                    S.current.parentCategory,
                                    style: AppTextStyles.s10wNormalBlack(),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimens.d8.responsive()),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.category_rounded,
                                        color: primaryColor,
                                        size: Dimens.d28.responsive(),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(height: Dimens.d4.responsive()),
                                          if (state.parent != null)
                                            Text(
                                              state.parent!.name,
                                              style: AppTextStyles.s16wNormalBlack(),
                                            )
                                          else
                                            Text(
                                              S.current.selectCategory,
                                              style: AppTextStyles.s15wNormalGrey().copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (state.parent == null)
                                        Icon(Icons.arrow_forward_ios, size: Dimens.d14.responsive())
                                      else
                                        GestureDetector(
                                          onTap: () {
                                            bloc.add(const CreateCategoryParentRemoved());
                                          },
                                          child: Icon(Icons.close, size: Dimens.d20.responsive()),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimens.d30.responsive()),
                BlocBuilder<CreateCategoryBloc, CreateCategoryState>(
                  buildWhen: (previous, current) {
                    return previous.confirmButtonEnable != current.confirmButtonEnable;
                  },
                  builder: (context, state) {
                    return CommonButton(
                      text: S.current.save,
                      onTap:
                          state.confirmButtonEnable
                              ? () {
                                context.read<CreateCategoryBloc>().add(
                                  CreateCategoryConfirmButtonPressed(widget.onFetchNewCategories),
                                );
                              }
                              : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
