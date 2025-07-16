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
  Widget buildPageListeners({required Widget child}) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) {
        return previous.needReloadTransactions != current.needReloadTransactions &&
            current.needReloadTransactions;
      },
      listener: (context, state) {
        // Reload transactions when the app state indicates a need to reload
        bloc.add(const TransactionsViewInitialized());
        // Reset the needReloadTransactions flag
        appBloc.add(const TransactionsReloaded(needReloadTransactions: false));
      },
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.transactions),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Dimens.d20.responsive()),
              BlocBuilder<TransactionsBloc, TransactionsState>(
                buildWhen: (previous, current) {
                  return previous.allDayTransactions != current.allDayTransactions;
                },
                builder: (context, state) {
                  if (state.allDayTransactions.isEmpty) return const SizedBox.shrink();

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.allDayTransactions.length,
                    itemBuilder: (context, index) {
                      if (state.allDayTransactions.isEmpty) return const SizedBox.shrink();

                      return _DayTransactionsWidget(state.allDayTransactions[index]);
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: Dimens.d20.responsive());
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayTransactionsWidget extends StatelessWidget {
  const _DayTransactionsWidget(this.dayTransactions);

  final DayTransactions dayTransactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
        border: Border.all(),
      ),
      padding: EdgeInsets.all(Dimens.d10.responsive()),
      child: Column(
        children: [
          if (dayTransactions.date != null)
            Row(
              children: [
                Text('${dayTransactions.date!.day}', style: AppTextStyles.s28wBoldBlack()),
                SizedBox(width: Dimens.d10.responsive()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppUtils.mapWeekDayToString(dayTransactions.date!.weekday)),
                    Row(
                      children: [
                        Text(AppUtils.mapMonthToString(dayTransactions.date!.month)),
                        SizedBox(width: Dimens.d4.responsive()),
                        Text('${dayTransactions.date!.year}'),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text('${dayTransactions.totalAmount.toInt()}'),
              ],
            ),
          SizedBox(height: Dimens.d10.responsive()),
          if (dayTransactions.transactions.isNotEmpty)
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: dayTransactions.transactions.length,
              itemBuilder: (context, index) {
                final transaction = dayTransactions.transactions[index];

                return _TransactionInfoWidget(transaction);
              },
              separatorBuilder: (context, index) {
                return const CommonLine();
              },
            ),
        ],
      ),
    );
  }
}

class _TransactionInfoWidget extends StatelessWidget {
  const _TransactionInfoWidget(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CommonCircleNetworkImage(imageUrl: transaction.category.iconUrl),
        SizedBox(width: Dimens.d10.responsive()),
        Text(transaction.category.name),
        const Spacer(),
        Text('${transaction.amount.toInt()}'),
      ],
    );
  }
}
