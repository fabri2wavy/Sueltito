import '../../../../core/network/api_client.dart'; 
import '../models/movement_model.dart';

class HistoryRemoteDataSource {
  final ApiClient apiClient;

  HistoryRemoteDataSource(this.apiClient);

  Future<List<MovementModel>> getPassengerHistory(String userId) async {
    try {
      // Llamada al endpoint
      // Asegúrate de que la URL sea la correcta según tu Postman
      // Si en Postman usaste: /api/movimiento/passenger/{id}
      final endpoint = '/user/$userId/move?profile=PASAJERO&limite=4';
      print("Llamando a API: $endpoint"); // Log para verificar
      final response = await apiClient.get(endpoint);

      // Validación de la respuesta REAL
      // JSON: { "continuar_flujo": true, "data": [...] }
      if (response != null && 
          response['continuar_flujo'] == true && 
          response['data'] != null) { // OJO: Aquí usamos 'data'
        
        final List<dynamic> lista = response['data'];
        return lista.map((item) => MovementModel.fromJson(item)).toList();
      }
      
      return []; 
    } catch (e) {
      print('Error en History DS: $e');
      return [];
    }
  }
}