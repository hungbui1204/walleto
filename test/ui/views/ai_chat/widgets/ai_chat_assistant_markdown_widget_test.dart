import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  Future<void> pumpMarkdown(WidgetTester tester, String content) async {
    tester.view.physicalSize = const Size(
      DeviceConstants.designDeviceWidth,
      DeviceConstants.designDeviceHeight,
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(
          DeviceConstants.designDeviceWidth,
          DeviceConstants.designDeviceHeight,
        ),
        builder: (context, _) {
          return MaterialApp(
            theme: AppThemes.appTheme,
            home: Builder(
              builder: (context) {
                AppDimen.of(context);
                return Scaffold(body: AiChatAssistantMarkdownWidget(content: content));
              },
            ),
          );
        },
      ),
    );
  }

  testWidgets('maps Noir Glass tokens onto MarkdownConfig', (tester) async {
    await pumpMarkdown(tester, 'Hello');

    final block = tester.widget<MarkdownBlock>(find.byType(MarkdownBlock));
    final config = block.config!;
    final heading = AppTextStyles.s16wBoldBlack();
    final subheading = AppTextStyles.s14wBoldBlack();

    expect(config.p.textStyle.color, blackColor);
    expect(config.p.textStyle.fontSize, AppTextStyles.s14wNormalBlack().fontSize);
    expect(config.a.style.color, primaryColor);
    expect(config.a.style.decoration, TextDecoration.underline);
    expect(config.code.style.backgroundColor, fieldFillColor);
    expect(config.hr.color, frameColor);
    expect(config.h1.style, heading);
    expect(config.h1.divider, isNull);
    expect(config.h2.style, heading);
    expect(config.h3.style, subheading);
    expect(config.blockquote.sideColor, frameColor);
    expect(config.blockquote.textColor, darkGreyColor);
  });

  testWidgets('renders bold, italic, lists, and inline code without raw markers', (tester) async {
    await pumpMarkdown(tester, '**Bold** and *italic*\n\n- coffee\n- tea\n\nUse `VND`');

    expect(find.byType(MarkdownBlock), findsOneWidget);
    expect(find.textContaining('**Bold**'), findsNothing);
    expect(find.textContaining('`VND`'), findsNothing);
    expect(find.textContaining('Bold'), findsWidgets);
    expect(find.textContaining('italic'), findsWidgets);
    expect(find.textContaining('coffee'), findsWidgets);
    expect(find.textContaining('tea'), findsWidgets);
    expect(find.textContaining('VND'), findsWidgets);
  });
}
