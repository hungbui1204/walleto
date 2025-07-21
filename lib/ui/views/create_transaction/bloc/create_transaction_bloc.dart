import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'create_transaction_event.dart';
part 'create_transaction_state.dart';
part 'create_transaction_bloc.freezed.dart';

@injectable
class CreateTransactionBloc extends BaseBloc<CreateTransactionEvent, CreateTransactionState> {
  CreateTransactionBloc(this._createTransactionUseCase) : super(const CreateTransactionState()) {
    on<CreateTransactionViewInitiated>(_onCreateTransactionViewInitiated);
    on<CreateTransactionKeyboardToggled>(_onCreateTransactionKeyboardToggled);
    on<CreateTransactionAmountChanged>(_onCreateTransactionAmountChanged);
    on<CreateTransactionOperationChanged>(_onCreateTransactionOperationChanged);
    on<CreateTransactionBackspacePressed>(_onCreateTransactionBackspacePressed);
    on<CreateTransactionClearPressed>(_onCreateTransactionClearPressed);
    on<CreateTransactionEqualButtonPressed>(_onCreateTransactionEqualButtonPressed);
    on<CreateTransactionConfirmButtonPressed>(_onCreateTransactionConfirmButtonPressed);
    on<CreateTransactionCategorySelected>(_onCreateTransactionCategorySelected);
  }

  final CreateTransactionUseCase _createTransactionUseCase;

  bool _confirmButtonEnableCheck({
    required String amountInput,
    required Category? selectedCategory,
    required DateTime? selectedDate,
    required String amountError,
  }) {
    // Check if the amount input is not empty and equals '0'
    // Check if a category is selected
    // Check if a date is selected
    // Check if there are no errors in the amount input
    // Check if the amount input does not contain any operators
    return amountInput.isNotEmpty &&
        amountInput != '0' &&
        selectedCategory != null &&
        selectedDate != null &&
        amountError.isEmpty &&
        !AppUtils.isContainOperator(amountInput);
  }

  void _onCreateTransactionViewInitiated(
    CreateTransactionViewInitiated event,
    Emitter<CreateTransactionState> emit,
  ) {
    final now = DateTime.now();
    final defaultWallet = appBloc.state.wallets.first;

    emit(state.copyWith(selectedDate: now, selectedWallet: defaultWallet));
  }

  void _onCreateTransactionKeyboardToggled(
    CreateTransactionKeyboardToggled event,
    Emitter<CreateTransactionState> emit,
  ) {
    emit(state.copyWith(showKeyboard: event.show));
  }

  void _onCreateTransactionAmountChanged(
    CreateTransactionAmountChanged event,
    Emitter<CreateTransactionState> emit,
  ) {
    // Check if the input is start with '0' and remove it
    String newAmount = state.amountInput;
    if (newAmount.startsWith('0')) {
      newAmount = newAmount.substring(1);
    }

    // Block '0','00','000' if input is empty
    if (newAmount.isEmpty) {
      if (event.number.contains('0')) return;
    }

    newAmount += event.number;

    // Block input if the length is greater than max length
    if (newAmount.countAllNumbersLength() > AppConstants.maxTransactionAmountLength) return;

    emit(
      state.copyWith(
        amountInput: newAmount.toFormattedNumberString(NumberFormatConstants.amountFormat),
        amountError: '',
        confirmButtonEnable: _confirmButtonEnableCheck(
          amountInput: newAmount,
          selectedCategory: state.selectedCategory,
          selectedDate: state.selectedDate,
          amountError: '',
        ),
      ),
    );
  }

