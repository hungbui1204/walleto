part of 'create_transaction_bloc.dart';

@freezed
sealed class CreateTransactionState extends BaseBlocState with _$CreateTransactionState {
  const CreateTransactionState._();
  const factory CreateTransactionState({
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
  }) = _CreateTransactionState;
}
