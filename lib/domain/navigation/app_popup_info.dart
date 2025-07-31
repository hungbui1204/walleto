import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

part 'app_popup_info.freezed.dart';

/// dialog, bottomsheet
@freezed
sealed class AppPopupInfo with _$AppPopupInfo {
  const factory AppPopupInfo.confirm({
    Widget? icon,
    @Default('') String message,
    @Default(false) bool showCancel,
    Widget? actions,
    Func0<void>? onPressed,
  }) = Confirm;

  const factory AppPopupInfo.errorWithRetry({
    Widget? icon,
    @Default('') String message,
    Widget? actions,
    Func0<void>? onRetryPressed,
  }) = ErrorWithRetry;

  const factory AppPopupInfo.complete({Widget? icon, required String message, Widget? actions}) =
      Complete;

  const factory AppPopupInfo.error({Widget? icon, required String message, Widget? actions}) =
      Error;

  const factory AppPopupInfo.warning({Widget? icon, required Widget content}) = Warning;

  const factory AppPopupInfo.selectCategory({required void Function(Category) onCategorySelected}) =
      SelectCategory;

  const factory AppPopupInfo.selectMonth({
    required int firstYear,
    required int lastYear,
    required void Function(DateTime) onMonthSelected,
    required DateTime? initialDate,
  }) = SelectMonth;

  const factory AppPopupInfo.noteInput({
    required String currentNote,
    required void Function(String) onNoteChanged,
  }) = NoteInput;
}
