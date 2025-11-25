import '../../../../core/network/api_client.dart';
import '../models/movement_model.dart';

class HistoryRemoteDataSource {
  final ApiClient apiClient;

  HistoryRemoteDataSource(this.apiClient);

  /// Obtiene el historial de pagos realizados (Perfil PASAJERO)
  Future<List<MovementModel>> getPassengerHistory(String userId) async {
    try {
      // Endpoint para Pasajero
      final endpoint = '/user/$userId/move?profile=PASAJERO&limite=10';
      print("Llamando a API Pasajero: $endpoint");

      final response = await apiClient.get(endpoint);

      if (response != null &&
          response['continuar_flujo'] == true &&
          response['data'] != null) {
        final List<dynamic> lista = response['data'];
        return lista.map((item) => MovementModel.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Error en History DS (Pasajero): $e');
      return [];
    }
  }

  /// Obtiene el historial de cobros realizados (Perfil CONDUCTOR)
  Future<List<MovementModel>> getDriverHistory(String userId) async {
    try {
      // CORRECCIÓN: Usamos 'CONDUCTOR' tal como lo pide tu API
      final endpoint = '/user/$userId/move?profile=CONDUCTOR&limite=10';
      print("Llamando a API Conductor: $endpoint");

      final response = await apiClient.get(endpoint);

      if (response != null &&
          response['continuar_flujo'] == true &&
          response['data'] != null) {
        final List<dynamic> lista = response['data'];
        return lista.map((item) => MovementModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error en History DS (Conductor): $e');
      return [];
    }
  }
}