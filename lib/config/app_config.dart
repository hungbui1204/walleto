import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/di/di.dart' as di;
import 'package:walleto/initializer/application_initializer.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class AppConfig extends ApplicationConfig {
  AppConfig._();

  factory AppConfig.getInstance() => _instance;

  static final AppConfig _instance = AppConfig._();

  @override
  Future<void> config() async {
    di.configureDependencies();
    await di.getIt.get<CookieHelper>().init();
    await di.getIt.get<AppInfo>().init();
    Bloc.observer = AppBlocObserver();
    // await LocalNotificationService.init();
    await ViewUtils.setPreferredOrientations(
      DeviceUtils.deviceType == DeviceType.mobile
          ? UiConstants.mobileOrientation
          : UiConstants.tabletOrientation,
    );
    ViewUtils.setSystemUIOverlayStyle(UiConstants.systemUiOverlay);
    ViewUtils.setSystemUIOverlay();
  }
}
