part of 'transaction_detail_bloc.dart';

@freezed
sealed class TransactionDetailState extends BaseBlocState with _$TransactionDetailState {
  const TransactionDetailState._();

  const factory TransactionDetailState() = _TransactionDetailState;
}
