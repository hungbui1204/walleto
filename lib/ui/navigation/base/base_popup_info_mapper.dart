import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';

abstract class BasePopupInfoMapper {
  Widget map(AppPopupInfo appRouteInfo, AppNavigator navigator);
}
