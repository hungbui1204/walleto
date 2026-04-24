import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_history_message.freezed.dart';

@freezed
sealed class AiChatHistoryMessage with _$AiChatHistoryMessage {
  const factory AiChatHistoryMessage({
    @Default(0) int id,
    @Default('') String userId,
    @Default('') String role,
    @Default('') String content,
    @Default('') String model,
    @Default(0) int promptTokens,
    @Default(0) int completionTokens,
    @Default(0) int totalTokens,
    DateTime? createdAt,
  }) = _AiChatHistoryMessage;
}
