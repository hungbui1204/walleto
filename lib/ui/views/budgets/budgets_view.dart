import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class BudgetsView extends StatefulWidget {
  const BudgetsView({super.key});

  @override
  State<BudgetsView> createState() => _BudgetsViewState();
}

class _BudgetsViewState extends State<BudgetsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CommonAppBar(title: 'Budgets'), body: Center(child: Text('Budgets!')));
  }
}
