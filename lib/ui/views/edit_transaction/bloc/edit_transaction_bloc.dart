import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'edit_transaction_event.dart';
part 'edit_transaction_state.dart';
part 'edit_transaction_bloc.freezed.dart';

@injectable
class EditTransactionBloc extends BaseBloc<EditTransactionEvent, EditTransactionState> {
  EditTransactionBloc(this._getExchangeRateUseCase, this._editTransactionUseCase)
    : super(const EditTransactionState()) {
    on<EditTransactionViewInitiated>(_onEditTransactionViewInitiated, transformer: log());
    on<EditTransactionKeyboardToggled>(_onEditTransactionKeyboardToggled, transformer: log());
    on<EditTransactionAmountChanged>(_onEditTransactionAmountChanged, transformer: log());
    on<EditTransactionEqualButtonPressed>(_onEditTransactionEqualButtonPressed, transformer: log());
    on<EditTransactionOperationChanged>(_onEditTransactionOperationChanged, transformer: log());
    on<EditTransactionBackspacePressed>(_onEditTransactionBackspacePressed, transformer: log());
    on<EditTransactionClearPressed>(_onEditTransactionClearPressed, transformer: log());
    on<EditTransactionCategorySelected>(_onEditTransactionCategorySelected, transformer: log());
    on<EditTransactionConfirmButtonPressed>(
      _onEditTransactionConfirmButtonPressed,
      transformer: log(),
    );
    on<EditTransactionDateSelected>(_onEditTransactionDateSelected, transformer: log());
    on<EditTransactionNoteChanged>(_onEditTransactionNoteChanged, transformer: log());
    on<EditTransactionWalletSelected>(_onEditTransactionWalletSelected, transformer: log());
    on<EditTransactionCurrencySelected>(_onEditTransactionCurrencySelected, transformer: log());
  }

  final GetExchangeRateUseCase _getExchangeRateUseCase;
  final EditTransactionUseCase _editTransactionUseCase;

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

  void _onEditTransactionViewInitiated(
    EditTransactionViewInitiated event,
    Emitter<EditTransactionState> emit,
  ) {
    final currentTransCurrency = appBloc.state.currencies.firstWhere(
      (currency) => currency.code == event.transaction.currencyCode,
      orElse: () => appBloc.state.currencies.first,
    );

    final currentWallet = appBloc.state.wallets.firstWhere(
      (wallet) => wallet.id == event.transaction.wallet.id,
      orElse: () => appBloc.state.wallets.first,
    );

    emit(
      state.copyWith(
        amount: event.transaction.amount,
        amountInput: event.transaction.amount.toStringWithFormat(
          NumberFormatConstants.amountFormat,
        ),
        selectedCategory: event.transaction.category,
        selectedDate: event.transaction.transactionDate ?? DateTime.now(),
        note: event.transaction.note,
        selectedWallet: currentWallet,
        selectedCurrency: currentTransCurrency,
        transactionId: event.transaction.id,
      ),
    );
  }

  void _updateConvertAmount(Emitter emit) {
    if (state.exchangeRate != null && state.convertedAmount != null) {
      final convertedAmount = AppUtils.calculateAmountWithExchangeRate(
        amount: state.amountInput.toDouble(),
        exchangeRate: state.exchangeRate!,
      );

      emit(state.copyWith(convertedAmount: convertedAmount));
    }
  }

  void _onEditTransactionKeyboardToggled(
    EditTransactionKeyboardToggled event,
    Emitter<EditTransactionState> emit,
  ) {
    emit(state.copyWith(showKeyboard: event.show));
  }

  void _onEditTransactionAmountChanged(
    EditTransactionAmountChanged event,
    Emitter<EditTransactionState> emit,
  ) {
    final newAmount = TransactionAmountCalculator.appendNumber(
      currentInput: state.amountInput,
      number: event.number,
    );
    if (newAmount == null) {
      return;
    }

    emit(
      state.copyWith(
        amountInput: newAmount,
        amountError: '',
        confirmButtonEnable: _confirmButtonEnableCheck(
          amountInput: newAmount,
          selectedCategory: state.selectedCategory,
          selectedDate: state.selectedDate,
          amountError: '',
        ),
      ),
    );

    _updateConvertAmount(emit);
  }

  void _onEditTransactionEqualButtonPressed(
    EditTransactionEqualButtonPressed event,
    Emitter<EditTransactionState> emit,
  ) {
    final result = TransactionAmountCalculator.evaluate(
      currentInput: state.amountInput,
      currentOperation: state.currentOperation,
    );

    if (result.error != null) {
      emit(state.copyWith(amountError: _amountErrorMessage(result.error!)));
      return;
    }

    if (result.unchanged || result.formattedAmount == null) {
      return;
    }

    final formattedAmount = result.formattedAmount!;
    emit(
      state.copyWith(
        amountInput: formattedAmount,
        currentOperation: null,
        confirmButtonEnable: _confirmButtonEnableCheck(
          amountInput: formattedAmount,
          selectedCategory: state.selectedCategory,
          selectedDate: state.selectedDate,
          amountError: state.amountError,
        ),
      ),
    );

    _updateConvertAmount(emit);
  }

  void _onEditTransactionOperationChanged(
    EditTransactionOperationChanged event,
    Emitter<EditTransactionState> emit,
  ) {
    final result = TransactionAmountCalculator.appendOperator(
      currentInput: state.amountInput,
      operationSymbol: event.operation,
      currentOperation: state.currentOperation,
    );
    if (result == null) {
      return;
    }

    emit(
      state.copyWith(
        currentOperation: result.operation,
        amountInput: result.amountInput,
        confirmButtonEnable: _confirmButtonEnableCheck(
          amountInput: result.amountInput,
          selectedCategory: state.selectedCategory,
          selectedDate: state.selectedDate,
          amountError: state.amountError,
        ),
      ),
    );
  }

