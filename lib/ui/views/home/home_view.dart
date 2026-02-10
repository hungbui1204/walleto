import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BasePageState<HomeView, HomeBloc> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    bloc.add(const HomeViewInitialized());
    super.initState();
  }

  @override
  Widget buildPageListeners({required Widget child}) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) {
        return previous.needReloadStatisticalCharts != current.needReloadStatisticalCharts &&
            current.needReloadStatisticalCharts;
      },
      listener: (context, state) {
        // Reload statistical chart when the app state indicates a need to reload
        bloc.add(const HomeViewInitialized());
        // Reset the needReloadStatisticalCharts flag
        appBloc.add(const StatisticalChartsReloaded(needReloadStatisticalCharts: false));
      },
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.home),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Dimens.d16.responsive()),
              const _AllWalletsWidget(),
              SizedBox(height: Dimens.d20.responsive()),
              StatisticWidget(tabController: _tabController),
              SizedBox(height: Dimens.d20.responsive()),
              const _RecentTransactionsWidget(),
              SizedBox(height: Dimens.d20.responsive()),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllWalletsWidget extends StatelessWidget {
  const _AllWalletsWidget();

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      titleWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(S.current.allWallets, style: AppTextStyles.s16wBoldBlack()),
          GestureDetector(
            onTap: () {
              getIt.get<AppNavigator>().push(const AppRouteInfo.wallets());
            },
            child: Text(S.current.seeAll, style: AppTextStyles.s13wUnderlineItalicBlack()),
          ),
        ],
      ),
      contentWidget: BlocBuilder<AppBloc, AppState>(
        buildWhen: (previous, current) => previous.wallets != current.wallets,
        builder: (context, state) {
          if (state.wallets.isEmpty) return const SizedBox.shrink();

          return ListView.separated(
            itemCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _WalletInfoWidget(state.wallets[index]);
            },
            separatorBuilder: (context, index) {
              return const CommonLine(color: greyColor);
            },
          );
        },
      ),
    );
  }
}

class _WalletInfoWidget extends StatelessWidget {
  const _WalletInfoWidget(this.wallet);

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CommonCircleNetworkImage(
          imageUrl: wallet.iconUrl,
          placeHolderType: ImagePlaceHolderType.wallet,
        ),
        SizedBox(width: Dimens.d10.responsive()),
        Text(wallet.name, style: AppTextStyles.s16wNormalBlack()),
        const Spacer(),
        CommonAmountWithSymbol(amount: wallet.amount, currencyCode: wallet.currencyCode),
      ],
    );
  }
}

class _RecentTransactionsWidget extends StatelessWidget {
  const _RecentTransactionsWidget();

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      titleWidget: Align(
        alignment: Alignment.centerLeft,
        child: Text(S.current.recentTransactions, style: AppTextStyles.s16wBoldBlack()),
      ),
      contentWidget: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) {
          return previous.recentTransactions != current.recentTransactions;
        },
        builder: (context, state) {
          if (state.recentTransactions.isEmpty) return const SizedBox.shrink();

          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: state.recentTransactions.length,
            itemBuilder: (context, index) {
              return _RecentTransactionWidget(state.recentTransactions[index]);
            },
            separatorBuilder: (context, index) {
              return const CommonLine(color: greyColor);
            },
          );
        },
      ),
    );
  }
}

class _RecentTransactionWidget extends StatelessWidget {
  const _RecentTransactionWidget(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        getIt.get<AppNavigator>().push(AppRouteInfo.transactionDetail(transaction: transaction));
      },
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CommonCircleNetworkImage(imageUrl: transaction.category.iconUrl),
              Positioned(
                bottom: 0,
                right: -6,
                child: CommonCircleNetworkImage(
                  imageUrl: transaction.wallet.iconUrl,
                  placeHolderType: ImagePlaceHolderType.wallet,
                  backgroundColor: secondaryColor,
                  size: Dimens.d16.responsive(),
                ),
              ),
            ],
          ),
          SizedBox(width: Dimens.d16.responsive()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.category.name),
              Text(
                transaction.transactionDate!.toStringWithFormat(
                  DateTimeFormatConstants.dayMonthYearFormat,
                ),
              ),
            ],
          ),
          const Spacer(),
          CommonAmountWithSymbol(
            amount: transaction.amount,
            currencyCode: transaction.currencyCode,
            textStyle:
                transaction.type == CategoryType.expense
                    ? AppTextStyles.s14wNormalRed()
                    : AppTextStyles.s14wNormalGreen(),
          ),
        ],
      ),
    );
  }
}
