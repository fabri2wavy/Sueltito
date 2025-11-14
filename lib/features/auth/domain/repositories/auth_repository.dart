import '../entities/auth_response.dart';
import '../entities/register_request.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String celular);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> isAuthenticated();
}