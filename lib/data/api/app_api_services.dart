import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';

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
}
