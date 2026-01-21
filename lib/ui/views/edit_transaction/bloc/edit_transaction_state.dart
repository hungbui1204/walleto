part of 'edit_transaction_bloc.dart';

@freezed
sealed class EditTransactionState extends BaseBlocState with _$EditTransactionState {
  const EditTransactionState._();

  const factory EditTransactionState({@Default(Transaction()) Transaction transaction}) =
      _EditTransactionState;
}
