import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonRow extends StatelessWidget {
  const CommonRow({super.key, this.prefix, required this.title, required this.content});

  final Widget? prefix;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (prefix != null) ...[prefix!, SizedBox(width: Dimens.d10.responsive())],
        Text(title, style: AppTextStyles.s16wNormalBlack()),
        const Spacer(),
        Text(content, style: AppTextStyles.s16wNormalBlack()),
      ],
    );
  }
}
