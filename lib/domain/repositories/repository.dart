import 'package:walleto/domain/domain.dart';

abstract class Repository {
  Future<bool> get isLoggedIn;

  Future<String> get token;

  Future<String> get refreshToken;

  Future<void> setToken(String token);

  Future<void> setRefreshToken(String refreshToken);

  Future<Authentication> loginByPassword({required String email, required String password});

  Future<Authentication> refreshAuthToken({required String refreshToken});

  Future<void> signOut();

  Future<List<Category>> getCategories();

  Future<List<Wallet>> getWallets();

  Future<List<Transaction>> getTransactions({
    int? targetMonth,
    int? targetYear,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<void> createTransaction(Transaction transaction);

  Future<List<DailyStat>> getMonthStat({required int targetMonth, required int targetYear});
}
