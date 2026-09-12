import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class AiChatEmptyStateWidget extends StatelessWidget {
  const AiChatEmptyStateWidget({super.key, required this.onPromptSelected});

  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    final prompts = [
      S.current.aiChatSuggestedSpending,
      S.current.aiChatSuggestedWallets,
      S.current.aiChatSuggestedSaving,
    ];

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
      children: [
        SizedBox(height: Dimens.d40.responsive()),
        CommonEmptyPanel(icon: Icons.auto_awesome_rounded, message: S.current.aiChatEmptyMessage),
        SizedBox(height: Dimens.d16.responsive()),
        ...prompts.map(
          (prompt) => Padding(
            padding: EdgeInsets.only(bottom: Dimens.d12.responsive()),
            child: CommonChipButton(text: prompt, onTap: () => onPromptSelected(prompt)),
          ),
        ),
      ],
    );
  }
}
