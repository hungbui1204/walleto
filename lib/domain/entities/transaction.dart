import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

@freezed
sealed class Transaction with _$Transaction {
  const factory Transaction({
    @Default(0) int id,
    @Default(0) double amount,
    @Default('') String date,
    int? categoryId,
    int? walletId,
    String? userId,
    @Default('') String note,
  }) = _Transaction;
}
