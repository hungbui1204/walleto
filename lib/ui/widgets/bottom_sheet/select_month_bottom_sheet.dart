import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class SelectMonthBottomSheet extends StatefulWidget {
  const SelectMonthBottomSheet({
    super.key,
    required this.firstYear,
    required this.lastYear,
    required this.onMonthSelected,
    this.initialDate,
  });

  final int firstYear;
  final int lastYear;
  final void Function(DateTime) onMonthSelected;
  final DateTime? initialDate;

  @override
  State<SelectMonthBottomSheet> createState() => _SelectMonthBottomSheetState();
}

class _SelectMonthBottomSheetState extends State<SelectMonthBottomSheet> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = widget.initialDate?.year ?? now.year;
    selectedMonth = widget.initialDate?.month ?? now.month;
  }

  @override
  Widget build(BuildContext context) {
    final months = {
      1: S.current.january,
      2: S.current.february,
      3: S.current.march,
      4: S.current.april,
      5: S.current.may,
      6: S.current.june,
      7: S.current.july,
      8: S.current.august,
      9: S.current.september,
      10: S.current.october,
      11: S.current.november,
      12: S.current.december,
    };

    return CommonPickerSheet(
      title: S.current.selectMonthTitle,
      expandChild: true,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pressable(
                onTap:
                    selectedYear > widget.firstYear ? () => setState(() => selectedYear--) : null,
                semanticLabel: S.current.previousYear,
                child: Padding(
                  padding: EdgeInsets.all(Dimens.d8.responsive()),
                  child: Icon(
                    Icons.arrow_left,
                    color: darkGreyColor,
                    size: Dimens.d24.responsive(),
                  ),
                ),
              ),
              Text('$selectedYear', style: AppTextStyles.s18wNormalBlack()),
              Pressable(
                onTap: selectedYear < widget.lastYear ? () => setState(() => selectedYear++) : null,
                semanticLabel: S.current.nextYear,
                child: Padding(
                  padding: EdgeInsets.all(Dimens.d8.responsive()),
                  child: Icon(
                    Icons.arrow_right,
                    color: darkGreyColor,
                    size: Dimens.d24.responsive(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimens.d12.responsive()),
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 3,
              childAspectRatio: 2.4,
              mainAxisSpacing: Dimens.d8.responsive(),
              crossAxisSpacing: Dimens.d8.responsive(),
              children: List.generate(months.length, (index) {
                final month = index + 1;
                final isSelected = selectedMonth == month;

                return Pressable(
                  onTap: () {
                    widget.onMonthSelected(DateTime(selectedYear, month));
                    context.read<AppNavigator>().pop();
                  },
                  borderRadius: AppDecorations.chipRadius(),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : fieldFillColor,
                      borderRadius: AppDecorations.chipRadius(),
                      border: Border.all(color: isSelected ? primaryColor : glassHairlineColor),
                    ),
                    child: SizedBox.expand(
                      child: Center(
                        child: Text(
                          '${months[month]}',
                          style:
                              isSelected
                                  ? AppTextStyles.s14wBoldBlack().copyWith(color: onPrimaryColor)
                                  : AppTextStyles.s14wNormalBlack(),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
