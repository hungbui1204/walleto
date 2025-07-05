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
  );

  final AppApiServices _appApiServices;
  final AppPreferences _appPreferences;
  final AuthenticationDataMapper _authenticationDataMapper;
  final CategoryDataMapper _categoryDataMapper;
  final WalletDataMapper _walletDataMapper;
  final TransactionDataMapper _transactionDataMapper;

  @override
  Future<bool> get isLoggedIn async => await _appPreferences.token != null;

  @override
  Future<Authentication> loginByPassword({required String email, required String password}) async {
    final response = await _appApiServices.loginByPassword(email: email, password: password);

    // Save the authentication data to secure storage
    await _appPreferences.setToken(response?.accessToken ?? '');
    await _appPreferences.setRefreshToken(response?.refreshToken ?? '');

    return _authenticationDataMapper.mapToEntity(response);
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
  Future<List<Transaction>> getTransactions() async {
    final response = await _appApiServices.getTransactions();

    return _transactionDataMapper.mapToListEntity(response);
  }

  @override
  Future<List<Wallet>> getWallets() async {
    final response = await _appApiServices.getWallets();

    return _walletDataMapper.mapToListEntity(response);
  }
}
