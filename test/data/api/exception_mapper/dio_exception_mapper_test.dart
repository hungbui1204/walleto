import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

void main() {
  final mapper = DioExceptionMapper(
    BaseErrorResponseMapper.fromType(ErrorResponseMapperType.jsonObject),
  );

  test('maps transform timeouts to timeout remote exceptions', () {
    final exception = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.transformTimeout,
    );

    final result = mapper.map(exception);

    expect(result.kind, RemoteExceptionKind.timeout);
    expect(result.rootException, exception);
  });
}