  void _onCreateTransactionEqualButtonPressed(
    CreateTransactionEqualButtonPressed event,
    Emitter<CreateTransactionState> emit,
  ) {
    // Validate the current input for calculating the final amount
    // Emit an error if the input is invalid
    // If the input is valid, calculate the final amount

    // 1. Check if the input is empty
    if (state.amountInput.isEmpty) {
      emit(state.copyWith(amountError: S.current.emptyField));

      return;
    }

    // 2. Check if the input is containing operator at the end
    if (AppUtils.isEndWithOperator(state.amountInput)) {
      emit(state.copyWith(amountError: S.current.invalidFormat));

      return;
    }

    // 3. Calculate the final amount
    if (state.currentOperation != null) {
      late final int amount;

      switch (state.currentOperation!) {
        case OperationType.addition:
          amount = state.amountInput
              .split(OperationType.addition.symbol)
              .map((e) => e.toInt())
              .reduce((a, b) => a + b);
          break;
        case OperationType.subtraction:
          amount = state.amountInput
              .split(OperationType.subtraction.symbol)
              .map((e) => e.toInt())
              .reduce((a, b) => a - b);
          break;
        case OperationType.multiplication:
          amount = state.amountInput
              .split(OperationType.multiplication.symbol)
              .map((e) => e.toInt())
              .reduce((a, b) => a * b);
          break;
        case OperationType.division:
          amount = state.amountInput
              .split(OperationType.division.symbol)
              .map((e) => e.toInt())
              .reduce((a, b) => a ~/ b);
          break;
      }

      // 4. Check the amount's length
      if (amount.toString().countAllNumbersLength() > AppConstants.maxTransactionAmountLength) {
        emit(state.copyWith(amountError: S.current.amountTooLarge));

        return;
      }

      emit(
        state.copyWith(
          amountInput: amount.toStringWithFormat(NumberFormatConstants.amountFormat),
          currentOperation: null,
          confirmButtonEnable: _confirmButtonEnableCheck(
            amountInput: amount.toStringWithFormat(NumberFormatConstants.amountFormat),
            selectedCategory: state.selectedCategory,
            selectedDate: state.selectedDate,
            amountError: state.amountError,
          ),
        ),
      );
    }
  }

  void _onCreateTransactionOperationChanged(
    CreateTransactionOperationChanged event,
    Emitter<CreateTransactionState> emit,
  ) {
    // If currently having an operation, do not allow to add more operation
    if (state.currentOperation != null) return;

    // Does not allow to add operation if the input is empty or only contain '0
    if (state.amountInput.isEmpty || state.amountInput == '0') return;

    // Update the input with the new operation
    String newAmount = state.amountInput + event.operation;

    final operation = OperationType.fromString(event.operation);
    emit(
      state.copyWith(
        currentOperation: operation,
        amountInput: newAmount,
        confirmButtonEnable: _confirmButtonEnableCheck(
          amountInput: newAmount,
          selectedCategory: state.selectedCategory,
          selectedDate: state.selectedDate,
          amountError: state.amountError,
        ),
      ),
    );
  }

  void _onCreateTransactionBackspacePressed(
    CreateTransactionBackspacePressed event,
    Emitter<CreateTransactionState> emit,
  ) {
    if (state.amountInput.isNotEmpty) {
      // Remove the last character from the input
      // If the last character is an operator, also reset the current operation
      final newAmount = state.amountInput.substring(0, state.amountInput.length - 1);
      if (AppUtils.isEndWithOperator(state.amountInput)) {
        emit(state.copyWith(currentOperation: null));
      }

      emit(
        state.copyWith(
          amountInput: newAmount.toFormattedNumberString(NumberFormatConstants.amountFormat),
          amountError: '',
          confirmButtonEnable: _confirmButtonEnableCheck(
            amountInput: newAmount,
            selectedCategory: state.selectedCategory,
            selectedDate: state.selectedDate,
            amountError: '',
          ),
        ),
      );
    }
  }

  void _onCreateTransactionClearPressed(
    CreateTransactionClearPressed event,
    Emitter<CreateTransactionState> emit,
  ) {
    emit(
      state.copyWith(
        amountInput: '',
        currentOperation: null,
        amountError: '',
        confirmButtonEnable: false,
      ),
    );
  }

  void _onCreateTransactionCategorySelected(
    CreateTransactionCategorySelected event,
    Emitter<CreateTransactionState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        confirmButtonEnable: _confirmButtonEnableCheck(
          amountInput: state.amountInput,
          selectedCategory: event.category,
          selectedDate: state.selectedDate,
          amountError: state.amountError,
        ),
      ),
    );
  }

  Future<void> _onCreateTransactionConfirmButtonPressed(
    CreateTransactionConfirmButtonPressed event,
    Emitter<CreateTransactionState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final newTransaction = Transaction(
          amount: state.amountInput.toInt().toDouble(),
          categoryId: state.selectedCategory?.id ?? 0,
          createdAt: state.selectedDate,
          note: state.note,
          walletId: state.selectedWallet?.id ?? 0,
        );

        await _createTransactionUseCase.execute(
          CreateTransactionInput(transaction: newTransaction),
        );

        // Refresh transactions after creating a new transaction
        // Refresh the wallets to update the balance
        appBloc.add(const TransactionsReloaded(needReloadTransactions: true));
        appBloc.add(const DataFetched());
        navigator.pop();
      },
    );
  }
}
