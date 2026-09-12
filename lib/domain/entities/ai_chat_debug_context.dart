import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_debug_context.freezed.dart';

@freezed
sealed class AiChatDebugContext with _$AiChatDebugContext {
  const factory AiChatDebugContext({
    @Default('') String baseCurrency,
    @Default(0) int walletCount,
    @Default(0) int transactionCount,
    @Default(<String>[]) List<String> missingRateCurrencies,
  }) = _AiChatDebugContext;
}
