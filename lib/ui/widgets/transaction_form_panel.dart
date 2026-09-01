import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/widgets/common_circle_network_image.dart';
import 'package:walleto/ui/widgets/common_currency_container.dart';
import 'package:walleto/ui/widgets/common_line.dart';
import 'package:walleto/ui/widgets/transaction_amount_input.dart';

class TransactionFormPanel extends StatelessWidget {
  const TransactionFormPanel({
    super.key,
    required this.amountController,
    required this.amountFocusNode,
    required this.amountInput,
    required this.amountError,
    required this.note,
    required this.onAmountTap,
    required this.onWalletSelected,
    required this.onCurrencySelected,
    required this.onCategorySelected,
    required this.onNoteChanged,
    required this.onDateSelected,
    this.selectedWallet,
    this.selectedCurrency,
    this.convertedAmount,
    this.selectedCategory,
    this.selectedDate,
  });

  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final String amountInput;
  final String amountError;
  final String note;
  final VoidCallback onAmountTap;
  final ValueChanged<Wallet> onWalletSelected;
  final ValueChanged<Currency> onCurrencySelected;
  final ValueChanged<Category> onCategorySelected;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<DateTime> onDateSelected;
  final Wallet? selectedWallet;
  final Currency? selectedCurrency;
  final double? convertedAmount;
  final Category? selectedCategory;
  final DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.glassPanel(),
      padding: EdgeInsets.all(Dimens.d16.responsive()),
      child: Column(
        children: [
          _WalletRow(wallet: selectedWallet, onSelected: onWalletSelected),
          const CommonLine(),
          _AmountSection(
            amountController: amountController,
            amountFocusNode: amountFocusNode,
            amountInput: amountInput,
            amountError: amountError,
            selectedCurrency: selectedCurrency,
            selectedWallet: selectedWallet,
            convertedAmount: convertedAmount,
            onAmountTap: onAmountTap,
            onCurrencySelected: onCurrencySelected,
          ),
          const CommonLine(),
          _CategoryRow(category: selectedCategory, onSelected: onCategorySelected),
          const CommonLine(),
          _NoteRow(note: note, onChanged: onNoteChanged),
          const CommonLine(),
          _DateRow(date: selectedDate, onSelected: onDateSelected),
        ],
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({required this.wallet, required this.onSelected});

  final Wallet? wallet;
  final ValueChanged<Wallet> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedWallet = wallet;
    if (selectedWallet == null) return const SizedBox.shrink();

    return _TransactionFormRow(
      onTap: () {
        context.read<AppNavigator>().showModalBottomSheet(
          AppPopupInfo.chooseWallet(onWalletSelected: onSelected, currentWallet: selectedWallet),
        );
      },
      leading: CommonCircleNetworkImage(
        imageUrl: selectedWallet.iconUrl,
        size: Dimens.d30.responsive(),
        placeHolderType: ImagePlaceHolderType.wallet,
        backgroundColor: primaryShadeColor,
      ),
      label: Text(selectedWallet.name, style: AppTextStyles.s14wNormalBlack()),
    );
  }
}

class _AmountSection extends StatelessWidget {
  const _AmountSection({
    required this.amountController,
    required this.amountFocusNode,
    required this.amountInput,
    required this.amountError,
    required this.onAmountTap,
    required this.onCurrencySelected,
    this.selectedCurrency,
    this.selectedWallet,
    this.convertedAmount,
  });

  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final String amountInput;
  final String amountError;
  final VoidCallback onAmountTap;
  final ValueChanged<Currency> onCurrencySelected;
  final Currency? selectedCurrency;
  final Wallet? selectedWallet;
  final double? convertedAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.amount, style: AppTextStyles.s12wNormalGrey()),
        Row(
          children: [
            Expanded(
              child: TransactionAmountInput(
                controller: amountController,
                focusNode: amountFocusNode,
                amountInput: amountInput,
                amountError: amountError,
                onTap: onAmountTap,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<AppNavigator>().showModalBottomSheet(
                  AppPopupInfo.chooseCurrency(
                    onCurrencySelected: onCurrencySelected,
                    currentCurrency: selectedCurrency,
                  ),
                );
              },
              child: CommonCurrencyContainer(currentCurrencyCode: selectedCurrency?.code),
            ),
          ],
        ),
        _ConvertedAmountHint(convertedAmount: convertedAmount, wallet: selectedWallet),
      ],
    );
  }
}

