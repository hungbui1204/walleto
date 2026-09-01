import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends BasePageState<MainView, MainBloc> {
  @override
  void initState() {
    if (Platform.isAndroid) {
      // TODO: implement push noti for iOS

      /// Give message on which user taps and it opened the app from terminated state (app closed)
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          /// Waiting for app to initialize
          Future.delayed(
            DurationConstants.durationUntilAppInitialized,
            () => LocalNotificationService.handleNavigate(message: message),
          );
        }
      });

      /// Just in foreground (app must open)
      FirebaseMessaging.onMessage.listen((message) {
        // appBloc.add(const GetUnreadNotice());
        LocalNotificationService.notify(message);
      });

      /// This just work when app in background (app not open) and user taps on the notification
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        LocalNotificationService.handleNavigate(message: message);
      });
    }

    appBloc.add(const DataFetched(currenciesFetched: true, walletsFetched: true));

    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    final hideBottomNav = context.topRouteMatch.meta['hideBottomNav'] == true;

    return AutoTabsScaffold(
      routes: navigator.tabRoutes,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          hideBottomNav
              ? null
              : FloatingActionButton(
                shape: const CircleBorder(),
                elevation: Dimens.d4.responsive(),
                tooltip: S.current.addTransaction,
                onPressed: () async => await navigator.push(const AppRouteInfo.createTransaction()),
                backgroundColor: primaryColor,
                foregroundColor: onPrimaryColor,
                splashColor: primaryShadeColor,
                child: Assets.icons.plus.svg(
                  width: Dimens.d24.responsive(),
                  height: Dimens.d24.responsive(),
                  colorFilter: const ColorFilter.mode(onPrimaryColor, BlendMode.srcIn),
                ),
              ),
      bottomNavigationBuilder: (_, tabsRouter) {
        navigator.tabsRouter = tabsRouter;

        if (hideBottomNav) return const SizedBox.shrink();

        return CustomBottomNavigationBar(tabsRouter: tabsRouter);
      },
    );
  }
}
