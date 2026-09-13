import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends BasePageState<MainView, MainBloc> {
  @override
  void initState() {
    bloc.add(const MainViewInitiated());
    appBloc.add(const DataFetched(currenciesFetched: true, walletsFetched: true));

    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    final hideBottomNav = context.topRouteMatch.meta['hideBottomNav'] == true;

    return AutoTabsScaffold(
      routes: navigator.tabRoutes,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          hideBottomNav
              ? null
              : BlocBuilder<AppBloc, AppState>(
                buildWhen: (previous, current) => previous.wallets != current.wallets,
                builder: (context, state) {
                  if (state.wallets.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final fabSize = Dimens.d56.responsive();
                  final fabRadius = BorderRadius.circular(fabSize / 2);

                  return Pressable(
                    onTap: () async {
                      await navigator.push(const AppRouteInfo.createTransaction());
                    },
                    clip: false,
                    borderRadius: fabRadius,
                    semanticLabel: S.current.addTransaction,
                    child: Pressable.clippedFill(
                      decoration: AppDecorations.primaryCta(radius: fabRadius),
                      child: SizedBox(
                        width: fabSize,
                        height: fabSize,
                        child: Center(
                          child: Assets.icons.plus.svg(
                            width: Dimens.d24.responsive(),
                            height: Dimens.d24.responsive(),
                            colorFilter: const ColorFilter.mode(onPrimaryColor, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBuilder: (_, tabsRouter) {
        navigator.tabsRouter = tabsRouter;

        if (hideBottomNav) return const SizedBox.shrink();

        return CustomBottomNavigationBar(tabsRouter: tabsRouter);
      },
    );
  }
}
