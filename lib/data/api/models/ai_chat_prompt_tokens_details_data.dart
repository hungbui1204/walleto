import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_prompt_tokens_details_data.freezed.dart';
part 'ai_chat_prompt_tokens_details_data.g.dart';

@freezed
sealed class AiChatPromptTokensDetailsData with _$AiChatPromptTokensDetailsData {
  const factory AiChatPromptTokensDetailsData({
    @JsonKey(name: 'cached_tokens') int? cachedTokens,
  }) = _AiChatPromptTokensDetailsData;

  factory AiChatPromptTokensDetailsData.fromJson(Map<String, dynamic> json) =>
      _$AiChatPromptTokensDetailsDataFromJson(json);
}
