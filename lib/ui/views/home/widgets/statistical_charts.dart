import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class StatisticalCharts extends StatelessWidget {
  const StatisticalCharts({super.key, required this.stats});

  final List<DailyStat> stats;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement another chart
    return CommonContainer(
      titleWidget: Align(
        alignment: Alignment.centerLeft,
        child: Text(S.current.statisticalCharts, style: AppTextStyles.s16wBoldBlack()),
      ),
      contentWidget: AspectRatio(
        aspectRatio: 1.4,
        child: BarChart(
          duration: DurationConstants.defaultChartAnimationDuration,
          curve: Curves.easeInOut,
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            maxY: _getMaxY(),
            barGroups: _buildBarGroups(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
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
                  reservedSize: Dimens.d20.responsive(),
                  getTitlesWidget: _buildBottomTitle,
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
            ),
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            groupsSpace: Dimens.d10.responsive(),
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
            width: 8,
            borderRadius: BorderRadius.circular(Dimens.d4.responsive()),
          ),
          BarChartRodData(
            toY: stat.totalExpense,
            color: redColor,
            width: 8,
            borderRadius: BorderRadius.circular(Dimens.d4.responsive()),
          ),
        ],
      );
    }).toList();
  }

  // Build the bottom title for each bar in the chart
  Widget _buildBottomTitle(double value, TitleMeta meta) {
    final index = value.toInt();
    final day = stats[index].date?.day;

    return SideTitleWidget(
      meta: meta,
      child: Text(day.toString(), style: AppTextStyles.s10wNormalBlack()),
    );
  }

  // Calculate the maximum Y value for the chart based on the stats
  double _getMaxY() {
    final maxIncome = stats.map((e) => e.totalIncome).fold(0.0, (a, b) => a > b ? a : b);
    final maxExpense = stats.map((e) => e.totalExpense).fold(0.0, (a, b) => a > b ? a : b);
    return (maxIncome > maxExpense ? maxIncome : maxExpense);
  }
}
