import '../../domain/repositories/payment_repository.dart';
import '../../domain/entities/pasaje_prepare_request.dart';
import '../../domain/entities/pasaje_prepare_response.dart';
import '../datasources/payment_remote_ds.dart';
import '../models/prepare_request_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PasajePrepareResponse> preparePasaje(PasajePrepareRequest request) async {
    final requestModel = PasajePrepareRequestModel.fromEntity(request);
    final responseModel = await remoteDataSource.preparePasaje(requestModel);
    return responseModel.toEntity();
  }
  @override
  Future<PasajePrepareResponse> registerPasaje(PasajePrepareRequest request) async {
    final requestModel = PasajePrepareRequestModel.fromEntity(request);
    final responseModel = await remoteDataSource.registerPasaje(requestModel);
    return responseModel.toEntity();
  }
}
