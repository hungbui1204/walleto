import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class ChooseWalletBottomSheet extends StatefulWidget {
  const ChooseWalletBottomSheet({
    super.key,
    required this.onWalletSelected,
    required this.currentWallet,
  });

  final void Function(Wallet) onWalletSelected;
  final Wallet? currentWallet;

  @override
  State<ChooseWalletBottomSheet> createState() => _ChooseWalletBottomSheetState();
}

class _ChooseWalletBottomSheetState extends State<ChooseWalletBottomSheet> {
  late Wallet? selectedWallet;

  @override
  void initState() {
    selectedWallet = widget.currentWallet;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimens.d16.responsive()),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.current.chooseWallet, style: AppTextStyles.s18wBoldBlack()),
            SizedBox(height: Dimens.d20.responsive()),
            BlocBuilder<AppBloc, AppState>(
              buildWhen: (previous, current) => previous.wallets != current.wallets,
              builder: (context, state) {
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.wallets.length,
                  itemBuilder: (context, index) {
                    return _WalletWidget(
                      wallet: state.wallets[index],
                      isSelected: selectedWallet?.id == state.wallets[index].id,
                      onTap: () {
                        setState(() {
                          selectedWallet = state.wallets[index];
                        });
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const CommonLine(margin: EdgeInsets.zero);
                  },
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonButton(
                  text: S.current.save,
                  borderRadius: BorderRadius.circular(Dimens.d8.responsive()),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.d24.responsive(),
                    vertical: Dimens.d6.responsive(),
                  ),
                  onTap: () {
                    if (selectedWallet != null) {
                      widget.onWalletSelected.call(selectedWallet!);
                    }

                    getIt.get<AppNavigator>().pop();
                  },
                ),
                SizedBox(width: Dimens.d8.responsive()),
                CommonButton(
                  text: S.current.cancel,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.d24.responsive(),
                    vertical: Dimens.d6.responsive(),
                  ),
                  borderRadius: BorderRadius.circular(Dimens.d8.responsive()),
                  backgroundColor: whiteColor,
                  onTap: () => getIt.get<AppNavigator>().pop(),
                ),
              ],
            ),
            SizedBox(height: Dimens.d32.responsive()),
          ],
        ),
      ),
    );
  }
}

class _WalletWidget extends StatelessWidget {
  const _WalletWidget({required this.isSelected, required this.wallet, required this.onTap});

  final bool isSelected;
  final Wallet wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: isSelected ? primaryShade1Color : whiteColor,
        child: Padding(
          padding: EdgeInsets.all(Dimens.d12.responsive()),
          child: Row(
            children: [
              CommonCircleNetworkImage(
                imageUrl: wallet.iconUrl,
                placeHolderType: ImagePlaceHolderType.wallet,
              ),
              SizedBox(width: Dimens.d8.responsive()),
              Text(wallet.name, style: AppTextStyles.s14wNormalBlack()),
            ],
          ),
        ),
      ),
    );
  }
}
