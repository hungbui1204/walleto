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
  CreateTransactionBloc(this._createTransactionUseCase, this._getExchangeRateUseCase)
    : super(const CreateTransactionState()) {
    on<CreateTransactionViewInitiated>(_onCreateTransactionViewInitiated, transformer: log());
    on<CreateTransactionKeyboardToggled>(_onCreateTransactionKeyboardToggled, transformer: log());
    on<CreateTransactionAmountChanged>(_onCreateTransactionAmountChanged, transformer: log());
    on<CreateTransactionOperationChanged>(_onCreateTransactionOperationChanged, transformer: log());
    on<CreateTransactionBackspacePressed>(_onCreateTransactionBackspacePressed, transformer: log());
    on<CreateTransactionClearPressed>(_onCreateTransactionClearPressed, transformer: log());
    on<CreateTransactionEqualButtonPressed>(
      _onCreateTransactionEqualButtonPressed,
      transformer: log(),
    );
    on<CreateTransactionConfirmButtonPressed>(
      _onCreateTransactionConfirmButtonPressed,
      transformer: log(),
    );
    on<CreateTransactionCategorySelected>(_onCreateTransactionCategorySelected, transformer: log());
    on<CreateTransactionDateSelected>(_onCreateTransactionDateSelected, transformer: log());
    on<CreateTransactionNoteChanged>(_onCreateTransactionNoteChanged, transformer: log());
    on<CreateTransactionWalletSelected>(_onCreateTransactionWalletSelected, transformer: log());
    on<CreateTransactionCurrencySelected>(_onCreateTransactionCurrencySelected, transformer: log());
  }

  final CreateTransactionUseCase _createTransactionUseCase;
  final GetExchangeRateUseCase _getExchangeRateUseCase;
  int _exchangeRateRequestId = 0;
  bool _isExchangeRateLoading = false;
  bool _isSubmitting = false;
  bool _hasSubmittedSuccessfully = false;

  bool _confirmButtonEnableCheck({
    required String amountInput,
    required Category? selectedCategory,
    required DateTime? selectedDate,
    required String amountError,
    bool exchangeRateReady = true,
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
        exchangeRateReady &&
        !_isSubmitting &&
        !AppUtils.isContainOperator(amountInput);
  }

  bool get _isExchangeRateReady {
    final wallet = state.selectedWallet;
    final currency = state.selectedCurrency;
    if (wallet == null || currency == null || currency.code == wallet.currencyCode) {
      return !_isExchangeRateLoading;
    }

    return !_isExchangeRateLoading && state.exchangeRate != null && state.convertedAmount != null;
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

  void _onCreateTransactionViewInitiated(
    CreateTransactionViewInitiated event,
    Emitter<CreateTransactionState> emit,
  ) {
    final wallets = appBloc.state.wallets;
    final currencies = appBloc.state.currencies;
    if (wallets.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final defaultWallet = wallets.first;
    final defaultCurrency = currencies.isEmpty
        ? null
        : currencies.firstWhere(
            (currency) => currency.code == defaultWallet.currencyCode,
            orElse: () => currencies.first,
          );

    emit(
      state.copyWith(
        selectedDate: now,
        selectedWallet: defaultWallet,
        selectedCurrency: defaultCurrency,
      ),
    );
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
          exchangeRateReady: _isExchangeRateReady,
        ),
      ),
    );

    _updateConvertAmount(emit);
  }

  void _onCreateTransactionEqualButtonPressed(
    CreateTransactionEqualButtonPressed event,
    Emitter<CreateTransactionState> emit,
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
          exchangeRateReady: _isExchangeRateReady,
        ),
      ),
    );

    _updateConvertAmount(emit);
  }

  void _onCreateTransactionOperationChanged(
    CreateTransactionOperationChanged event,
    Emitter<CreateTransactionState> emit,
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
          exchangeRateReady: _isExchangeRateReady,
        ),
      ),
    );
  }

  void _onCreateTransactionBackspacePressed(
    CreateTransactionBackspacePressed event,
    Emitter<CreateTransactionState> emit,
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
          exchangeRateReady: _isExchangeRateReady,
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
        convertedAmount: state.convertedAmount != null ? 0.0 : null,
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
          exchangeRateReady: _isExchangeRateReady,
        ),
      ),
    );
  }

  Future<void> _onCreateTransactionConfirmButtonPressed(
    CreateTransactionConfirmButtonPressed event,
    Emitter<CreateTransactionState> emit,
  ) async {
    if (_isSubmitting || !state.confirmButtonEnable || !_isExchangeRateReady) {
      return;
    }
    _isSubmitting = true;

    await runBlocCatching(
      doOnSubscribe: () async {
        emit(state.copyWith(confirmButtonEnable: false));
      },
      doOnError: (_) async {
        if (_hasSubmittedSuccessfully) return;
        _isSubmitting = false;
        if (!isClosed) {
          emit(
            state.copyWith(
              confirmButtonEnable: _confirmButtonEnableCheck(
                amountInput: state.amountInput,
                selectedCategory: state.selectedCategory,
                selectedDate: state.selectedDate,
                amountError: state.amountError,
                exchangeRateReady: _isExchangeRateReady,
              ),
            ),
          );
        }
      },
      doOnEventCompleted: () async {
        if (!_hasSubmittedSuccessfully) {
          _isSubmitting = false;
        }
      },
      action: () async {
        // If the [state.convertedAmount] is not null, use it as the transaction amount
        // Otherwise, use the [state.amountInput] as the transaction amount
        final amount = state.convertedAmount ?? state.amountInput.toDouble();

        final newTransaction = Transaction(
          amount: amount,
          categoryId: state.selectedCategory?.id ?? 0,
          transactionDate: state.selectedDate,
          note: state.note,
          walletId: state.selectedWallet?.id ?? 0,
          currencyCode: state.selectedWallet?.currencyCode ?? '',
        );

        await _createTransactionUseCase.execute(
          CreateTransactionInput(transaction: newTransaction),
        );
        _hasSubmittedSuccessfully = true;

        // Refresh transactions after creating a new transaction
        // Refresh the wallets to update the balance
        appBloc.add(const TransactionsReloaded(needReloadTransactions: true));
        appBloc.add(const StatisticalChartsReloaded(needReloadStatisticalCharts: true));
        appBloc.add(const DataFetched(walletsFetched: true));
        navigator.pop();
      },
    );
  }

  void _onCreateTransactionDateSelected(
    CreateTransactionDateSelected event,
    Emitter<CreateTransactionState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onCreateTransactionNoteChanged(
    CreateTransactionNoteChanged event,
    Emitter<CreateTransactionState> emit,
  ) {
    emit(state.copyWith(note: event.note));
  }

  void _onCreateTransactionWalletSelected(
    CreateTransactionWalletSelected event,
    Emitter<CreateTransactionState> emit,
  ) {
    if (event.wallet.id == state.selectedWallet?.id) return;
    _exchangeRateRequestId++;
    _isExchangeRateLoading = false;

    // Reset the selected currency to selected wallet's currency, exchange rate, and converted amount
    final walletCurrency = appBloc.state.currencies.isEmpty
        ? null
        : appBloc.state.currencies.firstWhere(
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
          exchangeRateReady:
              walletCurrency == null || walletCurrency.code == event.wallet.currencyCode,
        ),
      ),
    );
  }

  Future<void> _onCreateTransactionCurrencySelected(
    CreateTransactionCurrencySelected event,
    Emitter<CreateTransactionState> emit,
  ) async {
    if (event.currency == state.selectedCurrency &&
        (_isExchangeRateLoading || _isExchangeRateReady)) {
      return;
    }

    final selectedWallet = state.selectedWallet;
    if (selectedWallet == null) return;
    final requestId = ++_exchangeRateRequestId;

    if (event.currency.code == selectedWallet.currencyCode) {
      _isExchangeRateLoading = false;
      emit(
        state.copyWith(
          exchangeRate: null,
          selectedCurrency: event.currency,
          convertedAmount: null,
          confirmButtonEnable: _confirmButtonEnableCheck(
            amountInput: state.amountInput,
            selectedCategory: state.selectedCategory,
            selectedDate: state.selectedDate,
            amountError: state.amountError,
          ),
        ),
      );

      return;
    }

    _isExchangeRateLoading = true;
    emit(
      state.copyWith(
        selectedCurrency: event.currency,
        exchangeRate: null,
        convertedAmount: null,
        confirmButtonEnable: false,
      ),
    );

    await runBlocCatching(
      action: () async {
        final exchangeRateOutput = await _getExchangeRateUseCase.execute(
          GetExchangeRateInput(
            fromCurrencyCode: event.currency.code,
            toCurrencyCode: selectedWallet.currencyCode,
          ),
        );

        if (requestId != _exchangeRateRequestId ||
            state.selectedCurrency?.code != event.currency.code ||
            state.selectedWallet?.currencyCode != selectedWallet.currencyCode) {
          return;
        }

        _isExchangeRateLoading = false;
        final convertedAmount = AppUtils.calculateAmountWithExchangeRate(
          amount: state.amountInput.toDouble(),
          exchangeRate: exchangeRateOutput.exchangeRate.rate,
        );

        emit(
          state.copyWith(
            exchangeRate: exchangeRateOutput.exchangeRate.rate,
            convertedAmount: convertedAmount,
            confirmButtonEnable: _confirmButtonEnableCheck(
              amountInput: state.amountInput,
              selectedCategory: state.selectedCategory,
              selectedDate: state.selectedDate,
              amountError: state.amountError,
            ),
          ),
        );
      },
      doOnError: (_) async {
        if (requestId == _exchangeRateRequestId) {
          _isExchangeRateLoading = false;
        }
        if (requestId == _exchangeRateRequestId && !isClosed) {
          emit(state.copyWith(confirmButtonEnable: false));
        }
      },
    );
  }
}
