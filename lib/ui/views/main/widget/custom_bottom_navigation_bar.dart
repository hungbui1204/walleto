import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key, required this.tabsRouter});

  final TabsRouter tabsRouter;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BottomAppBar(
        padding: EdgeInsets.zero,
        height: Dimens.d60.responsive(),
        color: primaryShadeColor,
        key: key,
        shape: const CircularNotchedRectangle(),
        notchMargin: Dimens.d10.responsive(),
        child: Row(
          children: List.generate(BottomTab.values.length, (index) {
            // Create [indexWithout3rdIcon] that not include the createTrans tab
            final indexWithout3rdIcon = index < BottomTab.createTrans.index ? index : index - 1;

            // Skip the createTrans tab for the bottom navigation bar
            // Replace it with a SizedBox to maintain the FAB
            if (index == BottomTab.createTrans.index) {
              return SizedBox(width: Dimens.d50.responsive());
            }

            final tab = BottomTab.values[index];
            return Expanded(
              child: BottomBarIconButton(
                onTap: () {
                  tabsRouter.setActiveIndex(indexWithout3rdIcon);
                },
                icon: tab.icon(selected: tabsRouter.activeIndex == indexWithout3rdIcon),
              ),
            );
          }),
        ),
      ),
    );
  }
}
