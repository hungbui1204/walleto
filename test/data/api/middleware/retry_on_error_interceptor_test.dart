import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/data/data.dart';

class _ResponseLostAfterAcceptingPostAdapter implements HttpClientAdapter {
  int requestCount = 0;
  int acceptedWriteCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    if (options.method == 'POST') {
      acceptedWriteCount++;
    }

    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      error: const SocketException('server accepted request; response was lost'),
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('does not retry a write when the response is lost after server acceptance', () async {
    final adapter = _ResponseLostAfterAcceptingPostAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(RetryOnErrorInterceptor(dio));

    await expectLater(
      dio.post<dynamic>('/transactions', data: const {'amount': 25}),
      throwsA(isA<DioException>()),
    );

    expect(adapter.acceptedWriteCount, 1);
    expect(adapter.requestCount, 1);
    dio.close();
  });
}
