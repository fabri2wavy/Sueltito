import '../entities/profile_change_response.dart';
import '../repositories/auth_repository.dart';

class ChangeProfileUseCase {
  final AuthRepository repository;

  ChangeProfileUseCase(this.repository);

  Future<ProfileChangeResponse> call({
    required String userId,
    required String newProfile,
  }) async {
    return await repository.changeProfile(userId, newProfile);
  }
}
