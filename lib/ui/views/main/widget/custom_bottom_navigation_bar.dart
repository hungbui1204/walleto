import 'dart:ui';

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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: 0.82),
            border: const Border(top: BorderSide(color: glassHairlineColor)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: Dimens.d64.responsive(),
              child: Row(
                children: List.generate(BottomTab.values.length, (index) {
                  final indexWithout3rdIcon =
                      index < BottomTab.createTrans.index ? index : index - 1;

                  if (index == BottomTab.createTrans.index) {
                    return SizedBox(width: Dimens.d56.responsive());
                  }

                  final tab = BottomTab.values[index];
                  final selected =
                      tabsRouter.activeIndex == indexWithout3rdIcon;

                  return Expanded(
                    child: BottomBarIconButton(
                      label: tab.title,
                      selected: selected,
                      onTap: () {
                        tabsRouter.setActiveIndex(indexWithout3rdIcon);
                      },
                      icon: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          selected ? primaryColor : darkGreyColor,
                          BlendMode.srcIn,
                        ),
                        child: SizedBox(
                          width: Dimens.d24.responsive(),
                          height: Dimens.d24.responsive(),
                          child: FittedBox(child: tab.icon(selected: selected)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
