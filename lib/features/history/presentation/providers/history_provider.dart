import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/network/api_client.dart';

// Imports de tus capas (Ajusta si las rutas relativas varían ligeramente)
import '../../infra/datasources/history_remote_ds.dart';
import '../../infra/repositories/history_repository_impl.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/usecases/get_passenger_history_usecase.dart';

// 1. Provider del DataSource (Crea el ApiClient aquí mismo o usa un provider global si tienes)
final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) {
  return HistoryRemoteDataSource(ApiClient()); 
});

// 2. Provider del Repositorio (Conecta con el DataSource)
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final dataSource = ref.read(historyRemoteDataSourceProvider);
  return HistoryRepositoryImpl(dataSource);
});

// 3. Provider del UseCase (Este es el que llamará tu Pantalla)
final getPassengerHistoryUseCaseProvider = Provider<GetPassengerHistoryUseCase>((ref) {
  final repository = ref.read(historyRepositoryProvider);
  return GetPassengerHistoryUseCase(repository);
});