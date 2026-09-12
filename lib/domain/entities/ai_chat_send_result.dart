import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'ai_chat_send_result.freezed.dart';

@freezed
sealed class AiChatSendResult with _$AiChatSendResult {
  const factory AiChatSendResult({
    @Default(AiChatMessage()) AiChatMessage message,
    @Default(AiChatUsage()) AiChatUsage usage,
    @Default(AiChatDebugContext()) AiChatDebugContext debugContext,
    @Default(0) int userMessageId,
  }) = _AiChatSendResult;
}
