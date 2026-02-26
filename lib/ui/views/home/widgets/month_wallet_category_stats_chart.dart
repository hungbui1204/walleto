import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class MonthWalletCategoryStatsChart extends StatefulWidget {
  const MonthWalletCategoryStatsChart({super.key, required this.walletStat});

  final WalletStat walletStat;

  @override
  State<MonthWalletCategoryStatsChart> createState() => _MonthWalletCategoryStatsChartState();
}

class _MonthWalletCategoryStatsChartState extends State<MonthWalletCategoryStatsChart> {
  int _touchedIndex = -1;

  void _handleTap(int index) {
    setState(() {
      if (_touchedIndex == index) {
        _touchedIndex = -1;
      } else {
        _touchedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${S.current.topWallet}: ${widget.walletStat.walletName}',
          style: AppTextStyles.s16wBoldPrimary(),
        ),
        Text(
          '${S.current.total}: ${widget.walletStat.totalAmount.toStringWithFormat(NumberFormatConstants.amountFormat)} ${widget.walletStat.currencyCode}',
          style: AppTextStyles.s14wNormalBlack(),
        ),
        SizedBox(height: Dimens.d16.responsive()),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieSections(widget.walletStat.categoryStats),
                    sectionsSpace: Dimens.d2.responsive(),
                    centerSpaceRadius: Dimens.d50.responsive(),
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (response?.touchedSection != null && event is FlTapUpEvent) {
                          _handleTap(response!.touchedSection!.touchedSectionIndex);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.walletStat.categoryStats.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Container(
                          width: Dimens.d12.responsive(),
                          height: Dimens.d12.responsive(),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getColorForIndex(index),
                          ),
                        ),
                        SizedBox(width: Dimens.d8.responsive()),
                        Expanded(
                          child: Text(
                            widget.walletStat.categoryStats[index].categoryName,
                            style: AppTextStyles.s14wNormalBlack(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(List<CategoryStat> stats) {
    return List.generate(stats.length, (index) {
      final stat = stats[index];
      final isTouched = index == _touchedIndex;
      final total = stats.fold<double>(0, (sum, e) => sum + e.totalAmount);
      final double radius = isTouched ? Dimens.d60.responsive() : Dimens.d50.responsive();
      final title =
          isTouched
              ? stat.totalAmount.round().toCompactString()
              : '${((stat.totalAmount / total) * 100).toStringAsFixed(1)}%';

      final badgeWidget =
          isTouched
              ? CommonCircleNetworkImage(
                imageUrl: stat.categoryIconUrl,
                size: Dimens.d24.responsive(),
              )
              : null;

      return PieChartSectionData(
        badgeWidget: badgeWidget,
        value: stat.totalAmount,
        color: _getColorForIndex(index),
        radius: radius,
        title: title,
        titleStyle: AppTextStyles.s14wNormalBlack(),
        badgePositionPercentageOffset: .98,
      );
    });
  }

  Color _getColorForIndex(int index) {
    const colors = AppConstants.pieChartColors;

    return colors[index % colors.length];
  }
}
