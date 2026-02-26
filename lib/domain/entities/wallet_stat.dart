import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'wallet_stat.freezed.dart';

@freezed
sealed class WalletStat with _$WalletStat {
  const factory WalletStat({
    @Default(0) int walletId,
    @Default('') String walletName,
    @Default(0) double totalAmount,
    @Default('') String currencyCode,
    @Default([]) List<CategoryStat> categoryStats,
  }) = _WalletStat;
}
