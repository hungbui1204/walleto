import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class WalletoApplication extends StatefulWidget {
  const WalletoApplication({
    super.key,
    required this.initialResource,
    required this.initialThemePreference,
  });

  final LoadInitialResourceOutput initialResource;
  final AppThemePreference initialThemePreference;

  @override
  State<WalletoApplication> createState() => _WalletoApplicationState();
}

class _WalletoApplicationState extends BasePageState<WalletoApplication, AppBloc> {
  final _appRouter = getIt.get<AppRouter>();

  @override
  void initState() {
    appBloc.add(AppThemePreferenceInitialized(widget.initialThemePreference));
    if (Platform.isAndroid) {
      // TODO: implement push noti for iOS
      FirebaseMessaging.instance.requestPermission();
    }

    appBloc.add(const DataFetched(currenciesFetched: true));
    super.initState();
  }

  @override
  bool get isAppWidget => true;

  @override
  Widget buildPage(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(DeviceConstants.designDeviceWidth, DeviceConstants.designDeviceHeight),
      builder: (context, _) {
        return BlocBuilder<AppBloc, AppState>(
          buildWhen: (previous, current) =>
              previous.themePreference != current.themePreference ||
              previous.isThemePreferenceInitialized != current.isThemePreferenceInitialized,
          builder: (context, state) {
            final selectedPreference = state.isThemePreferenceInitialized
                ? state.themePreference
                : widget.initialThemePreference;
            final isLight = selectedPreference == AppThemePreference.light;
            final lightTheme = AppThemes.lightTheme;
            final darkTheme = AppThemes.darkTheme;
            AppColorPalette.setLight(isLight);

            return MaterialApp.router(
              title: UiConstants.appTitle,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              supportedLocales: S.delegate.supportedLocales,
              locale: Locale(LanguageCode.defaultValue.localeCode),
              localeResolutionCallback: (locale, supportedLocales) {
                return supportedLocales.contains(locale)
                    ? locale
                    : const Locale(LocaleConstants.defaultLocale);
              },
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerDelegate: _appRouter.delegate(
                deepLinkBuilder: (deepLink) {
                  return DeepLink(_mapRouteToPageRouteInfo());
                },
                navigatorObservers: () => [AppNavigatorObserver()],
              ),
              routeInformationParser: _appRouter.defaultRouteParser(),
              builder: (context, child) {
                final data = context.mediaQuery;
                final overlayStyle = SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
                  systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
                  systemNavigationBarContrastEnforced: false,
                );

                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: overlayStyle,
                  child: MediaQuery(
                    data: data.copyWith(textScaler: context.textScalerOf),
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<PageRouteInfo> _mapRouteToPageRouteInfo() {
    return widget.initialResource.initialRoutes
        .map<PageRouteInfo>((e) {
          return switch (e) {
            InitialAppRoute.login => const LoginRoute(),
            InitialAppRoute.main => const MainRoute(),
            InitialAppRoute.createWallet => CreateWalletRoute(isFromSignUp: true),
          };
        })
        .toList(growable: false);
  }
}
