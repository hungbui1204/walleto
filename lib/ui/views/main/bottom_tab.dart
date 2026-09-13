import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walleto/resources/resources.dart';

/// Tabs on [MainView]. Screen chrome — not a domain entity.
enum BottomTab { home, transactions, createTrans, budgets, account }

extension BottomTabUi on BottomTab {
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
      BottomTab.budgets => Icon(Icons.auto_awesome_rounded, size: Dimens.d24.responsive()),
      BottomTab.account => _buildIcon(
        iconPath: selected ? Assets.icons.accountActive.path : Assets.icons.accountInactive.path,
      ),
    };
  }

  Widget _buildIcon({required String iconPath}) {
    return SvgPicture.asset(
      iconPath,
      width: Dimens.d24.responsive(),
      height: Dimens.d24.responsive(),
    );
  }

  String get title {
    return switch (this) {
      BottomTab.home => S.current.home,
      BottomTab.transactions => S.current.transactions,
      BottomTab.account => S.current.account,
      BottomTab.budgets => S.current.aiAssistant,
      BottomTab.createTrans => '',
    };
  }
}
