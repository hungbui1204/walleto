import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_rate_data.freezed.dart';
part 'exchange_rate_data.g.dart';

@freezed
sealed class ExchangeRateData with _$ExchangeRateData {
  const factory ExchangeRateData({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'from_currency') String? fromCurrency,
    @JsonKey(name: 'to_currency') String? toCurrency,
    @JsonKey(name: 'rate') double? rate,
    @JsonKey(name: 'source') String? source,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'is_active') bool? isActive,
  }) = _ExchangeRateData;

  factory ExchangeRateData.fromJson(Map<String, dynamic> json) => _$ExchangeRateDataFromJson(json);
}
