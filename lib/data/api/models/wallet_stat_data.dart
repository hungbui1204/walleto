import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/data/data.dart';

part 'wallet_stat_data.freezed.dart';
part 'wallet_stat_data.g.dart';

@freezed
sealed class WalletStatData with _$WalletStatData {
  const factory WalletStatData({
    @JsonKey(name: 'wallet_id') int? walletId,
    @JsonKey(name: 'wallet_name') String? walletName,
    @JsonKey(name: 'total_amount') double? totalAmount,
    @JsonKey(name: 'currency_code') String? currencyCode,
    @JsonKey(name: 'categories') List<CategoryStatData>? categoryStats,
  }) = _WalletStatData;

  factory WalletStatData.fromJson(Map<String, dynamic> json) => _$WalletStatDataFromJson(json);
}
