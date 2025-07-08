import 'package:freezed_annotation/freezed_annotation.dart';
part 'app_route_info.freezed.dart';

@freezed
sealed class AppRouteInfo with _$AppRouteInfo {
  const factory AppRouteInfo.login() = Login;

  const factory AppRouteInfo.main() = Main;

  const factory AppRouteInfo.home() = Home;

  const factory AppRouteInfo.transactions() = Transactions;

  const factory AppRouteInfo.budgets() = Budgets;

  const factory AppRouteInfo.account() = Account;

  const factory AppRouteInfo.createTransaction() = CreateTransaction;
}
