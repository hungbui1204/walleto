import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';
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

  const factory AppRouteInfo.categories() = Categories;

  const factory AppRouteInfo.createWallet({@Default(false) bool isFromSignUp}) = CreateWallet;

  const factory AppRouteInfo.wallets() = Wallets;

  const factory AppRouteInfo.transactionDetail({required Transaction transaction}) =
      TransactionDetail;
}
