import '../entities/auth_response.dart';
import '../entities/register_request.dart';
import '../entities/profile_change_response.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String celular);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<ProfileChangeResponse> changeProfile(String userId, String newProfile);
  Future<User?> getCurrentUser();
}