import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSource({required this.secureStorage});

  static const _keyUser = 'user_data';
  // TODO: Implementar manejo de token cuando backend lo provea
  // static const _keyToken = 'auth_token';

  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await secureStorage.write(key: _keyUser, value: userJson);
  }

  Future<UserModel?> getUser() async {
    final userJson = await secureStorage.read(key: _keyUser);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  Future<void> clearAuth() async {
    await secureStorage.delete(key: _keyUser);
    // TODO: Limpiar token
  }

  Future<bool> isAuthenticated() async {
    final user = await getUser();
    return user != null;
  }
}