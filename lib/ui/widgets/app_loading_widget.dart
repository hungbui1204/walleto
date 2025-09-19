import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:walleto/resources/resources.dart';

class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: blackColor.withValues(alpha: 0.3),
      child: Center(
        child: Lottie.asset('assets/animations/app_loading.json', width: 260, height: 260),
      ),
    );
  }
}
