import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';

@lazySingleton
class AppApiServices {
  const AppApiServices(this._serverApiClientAuth, this._serverApiClientRest);

  final ServerApiClientAuth _serverApiClientAuth;
  final ServerApiClientRest _serverApiClientRest;
}
