import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class TransactionDetailView extends StatefulWidget {
  const TransactionDetailView({super.key, required this.transaction});

  final Transaction transaction;

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState
    extends BasePageState<TransactionDetailView, TransactionDetailBloc> {
  late final bool isAdjustTransaction;

  @override
  void initState() {
    isAdjustTransaction =
        widget.transaction.category.id == AppConstants.updateWalletBalanceCategoryId;
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.transactionDetail),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d16.responsive(),
          vertical: Dimens.d12.responsive(),
        ),
        child: Column(
          children: [
            SizedBox(height: Dimens.d16.responsive()),
            CommonContainer2(
              padding: EdgeInsets.all(Dimens.d16.responsive()),
              child: Column(
                children: [
                  Row(
                    children: [
                      CommonCircleNetworkImage(
                        imageUrl: widget.transaction.category.iconUrl,
                        size: Dimens.d40.responsive(),
                        backgroundColor: secondaryColor,
                      ),
                      SizedBox(width: Dimens.d16.responsive()),
                      Text(
                        widget.transaction.category.name,
                        style: AppTextStyles.s20wNormalBlack(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.transaction.amount.toStringWithFormat(
                          NumberFormatConstants.amountFormat,
                        ),
                        style:
                            widget.transaction.type == CategoryType.income
                                ? AppTextStyles.s28wNormalGreen()
                                : AppTextStyles.s28wNormalRed(),
                      ),
                    ],
                  ),
                  CommonLine(margin: EdgeInsets.only(bottom: Dimens.d12.responsive())),
                  if (widget.transaction.note.isNotEmpty) ...[
                    Row(
                      children: [
                        Assets.icons.note.svg(
                          width: Dimens.d30.responsive(),
                          height: Dimens.d30.responsive(),
                        ),
                        SizedBox(width: Dimens.d16.responsive()),
                        Expanded(
                          child: Text(
                            widget.transaction.note,
                            style: AppTextStyles.s14wNormalBlack(),
                          ),
                        ),
                      ],
                    ),
                    CommonLine(margin: EdgeInsets.symmetric(vertical: Dimens.d12.responsive())),
                  ],
                  Row(
                    children: [
                      Assets.icons.calendar.svg(
                        width: Dimens.d30.responsive(),
                        height: Dimens.d30.responsive(),
                      ),
                      SizedBox(width: Dimens.d16.responsive()),
                      Text(
                        widget.transaction.transactionDate!.toStringWithFormat(
                          DateTimeFormatConstants.commonDateFormat,
                        ),
                        style: AppTextStyles.s14wNormalBlack(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const CommonLine(),
                  Row(
                    children: [
                      CommonCircleNetworkImage(
                        imageUrl: widget.transaction.wallet.iconUrl,
                        size: Dimens.d30.responsive(),
                        placeHolderType: ImagePlaceHolderType.wallet,
                      ),
                      SizedBox(width: Dimens.d16.responsive()),
                      Text(widget.transaction.wallet.name, style: AppTextStyles.s14wNormalBlack()),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimens.d24.responsive()),
            CommonButton(
              text: S.current.editTransaction,
              backgroundColor: secondaryColor,
              onTap:
                  isAdjustTransaction
                      ? null
                      : () {
                        getIt.get<AppNavigator>().push(
                          AppRouteInfo.editTransaction(transaction: widget.transaction),
                        );
                      },
            ),
            SizedBox(height: Dimens.d12.responsive()),
            CommonButton(
              text: S.current.duplicateTransaction,
              onTap:
                  isAdjustTransaction
                      ? null
                      : () {
                        navigator.showDialog(
                          AppPopupInfo.duplicateTransaction(
                            transaction: widget.transaction,
                            onConfirm: (selectedDate) {
                              bloc.add(
                                TransactionDetailDuplicateButtonPressed(
                                  transactionId: widget.transaction.id,
                                  selectedDate: selectedDate,
                                ),
                              );

                              navigator.pop(useRootNavigator: true);
                            },
                          ),
                        );
                      },
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: redColor),
                onPressed:
                    isAdjustTransaction
                        ? null
                        : () {
                          navigator.showDialog(
                            AppPopupInfo.confirm(
                              message: S.current.areYouSureYouWantToDeleteThisTransaction,
                              showCancel: true,
                              onPressed: Func0(() {
                                bloc.add(
                                  TransactionDetailDeleteButtonPressed(
                                    transactionId: widget.transaction.id,
                                  ),
                                );

                                navigator.pop(useRootNavigator: true);
                              }),
                            ),
                          );
                        },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
