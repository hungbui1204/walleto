import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'ai_chat_message.freezed.dart';

@freezed
sealed class AiChatMessage with _$AiChatMessage {
  const factory AiChatMessage({
    @Default(0) int id,
    @Default(AiChatRole.user) AiChatRole role,
    @Default('') String content,
    @Default('') String model,
    DateTime? createdAt,
  }) = _AiChatMessage;
}
