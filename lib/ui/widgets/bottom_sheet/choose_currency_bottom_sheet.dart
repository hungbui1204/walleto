import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class ChooseCurrencyBottomSheet extends StatelessWidget {
  const ChooseCurrencyBottomSheet({
    super.key,
    required this.onCurrencySelected,
    this.currentCurrency,
  });

  final void Function(Currency) onCurrencySelected;
  final Currency? currentCurrency;

  @override
  Widget build(BuildContext context) {
    return CommonPickerSheet(
      title: S.current.chooseCurrency,
      child: BlocBuilder<AppBloc, AppState>(
        buildWhen: (previous, current) => previous.currencies != current.currencies,
        builder: (context, state) {
          return ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: state.currencies.length,
            itemBuilder: (context, index) {
              final currency = state.currencies[index];

              return _CurrencyWidget(
                currency: currency,
                isSelected: currentCurrency?.code == currency.code,
                onTap: () {
                  onCurrencySelected(currency);
                  context.read<AppNavigator>().pop();
                },
              );
            },
            separatorBuilder: (context, index) => const CommonLine(margin: EdgeInsets.zero),
          );
        },
      ),
    );
  }
}

class _CurrencyWidget extends StatelessWidget {
  const _CurrencyWidget({required this.currency, required this.onTap, required this.isSelected});

  final Currency currency;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return CommonListRow(
      onTap: onTap,
      leading: CommonRectangleNetworkImage(
        imageUrl: currency.iconUrl,
        height: Dimens.d30.responsive(),
        width: Dimens.d40.responsive(),
        placeHolderType: ImagePlaceHolderType.currency,
        hasBorder: false,
        backgroundColor: transParentColor,
      ),
      title: Text(currency.name, style: AppTextStyles.s14wNormalBlack()),
      backgroundColor: isSelected ? primaryShade1Color : surfaceColor,
      trailing:
          isSelected
              ? Icon(Icons.check_rounded, color: primaryColor, size: Dimens.d20.responsive())
              : null,
    );
  }
}
