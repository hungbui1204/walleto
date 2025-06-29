import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@LazySingleton(as: Repository)
class RepositoryImpl implements Repository {
  const RepositoryImpl(this._appApiServices, this._appPreferences, this._authenticationDataMapper);

  final AppApiServices _appApiServices;
  final AppPreferences _appPreferences;
  final AuthenticationDataMapper _authenticationDataMapper;

  @override
  Future<bool> get isLoggedIn async => await _appPreferences.token != null;

  @override
  Future<Authentication> loginByPassword({required String email, required String password}) async {
    final response = await _appApiServices.loginByPassword(email: email, password: password);

    return _authenticationDataMapper.mapToEntity(response);
  }

  @override
  Future<Authentication> refreshAuthToken({required String refreshToken}) async {
    final response = await _appApiServices.refreshToken(refreshToken: refreshToken);

    return _authenticationDataMapper.mapToEntity(response);
  }

  @override
  Future<void> signOut() async {
    // TODO: sign out from the server

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
}
