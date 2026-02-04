part of 'edit_transaction_bloc.dart';

@freezed
sealed class EditTransactionState extends BaseBlocState with _$EditTransactionState {
  const EditTransactionState._();

  const factory EditTransactionState({
    @Default(false) bool showKeyboard,
    @Default('0') String amountInput,
    @Default(0) double amount,
    OperationType? currentOperation,
    @Default('') String amountError,
    Category? selectedCategory,
    DateTime? selectedDate,
    @Default('') String note,
    @Default(false) bool confirmButtonEnable,
    Wallet? selectedWallet,
    Currency? selectedCurrency,
    double? convertedAmount,
    double? exchangeRate,
    @Default(0) int transactionId,
  }) = _EditTransactionState;
}
