import 'package:dio/dio.dart';
import 'package:walleto/shared/shared.dart';

import 'base_interceptor.dart';

class CustomLogInterceptor extends BaseInterceptor {
  CustomLogInterceptor({
    this.enableLogRequestInfo = LogConfig.enableLogRequestInfo,
    this.enableLogSuccessResponse = LogConfig.enableLogSuccessResponse,
    this.enableLogErrorResponse = LogConfig.enableLogErrorResponse,
  });

  final bool enableLogRequestInfo;
  final bool enableLogSuccessResponse;
  final bool enableLogErrorResponse;

  static const _enableLogInterceptor = LogConfig.enableLogInterceptor;

  @override
  int get priority => BaseInterceptor.customLogPriority;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_enableLogInterceptor || !enableLogRequestInfo) {
      handler.next(options);

      return;
    }

    final log = <String>[];
    log.add('************ Request ************');
    log.add('🌐 Request: ${options.method} ${options.uri}');
    if (options.headers.isNotEmpty) {
      log.add('🌐 Request Headers:');
      log.add('🌐 ${_prettyBody(options.headers)}');
    }

    if (options.data != null) {
      log.add('🌐 Request Body:');
      log.add('🌐 ${_prettyBody(options.data)}');
    }

    Log.d(log.join('\n'));
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_enableLogInterceptor || !enableLogSuccessResponse) {
      handler.next(response);

      return;
    }

    final log = <String>[];

    log.add('************ Request Response ************');
    log.add('🎉 ${response.requestOptions.method} ${response.requestOptions.uri}');
    log.add('🎉 Request Body: ${_prettyBody(response.requestOptions.data)}');
    log.add('🎉 Success Code: ${response.statusCode}');
    log.add('🎉 ${_prettyBody(response.data)}');

    Log.d(log.join('\n'));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_enableLogInterceptor || !enableLogErrorResponse) {
      handler.next(err);

      return;
    }

    final log = <String>[];

    log.add('************ Request Error ************');
    log.add('⛔️ ${err.requestOptions.method} ${err.requestOptions.uri}');
    log.add('⛔️ Error Code: ${err.response?.statusCode ?? 'unknown status code'}');
    log.add('⛔️ Request Body: ${_prettyBody(err.requestOptions.data)}');
    log.add('⛔️ ${LogRedactor.stringify(err.response?.data)}');

    Log.e(log.join('\n'));
    handler.next(err);
  }

  String _prettyBody(dynamic data) {
    if (data is FormData) {
      return LogRedactor.stringify({
        if (data.fields.isNotEmpty)
          'fields': {for (final field in data.fields) field.key: field.value},
        if (data.files.isNotEmpty)
          'files': [
            for (final file in data.files)
              '${file.key}: File name: ${file.value.filename}, '
                  'Content type: ${file.value.contentType}, Length: ${file.value.length}',
          ],
      });
    }

    return LogRedactor.stringify(data);
  }
}
