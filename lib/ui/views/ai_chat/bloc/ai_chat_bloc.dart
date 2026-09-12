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
  }

  final GetAiChatHistoryUseCase _getAiChatHistoryUseCase;
  final SendAiChatMessageUseCase _sendAiChatMessageUseCase;

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

    final previousMessages = state.messages;
    final userMessage = AiChatMessage(content: message);

    await runBlocCatching(
      handleLoading: false,
      action: () async {
        emit(state.copyWith(isSending: true, messages: [...previousMessages, userMessage]));

        final output = await _sendAiChatMessageUseCase.execute(
          SendAiChatMessageInput(message: message),
        );

        emit(
          state.copyWith(
            isSending: false,
            messages: [...state.messages, output.result.message],
            historyLoadedCount: state.historyLoadedCount + 2,
          ),
        );
      },
      doOnError: (_) async {
        emit(state.copyWith(isSending: false, messages: previousMessages));
      },
    );
  }
}
