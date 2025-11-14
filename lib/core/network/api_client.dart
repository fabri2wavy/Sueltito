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
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
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
        return ApiException(
          statusCode: error.response?.statusCode ?? 0,
          message:
              error.response?.data?['message'] ??
              error.response?.statusMessage ??
              'Error en la respuesta del servidor',
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
}

// Excepción personalizada
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException [$statusCode]: $message';
}
