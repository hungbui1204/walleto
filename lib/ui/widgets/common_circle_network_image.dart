import 'dart:async';

import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';

class CommonCircleNetworkImage extends StatelessWidget {
  const CommonCircleNetworkImage({
    super.key,
    required this.imageUrl,
    this.size,
    this.fit = BoxFit.cover,
    this.placeHolderType = ImagePlaceHolderType.category,
    this.backgroundColor = primaryColor,
  });

  final String? imageUrl;
  final double? size;
  final BoxFit fit;
  final ImagePlaceHolderType placeHolderType;
  final Color backgroundColor;

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  Widget get _placeholder {
    return placeHolderType == ImagePlaceHolderType.category
        ? Assets.icons.categoryImagePlaceHolder.svg(
          width: size ?? Dimens.d30.responsive(),
          height: size ?? Dimens.d30.responsive(),
        )
        : Assets.icons.walletImagePlaceHolder.svg(
          width: size ?? Dimens.d30.responsive(),
          height: size ?? Dimens.d30.responsive(),
        );
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _imageUrlCheck(),
      builder: (context, snapshot) {
        Widget imageWidget;

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          if (snapshot.data!) {
            imageWidget = Image.network(
              imageUrl!,
              fit: fit,
              width: size ?? Dimens.d30.responsive(),
              height: size ?? Dimens.d30.responsive(),
            );
          } else {
            imageWidget = _placeholder;
          }
        } else {
          imageWidget = _placeholder;
        }

        return Container(
          height: size == null ? Dimens.d36.responsive() : size! + Dimens.d6.responsive(),
          width: size == null ? Dimens.d36.responsive() : size! + Dimens.d6.responsive(),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(),
          ),
          alignment: Alignment.center,
          child: imageWidget,
        );
      },
    );
  }
}
