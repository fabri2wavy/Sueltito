import '../entities/pasaje_prepare_request.dart';
import '../entities/pasaje_prepare_response.dart';

abstract class PaymentRepository {
  Future<PasajePrepareResponse> preparePasaje(PasajePrepareRequest request);
  Future<PasajePrepareResponse> registerPasaje(PasajePrepareRequest request);
}
