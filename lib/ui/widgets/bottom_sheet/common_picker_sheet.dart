import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

class CommonPickerSheet extends StatelessWidget {
  const CommonPickerSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.expandChild = false,
  });

  final String title;
  final Widget child;
  final Widget? actions;

  /// When true, [child] gets a bounded height (for `Expanded` / inner list).
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * AppConstants.pickerSheetMaxHeightFactor;
    final body =
        expandChild
            ? Expanded(child: child)
            : ConstrainedBox(constraints: BoxConstraints(maxHeight: maxHeight), child: child);

    final content = Column(
      mainAxisSize: expandChild ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PickerSheetHandle(),
        SizedBox(height: Dimens.d12.responsive()),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.s18wBoldBlack()),
        SizedBox(height: Dimens.d20.responsive()),
        body,
        if (actions != null) ...[SizedBox(height: Dimens.d16.responsive()), actions!],
      ],
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: Dimens.d16.responsive(),
          right: Dimens.d16.responsive(),
          top: Dimens.d12.responsive(),
          bottom: Dimens.d16.responsive() + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: expandChild ? SizedBox(height: maxHeight, child: content) : content,
      ),
    );
  }
}

class _PickerSheetHandle extends StatelessWidget {
  const _PickerSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: glassHairlineColor,
          borderRadius: BorderRadius.circular(Dimens.d2.responsive()),
        ),
        child: SizedBox(width: Dimens.d36.responsive(), height: Dimens.d4.responsive()),
      ),
    );
  }
}
