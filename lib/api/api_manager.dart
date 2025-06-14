import 'dart:developer';
import 'dart:io';

import 'package:api_manager/api/api_response.dart';
import 'package:api_manager/api/handler/api_connection_error.dart';
import 'package:api_manager/api/handler/api_error.dart';
import 'package:api_manager/api/handler/api_internal_server_error.dart';
import 'package:api_manager/api/response_request_entity.dart';
import 'package:api_manager/api/response_request_mapper.dart';
import 'package:dio/dio.dart';
import 'package:api_manager/api/error_message_parser.dart';

class ApiManager {
  final Dio dio;
  final ResponseRequestMapper _requestMapper = ResponseRequestMapper();
  final ApiResponseParser _responseParser;

  ApiManager({
    ApiResponseParser? responseParser,
    ErrorMessageParser? errorMessageParser,
  }) : _responseParser =
           responseParser ??
           ApiResponseParser(errorMessageParser: errorMessageParser),
       dio = Dio(
         BaseOptions(
           followRedirects: true,
           maxRedirects: 3,
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(seconds: 30),
         ),
       ) {
    _addInterceptors();
  }

  ApiManager.withTimeout({
    required Duration connectTimeout,
    required Duration receiveTimeout,
    ApiResponseParser? responseParser,
    ErrorMessageParser? errorMessageParser,
  }) : _responseParser =
           responseParser ??
           ApiResponseParser(errorMessageParser: errorMessageParser),
       dio = Dio(
         BaseOptions(
           followRedirects: true,
           maxRedirects: 3,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
         ),
       ) {
    _addInterceptors();
  }

  ApiManager.withCustomDio(
    this.dio, {
    ApiResponseParser? responseParser,
    ErrorMessageParser? errorMessageParser,
  }) : _responseParser =
           responseParser ??
           ApiResponseParser(errorMessageParser: errorMessageParser) {
    _addInterceptors();
  }

  Future<ResponseRequestEntity> _handleRequest({
    required Future<Response> Function() request,
    required String method,
    required String url,
    dynamic body,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await request();
      final parsedResponse = _requestMapper.fromDio(response);
      return _responseParser.handleResponse(parsedResponse);
    } on ApiError {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        final originalError = e.error;
        if (originalError is SocketException) {
          throw ApiConnectionError(
            message:
                'Falha na conexão. Verifique sua internet e tente novamente.',
          );
        }
        throw ApiConnectionError(
          message: 'Erro de conexão. Tente novamente mais tarde.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiConnectionError(
          message: 'A conexão demorou muito para responder. Tente novamente.',
        );
      }

      if (e.response != null) {
        final response = _requestMapper.fromDio(e.response!);
        _responseParser.handleResponse(response);
      }

      throw ApiInternalServerError(
        message: e.message ?? 'Erro desconhecido na requisição',
      );
    } catch (e, s) {
      log(
        'Erro inesperado na requisição:\n'
        'Endpoint: $url\n'
        'RequestType: $method\n'
        'Body: $body\n'
        'Erro: $e\nStackTrace: $s',
        time: DateTime.now(),
      );
      throw ApiInternalServerError(message: e.toString());
    }
  }

  Future<ResponseRequestEntity> put(
    String url, {
    required Map<String, dynamic> body,
    required Map<String, dynamic> headers,
    bool isformData = false,
  }) async {
    dynamic data = body;
    if (isformData) {
      data = FormData.fromMap(data);
    }

    return _handleRequest(
      request: () => dio.put(
        url,
        data: data,
        options: Options(headers: headers),
      ),
      method: 'put',
      url: url,
      body: body,
      headers: headers,
    );
  }

  Future<ResponseRequestEntity> delete(
    String url, {
    required Map<String, dynamic> headers,
  }) async {
    return _handleRequest(
      request: () => dio.delete(url, options: Options(headers: headers)),
      method: 'delete',
      url: url,
      headers: headers,
    );
  }

  Future<ResponseRequestEntity> get(
    String url, {
    required Map<String, dynamic> headers,
  }) async {
    return _handleRequest(
      request: () => dio.get(url, options: Options(headers: headers)),
      method: 'get',
      url: url,
      headers: headers,
    );
  }

  Future<ResponseRequestEntity> post(
    String url, {
    required dynamic body,
    required Map<String, dynamic> headers,
    bool isformData = false,
  }) async {
    dynamic data = body;
    if (isformData) {
      data = FormData.fromMap(data);
    }

    return _handleRequest(
      request: () => dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      ),
      method: 'post',
      url: url,
      body: body,
      headers: headers,
    );
  }

  Future<ResponseRequestEntity> patch(
    String url, {
    required dynamic body,
    required Map<String, dynamic> headers,
  }) async {
    return _handleRequest(
      request: () => dio.patch(
        url,
        data: body,
        options: Options(headers: headers),
      ),
      method: 'patch',
      url: url,
      body: body,
      headers: headers,
    );
  }

  void _addInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final startTime = DateTime.now();

          String body = options.data is FormData
              ? formDataToString(options.data as FormData)
              : options.data.toString();

          log(
            '\n==================== INÍCIO REQUISIÇÃO ====================\n'
            '🔗 [${options.method}] ${options.uri}\n'
            '🕒 Iniciado em: $startTime\n'
            '📄 Headers: ${options.headers}\n'
            '📦 Body: $body\n'
            '===========================================================\n',
          );

          options.extra['startTime'] = startTime;
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final startTime =
              response.requestOptions.extra['startTime'] as DateTime?;
          final endTime = DateTime.now();
          final duration = startTime != null
              ? endTime.difference(startTime).inMilliseconds
              : null;

          log(
            '\n==================== RESPOSTA ====================\n'
            '🔗 [${response.requestOptions.method}] ${response.requestOptions.uri}\n'
            '📄 Status: ${response.statusCode}\n'
            '📦 Body: ${response.data}\n'
            '🕒 Tempo: ${duration != null ? "$duration ms" : "N/A"}\n'
            '=================================================\n',
          );

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log(
            '\n==================== ERRO ====================\n'
            '🔗 [${e.requestOptions.method}] ${e.requestOptions.uri}\n'
            '📄 Status: ${e.response?.statusCode}\n'
            '📦 Mensagem: ${e.message}\n'
            '📦 Body: ${e.response?.data}\n'
            '================================================\n',
          );

          return handler.reject(e);
        },
      ),
    );
  }

  String formDataToString(FormData formData) {
    final fields = formData.fields
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    final files = formData.files
        .map((e) => '${e.key}: ${e.value.filename}')
        .join(', ');
    return 'Fields: {$fields}, Files: {$files}';
  }
}
