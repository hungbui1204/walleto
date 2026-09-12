import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'ai_chat_event.dart';
part 'ai_chat_state.dart';
part 'ai_chat_bloc.freezed.dart';

@injectable
class AiChatBloc extends BaseBloc<AiChatEvent, AiChatState> {
  AiChatBloc(this._getAiChatHistoryUseCase, this._sendAiChatMessageUseCase)
    : super(const AiChatState()) {
    on<AiChatViewInitiated>(_onAiChatViewInitiated, transformer: log());
    on<AiChatLoadMoreRequested>(_onAiChatLoadMoreRequested, transformer: exhaustMap());
    on<AiChatMessageSubmitted>(_onAiChatMessageSubmitted, transformer: exhaustMap());
    on<AiChatGenerationStopRequested>(_onAiChatGenerationStopRequested, transformer: log());
  }

  final GetAiChatHistoryUseCase _getAiChatHistoryUseCase;
  final SendAiChatMessageUseCase _sendAiChatMessageUseCase;
  AppCancelToken? _sendCancelToken;

  @override
  Future<void> close() {
    _sendCancelToken?.cancel();
    return super.close();
  }

  Future<void> _onAiChatViewInitiated(AiChatViewInitiated event, Emitter<AiChatState> emit) async {
    await runBlocCatching(
      action: () async {
        final output = await _getAiChatHistoryUseCase.execute(const GetAiChatHistoryInput());
        final chronological = output.messages.reversed.toList();

        emit(
          state.copyWith(
            messages: chronological,
            historyLoadedCount: output.messages.length,
            hasMore: output.messages.length >= PagingConstants.aiChatHistoryPageSize,
          ),
        );
      },
    );
  }

  Future<void> _onAiChatLoadMoreRequested(
    AiChatLoadMoreRequested event,
    Emitter<AiChatState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore || state.isSending) {
      return;
    }

