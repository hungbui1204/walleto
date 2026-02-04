part of 'transactions_bloc.dart';

sealed class TransactionsEvent extends BaseBlocEvent {
  const TransactionsEvent();
}

@freezed
sealed class TransactionsViewInitialized extends TransactionsEvent
    with _$TransactionsViewInitialized {
  const TransactionsViewInitialized._();

  const factory TransactionsViewInitialized() = _TransactionsViewInitialized;
}

@freezed
sealed class TransactionsRefreshed extends TransactionsEvent with _$TransactionsRefreshed {
  const TransactionsRefreshed._();

  const factory TransactionsRefreshed() = _TransactionsRefreshed;
}

@freezed
sealed class TransactionsMonthSelected extends TransactionsEvent with _$TransactionsMonthSelected {
  const TransactionsMonthSelected._();

  const factory TransactionsMonthSelected({required DateTime selectedDate}) =
      _TransactionsMonthSelected;
}

@freezed
sealed class TransactionsDatePickerMethodExpandTriggered extends TransactionsEvent
    with _$TransactionsDatePickerMethodExpandTriggered {
  const TransactionsDatePickerMethodExpandTriggered._();

  const factory TransactionsDatePickerMethodExpandTriggered() =
      _TransactionsDatePickerMethodExpandTriggered;
}

@freezed
sealed class TransactionsDateRangePicked extends TransactionsEvent
    with _$TransactionsDateRangePicked {
  const TransactionsDateRangePicked._();

  const factory TransactionsDateRangePicked() = _TransactionsDateRangePicked;
}

@freezed
sealed class TransactionsWalletSelected extends TransactionsEvent
    with _$TransactionsWalletSelected {
  const TransactionsWalletSelected._();
  const factory TransactionsWalletSelected({required Wallet selectedWallet}) =
      _TransactionsWalletSelected;
}

@freezed
sealed class TransactionsWalletsUpdated extends TransactionsEvent
    with _$TransactionsWalletsUpdated {
  const TransactionsWalletsUpdated._();

  const factory TransactionsWalletsUpdated({required List<Wallet> wallets}) =
      _TransactionsWalletsUpdated;
}
