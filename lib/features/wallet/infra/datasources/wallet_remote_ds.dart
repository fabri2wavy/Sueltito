import '../../../../core/network/api_client.dart';

class WalletRemoteDataSource {
  final ApiClient apiClient;
  WalletRemoteDataSource(this.apiClient);

  Future<double> getBalance(String userId, String profile) async {
    try {
      final response = await apiClient.get('/user/$userId/balance?profile=$profile');
      if (response != null && response['continuar_flujo'] == true && response['data'] != null) {
        final data = response['data'];
        return double.tryParse(data['saldo']?.toString() ?? '0') ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}