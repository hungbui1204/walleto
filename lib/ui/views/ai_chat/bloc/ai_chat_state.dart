part of 'ai_chat_bloc.dart';

@freezed
sealed class AiChatState extends BaseBlocState with _$AiChatState {
  const AiChatState._();

  const factory AiChatState({
    @Default(<AiChatMessage>[]) List<AiChatMessage> messages,
    @Default(false) bool isSending,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default(0) int historyLoadedCount,
  }) = _AiChatState;

  bool get isEmpty => messages.isEmpty && !isSending;
}
