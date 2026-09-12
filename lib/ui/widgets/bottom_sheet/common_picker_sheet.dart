import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonPickerSheet extends StatelessWidget {
  const CommonPickerSheet({super.key, required this.title, required this.child, this.actions});

  static const double _maxHeightFactor = 0.7;

  final String title;
  final Widget child;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: Dimens.d16.responsive(),
          right: Dimens.d16.responsive(),
          top: Dimens.d12.responsive(),
          bottom: Dimens.d16.responsive() + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PickerSheetHandle(),
            SizedBox(height: Dimens.d12.responsive()),
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.s18wBoldBlack()),
            SizedBox(height: Dimens.d20.responsive()),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
              ),
              child: ListView(shrinkWrap: true, padding: EdgeInsets.zero, children: [child]),
            ),
            if (actions != null) ...[SizedBox(height: Dimens.d16.responsive()), actions!],
          ],
        ),
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
