import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency.freezed.dart';

@freezed
sealed class Currency with _$Currency {
  const factory Currency({
    @Default('') String code,
    @Default('') String name,
    @Default('') String symbol,
    @Default(0) int decimalPlaces,
    @Default(true) bool isActive,
    @Default('') String iconUrl,
    DateTime? createdAt,
  }) = _Currency;
}
