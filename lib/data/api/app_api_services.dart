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
  );

  final ServerApiClientAuth _serverApiClientAuth;
  final ServerApiClientRest _serverApiClientRest;
  final ServerApiFunctionsClient _serverApiFunctionsClient;

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
        'created_at': transaction.createdAt,
        'note': transaction.note,
        'user_id': transaction.userId,
        'wallet_id': transaction.walletId,
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

  Future<List<MonthSummaryStatData>?> getMonthSummaryStats() {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/get_monthly_summary',
      decoder: (data) => MonthSummaryStatData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
    );
  }

  Future<List<CategoryStatData>?> getCategoryStats({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  }) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/get_parent_category_stats',
      body: {
        'target_month': targetMonth,
        'target_year': targetYear,
        'target_type': categoryType.name,
      },
      decoder: (data) => CategoryStatData.fromJson(data as Map<String, dynamic>),
      successResponseMapperType: SuccessResponseMapperType.jsonArray,
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
}
