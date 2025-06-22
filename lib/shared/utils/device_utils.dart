import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:walleto/shared/shared.dart';

class DeviceUtils {
  const DeviceUtils._();

  static DeviceType deviceType = _getDeviceType();

  /// English:
  /// Get the device model name.
  ///
  /// Japanese:
  /// デバイスのモデル名を取得します。
  static Future<String> getDeviceModelName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      return iosInfo.name;
    } else {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      return '${androidInfo.brand} ${androidInfo.device}';
    }
  }

  static Future<int> get androidVersion async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    return androidInfo.version.sdkInt;
  }

  /// English:
  /// Returns the type of the device based on the screen size.
  ///
  /// The device type is determined by comparing the shortest side of the screen
  /// with the maximum width defined for a mobile device in [DeviceConstants].
  /// If the shortest side is less than the maximum width, the device is considered
  /// a mobile device. Otherwise, it is considered a tablet device.
  ///
  /// Japanese:
  /// 画面サイズに基づいてデバイスのタイプを返します。
  ///
  /// デバイスのタイプは、画面の最短辺を[DeviceConstants]のモバイルデバイスの最大幅と比較することによって決定されます。
  /// 最短辺が最大幅よりも小さい場合、デバイスはモバイルデバイスと見なされます。
  /// それ以外の場合は、タブレットデバイスと見なされます。
  static DeviceType _getDeviceType() {
    return MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first,
            ).size.shortestSide <
            DeviceConstants.maxMobileWidthForDeviceType
        ? DeviceType.mobile
        : DeviceType.tablet;
  }
}
