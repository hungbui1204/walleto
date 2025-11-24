import 'dart:async';

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

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

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

  Future<bool> _imageUrlCheck() async {
    try {
      if (!_isValidUrl(imageUrl)) return false;

      final image = NetworkImage(imageUrl!);
      final completer = Completer<bool>();
      final stream = image.resolve(ImageConfiguration.empty);

      final listener = ImageStreamListener(
        (image, synchronousCall) => completer.complete(true),
        onError: (exception, stackTrace) => completer.complete(false),
      );

      stream.addListener(listener);
      final result = await completer.future;
      stream.removeListener(listener);

      return result;
    } catch (_) {
      return false;
    }
  }

  Widget buildShapeImage(BuildContext context, {required Widget imageWidget});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FutureBuilder<bool>(
        future: _imageUrlCheck(),
        builder: (context, snapshot) {
          Widget imageWidget;

          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            if (snapshot.data!) {
              imageWidget = Image.network(imageUrl!, fit: fit, width: width, height: height);
            } else {
              imageWidget = _placeholder;
            }
          } else {
            imageWidget = _placeholder;
          }

          return buildShapeImage(context, imageWidget: imageWidget);
        },
      ),
    );
  }
}
