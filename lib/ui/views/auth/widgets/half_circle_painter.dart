import 'dart:math';

import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class HalfCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = primaryShade1Color
          ..style = PaintingStyle.fill;

    final diameter = size.width;
    final rect = Rect.fromCircle(center: Offset(size.width / 2, 0), radius: diameter / 2);

    // Draw the half circle
    // The angle is set to pi to start from the top and go downwards
    canvas.drawArc(rect, pi, -pi, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
