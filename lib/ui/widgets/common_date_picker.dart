import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

class CommonDatePicker extends StatelessWidget {
  const CommonDatePicker({
    super.key,
    this.initialDate,
    this.currentDate,
    required this.child,
  });

  final DateTime? initialDate;
  final DateTime? currentDate;
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
          headerBackgroundColor: primaryShadeColor,
          headerForegroundColor: blackColor,
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return onPrimaryColor;
            if (states.contains(WidgetState.disabled)) return darkGreyColor;
            return blackColor;
          }),
          dayShape: WidgetStateOutlinedBorder.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const LinearBorder(side: BorderSide(color: primaryColor));
            }

            return const LinearBorder(
              side: BorderSide(color: Colors.transparent),
            );
          }),
          elevation: 0,
          dayBackgroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primaryColor;
            return Colors.transparent;
          }),
          todayForegroundColor: const WidgetStatePropertyAll(primaryColor),
          todayBorder: const BorderSide(color: primaryColor),
        ),
      ),
      child: child,
    );
  }
}
