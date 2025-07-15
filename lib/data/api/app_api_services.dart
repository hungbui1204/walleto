import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

@lazySingleton
class AppApiServices {
  const AppApiServices(this._serverApiClientAuth, this._serverApiClientRest);

  final ServerApiClientAuth _serverApiClientAuth;
  final ServerApiClientRest _serverApiClientRest;

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
  }) {
    return _serverApiClientRest.request(
      method: RequestMethod.post,
      path: 'rpc/get_user_transactions',
      body: {
        if (targetMonth != null) 'target_month': targetMonth,
        if (targetYear != null) 'target_year': targetYear,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
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
}
