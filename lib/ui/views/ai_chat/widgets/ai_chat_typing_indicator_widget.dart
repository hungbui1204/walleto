import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class AiChatTypingIndicatorWidget extends StatelessWidget {
  const AiChatTypingIndicatorWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: Dimens.d12.responsive()),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d16.responsive(),
          vertical: Dimens.d12.responsive(),
        ),
        decoration: AppDecorations.glassPanel(),
        child: Text(label, style: AppTextStyles.s14wNormalGrey()),
      ),
    );
  }
}
