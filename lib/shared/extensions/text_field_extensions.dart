import 'package:flutter/material.dart';

/// Helper methods for TextFieldWidget to easily set, delete, append the value programmatically
/// ``` dart
/// final controller = TextEditingController();
///
/// controller.setText('1234');
///
/// TextFieldWidget(
///   controller: controller,
/// );
/// ```
///
extension TextEditingControllerExtension on TextEditingController {
  /// The length of the text field value
  int get length => text.length;

  /// Sets text field value
  void setText(String text) {
    this.text = text;
    moveCursorToEnd();
  }

  /// Deletes the last character of text field value
  void delete() {
    if (text.isEmpty) return;
    final newValue = text.substring(0, length - 1);
    text = newValue;
    moveCursorToEnd();
  }

  /// Appends character at the end of the text field value
  void append(String s, int maxLength) {
    if (length == maxLength) return;
    text = '$text$s';
    moveCursorToEnd();
  }

  /// Moves cursor at the end
  void moveCursorToEnd() {
    selection = TextSelection.collapsed(offset: length);
  }
}
