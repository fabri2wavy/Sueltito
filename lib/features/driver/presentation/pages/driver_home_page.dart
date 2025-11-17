import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/widgets/app_bottom_navigation.dart';
import 'package:sueltito/core/navigation/constants/navigation_config.dart';
import 'package:sueltito/core/navigation/presentation/providers/navigation_provider.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';

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

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido ${usuario?.nombre ?? 'Usuario'}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/images/logo_with_text.png',
                        height: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bus,
                            color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CEL: ${usuario?.celular ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${usuario?.nombreCompleto ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Ver Renta Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navegar a ver renta
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'VER RENTA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Últimos cobros (estilo historial como PassengerHomePage)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                // Remove white background to match passenger UI. Card below will be the white element.
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mis últimos cobros',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Ver todas las rentas
                          },
                          child: Text(
                            'Ver Rentas',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildHistoryItem(
                                context,
                                'Tramo Corto',
                                '2 personas',
                                'Bs 4.80',
                              ),
                              const Divider(height: 32),
                              _buildHistoryItem(
                                context,
                                'Tramo Largo',
                                '1 persona',
                                'Bs 3.00',
                              ),
                              const Divider(height: 32),
                              _buildHistoryItem(
                                context,
                                'Tramo Preferencia',
                                '1 persona',
                                'Bs 2.00',
                              ),
                            ],
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

  Widget _buildHistoryItem(
    BuildContext context,
    String title,
    String subtitle,
    String amount,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'ver recibo',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryYellow,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}