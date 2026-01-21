import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class EditTransactionView extends StatefulWidget {
  const EditTransactionView({super.key, required this.transaction});

  final Transaction transaction;

  @override
  State<EditTransactionView> createState() => _EditTransactionViewState();
}

class _EditTransactionViewState extends BasePageState<EditTransactionView, EditTransactionBloc> {
  @override
  void initState() {
    bloc.add(EditTransactionViewInitiated(widget.transaction));
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.editTransaction),
      body: Column(children: []),
    );
  }
}
