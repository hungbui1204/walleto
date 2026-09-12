import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class AiChatMessageBubbleWidget extends StatelessWidget {
  const AiChatMessageBubbleWidget({super.key, required this.message, this.isStreaming = false});

  final AiChatMessage message;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiChatRole.user;
    final radius = Dimens.d16.responsive();
    final style =
        isUser
            ? AppTextStyles.s14wNormalBlack().copyWith(color: onPrimaryColor)
            : AppTextStyles.s14wNormalBlack();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Dimens.d280.responsive()),
        child: Container(
          margin: EdgeInsets.only(bottom: Dimens.d12.responsive()),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.d16.responsive(),
            vertical: Dimens.d12.responsive(),
          ),
          decoration:
              isUser
                  ? AppDecorations.primaryCta(
                    radius: BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius),
                      bottomLeft: Radius.circular(radius),
                    ),
                  )
                  : AppDecorations.glassPanel(radius: radius),
          child: _body(isUser: isUser, style: style),
        ),
      ),
    );
  }

  Widget _body({required bool isUser, required TextStyle style}) {
    if (!isUser && !isStreaming) {
      return AiChatAssistantMarkdownWidget(content: message.content);
    }

    return SelectableText(message.content, style: style);
  }
}
