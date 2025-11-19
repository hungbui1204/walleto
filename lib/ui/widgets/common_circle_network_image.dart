import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/widgets/base/common_shape_network_image.dart';

class CommonCircleNetworkImage extends CommonShapeNetworkImage {
  const CommonCircleNetworkImage({
    super.key,
    required super.imageUrl,
    double? size,
    super.fit,
    super.placeHolderType,
    super.backgroundColor,
    super.enablePadding,
  }) : super(width: size, height: size);

  @override
  Widget buildShapeImage(BuildContext context, {required Widget imageWidget}) {
    final widgetSize =
        width == null
            ? Dimens.d36.responsive()
            : width! + (enablePadding ? Dimens.d6.responsive() : Dimens.d2.responsive());

    return ClipOval(
      child: Container(
        height: widgetSize,
        width: widgetSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(),
        ),
        alignment: Alignment.center,
        child: imageWidget,
      ),
    );
  }
}
