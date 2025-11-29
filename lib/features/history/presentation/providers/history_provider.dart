import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/network/api_client.dart';

// Imports de tus capas (Ajusta si las rutas relativas varían ligeramente)
import '../../infra/datasources/history_remote_ds.dart';
import '../../infra/repositories/history_repository_impl.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/usecases/get_passenger_history_usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/entities/movement.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';

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

// Proveedor genérico que usa el repository para decidir según el perfil
final getHistoryUseCaseProvider = Provider<GetHistoryUseCase>((ref) {
  final repository = ref.read(historyRepositoryProvider);
  return GetHistoryUseCase(repository);
});

/// Future provider that returns the history for the current user and profile
final historyFutureProvider = FutureProvider.autoDispose<List<Movement>>((ref) async {
  final user = ref.watch(authProvider).value?.usuario;
  if (user == null) return [];
  final usecase = ref.read(getHistoryUseCaseProvider);
  return await usecase.call(user.id, profile: user.perfilActual);
});