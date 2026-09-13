import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class StatisticWidget extends StatefulWidget {
  const StatisticWidget({super.key});

  @override
  State<StatisticWidget> createState() => _StatisticWidgetState();
}

class _StatisticWidgetState extends State<StatisticWidget> {
  int _chartIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CommonTitledPanel(
      titleWidget: Align(
        alignment: Alignment.centerLeft,
        child: Text(S.current.statisticalCharts, style: AppTextStyles.s16wBoldBlack()),
      ),
      contentWidget: Column(
        children: [
          CommonSegmentedControl<int>(
            segments: [
              (value: 0, label: S.current.monthSummary),
              (value: 1, label: S.current.spentStats),
            ],
            selected: _chartIndex,
            onSelected: (index) {
              if (index == _chartIndex) {
                return;
              }
              setState(() => _chartIndex = index);
            },
          ),
          SizedBox(height: Dimens.d16.responsive()),
          SizedBox(
            height: Dimens.d330.responsive(),
            child: IndexedStack(
              index: _chartIndex,
              children: const [_MonthSummaryChartTab(), _SpentStatsChartTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSummaryChartTab extends StatelessWidget {
  const _MonthSummaryChartTab();

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _SpentStatsChartTab extends StatelessWidget {
  const _SpentStatsChartTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) {
                  return previous.selectedCategoryType != current.selectedCategoryType;
                },
                builder: (context, state) {
                  return CommonSegmentedControl<CategoryType>(
                    segments: [
                      (value: CategoryType.expense, label: S.current.expense),
                      (value: CategoryType.income, label: S.current.income),
                    ],
                    selected: state.selectedCategoryType,
                    onSelected: (type) {
                      context.read<HomeBloc>().add(HomeCategoryTypeSelected(categoryType: type));
                    },
                  );
                },
              ),
            ),
            SizedBox(width: Dimens.d8.responsive()),
            const _SpentStatsDateChip(),
          ],
        ),
        SizedBox(height: Dimens.d10.responsive()),
        Expanded(
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) {
              return previous.walletStat != current.walletStat;
            },
            builder: (context, state) {
              return MonthWalletCategoryStatsChart(walletStat: state.walletStat);
            },
          ),
        ),
      ],
    );
  }
}

class _SpentStatsDateChip extends StatelessWidget {
  const _SpentStatsDateChip();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) {
        return previous.selectedDateTime != current.selectedDateTime;
      },
      builder: (context, state) {
        if (state.selectedDateTime == null) {
          return const SizedBox.shrink();
        }

        final label = state.selectedDateTime!.toStringWithFormat(
          DateTimeFormatConstants.monthYearFormat,
        );
        final radius = AppDecorations.chipRadius();

        return Semantics(
          label: label,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: glassHairlineColor),
              color: fieldFillColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.d10.responsive(),
                vertical: Dimens.d8.responsive(),
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
                  Text(label, style: AppTextStyles.s14wNormalBlack()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
