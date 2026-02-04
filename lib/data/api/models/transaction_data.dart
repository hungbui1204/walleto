import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/data/data.dart';

part 'transaction_data.freezed.dart';
part 'transaction_data.g.dart';

@freezed
sealed class TransactionData with _$TransactionData {
  const factory TransactionData({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'amount') double? amount,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'category_id') int? categoryId,
    @JsonKey(name: 'wallet_id') int? walletId,
    @JsonKey(name: 'category') CategoryData? category,
    @JsonKey(name: 'wallet') WalletData? wallet,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'currency_code') String? currencyCode,
    @JsonKey(name: 'transaction_date') String? transactionDate,
  }) = _TransactionData;

  factory TransactionData.fromJson(Map<String, dynamic> json) => _$TransactionDataFromJson(json);
}
