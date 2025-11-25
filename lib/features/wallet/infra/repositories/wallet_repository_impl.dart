// infra/repositories/wallet_repository_impl.dart
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_ds.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  WalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<double> getBalance(String userId, String profile) async {
    return await remoteDataSource.getBalance(userId, profile);
  }
}