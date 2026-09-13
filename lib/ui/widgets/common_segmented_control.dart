import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

import 'pressable.dart';

class CommonSegmentedControl<T> extends StatelessWidget {
  const CommonSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
  });

  final List<({T value, String label})> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          if (i > 0) SizedBox(width: Dimens.d8.responsive()),
          Expanded(
            child: _Segment(
              label: segments[i].label,
              selected: segments[i].value == selected,
              onTap: segments[i].value == selected ? null : () => onSelected(segments[i].value),
            ),
          ),
        ],
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = AppDecorations.chipRadius();
    final duration =
        MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : DurationConstants.microInteraction;

    return Pressable(
      onTap: onTap,
      borderRadius: radius,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: Dimens.d10.responsive()),
        decoration: BoxDecoration(
          color: selected ? primaryShadeColor : fieldFillColor,
          borderRadius: radius,
          border: Border.all(color: selected ? primaryColor : glassHairlineColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.s14wBoldBlack().copyWith(
            color: selected ? primaryColor : darkGreyColor,
          ),
        ),
      ),
    );
  }
}
