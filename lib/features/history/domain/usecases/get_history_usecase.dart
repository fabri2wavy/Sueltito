import '../../domain/repositories/history_repository.dart';
import '../../domain/entities/movement.dart';
import 'package:sueltito/core/constants/roles.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<List<Movement>> call(String userId, {String? profile}) async {
    final p = profile?.toUpperCase();
    if (p != null && Roles.isChofer(p)) {
      return await repository.getDriverHistory(userId);
    }
    // Default to passenger
    return await repository.getPassengerHistory(userId);
  }
}
