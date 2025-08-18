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
    this.enablePadding = true,
  });

  final String? imageUrl;
  final double? size;
  final BoxFit fit;
  final ImagePlaceHolderType placeHolderType;
  final Color backgroundColor;
  final bool enablePadding;

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  Widget get _placeholder {
    return switch (placeHolderType) {
      ImagePlaceHolderType.user => ClipOval(
        child: Assets.images.chooseAvt.image(
          width: size ?? Dimens.d30.responsive(),
          height: size ?? Dimens.d30.responsive(),
          fit: BoxFit.cover,
        ),
      ),
      ImagePlaceHolderType.category => Assets.icons.categoryImagePlaceHolder.svg(
        width: size ?? Dimens.d30.responsive(),
        height: size ?? Dimens.d30.responsive(),
      ),
      ImagePlaceHolderType.wallet => Assets.icons.walletImagePlaceHolder.svg(
        width: size ?? Dimens.d30.responsive(),
        height: size ?? Dimens.d30.responsive(),
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

  @override
  Widget build(BuildContext context) {
    final widgetSize =
        size == null
            ? Dimens.d36.responsive()
            : size! + (enablePadding ? Dimens.d6.responsive() : Dimens.d2.responsive());

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
          height: widgetSize,
          width: widgetSize,
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
