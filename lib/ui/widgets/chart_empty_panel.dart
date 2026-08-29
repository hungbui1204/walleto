import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/widgets/common_empty_panel.dart';

/// Empty chart area with optional retry — mint/rose series live in populated state.
class ChartEmptyPanel extends StatelessWidget {
  const ChartEmptyPanel({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CommonEmptyPanel(
        compact: true,
        icon: Icons.bar_chart_outlined,
        message: S.current.noChartData,
        actionLabel: onRetry != null ? S.current.retry : null,
        onAction: onRetry,
      ),
    );
  }
}
