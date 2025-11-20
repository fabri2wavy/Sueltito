import 'package:sueltito/features/auth/domain/entities/profile_change_response.dart';
import 'package:sueltito/features/auth/domain/entities/add_profile_response.dart';

import '../../domain/entities/auth_response.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_ds.dart';
import '../datasources/auth_remote_ds.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthResponse> login(String celular) async {
    final responseModel = await remoteDataSource.login(celular);

    await localDataSource.saveUser(responseModel.usuario as UserModel);

    return responseModel.toEntity(); 
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final requestModel = RegisterRequestModel.fromEntity(request);
    final responseModel = await remoteDataSource.register(requestModel);

    // TODO: token handling
    await localDataSource.saveUser(responseModel.usuario as UserModel);

    return responseModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAuth();
  }

  @override
  Future<void> saveUser(User user) async {
    final model = UserModel.fromEntity(user);
    await localDataSource.saveUser(model);
  }

  @override
  Future<bool> isAuthenticated() async {
    return await localDataSource.isAuthenticated();
  }

  @override
  Future<ProfileChangeResponse> changeProfile(String userId, String newProfile) async {
    final responseModel = await remoteDataSource.changeProfile(userId, newProfile);

    final userModel = await localDataSource.getUser();
    if (userModel != null) {
      final updatedUser = userModel.copyWith(
        perfiles: [newProfile], 
      );
      await localDataSource.saveUser(updatedUser);
    }

    return responseModel.toEntity();
  }

  @override
  Future<AddProfileResponse> addProfile(String userId, String cuenta, String tipoCuenta) async {
    final responseModel = await remoteDataSource.addProfile(userId, cuenta, tipoCuenta);

    // Update local user with the new profiles if present
    final userModel = await localDataSource.getUser();
    if (userModel != null) {
      final perfilList = responseModel.perfil.map((p) => p.perfil).toList();
      final updatedPerfiles = <String>{...userModel.perfiles, ...perfilList}.toList();
      final updatedUser = userModel.copyWith(perfiles: updatedPerfiles);
      await localDataSource.saveUser(updatedUser);
    }

    return responseModel.toEntity();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await localDataSource.getUser();
    return userModel?.toEntity();
  }
}