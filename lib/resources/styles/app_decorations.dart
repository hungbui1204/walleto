import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class AppDecorations {
  const AppDecorations._();

  static BorderRadius panelRadius({double? radius}) {
    return BorderRadius.circular(radius ?? Dimens.d16.responsive());
  }

  static BoxDecoration glassPanel({Color? color, double? radius}) {
    return BoxDecoration(
      borderRadius: panelRadius(radius: radius),
      border: Border.all(color: glassHairlineColor),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [surfaceHighlightColor, color ?? surfaceColor],
      ),
      boxShadow: softCardShadow,
    );
  }

  static BoxDecoration primaryCta({required BorderRadius radius}) {
    return BoxDecoration(
      color: primaryColor,
      borderRadius: radius,
      boxShadow: ctaGlowShadow,
    );
  }

  static BoxDecoration secondaryCta({
    required BorderRadius radius,
    Color color = surfaceColor,
    Color borderColor = glassHairlineColor,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: radius,
      border: Border.all(color: borderColor),
    );
  }

  static BoxDecoration keyboardSheet() {
    return BoxDecoration(
      color: surfaceColor,
      border: const Border(top: BorderSide(color: glassHairlineColor)),
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Dimens.d16.responsive()),
      ),
    );
  }
}
