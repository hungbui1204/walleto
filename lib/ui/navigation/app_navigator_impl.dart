import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@LazySingleton(as: AppNavigator)
class AppNavigatorImpl extends AppNavigator with LogMixin {
  AppNavigatorImpl(this._appRouter, this._appPopupInfoMapper, this._appRouteInfoMapper);

  final AppRouter _appRouter;
  final BasePopupInfoMapper _appPopupInfoMapper;
  final BaseRouteInfoMapper _appRouteInfoMapper;
  final _shownPopups = <AppPopupInfo, Completer<dynamic>>{};

  final List<PageRouteInfo> tabRoutes = const [
    BottomTabHomeRouter(),
    BottomTabTransactionsRouter(),
    BottomTabBudgetsRouter(),
    BottomTabAccountRouter(),
  ];

  TabsRouter? tabsRouter;

  StackRouter? get _currentTabRouter => tabsRouter?.stackRouterOfIndex(currentBottomTab);

  StackRouter get _currentTabRouterOrRootRouter => _currentTabRouter ?? _appRouter;

  m.BuildContext get _rootRouterContext => _appRouter.navigatorKey.currentContext!;

  m.BuildContext? get _currentTabRouterContext => _currentTabRouter?.navigatorKey.currentContext;

  m.BuildContext get _currentTabContextOrRootContext {
    return _currentTabRouterContext ?? _rootRouterContext;
  }

  @override
  int get currentBottomTab {
    if (tabsRouter == null) throw 'Not found any TabRouter';

    return tabsRouter?.activeIndex ?? 0;
  }

  @override
  bool get canPopSelfOrChildren => _appRouter.canPop();

  @override
  List<String?> getCurrentRouteNames({bool useRootNavigator = false}) {
    return AutoRouter.of(
      useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
    ).stack.map((route) => route.name).toList();
  }

  @override
  String getCurrentRouteName({bool useRootNavigator = false}) {
    return AutoRouter.of(
      useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
    ).current.name;
  }

  @override
  void popUntilRootOfCurrentBottomTab() {
    if (tabsRouter == null) throw 'Not found any TabRouter';

    if (_currentTabRouter?.canPop() ?? false) {
      if (LogConfig.enableNavigatorObserverLog) {
        logD('popUntilRootOfCurrentBottomTab');
      }
      _currentTabRouter?.popUntilRoot();
    }
  }

  @override
  void navigateToBottomTab(int index, {bool notify = true}) {
    if (tabsRouter == null) throw 'Not found any TabRouter';

    if (LogConfig.enableNavigatorObserverLog) {
      logD('navigateToBottomTab with index = $index, notify = $notify');
    }
    tabsRouter?.setActiveIndex(index, notify: notify);
  }

