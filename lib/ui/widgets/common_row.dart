import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/widgets/pressable.dart';

class CommonRow extends StatelessWidget {
  const CommonRow({
    super.key,
    this.prefix,
    required this.title,
    required this.content,
    this.onTap,
  });

  final Widget? prefix;
  final String title;
  final String content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: '$title $content',
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: Dimens.d44.responsive()),
        child: Row(
          children: [
            if (prefix != null) ...[
              prefix!,
              SizedBox(width: Dimens.d10.responsive()),
            ],
            Expanded(
              child: Text(title, style: AppTextStyles.s16wNormalBlack()),
            ),
            Text(
              content,
              style: AppThemes.amount(fontSize: Dimens.d16.responsive()),
            ),
          ],
        ),
      ),
    );
  }
}
