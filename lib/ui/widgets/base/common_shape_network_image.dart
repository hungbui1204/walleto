import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';

abstract class CommonShapeNetworkImage extends StatelessWidget {
  const CommonShapeNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.backgroundColor = primaryColor,
    this.enablePadding = true,
    this.fit = BoxFit.cover,
    this.placeHolderType = ImagePlaceHolderType.category,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final bool enablePadding;
  final BoxFit fit;
  final ImagePlaceHolderType placeHolderType;

  Widget get _placeholder {
    return switch (placeHolderType) {
      ImagePlaceHolderType.user => ClipOval(
        child: Assets.images.chooseAvt.image(width: width, height: height, fit: BoxFit.cover),
      ),
      ImagePlaceHolderType.category => Assets.icons.categoryImagePlaceHolder.svg(
        width: width,
        height: height,
      ),
      ImagePlaceHolderType.wallet => Assets.icons.walletImagePlaceHolder.svg(
        width: width,
        height: height,
      ),
      ImagePlaceHolderType.currency => Icon(
        Icons.flag,
        size: width! * 2 / 3,
        color: secondaryColor,
      ),
    };
  }

  Widget buildShapeImage(BuildContext context, {required Widget imageWidget});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Builder(
        builder: (context) {
          final imageWidget = Image.network(
            imageUrl ?? '',
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              return _placeholder;
            },
          );

          return buildShapeImage(context, imageWidget: imageWidget);
        },
      ),
    );
  }
}