    await runBlocCatching(
      handleLoading: false,
      action: () async {
        emit(state.copyWith(isLoadingMore: true));

        final output = await _getAiChatHistoryUseCase.execute(
          GetAiChatHistoryInput(offset: state.historyLoadedCount),
        );
        final olderChronological = output.messages.reversed.toList();

        emit(
          state.copyWith(
            isLoadingMore: false,
            messages: [...olderChronological, ...state.messages],
            historyLoadedCount: state.historyLoadedCount + output.messages.length,
            hasMore: output.messages.length >= PagingConstants.aiChatHistoryPageSize,
          ),
        );
      },
      doOnError: (_) async {
        emit(state.copyWith(isLoadingMore: false));
      },
    );
  }

  Future<void> _onAiChatMessageSubmitted(
    AiChatMessageSubmitted event,
    Emitter<AiChatState> emit,
  ) async {
    final message = event.message.trim();
    if (message.isEmpty || state.isSending) {
      return;
    }

    final userMessage = AiChatMessage(content: message);
    final cancelToken = AppCancelToken();
    _sendCancelToken?.cancel();
    _sendCancelToken = cancelToken;

    await runBlocCatching(
      handleLoading: false,
      handleRetry: false,
      handleError: false,
      forceHandleError: _shouldHandleSendError,
      action: () async {
        emit(
          state.copyWith(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.idle,
            messages: [
              ...state.messages,
              userMessage,
              const AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
        );

        final pendingDelta = StringBuffer();
        var lastUiEmitAt = DateTime.fromMillisecondsSinceEpoch(0);

        void flushPendingAssistantDelta() {
          if (pendingDelta.isEmpty) {
            return;
          }

          final content = pendingDelta.toString();
          pendingDelta.clear();
          emit(
            state.copyWith(
              streamingPhase: AiChatStreamingPhase.generating,
              messages: _appendAssistantDelta(state.messages, content),
            ),
          );
        }

        try {
          await for (final output in _sendAiChatMessageUseCase.execute(
            SendAiChatMessageInput(message: message, cancelToken: cancelToken),
          )) {
            switch (output.event) {
              case AiChatStreamStatus(:final status):
                if (!state.isSending ||
                    state.streamingPhase == AiChatStreamingPhase.generating ||
                    status != AiChatSseConstants.statusLoadingContext) {
                  break;
                }

                emit(state.copyWith(streamingPhase: AiChatStreamingPhase.loadingContext));
              case AiChatStreamDelta(:final content):
                pendingDelta.write(content);
                final now = DateTime.now();
                if (now.difference(lastUiEmitAt) >= DurationConstants.aiChatStreamUiThrottle) {
                  flushPendingAssistantDelta();
                  lastUiEmitAt = now;
                }
              case AiChatStreamCompleted(:final result):
                flushPendingAssistantDelta();
                emit(
                  state.copyWith(
                    isSending: false,
                    streamingPhase: AiChatStreamingPhase.idle,
                    messages: _finalizeStreamingAssistant(state.messages, result.message),
                  ),
                );
              case AiChatStreamPersisted(:final userMessageId, :final assistantMessageId):
                if (state.isSending || userMessageId <= 0 || assistantMessageId <= 0) {
                  break;
                }

                emit(
                  state.copyWith(
                    streamingPhase: AiChatStreamingPhase.idle,
                    messages: _applyPersistedTurnIds(
                      state.messages,
                      userMessageId: userMessageId,
                      assistantMessageId: assistantMessageId,
                    ),
                    historyLoadedCount:
                        state.historyLoadedCount + PagingConstants.aiChatTurnMessageCount,
                  ),
                );
            }
          }
        } catch (_) {
          flushPendingAssistantDelta();
          rethrow;
        } finally {
          if (identical(_sendCancelToken, cancelToken)) {
            _sendCancelToken = null;
          }
        }
      },
      doOnError: (_) async {
        if (isClosed) {
          return;
        }

        emit(
          state.copyWith(
            isSending: false,
            streamingPhase: AiChatStreamingPhase.idle,
            messages: _removeEmptyTrailingAssistant(state.messages),
          ),
        );
      },
    );
  }

  void _onAiChatGenerationStopRequested(
    AiChatGenerationStopRequested event,
    Emitter<AiChatState> emit,
  ) {
    _sendCancelToken?.cancel();
  }

  bool _shouldHandleSendError(AppException error) {
    return error is! RemoteException || error.kind != RemoteExceptionKind.cancellation;
  }

  List<AiChatMessage> _appendAssistantDelta(List<AiChatMessage> messages, String delta) {
    if (messages.isEmpty) {
      return [AiChatMessage(role: AiChatRole.assistant, content: delta)];
    }

    final last = messages.last;
    if (last.role != AiChatRole.assistant) {
      return [...messages, AiChatMessage(role: AiChatRole.assistant, content: delta)];
    }

    return [
      ...messages.sublist(0, messages.length - 1),
      last.copyWith(content: last.content + delta),
    ];
  }

  List<AiChatMessage> _finalizeStreamingAssistant(
    List<AiChatMessage> messages,
    AiChatMessage completedMessage,
  ) {
    if (messages.isEmpty || messages.last.role != AiChatRole.assistant) {
      return [...messages, completedMessage];
    }

    final last = messages.last;
    final content = last.content.isNotEmpty ? last.content : completedMessage.content;

    return [
      ...messages.sublist(0, messages.length - 1),
      last.copyWith(
        content: content,
        model: completedMessage.model.isNotEmpty ? completedMessage.model : last.model,
      ),
    ];
  }

  List<AiChatMessage> _applyPersistedTurnIds(
    List<AiChatMessage> messages, {
    required int userMessageId,
    required int assistantMessageId,
  }) {
    if (messages.length < PagingConstants.aiChatTurnMessageCount) {
      return messages;
    }

    final assistant = messages.last;
    final user = messages[messages.length - PagingConstants.aiChatTurnMessageCount];
    if (assistant.role != AiChatRole.assistant || user.role != AiChatRole.user) {
      return messages;
    }

    return [
      ...messages.sublist(0, messages.length - PagingConstants.aiChatTurnMessageCount),
      user.copyWith(id: userMessageId),
      assistant.copyWith(id: assistantMessageId),
    ];
  }

  List<AiChatMessage> _removeEmptyTrailingAssistant(List<AiChatMessage> messages) {
    if (messages.isEmpty) {
      return messages;
    }

    final last = messages.last;
    if (last.role != AiChatRole.assistant || last.content.isNotEmpty) {
      return messages;
    }

    return messages.sublist(0, messages.length - 1);
  }
}
