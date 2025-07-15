import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'day_transactions.freezed.dart';

@freezed
sealed class DayTransactions with _$DayTransactions {
  const factory DayTransactions({
    @Default(<Transaction>[]) List<Transaction> transactions,
    DateTime? date,
    @Default(0) double totalAmount,
  }) = _DayTransactions;
}
