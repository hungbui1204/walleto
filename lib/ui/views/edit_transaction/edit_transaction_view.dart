import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
              child: Column(
                children: [
                  SizedBox(height: Dimens.d20.responsive()),
                  BlocBuilder<EditTransactionBloc, EditTransactionState>(
                    buildWhen: _formFieldsChanged,
                    builder: (context, state) {
                      return TransactionFormPanel(
                        amountController: controller,
                        amountFocusNode: focusNode,
                        amountInput: state.amountInput,
                        amountError: state.amountError,
                        note: state.note,
                        selectedWallet: state.selectedWallet,
                        selectedCurrency: state.selectedCurrency,
                        convertedAmount: state.convertedAmount,
                        selectedCategory: state.selectedCategory,
                        selectedDate: state.selectedDate,
                        onAmountTap:
                            () => bloc.add(const EditTransactionKeyboardToggled(show: true)),
                        onWalletSelected:
                            (wallet) => bloc.add(EditTransactionWalletSelected(wallet: wallet)),
                        onCurrencySelected:
                            (currency) =>
                                bloc.add(EditTransactionCurrencySelected(currency: currency)),
                        onCategorySelected:
                            (category) =>
                                bloc.add(EditTransactionCategorySelected(category: category)),
                        onNoteChanged: (note) => bloc.add(EditTransactionNoteChanged(note: note)),
                        onDateSelected: (date) => bloc.add(EditTransactionDateSelected(date: date)),
                      );
                    },
                  ),
                  SizedBox(height: Dimens.d20.responsive()),
                  BlocBuilder<EditTransactionBloc, EditTransactionState>(
                    buildWhen:
                        (previous, current) =>
                            previous.confirmButtonEnable != current.confirmButtonEnable,
                    builder: (context, state) {
                      return CommonButton(
                        text: S.current.save,
                        onTap:
                            state.confirmButtonEnable
                                ? () => bloc.add(const EditTransactionConfirmButtonPressed())
                                : null,
                      );
                    },
                  ),
                ],
              ),
            ),
            BlocBuilder<EditTransactionBloc, EditTransactionState>(
              buildWhen: (previous, current) => previous.showKeyboard != current.showKeyboard,
              builder: (context, state) {
                return TransactionNumericKeyboardSheet(
                  visible: state.showKeyboard,
                  onNumberKeyTap: (value) {
                    bloc.add(EditTransactionAmountChanged(number: value));
                  },
                  onOperatorKeyTap: (operation) {
                    bloc.add(EditTransactionOperationChanged(operation: operation));
                  },
                  onBackspace: () => bloc.add(const EditTransactionBackspacePressed()),
                  onClear: () => bloc.add(const EditTransactionClearPressed()),
                  onDone: () => bloc.add(const EditTransactionKeyboardToggled(show: false)),
                  onEqual: () => bloc.add(const EditTransactionEqualButtonPressed()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _formFieldsChanged(EditTransactionState previous, EditTransactionState current) {
    return previous.selectedWallet != current.selectedWallet ||
        previous.selectedCurrency != current.selectedCurrency ||
        previous.convertedAmount != current.convertedAmount ||
        previous.amountInput != current.amountInput ||
        previous.amountError != current.amountError ||
        previous.selectedCategory != current.selectedCategory ||
        previous.note != current.note ||
        previous.selectedDate != current.selectedDate;
  }
}
