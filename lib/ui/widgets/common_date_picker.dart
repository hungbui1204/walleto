import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

class CommonDatePicker extends StatelessWidget {
  const CommonDatePicker({super.key, this.initialDate, this.currentDate, required this.child});

  final DateTime? initialDate;
  final DateTime? currentDate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(
        colorScheme: context.theme.colorScheme.copyWith(primary: primaryColor),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: whiteColor,
          dayShape: WidgetStateOutlinedBorder.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const LinearBorder(side: BorderSide(color: primaryShadeColor));
            }

            return const LinearBorder(side: BorderSide(color: Colors.transparent));
          }),
          elevation: 0,
          dayBackgroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primaryShadeColor;
            return Colors.transparent;
          }),
        ),
      ),
      child: child,
    );
  }
}
