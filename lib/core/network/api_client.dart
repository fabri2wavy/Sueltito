import 'package:dio/dio.dart';
import 'api_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  String? _token;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          print('[DIO ERROR] ${error.response?.statusCode}: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String? token) {
    _token = token;
  }

  Dio get dio => _dio;

  // GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PATCH request
  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE request
  Future<T> delete<T>(String path, {T Function(dynamic)? parser}) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  T _handleResponse<T>(Response response, T Function(dynamic)? parser) {
    // Check HTTP status
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      // If the API uses a 'continuar_flujo' boolean to denote business errors,
      // we must detect it even when HTTP status is 200 and raise an exception
      if (response.data is Map && response.data['continuar_flujo'] == false) {
        final message = _extractServerErrorMessage(response.data);
        throw ApiException(statusCode: response.statusCode ?? 0, message: message);
      }

      if (parser != null && response.data != null) {
        return parser(response.data);
      }

      return response.data as T;
    }

    throw ApiException(
      statusCode: response.statusCode ?? 0,
      message: response.statusMessage ?? 'Error desconocido',
    );
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          statusCode: 0,
          message: 'Tiempo de conexión agotado',
        );
      case DioExceptionType.sendTimeout:
        return ApiException(statusCode: 0, message: 'Tiempo de envío agotado');
      case DioExceptionType.receiveTimeout:
        return ApiException(
          statusCode: 0,
          message: 'Tiempo de respuesta agotado',
        );
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final serverMessage = _extractServerErrorMessage(data);
        return ApiException(
          statusCode: error.response?.statusCode ?? 0,
          message: serverMessage,
        );
      case DioExceptionType.cancel:
        return ApiException(statusCode: 0, message: 'Petición cancelada');
      case DioExceptionType.unknown:
        return ApiException(
          statusCode: 0,
          message: 'Error de conexión: ${error.message}',
        );
      default:
        return ApiException(statusCode: 0, message: 'Error desconocido');
    }
  }

  // Try to extract a meaningful message from server responses that follow
  // the structure provided in the issue (mensaje + detalle_error).
  String _extractServerErrorMessage(dynamic data) {
    try {
      if (data == null) return 'Error en la respuesta del servidor';
      if (data is Map) {
        // Top-level 'mensaje'
        if (data['mensaje'] != null && (data['mensaje'] is String)) {
          return data['mensaje'] as String;
        }

        // Generic 'message' fallback
        if (data['message'] != null && (data['message'] is String)) {
          return data['message'] as String;
        }

        // detalle_error -> list -> each has 'error' -> { error: '...' }
        if (data['detalle_error'] != null && data['detalle_error'] is List) {
          final List list = data['detalle_error'] as List;
          final messages = <String>[];
          for (final item in list) {
            if (item is Map) {
              final err = item['error'];
              if (err is Map && err['error'] != null && err['error'] is String) {
                messages.add(err['error'] as String);
              } else if (err is String) {
                messages.add(err);
              }
            }
          }
          if (messages.isNotEmpty) return messages.join('\n');
        }
      }
      // Fallback to some string representation
      return data.toString();
    } catch (_) {
      return 'Error en la respuesta del servidor';
    }
  }
}

// Excepción personalizada
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException [$statusCode]: $message';
}
