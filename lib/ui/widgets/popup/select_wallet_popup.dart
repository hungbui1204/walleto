import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class SelectWalletPopup extends StatelessWidget {
  const SelectWalletPopup({super.key, required this.wallets, required this.onWalletSelected});

  final List<Wallet> wallets;
  final void Function(Wallet) onWalletSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxHeight: context.mediaQuery.size.height * 0.7),
          margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.d16.responsive(),
            vertical: Dimens.d20.responsive(),
          ),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.current.selectWallet, style: AppTextStyles.s20wNormalBlack()),
              SizedBox(height: Dimens.d20.responsive()),
              if (wallets.first.id == AppConstants.totalWalletId) _TotalWalletWidget(wallets.first),
              _TotalWalletWidget(wallets.first),
              SizedBox(height: Dimens.d20.responsive()),
              _WalletsWidget(wallets),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalWalletWidget extends StatelessWidget {
  const _TotalWalletWidget(this.totalWallet);

  final Wallet totalWallet;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _WalletsWidget extends StatelessWidget {
  const _WalletsWidget(this.wallets);

  final List<Wallet> wallets;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];

        if (wallet.id == AppConstants.totalWalletId) return const SizedBox.shrink();

        return Row(
          children: [
            CommonCircleNetworkImage(
              imageUrl: wallet.iconUrl,
              placeHolderType: ImagePlaceHolderType.wallet,
            ),
            SizedBox(width: Dimens.d8.responsive()),
            Text(wallet.name),
            const Spacer(),
            Text(wallet.amount.toStringWithFormat(NumberFormatConstants.amountFormat)),
          ],
        );
      },
      separatorBuilder: (context, index) => const CommonLine(),
    );
  }
}
