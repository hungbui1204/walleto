import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_data.freezed.dart';
part 'transaction_data.g.dart';

@freezed
sealed class TransactionData with _$TransactionData {
  const factory TransactionData({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'amount') double? amount,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'category_id') int? categoryId,
    @JsonKey(name: 'wallet_id') int? walletId,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'note') String? note,
  }) = _TransactionData;

  factory TransactionData.fromJson(Map<String, dynamic> json) => _$TransactionDataFromJson(json);
}
