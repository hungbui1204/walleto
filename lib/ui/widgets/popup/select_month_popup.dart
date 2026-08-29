import 'package:flutter/material.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class SelectMonthPopup extends StatefulWidget {
  const SelectMonthPopup({
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
  State<SelectMonthPopup> createState() => _SelectMonthPopupState();
}

class _SelectMonthPopupState extends State<SelectMonthPopup> {
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

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
        side: const BorderSide(color: glassHairlineColor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d16.responsive(),
          vertical: Dimens.d16.responsive(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.current.selectMonthTitle,
              style: AppTextStyles.s20wBoldBlack(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left, color: darkGreyColor),
                  onPressed: () {
                    if (selectedYear > widget.firstYear) {
                      setState(() => selectedYear--);
                    }
                  },
                ),
                Text('$selectedYear', style: AppTextStyles.s18wNormalBlack()),
                IconButton(
                  icon: const Icon(Icons.arrow_right, color: darkGreyColor),
                  onPressed: () {
                    if (selectedYear < widget.lastYear) {
                      setState(() => selectedYear++);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: Dimens.d12.responsive()),
            GridView.count(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 2.4,
              mainAxisSpacing: Dimens.d8.responsive(),
              crossAxisSpacing: Dimens.d8.responsive(),
              children: List.generate(months.length, (index) {
                final month = index + 1;
                final isSelected = selectedMonth == month;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedMonth = month);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : fieldFillColor,
                      borderRadius: BorderRadius.circular(
                        Dimens.d12.responsive(),
                      ),
                      border: Border.all(
                        color: isSelected ? primaryColor : glassHairlineColor,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${months[month]}',
                      style:
                          isSelected
                              ? AppTextStyles.s14wBoldBlack().copyWith(
                                color: onPrimaryColor,
                              )
                              : AppTextStyles.s14wNormalBlack(),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: Dimens.d30.responsive()),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonButton(
                  compact: true,
                  text: S.current.save,
                  onTap: () {
                    final pickedDate = DateTime(selectedYear, selectedMonth);
                    widget.onMonthSelected.call(pickedDate);

                    getIt.get<AppNavigator>().pop();
                  },
                ),
                SizedBox(width: Dimens.d8.responsive()),
                CommonButton(
                  compact: true,
                  text: S.current.cancel,
                  backgroundColor: surfaceColor,
                  textColor: blackColor,
                  onTap: () => getIt.get<AppNavigator>().pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
