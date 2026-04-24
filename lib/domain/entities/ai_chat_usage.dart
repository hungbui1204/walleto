import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'ai_chat_usage.freezed.dart';

@freezed
sealed class AiChatUsage with _$AiChatUsage {
  const factory AiChatUsage({
    @Default(0) int promptTokens,
    @Default(0) int completionTokens,
    @Default(0) int totalTokens,
    @Default(AiChatPromptTokensDetails()) AiChatPromptTokensDetails promptTokensDetails,
  }) = _AiChatUsage;
}
