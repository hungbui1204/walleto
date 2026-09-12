import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class AiChatStreamingMessageWidget extends StatelessWidget {
  const AiChatStreamingMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen:
          (previous, current) =>
              previous.streamingPhase != current.streamingPhase ||
              previous.isSending != current.isSending ||
              _trailingAssistantContent(previous) != _trailingAssistantContent(current),
      builder: (context, state) {
        final last = _trailingMessage(state);
        final isEmptyAssistant =
            last != null && last.role == AiChatRole.assistant && last.content.isEmpty;

        if (state.isSending && isEmptyAssistant) {
          return AiChatTypingIndicatorWidget(
            label:
                state.streamingPhase == AiChatStreamingPhase.loadingContext
                    ? S.current.aiChatLoadingContext
                    : S.current.aiChatTyping,
          );
        }

        if (last == null || last.role != AiChatRole.assistant) {
          return const SizedBox.shrink();
        }

        return AiChatMessageBubbleWidget(message: last, isStreaming: true);
      },
    );
  }

  static AiChatMessage? _trailingMessage(AiChatState state) {
    if (state.messages.isEmpty) {
      return null;
    }

    return state.messages.last;
  }

  static String _trailingAssistantContent(AiChatState state) {
    final last = _trailingMessage(state);
    if (last == null || last.role != AiChatRole.assistant) {
      return '';
    }

    return last.content;
  }
}
