import '../repositories/history_repository.dart';
import '../entities/movement.dart';

class GetPassengerHistoryUseCase {
  final HistoryRepository repository;

  GetPassengerHistoryUseCase(this.repository);

  Future<List<Movement>> call(String userId) async {
    return await repository.getPassengerHistory(userId);
  }
}