  void _onEditTransactionBackspacePressed(
    EditTransactionBackspacePressed event,
    Emitter<EditTransactionState> emit,
  ) {
    final result = TransactionAmountCalculator.backspace(state.amountInput);
    if (result == null) {
      return;
    }

    emit(
      state.copyWith(
        currentOperation: result.clearedOperator ? null : state.currentOperation,
        amountInput: result.amountInput,
        amountError: '',
        confirmButtonEnable: _confirmButtonEnableCheck(
          amountInput: result.amountInput,
          selectedCategory: state.selectedCategory,
          selectedDate: state.selectedDate,
          amountError: '',
        ),
      ),
    );

    _updateConvertAmount(emit);
  }

  String _amountErrorMessage(TransactionAmountEvaluateError error) {
    return switch (error) {
      TransactionAmountEvaluateError.empty => S.current.emptyField,
      TransactionAmountEvaluateError.invalidFormat => S.current.invalidFormat,
      TransactionAmountEvaluateError.tooLarge => S.current.amountTooLarge,
    };
  }

  void _onEditTransactionClearPressed(
    EditTransactionClearPressed event,
    Emitter<EditTransactionState> emit,
  ) {
    emit(
      state.copyWith(
        amountInput: '',
        currentOperation: null,
        amountError: '',
        confirmButtonEnable: false,
        convertedAmount: state.convertedAmount != null ? 0.0 : null,
      ),
    );
  }

  void _onEditTransactionCategorySelected(
    EditTransactionCategorySelected event,
    Emitter<EditTransactionState> emit,
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

  Future<void> _onEditTransactionConfirmButtonPressed(
    EditTransactionConfirmButtonPressed event,
    Emitter<EditTransactionState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        // If the [state.convertedAmount] is not null, use it as the transaction amount
        // Otherwise, use the [state.amountInput] as the transaction amount
        final amount = state.convertedAmount ?? state.amountInput.toDouble();

        final newTransaction = Transaction(
          id: state.transactionId,
          amount: amount,
          categoryId: state.selectedCategory?.id ?? 0,
          transactionDate: state.selectedDate,
          note: state.note,
          walletId: state.selectedWallet?.id ?? 0,
          currencyCode: state.selectedWallet?.currencyCode ?? '',
        );

        await _editTransactionUseCase.execute(EditTransactionInput(transaction: newTransaction));

        // Refresh transactions after creating a new transaction
        // Refresh the wallets to update the balance
        appBloc.add(const TransactionsReloaded(needReloadTransactions: true));
        appBloc.add(const StatisticalChartsReloaded(needReloadStatisticalCharts: true));
        appBloc.add(const DataFetched(walletsFetched: true));
        navigator.popUntilRootOfCurrentBottomTab();
      },
    );
  }

  void _onEditTransactionDateSelected(
    EditTransactionDateSelected event,
    Emitter<EditTransactionState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onEditTransactionNoteChanged(
    EditTransactionNoteChanged event,
    Emitter<EditTransactionState> emit,
  ) {
    emit(state.copyWith(note: event.note));
  }

  void _onEditTransactionWalletSelected(
    EditTransactionWalletSelected event,
    Emitter<EditTransactionState> emit,
  ) {
    if (event.wallet.id == state.selectedWallet?.id) return;

    // Reset the selected currency to selected wallet's currency, exchange rate, and converted amount
    final walletCurrency = appBloc.state.currencies.firstWhere(
      (currency) => currency.code == event.wallet.currencyCode,
      orElse: () => appBloc.state.currencies.first,
    );

    emit(
      state.copyWith(
        selectedWallet: event.wallet,
        selectedCurrency: walletCurrency,
        exchangeRate: null,
        convertedAmount: null,
        confirmButtonEnable: _confirmButtonEnableCheck(
          amountInput: state.amountInput,
          selectedCategory: state.selectedCategory,
          selectedDate: state.selectedDate,
          amountError: state.amountError,
        ),
      ),
    );
  }

  Future<void> _onEditTransactionCurrencySelected(
    EditTransactionCurrencySelected event,
    Emitter<EditTransactionState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        if (event.currency == state.selectedCurrency) return;

        // Check the selected currency is the same as the wallet currency
        // Then reset the exchange rate and converted amount
        if (event.currency.code == state.selectedWallet!.currencyCode) {
          emit(
            state.copyWith(
              exchangeRate: null,
              selectedCurrency: event.currency,
              convertedAmount: null,
            ),
          );

          return;
        }

        // Get exchange rate from selected currency to current wallet currency
        final exchangeRateOutput = await _getExchangeRateUseCase.execute(
          GetExchangeRateInput(
            fromCurrencyCode: event.currency.code,
            toCurrencyCode: state.selectedWallet!.currencyCode,
          ),
        );

        final convertedAmount = AppUtils.calculateAmountWithExchangeRate(
          amount: state.amountInput.toDouble(),
          exchangeRate: exchangeRateOutput.exchangeRate.rate,
        );

        emit(
          state.copyWith(
            exchangeRate: exchangeRateOutput.exchangeRate.rate,
            selectedCurrency: event.currency,
            convertedAmount: convertedAmount,
          ),
        );
      },
    );
  }
}
