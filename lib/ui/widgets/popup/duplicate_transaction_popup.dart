import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class DuplicateTransactionPopup extends StatefulWidget {
  const DuplicateTransactionPopup({super.key, required this.onConfirm, required this.transaction});

  final void Function(DateTime) onConfirm;
  final Transaction transaction;

  @override
  State<DuplicateTransactionPopup> createState() => _DuplicateTransactionPopupState();
}

class _DuplicateTransactionPopupState extends State<DuplicateTransactionPopup> {
  final now = DateTime.now();
  DateTime? selectedDateUI;

  @override
  void initState() {
    selectedDateUI = now;
    super.initState();
  }

  Future<void> _dateTimeSelect() async {
    final selectedDate = await context.read<AppNavigator>().showDatePicker(
      useRootNavigator: true,
      firstDate: DateTime(AppConstants.firstYear),
      lastDate: DateTime(AppConstants.lastYear),
      currentDate: now,
      initialDate: now,
    );

    if (selectedDate != null) {
      setState(() {
        selectedDateUI = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxHeight: context.mediaQuery.size.height * 0.7),
          margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.d16.responsive(),
            vertical: Dimens.d20.responsive(),
          ),
          decoration: AppDecorations.glassPanel(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.current.duplicateTransaction, style: AppTextStyles.s20wNormalBlack()),
              SizedBox(height: Dimens.d20.responsive()),
              CommonContainer2(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.d12.responsive(),
                  vertical: Dimens.d10.responsive(),
                ),
                child: Row(
                  children: [
                    CommonCircleNetworkImage(
                      imageUrl: widget.transaction.category.iconUrl,
                      size: Dimens.d30.responsive(),
                      backgroundColor: primaryShadeColor,
                    ),
                    SizedBox(width: Dimens.d16.responsive()),
                    Column(
                      children: [
                        Text(
                          widget.transaction.category.name,
                          style: AppTextStyles.s16wNormalBlack(),
                        ),
                        if (widget.transaction.note.isNotEmpty)
                          Text(
                            widget.transaction.note,
                            style: AppTextStyles.s14wNormalGrey(),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.transaction.amount.toStringWithFormat(
                        NumberFormatConstants.amountFormat,
                      ),
                      style:
                          widget.transaction.category.type == CategoryType.income
                              ? AppTextStyles.s16wNormalGreen()
                              : AppTextStyles.s16wNormalRed(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimens.d20.responsive()),
              CommonContainer2(
                color: fieldFillColor,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.d8.responsive(),
                  vertical: Dimens.d4.responsive(),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _dateTimeSelect,
                  child: Row(
                    children: [
                      Assets.icons.calendar.svg(
                        width: Dimens.d30.responsive(),
                        height: Dimens.d30.responsive(),
                      ),
                      SizedBox(width: Dimens.d16.responsive()),
                      if (selectedDateUI != null)
                        Text(
                          selectedDateUI!.toStringWithFormat(
                            DateTimeFormatConstants.commonDateFormat,
                          ),
                          style: AppTextStyles.s14wNormalBlack(),
                        ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: blackColor,
                        size: Dimens.d18.responsive(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Dimens.d20.responsive()),
              CommonButton(
                text: S.current.confirm,
                onTap:
                    selectedDateUI != null
                        ? () {
                          widget.onConfirm(selectedDateUI!);
                        }
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
