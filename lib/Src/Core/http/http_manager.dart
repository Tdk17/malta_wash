import 'package:dio/dio.dart';
import 'package:malta_wash/Src/Core/auth/session_storage.dart';
import 'package:malta_wash/Src/Core/config/app_config.dart';
import 'package:malta_wash/Src/Core/http/api_exception.dart';
import 'package:malta_wash/Src/Core/http/http_method.dart';

class HttpManager {
  HttpManager({required SessionStorage sessionStorage})
      : _sessionStorage = sessionStorage,
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: const {'Accept': 'application/json'},
          ),
        );

  final Dio _dio;
  final SessionStorage _sessionStorage;

  Future<dynamic> request(
    String path, {
    HttpMethod method = HttpMethod.get,
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    try {
      final headers = <String, dynamic>{};
      if (authenticated) {
        final token = await _sessionStorage.token();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method.name.toUpperCase(),
          headers: headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map) {
        throw ApiException(
          message: (body['message'] ?? 'Falha na comunicação com a API.').toString(),
          code: body['code']?.toString(),
          statusCode: e.response?.statusCode,
          correlationId: body['correlationId']?.toString(),
          details: body['details'],
        );
      }
      throw ApiException(
        message: e.message ?? 'Não foi possível acessar a API.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
