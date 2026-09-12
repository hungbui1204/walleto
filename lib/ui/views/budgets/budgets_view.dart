import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class BudgetsView extends StatefulWidget {
  const BudgetsView({super.key});

  @override
  State<BudgetsView> createState() => _BudgetsViewState();
}

/// Placeholder kept for future budgets product work. The budgets bottom tab
/// currently opens [AiChatView] as its initial route.
class _BudgetsViewState extends BasePageState<BudgetsView, BudgetsBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.budgets),
      body: NoirScaffoldBody(
        child: Center(
          child: CommonEmptyPanel(
            icon: Icons.pie_chart_outline_rounded,
            message: S.current.budgets,
          ),
        ),
      ),
    );
  }
}
