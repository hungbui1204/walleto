import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

enum RequestMethod { get, post, put, patch, delete }

class ApiClient {
  ApiClient({
    required this.dio,
    this.successResponseMapperType = ApiClientDefaultSetting.defaultSuccessResponseMapperType,
    this.errorResponseMapperType = ApiClientDefaultSetting.defaultErrorResponseMapperType,
  });

  final Dio dio;
  final SuccessResponseMapperType successResponseMapperType;
  final ErrorResponseMapperType errorResponseMapperType;

  Future<T?> request<D extends Object, T extends Object>({
    required RequestMethod method,
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Options? options,
    Decoder<D>? decoder,
    SuccessResponseMapperType? successResponseMapperType,
    ErrorResponseMapperType? errorResponseMapperType,
  }) async {
    try {
      final response = await _requestByMethod(
        method: method,
        path: path,
        queryParameters: queryParameters,
        body: body,
        options: Options(
          extra: options?.extra,
          headers: options?.headers,
          contentType: options?.contentType,
          responseType: options?.responseType,
          sendTimeout: options?.sendTimeout,
          receiveTimeout: options?.receiveTimeout,
        ),
      );

      if (response.data == null || decoder == null) {
        return response.data;
      }

      return BaseSuccessResponseMapper<D, T>.fromType(
        successResponseMapperType ?? this.successResponseMapperType,
      ).map(response: response.data, decoder: decoder, httpStatusCode: response.statusCode);
    } catch (error) {
      throw DioExceptionMapper(
        BaseErrorResponseMapper.fromType(errorResponseMapperType ?? this.errorResponseMapperType),
      ).map(error);
    }
  }

  Future<Response<dynamic>> _requestByMethod({
    required RequestMethod method,
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Options? options,
  }) {
    switch (method) {
      case RequestMethod.get:
        return dio.get(path, data: body, queryParameters: queryParameters, options: options);
      case RequestMethod.post:
        return dio.post(path, data: body, queryParameters: queryParameters, options: options);
      case RequestMethod.patch:
        return dio.patch(path, data: body, queryParameters: queryParameters, options: options);
      case RequestMethod.put:
        return dio.put(path, data: body, queryParameters: queryParameters, options: options);
      case RequestMethod.delete:
        return dio.delete(path, data: body, queryParameters: queryParameters, options: options);
    }
  }

  Future<Response<ResponseBody>> requestStream({
    required String path,
    Object? body,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post<ResponseBody>(
        path,
        data: body,
        cancelToken: cancelToken,
        options: Options(
          extra: options?.extra,
          headers: {
            ...?options?.headers,
            ServerRequestResponseConstants.acceptHeader:
                ServerRequestResponseConstants.acceptTextEventStream,
          },
          contentType: options?.contentType,
          responseType: ResponseType.stream,
          sendTimeout: options?.sendTimeout,
          receiveTimeout: options?.receiveTimeout,
          validateStatus: options?.validateStatus,
        ),
      );
    } on DioException catch (error) {
      throw await _mapStreamingDioException(error);
    } catch (error) {
      throw DioExceptionMapper(
        BaseErrorResponseMapper.fromType(errorResponseMapperType),
      ).map(error);
    }
  }

  Future<RemoteException> _mapStreamingDioException(DioException error) async {
    final mapper = DioExceptionMapper(BaseErrorResponseMapper.fromType(errorResponseMapperType));
    final data = error.response?.data;

    if (data is ResponseBody) {
      final raw = await utf8.decoder.bind(data.stream).join();
      Object? parsed = raw;
      try {
        parsed = jsonDecode(raw);
      } on FormatException {
        parsed = raw;
      }

      return mapper.map(
        DioException(
          requestOptions: error.requestOptions,
          response: Response<dynamic>(
            requestOptions: error.requestOptions,
            statusCode: error.response?.statusCode,
            headers: error.response?.headers,
            data: parsed,
          ),
          type: error.type,
          error: error.error,
        ),
      );
    }

    return mapper.map(error);
  }
}
