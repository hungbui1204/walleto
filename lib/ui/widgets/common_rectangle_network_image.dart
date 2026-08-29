import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class CommonRectangleNetworkImage extends CommonShapeNetworkImage {
  const CommonRectangleNetworkImage({
    super.key,
    required super.imageUrl,
    super.width,
    super.height,
    super.fit,
    super.placeHolderType,
    super.backgroundColor,
    super.enablePadding,
    this.hasBorder = true,
  });

  final bool hasBorder;

  @override
  Widget buildShapeImage(BuildContext context, {required Widget imageWidget}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: hasBorder ? Border.all(color: glassHairlineColor) : null,
      ),
      alignment: Alignment.center,
      child: imageWidget,
    );
  }
}
