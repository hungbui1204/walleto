import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonRow extends StatelessWidget {
  const CommonRow({super.key, this.prefix, required this.title, required this.content, this.onTap});

  final Widget? prefix;
  final String title;
  final String content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Row(
        children: [
          if (prefix != null) ...[prefix!, SizedBox(width: Dimens.d10.responsive())],
          Text(title, style: AppTextStyles.s16wNormalBlack()),
          const Spacer(),
          Text(content, style: AppTextStyles.s16wNormalBlack()),
        ],
      ),
    );
  }
}
