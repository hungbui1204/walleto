import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonInlineTextField extends StatelessWidget {
  const CommonInlineTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLength = 30,
    this.inputType = TextInputType.text,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final int maxLength;
  final TextInputType inputType;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      cursorHeight: Dimens.d20.responsive(),
      showCursor: true,
      style: AppTextStyles.s18wNormalBlack(),
      maxLength: maxLength,
      keyboardType: inputType,
      decoration: InputDecoration(
        isCollapsed: true,
        hintText: hintText,
        hintStyle: AppTextStyles.s16wNormalGrey().copyWith(fontStyle: FontStyle.italic),
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        counter: const SizedBox.shrink(),
      ),
      controller: controller,
    );
  }
}
