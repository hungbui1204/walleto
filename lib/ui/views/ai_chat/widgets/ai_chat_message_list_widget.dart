import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

const _streamingAssistantKey = ValueKey<String>('streaming-assistant');

class AiChatMessageListWidget extends StatelessWidget {
  const AiChatMessageListWidget({
    super.key,
    required this.scrollController,
    required this.onPromptSelected,
  });

  final ScrollController scrollController;
  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen:
          (previous, current) =>
              previous.messages.length != current.messages.length ||
              previous.isLoadingMore != current.isLoadingMore,
      builder: (context, state) {
        if (state.isEmpty) {
          return AiChatEmptyStateWidget(onPromptSelected: onPromptSelected);
        }

        final messages = state.messages;
        final isStreamingLast =
            state.isSending && messages.isNotEmpty && messages.last.role == AiChatRole.assistant;
        final frozenCount = isStreamingLast ? messages.length - 1 : messages.length;
        final itemCount = frozenCount + (isStreamingLast ? 1 : 0);

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (isStreamingLast && index == 0) {
              return const AiChatStreamingMessageWidget(key: _streamingAssistantKey);
            }

            final frozenIndex = isStreamingLast ? index - 1 : index;
            final message = messages[frozenCount - 1 - frozenIndex];

            return AiChatMessageBubbleWidget(key: _messageKey(message), message: message);
          },
        );
      },
    );
  }

  static Key _messageKey(AiChatMessage message) {
    if (message.id > 0) {
      return ValueKey<int>(message.id);
    }

    return ValueKey<String>('ai-chat-unpersisted-${message.role.name}-${message.content}');
  }
}
