import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class EditTransactionView extends StatefulWidget {
  const EditTransactionView({super.key, required this.transaction});

  final Transaction transaction;

  @override
  State<EditTransactionView> createState() => _EditTransactionViewState();
}

class _EditTransactionViewState
    extends BasePageState<EditTransactionView, EditTransactionBloc> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    controller = TextEditingController();
    focusNode = FocusNode();
    bloc.add(EditTransactionViewInitiated(widget.transaction));
    controller.text = bloc.state.amountInput;
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.editTransaction),
      body: NoirScaffoldBody(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.d16.responsive(),
              ),
              child: Column(
                children: [
                  SizedBox(height: Dimens.d20.responsive()),
                  _NewTransactionInfo(
                    controller: controller,
                    focusNode: focusNode,
                  ),
                  SizedBox(height: Dimens.d20.responsive()),
                  BlocBuilder<EditTransactionBloc, EditTransactionState>(
                    buildWhen:
                        (previous, current) =>
                            previous.confirmButtonEnable !=
                            current.confirmButtonEnable,
                    builder: (context, state) {
                      return CommonButton(
                        text: S.current.save,
                        onTap:
                            state.confirmButtonEnable
                                ? () => bloc.add(
                                  const EditTransactionConfirmButtonPressed(),
                                )
                                : null,
                      );
                    },
                  ),
                ],
              ),
            ),
            BlocBuilder<EditTransactionBloc, EditTransactionState>(
              buildWhen:
                  (previous, current) =>
                      previous.showKeyboard != current.showKeyboard ||
                      previous.currentOperation != current.currentOperation,
              builder: (context, state) {
                return AnimatedPositioned(
                  duration: DurationConstants.defaultAnimationDuration,
                  curve: Curves.easeOut,
                  bottom: state.showKeyboard ? 0 : -Dimens.d400.responsive(),
                  child: DecoratedBox(
                    decoration: AppDecorations.keyboardSheet(),
                    child: SafeArea(
                      top: false,
                      child: NumericKeyboard(
                        onNumberKeyTap: (value) {
                          bloc.add(EditTransactionAmountChanged(number: value));
                        },
                        onOperatorKeyTap: (operation) {
                          bloc.add(
                            EditTransactionOperationChanged(
                              operation: operation,
                            ),
                          );
                        },
                        onBackspace:
                            () => bloc.add(
                              const EditTransactionBackspacePressed(),
                            ),
                        onClear:
                            () => bloc.add(const EditTransactionClearPressed()),
                        onDone:
                            () => bloc.add(
                              const EditTransactionKeyboardToggled(show: false),
                            ),
                        onEqual:
                            () => bloc.add(
                              const EditTransactionEqualButtonPressed(),
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NewTransactionInfo extends StatelessWidget {
  const _NewTransactionInfo({
    required this.controller,
    required this.focusNode,
  });
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.glassPanel(),
      padding: EdgeInsets.all(Dimens.d16.responsive()),
      child: Column(
        children: [
          BlocBuilder<EditTransactionBloc, EditTransactionState>(
            buildWhen:
                (previous, current) =>
                    previous.selectedWallet != current.selectedWallet,
            builder: (context, state) {
              if (state.selectedWallet == null) return const SizedBox.shrink();

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  context.read<AppNavigator>().showModalBottomSheet(
                    AppPopupInfo.chooseWallet(
                      onWalletSelected: (wallet) {
                        context.read<EditTransactionBloc>().add(
                          EditTransactionWalletSelected(wallet: wallet),
                        );
                      },
                      currentWallet: state.selectedWallet,
                    ),
                  );
                },
                child: Row(
                  children: [
                    CommonCircleNetworkImage(
                      imageUrl: state.selectedWallet!.iconUrl,
                      size: Dimens.d30.responsive(),
                      placeHolderType: ImagePlaceHolderType.wallet,
                      backgroundColor: primaryShadeColor,
                    ),
                    SizedBox(width: Dimens.d16.responsive()),
                    Text(
                      state.selectedWallet!.name,
                      style: AppTextStyles.s14wNormalBlack(),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: darkGreyColor,
                      size: Dimens.d18.responsive(),
                    ),
                  ],
                ),
              );
            },
          ),
          const CommonLine(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.amount, style: AppTextStyles.s12wNormalGrey()),
              Row(
                children: [
                  Expanded(
                    child: _AmountInput(
                      controller: controller,
                      focusNode: focusNode,
                    ),
                  ),
                  BlocBuilder<EditTransactionBloc, EditTransactionState>(
                    buildWhen: (previous, current) {
                      return previous.selectedCurrency !=
                          current.selectedCurrency;
                    },
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: () {
                          context.read<AppNavigator>().showModalBottomSheet(
                            AppPopupInfo.chooseCurrency(
                              onCurrencySelected: (selectedCurrency) {
                                context.read<EditTransactionBloc>().add(
                                  EditTransactionCurrencySelected(
                                    currency: selectedCurrency,
                                  ),
                                );
                              },
                              currentCurrency: state.selectedCurrency,
                            ),
                          );
                        },
                        child: CommonCurrencyContainer(
                          currentCurrencyCode: state.selectedCurrency?.code,
                        ),
                      );
                    },
                  ),
                ],
              ),
              BlocBuilder<EditTransactionBloc, EditTransactionState>(
                buildWhen: (previous, current) {
                  return previous.convertedAmount != current.convertedAmount ||
                      previous.selectedWallet != current.selectedWallet;
                },
                builder: (context, state) {
                  if (state.convertedAmount == null ||
                      state.selectedWallet == null) {
                    return const SizedBox.shrink();
                  }

                  return Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: DurationConstants.defaultTooltipShowDuration,
                    message: S.current.amountConvertInfo(
                      state.selectedWallet!.currencyCode,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimens.d16.responsive(),
                      vertical: Dimens.d12.responsive(),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: Dimens.d10.responsive(),
                    ),
                    textStyle: AppTextStyles.s14wNormalBlack(),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(
                        Dimens.d8.responsive(),
                      ),
                      border: Border.all(color: frameColor),
                    ),
                    enableFeedback: true,
                    child: Row(
                      children: [
                        Icon(
                          Icons.question_mark,
                          color: redColor,
                          size: Dimens.d20.responsive(),
                        ),
                        Expanded(
                          child: Text(
                            S.current.willBeConvertedTo(
                              state.convertedAmount!.toStringWithFormat(
                                NumberFormatConstants.amountFormat,
                              ),
                              state.selectedWallet!.currencyCode,
                            ),
                            style: AppTextStyles.s14wNormalItalicGrey(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const CommonLine(),
          BlocBuilder<EditTransactionBloc, EditTransactionState>(
            buildWhen:
                (previous, current) =>
                    previous.selectedCategory != current.selectedCategory,
            builder: (context, state) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  context.read<AppNavigator>().showDialog(
                    AppPopupInfo.selectCategory(
                      onCategorySelected: (category) {
                        context.read<EditTransactionBloc>().add(
                          EditTransactionCategorySelected(category: category),
                        );
                      },
                    ),
                  );
                },
                child: Row(
                  children: [
                    CommonCircleNetworkImage(
                      imageUrl: state.selectedCategory?.iconUrl,
                      size: Dimens.d30.responsive(),
                      backgroundColor: primaryShadeColor,
                    ),
                    SizedBox(width: Dimens.d16.responsive()),
                    if (state.selectedCategory != null) ...[
                      Text(
                        state.selectedCategory!.name,
                        style: AppTextStyles.s14wNormalBlack(),
                      ),
                    ] else ...[
                      Text(
                        S.current.selectCategory,
                        style: AppTextStyles.s14wNormalGrey(),
                      ),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: darkGreyColor,
                      size: Dimens.d18.responsive(),
                    ),
                  ],
                ),
              );
            },
          ),
          const CommonLine(),
          BlocBuilder<EditTransactionBloc, EditTransactionState>(
            buildWhen: (previous, current) => previous.note != current.note,
            builder: (context, state) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  context.read<AppNavigator>().showModalBottomSheet(
                    AppPopupInfo.noteInput(
                      currentNote: state.note,
                      onNoteChanged: (note) {
                        context.read<EditTransactionBloc>().add(
                          EditTransactionNoteChanged(note: note),
                        );
                      },
                    ),
                  );
                },
                child: Row(
                  children: [
                    Assets.icons.note.svg(
                      width: Dimens.d30.responsive(),
                      height: Dimens.d30.responsive(),
                    ),
                    SizedBox(width: Dimens.d16.responsive()),
                    if (state.note.isNotEmpty) ...[
                      Expanded(
                        child: Text(
                          state.note,
                          style: AppTextStyles.s14wNormalBlack(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else ...[
                      Text(
                        S.current.note,
                        style: AppTextStyles.s14wNormalGrey(),
                      ),
                    ],
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: darkGreyColor,
                      size: Dimens.d18.responsive(),
                    ),
                  ],
                ),
              );
            },
          ),
          const CommonLine(),
          BlocBuilder<EditTransactionBloc, EditTransactionState>(
            buildWhen:
                (previous, current) =>
                    previous.selectedDate != current.selectedDate,
            builder: (context, state) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  final now = DateTime.now();

                  final selectedDate = await context
                      .read<AppNavigator>()
                      .showDatePicker(
                        firstDate: DateTime(AppConstants.firstYear),
                        lastDate: DateTime(AppConstants.lastYear),
                        currentDate: now,
                        initialDate: state.selectedDate,
                      );

                  if (selectedDate != null) {
                    // ignore: use_build_context_synchronously
                    context.read<EditTransactionBloc>().add(
                      EditTransactionDateSelected(date: selectedDate),
                    );
                  }
                },
                child: Row(
                  children: [
                    Assets.icons.calendar.svg(
                      width: Dimens.d30.responsive(),
                      height: Dimens.d30.responsive(),
                    ),
                    SizedBox(width: Dimens.d16.responsive()),
                    if (state.selectedDate != null)
                      Text(
                        state.selectedDate!.toStringWithFormat(
                          DateTimeFormatConstants.commonDateFormat,
                        ),
                        style: AppTextStyles.s14wNormalBlack(),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: darkGreyColor,
                      size: Dimens.d18.responsive(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTransactionBloc, EditTransactionState>(
      buildWhen: (previous, current) {
        return previous.amountInput != current.amountInput ||
            previous.amountError != current.amountError;
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              cursorHeight: Dimens.d28.responsive(),
              readOnly: true,
              showCursor: true,
              cursorColor: primaryColor,
              style: AppThemes.amount(
                fontSize: Dimens.d32.responsive(),
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                counter: SizedBox.shrink(),
              ),
              onTap: () {
                context.read<EditTransactionBloc>().add(
                  const EditTransactionKeyboardToggled(show: true),
                );
              },
              controller: controller..text = state.amountInput,
            ),
            if (state.amountError.isNotEmpty)
              Text(state.amountError, style: AppTextStyles.s14wNormalRed()),
          ],
        );
      },
    );
  }
}
