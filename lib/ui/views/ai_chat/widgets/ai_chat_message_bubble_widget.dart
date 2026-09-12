import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';

class AiChatMessageBubbleWidget extends StatelessWidget {
  const AiChatMessageBubbleWidget({super.key, required this.message});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiChatRole.user;
    final radius = Dimens.d16.responsive();

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
          child: Text(
            message.content,
            style:
                isUser
                    ? AppTextStyles.s14wNormalBlack().copyWith(color: onPrimaryColor)
                    : AppTextStyles.s14wNormalBlack(),
          ),
        ),
      ),
    );
  }
}
