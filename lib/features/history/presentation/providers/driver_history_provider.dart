import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/network/api_client.dart';
import '../../domain/entities/movement.dart';
import '../../infra/datasources/history_remote_ds.dart';
import '../../infra/repositories/history_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Provider específico para el historial del CONDUCTOR
final driverHistoryProvider = FutureProvider.autoDispose<List<Movement>>((ref) async {
  final user = ref.watch(authProvider).value?.usuario;
  if (user == null) return [];

  // Reusamos las clases que ya tienes en History
  final apiClient = ApiClient();
  final ds = HistoryRemoteDataSource(apiClient); // Asegúrate que el DS tenga el método getDriverHistory
  final repo = HistoryRepositoryImpl(ds);
  
  return await repo.getDriverHistory(user.id);
});