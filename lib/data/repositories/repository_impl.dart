import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@LazySingleton(as: Repository)
class RepositoryImpl implements Repository {
  const RepositoryImpl(this._appPreferences);

  final AppPreferences _appPreferences;
  
  @override
  Future<bool> get isLoggedIn async => await _appPreferences.isLoggedIn;
  
  @override
  Future<void> signIn({required String email,required String password}) {
    // TODO: implement signIn
    throw UnimplementedError();
  }
  
  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }
}