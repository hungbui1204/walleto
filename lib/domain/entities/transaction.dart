import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'transaction.freezed.dart';

@freezed
sealed class Transaction with _$Transaction {
  const factory Transaction({
    @Default(0) int id,
    @Default(0) double amount,
    DateTime? createdAt,
    @Default(0) int categoryId,
    @Default(0) int walletId,
    @Default(Category()) Category category,
    @Default(Wallet()) Wallet wallet,
    String? userId,
    @Default('') String note,
  }) = _Transaction;
}
