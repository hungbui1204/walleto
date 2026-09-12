import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_history_message_data.freezed.dart';
part 'ai_chat_history_message_data.g.dart';

@freezed
sealed class AiChatHistoryMessageData with _$AiChatHistoryMessageData {
  const factory AiChatHistoryMessageData({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'content') String? content,
    @JsonKey(name: 'model') String? model,
    @JsonKey(name: 'prompt_tokens') int? promptTokens,
    @JsonKey(name: 'completion_tokens') int? completionTokens,
    @JsonKey(name: 'total_tokens') int? totalTokens,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _AiChatHistoryMessageData;

  factory AiChatHistoryMessageData.fromJson(Map<String, dynamic> json) =>
      _$AiChatHistoryMessageDataFromJson(json);
}
