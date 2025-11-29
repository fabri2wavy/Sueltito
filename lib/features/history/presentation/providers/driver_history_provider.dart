import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movement.dart';
import 'package:sueltito/core/constants/roles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'history_provider.dart';

// Provider específico para el historial del CONDUCTOR
final driverHistoryProvider = FutureProvider.autoDispose<List<Movement>>((ref) async {
  final user = ref.watch(authProvider).value?.usuario;
  if (user == null) return [];

  // Usamos el GetHistoryUseCase genérico para mantener la lógica centralizada
  final getHistoryUseCase = ref.read(getHistoryUseCaseProvider);
  return await getHistoryUseCase.call(user.id, profile: Roles.chofer);
});