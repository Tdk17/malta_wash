class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.correlationId,
    this.details,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final String? correlationId;
  final Object? details;

  @override
  String toString() => message;
}
