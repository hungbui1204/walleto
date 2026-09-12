import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockAppNavigator extends Mock implements AppNavigator {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cash = Wallet(id: 1, name: 'Cash', amount: 10, currencyCode: 'USD');
  const bank = Wallet(id: 2, name: 'Bank', amount: 20, currencyCode: 'USD');
  const total = Wallet(
    id: AppConstants.totalWalletId,
    name: 'Total',
    amount: 30,
    currencyCode: 'USD',
  );

  late _MockAppNavigator navigator;

  setUpAll(() async {
    await S.load(const Locale('en', 'US'));
  });

  setUp(() {
    navigator = _MockAppNavigator();
    when(() => navigator.pop()).thenAnswer((_) async => true);
  });

  Future<void> pumpSheet(WidgetTester tester, {required ChooseWalletBottomSheet sheet}) async {
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
                  body: RepositoryProvider<AppNavigator>.value(value: navigator, child: sheet),
                );
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('tap selects the wallet and pops', (tester) async {
    Wallet? selected;

    await pumpSheet(
      tester,
      sheet: ChooseWalletBottomSheet(
        wallets: const [cash, bank],
        currentWallet: cash,
        onWalletSelected: (wallet) => selected = wallet,
      ),
    );

    await tester.tap(find.text('Bank'));
    await tester.pump();

    expect(selected, bank);
    verify(() => navigator.pop()).called(1);
  });

  testWidgets('shows Total when includeTotalWallet is true', (tester) async {
    await pumpSheet(
      tester,
      sheet: ChooseWalletBottomSheet(
        wallets: const [total, cash],
        includeTotalWallet: true,
        onWalletSelected: (_) {},
      ),
    );

    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
  });

  testWidgets('hides Total when includeTotalWallet is false', (tester) async {
    await pumpSheet(
      tester,
      sheet: ChooseWalletBottomSheet(wallets: const [total, cash], onWalletSelected: (_) {}),
    );

    expect(find.text('Total'), findsNothing);
    expect(find.text('Cash'), findsOneWidget);
  });
}