class _ConvertedAmountHint extends StatelessWidget {
  const _ConvertedAmountHint({required this.convertedAmount, required this.wallet});

  final double? convertedAmount;
  final Wallet? wallet;

  @override
  Widget build(BuildContext context) {
    final amount = convertedAmount;
    final selectedWallet = wallet;
    if (amount == null || selectedWallet == null) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      showDuration: DurationConstants.defaultTooltipShowDuration,
      message: S.current.amountConvertInfo(selectedWallet.currencyCode),
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.d16.responsive(),
        vertical: Dimens.d12.responsive(),
      ),
      margin: EdgeInsets.symmetric(horizontal: Dimens.d10.responsive()),
      textStyle: AppTextStyles.s14wNormalBlack(),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(Dimens.d8.responsive()),
        border: Border.all(color: frameColor),
      ),
      enableFeedback: true,
      child: Row(
        children: [
          Icon(Icons.question_mark, color: redColor, size: Dimens.d20.responsive()),
          Expanded(
            child: Text(
              S.current.willBeConvertedTo(
                amount.toStringWithFormat(NumberFormatConstants.amountFormat),
                selectedWallet.currencyCode,
              ),
              style: AppTextStyles.s14wNormalItalicGrey(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.onSelected});

  final Category? category;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = category;

    return _TransactionFormRow(
      onTap: () {
        context.read<AppNavigator>().showDialog(
          AppPopupInfo.selectCategory(onCategorySelected: onSelected),
        );
      },
      leading: CommonCircleNetworkImage(
        imageUrl: selectedCategory?.iconUrl,
        size: Dimens.d30.responsive(),
        backgroundColor: primaryShadeColor,
      ),
      label:
          selectedCategory != null
              ? Text(selectedCategory.name, style: AppTextStyles.s14wNormalBlack())
              : Text(S.current.selectCategory, style: AppTextStyles.s14wNormalGrey()),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note, required this.onChanged});

  final String note;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _TransactionFormRow(
      onTap: () {
        context.read<AppNavigator>().showModalBottomSheet(
          AppPopupInfo.noteInput(currentNote: note, onNoteChanged: onChanged),
        );
      },
      leading: Assets.icons.note.svg(
        width: Dimens.d30.responsive(),
        height: Dimens.d30.responsive(),
      ),
      label:
          note.isNotEmpty
              ? Text(note, style: AppTextStyles.s14wNormalBlack(), overflow: TextOverflow.ellipsis)
              : Text(S.current.note, style: AppTextStyles.s14wNormalGrey()),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.date, required this.onSelected});

  final DateTime? date;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedDate = date;

    return _TransactionFormRow(
      onTap: () async {
        final navigator = context.read<AppNavigator>();
        final now = DateTime.now();
        final pickedDate = await navigator.showDatePicker(
          firstDate: DateTime(AppConstants.firstYear),
          lastDate: DateTime(AppConstants.lastYear),
          currentDate: now,
          initialDate: selectedDate,
        );
        if (pickedDate != null) {
          onSelected(pickedDate);
        }
      },
      leading: Assets.icons.calendar.svg(
        width: Dimens.d30.responsive(),
        height: Dimens.d30.responsive(),
      ),
      label:
          selectedDate != null
              ? Text(
                selectedDate.toStringWithFormat(DateTimeFormatConstants.commonDateFormat),
                style: AppTextStyles.s14wNormalBlack(),
              )
              : const SizedBox.shrink(),
    );
  }
}

class _TransactionFormRow extends StatelessWidget {
  const _TransactionFormRow({required this.leading, required this.label, required this.onTap});

  final Widget leading;
  final Widget label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Row(
        children: [
          leading,
          SizedBox(width: Dimens.d16.responsive()),
          Expanded(child: label),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: darkGreyColor,
            size: Dimens.d18.responsive(),
          ),
        ],
      ),
    );
  }
}
