// domain/repositories/wallet_repository.dart
abstract class WalletRepository {
  Future<double> getBalance(String userId, String profile);
}