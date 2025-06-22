import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends BasePageState<MainView, MainBloc> {
  final _bottomBarKey = GlobalKey();

  @override
  Widget buildPage(BuildContext context) {
    return AutoTabsScaffold(
      routes: (navigator as AppNavigatorImpl).tabRoutes,
      bottomNavigationBuilder: (_, tabsRouter) {
        (navigator as AppNavigatorImpl).tabsRouter = tabsRouter;

        final hideBottomNav = context.topRouteMatch.meta['hideBottomNav'] == true;

        if (hideBottomNav) return const SizedBox.shrink();

        return SafeArea(
          child: BottomNavigationBar(
            key: _bottomBarKey,
            elevation: 0,
            currentIndex: tabsRouter.activeIndex,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            backgroundColor: whiteColor,
            onTap: (index) {
              tabsRouter.setActiveIndex(index);
            },
            items:
                BottomTab.values.map((tab) {
                  return BottomNavigationBarItem(
                    label: tab.title,
                    icon: tab.icon(),
                    activeIcon: tab.icon(selected: !tabsRouter.canPop(ignoreChildRoutes: true)),
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}
