import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/widgets/app_bottom_navigation.dart';
import 'package:sueltito/core/navigation/constants/navigation_config.dart';
import 'package:sueltito/core/navigation/presentation/providers/navigation_provider.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';

// IMPORTS DE TU LÓGICA
import 'package:sueltito/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:sueltito/features/history/presentation/providers/driver_history_provider.dart'; // <--- Usamos el provider del conductor
import 'package:sueltito/features/history/domain/entities/movement.dart';

class DriverHomePage extends ConsumerWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final navigationItems = NavigationConfig.getDriverItems();

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
        items: navigationItems,
      ),
    );
  }
}

class DriverHomeContent extends ConsumerWidget {
  const DriverHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final auth = ref.watch(authProvider);
    final usuario = auth.value?.usuario;

    // 1. LEEMOS EL SALDO (RENTA) DEL CONDUCTOR
    final balanceAsync = ref.watch(driverBalanceProvider);
    
    // 2. LEEMOS EL HISTORIAL DE COBROS (NO DE PAGOS)
    final historyAsync = ref.watch(driverHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido ${usuario?.nombre ?? 'Usuario'}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                      Image.asset('assets/images/logo_with_text.png', height: 40),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.brown[300], borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bus, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CEL: ${usuario?.celular ?? 'N/A'}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                            Text('${usuario?.nombreCompleto ?? 'N/A'}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- TARJETA DE RENTA (SALDO) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    const Text("Renta Acumulada", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    balanceAsync.when(
                      data: (saldo) => Text('Bs. ${saldo.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      error: (_,__) => const Text('---', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => ref.refresh(driverBalanceProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('ACTUALIZAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            // --- HISTORIAL DE COBROS (CUADRADITO BLANCO) ---
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mis últimos cobros', style: textTheme.titleLarge?.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => ref.refresh(driverHistoryProvider),
                          child: const Text('Refrescar', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Expanded(
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: historyAsync.when(
                            data: (movimientos) {
                              if (movimientos.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "Aún no has realizado cobros.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              return ListView.separated(
                                itemCount: movimientos.length,
                                separatorBuilder: (_,__) => const Divider(),
                                itemBuilder: (context, index) {
                                  final mov = movimientos[index];
                                  return _buildDriverHistoryItem(context, mov);
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, _) => const Center(child: Text("Error de conexión", style: TextStyle(color: Colors.red))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget visual para el ITEM de historial
  Widget _buildDriverHistoryItem(BuildContext context, Movement mov) {
    // Formato de fecha: Día/Mes Hora:Minuto
    final dateStr = "${mov.fecha.day}/${mov.fecha.month} ${mov.fecha.hour.toString().padLeft(2,'0')}:${mov.fecha.minute.toString().padLeft(2,'0')}";
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mov.transporte, // Ej: "MINIBUS"
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textBlack),
              ),
              Text(
                dateStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+ Bs ${mov.monto.toStringAsFixed(2)}', // Signo + porque es ingreso
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
              Text(
                'cobrado',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}