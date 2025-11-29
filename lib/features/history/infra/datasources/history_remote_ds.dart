import '../../../../core/network/api_client.dart';
import 'package:sueltito/core/constants/roles.dart';
import 'package:sueltito/features/auth/domain/entities/user.dart';
import '../models/movement_model.dart';

class HistoryRemoteDataSource {
  final ApiClient apiClient;

  HistoryRemoteDataSource(this.apiClient);

  /// Obtiene el historial de pagos realizados (Perfil PASAJERO)
  Future<List<MovementModel>> getPassengerHistory(String userId) async {
    // Delegamos a la versión genérica
    return await getHistory(userId, profile: Roles.pasajero);
  }

  /// Obtiene el historial de cobros realizados (Perfil CONDUCTOR)
  Future<List<MovementModel>> getDriverHistory(String userId) async {
    // Delegamos a la versión genérica. Permitimos que ApiException se propague.
    return await getHistory(userId, profile: Roles.chofer);
  }

  /// Versión genérica: decide el endpoint según el perfil proporcionado.
  /// Si `profile` es null, por compatibilidad puedes usar `getHistoryForUser`.
  Future<List<MovementModel>> getHistory(String userId, {String? profile, int limite = 10}) async {
    final usedProfile = (profile ?? Roles.pasajero).toUpperCase();
      final endpoint = '/user/$userId/move?profile=$usedProfile&limite=$limite';
      print("Llamando a API History: $endpoint");

      final response = await apiClient.get(endpoint);

      if (response != null && response['continuar_flujo'] == true && response['data'] != null) {
        final List<dynamic> lista = response['data'];
        return lista.map((item) => MovementModel.fromJson(item)).toList();
      }

      return [];
    // Any ApiException or other exceptions will be thrown up the stack and should be
    // handled by the callers (usecases / UI) to display the proper message.
  }

  /// Versión que recibe el `User` completo y usa `perfilActual`/`Roles` para decidir.
  Future<List<MovementModel>> getHistoryForUser(User user, {int limite = 10}) async {
    final profile = user.perfilActual ?? (user.esConductor ? Roles.chofer : Roles.pasajero);
    return await getHistory(user.id, profile: profile, limite: limite);
  }
}