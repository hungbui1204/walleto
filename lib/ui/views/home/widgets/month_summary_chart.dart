import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

class MonthSummaryChart extends StatelessWidget {
  const MonthSummaryChart({super.key, required this.stats});

  final List<MonthSummaryStat> stats;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: BarChart(
        duration: DurationConstants.defaultChartAnimationDuration,
        curve: Curves.easeInOut,
        BarChartData(
          maxY: _getMaxY(),
          barGroups: _buildBarGroups(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                maxIncluded: false,
                showTitles: true,
                reservedSize: Dimens.d36.responsive(),
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(meta.formattedValue, style: AppTextStyles.s10wNormalBlack()),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: Dimens.d30.responsive(),
                getTitlesWidget: _buildBottomTitle,
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return const FlLine(color: greyColor, strokeWidth: 0.5, dashArray: [4, 3]);
            },
          ),
          borderData: FlBorderData(
            border: const Border(
              bottom: BorderSide(color: greyColor),
              left: BorderSide(color: greyColor),
            ),
          ),
          groupsSpace: Dimens.d10.responsive(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipMargin: Dimens.d4.responsive(),
              tooltipPadding: EdgeInsets.all(
                Dimens.d8.responsive(),
              ).copyWith(bottom: 0, top: Dimens.d4.responsive()),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toStringWithFormat(NumberFormatConstants.amountFormat),
                  rod.color == greenColor
                      ? AppTextStyles.s10wNormalGreen()
                      : AppTextStyles.s10wNormalRed(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return stats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: stat.totalIncome,
            color: greenColor,
            width: Dimens.d60.responsive(),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.d4.responsive()),
              topRight: Radius.circular(Dimens.d4.responsive()),
            ),
          ),
          BarChartRodData(
            toY: stat.totalExpense,
            color: redColor,
            width: Dimens.d60.responsive(),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.d4.responsive()),
              topRight: Radius.circular(Dimens.d4.responsive()),
            ),
          ),
        ],
      );
    }).toList();
  }

  // Build the bottom title for each bar in the chart
  Widget _buildBottomTitle(double value, TitleMeta meta) {
    final index = value.toInt();
    final targetMonth = stats[index].targetMonth.displayName;

    return SideTitleWidget(
      meta: meta,
      child: Text(targetMonth, style: AppTextStyles.s14wNormalBlack()),
    );
  }

  // Calculate the maximum Y value for the chart based on the stats
  double _getMaxY() {
    final maxIncome = stats.map((e) => e.totalIncome).fold(0.0, (a, b) => a > b ? a : b);
    final maxExpense = stats.map((e) => e.totalExpense).fold(0.0, (a, b) => a > b ? a : b);
    return (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
  }
}
