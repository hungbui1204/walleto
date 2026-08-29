import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:walleto/resources/resources.dart';

class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundOverlayColor,
      child: Center(
        child: Lottie.asset(
          'assets/animations/app_loading.json',
          width: Dimens.d260.responsive(),
          height: Dimens.d260.responsive(),
          repeat: true,
        ),
      ),
    );
  }
}
