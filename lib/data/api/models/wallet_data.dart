import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_data.freezed.dart';
part 'wallet_data.g.dart';

@freezed
sealed class WalletData with _$WalletData {
  const factory WalletData({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'amount') double? amount,
    @JsonKey(name: 'user_id') String? userId,
  }) = _WalletData;

  factory WalletData.fromJson(Map<String, dynamic> json) => _$WalletDataFromJson(json);
}
