import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class AiChatComposerWidget extends StatelessWidget {
  const AiChatComposerWidget({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSubmit,
    required this.onStop,
  });

  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onSubmit;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Dimens.d16.responsive());

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Dimens.d16.responsive(),
          Dimens.d8.responsive(),
          Dimens.d16.responsive(),
          Dimens.d28.responsive(),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: CommonTextField(
                controller: controller,
                hintText: S.current.aiChatInputHint,
                maxLines: 4,
                maxLength: AppConstants.maxAiChatMessageLength,
                textInputAction: TextInputAction.send,
                onSubmitted: isSending ? null : onSubmit,
              ),
            ),
            SizedBox(width: Dimens.d8.responsive()),
            Pressable(
              onTap: isSending ? onStop : () => onSubmit(controller.text),
              semanticLabel: isSending ? S.current.aiChatStop : S.current.aiChatSend,
              borderRadius: radius,
              child: Container(
                width: Dimens.d48.responsive(),
                height: Dimens.d48.responsive(),
                alignment: Alignment.center,
                decoration:
                    isSending
                        ? AppDecorations.secondaryCta(radius: radius, borderColor: alertColor)
                        : AppDecorations.primaryCta(radius: radius),
                child: Icon(
                  isSending ? Icons.stop_rounded : Icons.send_rounded,
                  color: isSending ? alertColor : onPrimaryColor,
                  size: Dimens.d20.responsive(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
