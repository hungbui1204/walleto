import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class AiChatLoadingSkeletonWidget extends StatelessWidget {
  const AiChatLoadingSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
        child: Column(
          children: [
            SizedBox(height: Dimens.d12.responsive()),
            _AiChatSkeletonBubble(
              alignment: Alignment.centerLeft,
              width: Dimens.d200.responsive(),
              height: Dimens.d48.responsive(),
            ),
            _AiChatSkeletonBubble(
              alignment: Alignment.centerRight,
              width: Dimens.d160.responsive(),
              height: Dimens.d40.responsive(),
            ),
            _AiChatSkeletonBubble(
              alignment: Alignment.centerLeft,
              width: Dimens.d240.responsive(),
              height: Dimens.d64.responsive(),
            ),
            _AiChatSkeletonBubble(
              alignment: Alignment.centerRight,
              width: Dimens.d200.responsive(),
              height: Dimens.d48.responsive(),
            ),
            _AiChatSkeletonBubble(
              alignment: Alignment.centerLeft,
              width: Dimens.d160.responsive(),
              height: Dimens.d36.responsive(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiChatSkeletonBubble extends StatelessWidget {
  const _AiChatSkeletonBubble({required this.alignment, required this.width, required this.height});

  final Alignment alignment;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.only(bottom: Dimens.d12.responsive()),
        child: CommonShimmerBox(width: width, height: height),
      ),
    );
  }
}
