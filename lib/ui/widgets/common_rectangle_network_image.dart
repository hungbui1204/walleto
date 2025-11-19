import 'package:flutter/material.dart';
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
  });

  @override
  Widget buildShapeImage(BuildContext context, {required Widget imageWidget}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: backgroundColor, border: Border.all()),
      alignment: Alignment.center,
      child: imageWidget,
    );
  }
}
