class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final String details;
  final int statusCode;
  final String? errorCode;

  ApiResponse._({
    required this.success,
    this.data,
    required this.message,
    required this.details,
    required this.statusCode,
    this.errorCode,
  });

  /// Constructor para respuesta exitosa
  factory ApiResponse.success(
      {required T data,
      required int statusCode,
      String message = 'Operación exitosa',
      String details = 'Ok'}) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
      details: details,
      statusCode: statusCode,
    );
  }

  /// Constructor para respuesta de error
  factory ApiResponse.error({
    required String message,
    required String details,
    required int statusCode,
    String? errorCode,
  }) {
    return ApiResponse._(
      success: false,
      message: message,
      details: details,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }

  /// Verifica si la respuesta es exitosa
  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;

  /// Verifica si hay error
  bool get isError => !success;

  /// Verifica si es error de red
  bool get isNetworkError => statusCode == 0;

  /// Verifica si es timeout
  bool get isTimeout => statusCode == 408;

  /// Verifica si es error de servidor
  bool get isServerError => statusCode >= 500;

  /// Verifica si es error de cliente
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, details: $details, statusCode: $statusCode, data: $data}';
  }
}
