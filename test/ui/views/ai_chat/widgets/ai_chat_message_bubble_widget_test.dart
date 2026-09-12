import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  Future<void> pumpBubble(
    WidgetTester tester, {
    required AiChatMessage message,
    bool isStreaming = false,
  }) async {
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
                return Scaffold(
                  body: AiChatMessageBubbleWidget(message: message, isStreaming: isStreaming),
                );
              },
            ),
          );
        },
      ),
    );
  }

  testWidgets('keeps user messages as plain SelectableText', (tester) async {
    await pumpBubble(tester, message: const AiChatMessage(content: '**do not parse me**'));

    expect(find.byType(MarkdownBlock), findsNothing);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.text('**do not parse me**'), findsOneWidget);
  });

  testWidgets('keeps streaming assistant messages as plain SelectableText', (tester) async {
    await pumpBubble(
      tester,
      message: const AiChatMessage(role: AiChatRole.assistant, content: '**half'),
      isStreaming: true,
    );

    expect(find.byType(MarkdownBlock), findsNothing);
    expect(find.byType(AiChatAssistantMarkdownWidget), findsNothing);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.text('**half'), findsOneWidget);
  });

  testWidgets('renders completed assistant messages as markdown', (tester) async {
    await pumpBubble(
      tester,
      message: const AiChatMessage(
        id: 12,
        role: AiChatRole.assistant,
        content: 'You spent **50**.',
      ),
    );

    expect(find.byType(AiChatAssistantMarkdownWidget), findsOneWidget);
    expect(find.byType(MarkdownBlock), findsOneWidget);
    expect(find.byType(SelectableText), findsNothing);
    expect(find.textContaining('**50**'), findsNothing);
    expect(find.textContaining('You spent 50'), findsWidgets);
  });
}
