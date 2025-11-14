import 'package:sueltito/core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/register_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String celular);
  Future<AuthResponseModel> register(RegisterRequestModel request);  
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login(String celular) async {
    try {
      final response = await apiClient.post(
        '/login',
        data: {'celular': celular},
      );

      return AuthResponseModel.fromJson(response);
    } on ApiException catch (e) {
      throw Exception('Error en login: ${e.message}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await apiClient.post(
        '/create',
        data: request.toJson(),  
      );

      return AuthResponseModel.fromJson(response);
    } on ApiException catch (e) {
      throw Exception('Error en registro: ${e.message}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}