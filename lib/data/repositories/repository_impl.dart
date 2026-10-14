import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

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
    this._walletStatDataMapper,
    this._userDataMapper,
    this._aiChatStreamEventDataMapper,
    this._aiChatHistoryMessageDataMapper,
    this._supabaseImageDataMapper,
    this._currencyDataMapper,
    this._exchangeRateDataMapper,
    this._biometricLoginDeviceDataMapper,
    this._biometricAuthenticationService,
    this._authSessionCoordinator,
  );

  final AppApiServices _appApiServices;
  final AppPreferences _appPreferences;
  final AuthenticationDataMapper _authenticationDataMapper;
  final CategoryDataMapper _categoryDataMapper;
  final WalletDataMapper _walletDataMapper;
  final TransactionDataMapper _transactionDataMapper;
  final DailyStatDataMapper _dailyStatDataMapper;
  final MonthSummaryStatDataMapper _monthSummaryStatDataMapper;
  final UserDataMapper _userDataMapper;
  final AiChatStreamEventDataMapper _aiChatStreamEventDataMapper;
  final AiChatHistoryMessageDataMapper _aiChatHistoryMessageDataMapper;
  final SupabaseImageDataMapper _supabaseImageDataMapper;
  final CurrencyDataMapper _currencyDataMapper;
  final ExchangeRateDataMapper _exchangeRateDataMapper;
  final BiometricLoginDeviceDataMapper _biometricLoginDeviceDataMapper;
  final BiometricAuthenticationService _biometricAuthenticationService;
  final AuthSessionCoordinator _authSessionCoordinator;
  final WalletStatDataMapper _walletStatDataMapper;

  @override
  Future<AppThemePreference> getAppThemePreference() async {
    final value = await _appPreferences.appThemePreference;

    return switch (value) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.dark,
    };
  }

  @override
  Future<void> setAppThemePreference(AppThemePreference preference) async {
    await _appPreferences.setAppThemePreference(preference.name);
  }

  @override
  Future<bool> get isLoggedIn async {
    final token = await _appPreferences.token;
    final refreshToken = await _appPreferences.refreshToken;
    final userId = await _appPreferences.userId;
    return token != null &&
        token.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty;
  }

  @override
  Future<DateTime?> get sessionExpiresAt => _appPreferences.sessionExpiresAt;

  @override
  Future<Authentication> loginByPassword({
    required String email,
    required String password,
    required String fcmToken,
    required String timezone,
  }) async {
    return _authSessionCoordinator.runExclusive(() async {
      final response = await _appApiServices.loginByPassword(email: email, password: password);
      final authInfo = _authenticationDataMapper.mapToEntity(response);
      final linkedUserId = await _appPreferences.biometricLoginUserId;
      if (linkedUserId != null && linkedUserId != authInfo.user.id) {
        // Drop the previous account association before loading or showing the new user's data.
        await _appPreferences.clearBiometricLogin();
      } else if (linkedUserId == authInfo.user.id) {
        await _appPreferences.clearBiometricCredential();
      }
      await _appPreferences.saveSession(authInfo);

      await _appApiServices.updateUserFcmTokenAndTimeZone(
        fcmToken: fcmToken,
        timezone: timezone,
        userId: authInfo.user.id,
      );

      return authInfo;
    });
  }

  @override
  Future<Authentication> refreshAuthToken({required String refreshToken}) async {
    final response = await _appApiServices.refreshToken(refreshToken: refreshToken);
    final authentication = _authenticationDataMapper.mapToEntity(response);
    final currentRefreshToken = await _appPreferences.refreshToken;
    if (currentRefreshToken != refreshToken) {
      throw const AppUncaughtException('Session changed while refresh was in flight');
    }
    await _appPreferences.saveSession(authentication);
    return authentication;
  }

  @override
  Future<SignOutResult> signOut() {
    return _authSessionCoordinator.runExclusive(() async {
      final currentUserId = await _appPreferences.userId ?? '';
      final refreshToken = await _appPreferences.refreshToken ?? '';
      var accessToken = await _appPreferences.token ?? '';
      final keepBiometricLogin =
          await _appPreferences.isBiometricLoginEnabled &&
          currentUserId.isNotEmpty &&
          await _appPreferences.biometricLoginUserId == currentUserId;

      if (keepBiometricLogin && refreshToken.isNotEmpty) {
        await _appPreferences.setBiometricTransferPending(true);
        try {
          await _appPreferences.clearBiometricCredential();
          await _appPreferences.writeBiometricRefreshToken(refreshToken);
          await _appPreferences.markBiometricCredentialPresent();
          await _appPreferences.clearSession();
          await _appPreferences.setBiometricTransferPending(false);
          return const SignOutResult(retainedForBiometric: true);
        } on Object catch (error, stackTrace) {
          Log.e(error, stackTrace: stackTrace, name: 'Biometric session transfer failed');
          await _appPreferences.clearSession();
          await _appPreferences.clearBiometricLogin();
          await _appPreferences.setBiometricTransferPending(false);
          return const SignOutResult();
        }
      }

      var serverSessionRevoked = false;
      final expiresAt = await _appPreferences.sessionExpiresAt;
      if (accessToken.isNotEmpty &&
          (expiresAt == null ||
              !expiresAt.isAfter(DateTime.now().add(AuthSessionConstants.refreshSafetyWindow)))) {
        try {
          final authentication = await refreshAuthToken(refreshToken: refreshToken);
          accessToken = authentication.accessToken;
        } on Object catch (error, stackTrace) {
          Log.e(error, stackTrace: stackTrace, name: 'Session refresh before sign-out failed');
        }
      }
      if (accessToken.isNotEmpty) {
        try {
          await _appApiServices.revokeRefreshToken(accessToken: accessToken);
          serverSessionRevoked = true;
        } on Object catch (error, stackTrace) {
          Log.e(error, stackTrace: stackTrace, name: 'Supabase local session revocation failed');
        }
      }

      await _appPreferences.clearSession();
      await _appPreferences.clearBiometricLogin();
      return SignOutResult(serverSessionRevoked: serverSessionRevoked);
    });
  }

  @override
  Future<void> clearInvalidSession() async {
    await _appPreferences.clearSession();
    await _appPreferences.clearBiometricLogin();
  }

  @override
  Future<BiometricLoginStatus> getBiometricLoginStatus({
    String? userId,
    required bool verifyServer,
  }) async {
    final isAvailable = await _biometricAuthenticationService.isAvailable;
    final localEnabled = await _appPreferences.isBiometricLoginEnabled;
    final localUserId = await _appPreferences.biometricLoginUserId;
    final credentialPresent = await _appPreferences.biometricCredentialPresent;
    final installationId = await _appPreferences.getInstallationId();
    final activeAccessToken = await _appPreferences.token;
    final activeRefreshToken = await _appPreferences.refreshToken;
    final activeUserId = await _appPreferences.userId;
    final hasStoredSession =
        activeAccessToken != null &&
        activeAccessToken.isNotEmpty &&
        activeRefreshToken != null &&
        activeRefreshToken.isNotEmpty &&
        activeUserId != null &&
        activeUserId.isNotEmpty;

    if (userId != null && localUserId != null && userId != localUserId) {
      await _appPreferences.clearBiometricLogin();
      return BiometricLoginStatus(isAvailable: isAvailable, hasStoredSession: hasStoredSession);
    }

    if (!verifyServer) {
      return BiometricLoginStatus(
        isAvailable: isAvailable,
        isEnabled: isAvailable && localEnabled && credentialPresent && localUserId != null,
        hasStoredSession: hasStoredSession,
      );
    }

    final targetUserId = userId ?? localUserId;
    if (targetUserId == null || targetUserId.isEmpty) {
      return BiometricLoginStatus(isAvailable: isAvailable, hasStoredSession: hasStoredSession);
    }

    final serverRows = await _appApiServices.getBiometricLoginDevices(
      userId: targetUserId,
      installationId: installationId,
    );
    final serverEnabled = _biometricLoginDeviceDataMapper
        .mapToListEntity(serverRows)
        .any(
          (device) =>
              device.userId == targetUserId &&
              device.installationId == installationId &&
              device.enabled,
        );
    final hasActiveCredential =
        activeUserId == targetUserId && activeRefreshToken != null && activeRefreshToken.isNotEmpty;
    final isEnabled =
        isAvailable &&
        localEnabled &&
        (credentialPresent || hasActiveCredential) &&
        localUserId == targetUserId &&
        serverEnabled;

    if (!isEnabled && localEnabled && (!serverEnabled || !isAvailable)) {
      await _appPreferences.clearBiometricLogin();
    }

    return BiometricLoginStatus(
      isAvailable: isAvailable,
      isEnabled: isEnabled,
      hasStoredSession: hasStoredSession,
    );
  }

  @override
  Future<void> setBiometricLoginEnabled({
    required String userId,
    required bool enabled,
    String? password,
  }) {
    return _authSessionCoordinator.runExclusive(() async {
      final currentUserId = await _appPreferences.userId ?? '';
      final installationId = await _appPreferences.getInstallationId();
      if (!enabled) {
        if (currentUserId != userId) {
          throw const AppUncaughtException('The active account changed');
        }
        await _appApiServices.setBiometricLoginDeviceEnabled(
          userId: userId,
          installationId: installationId,
          enabled: false,
        );
        await _appPreferences.clearBiometricLogin();
        return;
      }

      if (password == null || password.isEmpty || currentUserId != userId) {
        throw const AppUncaughtException('Password re-authentication is required');
      }
      if (!await _biometricAuthenticationService.isAvailable) {
        throw const AppUncaughtException('Strong biometric authentication is unavailable');
      }

      final email = await _appPreferences.userEmail ?? '';
      if (email.isEmpty) throw const AppUncaughtException('The active account email is missing');

      final response = await _appApiServices.loginByPassword(email: email, password: password);
      final authentication = _authenticationDataMapper.mapToEntity(response);
      if (authentication.user.id != userId) {
        await _tryRevokeTemporarySession(authentication.accessToken);
        throw const AppUncaughtException('Password re-authentication returned another account');
      }

      // Password grant may replace the prior Supabase session; the new valid session stays active
      // even if enabling biometric sign-in later fails.
      await _appPreferences.saveSession(authentication);
      var rowWasEnabled = false;
      try {
        final probe = const Uuid().v4();
        await _appPreferences.writeBiometricProbe(probe);
        final protectedProbe = await _appPreferences.readBiometricProbe();
        await _appPreferences.clearBiometricProbe();
        if (protectedProbe != probe) {
          throw const AppUncaughtException('Biometric credential protection could not be verified');
        }

        await _appApiServices.upsertBiometricLoginDevice(
          userId: userId,
          installationId: installationId,
          enabled: true,
          accessToken: authentication.accessToken,
        );
        rowWasEnabled = true;
        await _appPreferences.setBiometricLogin(enabled: true, userId: userId);
      } on Object {
        await _appPreferences.clearBiometricProbe();
        if (rowWasEnabled) {
          try {
            await _appApiServices.setBiometricLoginDeviceEnabled(
              userId: userId,
              installationId: installationId,
              enabled: false,
            );
          } on Object {
            // Local state remains off; the next Account load reconciles with the server.
          }
        }
        await _appPreferences.clearBiometricLogin();
        rethrow;
      }
    });
  }

  @override
  Future<Authentication> loginWithBiometrics() {
    return _authSessionCoordinator.runExclusive(() async {
      final localEnabled = await _appPreferences.isBiometricLoginEnabled;
      final linkedUserId = await _appPreferences.biometricLoginUserId ?? '';
      if (!localEnabled ||
          linkedUserId.isEmpty ||
          !await _biometricAuthenticationService.isAvailable) {
        throw const AppUncaughtException('Biometric sign-in is unavailable');
      }

      final refreshToken = await _appPreferences.readBiometricRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _appPreferences.clearBiometricLogin();
        throw const AppUncaughtException('Biometric credential is unavailable');
      }

      AuthenticationData? response;
      try {
        response = await _appApiServices.refreshToken(refreshToken: refreshToken);
      } on RemoteException catch (error) {
        if (_isRejectedRefreshToken(error)) {
          await _appPreferences.clearBiometricLogin();
        }
        rethrow;
      }
      final authentication = _authenticationDataMapper.mapToEntity(response);
      if (authentication.user.id != linkedUserId) {
        await _tryRevokeTemporarySession(authentication.accessToken);
        await _appPreferences.clearBiometricLogin();
        throw const AppUncaughtException('Biometric credential belongs to another account');
      }

      _validateAuthentication(authentication);

      // Supabase rotates refresh tokens. Save the new protected credential before any follow-up API.
      try {
        await _appPreferences.writeBiometricRefreshToken(authentication.refreshToken);
      } on Object {
        // The old refresh token has already been consumed. Do not offer a dead credential again.
        await _appPreferences.clearBiometricLogin();
        rethrow;
      }
      final installationId = await _appPreferences.getInstallationId();
      final serverRows = await _appApiServices.getBiometricLoginDevices(
        userId: linkedUserId,
        installationId: installationId,
        accessToken: authentication.accessToken,
      );
      final isServerEnabled = _biometricLoginDeviceDataMapper
          .mapToListEntity(serverRows)
          .any(
            (device) =>
                device.userId == linkedUserId &&
                device.installationId == installationId &&
                device.enabled,
          );
      if (!isServerEnabled) {
        await _tryRevokeTemporarySession(authentication.accessToken);
        await _appPreferences.clearBiometricLogin();
        throw const AppUncaughtException('Biometric sign-in was disabled for this device');
      }

      await _appPreferences.setBiometricTransferPending(true);
      try {
        await _appPreferences.saveSession(authentication);
        await _appPreferences.clearBiometricCredential();
        await _appPreferences.setBiometricTransferPending(false);
      } on Object {
        await _appPreferences.clearSession();
        await _appPreferences.clearBiometricLogin();
        await _appPreferences.setBiometricTransferPending(false);
        rethrow;
      }
      return authentication;
    });
  }

  Future<void> _tryRevokeTemporarySession(String accessToken) async {
    if (accessToken.isEmpty) return;
    try {
      await _appApiServices.revokeRefreshToken(accessToken: accessToken);
    } on Object catch (error, stackTrace) {
      Log.e(error, stackTrace: stackTrace, name: 'Temporary Supabase session revocation failed');
    }
  }

  void _validateAuthentication(Authentication authentication) {
    final expiresAt =
        authentication.expiresAt ??
        (authentication.expiresIn > 0
            ? DateTime.now().add(Duration(seconds: authentication.expiresIn))
            : null);
    if (authentication.accessToken.isEmpty ||
        authentication.refreshToken.isEmpty ||
        authentication.user.id.isEmpty ||
        expiresAt == null ||
        !expiresAt.isAfter(DateTime.now())) {
      throw const AppUncaughtException('Supabase returned an incomplete or expired session');
    }
  }

  bool _isRejectedRefreshToken(RemoteException error) {
    return AuthSessionConstants.isRejectedRefreshToken(
      httpStatusCode: error.httpErrorCode,
      errorCode: error.generalServerErrorId,
    );
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
  Future<List<MonthSummaryStat>> getMonthSummaryStats({String? baseCurrency}) async {
    final response = await _appApiServices.getMonthSummaryStats(baseCurrency: baseCurrency);

    return _monthSummaryStatDataMapper.mapToListEntity(response);
  }

  @override
  Future<List<WalletStat>> getWalletStats({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  }) async {
    final response = await _appApiServices.getWalletStats(
      targetMonth: targetMonth,
      targetYear: targetYear,
      categoryType: categoryType,
    );

    return _walletStatDataMapper.mapToListEntity(response);
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
  Future<void> createUserByEmail({
    required String email,
    required String password,
    required String code,
  }) async {
    await _appApiServices.createUserByEmail(email: email, password: password, code: code);
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

  @override
  Future<List<Currency>> getCurrencies() async {
    final response = await _appApiServices.getCurrencies();

    return _currencyDataMapper.mapToListEntity(response);
  }

  @override
  Future<ExchangeRate> getExchangeRate({
    required String fromCurrencyCode,
    required String toCurrencyCode,
  }) async {
    final response = await _appApiServices.getExchangeRate(
      fromCurrency: fromCurrencyCode,
      toCurrency: toCurrencyCode,
    );

    return _exchangeRateDataMapper.mapToEntity(response);
  }

  @override
  Future<void> sendOtpForResetPassword({required String email}) async {
    await _appApiServices.sendOtpForResetPassword(email: email);
  }

  @override
  Future<void> verifyOtpForResetPassword({required String email, required String code}) async {
    await _appApiServices.verifyOtpForResetPassword(email: email, code: code);
  }

  @override
  Future<void> resetUserPassword({
    required String email,
    required String password,
    required String code,
  }) async {
    await _appApiServices.resetUserPassword(email: email, password: password, code: code);
  }

  @override
  Future<Transaction> updateTransaction({required Transaction transaction}) async {
    final transactionData = _transactionDataMapper.mapToData(transaction);
    final response = await _appApiServices.updateTransaction(transaction: transactionData);

    return _transactionDataMapper.mapToEntity(response);
  }

  @override
  Future<void> deleteTransaction({required int transactionId}) async {
    await _appApiServices.deleteTransaction(transactionId: transactionId);
  }

  @override
  Future<Transaction> duplicateTransaction({
    required int transactionId,
    required DateTime newCreatedAt,
  }) async {
    final response = await _appApiServices.duplicateTransaction(
      transactionId: transactionId,
      newCreatedAt: newCreatedAt,
    );

    return _transactionDataMapper.mapToEntity(response);
  }

  @override
  Future<void> editWallet({required Wallet wallet}) async {
    final walletData = _walletDataMapper.mapToData(wallet);

    await _appApiServices.editWallet(wallet: walletData);
  }

  @override
  Future<WalletStat> getTopWalletStats({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  }) async {
    final response = await _appApiServices.getTopWalletStats(
      targetMonth: targetMonth,
      targetYear: targetYear,
      categoryType: categoryType,
    );

    return _walletStatDataMapper.mapToEntity(response);
  }

  @override
  Future<Currency> getUserDefaultCurrency() async {
    final response = await _appApiServices.getUserDefaultCurrency();

    return _currencyDataMapper.mapToEntity(response);
  }

  @override
  Future<void> updateUserDefaultCurrency({required String currencyCode}) async {
    final userId = await _appPreferences.userId ?? '';
    await _appApiServices.updateUserDefaultCurrency(userId: userId, currencyCode: currencyCode);
  }

  @override
  Stream<AiChatStreamEvent> sendAiChatMessage({
    required String message,
    AppCancelToken? cancelToken,
  }) {
    return _appApiServices
        .sendAiChatMessage(message: message, cancelToken: cancelToken)
        .map(_aiChatStreamEventDataMapper.mapToEntity);
  }

  @override
  Future<List<AiChatMessage>> getAiChatHistory({required int offset, required int limit}) async {
    final response = await _appApiServices.getAiChatHistory(offset: offset, limit: limit);

    return _aiChatHistoryMessageDataMapper.mapToListEntity(response);
  }
}
