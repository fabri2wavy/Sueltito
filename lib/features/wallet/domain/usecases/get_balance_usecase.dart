import '../repositories/wallet_repository.dart';

class GetBalanceUseCase {
  final WalletRepository repository;
  GetBalanceUseCase(this.repository);

  Future<double> call(String userId, String profile) async {
    return await repository.getBalance(userId, profile);
  }
}