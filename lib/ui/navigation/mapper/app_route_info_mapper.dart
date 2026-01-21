import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

@LazySingleton(as: BaseRouteInfoMapper)
class AppRouteInfoMapper extends BaseRouteInfoMapper {
  @override
  PageRouteInfo map(AppRouteInfo appRouteInfo) {
    return switch (appRouteInfo) {
      Login() => const LoginRoute(),
      Main() => const MainRoute(),
      Home() => const HomeRoute(),
      Transactions() => const TransactionsRoute(),
      Budgets() => const BudgetsRoute(),
      Account() => const AccountRoute(),
      CreateTransaction() => const CreateTransactionRoute(),
      Categories() => const CategoriesRoute(),
      CreateWallet(:final isFromSignUp) => CreateWalletRoute(isFromSignUp: isFromSignUp),
      Wallets() => const WalletsRoute(),
      TransactionDetail(:final transaction) => TransactionDetailRoute(transaction: transaction),
      ResetPassword() => const ResetPasswordRoute(),
      EditTransaction(:final transaction) => EditTransactionRoute(transaction: transaction),
    };
  }
}
