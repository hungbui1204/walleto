import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'ai_chat_stream_event.freezed.dart';

@freezed
sealed class AiChatStreamEvent with _$AiChatStreamEvent {
  const AiChatStreamEvent._();

  const factory AiChatStreamEvent.status({@Default('') String status}) = AiChatStreamStatus;

  const factory AiChatStreamEvent.delta({@Default('') String content}) = AiChatStreamDelta;

  const factory AiChatStreamEvent.completed({
    @Default(AiChatSendResult()) AiChatSendResult result,
  }) = AiChatStreamCompleted;

  const factory AiChatStreamEvent.persisted({
    @Default(0) int userMessageId,
    @Default(0) int assistantMessageId,
  }) = AiChatStreamPersisted;
}
