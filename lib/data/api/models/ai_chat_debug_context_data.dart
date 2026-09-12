import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_debug_context_data.freezed.dart';
part 'ai_chat_debug_context_data.g.dart';

@freezed
sealed class AiChatDebugContextData with _$AiChatDebugContextData {
  const factory AiChatDebugContextData({
    @JsonKey(name: 'base_currency') String? baseCurrency,
    @JsonKey(name: 'wallet_count') int? walletCount,
    @JsonKey(name: 'transaction_count') int? transactionCount,
    @JsonKey(name: 'missing_rate_currencies') List<String>? missingRateCurrencies,
  }) = _AiChatDebugContextData;

  factory AiChatDebugContextData.fromJson(Map<String, dynamic> json) =>
      _$AiChatDebugContextDataFromJson(json);
}
