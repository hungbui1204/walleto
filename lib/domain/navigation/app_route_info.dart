
import 'package:freezed_annotation/freezed_annotation.dart';
part 'app_route_info.freezed.dart';

@freezed
sealed class AppRouteInfo with _$AppRouteInfo {
  const factory AppRouteInfo.login() = Login;

  const factory AppRouteInfo.main() = Main;

}
