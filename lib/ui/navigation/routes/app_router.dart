import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

@LazySingleton()
@AutoRouterConfig(replaceInRouteName: 'View,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> routes = [
    CustomRoute(
      initial: true,
      page: MainRoute.page,
      transitionsBuilder: TransitionsBuilders.noTransition,
      guards: [AuthRouteGuard(getIt.get<IsLoggedInUseCase>())],
      children: [
        RedirectRoute(path: '', redirectTo: BottomTabHomeRouter.name),
        AutoRoute(
          path: 'home',
          page: BottomTabHomeRouter.page,
          children: [
            AutoRoute(initial: true, page: HomeRoute.page),
            AutoRoute(
              page: CreateTransactionRoute.page,
              path: 'create-transaction',
              meta: const {'hideBottomNav': true},
            ),
            AutoRoute(
              page: WalletsRoute.page,
              path: 'wallets',
              meta: const {'hideBottomNav': true},
            ),
          ],
        ),
        AutoRoute(
          path: 'transactions',
          page: BottomTabTransactionsRouter.page,
          children: [
            AutoRoute(initial: true, page: TransactionsRoute.page),
            AutoRoute(
              page: CreateTransactionRoute.page,
              path: 'create-transaction',
              meta: const {'hideBottomNav': true},
            ),
            AutoRoute(
              page: TransactionDetailRoute.page,
              path: 'transaction-detail',
              meta: const {'hideBottomNav': true},
            ),
            AutoRoute(
              page: EditTransactionRoute.page,
              path: 'edit-transaction',
              meta: const {'hideBottomNav': true},
            ),
          ],
        ),
        AutoRoute(
          path: 'budgets',
          page: BottomTabBudgetsRouter.page,
          children: [
            AutoRoute(initial: true, page: BudgetsRoute.page),
            AutoRoute(
              page: CreateTransactionRoute.page,
              path: 'create-transaction',
              meta: const {'hideBottomNav': true},
            ),
          ],
        ),
        AutoRoute(
          path: 'account',
          page: BottomTabAccountRouter.page,
          children: [
            AutoRoute(initial: true, page: AccountRoute.page),
            AutoRoute(
              page: CreateTransactionRoute.page,
              path: 'create-transaction',
              meta: const {'hideBottomNav': true},
            ),
            AutoRoute(
              page: CategoriesRoute.page,
              path: 'categories',
              meta: const {'hideBottomNav': true},
            ),
            AutoRoute(
              page: WalletsRoute.page,
              path: 'wallets',
              meta: const {'hideBottomNav': true},
            ),
            AutoRoute(
              page: CreateWalletRoute.page,
              path: 'create-wallet-from-account',
              meta: const {'hideBottomNav': true},
            ),
          ],
        ),
      ],
    ),
    AutoRoute(page: CreateWalletRoute.page, path: '/create-wallet'),
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/reset-password', page: ResetPasswordRoute.page),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}

@RoutePage(name: 'BottomTabHomeRouter')
class BottomTabHomeView extends AutoRouter {
  const BottomTabHomeView({super.key});
}

@RoutePage(name: 'BottomTabTransactionsRouter')
class BottomTabTransactionsView extends AutoRouter {
  const BottomTabTransactionsView({super.key});
}

@RoutePage(name: 'BottomTabBudgetsRouter')
class BottomTabBudgetsView extends AutoRouter {
  const BottomTabBudgetsView({super.key});
}

@RoutePage(name: 'BottomTabAccountRouter')
class BottomTabAccountView extends AutoRouter {
  const BottomTabAccountView({super.key});
}
