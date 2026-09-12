import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/data/data.dart';

part 'ai_chat_stream_event_data.freezed.dart';
part 'ai_chat_stream_event_data.g.dart';

@freezed
sealed class AiChatStreamEventData with _$AiChatStreamEventData {
  const factory AiChatStreamEventData({
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'content') String? content,
    @JsonKey(name: 'reply') String? reply,
    @JsonKey(name: 'model') String? model,
    @JsonKey(name: 'usage') AiChatUsageData? usage,
    @JsonKey(name: 'debug_context') AiChatDebugContextData? debugContext,
    @JsonKey(name: 'error') String? error,
    @JsonKey(name: 'user_message_id') int? userMessageId,
    @JsonKey(name: 'assistant_message_id') int? assistantMessageId,
  }) = _AiChatStreamEventData;

  factory AiChatStreamEventData.fromJson(Map<String, dynamic> json) =>
      _$AiChatStreamEventDataFromJson(json);
}
