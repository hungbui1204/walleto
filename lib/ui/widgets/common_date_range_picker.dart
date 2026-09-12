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
        datePickerTheme: AppThemes.datePicker,
      ),
      child: child,
    );
  }
}
