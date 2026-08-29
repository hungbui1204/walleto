import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

class CommonDateRangePicker extends StatelessWidget {
  const CommonDateRangePicker({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(
        colorScheme: context.theme.colorScheme.copyWith(
          primary: primaryColor,
          onPrimary: onPrimaryColor,
          surface: surfaceColor,
          onSurface: blackColor,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: surfaceColor,
          rangePickerElevation: 0,
          rangeSelectionBackgroundColor: primaryShade1Color,
          rangePickerHeaderBackgroundColor: primaryShadeColor,
          rangePickerHeaderHeadlineStyle: AppTextStyles.s20wBoldBlack(),
          rangePickerBackgroundColor: surfaceColor,
          dayBackgroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primaryColor;
            return Colors.transparent;
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return onPrimaryColor;
            return blackColor;
          }),
        ),
      ),
      child: child,
    );
  }
}
