import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class StatisticWidget extends StatelessWidget {
  const StatisticWidget({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      titleWidget: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          S.current.statisticalCharts,
          style: AppTextStyles.s16wBoldBlack(),
        ),
      ),
      contentWidget: AnimatedBuilder(
        animation: tabController,
        builder: (context, _) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ChartTab(
                      label: S.current.monthSummary,
                      selected: tabController.index == 0,
                      onTap: () => tabController.animateTo(0),
                    ),
                  ),
                  SizedBox(width: Dimens.d8.responsive()),
                  Expanded(
                    child: _ChartTab(
                      label: S.current.spentStats,
                      selected: tabController.index == 1,
                      onTap: () => tabController.animateTo(1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimens.d16.responsive()),
              SizedBox(
                height: Dimens.d330.responsive(),
                child: TabBarView(
                  controller: tabController,
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (previous, current) {
                              return previous.monthSummaryStats !=
                                  current.monthSummaryStats;
                            },
                            builder: (context, state) {
                              return MonthSummaryChart(
                                stats: state.monthSummaryStats,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            BlocBuilder<HomeBloc, HomeState>(
                              buildWhen: (previous, current) {
                                return previous.selectedCategoryType !=
                                    current.selectedCategoryType;
                              },
                              builder: (context, state) {
                                return SegmentedButton<CategoryType>(
                                  style: SegmentedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.d12.responsive(),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        Dimens.d12.responsive(),
                                      ),
                                    ),
                                    backgroundColor: fieldFillColor,
                                    selectedBackgroundColor: primaryShadeColor,
                                    selectedForegroundColor: primaryColor,
                                    foregroundColor: darkGreyColor,
                                    side: const BorderSide(
                                      color: glassHairlineColor,
                                    ),
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
                                  selected: {state.selectedCategoryType},
                                  showSelectedIcon: false,
                                  onSelectionChanged: (type) {
                                    context.read<HomeBloc>().add(
                                      HomeCategoryTypeSelected(
                                        categoryType: type.first,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            const Spacer(),
                            BlocBuilder<HomeBloc, HomeState>(
                              buildWhen: (previous, current) {
                                return previous.selectedDateTime !=
                                    current.selectedDateTime;
                              },
                              builder: (context, state) {
                                if (state.selectedDateTime == null) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimens.d10.responsive(),
                                    vertical: Dimens.d8.responsive(),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.d12.responsive(),
                                    ),
                                    border: Border.all(
                                      color: glassHairlineColor,
                                    ),
                                    color: fieldFillColor,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: Dimens.d16.responsive(),
                                        color: darkGreyColor,
                                      ),
                                      SizedBox(width: Dimens.d8.responsive()),
                                      Text(
                                        state.selectedDateTime!
                                            .toStringWithFormat(
                                              DateTimeFormatConstants
                                                  .monthYearFormat,
                                            ),
                                        style: AppTextStyles.s14wNormalBlack(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: Dimens.d10.responsive()),
                        Expanded(
                          child: BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (previous, current) {
                              return previous.walletStat != current.walletStat;
                            },
                            builder: (context, state) {
                              return MonthWalletCategoryStatsChart(
                                walletStat: state.walletStat,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChartTab extends StatelessWidget {
  const _ChartTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: DurationConstants.microInteraction,
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: Dimens.d10.responsive()),
        decoration: BoxDecoration(
          color: selected ? primaryShadeColor : fieldFillColor,
          borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
          border: Border.all(
            color: selected ? primaryColor : glassHairlineColor,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.s14wBoldBlack().copyWith(
            color: selected ? primaryColor : darkGreyColor,
          ),
        ),
      ),
    );
  }
}
