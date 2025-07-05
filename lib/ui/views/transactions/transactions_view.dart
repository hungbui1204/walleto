import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Transactions'),
      body: Center(child: Text('Transactions!')),
    );
  }
}
