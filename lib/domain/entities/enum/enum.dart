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
        height: Dimens.d30.responsive(),
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
        height: Dimens.d38.responsive(),
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

enum ImagePlaceHolderType { category, wallet, user, currency }

enum OperationType {
  addition,
  subtraction,
  multiplication,
  division;

  static OperationType fromString(String operation) {
    if (operation == S.current.addition) {
      return OperationType.addition;
    } else if (operation == S.current.subtraction) {
      return OperationType.subtraction;
    } else if (operation == S.current.multiplication) {
      return OperationType.multiplication;
    } else if (operation == S.current.division) {
      return OperationType.division;
    } else {
      throw ArgumentError('Invalid operation type: $operation');
    }
  }

  String get symbol {
    return switch (this) {
      OperationType.addition => S.current.addition,
      OperationType.subtraction => S.current.subtraction,
      OperationType.multiplication => S.current.multiplication,
      OperationType.division => S.current.division,
    };
  }
}

enum CategoryType {
  expense,
  income;

  String get name {
    return switch (this) {
      CategoryType.expense => 'expense',
      CategoryType.income => 'income',
    };
  }
}

enum TargetMonth {
  current,
  previous;

  String get name {
    return switch (this) {
      TargetMonth.current => 'this_month',
      TargetMonth.previous => 'last_month',
    };
  }

  String get displayName {
    return switch (this) {
      TargetMonth.current => S.current.thisMonth,
      TargetMonth.previous => S.current.lastMonth,
    };
  }
}

/// Sign up steps for [SignUpTab] in [LoginView]
enum SignUpStep {
  emailConfirm(1),
  otpConfirm(2),
  signingUp(3),
  signUpComplete(4);

  const SignUpStep(this.step);

  final int step;
}

/// Reset password steps for [ResetPasswordView]
enum ResetPasswordStep {
  emailConfirm(1),
  otpConfirm(2),
  resettingPassword(3),
  resetPasswordComplete(4);

  const ResetPasswordStep(this.step);

  final int step;
}

enum IconType { category, wallet }
