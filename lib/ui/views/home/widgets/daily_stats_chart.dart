import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class DailyStatsChart extends StatelessWidget {
  const DailyStatsChart({super.key, required this.stats});

  final List<DailyStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.4,
        child: ChartEmptyPanel(
          onRetry:
              () => context.read<HomeBloc>().add(const HomeViewInitialized()),
        ),
      );
    }

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
                    child: Text(
                      meta.formattedValue,
                      style: AppTextStyles.s10wNormalGrey(),
                    ),
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
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: frameColor,
                strokeWidth: 0.5,
                dashArray: [4, 3],
              );
            },
          ),
          borderData: FlBorderData(
            border: const Border(
              bottom: BorderSide(color: frameColor),
              left: BorderSide(color: frameColor),
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
                  rod.toY.toStringWithFormat(
                    NumberFormatConstants.amountFormat,
                  ),
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
            width: 8,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.d4.responsive()),
              topRight: Radius.circular(Dimens.d4.responsive()),
            ),
          ),
          BarChartRodData(
            toY: stat.totalExpense,
            color: redColor,
            width: 8,
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
    final day = stats[index].date?.day;

    return SideTitleWidget(
      meta: meta,
      child: Text(day.toString(), style: AppTextStyles.s10wNormalGrey()),
    );
  }

  // Calculate the maximum Y value for the chart based on the stats
  double _getMaxY() {
    if (stats.isEmpty) return 1;
    final maxIncome = stats
        .map((e) => e.totalIncome)
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxExpense = stats
        .map((e) => e.totalExpense)
        .fold(0.0, (a, b) => a > b ? a : b);
    final peak = maxIncome > maxExpense ? maxIncome : maxExpense;
    return peak <= 0 ? 1 : peak * 1.2;
  }
}
