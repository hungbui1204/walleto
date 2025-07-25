// ignore_for_file: avoid_hard_coded_text_style
import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

/// AppTextStyle format as follows:
/// s[fontSize][fontWeight][Color]
/// Example: s18w400Primary
class AppTextStyles {
  AppTextStyles._();

  static const _defaultLetterSpacing = 0.05;

  static const _baseTextStyle = TextStyle(height: 1.5, letterSpacing: _defaultLetterSpacing);

  static TextStyle s6wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d6.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s8wBoldBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d8.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s10wNormalWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d10.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s10wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d10.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s10wNormalRed({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: redColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d10.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s10wNormalGreen({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: greenColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d10.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s10wNormalGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: darkGreyColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d10.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s10wBoldWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d10.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s10wBoldBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d10.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s10wBoldGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: greyColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d10.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s12wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d12.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s12wNormalWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d12.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s12wBoldWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d12.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s12wNormalBlackUnderline({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d12.responsive(tablet: tablet, ultraTablet: ultraTablet),
        decoration: TextDecoration.underline,
      ),
    );
  }

  static TextStyle s13wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d13.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s13wNormalWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d13.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s13wBoldWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d13.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s13wBoldBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d13.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s13wBoldGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: greyColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d13.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s13wNormalLink({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: navyColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d13.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s13wNormalAlert({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: alertColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d13.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wNormalWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wNormalGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: greyColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wNormalRed({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: redColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wNormalGreen({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: greenColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wNormalBlackUnderline({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
        decoration: TextDecoration.underline,
      ),
    );
  }

  static TextStyle s14wBoldWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wBoldBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wBoldGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: greyColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wBoldDarkGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: darkGreyColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s14wBoldAlert({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: alertColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d14.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s15wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d15.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s15wBoldBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d15.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s16wNormalWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s16wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s16wNormalGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: backgroundDisabled,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s16wBoldWhite({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: whiteColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s16wBoldBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s16wBoldPrimary({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s16wBoldGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: greyColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s16wNormalAlert({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: alertColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s16wNormalNavy({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: navyColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
        decoration: TextDecoration.underline,
      ),
    );
  }

  static TextStyle s16wBoldAlert({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: alertColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d16.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s18wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d18.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s18wNormalGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: backgroundDisabled,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d18.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s18wBoldBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d18.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s20wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d20.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s20wBoldBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d20.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s20wBoldAlert({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: alertColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d20.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s28wNormalBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.normal,
        fontSize: Dimens.d28.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s28wBoldGrey({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: backgroundDisabled,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d28.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }

  static TextStyle s28wBoldBlack({double? tablet, double? ultraTablet}) {
    return _baseTextStyle.merge(
      TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: Dimens.d28.responsive(tablet: tablet, ultraTablet: ultraTablet),
      ),
    );
  }
}
