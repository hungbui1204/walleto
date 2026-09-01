import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@lazySingleton
class AppApiServices {
  const AppApiServices(
    this._serverApiClientAuth,
    this._serverApiClientRest,
    this._serverApiFunctionsClient,
    this._serverApiClientStorage,
  );

  final ServerApiClientAuth _serverApiClientAuth;
  final ServerApiClientRest _serverApiClientRest;
  final ServerApiFunctionsClient _serverApiFunctionsClient;
  final ServerApiClientStorage _serverApiClientStorage;

  Future<AuthenticationData?> loginByPassword({required String email, required String password}) {
    return _serverApiClientAuth.request(
      method: RequestMethod.post,
      path: 'token',
      queryParameters: {'grant_type': 'password'},
      body: {'email': email, 'password': password},
      decoder: (data) => AuthenticationData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonObject,
    );
  }

  Future<void> updateUserFcmTokenAndTimeZone({
    required String fcmToken,
    required String timezone,
    required String userId,
  }) {
    return _serverApiClientRest.request(
      method: RequestMethod.patch,
      path: 'profiles',
      queryParameters: {'id': 'eq.$userId'},
      body: {'fcm_token': fcmToken, 'timezone': timezone},
    );
  }

  Future<AuthenticationData?> refreshToken({required String refreshToken}) {
    return _serverApiClientAuth.request(
      method: RequestMethod.post,
      path: 'token',
      queryParameters: {'grant_type': 'refresh_token'},
      body: {'refresh_token': refreshToken},
      decoder: (data) => AuthenticationData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> revokeRefreshToken() {
    return _serverApiClientAuth.request(
      method: RequestMethod.post,
      path: 'logout',
      options: Options(extra: {ServerRequestResponseConstants.revokeRefreshToken: true}),
    );
  }

  Future<List<CategoryData>?> getCategories() {
    return _serverApiClientRest.request(
      method: RequestMethod.get,
      path: 'categories',
      queryParameters: {'is_system': 'eq.false'},
      decoder: (data) => CategoryData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<List<WalletData>?> getWallets() {
    return _serverApiClientRest.request(
      method: RequestMethod.get,
      path: 'wallets',
      decoder: (data) => WalletData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<List<TransactionData>?> getTransactions({
    int? targetMonth,
    int? targetYear,
    DateTime? fromDate,
    DateTime? toDate,
    int? walletId,
  }) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/get_user_transactions',
      body: {
        if (targetMonth != null) 'target_month': targetMonth,
        if (targetYear != null) 'target_year': targetYear,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        if (walletId != null) 'wallet_id': walletId,
      },
      decoder: (data) => TransactionData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<void> createTransaction(TransactionData transaction) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'transactions',
      body: {
        'amount': transaction.amount,
        'category_id': transaction.categoryId,
        'transaction_date': transaction.transactionDate,
        'note': transaction.note,
        'user_id': transaction.userId,
        'wallet_id': transaction.walletId,
        'currency_code': transaction.currencyCode,
      },
    );
  }

  Future<List<DailyStatData>?> getDailyStats({required int targetMonth, required int targetYear}) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/get_daily_stats',
      body: {'month': targetMonth, 'year': targetYear},
      decoder: (data) => DailyStatData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<List<MonthSummaryStatData>?> getMonthSummaryStats({String? baseCurrency}) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/get_monthly_summary',
      body: {if (baseCurrency != null) 'base_currency': baseCurrency},
      decoder: (data) => MonthSummaryStatData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<List<WalletStatData>?> getWalletStats({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  }) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/get_wallet_stats_with_parent_category',
      body: {
        'target_month': targetMonth,
        'target_year': targetYear,
        'target_type': const CategoryTypeDataMapper().mapToData(categoryType),
      },
      decoder: (data) => WalletStatData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<WalletStatData?> getTopWalletStats({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  }) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/get_top_wallet_stats',
      body: {
        'target_month': targetMonth,
        'target_year': targetYear,
        'target_type': const CategoryTypeDataMapper().mapToData(categoryType),
      },
      decoder: (data) => WalletStatData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<UserData>?> getUserInfo({required String userId}) {
    return _serverApiClientRest.request(
      method: RequestMethod.get,
      path: 'profiles',
      queryParameters: {'id': 'eq.$userId'},
      decoder: (data) => UserData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<List<TransactionData>?> getRecentTransactions({int? walletId}) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/get_recent_transactions',
      body: {if (walletId != null) 'wallet_id': walletId},
      decoder: (data) => TransactionData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<void> sendOtpForEmailChecking({required String email}) {
    return _serverApiFunctionsClient.request(
      method: RequestMethod.post,
      path: '/send_otp',
      body: {'email': email},
    );
  }

  Future<void> verifyOtpForEmail({required String email, required String code}) {
    return _serverApiFunctionsClient.request(
      method: RequestMethod.post,
      path: '/otp_verify',
      body: {'email': email, 'code': code},
    );
  }

  Future<void> createUserByEmail({required String email, required String password}) {
    return _serverApiFunctionsClient.request(
      method: RequestMethod.post,
      path: '/create_user',
      body: {'email': email, 'password': password},
    );
  }

  Future<void> createWallet(WalletData wallet) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'wallets',
      body: {
        'user_id': wallet.userId,
        'name': wallet.name,
        'amount': wallet.amount,
        'currency_code': wallet.currencyCode,
        'icon_url': wallet.iconUrl,
      },
    );
  }

  Future<void> createCategory(CategoryData category) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'categories',
      body: {
        'user_id': category.userId,
        'name': category.name,
        'icon_url': category.iconUrl,
        'type': category.type,
        'parent_id': category.parentId,
        'is_parent': category.isParent,
      },
    );
  }

  Future<List<SupabaseImageData>?> getCategoryImages() {
    return _serverApiClientStorage.request(
      method: RequestMethod.post,
      path: 'category-images',
      body: {"limit": "100", "offset": "0", "prefix": null},
      decoder: (data) => SupabaseImageData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<List<SupabaseImageData>?> getWalletImages() {
    return _serverApiClientStorage.request(
      method: RequestMethod.post,
      path: 'wallet-images',
      body: {"limit": "100", "offset": "0", "prefix": null},
      decoder: (data) => SupabaseImageData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<List<CurrencyData>?> getCurrencies() {
    return _serverApiClientRest.request(
      method: RequestMethod.get,
      path: 'currencies',
      decoder: (data) => CurrencyData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<ExchangeRateData?> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    return _serverApiClientRest.request(
      method: RequestMethod.get,
      path: 'rpc/get_exchange_rate',
      queryParameters: {'p_from_currency': fromCurrency, 'p_to_currency': toCurrency},
      decoder: (data) => ExchangeRateData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> sendOtpForResetPassword({required String email}) {
    return _serverApiFunctionsClient.request(
      method: RequestMethod.post,
      path: '/send_otp_reset_password',
      body: {'email': email},
    );
  }

  Future<void> verifyOtpForResetPassword({required String email, required String code}) {
    return _serverApiFunctionsClient.request(
      method: RequestMethod.post,
      path: '/otp_verify_reset_password',
      body: {'email': email, 'code': code},
    );
  }

  Future<void> resetUserPassword({required String email, required String password}) {
    return _serverApiFunctionsClient.request(
      method: RequestMethod.post,
      path: '/reset_user_password',
      body: {'email': email, 'password': password},
    );
  }

  Future<TransactionData?> updateTransaction({required TransactionData transaction}) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/update_transaction',
      body: {
        'p_id': transaction.id,
        'p_amount': transaction.amount,
        'p_category_id': transaction.categoryId,
        'p_note': transaction.note,
        'p_currency_code': transaction.currencyCode,
        'p_wallet_id': transaction.walletId,
        'p_transaction_date': transaction.transactionDate,
      },
      decoder: (data) => TransactionData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<TransactionData?> duplicateTransaction({
    required int transactionId,
    required DateTime newCreatedAt,
  }) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/duplicate_transaction',
      body: {'p_id': transactionId, 'p_new_transaction_date': newCreatedAt.toIso8601String()},
      decoder: (data) => TransactionData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteTransaction({required int transactionId}) {
    return _serverApiClientRest.request(
      method: RequestMethod.delete,
      path: 'transactions',
      queryParameters: {'id': 'eq.$transactionId'},
    );
  }

  Future<void> editWallet({required WalletData wallet}) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/update_wallet',
      body: {
        'p_wallet_id': wallet.id,
        'p_name': wallet.name,
        'p_icon_url': wallet.iconUrl,
        'p_new_amount': wallet.amount,
      },
    );
  }

  Future<CurrencyData?> getUserDefaultCurrency() {
    return _serverApiClientRest.request(
      method: RequestMethod.get,
      path: 'rpc/get_user_base_currency',
      decoder: (data) => CurrencyData.fromJson(data as Map<String, dynamic>),
    );
  }
}
