import 'package:dio/dio.dart';
import 'package:malta_wash/Src/Core/auth/session_storage.dart';
import 'package:malta_wash/Src/Core/config/app_config.dart';
import 'package:malta_wash/Src/Core/http/api_exception.dart';
import 'package:malta_wash/Src/Core/http/http_method.dart';

class HttpManager {
  HttpManager({required SessionStorage sessionStorage, Dio? dio})
      : _sessionStorage = sessionStorage,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.parseServerUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
                headers: <String, dynamic>{
                  'Accept': 'application/json',
                  'X-Parse-Application-Id': AppConfig.parseApplicationId,
                  if (AppConfig.parseClientKey.isNotEmpty)
                    'X-Parse-Client-Key': AppConfig.parseClientKey,
                },
              ),
            );

  final Dio _dio;
  final SessionStorage _sessionStorage;

  /// Mantém os repositories desacoplados do Parse. Os endpoints lógicos em
  /// /v1 são convertidos aqui para as Cloud Functions já publicadas no
  /// Back4App, sempre via POST /functions/<nome>.
  Future<dynamic> request(
    String path, {
    HttpMethod method = HttpMethod.get,
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    final call = _resolveCloudCall(path, method);
    final parameters = <String, dynamic>{
      ...?queryParameters,
      ..._bodyAsMap(data),
      ...call.pathParameters,
    };

    return cloudFunction(
      name: call.functionName,
      parameters: parameters,
      authenticated: authenticated,
    );
  }

  Future<dynamic> cloudFunction({
    required String name,
    Map<String, dynamic> parameters = const <String, dynamic>{},
    bool authenticated = true,
  }) async {
    final sessionToken = authenticated ? await _sessionStorage.token() : null;
    if (authenticated && (sessionToken == null || sessionToken.isEmpty)) {
      throw const ApiException(
        code: 'UNAUTHENTICATED',
        message: 'A operação exige uma sessão válida.',
        statusCode: 401,
      );
    }

    try {
      final response = await _dio.post<dynamic>(
        '/functions/$name',
        data: parameters,
        options: Options(
          headers: <String, dynamic>{
            if (authenticated && sessionToken != null)
              'X-Parse-Session-Token': sessionToken,
          },
        ),
      );
      return _normalizeResponse(response.data);
    } on DioException catch (error) {
      throw _fromDio(error);
    }
  }

  Map<String, dynamic> _bodyAsMap(Object? data) {
    if (data == null) return const <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{'value': data};
  }

  dynamic _normalizeResponse(dynamic raw) {
    dynamic payload = raw;

    if (raw is Map) {
      final outer = _stringMap(raw);
      if (outer.containsKey('result')) payload = outer['result'];
    }

    if (payload is Map) {
      final body = _stringMap(payload);

      if (body['ok'] == false) {
        final error = body['error'] is Map
            ? _stringMap(body['error'] as Map)
            : <String, dynamic>{};
        throw ApiException(
          code: error['code']?.toString() ?? 'API_ERROR',
          message: error['message']?.toString() ??
              'Não foi possível concluir a operação.',
          statusCode: _intOrNull(error['status']),
          correlationId: error['correlationId']?.toString() ??
              body['correlationId']?.toString(),
          details: error['details'],
        );
      }

      if (body['ok'] == true) return body['data'];

      if (body['code'] != null && body['error'] != null) {
        throw ApiException(
          code: body['code']?.toString(),
          message: body['error']?.toString() ?? 'Falha na API Parse.',
          statusCode: _parseStatus(body['code']),
        );
      }
    }

    return payload;
  }

  ApiException _fromDio(DioException error) {
    final raw = error.response?.data;
    if (raw is Map) {
      final body = _stringMap(raw);
      final nested = body['result'];
      if (nested is Map) {
        final result = _stringMap(nested);
        final resultError = result['error'];
        if (resultError is Map) {
          final apiError = _stringMap(resultError);
          return ApiException(
            code: apiError['code']?.toString(),
            message: apiError['message']?.toString() ??
                'Falha na comunicação com o Back4App.',
            statusCode: error.response?.statusCode,
            correlationId: apiError['correlationId']?.toString(),
            details: apiError['details'],
          );
        }
      }

      return ApiException(
        code: body['code']?.toString(),
        message: (body['error'] ?? body['message'] ??
                'Falha na comunicação com o Back4App.')
            .toString(),
        statusCode: error.response?.statusCode,
        correlationId: body['correlationId']?.toString(),
        details: body['details'],
      );
    }

    return ApiException(
      message: error.message ?? 'Não foi possível acessar o Back4App.',
      statusCode: error.response?.statusCode,
    );
  }

  Map<String, dynamic> _stringMap(Map raw) =>
      raw.map((key, value) => MapEntry(key.toString(), value));

  int? _intOrNull(dynamic value) => int.tryParse(value?.toString() ?? '');

  int? _parseStatus(dynamic parseCode) {
    return switch (int.tryParse(parseCode?.toString() ?? '')) {
      101 => 401,
      119 => 403,
      141 => 400,
      202 || 203 => 409,
      209 => 401,
      _ => null,
    };
  }

  _CloudCall _resolveCloudCall(String rawPath, HttpMethod method) {
    final path = rawPath.split('?').first.trim();

    if (path.startsWith('/functions/')) {
      return _CloudCall(path.substring('/functions/'.length));
    }

    final direct = _directFunctions['${method.name.toUpperCase()} $path'];
    if (direct != null) return _CloudCall(direct);

    for (final rule in _resourceRules) {
      if (path == rule.path) {
        return _CloudCall('${rule.functionPrefix}-${_rootOperation(method)}');
      }

      final detailPrefix = '${rule.path}/';
      if (!path.startsWith(detailPrefix)) continue;

      final remainder = path.substring(detailPrefix.length);
      final parts = remainder
          .split('/')
          .where((part) => part.trim().isNotEmpty)
          .map(Uri.decodeComponent)
          .toList(growable: false);

      if (parts.isEmpty) {
        return _CloudCall('${rule.functionPrefix}-${_rootOperation(method)}');
      }

      final id = parts.first;
      if (parts.length >= 2) {
        final action = parts[1];
        return _CloudCall(
          '${rule.functionPrefix}-$action',
          pathParameters: <String, dynamic>{'id': id},
        );
      }

      return _CloudCall(
        '${rule.functionPrefix}-${_detailOperation(method)}',
        pathParameters: <String, dynamic>{'id': id},
      );
    }

    throw ApiException(
      code: 'ENDPOINT_NOT_MAPPED',
      message: 'Endpoint não mapeado para Cloud Function: $path',
    );
  }

  String _rootOperation(HttpMethod method) {
    return switch (method) {
      HttpMethod.get => 'list',
      HttpMethod.post => 'create',
      HttpMethod.put || HttpMethod.patch => 'update',
      HttpMethod.delete => 'delete',
    };
  }

  String _detailOperation(HttpMethod method) {
    return switch (method) {
      HttpMethod.get => 'get',
      HttpMethod.post || HttpMethod.put || HttpMethod.patch => 'update',
      HttpMethod.delete => 'delete',
    };
  }

  static const Map<String, String> _directFunctions = <String, String>{
    'POST /v1/auth/register': 'v1-auth-register',
    'POST /v1/auth/login': 'v1-auth-login',
    'POST /v1/auth/logout': 'v1-auth-logout',
    'GET /v1/auth/me': 'v1-auth-me',
    'POST /v1/auth/password-reset': 'v1-auth-password-reset',
    'GET /v1/availability': 'v1-availability-list',
    'GET /v1/dashboard/metrics': 'v1-dashboard-metrics',
    'GET /v1/dashboard/operation': 'v1-dashboard-operation',
    'GET /v1/reports/sales': 'v1-reports-sales',
    'GET /v1/reports/services': 'v1-reports-services',
    'GET /v1/reports/customers': 'v1-reports-customers',
    'GET /v1/reports/occupancy': 'v1-reports-occupancy',
    'GET /v1/reports/subscriptions': 'v1-reports-subscriptions',
    'GET /v1/reports/team': 'v1-reports-team',
    'GET /v1/profile': 'v1-profile-get',
    'PATCH /v1/profile': 'v1-profile-update',
    'PUT /v1/profile': 'v1-profile-update',
    'GET /v1/settings': 'v1-settings-get',
    'PATCH /v1/settings': 'v1-settings-update',
    'PUT /v1/settings': 'v1-settings-update',
    'GET /v1/notification-preferences': 'v1-notification-preferences-get',
    'PATCH /v1/notification-preferences':
        'v1-notification-preferences-update',
    'PUT /v1/notification-preferences':
        'v1-notification-preferences-update',
    'POST /v1/coupons/validate': 'v1-coupons-validate',
    'POST /v1/payments/intent': 'v1-payments-intent',
    'POST /v1/reviews': 'v1-reviews-create',
    'GET /v1/admin/reviews': 'v1-admin-reviews-list',
    'POST /v1/uploads/presign': 'v1-uploads-presign',
  };

  static const List<_ResourceRule> _resourceRules = <_ResourceRule>[
    _ResourceRule('/v1/marketing/campaigns', 'v1-marketing-campaigns'),
    _ResourceRule('/v1/marketing/segments', 'v1-marketing-segments'),
    _ResourceRule('/v1/support/tickets', 'v1-support-tickets'),
    _ResourceRule('/v1/support/faqs', 'v1-support-faqs'),
    _ResourceRule('/v1/saas/billing', 'v1-saas-billing'),
    _ResourceRule('/v1/saas/plans', 'v1-saas-plans'),
    _ResourceRule('/v1/feature-flags', 'v1-feature-flags'),
    _ResourceRule('/v1/audit-logs', 'v1-audit-logs'),
    _ResourceRule('/v1/service-addons', 'v1-service-addons'),
    _ResourceRule('/v1/work-orders', 'v1-work-orders'),
    _ResourceRule('/v1/subscriptions', 'v1-subscriptions'),
    _ResourceRule('/v1/appointments', 'v1-appointments'),
    _ResourceRule('/v1/notifications', 'v1-notifications'),
    _ResourceRule('/v1/locations', 'v1-locations'),
    _ResourceRule('/v1/customers', 'v1-customers'),
    _ResourceRule('/v1/vehicles', 'v1-vehicles'),
    _ResourceRule('/v1/services', 'v1-services'),
    _ResourceRule('/v1/packages', 'v1-packages'),
    _ResourceRule('/v1/coupons', 'v1-coupons'),
    _ResourceRule('/v1/payments', 'v1-payments'),
    _ResourceRule('/v1/plans', 'v1-plans'),
    _ResourceRule('/v1/shifts', 'v1-shifts'),
    _ResourceRule('/v1/blocks', 'v1-blocks'),
    _ResourceRule('/v1/loyalty', 'v1-loyalty'),
    _ResourceRule('/v1/tenants', 'v1-tenants'),
    _ResourceRule('/v1/team', 'v1-team'),
  ];
}

class _CloudCall {
  const _CloudCall(
    this.functionName, {
    this.pathParameters = const <String, dynamic>{},
  });

  final String functionName;
  final Map<String, dynamic> pathParameters;
}

class _ResourceRule {
  const _ResourceRule(this.path, this.functionPrefix);

  final String path;
  final String functionPrefix;
}
