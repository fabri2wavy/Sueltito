import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';

class PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PaymentOptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: AppColors.primaryGreen),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PassengerHomePage extends ConsumerWidget {
  const PassengerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // Lee el usuario desde el provider de auth
    final auth = ref.watch(authProvider);
    final nombre = auth.value?.usuario.nombre?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
          },
        ),
        centerTitle: true,
        title: Text(
          'Bienvenido $nombre',
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'PAGAR',
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: PaymentOptionCard(
                      icon: FontAwesomeIcons.busSimple,
                      label: 'MINIBUS',
                      onTap: () {
                          context.push(AppPaths.minibusPayment);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: PaymentOptionCard(
                      icon: FontAwesomeIcons.taxi,
                      label: 'TRUFIS',
                      onTap: () {
                        context.push(AppPaths.trufisPayment);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: PaymentOptionCard(
                      icon: FontAwesomeIcons.carSide,
                      label: 'TAXI',
                      onTap: () {
                        context.push(AppPaths.taxiPayment);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Historial de Pasajes',
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
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
              const SizedBox(height: 24),
            ],
          ),
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
                'quitar',
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
