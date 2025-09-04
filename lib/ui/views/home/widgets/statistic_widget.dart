import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        child: Text(S.current.statisticalCharts, style: AppTextStyles.s16wBoldBlack()),
      ),
      contentWidget: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: [
              Padding(
                padding: EdgeInsets.all(Dimens.d12.responsive()),
                child: Text(
                  S.current.monthSummary,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Dimens.d12.responsive()),
                child: Text(
                  S.current.spentStats,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimens.d16.responsive()),
          SizedBox(
            height: Dimens.d300.responsive(),
            child: TabBarView(
              controller: tabController,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: BlocBuilder<HomeBloc, HomeState>(
                        buildWhen: (previous, current) {
                          return previous.monthSummaryStats != current.monthSummaryStats;
                        },
                        builder: (context, state) {
                          return MonthSummaryChart(stats: state.monthSummaryStats);
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BlocBuilder<HomeBloc, HomeState>(
                      buildWhen: (previous, current) {
                        return previous.selectedDateTime != current.selectedDateTime;
                      },
                      builder: (context, state) {
                        if (state.selectedDateTime == null) return const SizedBox.shrink();

                        return InkWell(
                          borderRadius: BorderRadius.circular(Dimens.d8.responsive()),
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: Dimens.d6.responsive()),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimens.d8.responsive()),
                              border: Border.all(),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_outward_rounded, size: Dimens.d16.responsive()),
                                Assets.icons.calendar.svg(
                                  width: Dimens.d30.responsive(),
                                  height: Dimens.d30.responsive(),
                                ),
                                SizedBox(width: Dimens.d10.responsive()),
                                Text(
                                  state.selectedDateTime!.toStringWithFormat(
                                    DateTimeFormatConstants.monthYearFormat,
                                  ),
                                  style: AppTextStyles.s14wNormalBlack(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: Dimens.d20.responsive()),
                    Expanded(
                      child: BlocBuilder<HomeBloc, HomeState>(
                        buildWhen: (previous, current) {
                          return previous.categoryStats != current.categoryStats;
                        },
                        builder: (context, state) {
                          return MonthCategoryStatsChart(stats: state.categoryStats);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
