import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:walleto/resources/resources.dart';

class CommonTextField extends StatefulWidget {
  const CommonTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.contentPadding,
    this.isPasswordField = false,
    this.prefixIcon,
    this.hintText,
    this.maxLines = 1,
    this.prefixBackgroundColor,
    this.maxLength = 100,
    this.keyboardType = TextInputType.text,
  });

  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? contentPadding;
  final bool isPasswordField;
  final SvgPicture? prefixIcon;
  final Color? prefixBackgroundColor;
  final String? hintText;
  final int maxLines;
  final int maxLength;
  final TextInputType keyboardType;

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool isVisible = true;

  OutlineInputBorder _border({Color color = glassHairlineColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(Dimens.d16.responsive())),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      controller: widget.controller,
      style: AppTextStyles.s14wNormalBlack(),
      obscureText: widget.isPasswordField ? isVisible : false,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      cursorColor: primaryColor,
      decoration: InputDecoration(
        counterText: '',
        hintText: widget.hintText,
        hintStyle: AppTextStyles.s14wNormalGrey(),
        contentPadding:
            widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: Dimens.d16.responsive(),
              vertical: Dimens.d14.responsive(),
            ),
        filled: true,
        fillColor: fieldFillColor,
        enabledBorder: _border(),
        focusedBorder: _border(color: primaryColor),
        border: _border(),
        errorBorder: _border(color: fieldErrorColor),
        focusedErrorBorder: _border(color: fieldErrorColor),
        prefixIcon:
            widget.prefixIcon != null
                ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.d12.responsive(),
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      widget.prefixBackgroundColor ?? darkGreyColor,
                      BlendMode.srcIn,
                    ),
                    child: widget.prefixIcon,
                  ),
                )
                : null,
        prefixIconConstraints: BoxConstraints(
          minWidth: Dimens.d44.responsive(),
          minHeight: Dimens.d44.responsive(),
        ),
        suffixIcon:
            widget.isPasswordField
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                  icon: Icon(
                    isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: darkGreyColor,
                  ),
                )
                : null,
      ),
    );
  }
}
