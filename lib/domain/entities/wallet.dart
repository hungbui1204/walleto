import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.freezed.dart';

@freezed
sealed class Wallet with _$Wallet {
  const factory Wallet({
    @Default(0) int id,
    @Default('') String name,
    @Default(0) double amount,
    String? userId,
    @Default('') String iconUrl,
    @Default('') String currencyCode,
  }) = _Wallet;
}
