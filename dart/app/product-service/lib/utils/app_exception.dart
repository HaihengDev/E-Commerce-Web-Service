class AppException implements Exception {
  final int statusCode;
  final String message;

  AppException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}
