import '../entities/auth_response.dart';
import '../entities/register_request.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthResponse> call(RegisterRequest request) {
    print('Use case call $request');
    return repository.register(request);
  }
}
