import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_prompt_tokens_details.freezed.dart';

@freezed
sealed class AiChatPromptTokensDetails with _$AiChatPromptTokensDetails {
  const factory AiChatPromptTokensDetails({
    @Default(0) int cachedTokens,
  }) = _AiChatPromptTokensDetails;
}
