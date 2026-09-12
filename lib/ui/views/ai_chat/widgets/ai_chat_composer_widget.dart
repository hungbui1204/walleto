import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class AiChatComposerWidget extends StatelessWidget {
  const AiChatComposerWidget({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
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
                enabled: enabled,
                hintText: S.current.aiChatInputHint,
                maxLines: 4,
                maxLength: AppConstants.maxAiChatMessageLength,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? onSubmit : null,
              ),
            ),
            SizedBox(width: Dimens.d8.responsive()),
            Pressable(
              onTap: enabled ? () => onSubmit(controller.text) : null,
              semanticLabel: S.current.aiChatSend,
              borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
              child: Container(
                width: Dimens.d48.responsive(),
                height: Dimens.d48.responsive(),
                alignment: Alignment.center,
                decoration: AppDecorations.primaryCta(
                  radius: BorderRadius.circular(Dimens.d16.responsive()),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: onPrimaryColor,
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
