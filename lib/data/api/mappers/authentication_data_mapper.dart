import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class AuthenticationDataMapper extends BaseDataMapper<AuthenticationData, Authentication> {
  const AuthenticationDataMapper(this._userDataMapper);

  final UserDataMapper _userDataMapper;

  @override
  Authentication mapToEntity(AuthenticationData? data) {
    return Authentication(
      user: _userDataMapper.mapToEntity(data?.user),
      accessToken: data?.accessToken ?? '',
      refreshToken: data?.refreshToken ?? '',
      expiresIn: data?.expiresIn ?? 0,
      expiresAt: data?.expiresAt?.toDateTime(),
    );
  }
}
