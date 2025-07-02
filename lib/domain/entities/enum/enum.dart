import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

enum InitialAppRoute { login, main }

enum LanguageCode {
  en(value: 1, localeCode: LocaleConstants.en);

  const LanguageCode({required this.value, required this.localeCode});

  final int value;
  final String localeCode;

  static const defaultValue = en;
}

/// [MainView]
enum BottomTab {
  home,
  transactions,
  createTrans,
  budgets,
  account;

  Widget icon({bool selected = false}) {
    return switch (this) {
      BottomTab.home => _buildIcon(
        iconPath: selected ? Assets.icons.homeActive.path : Assets.icons.homeInactive.path,
      ),
      BottomTab.transactions => _buildIcon(
        iconPath:
            selected
                ? Assets.icons.transactionsHistoryActive.path
                : Assets.icons.transactionsHistoryInactive.path,
      ),
      BottomTab.createTrans => _buildIcon(iconPath: Assets.icons.plus.path),
      BottomTab.budgets => _buildIcon(
        iconPath: selected ? Assets.icons.currencyActive.path : Assets.icons.currencyInactive.path,
        height: Dimens.d30.responsive(),
      ),
      BottomTab.account => _buildIcon(
        iconPath: selected ? Assets.icons.accountActive.path : Assets.icons.accountInactive.path,
      ),
    };
  }

  Widget _buildIcon({required String iconPath, double? height}) {
    return SvgPicture.asset(iconPath, height: height ?? Dimens.d28.responsive());
  }

  String get title {
    switch (this) {
      case BottomTab.home:
        return S.current.home;
      case BottomTab.transactions:
        return S.current.transactions;
      case BottomTab.account:
        return S.current.account;
      case BottomTab.budgets:
        return S.current.budgets;
      case BottomTab.createTrans:
        return '';
    }
  }
}

enum InvalidTokenHandlerStatus { emptyToken, tokenRefreshed, refreshTokenExpired }
