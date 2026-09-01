import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
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
      body: NoirScaffoldBody(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
              child: Column(
                children: [
                  SizedBox(height: Dimens.d20.responsive()),
                  BlocBuilder<CreateTransactionBloc, CreateTransactionState>(
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
                            () => bloc.add(const CreateTransactionKeyboardToggled(show: true)),
                        onWalletSelected:
                            (wallet) => bloc.add(CreateTransactionWalletSelected(wallet: wallet)),
                        onCurrencySelected:
                            (currency) =>
                                bloc.add(CreateTransactionCurrencySelected(currency: currency)),
                        onCategorySelected:
                            (category) =>
                                bloc.add(CreateTransactionCategorySelected(category: category)),
                        onNoteChanged: (note) => bloc.add(CreateTransactionNoteChanged(note: note)),
                        onDateSelected:
                            (date) => bloc.add(CreateTransactionDateSelected(date: date)),
                      );
                    },
                  ),
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
              buildWhen: (previous, current) => previous.showKeyboard != current.showKeyboard,
              builder: (context, state) {
                return TransactionNumericKeyboardSheet(
                  visible: state.showKeyboard,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _formFieldsChanged(CreateTransactionState previous, CreateTransactionState current) {
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
