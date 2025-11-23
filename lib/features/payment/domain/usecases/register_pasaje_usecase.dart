import '../repositories/payment_repository.dart';
import '../entities/pasaje_prepare_request.dart';
import '../entities/pasaje_prepare_response.dart';

class RegisterPasajeUseCase {
  final PaymentRepository repository;
  RegisterPasajeUseCase(this.repository);

  Future<PasajePrepareResponse> call(PasajePrepareRequest request) async {
    return await repository.registerPasaje(request);
  }
}
