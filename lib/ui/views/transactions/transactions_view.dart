import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState
    extends BasePageState<TransactionsView, TransactionsBloc> {
  @override
  void initState() {
    bloc.add(const TransactionsViewInitialized());
    super.initState();
  }

  @override
  Widget buildPageListeners({required Widget child}) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) {
        return previous.needReloadTransactions !=
                current.needReloadTransactions &&
            current.needReloadTransactions;
      },
      listener: (context, state) {
        // Reload transactions when the app state indicates a need to reload
        bloc.add(const TransactionsRefreshed());
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
      body: NoirScaffoldBody(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Dimens.d12.responsive()),
                const Center(child: _SelectedWalletWidget()),
                SizedBox(height: Dimens.d20.responsive()),
                const _DatePickerDropDownWidget(),
                SizedBox(height: Dimens.d20.responsive()),
                BlocBuilder<TransactionsBloc, TransactionsState>(
                  buildWhen: (previous, current) {
                    return previous.allDayTransactions !=
                        current.allDayTransactions;
                  },
                  builder: (context, state) {
                    if (state.allDayTransactions.isEmpty) {
                      return CommonEmptyPanel(
                        icon: Icons.receipt_long_outlined,
                        message: S.current.noRecentTransactions,
                        actionLabel: S.current.addTransaction,
                        onAction: () {
                          getIt.get<AppNavigator>().push(
                            const AppRouteInfo.createTransaction(),
                          );
                        },
                      );
                    }

                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.allDayTransactions.length,
                      itemBuilder: (context, index) {
                        if (state.allDayTransactions.isEmpty)
                          return const SizedBox.shrink();

                        return _DayTransactionsWidget(
                          state.allDayTransactions[index],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: Dimens.d20.responsive());
                      },
                    );
                  },
                ),
                SizedBox(height: Dimens.d24.responsive()),
              ],
            ),
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
    return CommonContainer(
      titleWidget:
          dayTransactions.date == null
              ? null
              : Row(
                children: [
                  Text(
                    '${dayTransactions.date!.day}',
                    style: AppTextStyles.s28wBoldBlack(),
                  ),
                  SizedBox(width: Dimens.d10.responsive()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppUtils.mapWeekDayToString(
                          dayTransactions.date!.weekday,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            AppUtils.mapMonthToString(
                              dayTransactions.date!.month,
                            ),
                          ),
                          SizedBox(width: Dimens.d4.responsive()),
                          Text('${dayTransactions.date!.year}'),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  CommonAmountWithSymbol(
                    amount: dayTransactions.totalAmount,
                    currencyCode: dayTransactions.currencyCode,
                  ),
                ],
              ),
      contentWidget:
          dayTransactions.transactions.isEmpty
              ? null
              : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: dayTransactions.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = dayTransactions.transactions[index];

                  return _TransactionInfoWidget(transaction);
                },
                separatorBuilder: (context, index) {
                  return const CommonLine(color: frameColor);
                },
              ),
    );
  }
}

