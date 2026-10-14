import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class BiometricLoginDeviceDataMapper
    extends BaseDataMapper<BiometricLoginDeviceData, BiometricLoginDevice> {
  const BiometricLoginDeviceDataMapper();

  @override
  BiometricLoginDevice mapToEntity(BiometricLoginDeviceData? data) {
    return BiometricLoginDevice(
      userId: data?.userId ?? '',
      installationId: data?.installationId ?? '',
      enabled: data?.enabled ?? false,
      updatedAt: DateTime.tryParse(data?.updatedAt ?? ''),
    );
  }
}
