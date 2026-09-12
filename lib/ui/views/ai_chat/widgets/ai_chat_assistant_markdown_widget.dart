import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:walleto/resources/resources.dart';

class AiChatAssistantMarkdownWidget extends StatelessWidget {
  const AiChatAssistantMarkdownWidget({super.key, required this.content});

  final String content;

  @visibleForTesting
  static MarkdownConfig config() {
    final bodyStyle = AppTextStyles.s14wNormalBlack();
    final headingStyle = AppTextStyles.s16wBoldBlack();
    final subheadingStyle = AppTextStyles.s14wBoldBlack();
    final codeStyle = AppTextStyles.s14wNormalGrey().copyWith(backgroundColor: fieldFillColor);
    final panelRadius = AppDecorations.panelRadius(radius: Dimens.d8.responsive());

    return MarkdownConfig(
      configs: [
        PConfig(textStyle: bodyStyle),
        _AssistantHeadingConfig(style: headingStyle, tag: MarkdownTag.h1.name),
        _AssistantHeadingConfig(style: headingStyle, tag: MarkdownTag.h2.name),
        _AssistantHeadingConfig(style: subheadingStyle, tag: MarkdownTag.h3.name),
        _AssistantHeadingConfig(style: subheadingStyle, tag: MarkdownTag.h4.name),
        _AssistantHeadingConfig(style: subheadingStyle, tag: MarkdownTag.h5.name),
        _AssistantHeadingConfig(style: subheadingStyle, tag: MarkdownTag.h6.name),
        CodeConfig(style: codeStyle),
        PreConfig(
          padding: EdgeInsets.all(Dimens.d8.responsive()),
          margin: EdgeInsets.symmetric(vertical: Dimens.d8.responsive()),
          decoration: AppDecorations.secondaryCta(radius: panelRadius, color: fieldFillColor),
          textStyle: AppTextStyles.s14wNormalGrey(),
          theme: const <String, TextStyle>{},
          builder: (code, _) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: Dimens.d8.responsive()),
              child: DecoratedBox(
                decoration: AppDecorations.secondaryCta(radius: panelRadius, color: fieldFillColor),
                child: Padding(
                  padding: EdgeInsets.all(Dimens.d8.responsive()),
                  child: Text(code, style: AppTextStyles.s14wNormalGrey()),
                ),
              ),
            );
          },
        ),
        LinkConfig(style: AppTextStyles.s14wNormalUnderlinePrimary(), onTap: (_) {}),
        ListConfig(
          marginLeft: Dimens.d20.responsive(),
          marginBottom: Dimens.d4.responsive(),
          marker: (isOrdered, _, index) {
            return Text(isOrdered ? '${index + 1}.' : '•', style: bodyStyle);
          },
        ),
        HrConfig(height: Dimens.d1.responsive(), color: frameColor),
        BlockquoteConfig(
          sideColor: frameColor,
          textColor: darkGreyColor,
          sideWith: Dimens.d2.responsive(),
          padding: EdgeInsets.only(
            left: Dimens.d12.responsive(),
            top: Dimens.d2.responsive(),
            bottom: Dimens.d2.responsive(),
          ),
          margin: EdgeInsets.symmetric(vertical: Dimens.d8.responsive()),
        ),
        ImgConfig(builder: (_, __) => const SizedBox.shrink()),
        TableConfig(wrapper: (_) => const SizedBox.shrink()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBlock(
      data: content,
      config: config(),
      generator: MarkdownGenerator(
        linesMargin: EdgeInsets.symmetric(vertical: Dimens.d4.responsive()),
      ),
    );
  }
}

class _AssistantHeadingConfig extends HeadingConfig {
  _AssistantHeadingConfig({required this.style, required this.tag});

  @override
  final TextStyle style;

  @override
  final String tag;

  @override
  HeadingDivider? get divider => null;

  @override
  EdgeInsets get padding =>
      EdgeInsets.only(top: Dimens.d8.responsive(), bottom: Dimens.d4.responsive());
}
