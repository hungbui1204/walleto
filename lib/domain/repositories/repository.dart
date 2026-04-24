import 'package:walleto/domain/domain.dart';

abstract class Repository {
  Future<bool> get isLoggedIn;

  Future<String> get token;

  Future<String> get refreshToken;

  Future<void> setToken(String token);

  Future<void> setRefreshToken(String refreshToken);

  Future<Authentication> loginByPassword({
    required String email,
    required String password,
    required String fcmToken,
    required String timezone,
  });

  Future<Authentication> refreshAuthToken({required String refreshToken});

  Future<void> signOut();

  Future<List<Category>> getCategories();

  Future<List<Wallet>> getWallets();

  Future<List<Transaction>> getTransactions({
    int? targetMonth,
    int? targetYear,
    DateTime? fromDate,
    DateTime? toDate,
    int? walletId,
  });

  Future<void> createTransaction(Transaction transaction);

  Future<List<DailyStat>> getMonthStat({required int targetMonth, required int targetYear});

  Future<List<MonthSummaryStat>> getMonthSummaryStats({String? baseCurrency});

  Future<List<WalletStat>> getWalletStats({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  });

  Future<WalletStat> getTopWalletStats({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  });

  Future<User> getUserInfo();

  Future<AiChatMessage> sendAiChatMessage({required String message});

  Future<List<AiChatHistoryMessage>> getAiChatHistory({
    required int offset,
    required int limit,
  });

  Future<List<Transaction>> getRecentTransactions({int? walletId});

  Future<void> sendOtpForEmailChecking({required String email});

  Future<void> verifyOtpForEmail({required String email, required String otp});

  Future<void> createUserByEmail({required String email, required String password});

  Future<void> createWallet(Wallet wallet);

  Future<void> createCategory(Category category);

  Future<List<SupabaseImage>> getCategoryImages();

  Future<List<SupabaseImage>> getWalletImages();

  Future<List<Currency>> getCurrencies();

  Future<ExchangeRate> getExchangeRate({
    required String fromCurrencyCode,
    required String toCurrencyCode,
  });

  Future<void> sendOtpForResetPassword({required String email});

  Future<void> verifyOtpForResetPassword({required String email, required String code});

  Future<void> resetUserPassword({required String email, required String password});

  Future<Transaction> updateTransaction({required Transaction transaction});

  Future<Transaction> duplicateTransaction({
    required int transactionId,
    required DateTime newCreatedAt,
  });

  Future<void> deleteTransaction({required int transactionId});

  Future<void> editWallet({required Wallet wallet});

  Future<Currency> getUserDefaultCurrency();
}
