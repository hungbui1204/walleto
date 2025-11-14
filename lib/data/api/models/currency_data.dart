import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_data.freezed.dart';
part 'currency_data.g.dart';

@freezed
sealed class CurrencyData with _$CurrencyData {
  const factory CurrencyData({
    @JsonKey(name: 'code') String? code,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'symbol') String? symbol,
    @JsonKey(name: 'decimal_places') int? decimalPlaces,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _CurrencyData;

  factory CurrencyData.fromJson(Map<String, dynamic> json) => _$CurrencyDataFromJson(json);
}
