import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class UserDataMapper extends BaseDataMapper<UserData, User> {
  const UserDataMapper();

  @override
  User mapToEntity(UserData? data) {
    return User(
      id: data?.id ?? '',
      email: data?.email ?? '',
      fullName: data?.fullName ?? '',
      phoneNumber: data?.phoneNumber ?? '',
      avatarUrl: data?.avatarUrl ?? '',
      createdAt: data?.createdAt?.toDateTime(),
      updatedAt: data?.updatedAt?.toDateTime(),
    );
  }
}
