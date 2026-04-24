import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'ai_chat_message.freezed.dart';

@freezed
sealed class AiChatMessage with _$AiChatMessage {
  const factory AiChatMessage({
    @Default('') String reply,
    @Default('') String model,
    @Default(AiChatUsage()) AiChatUsage usage,
    @Default(AiChatDebugContext()) AiChatDebugContext debugContext,
  }) = _AiChatMessage;
}
