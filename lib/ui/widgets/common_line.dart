import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/resources/styles/app_colors.dart';

class CommonLine extends StatelessWidget {
  const CommonLine({super.key, this.thickness = 1, this.color = blackColor, this.margin});

  final double thickness;
  final Color color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: Dimens.d12.responsive()),
      height: thickness,
      width: double.infinity,
      child: CustomPaint(painter: CustomLinePainter(color: color, thickness: thickness)),
    );
  }
}

class CustomLinePainter extends CustomPainter {
  CustomLinePainter({required this.color, this.thickness = 1.0});

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke;

    const start = Offset.zero;
    final end = Offset(size.width, 0);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomLinePainter oldDelegate) => false;
}
