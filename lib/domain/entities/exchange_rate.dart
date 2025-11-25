import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_rate.freezed.dart';

@freezed
sealed class ExchangeRate with _$ExchangeRate {
  const factory ExchangeRate({
    @Default(0) int id,
    @Default('') String fromCurrency,
    @Default('') String toCurrency,
    @Default(0.0) double rate,
    @Default('') String source,
    DateTime? createdAt,
    @Default(false) bool isActive,
  }) = _ExchangeRate;
}
