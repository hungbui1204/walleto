import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@injectable
class AuthRouteGuard extends AutoRouteGuard {
  const AuthRouteGuard(this._isLoggedInUseCase);

  final IsLoggedInUseCase _isLoggedInUseCase;

  Future<bool> get _isLoggedIn async {
    final result = await runAsyncCatching(
      action: () async {
        final isLoggedInOutput = await _isLoggedInUseCase.execute(const IsLoggedInInput());
        

        return isLoggedInOutput.isLoggedIn;
      },
    );

    return switch (result) {
      Success(:final data) => data,
      Failure() => false,
    };
  }

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (await _isLoggedIn) {
      resolver.next();
    } else {
      if (router.hasEntries) router.popUntilRoot();
      router.replace(const LoginRoute());
      resolver.next(false);
    }
  }
}
