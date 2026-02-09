import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class CreateTransactionView extends StatefulWidget {
  const CreateTransactionView({super.key});

  @override
  State<CreateTransactionView> createState() => _CreateTransactionViewState();
}

class _CreateTransactionViewState
    extends BasePageState<CreateTransactionView, CreateTransactionBloc> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    controller = TextEditingController();
    focusNode = FocusNode();
    bloc.add(const CreateTransactionViewInitiated());
    controller.text = bloc.state.amountInput;
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.addTransaction),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
            child: Column(
              children: [
                SizedBox(height: Dimens.d20.responsive()),
                _NewTransactionInfo(controller: controller, focusNode: focusNode),
                SizedBox(height: Dimens.d20.responsive()),
                BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
                  buildWhen:
                      (previous, current) =>
                          previous.confirmButtonEnable != current.confirmButtonEnable,
                  builder: (context, state) {
                    return CommonButton(
                      text: S.current.save,
                      onTap:
                          state.confirmButtonEnable
                              ? () => bloc.add(const CreateTransactionConfirmButtonPressed())
                              : null,
                    );
                  },
                ),
              ],
            ),
          ),
          BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
            buildWhen:
                (previous, current) =>
                    previous.showKeyboard != current.showKeyboard ||
                    previous.currentOperation != current.currentOperation,
            builder: (context, state) {
              return AnimatedPositioned(
                duration: DurationConstants.defaultAnimationDuration,
                curve: Curves.easeOut,
                bottom: state.showKeyboard ? 0 : -Dimens.d400.responsive(),
                child: NumericKeyboard(
                  onNumberKeyTap: (value) {
                    bloc.add(CreateTransactionAmountChanged(number: value));
                  },
                  onOperatorKeyTap: (operation) {
                    bloc.add(CreateTransactionOperationChanged(operation: operation));
                  },
                  onBackspace: () => bloc.add(const CreateTransactionBackspacePressed()),
                  onClear: () => bloc.add(const CreateTransactionClearPressed()),
                  onDone: () => bloc.add(const CreateTransactionKeyboardToggled(show: false)),
                  onEqual: () => bloc.add(const CreateTransactionEqualButtonPressed()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NewTransactionInfo extends StatelessWidget {
  const _NewTransactionInfo({required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

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
          BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
            buildWhen: (previous, current) => previous.selectedWallet != current.selectedWallet,
            builder: (context, state) {
              if (state.selectedWallet == null) return const SizedBox.shrink();

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  getIt.get<AppNavigator>().showModalBottomSheet(
                    AppPopupInfo.chooseWallet(
                      onWalletSelected: (wallet) {
                        context.read<CreateTransactionBloc>().add(
                          CreateTransactionWalletSelected(wallet: wallet),
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
                    ),
                    SizedBox(width: Dimens.d16.responsive()),
                    Text(state.selectedWallet!.name, style: AppTextStyles.s14wNormalBlack()),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: blackColor,
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
              Text(S.current.amount, style: AppTextStyles.s12wNormalBlack()),
              Row(
                children: [
                  Expanded(child: _AmountInput(controller: controller, focusNode: focusNode)),
                  BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
                    buildWhen: (previous, current) {
                      return previous.selectedCurrency != current.selectedCurrency;
                    },
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: () {
                          getIt.get<AppNavigator>().showModalBottomSheet(
                            AppPopupInfo.chooseCurrency(
                              onCurrencySelected: (selectedCurrency) {
                                context.read<CreateTransactionBloc>().add(
                                  CreateTransactionCurrencySelected(currency: selectedCurrency),
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
              BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
                buildWhen: (previous, current) {
                  return previous.convertedAmount != current.convertedAmount ||
                      previous.selectedWallet != current.selectedWallet;
                },
                builder: (context, state) {
                  if (state.convertedAmount == null || state.selectedWallet == null) {
                    return const SizedBox.shrink();
                  }

                  return Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: DurationConstants.defaultTooltipShowDuration,
                    message: S.current.amountConvertInfo(state.selectedWallet!.currencyCode),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimens.d16.responsive(),
                      vertical: Dimens.d12.responsive(),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: Dimens.d10.responsive()),
                    textStyle: AppTextStyles.s14wNormalWhite(),
                    enableFeedback: true,
                    child: Row(
                      children: [
                        Icon(Icons.question_mark, color: redColor, size: Dimens.d20.responsive()),
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
          BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
            buildWhen: (previous, current) => previous.selectedCategory != current.selectedCategory,
            builder: (context, state) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  getIt.get<AppNavigator>().showDialog(
                    AppPopupInfo.selectCategory(
                      onCategorySelected: (category) {
                        context.read<CreateTransactionBloc>().add(
                          CreateTransactionCategorySelected(category: category),
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
                      backgroundColor: secondaryColor,
                    ),
                    SizedBox(width: Dimens.d16.responsive()),
                    if (state.selectedCategory != null) ...[
                      Text(state.selectedCategory!.name, style: AppTextStyles.s14wNormalBlack()),
                    ] else ...[
                      Text(S.current.selectCategory, style: AppTextStyles.s14wNormalGrey()),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: blackColor,
                      size: Dimens.d18.responsive(),
                    ),
                  ],
                ),
              );
            },
          ),
          const CommonLine(),
          BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
            buildWhen: (previous, current) => previous.note != current.note,
            builder: (context, state) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  getIt.get<AppNavigator>().showModalBottomSheet(
                    AppPopupInfo.noteInput(
                      currentNote: state.note,
                      onNoteChanged: (note) {
                        context.read<CreateTransactionBloc>().add(
                          CreateTransactionNoteChanged(note: note),
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
                      Text(state.note, style: AppTextStyles.s14wNormalBlack()),
                    ] else ...[
                      Text(S.current.note, style: AppTextStyles.s14wNormalGrey()),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: blackColor,
                      size: Dimens.d18.responsive(),
                    ),
                  ],
                ),
              );
            },
          ),
          const CommonLine(),
          BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
            buildWhen: (previous, current) => previous.selectedDate != current.selectedDate,
            builder: (context, state) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  final now = DateTime.now();

                  final selectedDate = await getIt.get<AppNavigator>().showDatePicker(
                    firstDate: DateTime(AppConstants.firstYear),
                    lastDate: DateTime(AppConstants.lastYear),
                    currentDate: now,
                    initialDate: state.selectedDate,
                  );

                  if (selectedDate != null) {
                    // ignore: use_build_context_synchronously
                    context.read<CreateTransactionBloc>().add(
                      CreateTransactionDateSelected(date: selectedDate),
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
                      color: blackColor,
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
    return BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
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
              style: AppTextStyles.s28wNormalBlack(),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                counter: SizedBox.shrink(),
              ),
              onTap: () {
                context.read<CreateTransactionBloc>().add(
                  const CreateTransactionKeyboardToggled(show: true),
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
