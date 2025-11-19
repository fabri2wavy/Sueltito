import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/change_profile_usecase.dart';
import '../../infra/datasources/auth_local_ds.dart';
import '../../infra/datasources/auth_remote_ds.dart';
import '../../infra/repositories/auth_repository_impl.dart';


// TODO: Validate local user on build
class AuthNotifier extends AsyncNotifier<AuthResponse?> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final ChangeProfileUseCase _changeProfileUseCase;
  late final AuthRepositoryImpl _repository;

  @override
  Future<AuthResponse?> build() async {
    final apiClient = ApiClient();
    final secureStorage = FlutterSecureStorage();

    final localDataSource = AuthLocalDataSource(secureStorage: secureStorage);
    final remoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);

    _repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    _loginUseCase = LoginUseCase(_repository);
    _registerUseCase = RegisterUseCase(_repository);
    _changeProfileUseCase = ChangeProfileUseCase(_repository);

    final isAuth = await _repository.isAuthenticated();
    if (isAuth) {
      final currentUser = await _repository.getCurrentUser();
      if (currentUser != null) {
        return AuthResponse(
          continuarFlujo: true,
          usuario: currentUser,
          message: null,
        );
      }
    }
    
    return null;
  }

  Future<void> login(String celular) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loginUseCase(celular));
  }

  Future<void> register(RegisterRequest request) async {
    // Validaciones
    if (request.celular.trim().isEmpty) {
      state = AsyncError(
        Exception('El número de celular es requerido'),
        StackTrace.current,
      );
      return;
    }

    if (request.correo.trim().isEmpty) {
      state = AsyncError(
        Exception('El correo es requerido'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _registerUseCase(request));
  }

  Future<void> changeProfile(String userId, String newProfile) async {
    state = const AsyncLoading();
    
    try {
      final response = await _changeProfileUseCase(
        userId: userId,
        newProfile: newProfile,
      );
      
      final updatedUser = await _repository.getCurrentUser();
      
      if (updatedUser != null) {
        state = AsyncData(
          AuthResponse(
            continuarFlujo: response.continuarFlujo,
            usuario: updatedUser,
            message: response.message,
          ),
        );
      } else {
        throw Exception('No se pudo cargar el usuario actualizado');
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    
    try {
      await _repository.logout();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void clearError() {
    if (state.hasError) {
      state = const AsyncData(null);
    }
  }
}

// ===== Provider principal =====
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthResponse?>(
  AuthNotifier.new,
);

// ===== Computed Providers (helpers opcionales) =====
final currentUserProvider = Provider((ref) {
  return ref.watch(authProvider).value?.usuario;
});

final isAuthenticatedProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.hasValue && authState.value != null;
});