import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends BasePageState<TransactionsView, TransactionsBloc> {
  @override
  void initState() {
    bloc.add(const TransactionsViewInitialized());
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.transactions),
      body: Column(
        children: [
          SizedBox(height: Dimens.d20.responsive()),
          BlocBuilder<TransactionsBloc, TransactionsState>(
            buildWhen: (previous, current) {
              return previous.allDayTransactions != current.allDayTransactions;
            },
            builder: (context, state) {
              if (state.allDayTransactions.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                itemCount: state.allDayTransactions.length,
                itemBuilder: (context, index) {
                  return SizedBox();
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: Dimens.d20.responsive());
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayTransactionsWidget extends StatelessWidget {
  const _DayTransactionsWidget(this.dayTransactions);

  final DayTransactions dayTransactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (dayTransactions.date != null)
          Row(
            children: [
              Text('${dayTransactions.date!.day}'),
              Column(
                children: [
                  Text(AppUtils.mapWeekDayToString(dayTransactions.date!.weekday)),
                  Row(
                    children: [
                      Text(AppUtils.mapMonthToString(dayTransactions.date!.month)),
                      Text('${dayTransactions.date!.year}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
