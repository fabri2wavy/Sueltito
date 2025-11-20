import '../repositories/auth_repository.dart';
import '../entities/add_profile_response.dart';

class AddProfileUseCase {
  final AuthRepository repository;
  AddProfileUseCase(this.repository);

  Future<AddProfileResponse> call(String userId, String cuenta, String tipoCuenta) async {
    return await repository.addProfile(userId, cuenta, tipoCuenta);
  }
}
