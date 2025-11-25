import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/network/api_client.dart';
import '../../infra/datasources/wallet_remote_ds.dart';
import '../../infra/repositories/wallet_repository_impl.dart';
import '../../domain/usecases/get_balance_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final walletRepositoryProvider = Provider((ref) => WalletRepositoryImpl(WalletRemoteDataSource(ApiClient())));
final getBalanceUseCaseProvider = Provider((ref) => GetBalanceUseCase(ref.read(walletRepositoryProvider)));

// ESTE es el que usará tu pantalla
final driverBalanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final user = ref.watch(authProvider).value?.usuario;
  if (user == null) return 0.0;
  final useCase = ref.read(getBalanceUseCaseProvider);
  return await useCase.call(user.id, 'CONDUCTOR');
});