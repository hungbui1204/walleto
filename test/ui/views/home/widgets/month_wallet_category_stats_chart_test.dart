import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const walletStat = WalletStat(
    walletName: 'Cash',
    totalAmount: 100,
    currencyCode: 'USD',
    categoryStats: [
      CategoryStat(categoryName: 'Food', totalAmount: 60),
      CategoryStat(categoryName: 'Rent', totalAmount: 40),
    ],
  );

  setUpAll(() async {
    await S.load(const Locale('en', 'US'));
  });

  Future<void> pumpChart(WidgetTester tester, {required WalletStat walletStat}) async {
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
                return Scaffold(
                  body: SizedBox(
                    height: Dimens.d330.responsive(),
                    width: Dimens.d330.responsive(),
                    child: MonthWalletCategoryStatsChart(walletStat: walletStat),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('empty stats show ChartEmptyPanel', (tester) async {
    await pumpChart(tester, walletStat: const WalletStat());

    expect(find.byType(ChartEmptyPanel), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('legend uses a column instead of a nested ListView', (tester) async {
    await pumpChart(tester, walletStat: walletStat);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.byType(ChartEmptyPanel), findsNothing);
    expect(find.byType(ListView), findsNothing);
  });
}
