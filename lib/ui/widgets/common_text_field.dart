import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:walleto/resources/resources.dart';

class CommonTextField extends StatefulWidget {
  const CommonTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.isPasswordField = false,
    this.prefixIcon,
    this.hintText,
    this.maxLines,
  });

  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final EdgeInsetsGeometry contentPadding;
  final bool isPasswordField;
  final SvgPicture? prefixIcon;
  final String? hintText;
  final int? maxLines;

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      controller: widget.controller,
      style: AppTextStyles.s14wNormalBlack(),
      obscureText: widget.isPasswordField ? isVisible : false,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hintText,
        contentPadding: widget.contentPadding,
        filled: true,
        fillColor: fieldFillColor,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.d12.responsive())),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.d12.responsive())),
        ),
        prefixIcon:
            widget.prefixIcon != null
                ? Container(
                  margin: EdgeInsets.only(right: Dimens.d8.responsive()),
                  padding: EdgeInsets.all(Dimens.d16.responsive()),
                  decoration: BoxDecoration(
                    color: primaryShadeColor,
                    border: Border.all(),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimens.d12.responsive()),
                      bottomLeft: Radius.circular(Dimens.d12.responsive()),
                    ),
                  ),
                  child: widget.prefixIcon,
                )
                : null,
        suffixIcon:
            widget.isPasswordField
                ? GestureDetector(
                  onTap:
                      () => setState(() {
                        isVisible = !isVisible;
                      }),
                  child: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: primaryShadeColor,
                  ),
                )
                : null,
      ),
    );
  }
}
