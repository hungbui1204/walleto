import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonForwardButton extends StatelessWidget {
  const CommonForwardButton({
    super.key,
    required this.title,
    this.onTap,
    this.borderRadius,
    this.padding,
    this.color,
    this.leadingIcon,
  });

  final String title;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? primaryShade1Color,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: padding ?? EdgeInsets.all(Dimens.d12.responsive()),
          child: Row(
            children: [
              if (leadingIcon != null) ...[leadingIcon!, SizedBox(width: Dimens.d8.responsive())],
              Text(title, style: AppTextStyles.s14wNormalBlack()),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: Dimens.d14.responsive()),
            ],
          ),
        ),
      ),
    );
  }
}
