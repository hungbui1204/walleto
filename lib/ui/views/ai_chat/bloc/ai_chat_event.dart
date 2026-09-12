part of 'ai_chat_bloc.dart';

sealed class AiChatEvent extends BaseBlocEvent {
  const AiChatEvent();
}

@freezed
sealed class AiChatViewInitiated extends AiChatEvent with _$AiChatViewInitiated {
  const AiChatViewInitiated._();

  const factory AiChatViewInitiated() = _AiChatViewInitiated;
}

@freezed
sealed class AiChatLoadMoreRequested extends AiChatEvent with _$AiChatLoadMoreRequested {
  const AiChatLoadMoreRequested._();

  const factory AiChatLoadMoreRequested() = _AiChatLoadMoreRequested;
}

@freezed
sealed class AiChatMessageSubmitted extends AiChatEvent with _$AiChatMessageSubmitted {
  const AiChatMessageSubmitted._();

  const factory AiChatMessageSubmitted({required String message}) = _AiChatMessageSubmitted;
}
