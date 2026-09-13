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
        colorScheme: context.theme.colorScheme.copyWith(
          primary: primaryColor,
          onPrimary: onPrimaryColor,
          surface: surfaceColor,
          onSurface: blackColor,
        ),
        datePickerTheme: AppThemes.datePicker,
      ),
      child: child,
    );
  }
}
