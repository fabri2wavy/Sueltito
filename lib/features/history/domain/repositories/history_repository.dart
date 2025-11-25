import '../entities/movement.dart';

abstract class HistoryRepository {
  Future<List<Movement>> getPassengerHistory(String userId);
  Future<List<Movement>> getDriverHistory(String userId);
}