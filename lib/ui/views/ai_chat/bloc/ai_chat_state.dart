part of 'ai_chat_bloc.dart';

enum AiChatStreamingPhase { idle, loadingContext, generating }

@freezed
sealed class AiChatState extends BaseBlocState with _$AiChatState {
  const AiChatState._();

  const factory AiChatState({
    @Default(<AiChatMessage>[]) List<AiChatMessage> messages,
    @Default(false) bool isSending,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default(0) int historyLoadedCount,
    @Default(AiChatStreamingPhase.idle) AiChatStreamingPhase streamingPhase,
  }) = _AiChatState;

  bool get isEmpty => messages.isEmpty && !isSending;
}
