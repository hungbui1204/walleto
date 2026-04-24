import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_message.freezed.dart';

@freezed
sealed class AiChatMessage with _$AiChatMessage {
  const factory AiChatMessage({
    @Default('') String reply,
    @Default('') String model,
    @Default(0) int promptTokens,
    @Default(0) int completionTokens,
    @Default(0) int totalTokens,
  }) = _AiChatMessage;
}
