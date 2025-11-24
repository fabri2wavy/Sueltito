import '../../domain/entities/movement.dart';
import '../../domain/repositories/history_repository.dart';
// Usamos ruta absoluta para evitar errores de "../"
import 'package:sueltito/features/history/infra/datasources/history_remote_ds.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Movement>> getPassengerHistory(String userId) async {
    // Aquí llamamos al DataSource que conecta con la API
    final models = await remoteDataSource.getPassengerHistory(userId);
    return models;
  }

  @override
  Future<List<Movement>> getDriverHistory(String userId) async {
    // Implementación vacía temporal para cumplir con el contrato
    // (Opcional: podrías crear un método en el DS si lo necesitaras)
    return [];
  }
}