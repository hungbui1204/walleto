import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> platformCalls;

  setUp(() {
    platformCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        platformCalls.add(call);
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  bool didSelectionHaptic() {
    return platformCalls.any(
      (call) =>
          call.method == 'HapticFeedback.vibrate' &&
          call.arguments == 'HapticFeedbackType.selectionClick',
    );
  }

  Future<void> pumpPressable(WidgetTester tester, {required Widget pressable}) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(
          DeviceConstants.designDeviceWidth,
          DeviceConstants.designDeviceHeight,
        ),
        builder: (context, child) {
          return MaterialApp(
            home: Builder(
              builder: (context) {
                AppDimen.of(context);
                return Scaffold(body: Center(child: pressable));
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  AnimatedScale scaleOf(WidgetTester tester) {
    return tester.widget<AnimatedScale>(
      find.descendant(of: find.byType(Pressable), matching: find.byType(AnimatedScale)),
    );
  }

  testWidgets('tap on an enabled Pressable calls onTap and selection haptic', (tester) async {
    var tapped = false;

    await pumpPressable(
      tester,
      pressable: Pressable(onTap: () => tapped = true, child: const Text('Tap me')),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(tapped, isTrue);
    expect(didSelectionHaptic(), isTrue);
  });

  testWidgets('disabled Pressable does not scale, call onTap, or haptic', (tester) async {
    var tapped = false;

    await pumpPressable(tester, pressable: const Pressable(child: Text('Tap me')));

    expect(scaleOf(tester).scale, 1.0);

    final gesture = await tester.startGesture(tester.getCenter(find.text('Tap me')));
    await tester.pump();

    expect(scaleOf(tester).scale, 1.0);

    await gesture.up();
    await tester.pump();

    expect(tapped, isFalse);
    expect(didSelectionHaptic(), isFalse);
  });

  testWidgets('enabled Pressable scales while pressed', (tester) async {
    await pumpPressable(tester, pressable: Pressable(onTap: () {}, child: const Text('Tap me')));

    final gesture = await tester.startGesture(tester.getCenter(find.text('Tap me')));
    await tester.pump();

    expect(scaleOf(tester).scale, Pressable.pressedScale);

    await gesture.up();
    await tester.pump();

    expect(scaleOf(tester).scale, 1.0);
  });

  AnimatedOpacity opacityOf(WidgetTester tester) {
    return tester.widget<AnimatedOpacity>(
      find.descendant(of: find.byType(Pressable), matching: find.byType(AnimatedOpacity)),
    );
  }

  testWidgets('opacity feedback reduces opacity while pressed and does not scale', (tester) async {
    await pumpPressable(
      tester,
      pressable: Pressable(
        onTap: () {},
        feedback: PressableFeedback.opacity,
        child: const Text('Tap me'),
      ),
    );

    expect(opacityOf(tester).opacity, 1.0);
    expect(scaleOf(tester).scale, 1.0);

    final gesture = await tester.startGesture(tester.getCenter(find.text('Tap me')));
    await tester.pump();

    expect(opacityOf(tester).opacity, Pressable.pressedOpacity);
    expect(scaleOf(tester).scale, 1.0);

    await gesture.up();
    await tester.pump();

    expect(opacityOf(tester).opacity, 1.0);
  });

  testWidgets('ClipRRect uses the given borderRadius', (tester) async {
    const radius = BorderRadius.all(Radius.circular(8));

    await pumpPressable(
      tester,
      pressable: const Pressable(borderRadius: radius, child: Text('Tap me')),
    );

    final clip = tester.widget<ClipRRect>(
      find.descendant(of: find.byType(Pressable), matching: find.byType(ClipRRect)),
    );
    expect(clip.borderRadius, radius);
  });
}
