import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_usage_data.freezed.dart';
part 'ai_chat_usage_data.g.dart';

@freezed
sealed class AiChatUsageData with _$AiChatUsageData {
  const factory AiChatUsageData({
    @JsonKey(name: 'prompt_tokens') int? promptTokens,
    @JsonKey(name: 'completion_tokens') int? completionTokens,
    @JsonKey(name: 'total_tokens') int? totalTokens,
    @JsonKey(name: 'prompt_tokens_details') AiChatPromptTokensDetailsData? promptTokensDetails,
  }) = _AiChatUsageData;

  factory AiChatUsageData.fromJson(Map<String, dynamic> json) =>
      _$AiChatUsageDataFromJson(json);
}