class _TransactionInfoWidget extends StatelessWidget {
  const _TransactionInfoWidget(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        getIt.get<AppNavigator>().push(
          AppRouteInfo.transactionDetail(transaction: transaction),
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: Dimens.d44.responsive()),
        child: Row(
          children: [
            CommonCircleNetworkImage(
              imageUrl: transaction.category.iconUrl,
              backgroundColor: primaryShadeColor,
            ),
            SizedBox(width: Dimens.d10.responsive()),
            Expanded(
              child: Text(
                transaction.category.name,
                style: AppTextStyles.s14wNormalBlack(),
              ),
            ),
            CommonAmountWithSymbol(
              amount: transaction.amount,
              currencyCode: transaction.currencyCode,
              textStyle: AppThemes.amount(
                fontSize: Dimens.d14.responsive(),
                color:
                    transaction.type == CategoryType.expense
                        ? redColor
                        : greenColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerDropDownWidget extends StatelessWidget {
  const _DatePickerDropDownWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      buildWhen: (previous, current) {
        return previous.selectedDate != current.selectedDate ||
            previous.selectedDateRange != current.selectedDateRange ||
            previous.isDatePickerMethodExpanded !=
                current.isDatePickerMethodExpanded;
      },
      builder: (context, state) {
        return Container(
          decoration: AppDecorations.glassPanel(),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  context.read<TransactionsBloc>().add(
                    const TransactionsDatePickerMethodExpandTriggered(),
                  );
                },
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: Dimens.d44.responsive(),
                  ),
                  padding: EdgeInsets.all(Dimens.d10.responsive()),
                  child: Row(
                    children: [
                      Icon(
                        state.isDatePickerMethodExpanded
                            ? Icons.arrow_drop_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        size: Dimens.d26.responsive(),
                        color: darkGreyColor,
                      ),
                      Assets.icons.calendar.svg(
                        width: Dimens.d30.responsive(),
                        height: Dimens.d30.responsive(),
                      ),
                      SizedBox(width: Dimens.d10.responsive()),
                      if (state.selectedDate != null)
                        Text(
                          state.selectedDate!.toStringWithFormat(
                            DateTimeFormatConstants.monthYearFormat,
                          ),
                          style: AppTextStyles.s14wNormalBlack(),
                        ),
                      if (state.selectedDateRange != null)
                        Text(
                          '${state.selectedDateRange!.start.toStringWithFormat(DateTimeFormatConstants.dayMonthYearFormat)} - ${state.selectedDateRange!.end.toStringWithFormat(DateTimeFormatConstants.dayMonthYearFormat)}',
                          style: AppTextStyles.s14wNormalBlack(),
                        ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 300),
                child:
                    state.isDatePickerMethodExpanded
                        ? Column(
                          children: [
                            const CommonLine(margin: EdgeInsets.zero),
                            CommonForwardButton(
                              title: S.current.filterByMonth,
                              color: surfaceColor,
                              showBorder: false,
                              borderRadius: BorderRadius.zero,
                              onTap: () {
                                getIt.get<AppNavigator>().showDialog(
                                  AppPopupInfo.selectMonth(
                                    firstYear: AppConstants.firstYear,
                                    lastYear: AppConstants.lastYear,
                                    onMonthSelected: (date) {
                                      context.read<TransactionsBloc>().add(
                                        TransactionsMonthSelected(
                                          selectedDate: date,
                                        ),
                                      );
                                    },
                                    initialDate: state.selectedDate,
                                  ),
                                );
                              },
                            ),
                            CommonLine(
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.d16.responsive(),
                              ),
                            ),
                            CommonForwardButton(
                              title: S.current.filterByDateRange,
                              color: surfaceColor,
                              showBorder: false,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  Dimens.d16.responsive(),
                                ),
                                bottomRight: Radius.circular(
                                  Dimens.d16.responsive(),
                                ),
                              ),
                              onTap: () {
                                context.read<TransactionsBloc>().add(
                                  const TransactionsDateRangePicked(),
                                );
                              },
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectedWalletWidget extends StatelessWidget {
  const _SelectedWalletWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      buildWhen: (previous, current) {
        return previous.selectedWallet != current.selectedWallet ||
            previous.wallets != current.wallets;
      },
      builder: (context, state) {
        return CommonButton2(
          text: state.selectedWallet.name,
          icon:
              state.selectedWallet.id == AppConstants.totalWalletId
                  ? ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: frameColor),
                      ),
                      child: Assets.icons.summation.svg(
                        width: Dimens.d32.responsive(),
                        height: Dimens.d32.responsive(),
                      ),
                    ),
                  )
                  : CommonCircleNetworkImage(
                    imageUrl: state.selectedWallet.iconUrl,
                    placeHolderType: ImagePlaceHolderType.wallet,
                    size: Dimens.d32.responsive(),
                    backgroundColor: primaryShadeColor,
                  ),

          onTap: () {
            getIt.get<AppNavigator>().showDialog(
              AppPopupInfo.selectWallet(
                wallets: state.wallets,
                selectedWallet: state.selectedWallet,
                onWalletSelected: (wallet) {
                  context.read<TransactionsBloc>().add(
                    TransactionsWalletSelected(selectedWallet: wallet),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
