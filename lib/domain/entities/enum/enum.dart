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
  budgets,
  account;

  Widget icon({bool selected = false}) {
    return switch (this) {
      BottomTab.home => _buildIcon(
        selected ? Assets.icons.homeActive.path : Assets.icons.homeInactive.path,
      ),
      BottomTab.transactions => _buildIcon(
        selected
            ? Assets.icons.transactionsHistoryActive.path
            : Assets.icons.transactionsHistoryInactive.path,
      ),
      BottomTab.budgets => _buildIcon(
        selected ? Assets.icons.currencyActive.path : Assets.icons.currencyInactive.path,
      ),
      BottomTab.account => _buildIcon(
        selected ? Assets.icons.accountActive.path : Assets.icons.accountInactive.path,
      ),
    };
  }

  Widget _buildIcon(String iconPath) {
    return SvgPicture.asset(iconPath, height: Dimens.d28.responsive());
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
    }
  }
}

enum InvalidTokenHandlerStatus { emptyToken, tokenRefreshed, refreshTokenExpired }
