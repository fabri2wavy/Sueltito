import '../entities/auth_response.dart';
import '../entities/register_request.dart';
import '../entities/profile_change_response.dart';
import '../entities/user.dart';
import '../entities/add_profile_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String celular);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<ProfileChangeResponse> changeProfile(String userId, String newProfile);
  Future<AddProfileResponse> addProfile(String userId, String cuenta, String tipoCuenta);
  Future<User?> getCurrentUser();
  Future<void> saveUser(User user);
}