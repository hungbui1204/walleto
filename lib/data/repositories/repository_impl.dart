import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@LazySingleton(as: Repository)
class RepositoryImpl implements Repository {
  const RepositoryImpl(
    this._appApiServices,
    this._appPreferences,
    this._authenticationDataMapper,
    this._categoryDataMapper,
    this._walletDataMapper,
    this._transactionDataMapper,
    this._dailyStatDataMapper,
    this._monthSummaryStatDataMapper,
    this._categoryStatDataMapper,
    this._userDataMapper,
    this._supabaseImageDataMapper,
  );

  final AppApiServices _appApiServices;
  final AppPreferences _appPreferences;
  final AuthenticationDataMapper _authenticationDataMapper;
  final CategoryDataMapper _categoryDataMapper;
  final WalletDataMapper _walletDataMapper;
  final TransactionDataMapper _transactionDataMapper;
  final DailyStatDataMapper _dailyStatDataMapper;
  final MonthSummaryStatDataMapper _monthSummaryStatDataMapper;
  final CategoryStatDataMapper _categoryStatDataMapper;
  final UserDataMapper _userDataMapper;
  final SupabaseImageDataMapper _supabaseImageDataMapper;

  @override
  Future<bool> get isLoggedIn async => await _appPreferences.token != null;

  @override
  Future<Authentication> loginByPassword({
    required String email,
    required String password,
    required String fcmToken,
    required String timezone,
  }) async {
    final response = await _appApiServices.loginByPassword(email: email, password: password);
    final authInfo = _authenticationDataMapper.mapToEntity(response);

    // Save the authentication data to secure storage
    await _appPreferences.setToken(response?.accessToken ?? '');
    await _appPreferences.setRefreshToken(response?.refreshToken ?? '');
    await _appPreferences.setUserId(response?.user?.id ?? '');

    // Update the user's FCM token and timezone
    await _appApiServices.updateUserFcmTokenAndTimeZone(
      fcmToken: fcmToken,
      timezone: timezone,
      userId: authInfo.user.id,
    );

    return authInfo;
  }

  @override
  Future<Authentication> refreshAuthToken({required String refreshToken}) async {
    final response = await _appApiServices.refreshToken(refreshToken: refreshToken);

    // Save the new access token to secure storage
    await _appPreferences.setToken(response?.accessToken ?? '');

    return _authenticationDataMapper.mapToEntity(response);
  }

  @override
  Future<void> signOut() async {
    // Revoke the current refresh token
    // Not using at the moment, because the refresh token is not a jwt token
    // Consider using it in the future if needed
    // await _appApiServices.revokeRefreshToken();

    // Clear the current user data from secure storage
    await _appPreferences.clearCurrentUserData();
  }

  @override
  Future<String> get refreshToken async => await _appPreferences.refreshToken ?? '';

  @override
  Future<void> setRefreshToken(String refreshToken) async {
    await _appPreferences.setRefreshToken(refreshToken);
  }

  @override
  Future<void> setToken(String token) async {
    await _appPreferences.setToken(token);
  }

  @override
  Future<String> get token async => await _appPreferences.token ?? '';

  @override
  Future<List<Category>> getCategories() async {
    final response = await _appApiServices.getCategories();

    return _categoryDataMapper.mapToListEntity(response);
  }

  @override
  Future<List<Transaction>> getTransactions({
    int? targetMonth,
    int? targetYear,
    DateTime? fromDate,
    DateTime? toDate,
    int? walletId,
  }) async {
    final response = await _appApiServices.getTransactions(
      targetMonth: targetMonth,
      targetYear: targetYear,
      fromDate: fromDate,
      toDate: toDate,
      walletId: walletId,
    );

    return _transactionDataMapper.mapToListEntity(response);
  }

  @override
  Future<List<Wallet>> getWallets() async {
    final response = await _appApiServices.getWallets();

    return _walletDataMapper.mapToListEntity(response);
  }

  @override
  Future<void> createTransaction(Transaction transaction) async {
    final userId = await _appPreferences.userId ?? '';
    final transactionData = _transactionDataMapper.mapToData(transaction.copyWith(userId: userId));

    await _appApiServices.createTransaction(transactionData);
  }

  @override
  Future<List<DailyStat>> getMonthStat({required int targetMonth, required int targetYear}) async {
    final response = await _appApiServices.getDailyStats(
      targetMonth: targetMonth,
      targetYear: targetYear,
    );

    return _dailyStatDataMapper.mapToListEntity(response);
  }

  @override
  Future<List<MonthSummaryStat>> getMonthSummaryStats() async {
    final response = await _appApiServices.getMonthSummaryStats();

    return _monthSummaryStatDataMapper.mapToListEntity(response);
  }

  @override
  Future<List<CategoryStat>> getCategoryStats({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  }) async {
    final response = await _appApiServices.getCategoryStats(
      targetMonth: targetMonth,
      targetYear: targetYear,
      categoryType: categoryType,
    );

    return _categoryStatDataMapper.mapToListEntity(response);
  }

  @override
  Future<User> getUserInfo() async {
    final userId = await _appPreferences.userId ?? '';
    final response = await _appApiServices.getUserInfo(userId: userId);

    return _userDataMapper.mapToEntity(response?.first);
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int? walletId}) async {
    final response = await _appApiServices.getRecentTransactions(walletId: walletId);

    return _transactionDataMapper.mapToListEntity(response);
  }

  @override
  Future<void> sendOtpForEmailChecking({required String email}) async {
    await _appApiServices.sendOtpForEmailChecking(email: email);
  }

  @override
  Future<void> createUserByEmail({required String email, required String password}) async {
    await _appApiServices.createUserByEmail(email: email, password: password);
  }

  @override
  Future<void> verifyOtpForEmail({required String email, required String otp}) async {
    await _appApiServices.verifyOtpForEmail(email: email, code: otp);
  }

  @override
  Future<void> createWallet(Wallet wallet) async {
    final userId = await _appPreferences.userId ?? '';
    final walletData = _walletDataMapper.mapToData(wallet.copyWith(userId: userId));
    await _appApiServices.createWallet(walletData);
  }

  @override
  Future<void> createCategory(Category category) async {
    final userId = await _appPreferences.userId ?? '';
    final categoryData = _categoryDataMapper.mapToData(category.copyWith(userId: userId));
    await _appApiServices.createCategory(categoryData);
  }

  @override
  Future<List<SupabaseImage>> getCategoryImages() async {
    final response = await _appApiServices.getCategoryImages();

    return _supabaseImageDataMapper.mapToListEntity(response);
  }

  @override
  Future<List<SupabaseImage>> getWalletImages() async {
    final response = await _appApiServices.getWalletImages();

    return _supabaseImageDataMapper.mapToListEntity(response);
  }
}
