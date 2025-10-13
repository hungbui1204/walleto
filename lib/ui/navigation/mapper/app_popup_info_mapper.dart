import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

@LazySingleton(as: BasePopupInfoMapper)
class AppPopupInfoMapper extends BasePopupInfoMapper {
  @override
  Widget map(AppPopupInfo appRouteInfo, AppNavigator navigator) {
    return switch (appRouteInfo) {
      Confirm(:final message, :final showCancel, :final actions, :final onPressed) => ConfirmPopup(
        message: message,
        showCancel: showCancel,
        onPressed: onPressed,
        confirmAction: actions,
      ),
      ErrorWithRetry(:final message, :final actions) => ErrorPopup(
        message: message,
        errorAction: actions,
      ),
      Complete(:final message, :final actions) => CompletePopup(
        message: message,
        completeAction: actions,
      ),
      Error(:final message, :final actions) => ErrorPopup(message: message, errorAction: actions),
      Warning(:final content) => WarningPopup(content: content),
      SelectCategory(:final onCategorySelected, :final isSelectingParent, :final categoryType) =>
        SelectCategoryPopup(
          onCategorySelected: onCategorySelected,
          isSelectingParent: isSelectingParent,
          categoryType: categoryType,
        ),

      SelectMonth(:final firstYear, :final lastYear, :final onMonthSelected, :final initialDate) =>
        SelectMonthPopup(
          firstYear: firstYear,
          lastYear: lastYear,
          onMonthSelected: onMonthSelected,
          initialDate: initialDate,
        ),
      NoteInput(:final currentNote, :final onNoteChanged) => NoteInputBottomSheet(
        currentNote: currentNote,
        onNoteChanged: onNoteChanged,
      ),
      ChooseWallet(:final onWalletSelected, :final currentWallet) => ChooseWalletBottomSheet(
        onWalletSelected: onWalletSelected,
        currentWallet: currentWallet,
      ),
      SelectWallet(:final wallets, :final onWalletSelected, :final selectedWallet) =>
        SelectWalletPopup(
          wallets: wallets,
          onWalletSelected: onWalletSelected,
          selectedWallet: selectedWallet,
        ),
      SelectIcon(:final iconType, :final onIconSelected) => SelectIconPopup(
        iconType: iconType,
        onIconSelected: onIconSelected,
      ),
    };
  }
}