  @override
  Future<T?> push<T extends Object?>(AppRouteInfo appRouteInfo) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('push $appRouteInfo');
    }

    return _appRouter.push<T>(_appRouteInfoMapper.map(appRouteInfo));
  }

  @override
  Future<void> pushAll(List<AppRouteInfo> listAppRouteInfo) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('pushAll $listAppRouteInfo');
    }

    return _appRouter.pushAll(_appRouteInfoMapper.mapList(listAppRouteInfo));
  }

  @override
  Future<T?> pushAndPopUntilRoot<T extends Object?>(AppRouteInfo appRouteInfo) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('pushAndPopUntil $appRouteInfo');
    }

    return _appRouter.pushAndPopUntil<T>(
      _appRouteInfoMapper.map(appRouteInfo),
      predicate: (route) => route.isFirst,
    );
  }

  @override
  Future<T?> pushAndPopUntilRouteName<T extends Object?>(
    AppRouteInfo appRouteInfo,
    String routeName,
  ) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('pushAndPopUntilRouteName $appRouteInfo, routeName = $routeName');
    }

    return _appRouter.pushAndPopUntil<T>(
      _appRouteInfoMapper.map(appRouteInfo),
      predicate: (route) => route.settings.name == routeName,
    );
  }

  @override
  Future<T?> replace<T extends Object?>(AppRouteInfo appRouteInfo) {
    _shownPopups.clear();
    if (LogConfig.enableNavigatorObserverLog) {
      logD('replace by $appRouteInfo');
    }

    return _appRouter.replace<T>(_appRouteInfoMapper.map(appRouteInfo));
  }

  @override
  Future<void> replaceAll(List<AppRouteInfo> listAppRouteInfo) {
    _shownPopups.clear();
    if (LogConfig.enableNavigatorObserverLog) {
      logD('replaceAll by $listAppRouteInfo');
    }

    return _appRouter.replaceAll(_appRouteInfoMapper.mapList(listAppRouteInfo));
  }

  @override
  Future<bool> pop<T extends Object?>({T? result, bool useRootNavigator = false}) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('pop with result = $result, useRootNav = $useRootNavigator');
    }

    return useRootNavigator
        ? _appRouter.maybePop<T>(result)
        : _currentTabRouterOrRootRouter.maybePop<T>(result);
  }

  @override
  Future<T?> popAndPush<T extends Object?, R extends Object?>(
    AppRouteInfo appRouteInfo, {
    R? result,
    bool useRootNavigator = false,
  }) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('popAndPush $appRouteInfo with result = $result, useRootNav = $useRootNavigator');
    }

    return useRootNavigator
        ? _appRouter.popAndPush<T, R>(_appRouteInfoMapper.map(appRouteInfo), result: result)
        : _currentTabRouterOrRootRouter.popAndPush<T, R>(
          _appRouteInfoMapper.map(appRouteInfo),
          result: result,
        );
  }

  @override
  void popUntilRoot({bool useRootNavigator = false}) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('popUntilRoot, useRootNav = $useRootNavigator');
    }

    useRootNavigator ? _appRouter.popUntilRoot() : _currentTabRouterOrRootRouter.popUntilRoot();
  }

  @override
  void popUntilRouteName(String routeName, {bool useRootNavigator = false}) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('popUntilRouteName $routeName, useRootNav = $useRootNavigator');
    }

    _appRouter.popUntilRouteWithName(routeName, scoped: useRootNavigator ? false : true);
  }

  @override
  bool removeUntilRouteName(String routeName) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('removeUntilRouteName $routeName');
    }

    return _appRouter.removeUntil((route) => route.name == routeName);
  }

  @override
  bool removeAllRoutesWithName(String routeName) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('removeAllRoutesWithName $routeName');
    }

    return _appRouter.removeWhere((route) => route.name == routeName);
  }

  @override
  Future<void> popAndPushAll(List<AppRouteInfo> listAppRouteInfo, {bool useRootNavigator = false}) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('popAndPushAll $listAppRouteInfo, useRootNav = $useRootNavigator');
    }

    return useRootNavigator
        ? _appRouter.popAndPushAll(_appRouteInfoMapper.mapList(listAppRouteInfo))
        : _currentTabRouterOrRootRouter.popAndPushAll(
          _appRouteInfoMapper.mapList(listAppRouteInfo),
        );
  }

  @override
  bool removeLast() {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('removeLast');
    }

    return _appRouter.removeLast();
  }

  @override
  Future<T?> showDialog<T extends Object?>(
    AppPopupInfo appPopupInfo, {
    bool barrierDismissible = true,
    bool useSafeArea = false,
    bool useRootNavigator = true,
    m.Color barrierColor = const m.Color(0xB3000000),
  }) {
    if (_shownPopups.containsKey(appPopupInfo)) {
      logD('Dialog $appPopupInfo already shown');

      return _shownPopups[appPopupInfo]!.future.safeCast();
    }
    _shownPopups[appPopupInfo] = Completer<T?>();

    return m.showDialog<T>(
      context: useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      barrierDismissible: barrierDismissible,
      useSafeArea: useSafeArea,
      builder: (_) {
        return m.PopScope(
          onPopInvokedWithResult: (_, __) async {
            logD('Dialog $appPopupInfo dismissed');
            _shownPopups.remove(appPopupInfo);
          },
          child: _appPopupInfoMapper.map(appPopupInfo, this),
        );
      },
    );
  }

  @override
  Future<T?> showGeneralDialog<T extends Object?>(
    AppPopupInfo appPopupInfo, {
    Duration transitionDuration = DurationConstants.defaultGeneralDialogTransitionDuration,
    m.Widget Function(m.BuildContext, m.Animation<double>, m.Animation<double>, m.Widget)?
    transitionBuilder,
    m.Color barrierColor = const m.Color(0xB3000000),
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) {
    if (_shownPopups.containsKey(appPopupInfo)) {
      logD('Dialog $appPopupInfo already shown');

      return _shownPopups[appPopupInfo]!.future.safeCast();
    }
    _shownPopups[appPopupInfo] = Completer<T?>();

    return m.showGeneralDialog<T>(
      context: useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      barrierDismissible: barrierDismissible,
      pageBuilder: (context, animation1, animation2) {
        return m.PopScope(
          onPopInvokedWithResult: (_, __) async {
            logD('Dialog $appPopupInfo dismissed');
            _shownPopups.remove(appPopupInfo);
          },
          child: _appPopupInfoMapper.map(appPopupInfo, this),
        );
      },
      transitionBuilder: transitionBuilder,
      transitionDuration: transitionDuration,
    );
  }

  @override
  Future<T?> showModalBottomSheet<T extends Object?>(
    AppPopupInfo appPopupInfo, {
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    m.Color barrierColor = const m.Color(0xB3000000),
    m.Color? backgroundColor,
  }) {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('showModalBottomSheet $appPopupInfo, useRootNav = $useRootNavigator');
    }

    return m.showModalBottomSheet<T>(
      context: useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
      builder: (_) => _appPopupInfoMapper.map(appPopupInfo, this),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
    );
  }

  @override
  void showErrorSnackBar(String message, {Duration? duration}) {
    ViewUtils.showAppSnackBar(_rootRouterContext, message, duration: duration);
  }

  @override
  void showSuccessSnackBar(String message, {Duration? duration}) {
    ViewUtils.showAppSnackBar(_rootRouterContext, message, duration: duration);
  }

  @override
  Future<DateTime?> showDatePicker({
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    bool useRootNavigator = false,
    m.Color barrierColor = Colors.black54,
    m.Color? backgroundColor,
  }) async {
    if (LogConfig.enableNavigatorObserverLog) {
      logD('showDatePicker, useRootNav = $useRootNavigator');
    }

    return await m.showDatePicker(
      context: useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialDate: initialDate,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      initialEntryMode: m.DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return CommonDatePicker(initialDate: initialDate, currentDate: currentDate, child: child!);
      },
    );
  }

  @override
  Future<m.DateTimeRange?> showDateRangePicker({
    required DateTime firstDate,
    required DateTime lastDate,
    DateTimeRange? initialDateRange,
    bool useRootNavigator = false,
  }) async {
    return await m.showDateRangePicker(
      context: useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
      initialEntryMode: m.DatePickerEntryMode.calendarOnly,
      useRootNavigator: useRootNavigator,
      builder: (context, child) {
        return CommonDateRangePicker(child: child!);
      },
    );
  }
}
