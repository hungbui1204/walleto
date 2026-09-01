import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class CreateWalletView extends StatefulWidget {
  const CreateWalletView({super.key, this.isFromSignUp = false});

  final bool isFromSignUp;

  @override
  State<CreateWalletView> createState() => _CreateWalletViewState();
}

class _CreateWalletViewState
    extends BasePageState<CreateWalletView, CreateWalletBloc> {
  late final TextEditingController _walletNameController;
  late final TextEditingController _initialBalanceController;

  @override
  void initState() {
    super.initState();
    _walletNameController = TextEditingController();
    _initialBalanceController = TextEditingController();

    bloc.add(const CreateWalletViewInitiated());
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ViewUtils.hideKeyboard(context),
      child: Scaffold(
        appBar: CommonAppBar(
          title:
              widget.isFromSignUp
                  ? S.current.createYourFirstWallet
                  : S.current.createWallet,
        ),
        body: NoirScaffoldBody(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
            child: Column(
              children: [
                SizedBox(height: Dimens.d20.responsive()),
                Container(
                  padding: EdgeInsets.all(Dimens.d16.responsive()),
                  decoration: AppDecorations.glassPanel(),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              navigator.showDialog(
                                AppPopupInfo.selectIcon(
                                  iconType: IconType.wallet,
                                  onIconSelected: (url) {
                                    bloc.add(
                                      CreateWalletIconChanged(iconUrl: url),
                                    );
                                  },
                                ),
                              );
                            },
                            child: BlocBuilder<
                              CreateWalletBloc,
                              CreateWalletState
                            >(
                              buildWhen: (previous, current) {
                                return previous.iconUrl != current.iconUrl;
                              },
                              builder: (context, state) {
                                return CommonCircleNetworkImage(
                                  imageUrl: state.iconUrl,
                                  size: Dimens.d36.responsive(),
                                  placeHolderType: ImagePlaceHolderType.wallet,
                                  backgroundColor: primaryShadeColor,
                                );
                              },
                            ),
                          ),
                          SizedBox(width: Dimens.d10.responsive()),
                          Expanded(
                            child: CommonInlineTextField(
                              controller: _walletNameController,
                              hintText: S.current.nameYourWalletHere,
                              onChanged: (name) {
                                bloc.add(
                                  CreateWalletNameInputChanged(
                                    walletName: name,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const CommonLine(),
                      BlocBuilder<CreateWalletBloc, CreateWalletState>(
                        buildWhen: (previous, current) {
                          return previous.selectedCurrency !=
                              current.selectedCurrency;
                        },
                        builder: (context, state) {
                          return CommonForwardButton(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimens.d8.responsive(),
                            ),
                            title: S.current.currency,
                            color: surfaceColor,
                            showBorder: false,
                            onTap: () {
                              navigator.showModalBottomSheet(
                                AppPopupInfo.chooseCurrency(
                                  onCurrencySelected: (selectedCurrency) {
                                    context.read<CreateWalletBloc>().add(
                                      CreateWalletCurrencyChanged(
                                        currency: selectedCurrency,
                                      ),
                                    );
                                  },
                                  currentCurrency: state.selectedCurrency,
                                ),
                              );
                            },
                            leadingIcon: CommonCurrencyContainer(
                              currentCurrencyCode: state.selectedCurrency?.code,
                            ),
                          );
                        },
                      ),
                      const CommonLine(),
                      CommonInlineTextField(
                        controller: _initialBalanceController,
                        hintText: S.current.initialBalance,
                        inputType: TextInputType.number,
                        maxLength: 24,
                        onChanged: (balance) {
                          bloc.add(
                            CreateWalletInitialBalanceInputChanged(
                              initialBalance: balance,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimens.d30.responsive()),
                BlocBuilder<CreateWalletBloc, CreateWalletState>(
                  buildWhen: (previous, current) {
                    return previous.isConfirmButtonEnabled !=
                        current.isConfirmButtonEnabled;
                  },
                  builder: (context, state) {
                    return CommonButton(
                      text: S.current.save,
                      onTap:
                          state.isConfirmButtonEnabled
                              ? () {
                                context.read<CreateWalletBloc>().add(
                                  const CreateWalletConfirmButtonPressed(),
                                );
                              }
                              : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
