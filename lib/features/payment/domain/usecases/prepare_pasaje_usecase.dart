import '../repositories/payment_repository.dart';
import '../entities/pasaje_prepare_request.dart';
import '../entities/pasaje_prepare_response.dart';

class PreparePasajeUseCase {
  final PaymentRepository repository;
  PreparePasajeUseCase(this.repository);

  Future<PasajePrepareResponse> call(PasajePrepareRequest request) async {
    return await repository.preparePasaje(request);
  }
}
