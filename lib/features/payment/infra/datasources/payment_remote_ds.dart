import 'package:sueltito/core/network/api_client.dart';
import '../models/prepare_request_model.dart';
import '../models/prepare_response_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PasajePrepareResponseModel> preparePasaje(PasajePrepareRequestModel request);
  Future<PasajePrepareResponseModel> registerPasaje(PasajePrepareRequestModel request);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient apiClient;
  PaymentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PasajePrepareResponseModel> preparePasaje(PasajePrepareRequestModel request) async {
    try {
      final response = await apiClient.post('/pasaje/prepare', data: request.toJson());
      return PasajePrepareResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al preparar pasaje: $e');
    }
  }
  @override
  Future<PasajePrepareResponseModel> registerPasaje(PasajePrepareRequestModel request) async {
    try {
      final response = await apiClient.post('/pasaje/register', data: request.toJson());
      return PasajePrepareResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al registrar pasaje: $e');
    }
  }
}
